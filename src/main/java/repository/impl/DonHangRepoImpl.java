package repository.impl;

import config.DBConnect;
import model.entity.DonHang;
import model.entity.ChiTietDonHang;
import model.entity.ChiTietTopping;
import repository.IDonHangRepository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DonHangRepoImpl implements IDonHangRepository {
    private static DonHangRepoImpl instance;

    private DonHangRepoImpl() {}

    public static synchronized DonHangRepoImpl getInstance() {
        if (instance == null) {
            instance = new DonHangRepoImpl();
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
    public List<DonHang> getAll() {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT * FROM DON_HANG ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDonHang(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public DonHang getById(String id) {
        String sql = "SELECT * FROM DON_HANG WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDonHang(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(DonHang entity) {
        String sql = "INSERT INTO DON_HANG (ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, " +
                "tong_tien_hang, tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, " +
                "ly_do_huy, trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getMaDh());
            setStringOrNull(ps, 2, entity.getMaKh());
            setStringOrNull(ps, 3, entity.getMaNv());
            ps.setInt(4, entity.getMaPt());
            setStringOrNull(ps, 5, entity.getMaKm());
            ps.setInt(6, entity.getLoaiDonHang());
            ps.setTimestamp(7, entity.getThoiGianHenLay());
            ps.setInt(8, entity.getTongTienHang());
            ps.setInt(9, entity.getTienGiamGia());
            ps.setInt(10, entity.getDiemSuDung());
            ps.setInt(11, entity.getTienTruDiem());
            ps.setInt(12, entity.getTongPhaiTra());
            ps.setString(13, entity.getGhiChuDon());
            ps.setString(14, entity.getLyDoHuy());
            ps.setInt(15, entity.getTrangThaiThanhToan());
            ps.setInt(16, entity.getTrangThaiDon());
            ps.setTimestamp(17, entity.getThoiGianTao() != null ? entity.getThoiGianTao() : new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(DonHang entity) {
        String sql = "UPDATE DON_HANG SET ma_kh = ?, ma_nv = ?, ma_pt = ?, ma_km = ?, loai_don_hang = ?, " +
                "thoi_gian_hen_lay = ?, tong_tien_hang = ?, tien_giam_gia = ?, diem_su_dung = ?, " +
                "tien_tru_diem = ?, tong_phai_tra = ?, ghi_chu_don = ?, ly_do_huy = ?, " +
                "trang_thai_thanh_toan = ?, trang_thai_don = ?, thoi_gian_hoan_thanh = ? WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setStringOrNull(ps, 1, entity.getMaKh());
            setStringOrNull(ps, 2, entity.getMaNv()); // THÀNH CÔNG DẬP TẮT LỖI KHÓA NGOẠI MA_NV!
            ps.setInt(3, entity.getMaPt());
            setStringOrNull(ps, 4, entity.getMaKm());
            ps.setInt(5, entity.getLoaiDonHang());
            ps.setTimestamp(6, entity.getThoiGianHenLay());
            ps.setInt(7, entity.getTongTienHang());
            ps.setInt(8, entity.getTienGiamGia());
            ps.setInt(9, entity.getDiemSuDung());
            ps.setInt(10, entity.getTienTruDiem());
            ps.setInt(11, entity.getTongPhaiTra());
            ps.setString(12, entity.getGhiChuDon());
            ps.setString(13, entity.getLyDoHuy());
            ps.setInt(14, entity.getTrangThaiThanhToan());
            ps.setInt(15, entity.getTrangThaiDon());
            ps.setTimestamp(16, entity.getThoiGianHoanThanh());
            ps.setString(17, entity.getMaDh());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        String sql = "DELETE FROM DON_HANG WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<DonHang> getByKhachHang(String maKh) {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT * FROM DON_HANG WHERE ma_kh = ? ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDonHang(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<DonHang> getByTrangThai(int status) {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT * FROM DON_HANG WHERE trang_thai_don = ? ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDonHang(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateTrangThaiDon(String maDh, int status) {
        String sql = "UPDATE DON_HANG SET trang_thai_don = ?, thoi_gian_hoan_thanh = ? WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setTimestamp(2, status == 4 ? new Timestamp(System.currentTimeMillis()) : null);
            ps.setString(3, maDh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateTrangThaiThanhToan(String maDh, int status) {
        String sql = "UPDATE DON_HANG SET trang_thai_thanh_toan = ? WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setString(2, maDh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<ChiTietDonHang> getChiTietDonHang(String maDh) {
        List<ChiTietDonHang> list = new ArrayList<>();
        String sql = "SELECT ct.*, sp.ten_sp, sz.ten_size " +
                "FROM CHI_TIET_DON_HANG ct " +
                "JOIN SAN_PHAM sp ON ct.ma_sp = sp.ma_sp " +
                "JOIN KICH_CO sz ON ct.ma_size = sz.ma_size " +
                "WHERE ct.ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maDh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietDonHang ct = new ChiTietDonHang();
                    ct.setMaCtdh(rs.getLong("ma_ctdh"));
                    ct.setMaDh(rs.getString("ma_dh"));
                    ct.setMaSp(rs.getString("ma_sp"));
                    ct.setMaSize(rs.getInt("ma_size"));
                    ct.setSoLuong(rs.getInt("so_luong"));
                    ct.setGiaChot(rs.getInt("gia_chot"));
                    ct.setMucDa(rs.getString("muc_da"));
                    ct.setMucDuong(rs.getString("muc_duong"));
                    ct.setGhiChuMon(rs.getString("ghi_chu_mon"));
                    ct.setTenSp(rs.getString("ten_sp"));
                    ct.setTenSize(rs.getString("ten_size"));
                    list.add(ct);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<ChiTietTopping> getToppingsOfChiTiet(long maCtdh) {
        List<ChiTietTopping> list = new ArrayList<>();
        String sql = "SELECT ct.*, t.ten_tp " +
                "FROM CHI_TIET_TOPPING ct " +
                "JOIN TOPPING t ON ct.ma_tp = t.ma_tp " +
                "WHERE ct.ma_ctdh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtdh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietTopping ct = new ChiTietTopping();
                    ct.setMaCtdh(rs.getLong("ma_ctdh"));
                    ct.setMaTp(rs.getString("ma_tp"));
                    ct.setSoLuong(rs.getInt("so_luong"));
                    ct.setGiaChotTp(rs.getInt("gia_chot_tp"));
                    ct.setTenTopping(rs.getString("ten_tp"));
                    list.add(ct);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public String generateNextMaDh() {
        String sql = "SELECT NEXT VALUE FOR seq_DonHang";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                long val = rs.getLong(1);
                return "DH" + String.format("%05d", val);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "DH" + System.currentTimeMillis();
    }

    private DonHang mapResultSetToDonHang(ResultSet rs) throws SQLException {
        DonHang dh = new DonHang();
        dh.setMaDh(rs.getString("ma_dh"));
        dh.setMaKh(rs.getString("ma_kh"));
        dh.setMaNv(rs.getString("ma_nv"));
        dh.setMaPt(rs.getInt("ma_pt"));
        dh.setMaKm(rs.getString("ma_km"));
        dh.setLoaiDonHang(rs.getInt("loai_don_hang"));
        dh.setThoiGianHenLay(rs.getTimestamp("thoi_gian_hen_lay"));
        dh.setTongTienHang(rs.getInt("tong_tien_hang"));
        dh.setTienGiamGia(rs.getInt("tien_giam_gia"));
        dh.setDiemSuDung(rs.getInt("diem_su_dung"));
        dh.setTienTruDiem(rs.getInt("tien_tru_diem"));
        dh.setTongPhaiTra(rs.getInt("tong_phai_tra"));
        dh.setGhiChuDon(rs.getString("ghi_chu_don"));
        dh.setLyDoHuy(rs.getString("ly_do_huy"));
        dh.setTrangThaiThanhToan(rs.getInt("trang_thai_thanh_toan"));
        dh.setTrangThaiDon(rs.getInt("trang_thai_don"));
        dh.setThoiGianTao(rs.getTimestamp("thoi_gian_tao"));
        dh.setThoiGianHoanThanh(rs.getTimestamp("thoi_gian_hoan_thanh"));
        return dh;
    }
}
