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
        // Cơ chế phòng vệ 2 lớp: Thử SELECT hinh_anh, nếu SQL Server báo lỗi thiếu cột thì tự động lùi về SELECT không có hinh_anh
        String sqlWithImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING ORDER BY thu_tu_hien_thi ASC";
        String sqlNoImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai FROM TOPPING ORDER BY thu_tu_hien_thi ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithImg);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToTopping(rs, true));
            }
            return list;
        } catch (SQLException e) {
            // Có khả năng DB chưa chạy lệnh ALTER TABLE thêm cột hinh_anh -> Chạy câu lệnh dự phòng (Fallback)
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlNoImg);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToTopping(rs, false));
                }
                return list;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return list;
    }

    @Override
    public Topping getById(Integer id) {
        String sqlWithImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE ma_tp = ?";
        String sqlNoImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai FROM TOPPING WHERE ma_tp = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithImg)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTopping(rs, true);
                }
            }
        } catch (SQLException e) {
            // Chạy câu lệnh dự phòng (Fallback) khi không có cột hinh_anh
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlNoImg)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToTopping(rs, false);
                    }
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return null;
    }

    @Override
    public boolean add(Topping entity) {
        String sqlWithImg = "INSERT INTO TOPPING (ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh) VALUES (?, ?, ?, ?, ?, ?)";
        String sqlNoImg = "INSERT INTO TOPPING (ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithImg)) {
            ps.setString(1, entity.getTenTp());
            ps.setString(2, entity.getDinhLuong());
            ps.setInt(3, entity.getGiaBan());
            ps.setInt(4, entity.getThuTuHienThi());
            ps.setBoolean(5, entity.isTrangThai());
            ps.setString(6, entity.getHinhAnh());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Dự phòng (Fallback) ghi nhận không lưu hình ảnh
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlNoImg)) {
                ps.setString(1, entity.getTenTp());
                ps.setString(2, entity.getDinhLuong());
                ps.setInt(3, entity.getGiaBan());
                ps.setInt(4, entity.getThuTuHienThi());
                ps.setBoolean(5, entity.isTrangThai());
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
                return false;
            }
        }
    }

    @Override
    public boolean update(Topping entity) {
        String sqlWithImg = "UPDATE TOPPING SET ten_tp = ?, dinh_luong = ?, gia_ban = ?, thu_tu_hien_thi = ?, trang_thai = ?, hinh_anh = ? WHERE ma_tp = ?";
        String sqlNoImg = "UPDATE TOPPING SET ten_tp = ?, dinh_luong = ?, gia_ban = ?, thu_tu_hien_thi = ?, trang_thai = ? WHERE ma_tp = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithImg)) {
            ps.setString(1, entity.getTenTp());
            ps.setString(2, entity.getDinhLuong());
            ps.setInt(3, entity.getGiaBan());
            ps.setInt(4, entity.getThuTuHienThi());
            ps.setBoolean(5, entity.isTrangThai());
            ps.setString(6, entity.getHinhAnh());
            ps.setInt(7, entity.getMaTp());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Dự phòng (Fallback) khi update không có cột hinh_anh
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlNoImg)) {
                ps.setString(1, entity.getTenTp());
                ps.setString(2, entity.getDinhLuong());
                ps.setInt(3, entity.getGiaBan());
                ps.setInt(4, entity.getThuTuHienThi());
                ps.setBoolean(5, entity.isTrangThai());
                ps.setInt(6, entity.getMaTp());
                return ps.executeUpdate() > 0;
            } catch (SQLException ex) {
                ex.printStackTrace();
                return false;
            }
        }
    }

    @Override
    public boolean delete(Integer id) {
        return updateTrangThai(id, false);
    }

    @Override
    public List<Topping> getByTrangThai(boolean status) {
        List<Topping> list = new ArrayList<>();
        String sqlWithImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai, hinh_anh FROM TOPPING WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";
        String sqlNoImg = "SELECT ma_tp, ten_tp, dinh_luong, gia_ban, thu_tu_hien_thi, trang_thai FROM TOPPING WHERE trang_thai = ? ORDER BY thu_tu_hien_thi ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlWithImg)) {
            ps.setBoolean(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToTopping(rs, true));
                }
            }
            return list;
        } catch (SQLException e) {
            // Chạy câu lệnh dự phòng (Fallback)
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlNoImg)) {
                ps.setBoolean(1, status);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToTopping(rs, false));
                    }
                }
                return list;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return list;
    }

    @Override
    public boolean updateTrangThai(int maTp, boolean status) {
        String sql = "UPDATE TOPPING SET trang_thai = ? WHERE ma_tp = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, status);
            ps.setInt(2, maTp);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Topping mapResultSetToTopping(ResultSet rs, boolean hasImgColumn) throws SQLException {
        Topping tp = new Topping(
                rs.getInt("ma_tp"),
                rs.getString("ten_tp"),
                rs.getString("dinh_luong"),
                rs.getInt("gia_ban"),
                rs.getInt("thu_tu_hien_thi"),
                rs.getBoolean("trang_thai")
        );
        if (hasImgColumn) {
            try {
                tp.setHinhAnh(rs.getString("hinh_anh"));
            } catch (SQLException e) {
                tp.setHinhAnh("");
            }
        } else {
            tp.setHinhAnh("");
        }
        return tp;
    }
}
