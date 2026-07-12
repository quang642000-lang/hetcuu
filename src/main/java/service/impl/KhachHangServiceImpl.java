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
        kh.setTrangThai(false); // Chưa kích hoạt
        boolean success = khachHangRepository.add(kh);
        if (success) {
            sendActivationOTP(email);
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
        long expireTime = System.currentTimeMillis() + (2 * 60 * 1000);
        activationOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KÍCH HOẠT TÀI KHOẢN KHÁCH HÀNG MỚI]");
        System.out.println("Email khách nhận: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("Hãy sao chép mã này gõ vào ô OTP để kích hoạt ngay trong lúc Demo!");
        System.out.println("======================================================================");

        try {
            EmailSenderUtil.sendOTPEmail(email, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi (không sao cả, dùng mã in trên Console để nhập): " + e.getMessage());
        }
        return true;
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
        if (kh == null || !kh.isTrangThai()) {
            return false;
        }
        String otpCode = String.format("%06d", new Random().nextInt(999999));
        long expireTime = System.currentTimeMillis() + (2 * 60 * 1000);
        forgotPasswordOtpCache.put(email, new OtpInfo(otpCode, expireTime));

        System.out.println("======================================================================");
        System.out.println("[TEA POS - OTP KHÔI PHỤC MẬT KHẨU (FORGOT PASSWORD)]");
        System.out.println("Email tài khoản: " + email);
        System.out.println("Mã OTP để nhập:  " + otpCode);
        System.out.println("Hãy sao chép mã này gõ vào ô OTP để đổi mật khẩu ngay trong lúc Demo!");
        System.out.println("======================================================================");

        try {
            EmailSenderUtil.sendOTPEmail(email, otpCode);
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Gửi mail OTP lỗi (không sao cả, dùng mã in trên Console để nhập): " + e.getMessage());
        }
        return true;
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

        // BIỆN PHÁP PHÒNG THỦ (TRANS TRANSACTION PROTECTION):
        // Truy vấn dữ liệu thực tế hiện hành trong Database của khách hàng trước khi lưu cập nhật.
        // Chặn đứng hoàn toàn việc các dữ liệu cũ lưu trong Session (như số điểm diem_tich_luy cũ, hạng thẻ ma_hang cũ)
        // đè đè và ghi khống ngược lại Database làm mất mát số dư ví điểm CRM của hội viên!
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
            // Bảo toàn tuyệt đối hai trường điểm số nhạy cảm:
            // dbKh's diemTichLuy & dbKh's maHang được giữ nguyên không thay đổi!
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
            int newHang = 1; // Mặc định ĐỒNG
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
