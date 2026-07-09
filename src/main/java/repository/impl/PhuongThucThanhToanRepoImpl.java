package repository.impl;

import config.DBConnect;
import model.entity.PhuongThucThanhToan;
import repository.IPhuongThucThanhToanRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PhuongThucThanhToanRepoImpl implements IPhuongThucThanhToanRepository {

    private static PhuongThucThanhToanRepoImpl instance;

    private PhuongThucThanhToanRepoImpl() {}

    public static synchronized PhuongThucThanhToanRepoImpl getInstance() {
        if (instance == null) {
            instance = new PhuongThucThanhToanRepoImpl();
        }
        return instance;
    }

    @Override
    public List<PhuongThucThanhToan> getAll() {
        List<PhuongThucThanhToan> list = new ArrayList<>();
        String sql = "SELECT ma_pt, ten_pt, trang_thai FROM PHUONG_THUC_THANH_TOAN ORDER BY ma_pt ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new PhuongThucThanhToan(
                        rs.getInt("ma_pt"),
                        rs.getString("ten_pt"),
                        rs.getBoolean("trang_thai")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public PhuongThucThanhToan getById(Integer id) {
        String sql = "SELECT ma_pt, ten_pt, trang_thai FROM PHUONG_THUC_THANH_TOAN WHERE ma_pt = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new PhuongThucThanhToan(
                            rs.getInt("ma_pt"),
                            rs.getString("ten_pt"),
                            rs.getBoolean("trang_thai")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(PhuongThucThanhToan entity) {
        String sql = "INSERT INTO PHUONG_THUC_THANH_TOAN (ten_pt, trang_thai) VALUES (?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenPt());
            ps.setBoolean(2, entity.isTrangThai());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(PhuongThucThanhToan entity) {
        String sql = "UPDATE PHUONG_THUC_THANH_TOAN SET ten_pt = ?, trang_thai = ? WHERE ma_pt = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenPt());
            ps.setBoolean(2, entity.isTrangThai());
            ps.setInt(3, entity.getMaPt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "UPDATE PHUONG_THUC_THANH_TOAN SET trang_thai = 0 WHERE ma_pt = ?";
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
    public List<PhuongThucThanhToan> getByTrangThai(boolean status) {
        List<PhuongThucThanhToan> list = new ArrayList<>();
        String sql = "SELECT ma_pt, ten_pt, trang_thai FROM PHUONG_THUC_THANH_TOAN WHERE trang_thai = ? ORDER BY ma_pt ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PhuongThucThanhToan(
                            rs.getInt("ma_pt"),
                            rs.getString("ten_pt"),
                            rs.getBoolean("trang_thai")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
