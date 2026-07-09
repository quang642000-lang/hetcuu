package repository.impl;

import config.DBConnect;
import model.entity.NhanVien;
import repository.INhanVienRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NhanVienRepoImpl implements INhanVienRepository {

    private static NhanVienRepoImpl instance;

    private NhanVienRepoImpl() {}

    public static synchronized NhanVienRepoImpl getInstance() {
        if (instance == null) {
            instance = new NhanVienRepoImpl();
        }
        return instance;
    }

    @Override
    public List<NhanVien> getAll() {
        List<NhanVien> list = new ArrayList<>();
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToNhanVien(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public NhanVien getById(String id) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToNhanVien(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(NhanVien entity) {
        String sql = "{call sp_ThemNhanVien(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, entity.getMaVt());
            cs.setString(2, entity.getHoTen());
            cs.setString(3, entity.getSoDienThoai());
            cs.setString(4, entity.getEmail());
            cs.setString(5, entity.getTenDangNhap());
            cs.setString(6, entity.getMatKhau());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaNv(rs.getString("ma_nv"));
                    updateTrangThaiBoSung(entity);
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updateTrangThaiBoSung(NhanVien entity) throws SQLException {
        String sql = "UPDATE NHAN_VIEN SET trang_thai = ? WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, entity.isTrangThai());
            ps.setString(2, entity.getMaNv());
            ps.executeUpdate();
        }
    }

    @Override
    public boolean update(NhanVien entity) {
        String sql = "UPDATE NHAN_VIEN SET ma_vt = ?, ho_ten = ?, so_dien_thoai = ?, email = ?, ten_dang_nhap = ?, trang_thai = ? WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entity.getMaVt());
            ps.setString(2, entity.getHoTen());
            ps.setString(3, entity.getSoDienThoai());
            ps.setString(4, entity.getEmail());
            ps.setString(5, entity.getTenDangNhap());
            ps.setBoolean(6, entity.isTrangThai());
            ps.setString(7, entity.getMaNv());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE NHAN_VIEN SET trang_thai = 0 WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public NhanVien getByTenDangNhap(String username) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE ten_dang_nhap = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToNhanVien(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public NhanVien getByEmail(String email) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE email = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToNhanVien(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean updateMatKhau(String maNv, String matKhauMoi) {
        String sql = "UPDATE NHAN_VIEN SET mat_khau = ? WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, matKhauMoi);
            ps.setString(2, maNv);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaNv) {
        String sql = excludeMaNv == null
                ? "SELECT COUNT(*) FROM NHAN_VIEN WHERE so_dien_thoai = ? OR email = ?"
                : "SELECT COUNT(*) FROM NHAN_VIEN WHERE (so_dien_thoai = ? OR email = ?) AND ma_nv != ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sdt);
            ps.setString(2, email);
            if (excludeMaNv != null) {
                ps.setString(3, excludeMaNv);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private NhanVien mapResultSetToNhanVien(ResultSet rs) throws SQLException {
        return new NhanVien(
                rs.getString("ma_nv"),
                rs.getInt("ma_vt"),
                rs.getString("ho_ten"),
                rs.getString("so_dien_thoai"),
                rs.getString("email"),
                rs.getString("ten_dang_nhap"),
                rs.getString("mat_khau"),
                rs.getBoolean("trang_thai"),
                rs.getTimestamp("thoi_gian_tao"),
                rs.getTimestamp("thoi_gian_cap_nhat")
        );
    }
}
