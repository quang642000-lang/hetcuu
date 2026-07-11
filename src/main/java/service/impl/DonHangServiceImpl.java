package service.impl;

import model.entity.*;
import repository.*;
import repository.impl.*;
import service.IDonHangService;
import java.sql.Timestamp;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DonHangServiceImpl implements IDonHangService {
    private static DonHangServiceImpl instance;
    private final IDonHangRepository donHangRepository;
    private final IKhuyenMaiRepository khuyenMaiRepository;
    private final IKhachHangRepository khachHangRepository;
    private final INhatKyRepository nhatKyRepository;

    private DonHangServiceImpl() {
        this.donHangRepository = DonHangRepoImpl.getInstance();
        this.khuyenMaiRepository = KhuyenMaiRepoImpl.getInstance();
        this.khachHangRepository = KhachHangRepoImpl.getInstance();
        this.nhatKyRepository = NhatKyRepoImpl.getInstance();
    }

    public static synchronized DonHangServiceImpl getInstance() {
        if (instance == null) {
            instance = new DonHangServiceImpl();
        }
        return instance;
    }

    @Override
    public List<DonHang> getAllDonHang() {
        return donHangRepository.getAll();
    }

    @Override
    public DonHang getDonHangById(String id) {
        DonHang dh = donHangRepository.getById(id);
        if (dh != null) {
            List<ChiTietDonHang> items = donHangRepository.getChiTietDonHang(id);
            for (ChiTietDonHang item : items) {
                item.setToppingsList(donHangRepository.getToppingsOfChiTiet(item.getMaCtdh()));
            }
            dh.setChiTietDonHangList(items);
        }
        return dh;
    }

    @Override
    public List<DonHang> getDonHangByKhachHang(String maKh) {
        return donHangRepository.getByKhachHang(maKh);
    }

    @Override
    public List<DonHang> getDonHangByTrangThai(int trangThaiDon) {
        return donHangRepository.getByTrangThai(trangThaiDon);
    }

    @Override
    public boolean checkoutPOS(DonHang donHang, List<ChiTietDonHang> items, String maNv) {
        donHang.setMaNv(maNv);
        donHang.setChiTietDonHangList(items);
        if (donHang.getMaKm() != null) {
            khuyenMaiRepository.giamSoLuongVoucher(donHang.getMaKm());
        }
        if (donHang.getMaKh() != null && donHang.getDiemSuDung() > 0) {
            khachHangRepository.truDiemTichLuy(donHang.getMaKh(), donHang.getDiemSuDung());
        }
        boolean success = donHangRepository.add(donHang);
        if (success) {
            donHangRepository.updateTrangThaiDon(donHang.getMaDh(), donHang.getTrangThaiDon());
            nhatKyRepository.addLog(new NhatKyHoatDong(
                    maNv, "CHỐT_ĐƠN_POS", "DON_HANG", null, "Mã hóa đơn vừa xuất: " + donHang.getMaDh(), "127.0.0.1", null));
        }
        return success;
    }

    @Override
    public boolean placeOrderOnline(DonHang donHang, List<ChiTietDonHang> items) {
        if (!validateThoiGianHenLay(donHang.getThoiGianHenLay())) {
            return false;
        }
        donHang.setChiTietDonHangList(items);
        donHang.setTrangThaiDon(0);
        if (donHang.getMaKm() != null) {
            khuyenMaiRepository.giamSoLuongVoucher(donHang.getMaKm());
        }
        if (donHang.getMaKh() != null && donHang.getDiemSuDung() > 0) {
            khachHangRepository.truDiemTichLuy(donHang.getMaKh(), donHang.getDiemSuDung());
        }
        return donHangRepository.add(donHang);
    }

    @Override
    public boolean updateTrangThaiDon(String maDh, int trangThaiDon, String maNv, String lyDoHuy) {
        DonHang dh = donHangRepository.getById(maDh);
        if (dh == null) return false;

        // CẬP NHẬT NHÂN VIÊN NHẬN ĐƠN TRÁNH GHI HỆ THỐNG TỰ ĐỘNG
        dh.setMaNv(maNv);

        if (trangThaiDon == 5) { // Trạng thái hủy đơn
            dh.setLyDoHuy(lyDoHuy);
            dh.setTrangThaiDon(5);
            donHangRepository.update(dh); // Lưu thông tin

            if (dh.getMaKh() != null && dh.getDiemSuDung() > 0) {
                khachHangRepository.congDiemTichLuy(dh.getMaKh(), dh.getDiemSuDung());
            }
            nhatKyRepository.addLog(new NhatKyHoatDong(maNv, "HỦY_ĐƠN", "DON_HANG", "Trạng thái cũ: " + dh.getTrangThaiDon(), "Lý do hủy đơn " + maDh + ": " + lyDoHuy, "127.0.0.1", null));
            return donHangRepository.updateTrangThaiDon(maDh, 5);
        }

        dh.setTrangThaiDon(trangThaiDon);
        donHangRepository.update(dh); // Lưu nhân viên xử lý đơn hàng

        nhatKyRepository.addLog(new NhatKyHoatDong(maNv, "CẬP_NHẬT_TRẠNG_THÁI_ĐƠN", "DON_HANG", "Trạng thái cũ: " + dh.getTrangThaiDon(), "Trạng thái mới: " + trangThaiDon, "127.0.0.1", null));
        return donHangRepository.updateTrangThaiDon(maDh, trangThaiDon);
    }

    @Override
    public boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan) {
        return donHangRepository.updateTrangThaiThanhToan(maDh, trangThaiThanhToan);
    }

    @Override
    public boolean handleSePayWebhook(String content, double amount) {
        Pattern pattern = Pattern.compile("TEA(\\d+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            String extractedMaDh = "TEA" + matcher.group(1);
            DonHang dh = donHangRepository.getById(extractedMaDh);
            if (dh != null && dh.getTrangThaiDon() == 0) {
                if (Math.abs(dh.getTongPhaiTra() - amount) < 100) {
                    donHangRepository.updateTrangThaiThanhToan(extractedMaDh, 1);
                    donHangRepository.updateTrangThaiDon(extractedMaDh, 2);
                    nhatKyRepository.addLog(new NhatKyHoatDong("SYSTEM", "KHỚP_ĐƠN_ONLINE_AUTO", "DON_HANG", null, "Khớp thành công đơn " + extractedMaDh + " qua SePay Webhook số tiền: " + amount, "127.0.0.1", null));
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public boolean validateThoiGianHenLay(Timestamp thoiGianHenLay) {
        if (thoiGianHenLay == null) return false;
        long current = System.currentTimeMillis();
        long diffMinutes = (thoiGianHenLay.getTime() - current) / (60 * 1000);
        return diffMinutes >= 15;
    }
}
