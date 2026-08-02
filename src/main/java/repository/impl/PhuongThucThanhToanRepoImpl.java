package repository.impl;

import model.entity.PhuongThucThanhToan;
import repository.IPhuongThucThanhToanRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class PhuongThucThanhToanRepoImpl implements IPhuongThucThanhToanRepository {
    private static PhuongThucThanhToanRepoImpl instance;
    private final RowMapper<PhuongThucThanhToan> rowMapper = rs -> new PhuongThucThanhToan(
            rs.getInt("ma_pt"),
            rs.getString("ten_pt"),
            rs.getBoolean("trang_thai")
    );

    private PhuongThucThanhToanRepoImpl() {}

    public static synchronized PhuongThucThanhToanRepoImpl getInstance() {
        if (instance == null) {
            instance = new PhuongThucThanhToanRepoImpl();
        }
        return instance;
    }

    @Override
    public List<PhuongThucThanhToan> getAll() {
        String sql = "SELECT * FROM PHUONG_THUC_THANH_TOAN ORDER BY ma_pt ASC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public PhuongThucThanhToan getById(Integer id) {
        String sql = "SELECT * FROM PHUONG_THUC_THANH_TOAN WHERE ma_pt = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(PhuongThucThanhToan entity) {
        String sql = "INSERT INTO PHUONG_THUC_THANH_TOAN (ten_pt, trang_thai) VALUES (?, ?)";
        return JdbcHelper.update(sql, entity.getTenPt(), entity.isTrangThai()) > 0;
    }

    @Override
    public boolean update(PhuongThucThanhToan entity) {
        String sql = "UPDATE PHUONG_THUC_THANH_TOAN SET ten_pt = ?, trang_thai = ? WHERE ma_pt = ?";
        return JdbcHelper.update(sql, entity.getTenPt(), entity.isTrangThai(), entity.getMaPt()) > 0;
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "UPDATE PHUONG_THUC_THANH_TOAN SET trang_thai = 0 WHERE ma_pt = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public List<PhuongThucThanhToan> getByTrangThai(boolean status) {
        String sql = "SELECT * FROM PHUONG_THUC_THANH_TOAN WHERE trang_thai = ? ORDER BY ma_pt ASC";
        return JdbcHelper.query(sql, rowMapper, status);
    }
}
