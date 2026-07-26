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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher FROM CHUONG_TRINH_KHUYEN_MAI ORDER BY ngay_bat_dau DESC";
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
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
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
        String genMaKmSql = "SELECT 'KM' + RIGHT('00000' + CAST(NEXT VALUE FOR seq_Voucher AS VARCHAR(10)), 5)";
        String insertSql = "INSERT INTO CHUONG_TRINH_KHUYEN_MAI (ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection()) {
            String maKm = "";
            try (PreparedStatement psGen = conn.prepareStatement(genMaKmSql);
                 ResultSet rsGen = psGen.executeQuery()) {
                if (rsGen.next()) {
                    maKm = rsGen.getString(1);
                }
            }
            if (maKm.isEmpty()) return false;
            entity.setMaKm(maKm);
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, maKm);
                ps.setString(2, entity.getTenKm());
                ps.setString(3, entity.getMaCode());
                ps.setString(4, entity.getMoTaDieuKien());
                ps.setString(5, entity.getHinhAnhUrl());
                ps.setInt(6, entity.getLoaiGiam());
                ps.setInt(7, entity.getGiaTriGiam());
                ps.setInt(8, entity.getGiamToiDa());
                ps.setInt(9, entity.getDonToiThieu());
                ps.setBoolean(10, entity.isPublic());
                ps.setInt(11, entity.getSoLuong());
                ps.setTimestamp(12, entity.getNgayBatDau());
                ps.setTimestamp(13, entity.getNgayKetThuc());
                ps.setBoolean(14, entity.isTrangThai());
                ps.setInt(15, entity.getSoLuotDungCaNhan());
                ps.setInt(16, entity.getHangApDung());
                ps.setInt(17, entity.getLoaiVoucher());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(KhuyenMai entity) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET ten_km = ?, ma_code = ?, mo_ta_dieu_kien = ?, hinh_anh_url = ?, loai_giam = ?, gia_tri_giam = ?, giam_toi_da = ?, don_toi_thieu = ?, is_public = ?, so_luong = ?, ngay_bat_dau = ?, ngay_ket_thuc = ?, trang_thai = ?, so_luot_dung_ca_nhan = ?, hang_ap_dung = ?, loai_voucher = ? WHERE ma_km = ?";
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
            ps.setInt(15, entity.getHangApDung());
            ps.setInt(16, entity.getLoaiVoucher());
            ps.setString(17, entity.getMaKm());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
        }
        return false;
    }

    @Override
    public KhuyenMai getByCode(String code) {
        String sql = "SELECT ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, loai_giam, " +
                "gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, " +
                "ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_code = ? AND trang_thai = 1";
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
                "ngay_ket_thuc, trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher FROM CHUONG_TRINH_KHUYEN_MAI " +
                "WHERE trang_thai = 1 AND GETDATE() BETWEEN ngay_bat_dau AND ngay_ket_thuc " +
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
        return true;
    }

    @Override
    public boolean congSoLuongVoucher(String maKm) {
        return true;
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
        try { km.setSoLuotDungCaNhan(rs.getInt("so_luot_dung_ca_nhan")); } catch (SQLException e) { km.setSoLuotDungCaNhan(0); }
        try { km.setHangApDung(rs.getInt("hang_ap_dung")); } catch (SQLException e) { km.setHangApDung(1); }
        try { km.setLoaiVoucher(rs.getInt("loai_voucher")); } catch (SQLException e) { km.setLoaiVoucher(1); }

        int usedCount = 0;
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM DON_HANG WHERE ma_km = ? AND trang_thai_don != 5")) {
            ps.setString(1, km.getMaKm());
            try (ResultSet rsCount = ps.executeQuery()) {
                if (rsCount.next()) usedCount = rsCount.getInt(1);
            }
        } catch (Exception e) {
            // ignore
        }
        km.setSoLuongDaDung(usedCount);
        return km;
    }
}
