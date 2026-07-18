package controller.auth;

import service.IKhachHangService;
import service.INhanVienService;
import service.impl.KhachHangServiceImpl;
import service.impl.NhanVienServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "customer"; // Mặc định là khách hàng
        }
        request.setAttribute("role", role);
        request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "customer";
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ Email đăng ký tài khoản.");
            request.setAttribute("role", role);
            request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
            return;
        }

        boolean sent = false;
        // PHÂN BIỆT NHÂN VIÊN VÀ KHÁCH HÀNG CRM TRỰC TIẾP
        if ("employee".equals(role)) {
            sent = nhanVienService.sendForgotPasswordOTP(email.trim());
        } else {
            sent = khachHangService.sendForgotPasswordOTP(email.trim());
        }

        if (sent) {
            HttpSession session = request.getSession(true);
            session.setAttribute("otpEmail", email.trim());
            session.setAttribute("otpType", "recovery");
            session.setAttribute("otpRole", role); // Lưu vết vai trò khôi phục mật khẩu vào session
            response.sendRedirect(request.getContextPath() + "/verify-otp?type=recovery&role=" + role);
        } else {
            request.setAttribute("error", "Email này không tồn tại trong hệ thống hoặc tài khoản đang bị tạm khóa.");
            request.setAttribute("email", email);
            request.setAttribute("role", role);
            request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
        }
    }
}
