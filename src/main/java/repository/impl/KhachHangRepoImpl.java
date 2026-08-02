package repository.impl;

import config.DBConnect;
import model.entity.KhachHang;
import repository.IKhachHangRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class KhachHangRepoImpl implements IKhachHangRepository {
    private static KhachHangRepoImpl instance;

    private final RowMapper<KhachHang> rowMapper = rs -> new KhachHang(
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

    private KhachHangRepoImpl() {}

    public static synchronized KhachHangRepoImpl getInstance() {
        if (instance == null) {
            instance = new KhachHangRepoImpl();
        }
        return instance;
    }

    @Override
    public List<KhachHang> getAll() {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG ORDER BY thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public KhachHang getById(String id) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE ma_kh = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(KhachHang entity) {
        // SỬA LỖI CHÍ MẠNG: Sử dụng inline lambda 'rs -> rs.getString("ma_kh")' thay vì 'rowMapper' toàn cục
        // để tránh lỗi SQLServerException "The column name ma_hang is not valid" do Stored Procedure chỉ trả về duy nhất cột ma_kh.
        String sql = "{call sp_ThemKhachHang(?, ?, ?, ?)}";
        String generatedId = JdbcHelper.queryForObject(sql, rs -> rs.getString("ma_kh"),
                entity.getTenKh(),
                entity.getSoDienThoai(),
                entity.getEmail(),
                entity.getMatKhau()
        );
        if (generatedId != null) {
            entity.setMaKh(generatedId);
            try (Connection conn = DBConnect.getConnection()) {
                updateKhachHangBoSung(entity, conn);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return true;
        }
        return false;
    }

    private void updateKhachHangBoSung(KhachHang entity, Connection conn) throws SQLException {
        String sql = "UPDATE KHACH_HANG SET ma_hang = ?, ngay_sinh = ?, gioi_tinh = ?, dia_chi_lien_he = ?, hinh_anh_url = ?, diem_tich_luy = ?, trang_thai = ? WHERE ma_kh = ?";
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
        return JdbcHelper.update(sql,
                entity.getMaHang(),
                entity.getSoDienThoai(),
                entity.getTenKh(),
                entity.getEmail(),
                entity.getNgaySinh(),
                entity.getGioiTinh(),
                entity.getDiaChiLienHe(),
                entity.getHinhAnhUrl(),
                entity.getDiemTichLuy(),
                entity.isTrangThai(),
                entity.getMaKh()
        ) > 0;
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE KHACH_HANG SET trang_thai = 0 WHERE ma_kh = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public KhachHang getBySdt(String sdt) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE so_dien_thoai = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, sdt);
    }

    @Override
    public KhachHang getByEmail(String email) {
        String sql = "SELECT ma_kh, ma_hang, so_dien_thoai, ten_kh, email, mat_khau, ngay_sinh, gioi_tinh, dia_chi_lien_he, hinh_anh_url, diem_tich_luy, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM KHACH_HANG WHERE email = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, email);
    }

    @Override
    public boolean congDiemTichLuy(String maKh, int diemCong) {
        String sql = "UPDATE KHACH_HANG SET diem_tich_luy = diem_tich_luy + ? WHERE ma_kh = ?";
        return JdbcHelper.update(sql, diemCong, maKh) > 0;
    }

    @Override
    public boolean truDiemTichLuy(String maKh, int diemTru) {
        String sql = "UPDATE KHACH_HANG SET diem_tich_luy = diem_tich_luy - ? WHERE ma_kh = ? AND diem_tich_luy >= ?";
        return JdbcHelper.update(sql, diemTru, maKh, diemTru) > 0;
    }

    @Override
    public boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaKh) {
        String sql = excludeMaKh == null
                ? "SELECT COUNT(*) FROM KHACH_HANG WHERE so_dien_thoai = ? OR email = ?"
                : "SELECT COUNT(*) FROM KHACH_HANG WHERE (so_dien_thoai = ? OR email = ?) AND ma_kh != ?";
        Integer count;
        if (excludeMaKh == null) {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), sdt, email);
        } else {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), sdt, email, excludeMaKh);
        }
        return count != null && count > 0;
    }

    @Override
    public boolean updateMatKhau(String maKh, String matKhauMoi) {
        String sql = "UPDATE KHACH_HANG SET mat_khau = ? WHERE ma_kh = ?";
        return JdbcHelper.update(sql, matKhauMoi, maKh) > 0;
    }
}
