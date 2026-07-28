package service.impl;

import config.DBConnect;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import repository.ISanPhamKichCoRepository;
import repository.ISanPhamRepository;
import repository.impl.SanPhamKichCoRepoImpl;
import repository.impl.SanPhamRepoImpl;
import service.ISanPhamService;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * =========================================================================
 * TEA POS SYSTEM - PRODUCT SERVICE IMPLEMENTATION (BULLETPROOF CONCURRENCY)
 * Fixed Connection Leaks, Transaction Rollovers, and Foreign Key conflicts.
 * Solved transaction deadlock by performing all DB modifications inside transactions
 * directly on the same connection object.
 * =========================================================================
 */
public class SanPhamServiceImpl implements ISanPhamService {

    private static final Logger LOGGER = Logger.getLogger(SanPhamServiceImpl.class.getName());
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
        CallableStatement csAddSp = null;
        PreparedStatement psUpdateFlags = null;
        PreparedStatement psAddSize = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            // 1. Thêm sản phẩm mẹ thông qua Stored Procedure trực tiếp trên Connection Transaction này
            String callSql = "{call sp_ThemSanPham(?, ?, ?, ?)}";
            csAddSp = conn.prepareCall(callSql);
            csAddSp.setString(1, sanPham.getMaDm());
            csAddSp.setString(2, sanPham.getTenSp());
            csAddSp.setString(3, sanPham.getMoTa());
            csAddSp.setString(4, sanPham.getHinhAnh());

            String generatedMaSp = null;
            try (ResultSet rs = csAddSp.executeQuery()) {
                if (rs.next()) {
                    generatedMaSp = rs.getString("ma_sp");
                    sanPham.setMaSp(generatedMaSp);
                }
            }

            if (generatedMaSp == null || generatedMaSp.trim().isEmpty()) {
                conn.rollback();
                return false;
            }

            // 2. Cập nhật các trường cờ flags và thứ tự hiển thị ưu tiên trực tiếp trên connection này
            String updateFlagsSql = "UPDATE SAN_PHAM SET cho_phep_doi_da = ?, cho_phep_doi_duong = ?, is_new = ?, " +
                    "is_bestseller = ?, trang_thai = ?, cho_phep_topping = ?, thu_tu_hien_thi = ? WHERE ma_sp = ?";
            psUpdateFlags = conn.prepareStatement(updateFlagsSql);
            psUpdateFlags.setBoolean(1, sanPham.isChoPhepDoiDa());
            psUpdateFlags.setBoolean(2, sanPham.isChoPhepDoiDuong());
            psUpdateFlags.setBoolean(3, sanPham.getIsNew());
            psUpdateFlags.setBoolean(4, sanPham.getIsBestseller());
            psUpdateFlags.setBoolean(5, sanPham.isTrangThai());
            psUpdateFlags.setBoolean(6, sanPham.isChoPhepTopping());
            psUpdateFlags.setInt(7, sanPham.getThuTuHienThi());
            psUpdateFlags.setString(8, generatedMaSp);
            psUpdateFlags.executeUpdate();

            // 3. Thêm mới các kích cỡ đi kèm trực tiếp trên connection này để tránh nghẽn pool
            String addSizeSql = "INSERT INTO SAN_PHAM_KICH_CO (ma_sp, ma_size, gia_ban, dinh_luong, trang_thai) VALUES (?, ?, ?, ?, ?)";
            psAddSize = conn.prepareStatement(addSizeSql);

