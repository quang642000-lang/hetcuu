package service.impl;

import config.DBConnect;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import repository.ISanPhamKichCoRepository;
import repository.ISanPhamRepository;
import repository.impl.SanPhamKichCoRepoImpl;
import repository.impl.SanPhamRepoImpl;
import service.ISanPhamService;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * =========================================================================
 * TEA POS SYSTEM - PRODUCT SERVICE IMPLEMENTATION (BULLETPROOF CONCURRENCY)
 * Fixed Connection Leaks, Transaction Rollovers, and Foreign Key conflicts with Cart details.
 * =========================================================================
 */
public class SanPhamServiceImpl implements ISanPhamService {
    private static SanPhamServiceImpl instance;
    private final ISanPhamRepository sanPhamRepository;
    private final ISanPhamKichCoRepository sanPhamKichCoRepository;

    private SanPhamServiceImpl() {
        this.sanPhamRepository = SanPhamRepoImpl.getInstance();
        this.sanPhamKichCoRepository = SanPhamKichCoRepoImpl.getInstance();
    }

    public static synchronized SanPhamServiceImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamServiceImpl();
        }
        return instance;
    }

    @Override
    public List<SanPham> getAllSanPham() {
        return sanPhamRepository.getAll();
    }

    @Override
    public SanPham getSanPhamById(String id) {
        return sanPhamRepository.getById(id);
    }

    @Override
    public List<SanPham> getSanPhamByDanhMuc(String maDm) {
        return sanPhamRepository.getByDanhMuc(maDm);
    }

    @Override
    public List<SanPham> getBestsellers() {
        return sanPhamRepository.getBestsellers();
    }

    @Override
    public List<SanPham> getNewArrivals() {
        return sanPhamRepository.getNewArrivals();
    }

    @Override
    public List<SanPham> searchSanPham(String keyword) {
        return sanPhamRepository.searchByName(keyword);
    }

    @Override
    public boolean createSanPham(SanPham sanPham, List<SanPhamKichCo> sizes) {
        if (sizes == null || sizes.isEmpty()) {
            return false;
        }
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);
            boolean addedSp = sanPhamRepository.add(sanPham);
            if (!addedSp || sanPham.getMaSp() == null) {
                conn.rollback();
                return false;
            }
            for (SanPhamKichCo size : sizes) {
                size.setMaSp(sanPham.getMaSp());
                boolean addedSize = sanPhamKichCoRepository.add(size);
                if (!addedSize) {
                    conn.rollback();
                    return false;
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public boolean updateSanPham(SanPham sanPham, List<SanPhamKichCo> sizes) {
        if (sizes == null || sizes.isEmpty()) {
            return false;
        }
        Connection conn = null;
        PreparedStatement psCheckOrders = null;
        PreparedStatement psSoftDelete = null;
        PreparedStatement psHardDelete = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật thông tin sản phẩm mẹ
            boolean updatedSp = sanPhamRepository.update(sanPham);
            if (!updatedSp) {
                conn.rollback();
                return false;
            }

            // 2. Lấy danh sách kích cỡ hiện tại từ DB (bao gồm tất cả để đối soát trạng thái)
            List<SanPhamKichCo> allDbSizes = new ArrayList<>();
            String selectAllSql = "SELECT ma_sp, ma_size, gia_ban, dinh_luong, trang_thai FROM SAN_PHAM_KICH_CO WHERE ma_sp = ?";
            try (PreparedStatement ps = conn.prepareStatement(selectAllSql)) {
                ps.setString(1, sanPham.getMaSp());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        allDbSizes.add(new SanPhamKichCo(
                                rs.getString("ma_sp"),
                                rs.getInt("ma_size"),
                                rs.getInt("gia_ban"),
                                rs.getString("dinh_luong"),
                                rs.getBoolean("trang_thai")
                        ));
                    }
                }
            }

            // CHỐT CHẶN PHÒNG THỦ: Kiểm toán lồng ghép cả CHI_TIET_DON_HANG (đã thanh toán/bán) và CHI_TIET_GIO_HANG (trong giỏ của khách)
            // Triệt tiêu hoàn toàn lỗi vi phạm khóa ngoại (REFERENCE constraint) khi xóa cứng biến thể!
            String checkOrdersSql = "SELECT " +
                    "  (SELECT COUNT(*) FROM CHI_TIET_DON_HANG WHERE ma_sp = ? AND ma_size = ?) + " +
                    "  (SELECT COUNT(*) FROM CHI_TIET_GIO_HANG WHERE ma_sp = ? AND ma_size = ?)";
            String softDeleteSql = "UPDATE SAN_PHAM_KICH_CO SET trang_thai = 0 WHERE ma_sp = ? AND ma_size = ?";
            String hardDeleteSql = "DELETE FROM SAN_PHAM_KICH_CO WHERE ma_sp = ? AND ma_size = ?";

            psCheckOrders = conn.prepareStatement(checkOrdersSql);
            psSoftDelete = conn.prepareStatement(softDeleteSql);
            psHardDelete = conn.prepareStatement(hardDeleteSql);

            // Xử lý các kích cỡ cũ đã bị bỏ chọn khỏi form
            for (SanPhamKichCo dbSize : allDbSizes) {
                boolean stillSelected = false;
                for (SanPhamKichCo newSize : sizes) {
                    if (newSize.getMaSize() == dbSize.getMaSize()) {
                        stillSelected = true;
                        break;
                    }
                }
                if (!stillSelected) {
                    // Size này đã bị deselect khỏi form. Kiểm tra xem đã bán đơn nào hoặc có trong giỏ hàng nào chưa!
                    psCheckOrders.setString(1, sanPham.getMaSp());
                    psCheckOrders.setInt(2, dbSize.getMaSize());
                    psCheckOrders.setString(3, sanPham.getMaSp());
                    psCheckOrders.setInt(4, dbSize.getMaSize());
                    try (ResultSet rs = psCheckOrders.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            // Đã bán hoặc đã nằm trong giỏ hàng -> Chỉ cho phép tắt trạng thái (Soft Delete) để bảo toàn dữ liệu
                            psSoftDelete.setString(1, sanPham.getMaSp());
                            psSoftDelete.setInt(2, dbSize.getMaSize());
                            psSoftDelete.executeUpdate();
                        } else {
                            // Chưa bán và không nằm trong giỏ -> Cho phép xóa cứng hoàn toàn khỏi cơ sở dữ liệu
                            psHardDelete.setString(1, sanPham.getMaSp());
                            psHardDelete.setInt(2, dbSize.getMaSize());
                            psHardDelete.executeUpdate();
                        }
                    }
                }
            }

            // Xử lý chèn mới hoặc cập nhật các kích cỡ được chọn trên form
            for (SanPhamKichCo newSize : sizes) {
                boolean existsInDb = false;
                for (SanPhamKichCo dbSize : allDbSizes) {
                    if (newSize.getMaSize() == dbSize.getMaSize()) {
                        existsInDb = true;
                        break;
                    }
                }
                if (existsInDb) {
                    // Đã tồn tại -> Cập nhật giá bán, định lượng và trạng thái hoạt động mới
                    boolean updatedSize = sanPhamKichCoRepository.update(newSize);
                    if (!updatedSize) {
                        conn.rollback();
                        return false;
                    }
                } else {
                    // Chưa tồn tại -> Thêm mới bản ghi liên kết vào DB
                    newSize.setMaSp(sanPham.getMaSp());
                    boolean addedSize = sanPhamKichCoRepository.add(newSize);
                    if (!addedSize) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            // ĐÓNG TÀI NGUYÊN AN TOÀN TUYỆT ĐỐI (Gỡ bỏ Connection Leak rò rỉ bộ đệm HikariCP)
            if (psCheckOrders != null) { try { psCheckOrders.close(); } catch (SQLException e) {} }
            if (psSoftDelete != null) { try { psSoftDelete.close(); } catch (SQLException e) {} }
            if (psHardDelete != null) { try { psHardDelete.close(); } catch (SQLException e) {} }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    // Bỏ qua lỗi cấu hình autocommit trong finally
                }
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public boolean deleteSanPham(String id) {
        return sanPhamRepository.delete(id);
    }

    @Override
    public List<SanPhamKichCo> getSizesBySanPham(String maSp) {
        return sanPhamKichCoRepository.getBySanPham(maSp);
    }

    @Override
    public int getGiaKichCoSanPham(String maSp, int maSize) {
        SanPhamKichCo spkc = sanPhamKichCoRepository.getBySanPhamAndSize(maSp, maSize);
        return spkc != null ? spkc.getGiaBan() : 0;
    }
}
