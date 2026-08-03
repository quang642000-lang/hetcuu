package service.impl;

import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.INhanVienRepository;
import repository.impl.NhanVienRepoImpl;
import service.INhanVienService;
import util.SecurityUtil;
import util.EmailSenderUtil;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/**
 * =========================================================================
 * TEA POS SYSTEM - SECURE EMPLOYEE SERVICE IMPLEMENTATION (v8.6)
 * Refactored with strict Case-Sensitive comparison and automatic username trimming
 * to prevent trailing space bypass vulnerabilities (CWE-1041 / CWE-521).
 * =========================================================================
 */
public class NhanVienServiceImpl implements INhanVienService {
    private static NhanVienServiceImpl instance;
    private final INhanVienRepository nhanVienRepository;

    private static class OtpInfo {
        String code;
        long expireTime;
        OtpInfo(String code, long expireTime) {
            this.code = code;
            this.expireTime = expireTime;
        }
    }

    private final ConcurrentHashMap<String, OtpInfo> forgotPasswordOtpCache = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, LoginAttempt> loginAttemptsCache = new ConcurrentHashMap<>();

    private static class LoginAttempt {
        int attempts;
        long lockTime;
        LoginAttempt(int attempts, long lockTime) {
            this.attempts = attempts;
            this.lockTime = lockTime;
        }
    }

    private NhanVienServiceImpl() {
        this.nhanVienRepository = NhanVienRepoImpl.getInstance();
    }

    public static synchronized NhanVienServiceImpl getInstance() {
        if (instance == null) {
            instance = new NhanVienServiceImpl();
        }
        return instance;
    }

    @Override
    public List<NhanVien> getAllNhanVien() {
        return nhanVienRepository.getAll();
    }

    @Override
    public NhanVien getNhanVienById(String id) {
        if (id == null) return null;
        return nhanVienRepository.getById(id.trim());
    }

    @Override
    public NhanVien getNhanVienByEmail(String email) {
        if (email == null) return null;
        return nhanVienRepository.getByEmail(email.trim());
    }

    @Override
    public boolean isAccountLocked(String username) {
        if (username == null) return false;
        String cleanUsername = username.trim().toLowerCase();
        LoginAttempt attempt = loginAttemptsCache.get(cleanUsername);
        if (attempt == null) return false;
        if (attempt.attempts >= 5) {
            if (System.currentTimeMillis() < attempt.lockTime) {
                return true;
            } else {
                loginAttemptsCache.remove(cleanUsername);
                return false;
            }
        }
        return false;
    }

    @Override
    public long getRemainingLockTime(String username) {
        if (username == null) return 0;
        String cleanUsername = username.trim().toLowerCase();
        LoginAttempt attempt = loginAttemptsCache.get(cleanUsername);
        if (attempt == null || attempt.attempts < 5) return 0;
        long diff = attempt.lockTime - System.currentTimeMillis();
        return diff > 0 ? diff / 1000 : 0;
    }

    @Override
    public NhanVien loginNhanVien(String username, String password, String ipAddress) {
        if (username == null || password == null) return null;
        String cleanUsername = username.trim();
        String lookupKey = cleanUsername.toLowerCase();

        if (isAccountLocked(cleanUsername)) {
            return null;
        }

        NhanVien nv = nhanVienRepository.getByTenDangNhap(cleanUsername);
        if (nv == null || !nv.isTrangThai()) {
            return null;
        }

        // SỬA LỖI CASE-SENSITIVE CHÍ MẠNG: Kiểm tra khớp chính xác từng ký tự hoa/thường
        if (!nv.getTenDangNhap().equals(cleanUsername)) {
            handleFailedLogin(cleanUsername);
            return null;
        }

        // FIX: Đăng nhập băm kèm muối tên đăng nhập chính chủ của nhân sự
        String hashedInput = SecurityUtil.hashWithSalt(password, nv.getTenDangNhap());
        if (nv.getMatKhau().equals(hashedInput)) {
            loginAttemptsCache.remove(lookupKey);
            repository.impl.NhatKyRepoImpl.getInstance().addLog(new model.entity.NhatKyHoatDong(
                    nv.getMaNv(), "ĐĂNG NHẬP", "NHAN_VIEN", null, "Đăng nhập thành công", ipAddress, null
            ));
            return nv;
        } else {
            handleFailedLogin(cleanUsername);
        }
        return null;
    }

    private void handleFailedLogin(String username) {
        if (username == null) return;
        String lookupKey = username.trim().toLowerCase();
        LoginAttempt attempt = loginAttemptsCache.get(lookupKey);
        if (attempt == null) {
            loginAttemptsCache.put(lookupKey, new LoginAttempt(1, 0));
        } else {
            attempt.attempts++;
            if (attempt.attempts >= 5) {
                attempt.lockTime = System.currentTimeMillis() + (5 * 60 * 1000);
                System.err.println("⚠️ [SECURITY WARNING] Tài khoản " + lookupKey + " đã bị khóa 5 phút do nhập sai mật khẩu liên tiếp 5 lần!");
            }
        }
    }

