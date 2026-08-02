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

/**
 * =========================================================================
 * TEA POS SYSTEM - ORDER SERVICE IMPLEMENTATION (OPTIMIZED WORKFLOW)
 * Fully synchronized with in-memory pending orders cache, ACID transactions,
 * and SePay Webhook dual-layered lookups.
 *
 * SỬA ĐỔI NGHIỆP VỤ: Khi khách chuyển khoản thành công qua SePay, đơn hàng
 * được cập nhật trạng thái đã thanh toán nhưng sẽ giữ ở trạng thái
 * "0 - Chờ xác nhận" (Chờ duyệt) thay vì nhảy thẳng sang "2 - Đang pha chế".
 * Điều này cho phép nhân viên quầy POS chủ động rà soát, kiểm kho nguyên liệu
 * và click "Duyệt đơn" thủ công trước khi Barista pha chế.
 * =========================================================================
 */
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
        // Hỗ trợ tìm kiếm đơn hàng tạm thời từ Cache nếu chưa có trong DB
        if (util.PaymentStore.pendingOrders != null && util.PaymentStore.pendingOrders.containsKey(id)) {
            return util.PaymentStore.pendingOrders.get(id);
        }
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
        // Nếu thanh toán chuyển khoản QR, lưu tạm thời vào Cache chờ khớp tiền, KHÔNG ghi nhận DB ngay
        if (donHang.getMaPt() == 2) {
            donHang.setTrangThaiThanhToan(0); // Chưa thanh toán
            donHang.setTrangThaiDon(0);       // Chờ duyệt
            // Đưa vào Cache in-memory
            util.PaymentStore.pendingOrders.put(donHang.getMaDh(), donHang);
            System.out.println("💾 [TEA POS] Đơn hàng QR tại quầy " + donHang.getMaDh() + " được lưu tạm thời vào Cache.");
            return true;
        }
        // Với Tiền mặt, ghi nhận DB trực tiếp
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
        donHang.setTrangThaiDon(0); // Chờ duyệt
        // Nếu thanh toán bằng QR trực tuyến, đưa vào Cache, không lưu DB rác
        if (donHang.getMaPt() == 2) {
            donHang.setTrangThaiThanhToan(0);
            util.PaymentStore.pendingOrders.put(donHang.getMaDh(), donHang);
            System.out.println("💾 [TEA PORTAL] Đơn hàng Online QR " + donHang.getMaDh() + " được lưu tạm thời vào Cache.");
            return true;
        }
        // Với Tiền mặt khi đến lấy, lưu trực tiếp
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
        // Hỗ trợ "Bỏ qua chuyển khoản" (Force Submit) cho đơn hàng QR nằm trong Cache
        if (util.PaymentStore.pendingOrders.containsKey(maDh) && (trangThaiMoi == 1 || trangThaiMoi == 2)) {
            DonHang cachedOrder = util.PaymentStore.pendingOrders.remove(maDh);
            cachedOrder.setTrangThaiThanhToan(1); // Ép trạng thái đã thanh toán
            cachedOrder.setTrangThaiDon(trangThaiMoi);
            if (maNv != null && !maNv.isEmpty()) {
                cachedOrder.setMaNv(maNv);
            }
            // Áp mã giảm giá và ví điểm CRM
            if (cachedOrder.getMaKm() != null) {
                khuyenMaiRepository.giamSoLuongVoucher(cachedOrder.getMaKm());
            }
            if (cachedOrder.getMaKh() != null && cachedOrder.getDiemSuDung() > 0) {
                khachHangRepository.truDiemTichLuy(cachedOrder.getMaKh(), cachedOrder.getDiemSuDung());
            }
            // Ghi nhận trực tiếp xuống database
            boolean success = donHangRepository.add(cachedOrder);
            if (success) {
                donHangRepository.updateTrangThaiDon(maDh, trangThaiMoi);
                if (cachedOrder.getMaKh() != null) {
                    int diemCong = cachedOrder.getTongPhaiTra() / 10000;
                    if (diemCong > 0) {
                        khachHangRepository.congDiemTichLuy(cachedOrder.getMaKh(), diemCong);
                    }
                }
                util.PaymentStore.transactions.put(maDh, true);
                util.PaymentStore.transactions.put(maDh.replace("-", ""), true);
                return true;
            }
            return false;
        }

        DonHang dh = donHangRepository.getById(maDh);
        if (dh == null) return false;
        if (maNv != null && !maNv.trim().isEmpty() && !maNv.equalsIgnoreCase("SYSTEM") && !maNv.equalsIgnoreCase("CUSTOMER")) {
            dh.setMaNv(maNv.trim());
        }
        // Buộc trạng thái thanh toán = 1 khi đơn chuyển thành Hoàn thành (status = 4)
        if (trangThaiMoi == 4) {
            dh.setTrangThaiThanhToan(1);
            donHangRepository.updateTrangThaiThanhToan(maDh, 1);
        }
        if (trangThaiMoi == 5) { // Đã hủy
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
        System.out.println("🔍 [SEPAY MATCHING] Đang phân tách nội dung chuyển khoản: " + cleanContent);
        Pattern pattern = Pattern.compile("TEA(\\d{8})(\\d{5,6})", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(cleanContent);
        if (matcher.find()) {
            String datePart = matcher.group(1);
            String serialPart = matcher.group(2);
            if (serialPart.length() == 6) {
                try {
                    int val = Integer.parseInt(serialPart);
                    serialPart = String.format("%05d", val);
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
            String extractedMaDh = "TEA-" + datePart + "-" + serialPart;
            System.out.println("🎯 [SEPAY MATCHING] Khớp được mã đơn hàng trích xuất: " + extractedMaDh);

            // BƯỚC 1: Tìm trong bộ nhớ đệm pendingOrders trước!
            if (util.PaymentStore.pendingOrders != null && util.PaymentStore.pendingOrders.containsKey(extractedMaDh)) {
                DonHang cachedOrder = util.PaymentStore.pendingOrders.get(extractedMaDh);
                // Cho phép sai lệch nhỏ dưới 100đ khi đối soát
                if (Math.abs(cachedOrder.getTongPhaiTra() - amount) < 100) {
                    // Xóa khỏi cache
                    util.PaymentStore.pendingOrders.remove(extractedMaDh);
                    // Thiết lập trạng thái thanh toán = 1 (Đã trả) và trạng thái đơn = 0 (Chờ xác nhận)
                    cachedOrder.setTrangThaiThanhToan(1);
                    cachedOrder.setTrangThaiDon(0); // SỬA: Chờ xác nhận (Chờ duyệt) thay vì nhảy thẳng sang 2 (Pha chế)

                    // Áp mã giảm giá và CRM ví điểm chính thức
                    if (cachedOrder.getMaKm() != null) {
                        khuyenMaiRepository.giamSoLuongVoucher(cachedOrder.getMaKm());
                    }
                    if (cachedOrder.getMaKh() != null && cachedOrder.getDiemSuDung() > 0) {
                        khachHangRepository.truDiemTichLuy(cachedOrder.getMaKh(), cachedOrder.getDiemSuDung());
                    }

                    // INSERT chính thức vào database
                    boolean success = donHangRepository.add(cachedOrder);
                    if (success) {
                        donHangRepository.updateTrangThaiDon(extractedMaDh, 0); // SỬA: Cập nhật trạng thái Chờ xác nhận (0)
                        if (cachedOrder.getMaKh() != null) {
                            int diemCong = cachedOrder.getTongPhaiTra() / 10000;
                            if (diemCong > 0) {
                                khachHangRepository.congDiemTichLuy(cachedOrder.getMaKh(), diemCong);
                            }
                        }
                        // Đánh dấu giao dịch thành công để Front-end Polling nhận biết
                        util.PaymentStore.transactions.put(extractedMaDh, true);
                        util.PaymentStore.transactions.put(extractedMaDh.replace("-", ""), true);
                        System.out.println("✅ [SEPAY MATCHING] Khớp cache thành công! Lưu DB đơn hàng (Chờ xác nhận): " + extractedMaDh);
                        return true;
                    }
                } else {
                    System.err.println("❌ [SEPAY MATCHING] Sai số tiền cho đơn " + extractedMaDh + ". Đơn cần: " + cachedOrder.getTongPhaiTra() + "đ | Thực nhận: " + amount + "đ");
                }
            } else {
                // BƯỚC 2: Fallback tìm kiếm dưới Database vật lý (đề phòng đơn đã lưu dưới DB từ trước)
                DonHang dh = donHangRepository.getById(extractedMaDh);
                if (dh != null && (dh.getTrangThaiThanhToan() == 0)) {
                    if (Math.abs(dh.getTongPhaiTra() - amount) < 100) {
                        donHangRepository.updateTrangThaiThanhToan(extractedMaDh, 1);
                        updateTrangThaiDon(extractedMaDh, 0, "SYSTEM", "Khớp thành công đơn SePay Webhook."); // SỬA: Chuyển về Chờ xác nhận (0)
                        util.PaymentStore.transactions.put(extractedMaDh, true);
                        util.PaymentStore.transactions.put(extractedMaDh.replace("-", ""), true);
                        System.out.println("✅ [SEPAY MATCHING] Khớp CSDL thành công! Cập nhật trạng thái đơn hàng (Chờ xác nhận): " + extractedMaDh);
                        return true;
                    }
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