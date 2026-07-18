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

@WebServlet(name = "VerifyOtpController", urlPatterns = {"/verify-otp"})
public class VerifyOtpController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        String role = request.getParameter("role");
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");

        // Gửi lại mã OTP qua AJAX
        if ("resend-otp".equals(action)) {
            response.setContentType("text/plain");
            boolean success = false;
            String otpType = (String) session.getAttribute("otpType");
            String otpRole = (String) session.getAttribute("otpRole");
            if ("recovery".equals(otpType)) {
                if ("employee".equals(otpRole)) {
                    success = nhanVienService.sendForgotPasswordOTP(email);
                } else {
                    success = khachHangService.sendForgotPasswordOTP(email);
                }
            } else {
                success = khachHangService.sendActivationOTP(email);
            }
            response.getWriter().write(success ? "SUCCESS" : "FAILED");
            return;
        }

        request.setAttribute("type", type != null ? type : "activation");
        request.setAttribute("role", role != null ? role : "customer");
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
        String role = request.getParameter("role");

        if (role == null) {
            role = (String) session.getAttribute("otpRole");
        }

        // Gom mảng mã OTP
        StringBuilder otpBuilder = new StringBuilder();
        for (int i = 1; i <= 6; i++) {
            String digit = request.getParameter("otp" + i);
            if (digit != null) otpBuilder.append(digit.trim());
        }
        String otp = otpBuilder.toString();

        if (otp.length() < 6) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ mã xác thực gồm 6 chữ số.");
            request.setAttribute("type", type);
            request.setAttribute("role", role);
            request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            return;
        }

        if ("recovery".equals(type)) {
            boolean success = false;
            if ("employee".equals(role)) {
                success = nhanVienService.verifyForgotPasswordOTP(email, otp);
            } else {
                success = khachHangService.verifyForgotPasswordOTP(email, otp);
            }

            if (success) {
                // Set session verified, then redirect to reset-password screen
                session.setAttribute("otpVerified", true);
                session.setAttribute("otpEmail", email);
                session.setAttribute("otpRole", role);
                response.sendRedirect(request.getContextPath() + "/reset-password");
            } else {
                request.setAttribute("error", "Mã OTP khôi phục không chính xác hoặc đã hết hiệu lực.");
                request.setAttribute("type", type);
                request.setAttribute("role", role);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            }
        } else {
            // Xác thực kích hoạt tài khoản CRM khách hàng mới (activation)
            boolean success = khachHangService.verifyActivationOTP(email, otp);
            if (success) {
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");
                session.removeAttribute("otpRole");
                request.setAttribute("success", "Kích hoạt tài khoản CRM thành công! Bạn có thể đăng nhập ngay.");
                request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP kích hoạt không chính xác hoặc đã hết hiệu lực.");
                request.setAttribute("type", type);
                request.setAttribute("role", role);
                request.getRequestDispatcher("/views/auth/verify_otp.jsp").forward(request, response);
            }
        }
    }
}
