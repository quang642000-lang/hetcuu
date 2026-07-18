package service;

import model.entity.NhanVien;
import java.util.List;

public interface INhanVienService {
    List<NhanVien> getAllNhanVien();
    NhanVien getNhanVienById(String id);
    NhanVien loginNhanVien(String username, String password, String ipAddress);
    boolean createNhanVien(NhanVien nhanVien);
    boolean updateNhanVien(NhanVien nhanVien);
    boolean deleteNhanVien(String id);
    boolean changePassword(String maNv, String oldPassword, String newPassword);
    boolean resetPasswordByAdmin(String maNv, String newPassword);
    boolean isAccountLocked(String username);
    long getRemainingLockTime(String username);

    // BỔ SUNG ĐỘC QUYỀN CHO GIAI ĐOẠN 2: QUÊN MẬT KHẨU NHÂN VIÊN
    boolean sendForgotPasswordOTP(String email);
    boolean resetPasswordWithOTP(String email, String otp, String newPassword);
}
