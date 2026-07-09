package service.impl;

import model.entity.KhuyenMai;
import model.entity.KhachHang;
import repository.IKhuyenMaiRepository;
import repository.IKhachHangRepository;
import repository.impl.KhuyenMaiRepoImpl;
import repository.impl.KhachHangRepoImpl;
import service.IKhuyenMaiService;

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
            return false; // Code đã tồn tại
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

    @Override
    public List<KhuyenMai> getVouchersKhaDungForKhachHang(int tongDonHang, String maKh) {
        List<KhuyenMai> dbVouchers = khuyenMaiRepository.getVouchersKhaDung(tongDonHang, maKh);
        List<KhuyenMai> validVouchers = new ArrayList<>();

        for (KhuyenMai km : dbVouchers) {
            if (validateVoucher(km.getMaCode(), tongDonHang, maKh)) {
                validVouchers.add(km);
            }
        }
        return validVouchers;
    }

    @Override
    public boolean validateVoucher(String code, int tongDonHang, String maKh) {
        KhuyenMai km = khuyenMaiRepository.getByCode(code);
        if (km == null || !km.isTrangThai() || km.getSoLuong() <= 0) {
            return false; // Không tồn tại, đã tắt hoặc hết số lượng
        }

        Date now = new Date();
        if (now.before(km.getNgayBatDau()) || now.after(km.getNgayKetThuc())) {
            return false; // Ngoài khoảng thời gian hiệu lực
        }

        if (tongDonHang < km.getDonToiThieu()) {
            return false; // Không đạt giá trị đơn tối thiểu
        }

        // Kiểm tra thứ hạng nếu Voucher chỉ áp dụng cho nhóm riêng tư (is_public = false)
        if (!km.isPublic() && maKh != null) {
            KhachHang kh = khachHangRepository.getById(maKh);
            if (kh == null) return false;

            // Quy tắc: Hạng Vàng (ma_hang = 3) hoặc Hạng Kim cương (ma_hang = 4) mới áp dụng được voucher VIP
            if (km.getTenKm().contains("VIP") && kh.getMaHang() < 3) {
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
        if (km.getLoaiGiam() == 1) { // 1: TRU_TIEN
            discount = km.getGiaTriGiam();
        } else if (km.getLoaiGiam() == 2) { // 2: TRU_PHAN_TRAM
            discount = (tongDonHang * km.getGiaTriGiam()) / 100;
            if (km.getGiamToiDa() > 0 && discount > km.getGiamToiDa()) {
                discount = km.getGiamToiDa(); // Chặn giới hạn giảm tối đa
            }
        }

        if (discount > tongDonHang) {
            discount = tongDonHang; // Không giảm vượt quá giá trị đơn hàng
        }
        return discount;
    }
}
