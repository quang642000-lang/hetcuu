package repository.impl;

import config.DBConnect;
import model.entity.SanPhamKichCo;
import repository.ISanPhamKichCoRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SanPhamKichCoRepoImpl implements ISanPhamKichCoRepository {

    private static SanPhamKichCoRepoImpl instance;

    private SanPhamKichCoRepoImpl() {}

    public static synchronized SanPhamKichCoRepoImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamKichCoRepoImpl();
        }
        return instance;
    }

    @Override
    public List<SanPhamKichCo> getAll() {
        List<SanPhamKichCo> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_size, gia_ban, dinh_luong, trang_thai FROM SAN_PHAM_KICH_CO ORDER BY ma_sp ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSanPhamKichCo(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<SanPhamKichCo> getBySanPham(String maSp) {
        List<SanPhamKichCo> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_size, gia_ban, dinh_luong, trang_thai FROM SAN_PHAM_KICH_CO WHERE ma_sp = ? AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maSp);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSanPhamKichCo(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public SanPhamKichCo getBySanPhamAndSize(String maSp, int maSize) {
        String sql = "SELECT ma_sp, ma_size, gia_ban, dinh_luong, trang_thai FROM SAN_PHAM_KICH_CO WHERE ma_sp = ? AND ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maSp);
            ps.setInt(2, maSize);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSanPhamKichCo(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(SanPhamKichCo entity) {
        String sql = "INSERT INTO SAN_PHAM_KICH_CO (ma_sp, ma_size, gia_ban, dinh_luong, trang_thai) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getMaSp());
            ps.setInt(2, entity.getMaSize());
            ps.setInt(3, entity.getGiaBan());
            ps.setString(4, entity.getDinhLuong());
            ps.setBoolean(5, entity.isTrangThai());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(SanPhamKichCo entity) {
        String sql = "UPDATE SAN_PHAM_KICH_CO SET gia_ban = ?, dinh_luong = ?, trang_thai = ? WHERE ma_sp = ? AND ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entity.getGiaBan());
            ps.setString(2, entity.getDinhLuong());
            ps.setBoolean(3, entity.isTrangThai());
            ps.setString(4, entity.getMaSp());
            ps.setInt(5, entity.getMaSize());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String maSp, int maSize) {
        String sql = "UPDATE SAN_PHAM_KICH_CO SET trang_thai = 0 WHERE ma_sp = ? AND ma_size = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maSp);
            ps.setInt(2, maSize);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteAllBySanPham(String maSp) {
        String sql = "DELETE FROM SAN_PHAM_KICH_CO WHERE ma_sp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maSp);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private SanPhamKichCo mapResultSetToSanPhamKichCo(ResultSet rs) throws SQLException {
        return new SanPhamKichCo(
                rs.getString("ma_sp"),
                rs.getInt("ma_size"),
                rs.getInt("gia_ban"),
                rs.getString("dinh_luong"),
                rs.getBoolean("trang_thai")
        );
    }
}