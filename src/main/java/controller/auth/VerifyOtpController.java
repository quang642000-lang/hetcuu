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

@WebServlet(name = "VerifyOtpController", urlPatterns = {"/verify-otp", "/resend-otp"})
public class VerifyOtpController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        // LUỒNG NGHIỆP VỤ: GỬI LẠI MÃ OTP (RESEND OTP) QUA LỜI GỌI AJAX KHÔNG LOAD LẠI TRANG
        if (uri.endsWith("/resend-otp")) {
            if (session != null && session.getAttribute("otpEmail") != null) {
                String email = (String) session.getAttribute("otpEmail");
                String type = (String) session.getAttribute("otpType");

                boolean sent = false;
                if ("activation".equals(type)) {
                    sent = khachHangService.sendActivationOTP(email);
                } else if ("recovery".equals(type)) {
                    sent = khachHangService.sendForgotPasswordOTP(email);
                }

                if (sent) {
                    response.getWriter().write("SUCCESS");
                } else {
                    response.getWriter().write("FAILED");
                }
            } else {
                response.getWriter().write("SESSION_EXPIRED");
            }
            return;
        }

        // LUỒNG NGHIỆP VỤ: HIỂN THỊ GIAO DIỆN NHẬP OTP BÌNH THƯỜNG
        String type = request.getParameter("type");
        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        request.setAttribute("type", type);
        request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("otpEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");
        String type = (String) session.getAttribute("otpType");

        // Nhận diện mã OTP 6 ô từ giao diện nhập liệu Figma chuyên nghiệp [8]
        StringBuilder otpBuilder = new StringBuilder();
        for (int i = 1; i <= 6; i++) {
            String digit = request.getParameter("otp" + i);
            if (digit != null) {
                otpBuilder.append(digit.trim());
            }
        }
        String otp = otpBuilder.toString();

        if (otp.length() < 6) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ mã OTP gồm 6 chữ số.");
            request.setAttribute("type", type);
            request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        if ("activation".equals(type)) {
            // LUỒNG 1: XÁC THỰC KÍCH HOẠT TÀI KHOẢN KHÁCH HÀNG MỚI ĐĂNG KÝ [6]
            boolean verified = khachHangService.verifyActivationOTP(email, otp);
            if (verified) {
                // Kích hoạt tài khoản thành công -> Dọn dẹp session OTP lâm thời
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");

                request.setAttribute("success", "Tài khoản của bạn đã được kích hoạt thành công! Hãy đăng nhập ngay.");
                request.getRequestDispatcher("/views/auth/login-customer.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP kích hoạt không chính xác hoặc đã hết hiệu lực 5 phút.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
            }
        } else if ("recovery".equals(type)) {
            // LUỒNG 2: KHÔI PHỤC ĐẶT LẠI MẬT KHẨU MỚI (QUÊN MẬT KHẨU) [8]
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.trim().isEmpty() || confirmPassword == null || confirmPassword.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng điền đầy đủ Mật khẩu mới và Xác nhận mật khẩu mới.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu nhập lại không khớp với mật khẩu mới.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            // Gọi dịch vụ đặt lại mật khẩu (Service sẽ thực hiện băm SHA-256 nội bộ trước khi lưu CSDL)
            boolean updated = khachHangService.resetPasswordWithOTP(email, otp, newPassword);
            if (updated) {
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");

                request.setAttribute("success", "Đặt lại mật khẩu thành công! Hãy sử dụng mật khẩu mới để đăng nhập.");
                request.getRequestDispatcher("/views/auth/login-customer.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã OTP khôi phục không chính xác, đã hết hạn hoặc không khớp.");
                request.setAttribute("type", type);
                request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
            }
        }
    }
}
