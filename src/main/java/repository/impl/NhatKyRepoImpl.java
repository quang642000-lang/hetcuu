package repository.impl;

import config.DBConnect;
import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
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

            // Xử lý mã nhân viên nullable (Nếu rỗng hoặc null thì ghi nhận NULL vật lý tránh sập khóa ngoại)
            if (log.getMaNv() == null || log.getMaNv().trim().isEmpty() || log.getMaNv().equalsIgnoreCase("null")) {
                ps.setNull(1, Types.VARCHAR);
            } else {
                ps.setString(1, log.getMaNv().trim());
            }

            ps.setString(2, log.getHanhDong());
            ps.setString(3, log.getBangTacDong()); // Chứa tên bảng và mã khóa chính (ví dụ: "SAN_PHAM [SP00001]")
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
        String sql = "SELECT ma_log, ma_nv, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi, ip_address, thoi_gian FROM NHAT_KY_HOAT_DONG ORDER BY thoi_gian DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                NhatKyHoatDong log = new NhatKyHoatDong();
                log.setMaLog(rs.getLong("ma_log"));
                log.setMaNv(rs.getString("ma_nv"));
                log.setHanhDong(rs.getNString("hanh_dong"));
                log.setBangTacDong(rs.getString("bang_tac_dong"));
                log.setDuLieuCu(rs.getNString("du_lieu_cu"));
                log.setDuLieuMoi(rs.getNString("du_lieu_moi"));
                log.setIpAddress(rs.getString("ip_address"));
                log.setThoiGian(rs.getTimestamp("thoi_gian"));
                list.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<NhatKyHoatDong> getLogsByNhanVien(String maNv) {
        List<NhatKyHoatDong> list = new ArrayList<>();
        String sql = "SELECT ma_log, ma_nv, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi, ip_address, thoi_gian FROM NHAT_KY_HOAT_DONG WHERE ma_nv = ? ORDER BY thoi_gian DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNv);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NhatKyHoatDong log = new NhatKyHoatDong();
                    log.setMaLog(rs.getLong("ma_log"));
                    log.setMaNv(rs.getString("ma_nv"));
                    log.setHanhDong(rs.getNString("hanh_dong"));
                    log.setBangTacDong(rs.getString("bang_tac_dong"));
                    log.setDuLieuCu(rs.getNString("du_lieu_cu"));
                    log.setDuLieuMoi(rs.getNString("du_lieu_moi"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setThoiGian(rs.getTimestamp("thoi_gian"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * HÀM TIỆN ÍCH CAO CẤP: Đối soát và ghi nhật ký hoạt động thông minh (Audit Trail Engine)
     * Chỉ lưu vết các thao tác Đăng nhập/Đăng xuất và các lệnh Thay đổi dữ liệu nhạy cảm (Insert, Update, Delete)
     * Đối với sửa: Đối soát từng trường thuộc tính biến động (Giá cũ -> Giá mới).
     * Đối với thêm: Liệt kê chi tiết các thông tin vừa được nạp vào hệ thống.
     * Đối với xóa: Lưu trữ mã khóa chính và bảng bị tác động để phục vụ quản lý.
     */
    public static boolean recordActivity(String maNv, String action, String tableName, String primaryKey, String oldData, String newData, String ipAddress) {
        NhatKyHoatDong log = new NhatKyHoatDong();
        log.setMaNv(maNv);
        log.setHanhDong(action.toUpperCase().trim());

        // Gắn cứng Mã khóa chính (không thể thay đổi) trực tiếp vào trường Tác động để phục vụ truy vết
        log.setBangTacDong(tableName.toUpperCase().trim() + " [" + primaryKey.trim() + "]");
        log.setDuLieuCu(oldData);
        log.setDuLieuMoi(newData);
        log.setIpAddress(ipAddress != null ? ipAddress : "127.0.0.1");

        return getInstance().addLog(log);
    }
}
