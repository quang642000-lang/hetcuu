package service.impl;

import model.entity.KhuyenMai;
import model.entity.KhachHang;
import service.IKhuyenMaiService;
import repository.IKhuyenMaiRepository;
import repository.IKhachHangRepository;
import repository.impl.KhuyenMaiRepoImpl;
import repository.impl.KhachHangRepoImpl;
import config.DBConnect;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class KhuyenMaiServiceImpl implements IKhuyenMaiService {

    private static KhuyenMaiServiceImpl instance;
    private final IKhuyenMaiRepository khuyenMaiRepository;
    private final IKhachHangRepository khachHangRepository;

    private KhuyenMaiServiceImpl() {
        this.khuyenMaiRepository = KhuyenMaiRepoImpl.getInstance();
        this.khachHangRepository = KhachHangRepoImpl.getInstance();
    }

    public static synchronized KhuyenMaiServiceImpl getInstance() {
        if (instance == null) {
            instance = new KhuyenMaiServiceImpl();
        }
        return instance;
    }

    @Override
    public List<KhuyenMai> getAllKhuyenMai() {
        return khuyenMaiRepository.getAll();
    }

    @Override
    public KhuyenMai getKhuyenMaiById(String id) {
        return khuyenMaiRepository.getById(id);
    }

    @Override
    public KhuyenMai getKhuyenMaiByCode(String code) {
        if (code == null) return null;
        return khuyenMaiRepository.getByCode(code.trim().toUpperCase());
    }

    // Both implementations to avoid any interface signature mismatches
    public List<KhuyenMai> getVouchersKhaDungForKhachHang(int tongDonHang, String maKh) {
        return getVouchersKhaDung(tongDonHang, maKh);
    }

    public List<KhuyenMai> getVouchersKhaDung(int tongDonHang, String maKh) {
        List<KhuyenMai> allVouchers = khuyenMaiRepository.getVouchersKhaDung(tongDonHang, maKh);
        List<KhuyenMai> result = new ArrayList<>();

        if (maKh == null || maKh.trim().isEmpty() || maKh.equalsIgnoreCase("null")) {
            for (KhuyenMai km : allVouchers) {
                if (km.isPublic() && km.getLoaiVoucher() != 2) {
                    result.add(km);
                }
            }
            return result;
        }

        KhachHang kh = khachHangRepository.getById(maKh);
        if (kh == null) {
            return result;
        }

        int rankKh = kh.getMaHang();

        for (KhuyenMai km : allVouchers) {
            if (km.getLoaiVoucher() == 2) {
                continue;
            }

            if (rankKh < km.getHangApDung()) {
                continue;
            }

            if (km.getSoLuotDungCaNhan() > 0) {
                int usages = getSoLuotDaDung(maKh, km.getMaKm());
                if (usages >= km.getSoLuotDungCaNhan()) {
                    continue;
                }
            }

            result.add(km);
        }
        return result;
    }

    @Override
    public boolean validateVoucher(String code, int tongDonHang, String maKh) {
        if (code == null || code.trim().isEmpty()) {
            return false;
        }

        KhuyenMai km = khuyenMaiRepository.getByCode(code.trim().toUpperCase());
        if (km == null || !km.isTrangThai()) {
            return false;
        }

        java.util.Date now = new java.util.Date();
        if (now.before(km.getNgayBatDau()) || now.after(km.getNgayKetThuc())) {
            return false;
        }

        if (tongDonHang < km.getDonToiThieu()) {
            return false;
        }

        if (km.getSoLuong() <= 0) {
            return false;
        }

        if (km.getLoaiVoucher() == 2) {
            return true;
        }

        if (maKh == null || maKh.trim().isEmpty() || maKh.equalsIgnoreCase("null")) {
            if (!km.isPublic()) {
                return false;
            }
            if (km.getSoLuotDungCaNhan() > 0) {
                return false;
            }
            return true;
        }

        KhachHang kh = khachHangRepository.getById(maKh);
        if (kh == null) {
            return false;
        }

        if (kh.getMaHang() < km.getHangApDung()) {
            return false;
        }

        if (km.getSoLuotDungCaNhan() > 0) {
            int usages = getSoLuotDaDung(maKh, km.getMaKm());
            if (usages >= km.getSoLuotDungCaNhan()) {
                return false;
            }
        }

        return true;
    }

    @Override
    public int calculateDiscount(String code, int tongDonHang) {
        if (code == null || code.trim().isEmpty()) {
            return 0;
        }

        KhuyenMai km = khuyenMaiRepository.getByCode(code.trim().toUpperCase());
        if (km == null || !km.isTrangThai()) {
            return 0;
        }

        if (tongDonHang < km.getDonToiThieu()) {
            return 0;
        }

        int discount = 0;
        if (km.getLoaiGiam() == 1) {
            discount = km.getGiaTriGiam();
        } else if (km.getLoaiGiam() == 2) {
            discount = (int) (tongDonHang * (km.getGiaTriGiam() / 100.0));
            if (km.getGiamToiDa() > 0 && discount > km.getGiamToiDa()) {
                discount = km.getGiamToiDa();
            }
        }

        if (discount > tongDonHang) {
            discount = tongDonHang;
        }

        return discount;
    }

    public int getSoLuotDaDung(String maKh, String maKm) {
        if (maKh == null || maKh.trim().isEmpty() || maKh.equalsIgnoreCase("null") ||
                maKm == null || maKm.trim().isEmpty()) {
            return 0;
        }

        String sql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_kh = ? AND ma_km = ? AND trang_thai_don != 5";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            ps.setString(2, maKm);
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

    // Implementing the required CRUD methods defined in IKhuyenMaiService
    @Override
    public boolean createKhuyenMai(KhuyenMai km) {
        return khuyenMaiRepository.add(km);
    }

    @Override
    public boolean updateKhuyenMai(KhuyenMai km) {
        return khuyenMaiRepository.update(km);
    }

    @Override
    public boolean deleteKhuyenMai(String id) {
        return khuyenMaiRepository.delete(id);
    }
}
