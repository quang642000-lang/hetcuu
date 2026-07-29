package service.impl;

import model.entity.DonHang;
import model.entity.ChiTietDonHang;
import model.entity.ChiTietTopping;
import repository.IDonHangRepository;
import repository.IKhuyenMaiRepository;
import repository.IKhachHangRepository;
import repository.impl.DonHangRepoImpl;
import repository.impl.KhuyenMaiRepoImpl;
import repository.impl.KhachHangRepoImpl;
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

    private DonHangServiceImpl() {
        this.donHangRepository = DonHangRepoImpl.getInstance();
        this.khuyenMaiRepository = KhuyenMaiRepoImpl.getInstance();
        this.khachHangRepository = KhachHangRepoImpl.getInstance();
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
            boolean voucherDecremented = khuyenMaiRepository.giamSoLuongVoucher(donHang.getMaKm());
            if (!voucherDecremented) {
                System.err.println("⚠️ [SECURITY WARNING] Áp dụng Voucher thất bại do hết lượt sử dụng!");
                return false;
            }
        }

        if (donHang.getMaKh() != null && donHang.getDiemSuDung() > 0) {
            khachHangRepository.truDiemTichLuy(donHang.getMaKh(), donHang.getDiemSuDung());
        }

        boolean success = donHangRepository.add(donHang);
        if (success) {
            donHangRepository.updateTrangThaiDon(donHang.getMaDh(), donHang.getTrangThaiDon());
            if (donHang.getMaKh() != null) {
                int diemCong = donHang.getTongPhaiTra() / 10000;
                if (diemCong > 0) {
                    khachHangRepository.congDiemTichLuy(donHang.getMaKh(), diemCong);
                }
            }
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
            boolean voucherDecremented = khuyenMaiRepository.giamSoLuongVoucher(donHang.getMaKm());
            if (!voucherDecremented) {
                System.err.println("⚠️ [SECURITY WARNING] Áp dụng Voucher Online thất bại do hết lượt!");
                return false;
            }
        }

        if (donHang.getMaKh() != null && donHang.getDiemSuDung() > 0) {
            khachHangRepository.truDiemTichLuy(donHang.getMaKh(), donHang.getDiemSuDung());
        }

        return donHangRepository.add(donHang);
    }

    @Override
    public boolean updateTrangThaiDon(String maDh, int trangThaiMoi, String maNv, String lyDoHuy) {
        DonHang dh = donHangRepository.getById(maDh);
        if (dh == null) return false;

        if (maNv != null && !maNv.trim().isEmpty() && !maNv.equalsIgnoreCase("SYSTEM") && !maNv.equalsIgnoreCase("CUSTOMER")) {
            dh.setMaNv(maNv.trim());
        }

        if (trangThaiMoi == 5) {
            dh.setLyDoHuy(lyDoHuy);
            dh.setTrangThaiDon(5);
            donHangRepository.update(dh);

            if (dh.getMaKh() != null && dh.getDiemSuDung() > 0) {
                khachHangRepository.congDiemTichLuy(dh.getMaKh(), dh.getDiemSuDung());
            }

            if (dh.getMaKh() != null) {
                int diemCongDaNhan = dh.getTongPhaiTra() / 10000;
                if (diemCongDaNhan > 0) {
                    khachHangRepository.truDiemTichLuy(dh.getMaKh(), diemCongDaNhan);
                }
            }

            if (dh.getMaKm() != null) {
                khuyenMaiRepository.congSoLuongVoucher(dh.getMaKm());
            }

            return donHangRepository.updateTrangThaiDon(maDh, 5);
        }

        dh.setTrangThaiDon(trangThaiMoi);
        donHangRepository.update(dh);

        if (trangThaiMoi == 4) {
            if (dh.getMaKh() != null) {
                int diemCong = dh.getTongPhaiTra() / 10000;
                if (diemCong > 0) {
                    khachHangRepository.congDiemTichLuy(dh.getMaKh(), diemCong);
                }
            }
        }

        return donHangRepository.updateTrangThaiDon(maDh, trangThaiMoi);
    }

    @Override
    public boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan) {
        return donHangRepository.updateTrangThaiThanhToan(maDh, trangThaiThanhToan);
    }

    @Override
    public boolean handleSePayWebhook(String content, double amount) {
        String cleanContent = content.replaceAll("[\\s\\-]+", "").toUpperCase();

        // VÁ LỖI CHÍ MẠNG TOÀN DIỆN: Hỗ trợ linh hoạt cả mã đơn 5 số (e.g. TEA2026072900003) và 6 số (e.g. TEA20260729000003)
        Pattern pattern = Pattern.compile("TEA(\\d{8})(\\d{5,6})", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(cleanContent);

        if (matcher.find()) {
            String datePart = matcher.group(1);
            String serialPart = matcher.group(2);

            // Đồng dạng mã: Nếu mã chuyển khoản có 6 số (000003), quy đổi về 5 số (00003) để khớp khóa chính DB
            if (serialPart.length() == 6) {
                try {
                    int val = Integer.parseInt(serialPart);
                    serialPart = String.format("%05d", val);
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu có lỗi định dạng thô
                }
            }

            String extractedMaDh = "TEA-" + datePart + "-" + serialPart;
            DonHang dh = donHangRepository.getById(extractedMaDh);

            if (dh != null && (dh.getTrangThaiDon() == 0 || dh.getTrangThaiDon() == 1)) {
                // Cho phép sai số nhỏ dưới 100đ khi đối soát khớp tiền
                if (Math.abs(dh.getTongPhaiTra() - amount) < 100) {
                    donHangRepository.updateTrangThaiThanhToan(extractedMaDh, 1);
                    updateTrangThaiDon(extractedMaDh, 2, "SYSTEM", "Khớp thành công đơn SePay Webhook.");
                    util.PaymentStore.transactions.put(extractedMaDh, true);
                    util.PaymentStore.transactions.put(extractedMaDh.replace("-", ""), true);
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
        return diffMinutes >= 13;
    }

    @Override
    public String generateNextMaDh() {
        return donHangRepository.generateNextMaDh();
    }
}
