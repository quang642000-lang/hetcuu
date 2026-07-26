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

    private void setStringOrNull(PreparedStatement ps, int index, String val) throws SQLException {
        if (val == null || val.trim().isEmpty() || val.equalsIgnoreCase("null")) {
            ps.setNull(index, Types.VARCHAR);
        } else {
            ps.setString(index, val);
        }
    }

    @Override
    public boolean addLog(NhatKyHoatDong log) {
        String sql = "INSERT INTO NHAT_KY_HOAT_DONG (ma_nv, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi, ip_address, thoi_gian) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setStringOrNull(ps, 1, log.getMaNv()); // THÀNH CÔNG KHẮC PHỤC LỖI KHÓA NGOẠI MA_NV KHI ĐẶT ONLINE!
            ps.setString(2, log.getHanhDong());
            ps.setString(3, log.getBangTacDong());
            ps.setString(4, log.getDuLieuCu());
            ps.setString(5, log.getDuLieuMoi());
            ps.setString(6, log.getIpAddress());
            ps.setTimestamp(7, log.getThoiGian() != null ? log.getThoiGian() : new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<NhatKyHoatDong> getAllLogs() {
        List<NhatKyHoatDong> list = new ArrayList<>();
        String sql = "SELECT * FROM NHAT_KY_HOAT_DONG ORDER BY thoi_gian DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToNhatKy(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<NhatKyHoatDong> getLogsByNhanVien(String maNv) {
        List<NhatKyHoatDong> list = new ArrayList<>();
        String sql = "SELECT * FROM NHAT_KY_HOAT_DONG WHERE ma_nv = ? ORDER BY thoi_gian DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNv);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToNhatKy(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private NhatKyHoatDong mapResultSetToNhatKy(ResultSet rs) throws SQLException {
        NhatKyHoatDong nk = new NhatKyHoatDong();
        nk.setMaLog(rs.getLong("ma_log"));
        nk.setMaNv(rs.getString("ma_nv"));
        nk.setHanhDong(rs.getString("hanh_dong"));
        nk.setBangTacDong(rs.getString("bang_tac_dong"));
        nk.setDuLieuCu(rs.getString("du_lieu_cu"));
        nk.setDuLieuMoi(rs.getString("du_lieu_moi"));
        nk.setIpAddress(rs.getString("ip_address"));
        nk.setThoiGian(rs.getTimestamp("thoi_gian"));
        return nk;
    }
}
