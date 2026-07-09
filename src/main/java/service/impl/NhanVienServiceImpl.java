package service.impl;

import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.INhanVienRepository;
import repository.INhatKyRepository;
import repository.impl.NhanVienRepoImpl;
import repository.impl.NhatKyRepoImpl;
import service.INhanVienService;
import util.SecurityUtil;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

public class NhanVienServiceImpl implements INhanVienService {
    private static NhanVienServiceImpl instance;
    private final INhanVienRepository nhanVienRepository;
    private final INhatKyRepository nhatKyRepository;

    // Quản lý Brute-force trong RAM
    private static class LoginTracker {
        int attempts;
        long lockUntil;
        LoginTracker(int attempts, long lockUntil) {
            this.attempts = attempts;
            this.lockUntil = lockUntil;
        }
    }
    private final ConcurrentHashMap<String, LoginTracker> loginAttemptsCache = new ConcurrentHashMap<>();

    private NhanVienServiceImpl() {
        this.nhanVienRepository = NhanVienRepoImpl.getInstance();
        this.nhatKyRepository = NhatKyRepoImpl.getInstance();
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
    public NhanVien loginNhanVien(String username, String password, String ipAddress) {
        // 1. Kiểm tra tài khoản có đang bị khóa hay không
        if (isAccountLocked(username)) {
            return null;
        }

        NhanVien nv = nhanVienRepository.getByTenDangNhap(username);
        if (nv == null || !nv.isTrangThai()) {
            return null; // Không tồn tại hoặc đã ngừng hoạt động
        }

        String hashedInput = SecurityUtil.hashSHA256(password);
        if (nv.getMatKhau().equals(hashedInput)) {
            // Đăng nhập thành công -> Reset cache theo dõi sai mật khẩu
            loginAttemptsCache.remove(username);

            // Ghi nhật ký đăng nhập
            nhatKyRepository.addLog(new NhatKyHoatDong(nv.getMaNv(), "ĐĂNG NHẬP", "NHAN_VIEN", null, "Đăng nhập thành công", ipAddress, null));
            return nv;
        } else {
            // Đăng nhập thất bại -> Ghi nhận cộng dồn lần sai mật khẩu
            LoginTracker tracker = loginAttemptsCache.get(username);
            if (tracker == null) {
                tracker = new LoginTracker(1, 0);
            } else {
                tracker.attempts++;
            }

            if (tracker.attempts >= 5) {
                tracker.lockUntil = System.currentTimeMillis() + (5 * 60 * 1000); // Khóa 5 phút
                loginAttemptsCache.put(username, tracker);

                // Ghi log bảo mật: Phát hiện dò mật khẩu
                nhatKyRepository.addLog(new NhatKyHoatDong(nv.getMaNv(), "KHÓA_TÀI_KHOẢN", "NHAN_VIEN", null, "Tài khoản bị khóa 5 phút do nhập sai 5 lần", ipAddress, null));
            } else {
                loginAttemptsCache.put(username, tracker);
            }
            return null;
        }
    }

    @Override
    public boolean createNhanVien(NhanVien nhanVien) {
        if (nhanVienRepository.checkTrungSdtOrEmail(nhanVien.getSoDienThoai(), nhanVien.getEmail(), null)) {
            return false;
        }
        if (nhanVienRepository.getByTenDangNhap(nhanVien.getTenDangNhap()) != null) {
            return false; // Trùng tên đăng nhập
        }

        nhanVien.setMatKhau(SecurityUtil.hashSHA256(nhanVien.getMatKhau())); // Mã hóa một chiều
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
        return nhanVienRepository.delete(id); // Soft Delete
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
        LoginTracker tracker = loginAttemptsCache.get(username);
        if (tracker == null) return false;
        if (System.currentTimeMillis() < tracker.lockUntil) {
            return true;
        }
        // Đã qua thời gian khóa -> tự động giải phóng khóa
        if (System.currentTimeMillis() >= tracker.lockUntil && tracker.lockUntil > 0) {
            loginAttemptsCache.remove(username);
        }
        return false;
    }

    @Override
    public long getRemainingLockTime(String username) {
        LoginTracker tracker = loginAttemptsCache.get(username);
        if (tracker == null || tracker.lockUntil == 0) return 0;
        long remain = tracker.lockUntil - System.currentTimeMillis();
        return remain > 0 ? (remain / 1000) : 0;
    }
}