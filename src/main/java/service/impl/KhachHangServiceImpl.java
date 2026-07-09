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

    // Cache lưu trữ OTP tạm thời trong RAM (Key: Email, Value: OTP_Info)
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
    public KhachHang registerCustomer(String tenKh, String sdt, String email, String password) {
        // 1. Kiểm tra trung lặp SĐT hoặc Email
        if (khachHangRepository.checkTrungSdtOrEmail(sdt, email, null)) {
            return null;
        }

        // 2. Khởi tạo đối tượng
        KhachHang kh = new KhachHang();
        kh.setTenKh(tenKh);
        kh.setSoDienThoai(sdt);
        kh.setEmail(email);
        kh.setMatKhau(SecurityUtil.hashSHA256(password)); // Băm SHA-256 bảo mật
        kh.setDiemTichLuy(0);
        kh.setMaHang(1); // Mặc định hạng mới tham gia
        kh.setTrangThai(false); // Chưa kích hoạt, đợi nhập OTP

        // 3. Lưu vào Database (Procedure sp_ThemKhachHang sẽ tự động tạo mã dạng KHxxxxx)
        boolean success = khachHangRepository.add(kh);
        if (success) {
            sendActivationOTP(email); // Gửi OTP kích hoạt
            return kh;
        }
        return null;
    }

    @Override
    public KhachHang loginCustomer(String usernameOrSdtOrEmail, String password) {
        KhachHang kh = khachHangRepository.getBySdt(usernameOrSdtOrEmail);
        if (kh == null) {
            kh = khachHangRepository.getByEmail(usernameOrSdtOrEmail);
        }

        if (kh != null && kh.isTrangThai()) {
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
        // Cập nhật hiệu lực thành 2 phút (120,000 milliseconds) để khớp với Template Email
        long expireTime = System.currentTimeMillis() + (2 * 60 * 1000);
        activationOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        // Gọi hàm gửi email với 2 tham số từ tiện ích mới của bạn
        return EmailSenderUtil.sendOTPEmail(email, otpCode);
    }

    @Override
    public boolean verifyActivationOTP(String email, String otp) {
        OtpInfo info = activationOtpCache.get(email);
        if (info == null || System.currentTimeMillis() > info.expireTime) {
            activationOtpCache.remove(email);
            return false; // OTP không tồn tại hoặc hết hạn
        }

        if (info.code.equals(otp)) {
            KhachHang kh = khachHangRepository.getByEmail(email);
            if (kh != null) {
                kh.setTrangThai(true); // Kích hoạt tài khoản thành công
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
        if (kh == null || !kh.isTrangThai()) {
            return false;
        }

        String otpCode = String.format("%06d", new Random().nextInt(999999));
        // Cập nhật hiệu lực thành 2 phút (120,000 milliseconds)
        long expireTime = System.currentTimeMillis() + (2 * 60 * 1000);
        forgotPasswordOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        // Gọi hàm gửi email với 2 tham số
        return EmailSenderUtil.sendOTPEmail(email, otpCode);
    }

    @Override
    public boolean resetPasswordWithOTP(String email, String otp, String newPassword) {
        OtpInfo info = forgotPasswordOtpCache.get(email);
        if (info == null || System.currentTimeMillis() > info.expireTime) {
            forgotPasswordOtpCache.remove(email);
            return false;
        }

        if (info.code.equals(otp)) {
            KhachHang kh = khachHangRepository.getByEmail(email);
            if (kh != null) {
                kh.setMatKhau(SecurityUtil.hashSHA256(newPassword));
                boolean success = khachHangRepository.update(kh);
                if (success) {
                    forgotPasswordOtpCache.remove(email);
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public boolean updateCustomerProfile(KhachHang khachHang) {
        if (khachHangRepository.checkTrungSdtOrEmail(khachHang.getSoDienThoai(), khachHang.getEmail(), khachHang.getMaKh())) {
            return false;
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
            int newHang = 1; // Mặc định hạng Đồng
            if (currentDiem >= 500) {
                newHang = 4; // Kim cương
            } else if (currentDiem >= 200) {
                newHang = 3; // Vàng
            } else if (currentDiem >= 50) {
                newHang = 2; // Bạc
            }
            if (kh.getMaHang() != newHang) {
                kh.setMaHang(newHang);
                khachHangRepository.update(kh);
            }
        }
    }
}