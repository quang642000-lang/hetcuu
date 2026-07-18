package service.impl;

import model.entity.NhanVien;
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
    public NhanVien loginNhanVien(String username, String password, String ipAddress) {
        if (isAccountLocked(username)) {
            return null;
        }
        NhanVien nv = nhanVienRepository.getByTenDangNhap(username);
        if (nv == null || !nv.isTrangThai()) {
            return null;
        }
        String hashedInput = SecurityUtil.hashSHA256(password);
        if (nv.getMatKhau().equals(hashedInput)) {
            repository.impl.NhatKyRepoImpl.getInstance().addLog(new model.entity.NhatKyHoatDong(
                    nv.getMaNv(), "ĐĂNG NHẬP", "NHAN_VIEN", null, "Đăng nhập thành công", ipAddress, null
            ));
            return nv;
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
        nhanVien.setMatKhau(SecurityUtil.hashSHA256(nhanVien.getMatKhau()));
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
            String oldHashed = SecurityUtil.hashSHA256(oldPassword);
            if (nv.getMatKhau().equals(oldHashed)) {
                return nhanVienRepository.updateMatKhau(maNv, SecurityUtil.hashSHA256(newPassword));
            }
        }
        return false;
    }

    @Override
    public boolean resetPasswordByAdmin(String maNv, String newPassword) {
        return nhanVienRepository.updateMatKhau(maNv, SecurityUtil.hashSHA256(newPassword));
    }

    @Override
    public boolean isAccountLocked(String username) {
        return false;
    }

    @Override
    public long getRemainingLockTime(String username) {
        return 0;
    }

    @Override
    public boolean sendForgotPasswordOTP(String email) {
        NhanVien nv = nhanVienRepository.getByEmail(email);
        if (nv == null || !nv.isTrangThai()) {
            return false;
        }
        String otpCode = String.format("%06d", new java.util.Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 phút
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
