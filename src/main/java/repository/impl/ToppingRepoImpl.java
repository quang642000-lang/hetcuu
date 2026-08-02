package repository.impl;

import config.DBConnect;
import model.entity.Topping;
import repository.IToppingRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ToppingRepoImpl implements IToppingRepository {
    private static ToppingRepoImpl instance;

    private final RowMapper<Topping> rowMapper = rs -> {
        Topping tp = new Topping(
                rs.getString("ma_tp"),
                rs.getString("ten_tp"),
                rs.getString("dinh_luong"),
                rs.getInt("gia_ban"),
                rs.getInt("thu_tu_hien_thi"),
                rs.getBoolean("trang_thai")
        );
        tp.setHinhAnh(rs.getString("hinh_anh"));
        return tp;
    };

    private ToppingRepoImpl() {}

    public static synchronized ToppingRepoImpl getInstance() {
        if (instance == null) {
            instance = new ToppingRepoImpl();
        }
        return instance;
    }

    @Override
    public List<Topping> getAll() {
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING ORDER BY thu_tu_hien_thi ASC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public Topping getById(String id) {
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE ma_tp = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(Topping entity) {
        // SỬA LỖI CHÍ MẠNG: Sử dụng inline lambda 'rs -> rs.getString("ma_tp")' thay vì 'rowMapper' toàn cục
        // để tránh lỗi SQLServerException "The column name ten_tp is not valid" do Stored Procedure chỉ trả về duy nhất cột ma_tp.
        String sql = "{call sp_ThemTopping(?, ?, ?, ?, ?, ?)}";
        String generatedId = JdbcHelper.queryForObject(sql, rs -> rs.getString("ma_tp"),
                entity.getTenTp(),
                entity.getDinhLuong(),
                entity.getGiaBan(),
                entity.getThuTuHienThi(),
                entity.isTrangThai(),
                entity.getHinhAnh()
        );
        if (generatedId != null) {
            entity.setMaTp(generatedId);
            return true;
        }
        return false;
    }

    @Override
    public boolean update(Topping entity) {
        String sql = "UPDATE TOPPING SET ten_tp = ?, dinh_luong = ?, gia_ban = ?, thu_tu_hien_thi = ?, trang_thai = ?, hinh_anh = ? WHERE ma_tp = ?";
        return JdbcHelper.update(sql,
                entity.getTenTp(),
                entity.getDinhLuong(),
                entity.getGiaBan(),
                entity.getThuTuHienThi(),
                entity.isTrangThai(),
                entity.getHinhAnh(),
                entity.getMaTp()
        ) > 0;
    }

    @Override
    public boolean delete(String id) {
        return updateTrangThai(id, false);
    }

    @Override
    public List<Topping> getByTrangThai(boolean status) {
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";
        return JdbcHelper.query(sql, rowMapper, status);
    }

    @Override
    public boolean updateTrangThai(String maTp, boolean status) {
        String sql = "UPDATE TOPPING SET trang_thai = ? WHERE ma_tp = ?";
        return JdbcHelper.update(sql, status, maTp) > 0;
    }
}
