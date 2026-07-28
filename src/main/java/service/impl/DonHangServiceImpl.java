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
        // 1. Giảm số lượng Voucher khả dụng kèm đối soát tính hợp lệ
        if (donHang.getMaKm() != null) {
            boolean voucherDecremented = khuyenMaiRepository.giamSoLuongVoucher(donHang.getMaKm());
            if (!voucherDecremented) {
                System.err.println("⚠️ [SECURITY WARNING] Áp dụng Voucher thất bại do hết lượt sử dụng!");
                return false;
            }
        }
        // 2. Khấu trừ điểm CRM của khách hàng nếu áp dụng tiêu điểm
        if (donHang.getMaKh() != null && donHang.getDiemSuDung() > 0) {
            khachHangRepository.truDiemTichLuy(donHang.getMaKh(), donHang.getDiemSuDung());
        }
        boolean success = donHangRepository.add(donHang);
        if (success) {
            donHangRepository.updateTrangThaiDon(donHang.getMaDh(), donHang.getTrangThaiDon());
            // 3. TỰ ĐỘNG TÍCH LŨY ĐIỂM CRM CHO KHÁCH HÀNG THÀNH VIÊN (1 Điểm = 10.000 VNĐ chi tiêu thực tế)
            if (donHang.getMaKh() != null) {
                int diemCong = donHang.getTongPhaiTra() / 10000;
                if (diemCong > 0) {
                    khachHangRepository.congDiemTichLuy(donHang.getMaKh(), diemCong);
                }
            }
            // ĐÃ LOẠI BỎ HÀM GHI NHẬT KÝ ĐƠN HÀNG DƯ THỪA THEO YÊU CẦU CỦA KHÁCH HÀNG CRM
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

        // CHỐT CHẶN BẢO MẬT & ĐỒNG BỘ CƠ SỞ DỮ LIỆU:
        // Tránh gán "SYSTEM" hoặc "CUSTOMER" trực tiếp vào cột ma_nv của bảng DON_HANG
        // vì ma_nv là Khóa Ngoại (Foreign Key) chỉ liên kết tới bảng NHAN_VIEN. Gán sai giá trị sẽ ném ngoại lệ SQLServerException.
        if (maNv != null && !maNv.trim().isEmpty() && !maNv.equalsIgnoreCase("SYSTEM") && !maNv.equalsIgnoreCase("CUSTOMER")) {
            dh.setMaNv(maNv.trim());
        }

        if (trangThaiMoi == 5) {
            dh.setLyDoHuy(lyDoHuy);
            dh.setTrangThaiDon(5);
            donHangRepository.update(dh);
            // Hủy đơn -> Hoàn trả lại điểm tích lũy cũ đã dùng nếu có
            if (dh.getMaKh() != null && dh.getDiemSuDung() > 0) {
                khachHangRepository.congDiemTichLuy(dh.getMaKh(), dh.getDiemSuDung());
            }
            // Thu hồi lại số điểm CRM tích lũy đã cộng của đơn này
            if (dh.getMaKh() != null) {
                int diemCongDaNhan = dh.getTongPhaiTra() / 10000;
                if (diemCongDaNhan > 0) {
                    khachHangRepository.truDiemTichLuy(dh.getMaKh(), diemCongDaNhan);
                }
            }
            // Hoàn lại số lượng voucher đã áp dụng
            if (dh.getMaKm() != null) {
                khuyenMaiRepository.congSoLuongVoucher(dh.getMaKm());
            }
            // ĐÃ LOẠI BỎ HÀM GHI NHẬT KÝ ĐƠN HÀNG DƯ THỪA THEO YÊU CẦU CỦA KHÁCH HÀNG CRM
            return donHangRepository.updateTrangThaiDon(maDh, 5);
        }

        dh.setTrangThaiDon(trangThaiMoi);
        donHangRepository.update(dh);

        // TỰ ĐỘNG TÍCH ĐIỂM CRM CHO KHÁCH HÀNG KHI ĐƠN HÀNG ONLINE CLICK & COLLECT HOÀN THÀNH (4)
        if (trangThaiMoi == 4) {
            if (dh.getMaKh() != null) {
                int diemCong = dh.getTongPhaiTra() / 10000;
                if (diemCong > 0) {
                    khachHangRepository.congDiemTichLuy(dh.getMaKh(), diemCong);
                }
            }
        }
        // ĐÃ LOẠI BỎ HÀM GHI NHẬT KÝ ĐƠN HÀNG DƯ THỪA THEO YÊU CẦU CỦA KHÁCH HÀNG CRM
        return donHangRepository.updateTrangThaiDon(maDh, trangThaiMoi);
    }

    @Override
    public boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan) {
        return donHangRepository.updateTrangThaiThanhToan(maDh, trangThaiThanhToan);
    }

    @Override
    public boolean handleSePayWebhook(String content, double amount) {
        String cleanContent = content.replaceAll("[\\s\\-]+", "").toUpperCase();
        Pattern pattern = Pattern.compile("TEA(\\d{8})(\\d{6})", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(cleanContent);
        if (matcher.find()) {
            String extractedMaDh = "TEA-" + matcher.group(1) + "-" + matcher.group(2);
            DonHang dh = donHangRepository.getById(extractedMaDh);
            if (dh != null && dh.getTrangThaiDon() == 0) {
                if (Math.abs(dh.getTongPhaiTra() - amount) < 100) {
                    donHangRepository.updateTrangThaiThanhToan(extractedMaDh, 1);
                    updateTrangThaiDon(extractedMaDh, 2, "SYSTEM", "Khớp thành công đơn SePay Webhook.");
                    util.PaymentStore.transactions.put(extractedMaDh, true);
                    util.PaymentStore.transactions.put(extractedMaDh.replace("-", ""), true);
                    // ĐÃ LOẠI BỎ HÀM GHI NHẬT KÝ ĐƠN HÀNG DƯ THỪA THEO YÊU CẦU CỦA KHÁCH HÀNG CRM
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
