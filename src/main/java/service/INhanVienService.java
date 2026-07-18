package service;

import model.entity.NhanVien;
import java.util.List;

public interface INhanVienService {
    List<NhanVien> getAllNhanVien();
    NhanVien getNhanVienById(String id);
    NhanVien getNhanVienByEmail(String email);
    NhanVien loginNhanVien(String username, String password, String ipAddress);
    boolean createNhanVien(NhanVien nhanVien);
    boolean updateNhanVien(NhanVien nhanVien);
    boolean deleteNhanVien(String id);
    boolean changePassword(String maNv, String oldPassword, String newPassword);
    boolean resetPasswordByAdmin(String maNv, String newPassword);
    boolean isAccountLocked(String username);
    long getRemainingLockTime(String username);
    boolean sendForgotPasswordOTP(String email);
    boolean verifyForgotPasswordOTP(String email, String otp);
    boolean resetPasswordWithOTP(String email, String otp, String newPassword);
}
