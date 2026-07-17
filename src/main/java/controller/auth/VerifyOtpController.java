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

@WebServlet(name = "VerifyOtpController", urlPatterns = {"/verify-otp"})
public class VerifyOtpController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");

        // AJAX resend OTP without reloading page
        if ("resend-otp".equals(action)) {
            response.setContentType("text/plain");
            boolean success = false;
            String otpType = (String) session.getAttribute("otpType");
            if ("recovery".equals(otpType)) {
                success = khachHangService.sendForgotPasswordOTP(email);
            } else {
                success = khachHangService.sendActivationOTP(email);
            }
            response.getWriter().write(success ? "SUCCESS" : "FAILED");
            return;
        }

        request.setAttribute("type", type != null ? type : "activation");
        request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");
        String type = request.getParameter("type");

        // Assemble OTP 6 digits from form fields
        StringBuilder otpBuilder = new StringBuilder();
        for (int i = 1; i <= 6; i++) {
            String digit = request.getParameter("otp" + i);
            if (digit != null) otpBuilder.append(digit.trim());
        }
        String otp = otpBuilder.toString();

        if (otp.length() < 6) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ mã xác thực gồm 6 chữ số.");
            request.setAttribute("type", type);
            request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if ("recovery".equals(type)) {
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.trim().isEmpty()) {
                request.setAttribute("error", "Mật khẩu mới không được để trống!");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Xác nhận mật khẩu mới không trùng khớp!");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
                return;
            }

            boolean success = khachHangService.resetPasswordWithOTP(email, otp, newPassword);
            if (success) {
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");
                request.setAttribute("success", "Khôi phục mật khẩu thành công! Vui lòng đăng nhập.");
                request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP khôi phục không chính xác hoặc đã hết hiệu lực.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            }
        } else {
            // Account Activation OTP
            boolean success = khachHangService.verifyActivationOTP(email, otp);
            if (success) {
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");
                request.setAttribute("success", "Kích hoạt tài khoản thành công! Quý khách đã có thể đăng nhập.");
                request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP kích hoạt không chính xác hoặc đã hết hiệu lực.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            }
        }
    }
}
