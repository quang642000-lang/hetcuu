package controller.auth;

import service.IKhachHangService;
import service.impl.KhachHangServiceImpl;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ Email đăng ký tài khoản của bạn.");
            request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
            return;
        }

        boolean sent = khachHangService.sendForgotPasswordOTP(email.trim());
        if (sent) {
            HttpSession session = request.getSession(true);
            session.setAttribute("otpEmail", email.trim());
            session.setAttribute("otpType", "recovery");
            response.sendRedirect(request.getContextPath() + "/verify-otp?type=recovery");
        } else {
            request.setAttribute("error", "Email này không tồn tại trong hệ thống hoặc tài khoản đang bị tạm khóa.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/auth/forgot_password.jsp").forward(request, response);
        }
    }
}