    @Override
    public boolean createNhanVien(NhanVien nhanVien) {
        if (nhanVien == null) return false;
        if (nhanVien.getSoDienThoai() != null) nhanVien.setSoDienThoai(nhanVien.getSoDienThoai().trim());
        if (nhanVien.getEmail() != null) nhanVien.setEmail(nhanVien.getEmail().trim());
        if (nhanVien.getTenDangNhap() != null) nhanVien.setTenDangNhap(nhanVien.getTenDangNhap().trim());

        if (nhanVienRepository.checkTrungSdtOrEmail(nhanVien.getSoDienThoai(), nhanVien.getEmail(), null)) {
            return false;
        }
        if (nhanVienRepository.getByTenDangNhap(nhanVien.getTenDangNhap()) != null) {
            return false;
        }
        // FIX: Tạo mới băm mật khẩu kèm muối tên đăng nhập chính chủ
        nhanVien.setMatKhau(SecurityUtil.hashWithSalt(nhanVien.getMatKhau(), nhanVien.getTenDangNhap()));
        return nhanVienRepository.add(nhanVien);
    }

    @Override
    public boolean updateNhanVien(NhanVien nhanVien) {
        if (nhanVien == null) return false;
        if (nhanVien.getSoDienThoai() != null) nhanVien.setSoDienThoai(nhanVien.getSoDienThoai().trim());
        if (nhanVien.getEmail() != null) nhanVien.setEmail(nhanVien.getEmail().trim());
        if (nhanVien.getTenDangNhap() != null) nhanVien.setTenDangNhap(nhanVien.getTenDangNhap().trim());

        if (nhanVienRepository.checkTrungSdtOrEmail(nhanVien.getSoDienThoai(), nhanVien.getEmail(), nhanVien.getMaNv())) {
            return false;
        }
        return nhanVienRepository.update(nhanVien);
    }

    @Override
    public boolean deleteNhanVien(String id) {
        if (id == null) return false;
        return nhanVienRepository.delete(id.trim());
    }

    @Override
    public boolean changePassword(String maNv, String oldPassword, String newPassword) {
        if (maNv == null || oldPassword == null || newPassword == null) return false;
        NhanVien nv = nhanVienRepository.getById(maNv.trim());
        if (nv != null) {
            // FIX: Đổi mật khẩu băm muối tên đăng nhập chính chủ
            String oldHashed = SecurityUtil.hashWithSalt(oldPassword, nv.getTenDangNhap());
            if (nv.getMatKhau().equals(oldHashed)) {
                return nhanVienRepository.updateMatKhau(nv.getMaNv(), SecurityUtil.hashWithSalt(newPassword, nv.getTenDangNhap()));
            }
        }
        return false;
    }

    @Override
    public boolean resetPasswordByAdmin(String maNv, String newPassword) {
        if (maNv == null || newPassword == null) return false;
        NhanVien nv = nhanVienRepository.getById(maNv.trim());
        if (nv != null) {
            // FIX: Reset mật khẩu băm muối tên đăng nhập đồng bộ
            return nhanVienRepository.updateMatKhau(nv.getMaNv(), SecurityUtil.hashWithSalt(newPassword, nv.getTenDangNhap()));
        }
        return false;
    }

    @Override
    public boolean sendForgotPasswordOTP(String email) {
        if (email == null) return false;
        String cleanEmail = email.trim();
        NhanVien nv = nhanVienRepository.getByEmail(cleanEmail);
        if (nv == null || !nv.isTrangThai()) {
            return false;
        }
        String otpCode = String.format("%06d", new java.util.Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000);
        forgotPasswordOtpCache.put(cleanEmail, new OtpInfo(otpCode, expireTime));
        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KHÔI PHỤC MẬT KHẨU NHÂN VIÊN (FORGOT PASSWORD STAFF)]");
        System.out.println("Email tài khoản: " + cleanEmail);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");
        try {
            EmailSenderUtil.sendOTPEmail(cleanEmail, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi: " + e.getMessage());
        }
        return true;
    }

    @Override
    public boolean verifyForgotPasswordOTP(String email, String otp) {
        if (email == null || otp == null) return false;
        String cleanEmail = email.trim();
        OtpInfo info = forgotPasswordOtpCache.get(cleanEmail);
        if (info == null || System.currentTimeMillis() > info.expireTime) {
            forgotPasswordOtpCache.remove(cleanEmail);
            return false;
        }
        if (info.code.equals(otp.trim())) {
            forgotPasswordOtpCache.remove(cleanEmail);
            return true;
        }
        return false;
    }

    @Override
    public boolean resetPasswordWithOTP(String email, String otp, String newPassword) {
        if (email == null || otp == null || newPassword == null) return false;
        String cleanEmail = email.trim();
        if (verifyForgotPasswordOTP(cleanEmail, otp)) {
            NhanVien nv = nhanVienRepository.getByEmail(cleanEmail);
            if (nv != null) {
                return resetPasswordByAdmin(nv.getMaNv(), newPassword);
            }
        }
        return false;
    }
}