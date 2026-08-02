package repository.impl;

import model.entity.SanPhamKichCo;
import repository.ISanPhamKichCoRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class SanPhamKichCoRepoImpl implements ISanPhamKichCoRepository {
    private static SanPhamKichCoRepoImpl instance;
    private final RowMapper<SanPhamKichCo> rowMapper = rs -> {
        SanPhamKichCo spkc = new SanPhamKichCo(
                rs.getString("ma_sp"),
                rs.getInt("ma_size"),
                rs.getInt("gia_ban"),
                rs.getString("dinh_luong"),
                rs.getBoolean("trang_thai")
        );
        spkc.setTenSize(rs.getString("ten_size"));
        return spkc;
    };

    private SanPhamKichCoRepoImpl() {}

    public static synchronized SanPhamKichCoRepoImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamKichCoRepoImpl();
        }
        return instance;
    }

    @Override
    public List<SanPhamKichCo> getAll() {
        String sql = "SELECT pk.ma_sp, pk.ma_size, pk.gia_ban, pk.dinh_luong, pk.trang_thai, kc.ten_size " +
                "FROM SAN_PHAM_KICH_CO pk " +
                "JOIN KICH_CO kc ON pk.ma_size = kc.ma_size " +
                "ORDER BY pk.ma_sp ASC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public List<SanPhamKichCo> getBySanPham(String maSp) {
        String sql = "SELECT pk.ma_sp, pk.ma_size, pk.gia_ban, pk.dinh_luong, pk.trang_thai, kc.ten_size " +
                "FROM SAN_PHAM_KICH_CO pk " +
                "JOIN KICH_CO kc ON pk.ma_size = kc.ma_size " +
                "WHERE pk.ma_sp = ? AND pk.trang_thai = 1";
        return JdbcHelper.query(sql, rowMapper, maSp);
    }

    @Override
    public SanPhamKichCo getBySanPhamAndSize(String maSp, int maSize) {
        String sql = "SELECT pk.ma_sp, pk.ma_size, pk.gia_ban, pk.dinh_luong, pk.trang_thai, kc.ten_size " +
                "FROM SAN_PHAM_KICH_CO pk " +
                "JOIN KICH_CO kc ON pk.ma_size = kc.ma_size " +
                "WHERE pk.ma_sp = ? AND pk.ma_size = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, maSp, maSize);
    }

    @Override
    public boolean add(SanPhamKichCo entity) {
        String sql = "INSERT INTO SAN_PHAM_KICH_CO (ma_sp, ma_size, gia_ban, dinh_luong, trang_thai) VALUES (?, ?, ?, ?, ?)";
        return JdbcHelper.update(sql, entity.getMaSp(), entity.getMaSize(), entity.getGiaBan(), entity.getDinhLuong(), entity.isTrangThai()) > 0;
    }

    @Override
    public boolean update(SanPhamKichCo entity) {
        String sql = "UPDATE SAN_PHAM_KICH_CO SET gia_ban = ?, dinh_luong = ?, trang_thai = ? WHERE ma_sp = ? AND ma_size = ?";
        return JdbcHelper.update(sql, entity.getGiaBan(), entity.getDinhLuong(), entity.isTrangThai(), entity.getMaSp(), entity.getMaSize()) > 0;
    }

    @Override
    public boolean delete(String maSp, int maSize) {
        String sql = "UPDATE SAN_PHAM_KICH_CO SET trang_thai = 0 WHERE ma_sp = ? AND ma_size = ?";
        return JdbcHelper.update(sql, maSp, maSize) > 0;
    }

    @Override
    public boolean deleteAllBySanPham(String maSp) {
        String sql = "DELETE FROM SAN_PHAM_KICH_CO WHERE ma_sp = ?";
        return JdbcHelper.update(sql, maSp) > 0;
    }
}
