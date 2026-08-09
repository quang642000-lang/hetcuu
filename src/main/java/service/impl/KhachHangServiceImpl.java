package service.impl;

import model.entity.KhachHang;
import repository.IKhachHangRepository;
import repository.impl.KhachHangRepoImpl;
import service.IKhachHangService;
import util.SecurityUtil;
import util.EmailSenderUtil;
import config.DBConnect;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

/**
 * =========================================================================
 * TEA POS SYSTEM - CLIENT CRM SERVICE IMPLEMENTATION (LIFETIME SPENT RANK LOGIC V2)
 * Fully synchronized with application database, supporting secure email OTP codes,
 * salted SHA-256 password validations, and true lifetimespent-based loyalty tiers.
 * =========================================================================
 */
public class KhachHangServiceImpl implements IKhachHangService {
    private static KhachHangServiceImpl instance;
    private final IKhachHangRepository khachHangRepository;

    private static class OtpInfo {
        String code;
        long expireTime;
        OtpInfo(String code, long expireTime) {
            this.code = code;
            this.expireTime = expireTime;
        }
    }

    private final ConcurrentHashMap<String, OtpInfo> activationOtpCache = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, OtpInfo> forgotPasswordOtpCache = new ConcurrentHashMap<>();

    private KhachHangServiceImpl() {
        this.khachHangRepository = KhachHangRepoImpl.getInstance();
    }

    public static synchronized KhachHangServiceImpl getInstance() {
        if (instance == null) {
            instance = new KhachHangServiceImpl();
        }
        return instance;
    }

    @Override
    public List<KhachHang> getAllKhachHang() {
        return khachHangRepository.getAll();
    }

    @Override
    public KhachHang getKhachHangById(String id) {
        return khachHangRepository.getById(id);
    }

    @Override
    public KhachHang getKhachHangBySdt(String sdt) {
        return khachHangRepository.getBySdt(sdt);
    }

    @Override
    public KhachHang getKhachHangByEmail(String email) {
        return khachHangRepository.getByEmail(email);
    }

    @Override
    public KhachHang registerCustomer(String tenKh, String sdt, String email, String password) {
        if (khachHangRepository.checkTrungSdtOrEmail(sdt, email, null)) {
            return null;
        }
        KhachHang kh = new KhachHang();
        kh.setTenKh(tenKh);
        kh.setSoDienThoai(sdt);
        kh.setEmail(email);
        kh.setMatKhau(SecurityUtil.hashWithSalt(password, email));
        kh.setDiemTichLuy(0);
        kh.setMaHang(1);
        kh.setTrangThai(false);

        boolean success = khachHangRepository.add(kh);
        if (success) {
            boolean otpSent = sendActivationOTP(email);
            if (!otpSent) {
                System.err.println("[TEA POS WARNING] Gửi mail kích hoạt OTP thất bại cho: " + email);
            }
            return kh;
        }
        return null;
    }

    @Override
    public KhachHang registerCustomerAtPOS(String tenKh, String sdt, String email) {
        if (khachHangRepository.checkTrungSdtOrEmail(sdt, email, null)) {
            return null;
        }
        KhachHang kh = new KhachHang();
        kh.setTenKh(tenKh);
        kh.setSoDienThoai(sdt);
        kh.setEmail(email);
        kh.setMatKhau(null);
        kh.setDiemTichLuy(0);
        kh.setMaHang(1);
        kh.setTrangThai(true);

        boolean success = khachHangRepository.add(kh);
        if (success) {
            return khachHangRepository.getBySdt(sdt);
        }
        return null;
    }

    @Override
    public KhachHang loginCustomer(String usernameOrSdtOrEmail, String password) {
        KhachHang kh = khachHangRepository.getBySdt(usernameOrSdtOrEmail);
        if (kh == null) {
            kh = khachHangRepository.getByEmail(usernameOrSdtOrEmail);
        }
        if (kh != null && kh.isTrangThai() && kh.getMatKhau() != null) {
            String hashedInput = SecurityUtil.hashWithSalt(password, kh.getEmail());
            if (kh.getMatKhau().equals(hashedInput)) {
                return kh;
            }
        }
        return null;
    }

