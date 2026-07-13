package repository.impl;

import config.DBConnect;
import model.entity.Topping;
import repository.IToppingRepository;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ToppingRepoImpl implements IToppingRepository {
    private static ToppingRepoImpl instance;

    private ToppingRepoImpl() {}

    public static synchronized ToppingRepoImpl getInstance() {
        if (instance == null) {
            instance = new ToppingRepoImpl();
        }
        return instance;
    }

    @Override
    public List<Topping> getAll() {
        List<Topping> list = new ArrayList<>();
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING ORDER BY thu_tu_hien_thi ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToTopping(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Topping getById(String id) {
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE ma_tp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTopping(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(Topping entity) {
        String sql = "{call sp_ThemTopping(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entity.getTenTp());
            cs.setString(2, entity.getDinhLuong());
            cs.setInt(3, entity.getGiaBan());
            cs.setInt(4, entity.getThuTuHienThi());
            cs.setBoolean(5, entity.isTrangThai());
            cs.setString(6, entity.getHinhAnh());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaTp(rs.getString("ma_tp"));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(Topping entity) {
        String sql = "UPDATE TOPPING SET ten_tp = ?, dinh_luong = ?, gia_ban = ?, thu_tu_hien_thi = ?, trang_thai = ?, hinh_anh = ? WHERE ma_tp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenTp());
            ps.setString(2, entity.getDinhLuong());
            ps.setInt(3, entity.getGiaBan());
            ps.setInt(4, entity.getThuTuHienThi());
            ps.setBoolean(5, entity.isTrangThai());
            ps.setString(6, entity.getHinhAnh());
            ps.setString(7, entity.getMaTp());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        return updateTrangThai(id, false);
    }

    @Override
    public List<Topping> getByTrangThai(boolean status) {
        List<Topping> list = new ArrayList<>();
        String sql = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToTopping(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateTrangThai(String maTp, boolean status) {
        String sql = "UPDATE TOPPING SET trang_thai = ? WHERE ma_tp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setString(2, maTp);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Topping mapResultSetToTopping(ResultSet rs) throws SQLException {
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
    }
}
