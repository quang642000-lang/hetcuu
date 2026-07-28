package repository.impl;

import config.DBConnect;
import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class NhatKyRepoImpl implements INhatKyRepository {
    private static NhatKyRepoImpl instance;
    private NhatKyRepoImpl() {}

    public static synchronized NhatKyRepoImpl getInstance() {
        if (instance == null) {
            instance = new NhatKyRepoImpl();
        }
        return instance;
    }

    /**
     * BẢO MẬT CHỐT CHẶN: Che giấu thông tin nhạy cảm (Mật khẩu) trong chuỗi JSON log bằng Regex
     */
    private String maskSensitiveData(String json) {
        if (json == null || json.trim().isEmpty()) return json;
        // Regex tìm khóa "matKhau" hoặc "password" bất kể viết hoa viết thường
        Pattern pattern = Pattern.compile("(\"(?:matKhau|password|mat_khau)\":\\s*\")[^\"]+(\")", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.replaceAll("$1********$2");
        }
        return json;
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

            // Thực hiện che giấu dữ liệu mật khẩu nhạy cảm
            ps.setString(4, maskSensitiveData(log.getDuLieuCu()));
            ps.setString(5, maskSensitiveData(log.getDuLieuMoi()));

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
        String sql = "SELECT nk.*, nv.ho_ten AS ho_ten_nv FROM NHAT_KY_HOAT_DONG nk LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv ORDER BY nk.ma_log DESC";
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
        String sql = "SELECT nk.*, nv.ho_ten AS ho_ten_nv FROM NHAT_KY_HOAT_DONG nk LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv WHERE nk.ma_nv = ? ORDER BY nk.ma_log DESC";
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

    /**
     * TỐI ƯU ARCHITECTURE: Phân trang từ mức SERVER-SIDE bằng SQL OFFSET-FETCH
     * Triệt tiêu hoàn toàn gánh nặng OOM khi bảng log phình to lên hàng triệu dòng.
     */
    public List<NhatKyHoatDong> getFilteredLogsServerSide(String search, String action, String tableName, String startDate, String endDate, int page, int pageSize) {
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
            params.add(likeVal); params.add(likeVal); params.add(likeVal); params.add(likeVal); params.add(likeVal);
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

        sql.append("ORDER BY nk.ma_log DESC ");

        // OFFSET - FETCH: Thuật toán phân trang tối thượng của SQL Server
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);

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

    /**
     * Lấy tổng số dòng nhật ký thỏa điều kiện lọc để phân trang chính xác
     */
    public int getFilteredLogsCount(String search, String action, String tableName, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM NHAT_KY_HOAT_DONG nk LEFT JOIN NHAN_VIEN nv ON nk.ma_nv = nv.ma_nv WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (nk.ma_nv LIKE ? OR nv.ho_ten LIKE ? OR nk.bang_tac_dong LIKE ? OR nk.du_lieu_cu LIKE ? OR nk.du_lieu_moi LIKE ?) ");
            String likeVal = "%" + search.trim() + "%";
            params.add(likeVal); params.add(likeVal); params.add(likeVal); params.add(likeVal); params.add(likeVal);
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

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
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