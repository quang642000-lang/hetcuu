package repository.impl;

import config.DBConnect;
import model.entity.KichCo;
import repository.IKichCoRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KichCoRepoImpl implements IKichCoRepository {

    private static KichCoRepoImpl instance;

    private KichCoRepoImpl() {}

    public static synchronized KichCoRepoImpl getInstance() {
        if (instance == null) {
            instance = new KichCoRepoImpl();
        }
        return instance;
    }

    @Override
    public List<KichCo> getAll() {
        List<KichCo> list = new ArrayList<>();
        String sql = "SELECT ma_size, ten_size, thu_tu_hien_thi FROM KICH_CO ORDER BY thu_tu_hien_thi ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new KichCo(
                        rs.getInt("ma_size"),
                        rs.getString("ten_size"),
                        rs.getInt("thu_tu_hien_thi")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public KichCo getById(Integer id) {
        String sql = "SELECT ma_size, ten_size, thu_tu_hien_thi FROM KICH_CO WHERE ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new KichCo(
                            rs.getInt("ma_size"),
                            rs.getString("ten_size"),
                            rs.getInt("thu_tu_hien_thi")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(KichCo entity) {
        String sql = "INSERT INTO KICH_CO (ten_size, thu_tu_hien_thi) VALUES (?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenSize());
            ps.setInt(2, entity.getThuTuHienThi());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(KichCo entity) {
        String sql = "UPDATE KICH_CO SET ten_size = ?, thu_tu_hien_thi = ? WHERE ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenSize());
            ps.setInt(2, entity.getThuTuHienThi());
            ps.setInt(3, entity.getMaSize());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM KICH_CO WHERE ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public KichCo getByTenSize(String tenSize) {
        String sql = "SELECT ma_size, ten_size, thu_tu_hien_thi FROM KICH_CO WHERE ten_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenSize);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new KichCo(
                            rs.getInt("ma_size"),
                            rs.getString("ten_size"),
                            rs.getInt("thu_tu_hien_thi")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
