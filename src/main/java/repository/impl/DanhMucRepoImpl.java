package repository.impl;

import config.DBConnect;
import model.entity.DanhMuc;
import repository.IDanhMucRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class DanhMucRepoImpl implements IDanhMucRepository {
    private static DanhMucRepoImpl instance;

    private final RowMapper<DanhMuc> rowMapper = rs -> new DanhMuc(
            rs.getString("ma_dm"),
            rs.getString("ten_dm"),
            rs.getString("hinh_anh"),
            rs.getInt("thu_tu_hien_thi"),
            rs.getBoolean("trang_thai")
    );

    private DanhMucRepoImpl() {}

    public static synchronized DanhMucRepoImpl getInstance() {
        if (instance == null) {
            instance = new DanhMucRepoImpl();
        }
        return instance;
    }

    @Override
    public List<DanhMuc> getAll() {
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC ORDER BY thu_tu_hien_thi ASC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public DanhMuc getById(String id) {
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC WHERE ma_dm = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(DanhMuc entity) {
        // SỬA LỖI CHÍ MẠNG: Sử dụng inline lambda 'rs -> rs.getString("ma_dm")' thay vì 'rowMapper' toàn cục
        // để tránh lỗi SQLServerException "The column name ten_dm is not valid" do Stored Procedure chỉ trả về duy nhất cột ma_dm.
        String sql = "{call sp_ThemDanhMuc(?, ?, ?, ?)}";
        String generatedId = JdbcHelper.queryForObject(sql, rs -> rs.getString("ma_dm"),
                entity.getTenDm(),
                entity.getHinhAnh(),
                entity.getThuTuHienThi(),
                entity.isTrangThai()
        );
        if (generatedId != null) {
            entity.setMaDm(generatedId);
            return true;
        }
        return false;
    }

    @Override
    public boolean update(DanhMuc entity) {
        String sql = "UPDATE DANH_MUC SET ten_dm = ?, hinh_anh = ?, thu_tu_hien_thi = ?, trang_thai = ? WHERE ma_dm = ?";
        return JdbcHelper.update(sql,
                entity.getTenDm(),
                entity.getHinhAnh(),
                entity.getThuTuHienThi(),
                entity.isTrangThai(),
                entity.getMaDm()
        ) > 0;
    }

    @Override
    public boolean delete(String id) {
        String checkSql = "SELECT COUNT(*) FROM SAN_PHAM WHERE ma_dm = ?";
        Integer count = JdbcHelper.queryForObject(checkSql, rs -> rs.getInt(1), id);
        if (count != null && count > 0) {
            return false; // Vi phạm ràng buộc liên kết sản phẩm
        }
        String deleteSql = "DELETE FROM DANH_MUC WHERE ma_dm = ?";
        return JdbcHelper.update(deleteSql, id) > 0;
    }

    @Override
    public List<DanhMuc> getByTrangThai(boolean status) {
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";
        return JdbcHelper.query(sql, rowMapper, status);
    }

    @Override
    public boolean checkTenDanhMucTrung(String tenDm, String excludeId) {
        String sql = excludeId == null
                ? "SELECT COUNT(*) FROM DANH_MUC WHERE ten_dm = ?"
                : "SELECT COUNT(*) FROM DANH_MUC WHERE ten_dm = ? AND ma_dm <> ?";
        Integer count;
        if (excludeId == null) {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), tenDm);
        } else {
            count = JdbcHelper.queryForObject(sql, rs -> rs.getInt(1), tenDm, excludeId);
        }
        return count != null && count > 0;
    }
}
