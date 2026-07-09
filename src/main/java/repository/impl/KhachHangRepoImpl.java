package repository.impl;

import config.DBConnect;
import model.entity.KhachHang;
import repository.IKhachHangRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KhachHangRepoImpl implements IKhachHangRepository {

    private static KhachHangRepoImpl instance;

    private KhachHangRepoImpl() {}

    public static synchronized KhachHangRepoImpl getInstance() {
        if (instance == null) {
            instance = new KhachHangRepoImpl();
        }
        return instance;
    }

    @Override
    public List<KhachHang> getAll() {
        List<KhachHang> list = new ArrayList<>();
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToKhachHang(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public KhachHang getById(String id) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE ma_kh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKhachHang(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(KhachHang entity) {
        String sql = "{call sp_ThemKhachHang(?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entity.getTenKh());
            cs.setString(2, entity.getSoDienThoai());
            cs.setString(3, entity.getEmail());
            cs.setString(4, entity.getMatKhau());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaKh(rs.getString("ma_kh"));
                    updateKhachHangBoSung(entity, conn); // CHỈNH SỬA: Truyền Connection trực tiếp
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updateKhachHangBoSung(KhachHang entity, Connection conn) throws SQLException {
        String sql = "UPDATE KHACH_HANG SET ma_hang = ?, ngay_sinh = ?, gioi_tinh = ?, dia_chi_lien_he = ?, hinh_anh_url = ?, diem_tich_luy = ?, trang_thai = ? WHERE ma_kh = ?";
        // Tái sử dụng đối tượng PreparedStatement từ conn được truyền từ hàm cha, tránh rò rỉ kết nối!
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entity.getMaHang() <= 0 ? 1 : entity.getMaHang());
            ps.setDate(2, entity.getNgaySinh());
            ps.setString(3, entity.getGioiTinh());
            ps.setString(4, entity.getDiaChiLienHe());
            ps.setString(5, entity.getHinhAnhUrl());
            ps.setInt(6, entity.getDiemTichLuy());
            ps.setBoolean(7, entity.isTrangThai());
            ps.setString(8, entity.getMaKh());
            ps.executeUpdate();
        }
    }


    @Override
    public boolean update(KhachHang entity) {
        String sql = "UPDATE KHACH_HANG SET ma_hang = ?, so_dien_thoai = ?, ten_kh = ?, email = ?, ngay_sinh = ?, gioi_tinh = ?, dia_chi_lien_he = ?, hinh_anh_url = ?, diem_tich_luy = ?, trang_thai = ? WHERE ma_kh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entity.getMaHang());
            ps.setString(2, entity.getSoDienThoai());
            ps.setString(3, entity.getTenKh());
            ps.setString(4, entity.getEmail());
            ps.setDate(5, entity.getNgaySinh());
            ps.setString(6, entity.getGioiTinh());
            ps.setString(7, entity.getDiaChiLienHe());
            ps.setString(8, entity.getHinhAnhUrl());
            ps.setInt(9, entity.getDiemTichLuy());
            ps.setBoolean(10, entity.isTrangThai());
            ps.setString(11, entity.getMaKh());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE KHACH_HANG SET trang_thai = 0 WHERE ma_kh = ?";
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
    public KhachHang getBySdt(String sdt) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE so_dien_thoai = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sdt);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKhachHang(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public KhachHang getByEmail(String email) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE email = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKhachHang(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean congDiemTichLuy(String maKh, int diemCong) {
        String sql = "UPDATE KHACH_HANG SET diem_tich_luy = diem_tich_luy + ? WHERE ma_kh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, diemCong);
            ps.setString(2, maKh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean truDiemTichLuy(String maKh, int diemTru) {
        String sql = "UPDATE KHACH_HANG SET diem_tich_luy = diem_tich_luy - ? WHERE ma_kh = ? AND diem_tich_luy >= ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, diemTru);
            ps.setString(2, maKh);
            ps.setInt(3, diemTru);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaKh) {
        String sql = excludeMaKh == null
                ? "SELECT COUNT(*) FROM KHACH_HANG WHERE so_dien_thoai = ? OR email = ?"
                : "SELECT COUNT(*) FROM KHACH_HANG WHERE (so_dien_thoai = ? OR email = ?) AND ma_kh != ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sdt);
            ps.setString(2, email);
            if (excludeMaKh != null) {
                ps.setString(3, excludeMaKh);
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

    private KhachHang mapResultSetToKhachHang(ResultSet rs) throws SQLException {
        return new KhachHang(
                rs.getString("ma_kh"),
                rs.getInt("ma_hang"),
                rs.getString("so_dien_thoai"),
                rs.getString("ten_kh"),
                rs.getString("email"),
                rs.getString("mat_khau"),
                rs.getDate("ngay_sinh"),
                rs.getString("gioi_tinh"),
                rs.getString("dia_chi_lien_he"),
                rs.getString("hinh_anh_url"),
                rs.getInt("diem_tich_luy"),
                rs.getBoolean("trang_thai"),
                rs.getTimestamp("thoi_gian_tao"),
                rs.getTimestamp("thoi_gian_cap_nhat")
        );
    }
}