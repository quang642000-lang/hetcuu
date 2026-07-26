package service.impl;

import model.entity.KhuyenMai;
import model.entity.KhachHang;
import repository.IKhuyenMaiRepository;
import repository.IKhachHangRepository;
import repository.impl.KhuyenMaiRepoImpl;
import repository.impl.KhachHangRepoImpl;
import service.IKhuyenMaiService;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;
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
        return khuyenMaiRepository.getByCode(code);
    }

    @Override
    public boolean createKhuyenMai(KhuyenMai khuyenMai) {
        if (khuyenMaiRepository.getByCode(khuyenMai.getMaCode()) != null) {
            return false;
        }
        return khuyenMaiRepository.add(khuyenMai);
    }

    @Override
    public boolean updateKhuyenMai(KhuyenMai khuyenMai) {
        return khuyenMaiRepository.update(khuyenMai);
    }

    @Override
    public boolean deleteKhuyenMai(String id) {
        return khuyenMaiRepository.delete(id);
    }

    private int getVoucherTotalUsages(String maKm) {
        int usages = 0;
        String sql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_km = ? AND trang_thai_don != 5";
        try (Connection conn = config.DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKm);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) usages = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return usages;
    }

    @Override
    public List<KhuyenMai> getVouchersKhaDungForKhachHang(int tongDonHang, String maKh) {
        List<KhuyenMai> dbVouchers = khuyenMaiRepository.getVouchersKhaDung(tongDonHang, maKh);
        List<KhuyenMai> validVouchers = new ArrayList<>();
        for (KhuyenMai km : dbVouchers) {
            if (km.getLoaiVoucher() == 2) {
                continue;
            }
            if (validateVoucher(km.getMaCode(), tongDonHang, maKh)) {
                int userUsages = 0;
                if (maKh != null) {
                    String sql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_kh = ? AND ma_km = ? AND trang_thai_don != 5";
                    try (Connection conn = config.DBConnect.getConnection();
                         PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, maKh);
                        ps.setString(2, km.getMaKm());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) userUsages = rs.getInt(1);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                km.setSoLuotDaDungCaNhan(userUsages);
                validVouchers.add(km);
            }
        }
        return validVouchers;
    }

    @Override
    public boolean validateVoucher(String code, int tongDonHang, String maKh) {
        KhuyenMai km = khuyenMaiRepository.getByCode(code);
        if (km == null || !km.isTrangThai()) {
            return false;
        }
        Date now = new Date();
        if (now.before(km.getNgayBatDau()) || now.after(km.getNgayKetThuc())) {
            return false;
        }
        if (tongDonHang < km.getDonToiThieu()) {
            return false;
        }

        int totalUsages = getVoucherTotalUsages(km.getMaKm());
        if (totalUsages >= km.getSoLuong()) {
            return false;
        }

        if (km.getLoaiVoucher() == 2) {
            return true;
        }

        if (maKh == null) {
            return false;
        }

        KhachHang kh = khachHangRepository.getById(maKh);
        if (kh == null || !kh.isTrangThai()) {
            return false;
        }

        if (kh.getMaHang() < km.getHangApDung()) {
            return false;
        }

        if (km.getSoLuotDungCaNhan() > 0) {
            int userUsages = 0;
            String sql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_kh = ? AND ma_km = ? AND trang_thai_don != 5";
            try (Connection conn = config.DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, maKh);
                ps.setString(2, km.getMaKm());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userUsages = rs.getInt(1);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (userUsages >= km.getSoLuotDungCaNhan()) {
                return false;
            }
        }
        return true;
    }

    @Override
    public int calculateDiscount(String code, int tongDonHang) {
        KhuyenMai km = khuyenMaiRepository.getByCode(code);
        if (km == null) return 0;
        int discount = 0;
        if (km.getLoaiGiam() == 1) {
            discount = km.getGiaTriGiam();
        } else if (km.getLoaiGiam() == 2) {
            discount = (tongDonHang * km.getGiaTriGiam()) / 100;
            if (km.getGiamToiDa() > 0 && discount > km.getGiamToiDa()) {
                discount = km.getGiamToiDa();
            }
        }
        if (discount > tongDonHang) {
            discount = tongDonHang;
        }
        return discount;
    }
}
