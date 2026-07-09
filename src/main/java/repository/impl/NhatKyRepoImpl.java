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
            ps.setString(1, log.getMaNv());
            ps.setString(2, log.getHanhDong());
            ps.setString(3, log.getBangTacDong());
            ps.setString(4, log.getDuLieuCu());
            ps.setString(5, log.getDuLieuMoi());
            ps.setString(6, log.getIpAddress());
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
                list.add(new NhatKyHoatDong(
                        rs.getLong("ma_log"),
                        rs.getString("ma_nv"),
                        rs.getString("hanh_dong"),
                        rs.getString("bang_tac_dong"),
                        rs.getString("du_lieu_cu"),
                        rs.getString("du_lieu_moi"),
                        rs.getString("ip_address"),
                        rs.getTimestamp("thoi_gian")
                ));
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
                    list.add(new NhatKyHoatDong(
                            rs.getLong("ma_log"),
                            rs.getString("ma_nv"),
                            rs.getString("hanh_dong"),
                            rs.getString("bang_tac_dong"),
                            rs.getString("du_lieu_cu"),
                            rs.getString("du_lieu_moi"),
                            rs.getString("ip_address"),
                            rs.getTimestamp("thoi_gian")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}