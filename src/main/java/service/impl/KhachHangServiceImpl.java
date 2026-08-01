package service.impl;

import model.entity.KhachHang;
import repository.IKhachHangRepository;
import repository.impl.KhachHangRepoImpl;
import service.IKhachHangService;
import util.SecurityUtil;
import util.EmailSenderUtil;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

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
        kh.setMatKhau(SecurityUtil.hashSHA256(password));
        kh.setDiemTichLuy(0);
        kh.setMaHang(1); // Mặc định ĐỒNG
        kh.setTrangThai(false); // Chưa kích hoạt trên web

        boolean success = khachHangRepository.add(kh);
        if (success) {
            // SỬA LỖI LOGIC: Kiểm toán kết quả gửi OTP để trả về trạng thái chính xác
            boolean otpSent = sendActivationOTP(email);
            if (!otpSent) {
                System.err.println("[TEA POS WARNING] Tạo được tài khoản nhưng không gửi được mail kích hoạt OTP cho email: " + email);
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
        kh.setMatKhau(null); // mật khẩu trống, chờ kích hoạt trên web
        kh.setDiemTichLuy(0);
        kh.setMaHang(1); // Đồng
        kh.setTrangThai(true); // Trạng thái = true để có thể sử dụng ngay tại POS!

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
            String hashedInput = SecurityUtil.hashSHA256(password);
            if (kh.getMatKhau().equals(hashedInput)) {
                return kh;
            }
        }
        return null;
    }

    @Override
    public boolean sendActivationOTP(String email) {
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 phút
        activationOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KÍCH HOẠT TÀI KHOẢN KHÁCH HÀNG MỚI]");
        System.out.println("Email khách nhận: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");

        try {
            // SỬA LỖI LOGIC: Trả về giá trị của EmailSenderUtil thay vì luôn trả về true bừa bãi
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
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 phút
        forgotPasswordOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KHÔI PHỤC MẬT KHẨU (FORGOT PASSWORD)]");
        System.out.println("Email tài khoản: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");

        try {
            // SỬA LỖI LOGIC: Trả về kết quả thực gửi thư từ SMTP Server
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
        if (info.code.equals(otp)) {
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
                kh.setMatKhau(SecurityUtil.hashSHA256(newPassword));
                kh.setTrangThai(true); // Tự động kích hoạt tài khoản luôn sau khi tạo mật khẩu
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
            return khachHangRepository.truDiemTichLuy(maKh, diem);
        }
    }

    private void updateHangThanhVienDongBo(String maKh) {
        KhachHang kh = khachHangRepository.getById(maKh);
        if (kh != null) {
            int currentDiem = kh.getDiemTichLuy();
            int newHang = 1;
            if (currentDiem >= 500) {
                newHang = 4;
            } else if (currentDiem >= 200) {
                newHang = 3;
            } else if (currentDiem >= 50) {
                newHang = 2;
            }
            if (kh.getMaHang() != newHang) {
                kh.setMaHang(newHang);
                khachHangRepository.update(kh);
            }
        }
    }
}
