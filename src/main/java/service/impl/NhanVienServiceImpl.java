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
        return nhanVienRepository.getById(id);
    }

    @Override
    public NhanVien getNhanVienByEmail(String email) {
        return nhanVienRepository.getByEmail(email);
    }

    @Override
    public boolean isAccountLocked(String username) {
        LoginAttempt attempt = loginAttemptsCache.get(username);
        if (attempt == null) return false;
        if (attempt.attempts >= 5) {
            if (System.currentTimeMillis() < attempt.lockTime) {
                return true;
            } else {
                loginAttemptsCache.remove(username);
                return false;
            }
        }
        return false;
    }

    @Override
    public long getRemainingLockTime(String username) {
        LoginAttempt attempt = loginAttemptsCache.get(username);
        if (attempt == null || attempt.attempts < 5) return 0;
        long diff = attempt.lockTime - System.currentTimeMillis();
        return diff > 0 ? diff / 1000 : 0;
    }

    @Override
    public NhanVien loginNhanVien(String username, String password, String ipAddress) {
        if (isAccountLocked(username)) {
            return null;
        }
        NhanVien nv = nhanVienRepository.getByTenDangNhap(username);
        if (nv == null || !nv.isTrangThai()) {
            return null;
        }
        // FIX: Đăng nhập băm kèm muối tên đăng nhập của nhân sự
        String hashedInput = SecurityUtil.hashWithSalt(password, nv.getTenDangNhap());
        if (nv.getMatKhau().equals(hashedInput)) {
            loginAttemptsCache.remove(username);
            repository.impl.NhatKyRepoImpl.getInstance().addLog(new model.entity.NhatKyHoatDong(
                    nv.getMaNv(), "ĐĂNG NHẬP", "NHAN_VIEN", null, "Đăng nhập thành công", ipAddress, null
            ));
            return nv;
        } else {
            LoginAttempt attempt = loginAttemptsCache.get(username);
            if (attempt == null) {
                loginAttemptsCache.put(username, new LoginAttempt(1, 0));
            } else {
                attempt.attempts++;
                if (attempt.attempts >= 5) {
                    attempt.lockTime = System.currentTimeMillis() + (5 * 60 * 1000);
                    System.err.println("⚠️ [SECURITY WARNING] Tài khoản " + username + " đã bị khóa 5 phút do nhập sai mật khẩu liên tiếp 5 lần!");
                }
            }
        }
        return null;
    }

    @Override
    public boolean createNhanVien(NhanVien nhanVien) {
        if (nhanVienRepository.checkTrungSdtOrEmail(nhanVien.getSoDienThoai(), nhanVien.getEmail(), null)) {
            return false;
        }
        if (nhanVienRepository.getByTenDangNhap(nhanVien.getTenDangNhap()) != null) {
            return false;
        }
        // FIX: Tạo mới băm mật khẩu kèm muối tên đăng nhập
        nhanVien.setMatKhau(SecurityUtil.hashWithSalt(nhanVien.getMatKhau(), nhanVien.getTenDangNhap()));
        return nhanVienRepository.add(nhanVien);
    }

    @Override
    public boolean updateNhanVien(NhanVien nhanVien) {
        if (nhanVienRepository.checkTrungSdtOrEmail(nhanVien.getSoDienThoai(), nhanVien.getEmail(), nhanVien.getMaNv())) {
            return false;
        }
        return nhanVienRepository.update(nhanVien);
    }

    @Override
    public boolean deleteNhanVien(String id) {
        return nhanVienRepository.delete(id);
    }

    @Override
    public boolean changePassword(String maNv, String oldPassword, String newPassword) {
        NhanVien nv = nhanVienRepository.getById(maNv);
        if (nv != null) {
            // FIX: Đổi mật khẩu băm muối tên đăng nhập
            String oldHashed = SecurityUtil.hashWithSalt(oldPassword, nv.getTenDangNhap());
            if (nv.getMatKhau().equals(oldHashed)) {
                return nhanVienRepository.updateMatKhau(maNv, SecurityUtil.hashWithSalt(newPassword, nv.getTenDangNhap()));
            }
        }
        return false;
    }

    @Override
    public boolean resetPasswordByAdmin(String maNv, String newPassword) {
        NhanVien nv = nhanVienRepository.getById(maNv);
        if (nv != null) {
            // FIX: Reset mật khẩu băm muối tên đăng nhập đồng bộ
            return nhanVienRepository.updateMatKhau(maNv, SecurityUtil.hashWithSalt(newPassword, nv.getTenDangNhap()));
        }
        return false;
    }

    @Override
    public boolean sendForgotPasswordOTP(String email) {
        NhanVien nv = nhanVienRepository.getByEmail(email);
        if (nv == null || !nv.isTrangThai()) {
            return false;
        }
        String otpCode = String.format("%06d", new java.util.Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000);
        forgotPasswordOtpCache.put(email, new OtpInfo(otpCode, expireTime));
        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KHÔI PHỤC MẬT KHẨU NHÂN VIÊN (FORGOT PASSWORD STAFF)]");
        System.out.println("Email tài khoản: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("======================================================================");
        try {
            EmailSenderUtil.sendOTPEmail(email, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi: " + e.getMessage());
        }
        return true;
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
            NhanVien nv = nhanVienRepository.getByEmail(email);
            if (nv != null) {
                return resetPasswordByAdmin(nv.getMaNv(), newPassword);
            }
        }
        return false;
    }
}
