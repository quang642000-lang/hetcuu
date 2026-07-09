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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai FROM CHUONG_TRINH_KHUYEN_MAI ORDER BY ngay_bat_dau DESC";
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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
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
        String sql = "{call sp_ThemVoucher(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entity.getMaKm());
            cs.setString(2, entity.getTenKm());
            cs.setString(3, entity.getMaCode());
            cs.setInt(4, entity.getLoaiGiam());
            cs.setInt(5, entity.getGiaTriGiam());
            cs.setInt(6, entity.getGiamToiDa());
            cs.setInt(7, entity.getDonToiThieu());
            cs.setInt(8, entity.getSoLuong());
            cs.setTimestamp(9, entity.getNgayBatDau());
            cs.setTimestamp(10, entity.getNgayKetThuc());
            cs.execute();

            updateVoucherFlags(entity);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void updateVoucherFlags(KhuyenMai entity) throws SQLException {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET hinh_anh_url = ?, mo_ta_dieu_kien = ?, is_public = ?, trang_thai = ? WHERE ma_km = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getHinhAnhUrl());
            ps.setString(2, entity.getMoTaDieuKien());
            ps.setBoolean(3, entity.isPublic());
            ps.setBoolean(4, entity.isTrangThai());
            ps.setString(5, entity.getMaKm());
            ps.executeUpdate();
        }
    }

    @Override
    public boolean update(KhuyenMai entity) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET ten_km = ?, ma_code = ?, mo_ta_dieu_kien = ?, hinh_anh_url = ?, loai_giam = ?, gia_tri_giam = ?, giam_toi_da = ?, don_toi_thieu = ?, is_public = ?, so_luong = ?, ngay_bat_dau = ?, ngay_ket_thuc = ?, trang_thai = ? WHERE ma_km = ?";
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
            ps.setString(14, entity.getMaKm());
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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_code = ? AND trang_thai = 1";
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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai "
                + "FROM CHUONG_TRINH_KHUYEN_MAI "
                + "WHERE trang_thai = 1 AND so_luong > 0 AND GETDATE() BETWEEN ngay_bat_dau AND ngay_ket_thuc "
                + "AND don_toi_thieu <= ? ORDER BY gia_tri_giam DESC";
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
        return new KhuyenMai(
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
    }
}