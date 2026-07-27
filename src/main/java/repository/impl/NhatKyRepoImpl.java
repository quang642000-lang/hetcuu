package repository.impl;

import config.DBConnect;
import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NhatKyRepoImpl implements INhatKyRepository {
    private static NhatKyRepoImpl instance;

    private NhatKyRepoImpl() {}

    public static synchronized NhatKyRepoImpl getInstance() {
        if (instance == null) {
            instance = new NhatKyRepoImpl();
        }
        return instance;
    }

    @Override
    public boolean addLog(NhatKyHoatDong log) {
        String sql = "INSERT INTO NHAT_KY_HOAT_DONG (ma_nv, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi, ip_address, thoi_gian) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (log.getMaNv() == null || log.getMaNv().trim().isEmpty() || log.getMaNv().equalsIgnoreCase("null")) {
                ps.setNull(1, Types.VARCHAR);
            } else {
                ps.setString(1, log.getMaNv().trim());
            }
            ps.setString(2, log.getHanhDong().toUpperCase().trim());
            ps.setString(3, log.getBangTacDong());
            ps.setString(4, log.getDuLieuCu());
            ps.setString(5, log.getDuLieuMoi());
            ps.setString(6, log.getIpAddress() != null ? log.getIpAddress() : "127.0.0.1");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<NhatKyHoatDong> getAllLogs() {
        List<NhatKyHoatDong> list = new ArrayList<>();
        String sql = "SELECT nk.*, nv.ho_ten AS ho_ten_nv " +
                "FROM NHAT_KY_HOAT_DONG nk " +
                "LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv " +
                "ORDER BY nk.ma_log DESC"; // Sắp xếp từ lớn đến nhỏ theo mã Log
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToNhatKy(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<NhatKyHoatDong> getLogsByNhanVien(String maNv) {
        List<NhatKyHoatDong> list = new ArrayList<>();
        String sql = "SELECT nk.*, nv.ho_ten AS ho_ten_nv " +
                "FROM NHAT_KY_HOAT_DONG nk " +
                "LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv " +
                "WHERE nk.ma_nv = ? " +
                "ORDER BY nk.ma_log DESC"; // Sắp xếp từ lớn đến nhỏ theo mã Log
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNv);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToNhatKy(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Bộ lọc kiểm toán nâng cao đối soát
    public List<NhatKyHoatDong> getFilteredLogs(String search, String action, String tableName, String startDate, String endDate) {
        List<NhatKyHoatDong> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT nk.*, nv.ho_ten AS ho_ten_nv " +
                        "FROM NHAT_KY_HOAT_DONG nk " +
                        "LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv " +
                        "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (nk.ma_nv LIKE ? OR nv.ho_ten LIKE ? OR nk.bang_tac_dong LIKE ? OR nk.du_lieu_cu LIKE ? OR nk.du_lieu_moi LIKE ?) ");
            String likeVal = "%" + search.trim() + "%";
            params.add(likeVal);
            params.add(likeVal);
            params.add(likeVal);
            params.add(likeVal);
            params.add(likeVal);
        }

        if (action != null && !action.trim().isEmpty()) {
            sql.append("AND nk.hanh_dong = ? ");
            params.add(action.trim().toUpperCase());
        }

        if (tableName != null && !tableName.trim().isEmpty()) {
            sql.append("AND nk.bang_tac_dong LIKE ? ");
            params.add(tableName.trim().toUpperCase() + "%");
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND nk.thoi_gian >= ? ");
            params.add(Timestamp.valueOf(startDate.trim() + " 00:00:00"));
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND nk.thoi_gian <= ? ");
            params.add(Timestamp.valueOf(endDate.trim() + " 23:59:59"));
        }

        sql.append("ORDER BY nk.ma_log DESC"); // Sắp xếp từ lớn đến nhỏ (mã log mới nhất lên đầu)

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToNhatKy(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private NhatKyHoatDong mapResultSetToNhatKy(ResultSet rs) throws SQLException {
        NhatKyHoatDong log = new NhatKyHoatDong();
        log.setMaLog(rs.getLong("ma_log"));
        log.setMaNv(rs.getString("ma_nv"));
        log.setHanhDong(rs.getString("hanh_dong"));
        log.setBangTacDong(rs.getString("bang_tac_dong"));
        log.setDuLieuCu(rs.getString("du_lieu_cu"));
        log.setDuLieuMoi(rs.getString("du_lieu_moi"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setThoiGian(rs.getTimestamp("thoi_gian"));

        // Gán hoTenNhanVien tiếng Việt có dấu lấy từ LEFT JOIN
        String tenNv = rs.getString("ho_ten_nv");
        if (tenNv == null || tenNv.trim().isEmpty()) {
            log.setHoTenNhanVien("Khách đặt Online");
        } else {
            log.setHoTenNhanVien(tenNv.trim());
        }
        return log;
    }

    public static boolean recordActivity(String maNv, String action, String tableName, String primaryKey, String oldData, String newData, String ipAddress) {
        NhatKyHoatDong log = new NhatKyHoatDong();
        log.setMaNv(maNv);
        log.setHanhDong(action.toUpperCase().trim());
        log.setBangTacDong(tableName.toUpperCase().trim() + " [" + primaryKey.trim() + "]");
        log.setDuLieuCu(oldData);
        log.setDuLieuMoi(newData);
        log.setIpAddress(ipAddress != null ? ipAddress : "127.0.0.1");
        return getInstance().addLog(log);
    }
}
