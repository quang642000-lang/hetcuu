package repository.impl;
import config.DBConnect;
import model.entity.KhuyenMai;
import repository.IKhuyenMaiRepository;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KhuyenMaiRepoImpl implements IKhuyenMaiRepository {
    private static KhuyenMaiRepoImpl instance;
    private KhuyenMaiRepoImpl() {}
    public static synchronized KhuyenMaiRepoImpl getInstance() {
        if (instance == null) {
            instance = new KhuyenMaiRepoImpl();
        }
        return instance;
    }
    @Override
    public List<KhuyenMai> getAll() {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan FROM CHUONG_TRINH_KHUYEN_MAI ORDER BY ngay_bat_dau DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToKhuyenMai(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    @Override
    public KhuyenMai getById(String id) {
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKhuyenMai(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    @Override
    public boolean add(KhuyenMai entity) {
        String sql = "{call sp_ThemVoucher(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}"; // 14 parameters
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entity.getTenKm());
            cs.setString(2, entity.getMaCode());
            cs.setString(3, entity.getMoTaDieuKien());
            cs.setString(4, entity.getHinhAnhUrl());
            cs.setInt(5, entity.getLoaiGiam());
            cs.setInt(6, entity.getGiaTriGiam());
            cs.setInt(7, entity.getGiamToiDa());
            cs.setInt(8, entity.getDonToiThieu());
            cs.setBoolean(9, entity.isPublic());
            cs.setInt(10, entity.getSoLuong());
            cs.setTimestamp(11, entity.getNgayBatDau());
            cs.setTimestamp(12, entity.getNgayKetThuc());
            cs.setBoolean(13, entity.isTrangThai());
            cs.setInt(14, entity.getSoLuotDungCaNhan()); // PARAM 14
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaKm(rs.getString("ma_km"));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    @Override
    public boolean update(KhuyenMai entity) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET ten_km = ?, ma_code = ?, mo_ta_dieu_kien = ?, " +
                "hinh_anh_url = ?, loai_giam = ?, gia_tri_giam = ?, giam_toi_da = ?, don_toi_thieu = ?, " +
                "is_public = ?, so_luong = ?, ngay_bat_dau = ?, ngay_ket_thuc = ?, trang_thai = ?, so_luot_dung_ca_nhan = ? " +
                "WHERE ma_km = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenKm());
            ps.setString(2, entity.getMaCode());
            ps.setString(3, entity.getMoTaDieuKien());
            ps.setString(4, entity.getHinhAnhUrl());
            ps.setInt(5, entity.getLoaiGiam());
            ps.setInt(6, entity.getGiaTriGiam());
            ps.setInt(7, entity.getGiamToiDa());
            ps.setInt(8, entity.getDonToiThieu());
            ps.setBoolean(9, entity.isPublic());
            ps.setInt(10, entity.getSoLuong());
            ps.setTimestamp(11, entity.getNgayBatDau());
            ps.setTimestamp(12, entity.getNgayKetThuc());
            ps.setBoolean(13, entity.isTrangThai());
            ps.setInt(14, entity.getSoLuotDungCaNhan());
            ps.setString(15, entity.getMaKm());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    @Override
    public boolean delete(String id) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET trang_thai = 0 WHERE ma_km = ?";
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
    public KhuyenMai getByCode(String code) {
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, " +
                "gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, " +
                "ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_code = ? AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToKhuyenMai(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    @Override
    public List<KhuyenMai> getVouchersKhaDung(int tongDonHang, String maKh) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, " +
                "gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, " +
                "ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan FROM CHUONG_TRINH_KHUYEN_MAI " +
                "WHERE trang_thai = 1 AND so_luong > 0 AND GETDATE() BETWEEN ngay_bat_dau AND ngay_ket_thuc " +
                "AND don_toi_thieu <= ? ORDER BY gia_tri_giam DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tongDonHang);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToKhuyenMai(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    @Override
    public boolean giamSoLuongVoucher(String maKm) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET so_luong = so_luong - 1 WHERE ma_km = ? AND so_luong > 0";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKm);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    private KhuyenMai mapResultSetToKhuyenMai(ResultSet rs) throws SQLException {
        KhuyenMai km = new KhuyenMai(
                rs.getString("ma_km"),
                rs.getString("ten_km"),
                rs.getString("ma_code"),
                rs.getString("mo_ta_dieu_kien"),
                rs.getString("hinh_anh_url"),
                rs.getInt("loai_giam"),
                rs.getInt("gia_tri_giam"),
                rs.getInt("giam_toi_da"),
                rs.getInt("don_toi_thieu"),
                rs.getBoolean("is_public"),
                rs.getInt("so_luong"),
                rs.getTimestamp("ngay_bat_dau"),
                rs.getTimestamp("ngay_ket_thuc"),
                rs.getBoolean("trang_thai")
        );
        try {
            km.setSoLuotDungCaNhan(rs.getInt("so_luot_dung_ca_nhan"));
        } catch (SQLException e) {
            km.setSoLuotDungCaNhan(0);
        }
        return km;
    }
}