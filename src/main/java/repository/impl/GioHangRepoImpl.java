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
        String sql = "SELECT * FROM GIO_HANG WHERE ma_kh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    GioHang gh = new GioHang();
                    gh.setMaGh(rs.getInt("ma_gh"));
                    gh.setMaKh(rs.getString("ma_kh"));
                    gh.setThoiGianTao(rs.getTimestamp("thoi_gian_tao"));
                    gh.setThoiGianCapNhat(rs.getTimestamp("thoi_gian_cap_nhat"));
                    return gh;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean createGioHang(String maKh) {
        String sql = "INSERT INTO GIO_HANG (ma_kh, thoi_gian_tao) VALUES (?, GETDATE())";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<ChiTietGioHang> getChiTietGioHang(int maGh) {
        List<ChiTietGioHang> list = new ArrayList<>();
        String sql = "SELECT ct.*, sp.ten_sp, sp.hinh_anh, sz.ten_size, sk.gia_ban " +
                "FROM CHI_TIET_GIO_HANG ct " +
                "JOIN SAN_PHAM sp ON ct.ma_sp = sp.ma_sp " +
                "JOIN KICH_CO sz ON ct.ma_size = sz.ma_size " +
                "JOIN SAN_PHAM_KICH_CO sk ON ct.ma_sp = sk.ma_sp AND ct.ma_size = sk.ma_size " +
                "WHERE ct.ma_gh = ? ORDER BY ct.thoi_gian_them DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maGh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietGioHang ct = new ChiTietGioHang();
                    ct.setMaCtgh(rs.getLong("ma_ctgh"));
                    ct.setMaGh(rs.getInt("ma_gh"));
                    ct.setMaSp(rs.getString("ma_sp"));
                    ct.setMaSize(rs.getInt("ma_size"));
                    ct.setSoLuong(rs.getInt("so_luong"));
                    ct.setMucDa(rs.getString("muc_da"));
                    ct.setMucDuong(rs.getString("muc_duong"));
                    ct.setGhiChuMon(rs.getString("ghi_chu_mon"));
                    ct.setChonMua(rs.getBoolean("is_chon_mua"));
                    ct.setThoiGianThem(rs.getTimestamp("thoi_gian_them"));
                    ct.setTenSp(rs.getString("ten_sp"));
                    ct.setHinhAnh(rs.getString("hinh_anh"));
                    ct.setTenSize(rs.getString("ten_size"));
                    ct.setGiaBan(rs.getInt("gia_ban"));
                    list.add(ct);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<ChiTietToppingGioHang> getToppingByChiTiet(long maCtgh) {
        List<ChiTietToppingGioHang> list = new ArrayList<>();
        String sql = "SELECT ct.*, t.ten_tp, t.gia_ban " +
                "FROM CHI_TIET_TOPPING_GIO_HANG ct " +
                "JOIN TOPPING t ON ct.ma_tp = t.ma_tp " +
                "WHERE ct.ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietToppingGioHang ct = new ChiTietToppingGioHang();
                    ct.setMaCtgh(rs.getLong("ma_ctgh"));
                    ct.setMaTp(rs.getString("ma_tp"));
                    ct.setSoLuongTp(rs.getInt("so_luong_tp"));
                    ct.setGiaTp(rs.getInt("gia_ban"));
                    ct.setTenTp(rs.getString("ten_tp"));
                    list.add(ct);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public ChiTietGioHang getChiTietBySpAndSize(int maGh, String maSp, int maSize) {
        String sql = "SELECT * FROM CHI_TIET_GIO_HANG WHERE ma_gh = ? AND ma_sp = ? AND ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maGh);
            ps.setString(2, maSp);
            ps.setInt(3, maSize);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChiTietGioHang ct = new ChiTietGioHang();
                    ct.setMaCtgh(rs.getLong("ma_ctgh"));
                    ct.setMaGh(rs.getInt("ma_gh"));
                    ct.setMaSp(rs.getString("ma_sp"));
                    ct.setMaSize(rs.getInt("ma_size"));
                    ct.setSoLuong(rs.getInt("so_luong"));
                    ct.setMucDa(rs.getString("muc_da"));
                    ct.setMucDuong(rs.getString("muc_duong"));
                    ct.setGhiChuMon(rs.getString("ghi_chu_mon"));
                    ct.setChonMua(rs.getBoolean("is_chon_mua"));
                    ct.setThoiGianThem(rs.getTimestamp("thoi_gian_them"));
                    return ct;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean addOrUpdateChiTiet(ChiTietGioHang chiTiet) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean isUpdate = chiTiet.getMaCtgh() > 0;

        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); // Begin transaction!

            if (isUpdate) {
                // If it is a partial update (like simple quantity update) or full gộp món update:
                String sql = "UPDATE CHI_TIET_GIO_HANG SET so_luong = ?, is_chon_mua = ? ";
                // Update text fields only if they are supplied (to prevent overriding with null on basic qty changes)
                if (chiTiet.getMucDa() != null) sql += ", muc_da = ? ";
                if (chiTiet.getMucDuong() != null) sql += ", muc_duong = ? ";
                if (chiTiet.getGhiChuMon() != null) sql += ", ghi_chu_mon = ? ";
                sql += "WHERE ma_ctgh = ?";

                ps = conn.prepareStatement(sql);
                int idx = 1;
                ps.setInt(idx++, chiTiet.getSoLuong());
                ps.setBoolean(idx++, chiTiet.isChonMua());
                if (chiTiet.getMucDa() != null) ps.setString(idx++, chiTiet.getMucDa());
                if (chiTiet.getMucDuong() != null) ps.setString(idx++, chiTiet.getMucDuong());
                if (chiTiet.getGhiChuMon() != null) ps.setString(idx++, chiTiet.getGhiChuMon());
                ps.setLong(idx, chiTiet.getMaCtgh());
                ps.executeUpdate();

                // If toppings are supplied on update, let's sync toppings (clear and insert)
                if (chiTiet.getToppingGioHangList() != null) {
                    String delSql = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
                    try (PreparedStatement delPs = conn.prepareStatement(delSql)) {
                        delPs.setLong(1, chiTiet.getMaCtgh());
                        delPs.executeUpdate();
                    }
                }
            } else {
                // INSERT BRAND NEW COCKTAIL LINE
                String sql = "INSERT INTO CHI_TIET_GIO_HANG (ma_gh, ma_sp, ma_size, so_luong, muc_da, muc_duong, ghi_chu_mon, is_chon_mua) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, chiTiet.getMaGh());
                ps.setString(2, chiTiet.getMaSp());
                ps.setInt(3, chiTiet.getMaSize());
                ps.setInt(4, chiTiet.getSoLuong());
                ps.setString(5, chiTiet.getMucDa() != null ? chiTiet.getMucDa() : "100% Đá");
                ps.setString(6, chiTiet.getMucDuong() != null ? chiTiet.getMucDuong() : "100% Đường");
                ps.setString(7, chiTiet.getGhiChuMon() != null ? chiTiet.getGhiChuMon() : "");
                ps.setBoolean(8, chiTiet.isChonMua());
                ps.executeUpdate();

                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    chiTiet.setMaCtgh(rs.getLong(1));
                }
            }

            // Sync Toppings if provided
            if (chiTiet.getToppingGioHangList() != null && !chiTiet.getToppingGioHangList().isEmpty()) {
                String topSql = "INSERT INTO CHI_TIET_TOPPING_GIO_HANG (ma_ctgh, ma_tp, so_luong_tp) VALUES (?, ?, ?)";
                try (PreparedStatement topPs = conn.prepareStatement(topSql)) {
                    for (ChiTietToppingGioHang top : chiTiet.getToppingGioHangList()) {
                        topPs.setLong(1, chiTiet.getMaCtgh());
                        topPs.setString(2, top.getMaTp());
                        topPs.setInt(3, top.getSoLuongTp());
                        topPs.addBatch();
                    }
                    topPs.executeBatch();
                }
            }

            conn.commit(); // Success! Commit transaction.
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (rs != null) { try { rs.close(); } catch (Exception e) { e.printStackTrace(); } }
            if (ps != null) { try { ps.close(); } catch (Exception e) { e.printStackTrace(); } }
        }
    }

    @Override
    public boolean deleteChiTiet(long maCtgh) {
        Connection conn = null;
        PreparedStatement psTop = null;
        PreparedStatement psItem = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            String sqlTop = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
            psTop = conn.prepareStatement(sqlTop);
            psTop.setLong(1, maCtgh);
            psTop.executeUpdate();

            String sqlItem = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_ctgh = ?";
            psItem = conn.prepareStatement(sqlItem);
            psItem.setLong(1, maCtgh);
            int rows = psItem.executeUpdate();

            conn.commit();
            return rows > 0;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (psTop != null) { try { psTop.close(); } catch (Exception e) { e.printStackTrace(); } }
            if (psItem != null) { try { psItem.close(); } catch (Exception e) { e.printStackTrace(); } }
        }
    }

    @Override
    public boolean clearGioHang(int maGh) {
        Connection conn = null;
        PreparedStatement psTop = null;
        PreparedStatement psItem = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            String sqlTop = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh IN (SELECT ma_ctgh FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?)";
            psTop = conn.prepareStatement(sqlTop);
            psTop.setInt(1, maGh);
            psTop.executeUpdate();

            String sqlItem = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?";
            psItem = conn.prepareStatement(sqlItem);
            psItem.setInt(1, maGh);
            psItem.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (psTop != null) { try { psTop.close(); } catch (Exception e) { e.printStackTrace(); } }
            if (psItem != null) { try { psItem.close(); } catch (Exception e) { e.printStackTrace(); } }
        }
    }

    @Override
    public boolean updateTrangThaiChonMua(long maCtgh, boolean isChon) {
        String sql = "UPDATE CHI_TIET_GIO_HANG SET is_chon_mua = ? WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isChon);
            ps.setLong(2, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean addToppingToGioHang(long maCtgh, String maTp, int qty) {
        String sql = "INSERT INTO CHI_TIET_TOPPING_GIO_HANG (ma_ctgh, ma_tp, so_luong_tp) VALUES (?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE so_luong_tp = so_luong_tp + VALUES(so_luong_tp)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            ps.setString(2, maTp);
            ps.setInt(3, qty);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            // Fallback if ON DUPLICATE KEY is not supported in MS SQL Server
            try {
                String msSql = "IF EXISTS (SELECT 1 FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ? AND ma_tp = ?) " +
                        "UPDATE CHI_TIET_TOPPING_GIO_HANG SET so_luong_tp = so_luong_tp + ? WHERE ma_ctgh = ? AND ma_tp = ? " +
                        "ELSE INSERT INTO CHI_TIET_TOPPING_GIO_HANG (ma_ctgh, ma_tp, so_luong_tp) VALUES (?, ?, ?)";
                try (Connection conn = DBConnect.getConnection();
                     PreparedStatement ps2 = conn.prepareStatement(msSql)) {
                    ps2.setLong(1, maCtgh);
                    ps2.setString(2, maTp);
                    ps2.setInt(3, qty);
                    ps2.setLong(4, maCtgh);
                    ps2.setString(5, maTp);
                    ps2.setLong(6, maCtgh);
                    ps2.setString(7, maTp);
                    ps2.setInt(8, qty);
                    return ps2.executeUpdate() > 0;
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                return false;
            }
        }
    }

    @Override
    public boolean removeToppingsFromChiTiet(long maCtgh) {
        String sql = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
