package repository.impl;

import model.entity.KhuyenMai;
import repository.IKhuyenMaiRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class KhuyenMaiRepoImpl implements IKhuyenMaiRepository {
    private static KhuyenMaiRepoImpl instance;
    private final RowMapper<KhuyenMai> rowMapper = rs -> {
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

        // Dynamic usage count checking
        String countSql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_km = ? AND trang_thai_don != 5";
        Integer usedCount = JdbcHelper.queryForObject(countSql, r -> r.getInt(1), km.getMaKm());
        km.setSoLuongDaDung(usedCount != null ? usedCount : 0);
        return km;
    };

    private KhuyenMaiRepoImpl() {}

    public static synchronized KhuyenMaiRepoImpl getInstance() {
        if (instance == null) {
            instance = new KhuyenMaiRepoImpl();
        }
        return instance;
    }

    @Override
    public List<KhuyenMai> getAll() {
        String sql = "SELECT * FROM CHUONG_TRINH_KHUYEN_MAI ORDER BY ngay_bat_dau DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public KhuyenMai getById(String id) {
        String sql = "SELECT * FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(KhuyenMai entity) {
        String genMaKmSql = "SELECT 'KM' + RIGHT('00000' + CAST(NEXT VALUE FOR seq_Voucher AS VARCHAR(10)), 5)";
        String maKm = JdbcHelper.queryForObject(genMaKmSql, rs -> rs.getString(1));
        if (maKm == null) return false;
        entity.setMaKm(maKm);

        String insertSql = "INSERT INTO CHUONG_TRINH_KHUYEN_MAI (ma_km, ten_km, ma_code, mo_ta_dieu_kien, hinh_anh_url, " +
                "loai_giam, gia_tri_giam, giam_toi_da, don_toi_thieu, is_public, so_luong, ngay_bat_dau, ngay_ket_thuc, " +
                "trang_thai, so_luot_dung_ca_nhan, hang_ap_dung, loai_voucher) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return JdbcHelper.update(insertSql, maKm, entity.getTenKm(), entity.getMaCode(), entity.getMoTaDieuKien(), entity.getHinhAnhUrl(),
                entity.getLoaiGiam(), entity.getGiaTriGiam(), entity.getGiamToiDa(), entity.getDonToiThieu(), entity.isPublic(),
                entity.getSoLuong(), entity.getNgayBatDau(), entity.getNgayKetThuc(), entity.isTrangThai(), entity.getSoLuotDungCaNhan(),
                entity.getHangApDung(), entity.getLoaiVoucher()) > 0;
    }

    @Override
    public boolean update(KhuyenMai entity) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET ten_km = ?, ma_code = ?, mo_ta_dieu_kien = ?, hinh_anh_url = ?, " +
                "loai_giam = ?, gia_tri_giam = ?, giam_toi_da = ?, don_toi_thieu = ?, is_public = ?, so_luong = ?, " +
                "ngay_bat_dau = ?, ngay_ket_thuc = ?, trang_thai = ?, so_luot_dung_ca_nhan = ?, hang_ap_dung = ?, loai_voucher = ? WHERE ma_km = ?";
        return JdbcHelper.update(sql, entity.getTenKm(), entity.getMaCode(), entity.getMoTaDieuKien(), entity.getHinhAnhUrl(),
                entity.getLoaiGiam(), entity.getGiaTriGiam(), entity.getGiamToiDa(), entity.getDonToiThieu(), entity.isPublic(),
                entity.getSoLuong(), entity.getNgayBatDau(), entity.getNgayKetThuc(), entity.isTrangThai(), entity.getSoLuotDungCaNhan(),
                entity.getHangApDung(), entity.getLoaiVoucher(), entity.getMaKm()) > 0;
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE CHUONG_TRINH_KHUYEN_MAI SET trang_thai = 0 WHERE ma_km = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public KhuyenMai getByCode(String code) {
        String sql = "SELECT * FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_code = ? AND trang_thai = 1";
        return JdbcHelper.queryForObject(sql, rowMapper, code);
    }

    @Override
    public List<KhuyenMai> getVouchersKhaDung(int tongDonHang, String maKh) {
        String sql = "SELECT * FROM CHUONG_TRINH_KHUYEN_MAI " +
                "WHERE trang_thai = 1 AND GETDATE() BETWEEN ngay_bat_dau AND ngay_ket_thuc " +
                "AND don_toi_thieu <= ? ORDER BY gia_tri_giam DESC";
        return JdbcHelper.query(sql, rowMapper, tongDonHang);
    }

    @Override
    public boolean giamSoLuongVoucher(String maKm) {
        return true;
    }

    @Override
    public boolean congSoLuongVoucher(String maKm) {
        return true;
    }
}
