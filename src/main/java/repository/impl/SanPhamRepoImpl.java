package repository.impl;

import config.DBConnect;
import model.entity.SanPham;
import repository.ISanPhamRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class SanPhamRepoImpl implements ISanPhamRepository {
    private static SanPhamRepoImpl instance;

    private final RowMapper<SanPham> rowMapper = rs -> new SanPham(
            rs.getString("ma_sp"),
            rs.getString("ma_dm"),
            rs.getString("ten_sp"),
            rs.getString("mo_ta"),
            rs.getString("hinh_anh"),
            rs.getBoolean("cho_phep_doi_da"),
            rs.getBoolean("cho_phep_doi_duong"),
            rs.getBoolean("is_new"),
            rs.getBoolean("is_bestseller"),
            rs.getBoolean("trang_thai"),
            rs.getTimestamp("thoi_gian_tao"),
            rs.getTimestamp("thoi_gian_cap_nhat"),
            rs.getBoolean("cho_phep_topping"),
            rs.getInt("thu_tu_hien_thi")
    );

    private SanPhamRepoImpl() {}

    public static synchronized SanPhamRepoImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamRepoImpl();
        }
        return instance;
    }

    @Override
    public List<SanPham> getAll() {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM ORDER BY thu_tu_hien_thi ASC, thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public SanPham getById(String id) {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM WHERE ma_sp = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(SanPham entity) {
        // SỬA LỖI CHÍ MẠNG: Sử dụng inline lambda 'rs -> rs.getString("ma_sp")' thay vì 'rowMapper' toàn cục
        // để tránh lỗi SQLServerException "The column name ma_dm is not valid" do Stored Procedure chỉ trả về duy nhất cột ma_sp.
        String sql = "{call sp_ThemSanPham(?, ?, ?, ?)}";
        String generatedId = JdbcHelper.queryForObject(sql, rs -> rs.getString("ma_sp"),
                entity.getMaDm(),
                entity.getTenSp(),
                entity.getMoTa(),
                entity.getHinhAnh()
        );
        if (generatedId != null) {
            entity.setMaSp(generatedId);
            return true;
        }
        return false;
    }

    @Override
    public boolean update(SanPham entity) {
        String sql = "UPDATE SAN_PHAM SET ma_dm = ?, ten_sp = ?, mo_ta = ?, hinh_anh = ?, " +
                "cho_phep_doi_da = ?, cho_phep_doi_duong = ?, is_new = ?, is_bestseller = ?, " +
                "trang_thai = ?, cho_phep_topping = ?, thu_tu_hien_thi = ?, thoi_gian_cap_nhat = GETDATE() WHERE ma_sp = ?";
        return JdbcHelper.update(sql,
                entity.getMaDm(),
                entity.getTenSp(),
                entity.getMoTa(),
                entity.getHinhAnh(),
                entity.isChoPhepDoiDa(),
                entity.isChoPhepDoiDuong(),
                entity.getIsNew(),
                entity.getIsBestseller(),
                entity.isTrangThai(),
                entity.isChoPhepTopping(),
                entity.getThuTuHienThi(),
                entity.getMaSp()
        ) > 0;
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE SAN_PHAM SET trang_thai = 0 WHERE ma_sp = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public List<SanPham> getByDanhMuc(String maDm) {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM WHERE ma_dm = ? AND trang_thai = 1 ORDER BY thu_tu_hien_thi ASC, thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper, maDm);
    }

    @Override
    public List<SanPham> getBestsellers() {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM WHERE is_bestseller = 1 AND trang_thai = 1 ORDER BY thu_tu_hien_thi ASC, thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public List<SanPham> getNewArrivals() {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM WHERE is_new = 1 AND trang_thai = 1 ORDER BY thu_tu_hien_thi ASC, thoi_gian_tao DESC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public List<SanPham> searchByName(String keyword) {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, " +
                "is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat, cho_phep_topping, thu_tu_hien_thi " +
                "FROM SAN_PHAM WHERE (ten_sp LIKE ? OR ma_sp LIKE ?) AND trang_thai = 1 " +
                "ORDER BY thu_tu_hien_thi ASC, thoi_gian_tao DESC";
        String match = "%" + keyword + "%";
        return JdbcHelper.query(sql, rowMapper, match, match);
    }
}
