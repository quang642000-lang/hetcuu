package repository.impl;

import config.DBConnect;
import model.entity.NhanVien;
import repository.INhanVienRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class NhanVienRepoImpl implements INhanVienRepository {
    private static NhanVienRepoImpl instance;

    private final RowMapper<NhanVien> rowMapper = rs -> new NhanVien(
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

    private NhanVienRepoImpl() {}

    public static synchronized NhanVienRepoImpl getInstance() {
        if (instance == null) {
            instance = new NhanVienRepoImpl();
        }
        return instance;
    }

    @Override
    public List<NhanVien> getAll() {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN ORDER BY thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public NhanVien getById(String id) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE ma_nv = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(NhanVien entity) {
        // SỬA LỖI CHÍ MẠNG: Sử dụng inline lambda 'rs -> rs.getString("ma_nv")' thay vì 'rowMapper' toàn cục
        // để tránh lỗi SQLServerException "The column name ma_vt is not valid" do Stored Procedure chỉ trả về duy nhất cột ma_nv.
        String sql = "{call sp_ThemNhanVien(?, ?, ?, ?, ?, ?)}";
        String generatedId = JdbcHelper.queryForObject(sql, rs -> rs.getString("ma_nv"),
                entity.getMaVt(),
                entity.getHoTen(),
                entity.getSoDienThoai(),
                entity.getEmail(),
                entity.getTenDangNhap(),
                entity.getMatKhau()
        );
        if (generatedId != null) {
            entity.setMaNv(generatedId);
            try (Connection conn = DBConnect.getConnection()) {
                updateTrangThaiBoSung(entity, conn);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return true;
        }
        return false;
    }

    private void updateTrangThaiBoSung(NhanVien entity, Connection conn) throws SQLException {
        String sql = "UPDATE NHAN_VIEN SET trang_thai = ? WHERE ma_nv = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, entity.isTrangThai());
            ps.setString(2, entity.getMaNv());
            ps.executeUpdate();
        }
    }

    @Override
    public boolean update(NhanVien entity) {
        String sql = "UPDATE NHAN_VIEN SET ma_vt = ?, ho_ten = ?, so_dien_thoai = ?, email = ?, ten_dang_nhap = ?, trang_thai = ? WHERE ma_nv = ?";
        return JdbcHelper.update(sql,
                entity.getMaVt(),
                entity.getHoTen(),
                entity.getSoDienThoai(),
                entity.getEmail(),
                entity.getTenDangNhap(),
                entity.isTrangThai(),
                entity.getMaNv()
        ) > 0;
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE NHAN_VIEN SET trang_thai = 0 WHERE ma_nv = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public NhanVien getByTenDangNhap(String username) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE ten_dang_nhap = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, username);
    }

    @Override
    public NhanVien getByEmail(String email) {
        String sql = "SELECT ma_nv, ma_vt, ho_ten, so_dien_thoai, email, ten_dang_nhap, mat_khau, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM NHAN_VIEN WHERE email = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, email);
    }

    @Override
    public boolean updateMatKhau(String maNv, String matKhauMoi) {
        String sql = "UPDATE NHAN_VIEN SET mat_khau = ? WHERE ma_nv = ?";
        return JdbcHelper.update(sql, matKhauMoi, maNv) > 0;
    }

    @Override
    public boolean checkTrungSdtOrEmail(String sdt, String email, String excludeMaNv) {
        String sql = excludeMaNv == null
                ? "SELECT COUNT(*) FROM NHAN_VIEN WHERE so_dien_thoai = ? OR email = ?"
                : "SELECT COUNT(*) FROM NHAN_VIEN WHERE (so_dien_thoai = ? OR email = ?) AND ma_nv != ?";
        Integer count;
        if (excludeMaNv == null) {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), sdt, email);
        } else {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), sdt, email, excludeMaNv);
        }
        return count != null && count > 0;
    }
}
