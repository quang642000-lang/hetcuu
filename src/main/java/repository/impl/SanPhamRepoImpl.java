package repository.impl;

import config.DBConnect;
import model.entity.SanPham;
import repository.ISanPhamRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SanPhamRepoImpl implements ISanPhamRepository {

    private static SanPhamRepoImpl instance;

    private SanPhamRepoImpl() {}

    public static synchronized SanPhamRepoImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamRepoImpl();
        }
        return instance;
    }

    @Override
    public List<SanPham> getAll() {
        List<SanPham> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSanPham(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public SanPham getById(String id) {
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM WHERE ma_sp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSanPham(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(SanPham entity) {
        String sql = "{call sp_ThemSanPham(?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setInt(1, entity.getMaDm());
            cs.setString(2, entity.getTenSp());
            cs.setString(3, entity.getMoTa());
            cs.setString(4, entity.getHinhAnh());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaSp(rs.getString("ma_sp"));
                    updateFlags(entity);
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void updateFlags(SanPham entity) throws SQLException {
        String sql = "UPDATE SAN_PHAM SET cho_phep_doi_da = ?, cho_phep_doi_duong = ?, is_new = ?, is_bestseller = ?, trang_thai = ? WHERE ma_sp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, entity.isChoPhepDoiDa());
            ps.setBoolean(2, entity.isChoPhepDoiDuong());
            ps.setBoolean(3, entity.getIsNew()); // Đã sửa
            ps.setBoolean(4, entity.getIsBestseller()); // Đã sửa
            ps.setBoolean(5, entity.isTrangThai());
            ps.setString(6, entity.getMaSp());
            ps.executeUpdate();
        }
    }

    @Override
    public boolean update(SanPham entity) {
        String sql = "UPDATE SAN_PHAM SET ma_dm = ?, ten_sp = ?, mo_ta = ?, hinh_anh = ?, cho_phep_doi_da = ?, cho_phep_doi_duong = ?, is_new = ?, is_bestseller = ?, trang_thai = ? WHERE ma_sp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, entity.getMaDm());
            ps.setString(2, entity.getTenSp());
            ps.setString(3, entity.getMoTa());
            ps.setString(4, entity.getHinhAnh());
            ps.setBoolean(5, entity.isChoPhepDoiDa());
            ps.setBoolean(6, entity.isChoPhepDoiDuong());
            ps.setBoolean(7, entity.getIsNew()); // Đã sửa
            ps.setBoolean(8, entity.getIsBestseller()); // Đã sửa
            ps.setBoolean(9, entity.isTrangThai());
            ps.setString(10, entity.getMaSp());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        String sql = "UPDATE SAN_PHAM SET trang_thai = 0 WHERE ma_sp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<SanPham> getByDanhMuc(int maDm) {
        List<SanPham> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM WHERE ma_dm = ? AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maDm);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSanPham(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<SanPham> getBestsellers() {
        List<SanPham> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM WHERE is_bestseller = 1 AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSanPham(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<SanPham> getNewArrivals() {
        List<SanPham> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM WHERE is_new = 1 AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSanPham(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<SanPham> searchByName(String keyword) {
        List<SanPham> list = new ArrayList<>();
        String sql = "SELECT ma_sp, ma_dm, ten_sp, mo_ta, hinh_anh, cho_phep_doi_da, cho_phep_doi_duong, is_new, is_bestseller, trang_thai, thoi_gian_tao, thoi_gian_cap_nhat FROM SAN_PHAM WHERE ten_sp LIKE ? AND trang_thai = 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSanPham(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private SanPham mapResultSetToSanPham(ResultSet rs) throws SQLException {
        return new SanPham(
                rs.getString("ma_sp"),
                rs.getInt("ma_dm"),
                rs.getString("ten_sp"),
                rs.getString("mo_ta"),
                rs.getString("hinh_anh"),
                rs.getBoolean("cho_phep_doi_da"),
                rs.getBoolean("cho_phep_doi_duong"),
                rs.getBoolean("is_new"),
                rs.getBoolean("is_bestseller"),
                rs.getBoolean("trang_thai"),
                rs.getTimestamp("thoi_gian_tao"),
                rs.getTimestamp("thoi_gian_cap_nhat")
        );
    }
}