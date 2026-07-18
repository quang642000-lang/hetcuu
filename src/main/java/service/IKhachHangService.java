package service;

import model.entity.KhachHang;
import java.util.List;

public interface IKhachHangService {
    List<KhachHang> getAllKhachHang();
    KhachHang getKhachHangById(String id);
    KhachHang getKhachHangBySdt(String sdt);
    KhachHang getKhachHangByEmail(String email);
    KhachHang registerCustomer(String tenKh, String sdt, String email, String password);
    KhachHang loginCustomer(String usernameOrSdtOrEmail, String password);
    boolean sendActivationOTP(String email);
    boolean verifyActivationOTP(String email, String otp);
    boolean sendForgotPasswordOTP(String email);
    boolean verifyForgotPasswordOTP(String email, String otp);
    boolean resetPasswordWithOTP(String email, String otp, String newPassword);
    boolean updateMatKhau(String maKh, String matKhauMoi);
    boolean updateCustomerProfile(KhachHang khachHang);
    boolean updateDiemTichLuy(String maKh, int diem, boolean isCong);
}