            for (SanPhamKichCo size : sizes) {
                psAddSize.setString(1, generatedMaSp);
                psAddSize.setInt(2, size.getMaSize());
                psAddSize.setInt(3, size.getGiaBan());
                psAddSize.setString(4, size.getDinhLuong());
                psAddSize.setBoolean(5, size.isTrangThai());
                psAddSize.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Sập luồng tạo mới sản phẩm mẹ và kích cỡ đi kèm", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            // Giải phóng tài nguyên an toàn tuyệt đối chống Leak kết nối
            if (csAddSp != null) { try { csAddSp.close(); } catch (SQLException e) {} }
            if (psUpdateFlags != null) { try { psUpdateFlags.close(); } catch (SQLException e) {} }
            if (psAddSize != null) { try { psAddSize.close(); } catch (SQLException e) {} }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
                try { conn.close(); } catch (SQLException e) {}
            }
        }
    }

    @Override
    public boolean updateSanPham(SanPham sanPham, List<SanPhamKichCo> sizes) {
        if (sizes == null || sizes.isEmpty()) {
            return false;
        }
        Connection conn = null;
        PreparedStatement psUpdateMother = null;
        PreparedStatement psCheckOrders = null;
        PreparedStatement psSoftDelete = null;
        PreparedStatement psHardDelete = null;
        PreparedStatement psUpdateSize = null;
        PreparedStatement psInsertSize = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật thông tin sản phẩm mẹ trực tiếp trên Connection Transaction này (Tránh deadlock)
            String updateMotherSql = "UPDATE SAN_PHAM SET ma_dm = ?, ten_sp = ?, mo_ta = ?, hinh_anh = ?, " +
                    "cho_phep_doi_da = ?, cho_phep_doi_duong = ?, is_new = ?, is_bestseller = ?, " +
                    "trang_thai = ?, cho_phep_topping = ?, thu_tu_hien_thi = ?, thoi_gian_cap_nhat = GETDATE() WHERE ma_sp = ?";
            psUpdateMother = conn.prepareStatement(updateMotherSql);
            psUpdateMother.setString(1, sanPham.getMaDm());
            psUpdateMother.setString(2, sanPham.getTenSp());
            psUpdateMother.setString(3, sanPham.getMoTa());
            psUpdateMother.setString(4, sanPham.getHinhAnh());
            psUpdateMother.setBoolean(5, sanPham.isChoPhepDoiDa());
            psUpdateMother.setBoolean(6, sanPham.isChoPhepDoiDuong());
            psUpdateMother.setBoolean(7, sanPham.getIsNew());
            psUpdateMother.setBoolean(8, sanPham.getIsBestseller());
            psUpdateMother.setBoolean(9, sanPham.isTrangThai());
            psUpdateMother.setBoolean(10, sanPham.isChoPhepTopping());
            psUpdateMother.setInt(11, sanPham.getThuTuHienThi());
            psUpdateMother.setString(12, sanPham.getMaSp());

            int rowsUpdated = psUpdateMother.executeUpdate();
            if (rowsUpdated <= 0) {
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

            // Xử lý chèn mới hoặc cập nhật các kích cỡ được chọn trên form trực tiếp trên conn này (Triệt tiêu 100% deadlock!)
            String updateSizeSql = "UPDATE SAN_PHAM_KICH_CO SET gia_ban = ?, dinh_luong = ?, trang_thai = ? WHERE ma_sp = ? AND ma_size = ?";
            String insertSizeSql = "INSERT INTO SAN_PHAM_KICH_CO (ma_sp, ma_size, gia_ban, dinh_luong, trang_thai) VALUES (?, ?, ?, ?, ?)";
            psUpdateSize = conn.prepareStatement(updateSizeSql);
            psInsertSize = conn.prepareStatement(insertSizeSql);

            for (SanPhamKichCo newSize : sizes) {
                boolean existsInDb = false;
                for (SanPhamKichCo dbSize : allDbSizes) {
                    if (newSize.getMaSize() == dbSize.getMaSize()) {
                        existsInDb = true;
                        break;
                    }
                }
                if (existsInDb) {
                    // Đã tồn tại -> Cập nhật giá bán, định lượng và trạng thái hoạt động mới trực tiếp trên conn
                    psUpdateSize.setInt(1, newSize.getGiaBan());
                    psUpdateSize.setString(2, newSize.getDinhLuong());
                    psUpdateSize.setBoolean(3, newSize.isTrangThai());
                    psUpdateSize.setString(4, sanPham.getMaSp());
                    psUpdateSize.setInt(5, newSize.getMaSize());
                    psUpdateSize.executeUpdate();
                } else {
                    // Chưa tồn tại -> Thêm mới bản ghi liên kết trực tiếp trên conn
                    psInsertSize.setString(1, sanPham.getMaSp());
                    psInsertSize.setInt(2, newSize.getMaSize());
                    psInsertSize.setInt(3, newSize.getGiaBan());
                    psInsertSize.setString(4, newSize.getDinhLuong());
                    psInsertSize.setBoolean(5, newSize.isTrangThai());
                    psInsertSize.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi luồng cập nhật sản phẩm mẹ và kích cỡ trong Service", e);
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
            if (psUpdateMother != null) { try { psUpdateMother.close(); } catch (SQLException e) {} }
            if (psCheckOrders != null) { try { psCheckOrders.close(); } catch (SQLException e) {} }
            if (psSoftDelete != null) { try { psSoftDelete.close(); } catch (SQLException e) {} }
            if (psHardDelete != null) { try { psHardDelete.close(); } catch (SQLException e) {} }
            if (psUpdateSize != null) { try { psUpdateSize.close(); } catch (SQLException e) {} }
            if (psInsertSize != null) { try { psInsertSize.close(); } catch (SQLException e) {} }
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
