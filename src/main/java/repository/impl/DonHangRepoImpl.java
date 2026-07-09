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

    @Override
    public List<DonHang> getAll() {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, tong_tien_hang, " +
                "tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, ly_do_huy, " +
                "trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao, thoi_gian_hoan_thanh FROM DON_HANG ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDonHang(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public DonHang getById(String id) {
        String sql = "SELECT ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, tong_tien_hang, " +
                "tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, ly_do_huy, " +
                "trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao, thoi_gian_hoan_thanh FROM DON_HANG WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToDonHang(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(DonHang entity) {
        Connection conn = null;
        PreparedStatement psDh = null;
        PreparedStatement psCtdh = null;
        PreparedStatement psCttp = null;

        String sqlDh = "INSERT INTO DON_HANG (ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, " +
                "tong_tien_hang, tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, ly_do_huy, " +
                "trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        String sqlCtdh = "INSERT INTO CHI_TIET_DON_HANG (ma_dh, ma_sp, ma_size, so_luong, gia_chot, muc_da, muc_duong, ghi_chu_mon) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlCttp = "INSERT INTO CHI_TIET_TOPPING (ma_ctdh, ma_tp, so_luong, gia_chot_tp) VALUES (?, ?, ?, ?)";

        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            psDh = conn.prepareStatement(sqlDh);
            psDh.setString(1, entity.getMaDh());
            psDh.setString(2, entity.getMaKh());
            psDh.setString(3, entity.getMaNv());
            psDh.setInt(4, entity.getMaPt());
            psDh.setString(5, entity.getMaKm());
            psDh.setInt(6, entity.getLoaiDonHang());
            psDh.setTimestamp(7, entity.getThoiGianHenLay());
            psDh.setInt(8, entity.getTongTienHang());
            psDh.setInt(9, entity.getTienGiamGia());
            psDh.setInt(10, entity.getDiemSuDung());
            psDh.setInt(11, entity.getTienTruDiem());
            psDh.setInt(12, entity.getTongPhaiTra());
            psDh.setString(13, entity.getGhiChuDon());
            psDh.setString(14, entity.getLyDoHuy());
            psDh.setInt(15, entity.getTrangThaiThanhToan());
            psDh.setInt(16, entity.getTrangThaiDon());
            psDh.executeUpdate();

            psCtdh = conn.prepareStatement(sqlCtdh, Statement.RETURN_GENERATED_KEYS);
            psCttp = conn.prepareStatement(sqlCttp);

            for (ChiTietDonHang detail : entity.getChiTietDonHangList()) {
                psCtdh.setString(1, entity.getMaDh());
                psCtdh.setString(2, detail.getMaSp());
                psCtdh.setInt(3, detail.getMaSize());
                psCtdh.setInt(4, detail.getSoLuong());
                psCtdh.setInt(5, detail.getGiaChot());
                psCtdh.setString(6, detail.getMucDa());
                psCtdh.setString(7, detail.getMucDuong());
                psCtdh.setString(8, detail.getGhiChuMon());
                psCtdh.executeUpdate();

                long generatedCtdhId = -1;
                try (ResultSet rsKeys = psCtdh.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        generatedCtdhId = rsKeys.getLong(1);
                    }
                }

                if (generatedCtdhId != -1) {
                    for (ChiTietTopping topping : detail.getToppingsList()) {
                        psCttp.setLong(1, generatedCtdhId);
                        psCttp.setInt(2, topping.getMaTp());
                        psCttp.setInt(3, topping.getSoLuong());
                        psCttp.setInt(4, topping.getGiaChotTp());
                        psCttp.addBatch();
                    }
                    psCttp.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (psDh != null) psDh.close();
                if (psCtdh != null) psCtdh.close();
                if (psCttp != null) psCttp.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public boolean update(DonHang entity) {
        String sql = "UPDATE DON_HANG SET ma_kh = ?, ma_nv = ?, ma_pt = ?, ma_km = ?, loai_don_hang = ?, thoi_gian_hen_lay = ?, " +
                "tong_tien_hang = ?, tien_giam_gia = ?, diem_su_dung = ?, tien_tru_diem = ?, tong_phai_tra = ?, " +
                "ghi_chu_don = ?, ly_do_huy = ?, trang_thai_thanh_toan = ?, trang_thai_don = ? WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity.getMaKh());
            ps.setString(2, entity.getMaNv());
            ps.setInt(3, entity.getMaPt());
            ps.setString(4, entity.getMaKm());
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
            ps.setString(16, entity.getMaDh());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(String id) {
        return updateTrangThaiDon(id, 5);
    }

    @Override
    public List<DonHang> getByKhachHang(String maKh) {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, tong_tien_hang, " +
                "tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, ly_do_huy, " +
                "trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao, thoi_gian_hoan_thanh FROM DON_HANG WHERE ma_kh = ? ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDonHang(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<DonHang> getByTrangThai(int trangThaiDon) {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT ma_dh, ma_kh, ma_nv, ma_pt, ma_km, loai_don_hang, thoi_gian_hen_lay, tong_tien_hang, " +
                "tien_giam_gia, diem_su_dung, tien_tru_diem, tong_phai_tra, ghi_chu_don, ly_do_huy, " +
                "trang_thai_thanh_toan, trang_thai_don, thoi_gian_tao, thoi_gian_hoan_thanh FROM DON_HANG WHERE trang_thai_don = ? ORDER BY thoi_gian_tao DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, trangThaiDon);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToDonHang(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateTrangThaiDon(String maDh, int trangThaiDon) {
        String sql = "{call sp_ThanhToanDonHang(?, ?, ?)}";
        try (Connection conn = DBConnect.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maDh);
            int currentPaymentStatus = 0;
            DonHang current = getById(maDh);
            if (current != null) {
                currentPaymentStatus = current.getTrangThaiThanhToan();
                if (trangThaiDon == 4) {
                    currentPaymentStatus = 1;
                }
            }
            cs.setInt(2, currentPaymentStatus);
            cs.setInt(3, trangThaiDon);
            cs.execute();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan) {
        String sql = "UPDATE DON_HANG SET trang_thai_thanh_toan = ? WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, trangThaiThanhToan);
            ps.setString(2, maDh);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<ChiTietDonHang> getChiTietDonHang(String maDh) {
        List<ChiTietDonHang> list = new ArrayList<>();
        String sql = "SELECT ma_ctdh, ma_dh, ma_sp, ma_size, so_luong, gia_chot, muc_da, muc_duong, ghi_chu_mon FROM CHI_TIET_DON_HANG WHERE ma_dh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maDh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ChiTietDonHang(
                            rs.getLong("ma_ctdh"),
                            rs.getString("ma_dh"),
                            rs.getString("ma_sp"),
                            rs.getInt("ma_size"),
                            rs.getInt("so_luong"),
                            rs.getInt("gia_chot"),
                            rs.getString("muc_da"),
                            rs.getString("muc_duong"),
                            rs.getString("ghi_chu_mon")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<ChiTietTopping> getToppingsOfChiTiet(long maCtdh) {
        List<ChiTietTopping> list = new ArrayList<>();
        String sql = "SELECT ma_ctdh, ma_tp, so_luong, gia_chot_tp FROM CHI_TIET_TOPPING WHERE ma_ctdh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, maCtdh);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ChiTietTopping(
                            rs.getLong("ma_ctdh"),
                            rs.getInt("ma_tp"),
                            rs.getInt("so_luong"),
                            rs.getInt("gia_chot_tp")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private DonHang mapResultSetToDonHang(ResultSet rs) throws SQLException {
        return new DonHang(
                rs.getString("ma_dh"),
                rs.getString("ma_kh"),
                rs.getString("ma_nv"),
                rs.getInt("ma_pt"),
                rs.getString("ma_km"),
                rs.getInt("loai_don_hang"),
                rs.getTimestamp("thoi_gian_hen_lay"),
                rs.getInt("tong_tien_hang"),
                rs.getInt("tien_giam_gia"),
                rs.getInt("diem_su_dung"),
                rs.getInt("tien_tru_diem"),
                rs.getInt("tong_phai_tra"),
                rs.getString("ghi_chu_don"),
                rs.getString("ly_do_huy"),
                rs.getInt("trang_thai_thanh_toan"),
                rs.getInt("trang_thai_don"),
                rs.getTimestamp("thoi_gian_tao"),
                rs.getTimestamp("thoi_gian_hoan_thanh")
        );
    }
}
