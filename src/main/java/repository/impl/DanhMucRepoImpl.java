package repository.impl;

import config.DBConnect;
import model.entity.DanhMuc;
import repository.IDanhMucRepository;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DanhMucRepoImpl implements IDanhMucRepository {
    private static DanhMucRepoImpl instance;

    private DanhMucRepoImpl() {}

    public static synchronized DanhMucRepoImpl getInstance() {
        if (instance == null) {
            instance = new DanhMucRepoImpl();
        }
        return instance;
    }

    @Override
    public List<DanhMuc> getAll() {
        List<DanhMuc> list = new ArrayList<>();
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC ORDER BY thu_tu_hien_thi ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DanhMuc(
                        rs.getString("ma_dm"),
                        rs.getString("ten_dm"),
                        rs.getString("hinh_anh"),
                        rs.getInt("thu_tu_hien_thi"),
                        rs.getBoolean("trang_thai")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public DanhMuc getById(String id) {
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC WHERE ma_dm = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new DanhMuc(
                            rs.getString("ma_dm"),
                            rs.getString("ten_dm"),
                            rs.getString("hinh_anh"),
                            rs.getInt("thu_tu_hien_thi"),
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
    public boolean add(DanhMuc entity) {
        // Gọi Stored Procedure sp_ThemDanhMuc tự sinh mã danh mục định dạng chuỗi: DM00001
        String sql = "{call sp_ThemDanhMuc(?, ?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, entity.getTenDm());
            cs.setString(2, entity.getHinhAnh());
            cs.setInt(3, entity.getThuTuHienThi());
            cs.setBoolean(4, entity.isTrangThai());
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    entity.setMaDm(rs.getString("ma_dm"));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(DanhMuc entity) {
        String sql = "UPDATE DANH_MUC SET ten_dm = ?, hinh_anh = ?, thu_tu_hien_thi = ?, trang_thai = ? WHERE ma_dm = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getTenDm());
            ps.setString(2, entity.getHinhAnh());
            ps.setInt(3, entity.getThuTuHienThi());
            ps.setBoolean(4, entity.isTrangThai());
            ps.setString(5, entity.getMaDm());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        // Kiểm toán 2 lớp an toàn: chỉ xóa danh mục nếu chưa phát sinh liên kết với bất kỳ sản phẩm nào
        String checkSql = "SELECT COUNT(*) FROM SAN_PHAM WHERE ma_dm = ?";
        String deleteSql = "DELETE FROM DANH_MUC WHERE ma_dm = ?";
        try (Connection conn = DBConnect.getConnection()) {
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, id);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false; // Vi phạm ràng buộc liên kết sản phẩm
                    }
                }
            }
            try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
                psDelete.setString(1, id);
                return psDelete.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<DanhMuc> getByTrangThai(boolean status) {
        List<DanhMuc> list = new ArrayList<>();
        String sql = "SELECT ma_dm, ten_dm, hinh_anh, thu_tu_hien_thi, trang_thai FROM DANH_MUC WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new DanhMuc(
                            rs.getString("ma_dm"),
                            rs.getString("ten_dm"),
                            rs.getString("hinh_anh"),
                            rs.getInt("thu_tu_hien_thi"),
                            rs.getBoolean("trang_thai")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean checkTenDanhMucTrung(String tenDm, String excludeId) {
        String sql = excludeId == null
                ? "SELECT COUNT(*) FROM DANH_MUC WHERE ten_dm = ?"
                : "SELECT COUNT(*) FROM DANH_MUC WHERE ten_dm = ? AND ma_dm <> ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenDm);
            if (excludeId != null) {
                ps.setString(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