    @Override
    public boolean sendActivationOTP(String email) {
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000);
        activationOtpCache.put(email, new OtpInfo(otpCode, expireTime));
        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KÍCH HOẠT TÀI KHOẢN KHÁCH HÀNG MỚI]");
        System.out.println("Email khách nhận: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");
        try {
            return EmailSenderUtil.sendOTPEmail(email, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean verifyActivationOTP(String email, String otp) {
        OtpInfo info = activationOtpCache.get(email);
        if (info == null || System.currentTimeMillis() > info.expireTime) {
            activationOtpCache.remove(email);
            return false;
        }
        if (info.code.equals(otp)) {
            KhachHang kh = khachHangRepository.getByEmail(email);
            if (kh != null) {
                kh.setTrangThai(true);
                khachHangRepository.update(kh);
                activationOtpCache.remove(email);
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean sendForgotPasswordOTP(String email) {
        KhachHang kh = khachHangRepository.getByEmail(email);
        if (kh == null) {
            return false;
        }
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000);
        forgotPasswordOtpCache.put(email, new OtpInfo(otpCode, expireTime));
        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KHÔI PHỤC MẬT KHẨU (FORGOT PASSWORD)]");
        System.out.println("Email tài khoản: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");
        try {
            return EmailSenderUtil.sendOTPEmail(email, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi: " + e.getMessage());
            return false;
        }
    }

    @Override
    public boolean verifyForgotPasswordOTP(String email, String otp) {
        OtpInfo info = forgotPasswordOtpCache.get(email);
        if (info == null || System.currentTimeMillis() > info.expireTime) {
            forgotPasswordOtpCache.remove(email);
            return false;
        }
        if (info.code.equals(otp.trim())) {
            forgotPasswordOtpCache.remove(email);
            return true;
        }
        return false;
    }

    @Override
    public boolean resetPasswordWithOTP(String email, String otp, String newPassword) {
        if (verifyForgotPasswordOTP(email, otp)) {
            KhachHang kh = khachHangRepository.getByEmail(email);
            if (kh != null) {
                kh.setMatKhau(SecurityUtil.hashWithSalt(newPassword, kh.getEmail()));
                kh.setTrangThai(true);
                return khachHangRepository.update(kh);
            }
        }
        return false;
    }

    @Override
    public boolean updateMatKhau(String maKh, String matKhauMoi) {
        return khachHangRepository.updateMatKhau(maKh, matKhauMoi);
    }

    @Override
    public boolean updateCustomerProfile(KhachHang khachHang) {
        if (khachHangRepository.checkTrungSdtOrEmail(khachHang.getSoDienThoai(), khachHang.getEmail(), khachHang.getMaKh())) {
            return false;
        }
        KhachHang dbKh = khachHangRepository.getById(khachHang.getMaKh());
        if (dbKh != null) {
            dbKh.setTenKh(khachHang.getTenKh());
            dbKh.setSoDienThoai(khachHang.getSoDienThoai());
            dbKh.setEmail(khachHang.getEmail());
            dbKh.setNgaySinh(khachHang.getNgaySinh());
            dbKh.setGioiTinh(khachHang.getGioiTinh());
            dbKh.setDiaChiLienHe(khachHang.getDiaChiLienHe());
            dbKh.setHinhAnhUrl(khachHang.getHinhAnhUrl());
            dbKh.setTrangThai(khachHang.isTrangThai());
            return khachHangRepository.update(dbKh);
        }
        return khachHangRepository.update(khachHang);
    }

    @Override
    public boolean updateDiemTichLuy(String maKh, int diem, boolean isCong) {
        if (isCong) {
            boolean success = khachHangRepository.congDiemTichLuy(maKh, diem);
            if (success) updateHangThanhVienDongBo(maKh);
            return success;
        } else {
            boolean success = khachHangRepository.truDiemTichLuy(maKh, diem);
            // SỬA LỖI CRM LOGIC: Luôn cập nhật lại hạng thành viên đồng bộ khi trừ điểm
            if (success) updateHangThanhVienDongBo(maKh);
            return success;
        }
    }

    /**
     * Tính toán tổng số tiền tích lũy từ các đơn hàng thành công (trang_thai_don = 4) của khách hàng
     */
    public int getTongChiTieu(String maKh) {
        if (maKh == null || maKh.trim().isEmpty()) return 0;
        String sql = "SELECT COALESCE(SUM(tong_phai_tra), 0) FROM DON_HANG WHERE ma_kh = ? AND trang_thai_don = 4";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKh);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Đồng bộ hóa hạng thành viên dựa trên tổng số tiền tích lũy thực tế đã mua hàng (Lifetime Purchases)
     */
    public void updateHangThanhVienDongBo(String maKh) {
        KhachHang kh = khachHangRepository.getById(maKh);
        if (kh != null) {
            int tongChiTieu = getTongChiTieu(maKh);
            int newHang = 1; // 1: Đồng
            if (tongChiTieu >= 5000000) {
                newHang = 4; // VIP / Kim Cương
            } else if (tongChiTieu >= 2000000) {
                newHang = 3; // Vàng
            } else if (tongChiTieu >= 500000) {
                newHang = 2; // Bạc
            }

            if (kh.getMaHang() != newHang) {
                kh.setMaHang(newHang);
                khachHangRepository.update(kh);
                System.out.println("🎉 [CRM UPGRADE] Hội viên " + kh.getTenKh() + " (" + maKh + ") thăng hạng thành công lên Hạng " + newHang + " dựa trên chi tiêu: " + tongChiTieu + "đ.");
            }
        }
    }
}
