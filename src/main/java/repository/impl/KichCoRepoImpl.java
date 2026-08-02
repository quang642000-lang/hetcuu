package repository.impl;

import model.entity.KichCo;
import repository.IKichCoRepository;
import repository.RowMapper;
import util.JdbcHelper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class KichCoRepoImpl implements IKichCoRepository {
    private static KichCoRepoImpl instance;
    private final RowMapper<KichCo> rowMapper = rs -> new KichCo(
            rs.getInt("ma_size"),
            rs.getString("ten_size"),
            rs.getInt("thu_tu_hien_thi")
    );

    private KichCoRepoImpl() {}

    public static synchronized KichCoRepoImpl getInstance() {
        if (instance == null) {
            instance = new KichCoRepoImpl();
        }
        return instance;
    }

    @Override
    public List<KichCo> getAll() {
        String sql = "SELECT * FROM KICH_CO ORDER BY thu_tu_hien_thi ASC";
        return JdbcHelper.query(sql, rowMapper);
    }

    @Override
    public KichCo getById(Integer id) {
        String sql = "SELECT * FROM KICH_CO WHERE ma_size = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, id);
    }

    @Override
    public boolean add(KichCo entity) {
        String sql = "INSERT INTO KICH_CO (ten_size, thu_tu_hien_thi) VALUES (?, ?)";
        return JdbcHelper.update(sql, entity.getTenSize(), entity.getThuTuHienThi()) > 0;
    }

    @Override
    public boolean update(KichCo entity) {
        String sql = "UPDATE KICH_CO SET ten_size = ?, thu_tu_hien_thi = ? WHERE ma_size = ?";
        return JdbcHelper.update(sql, entity.getTenSize(), entity.getThuTuHienThi(), entity.getMaSize()) > 0;
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM KICH_CO WHERE ma_size = ?";
        return JdbcHelper.update(sql, id) > 0;
    }

    @Override
    public KichCo getByTenSize(String tenSize) {
        String sql = "SELECT * FROM KICH_CO WHERE ten_size = ?";
        return JdbcHelper.queryForObject(sql, rowMapper, tenSize);
    }
}
