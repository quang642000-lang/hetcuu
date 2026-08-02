package repository.impl;

import config.DBConnect;
import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import model.entity.SanPham;
import repository.IGioHangRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GioHangRepoImpl implements IGioHangRepository {
    private static GioHangRepoImpl instance;
    private final RowMapper<GioHang> rowMapper = rs -> new GioHang(
            rs.getInt("ma_gh"),
            rs.getString("ma_kh"),
            rs.getTimestamp("thoi_gian_tao"),
            rs.getTimestamp("thoi_gian_cap_nhat")
    );

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
        return JdbcHelper.queryForObject(sql, rowMapper, maKh);
    }

    @Override
    public boolean createGioHang(String maKh) {
        String sql = "INSERT INTO GIO_HANG (ma_kh, thoi_gian_tao) VALUES (?, GETDATE())";
        return JdbcHelper.update(sql, maKh) > 0;
    }

    @Override
    public List<ChiTietGioHang> getChiTietGioHang(int maGh) {
        String sql = "SELECT ct.*, sz.ten_size, sk.gia_ban, sp.ten_sp, sp.hinh_anh, sp.cho_phep_doi_da, sp.cho_phep_doi_duong " +
                "FROM CHI_TIET_GIO_HANG ct " +
                "JOIN SAN_PHAM sp ON ct.ma_sp = sp.ma_sp " +
                "JOIN KICH_CO sz ON ct.ma_size = sz.ma_size " +
                "JOIN SAN_PHAM_KICH_CO sk ON ct.ma_sp = sk.ma_sp AND ct.ma_size = sk.ma_size " +
                "WHERE ct.ma_gh = ? ORDER BY ct.thoi_gian_them DESC";
        RowMapper<ChiTietGioHang> mapper = rs -> {
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
            ct.setTenSize(rs.getString("ten_size"));
            ct.setGiaBan(rs.getInt("gia_ban"));

            SanPham sp = new SanPham();
            sp.setMaSp(rs.getString("ma_sp"));
            sp.setTenSp(rs.getString("ten_sp"));
            sp.setHinhAnh(rs.getString("hinh_anh"));
            sp.setChoPhepDoiDa(rs.getBoolean("cho_phep_doi_da"));
            sp.setChoPhepDoiDuong(rs.getBoolean("cho_phep_doi_duong"));
            ct.setSanPham(sp);
            return ct;
        };
        return JdbcHelper.query(sql, mapper, maGh);
    }

    @Override
    public List<ChiTietToppingGioHang> getToppingByChiTiet(long maCtgh) {
        String sql = "SELECT ct.*, t.ten_tp, t.gia_ban " +
                "FROM CHI_TIET_TOPPING_GIO_HANG ct " +
                "JOIN TOPPING t ON ct.ma_tp = t.ma_tp " +
                "WHERE ct.ma_ctgh = ?";
        RowMapper<ChiTietToppingGioHang> mapper = rs -> {
            ChiTietToppingGioHang ct = new ChiTietToppingGioHang();
            ct.setMaCtgh(rs.getLong("ma_ctgh"));
            ct.setMaTp(rs.getString("ma_tp"));
            ct.setSoLuongTp(rs.getInt("so_luong_tp"));
            ct.setGiaTp(rs.getInt("gia_ban"));
            ct.setTenTp(rs.getString("ten_tp"));
            return ct;
        };
        return JdbcHelper.query(sql, mapper, maCtgh);
    }

    @Override
    public ChiTietGioHang getChiTietBySpAndSize(int maGh, String maSp, int maSize) {
        String sql = "SELECT * FROM CHI_TIET_GIO_HANG WHERE ma_gh = ? AND ma_sp = ? AND ma_size = ?";
        RowMapper<ChiTietGioHang> mapper = rs -> {
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
        };
        return JdbcHelper.queryForObject(sql, mapper, maGh, maSp, maSize);
    }

    @Override
    public boolean addOrUpdateChiTiet(ChiTietGioHang chiTiet) {
        boolean isUpdate = chiTiet.getMaCtgh() > 0;
        try (Connection conn = DBConnect.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (isUpdate) {
                    String sql = "UPDATE CHI_TIET_GIO_HANG SET so_luong = ?, is_chon_mua = ? ";
                    if (chiTiet.getMucDa() != null) sql += ", muc_da = ? ";
                    if (chiTiet.getMucDuong() != null) sql += ", muc_duong = ? ";
                    if (chiTiet.getGhiChuMon() != null) sql += ", ghi_chu_mon = ? ";
                    sql += "WHERE ma_ctgh = ?";

                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        int idx = 1;
                        ps.setInt(idx++, chiTiet.getSoLuong());
                        ps.setBoolean(idx++, chiTiet.isChonMua());
                        if (chiTiet.getMucDa() != null) ps.setString(idx++, chiTiet.getMucDa());
                        if (chiTiet.getMucDuong() != null) ps.setString(idx++, chiTiet.getMucDuong());
                        if (chiTiet.getGhiChuMon() != null) ps.setString(idx++, chiTiet.getGhiChuMon());
                        ps.setLong(idx, chiTiet.getMaCtgh());
                        ps.executeUpdate();
                    }

                    if (chiTiet.getToppingGioHangList() != null) {
                        String delSql = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
                        try (PreparedStatement delPs = conn.prepareStatement(delSql)) {
                            delPs.setLong(1, chiTiet.getMaCtgh());
                            delPs.executeUpdate();
                        }
                    }
                } else {
                    String sql = "INSERT INTO CHI_TIET_GIO_HANG (ma_gh, ma_sp, ma_size, so_luong, muc_da, muc_duong, ghi_chu_mon, is_chon_mua) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, chiTiet.getMaGh());
                        ps.setString(2, chiTiet.getMaSp());
                        ps.setInt(3, chiTiet.getMaSize());
                        ps.setInt(4, chiTiet.getSoLuong());
                        ps.setString(5, chiTiet.getMucDa() != null ? chiTiet.getMucDa() : "100% Đá");
                        ps.setString(6, chiTiet.getMucDuong() != null ? chiTiet.getMucDuong() : "100% Đường");
                        ps.setString(7, chiTiet.getGhiChuMon() != null ? chiTiet.getGhiChuMon() : "");
                        ps.setBoolean(8, chiTiet.isChonMua());
                        ps.executeUpdate();
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) {
                                chiTiet.setMaCtgh(rs.getLong(1));
                            }
                        }
                    }
                }

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
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteChiTiet(long maCtgh) {
        try (Connection conn = DBConnect.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sqlTop = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlTop)) {
                    ps.setLong(1, maCtgh);
                    ps.executeUpdate();
                }
                String sqlItem = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_ctgh = ?";
                int rows = 0;
                try (PreparedStatement ps = conn.prepareStatement(sqlItem)) {
                    ps.setLong(1, maCtgh);
                    rows = ps.executeUpdate();
                }
                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean clearGioHang(int maGh) {
        try (Connection conn = DBConnect.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sqlTop = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh IN (SELECT ma_ctgh FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlTop)) {
                    ps.setInt(1, maGh);
                    ps.executeUpdate();
                }
                String sqlItem = "DELETE FROM CHI_TIET_GIO_HANG WHERE ma_gh = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlItem)) {
                    ps.setInt(1, maGh);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateTrangThaiChonMua(long maCtgh, boolean isChon) {
        String sql = "UPDATE CHI_TIET_GIO_HANG SET is_chon_mua = ? WHERE ma_ctgh = ?";
        return JdbcHelper.update(sql, isChon, maCtgh) > 0;
    }

    @Override
    public boolean addToppingToGioHang(long maCtgh, String maTp, int qty) {
        String msSql = "IF EXISTS (SELECT 1 FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ? AND ma_tp = ?) " +
                "UPDATE CHI_TIET_TOPPING_GIO_HANG SET so_luong_tp = so_luong_tp + ? WHERE ma_ctgh = ? AND ma_tp = ? " +
                "ELSE INSERT INTO CHI_TIET_TOPPING_GIO_HANG (ma_ctgh, ma_tp, so_luong_tp) VALUES (?, ?, ?)";
        return JdbcHelper.update(msSql, maCtgh, maTp, qty, maCtgh, maTp, maCtgh, maTp, qty) > 0;
    }

    @Override
    public boolean removeToppingsFromChiTiet(long maCtgh) {
        String sql = "DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_ctgh = ?";
        return JdbcHelper.update(sql, maCtgh) > 0;
    }
}
