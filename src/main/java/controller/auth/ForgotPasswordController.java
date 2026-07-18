package controller.auth;

import service.IKhachHangService;
import service.INhanVienService;
import service.impl.KhachHangServiceImpl;
import service.impl.NhanVienServiceImpl;
import model.entity.KhachHang;
import model.entity.NhanVien;
import util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password", "/reset-password"})
public class ForgotPasswordController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        if (uri.endsWith("/reset-password")) {
            if (session == null || session.getAttribute("otpVerified") == null || !(Boolean) session.getAttribute("otpVerified")) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }
            request.getRequestDispatcher("/views/auth/reset_password.jsp").forward(request, response);
            return;
        }

        // forgot-password view routing
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "customer"; // Mặc định là khách hàng
        }

        request.setAttribute("role", role);
        if ("employee".equals(role)) {
            request.getRequestDispatcher("/views/auth/forgot_password_admin.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/auth/forgot_password_customer.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(true);

        if (uri.endsWith("/reset-password")) {
            if (session == null || session.getAttribute("otpVerified") == null || !(Boolean) session.getAttribute("otpVerified")) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }

            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.trim().isEmpty() || confirmPassword == null || confirmPassword.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập mật khẩu mới đầy đủ!");
                request.getRequestDispatcher("/views/auth/reset_password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Xác nhận mật khẩu mới không trùng khớp!");
                request.getRequestDispatcher("/views/auth/reset_password.jsp").forward(request, response);
                return;
            }

            if (newPassword.length() < 8) {
                request.setAttribute("error", "Mật khẩu mới bắt buộc phải chứa tối thiểu từ 8 ký tự!");
                request.getRequestDispatcher("/views/auth/reset_password.jsp").forward(request, response);
                return;
            }

            String email = (String) session.getAttribute("otpEmail");
            String role = (String) session.getAttribute("otpRole");
            boolean success = false;

            if ("employee".equals(role)) {
                NhanVien nv = nhanVienService.getNhanVienByEmail(email);
                if (nv != null) {
                    // resetPasswordByAdmin hashes internally
                    success = nhanVienService.resetPasswordByAdmin(nv.getMaNv(), newPassword);
                }
            } else {
                KhachHang kh = khachHangService.getKhachHangByEmail(email);
                if (kh != null) {
                    success = khachHangService.updateMatKhau(kh.getMaKh(), SecurityUtil.hashSHA256(newPassword));
                }
            }

            if (success) {
                session.removeAttribute("otpEmail");
                session.removeAttribute("otpType");
                session.removeAttribute("otpRole");
                session.removeAttribute("otpVerified");

                request.setAttribute("success", "Khôi phục mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.");
                if ("employee".equals(role)) {
                    request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Cập nhật mật khẩu thất bại. Vui lòng liên hệ quản trị hệ thống!");
                request.getRequestDispatcher("/views/auth/reset_password.jsp").forward(request, response);
            }
            return;
        }

        // POST /forgot-password
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "customer";
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập địa chỉ Email đăng ký tài khoản.");
            request.setAttribute("role", role);
            if ("employee".equals(role)) {
                request.getRequestDispatcher("/views/auth/forgot_password_admin.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/views/auth/forgot_password_customer.jsp").forward(request, response);
            }
            return;
        }

        boolean sent = false;
        if ("employee".equals(role)) {
            sent = nhanVienService.sendForgotPasswordOTP(email.trim());
        } else {
            sent = khachHangService.sendForgotPasswordOTP(email.trim());
        }

        if (sent) {
            session.setAttribute("otpEmail", email.trim());
            session.setAttribute("otpType", "recovery");
            session.setAttribute("otpRole", role);
            response.sendRedirect(request.getContextPath() + "/verify-otp?type=recovery&role=" + role);
        } else {
            request.setAttribute("error", "Email này không tồn tại trong hệ thống hoặc tài khoản đang bị tạm khóa.");
            request.setAttribute("email", email);
            request.setAttribute("role", role);
            if ("employee".equals(role)) {
                request.getRequestDispatcher("/views/auth/forgot_password_admin.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/views/auth/forgot_password_customer.jsp").forward(request, response);
            }
        }
    }
}
