package controller.auth;

import model.entity.KhachHang;
import service.IKhachHangService;
import service.impl.KhachHangServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tenKh = request.getParameter("tenKh");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String dongYDieuKhoan = request.getParameter("dongYDieuKhoan"); // Trạng thái checkbox đồng ý điều khoản [6]

        // 1. Kiểm tra tính toàn vẹn của dữ liệu nhập (Validation)
        if (tenKh == null || tenKh.trim().isEmpty() ||
                sdt == null || sdt.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin vào tất cả các trường dữ liệu đăng ký.");
            keepFormValues(request, tenKh, sdt, email);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 2. Kiểm tra tính trùng khớp của Mật khẩu xác nhận
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu nhập lại không trùng khớp với mật khẩu ban đầu.");
            keepFormValues(request, tenKh, sdt, email);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra bắt buộc tick chọn Điều khoản dịch vụ
        if (dongYDieuKhoan == null) {
            request.setAttribute("error", "Bạn bắt buộc phải tick chọn đồng ý với điều khoản sử dụng hệ thống.");
            keepFormValues(request, tenKh, sdt, email);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 4. Gọi Service tạo tài khoản khách hàng mới dưới dạng "Chờ kích hoạt OTP"
        KhachHang kh = khachHangService.registerCustomer(tenKh, sdt, email, password);
        if (kh != null) {
            // Đăng ký bước đầu thành công -> Đưa email đăng ký vào Session để bảo mật và gửi sang màn hình kích hoạt OTP
            HttpSession session = request.getSession(true);
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpType", "activation");

            // Chuyển hướng sang màn hình nhập mã OTP kích hoạt tài khoản [6]
            response.sendRedirect(request.getContextPath() + "/verify-otp?type=activation");
        } else {
            request.setAttribute("error", "Đăng ký không thành công. Số điện thoại hoặc Email này đã tồn tại trong hệ thống.");
            keepFormValues(request, tenKh, sdt, email);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }

    private void keepFormValues(HttpServletRequest request, String tenKh, String sdt, String email) {
        request.setAttribute("tenKh", tenKh);
        request.setAttribute("soDienThoai", sdt);
        request.setAttribute("email", email);
    }
}
