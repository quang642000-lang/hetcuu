package repository.impl;

import config.DBConnect;
import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import repository.IGioHangRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GioHangRepoImpl implements IGioHangRepository {

    private static GioHangRepoImpl instance;

    private GioHangRepoImpl() {}

    public static synchronized GioHangRepoImpl getInstance() {
        if (instance == null) {
            instance = new GioHangRepoImpl();
        }
        return instance;
    }

    @Override
    public GioHang getByKhachHang(String maKh) {
        String sql = "SELECT ma_gh, ma_kh, thoi_gian_tao, thoi_gian_cap_nhat FROM GIO_HANG WHERE ma_kh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new GioHang(
                            rs.getInt("ma_gh"),
                            rs.getString("ma_kh"),
                            rs.getTimestamp("thoi_gian_tao"),
                            rs.getTimestamp("thoi_gian_cap_nhat")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean createGioHang(String maKh) {
        String sql = "INSERT INTO GIO_HANG (ma_kh) VALUES (?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<ChiTietGioHang> getChiTietGioHang(int maGh) {
        List<ChiTietGioHang> list = new ArrayList<>();
        String sql = "SELECT ma_ctgh, ma_gh, ma_sp, ma_size, so_luong, muc_da, muc_duong, ghi_chu_mon, is_chon_mua, thoi_gian_them FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maGh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToChiTietGioHang(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public ChiTietGioHang getChiTietBySpAndSize(int maGh, String maSp, int maSize) {
        String sql = "SELECT ma_ctgh, ma_gh, ma_sp, ma_size, so_luong, muc_da, muc_duong, ghi_chu_mon, is_chon_mua, thoi_gian_them FROM CHI_TIET_GIO_HANG WHERE ma_gh = ? AND ma_sp = ? AND ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maGh);
            ps.setString(2, maSp);
            ps.setInt(3, maSize);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToChiTietGioHang(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean addOrUpdateChiTiet(ChiTietGioHang chiTiet) {
        if (chiTiet.getMaCtgh() > 0) {
            String sql = "UPDATE CHI_TIET_GIO_HANG SET so_luong = ?, muc_da = ?, muc_duong = ?, ghi_chu_mon = ?, is_chon_mua = ? WHERE ma_ctgh = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, chiTiet.getSoLuong());
                ps.setString(2, chiTiet.getMucDa());
                ps.setString(3, chiTiet.getMucDuong());
                ps.setString(4, chiTiet.getGhiChuMon());
                ps.setBoolean(5, chiTiet.isChonMua());
                ps.setLong(6, chiTiet.getMaCtgh());
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        } else {
            String sql = "INSERT INTO CHI_TIET_GIO_HANG (ma_gh, ma_sp, ma_size, so_luong, muc_da, muc_duong, ghi_chu_mon, is_chon_mua) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, chiTiet.getMaGh());
                ps.setString(2, chiTiet.getMaSp());
                ps.setInt(3, chiTiet.getMaSize());
                ps.setInt(4, chiTiet.getSoLuong());
                ps.setString(5, chiTiet.getMucDa());
                ps.setString(6, chiTiet.getMucDuong());
                ps.setString(7, chiTiet.getGhiChuMon());
                ps.setBoolean(8, chiTiet.isChonMua());
                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    try (ResultSet rsKeys = ps.getGeneratedKeys()) {
                        if (rsKeys.next()) {
                            chiTiet.setMaCtgh(rsKeys.getLong(1));
                        }
                    }
                    return true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return false;
        }
    }

    @Override
    public boolean deleteChiTiet(long maCtgh) {
        String sql = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean clearGioHang(int maGh) {
        String sql = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maGh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateTrangThaiChonMua(long maCtgh, boolean isChonMua) {
        String sql = "UPDATE CHI_TIET_GIO_HANG SET is_chon_mua = ? WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isChonMua);
            ps.setLong(2, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<ChiTietToppingGioHang> getToppingByChiTiet(long maCtgh) {
        List<ChiTietToppingGioHang> list = new ArrayList<>();
        // CHỈNH SỬA: Thực hiện INNER JOIN để kéo cột gia_ban của topping lên đối tượng
        String sql = "SELECT ct.ma_ctgh, ct.ma_tp, ct.so_luong_tp, t.gia_ban " +
                "FROM CHI_TIET_TOPPING_GIO_HANG ct " +
                "JOIN TOPPING t ON ct.ma_tp = t.ma_tp " +
                "WHERE ct.ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietToppingGioHang tp = new ChiTietToppingGioHang(
                            rs.getLong("ma_ctgh"),
                            rs.getInt("ma_tp"),
                            rs.getInt("so_luong_tp")
                    );
                    tp.setGiaTp(rs.getInt("gia_ban")); // Gán giá trị bán lẻ chốt cứng của topping
                    list.add(tp);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    @Override
    public boolean addToppingToGioHang(long maCtgh, int maTp, int soLuongTp) {
        String sql = "IF EXISTS (SELECT 1 FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ? AND ma_tp = ?) " +
                "  UPDATE CHI_TIET_TOPPING_GIO_HANG SET so_luong_tp = so_luong_tp + ? WHERE ma_ctgh = ? AND ma_tp = ? " +
                "ELSE " +
                "  INSERT INTO CHI_TIET_TOPPING_GIO_HANG (ma_ctgh, ma_tp, so_luong_tp) VALUES (?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            ps.setInt(2, maTp);
            ps.setInt(3, soLuongTp);
            ps.setLong(4, maCtgh);
            ps.setInt(5, maTp);
            ps.setLong(6, maCtgh);
            ps.setInt(7, maTp);
            ps.setInt(8, soLuongTp);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean removeToppingsFromChiTiet(long maCtgh) {
        String sql = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private ChiTietGioHang mapResultSetToChiTietGioHang(ResultSet rs) throws SQLException {
        return new ChiTietGioHang(
                rs.getLong("ma_ctgh"),
                rs.getInt("ma_gh"),
                rs.getString("ma_sp"),
                rs.getInt("ma_size"),
                rs.getInt("so_luong"),
                rs.getString("muc_da"),
                rs.getString("muc_duong"),
                rs.getString("ghi_chu_mon"),
                rs.getBoolean("is_chon_mua"),
                rs.getTimestamp("thoi_gian_them")
        );
    }
}