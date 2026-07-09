package service;

import model.entity.KhachHang;
import java.sql.Date;
import java.util.List;

public interface IKhachHangService {

    List<KhachHang> getAllKhachHang();

    KhachHang getKhachHangById(String id);

    KhachHang getKhachHangBySdt(String sdt);

    /**
     * Đăng ký tài khoản khách hàng mới trên Website Portal.
     * Quy tắc nghiệp vụ (Business Rules):
     * - Kiểm tra số điện thoại và email tuyệt đối không được trùng lặp trong hệ thống.
     * - Mật khẩu bắt buộc phải được băm mã hóa một chiều SHA-256 thông qua `SecurityUtil` trước khi lưu vào CSDL.
     * - Sau khi đăng ký thành công, CSDL tự động kích hoạt giỏ hàng rỗng thông qua Trigger `trg_TuDongTaoGioHang` [10].
     * - Hệ thống sinh mã OTP 6 số ngẫu nhiên gửi về Email khách hàng để yêu cầu kích hoạt tài khoản [11].
     * @param tenKh Họ tên khách hàng
     * @param sdt Số điện thoại đăng ký
     * @param email Email đăng ký nhận OTP
     * @param password Mật khẩu gốc chưa mã hóa
     * @return Đối tượng KhachHang vừa tạo kèm mã định danh KHxxxxx vừa sinh tự động
     */
    KhachHang registerCustomer(String tenKh, String sdt, String email, String password);

    /**
     * Đăng nhập cổng thông tin khách hàng Customer Portal.
     * @param usernameOrSdtOrEmail Có thể là Email hoặc Số điện thoại đăng ký của khách
     * @param password Mật khẩu gốc nhập từ form đăng nhập (sẽ được băm SHA-256 để so khớp)
     * @return Đối tượng KhachHang nếu đăng nhập thành công, ngược lại trả về null
     */
    KhachHang loginCustomer(String usernameOrSdtOrEmail, String password);

    /**
     * Gửi mã OTP kích hoạt tài khoản về email khách hàng khi đăng ký mới.
     * @param email Email khách hàng
     * @return true nếu gửi thành công qua SMTP Server của Google
     */
    boolean sendActivationOTP(String email);

    /**
     * Xác minh mã OTP kích hoạt tài khoản.
     * Nghiệp vụ: Mã OTP hợp lệ phải trùng khớp và nằm trong thời gian hiệu lực đếm ngược đúng 5 phút [12].
     * Nếu đúng, tiến hành cập nhật trạng thái hoạt động của khách hàng (trang_thai = true).
     * @param email Email của khách hàng cần kích hoạt
     * @param otp Mã OTP 6 chữ số do khách hàng nhập vào
     * @return true nếu kích hoạt tài khoản thành công
     */
    boolean verifyActivationOTP(String email, String otp);

    /**
     * Gửi mã OTP khôi phục mật khẩu (Quên mật khẩu) cho khách hàng [11].
     * @param email Email đăng ký tài khoản cần khôi phục
     * @return true nếu tìm thấy email trong hệ thống và đã gửi OTP thành công
     */
    boolean sendForgotPasswordOTP(String email);

    /**
     * Xác minh OTP và cập nhật mật khẩu mới (Reset Password) cho khách hàng.
     * @param email Email yêu cầu khôi phục
     * @param otp Mã OTP xác thực gửi qua Email
     * @param newPassword Mật khẩu mới chưa mã hóa (hệ thống sẽ tự động băm SHA-256 trước khi lưu)
     * @return true nếu cập nhật mật khẩu mới thành công
     */
    boolean resetPasswordWithOTP(String email, String otp, String newPassword);

    /**
     * Cập nhật thông tin hồ sơ cá nhân của khách hàng.
     */
    boolean updateCustomerProfile(KhachHang khachHang);

    /**
     * Cộng hoặc Trừ điểm tích lũy trong ví điểm CRM của khách hàng.
     * Quy tắc: Chỉ cho phép trừ điểm nếu số điểm khả dụng hiện tại lớn hơn hoặc bằng số điểm cần trừ.
     * @param maKh Mã khách hàng cần thao tác
     * @param diem Số điểm cần biến động
     * @param isCong true để cộng điểm, false để trừ điểm
     * @return true nếu biến động điểm thành công và cập nhật hạng thẻ tương ứng
     */
    boolean updateDiemTichLuy(String maKh, int diem, boolean isCong);
}