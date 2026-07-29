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

@WebServlet(name = "ActivateAccountController", urlPatterns = {"/activate", "/activate/verify", "/activate/password"})
public class ActivateAccountController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        if (uri.endsWith("/activate/password")) {
            if (session == null || session.getAttribute("otpVerified") == null || !(Boolean) session.getAttribute("otpVerified")) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }
            request.getRequestDispatcher("/views/auth/activate_password.jsp").forward(request, response);
            return;
        }

        if (uri.endsWith("/activate/verify")) {
            if (session == null || session.getAttribute("otpEmail") == null) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }
            request.getRequestDispatcher("/views/auth/activate_verify.jsp").forward(request, response);
            return;
        }

        // Mặc định: trang tìm kiếm thẻ / tài khoản để kích hoạt
        request.getRequestDispatcher("/views/auth/activate_account.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(true);

        if (uri.endsWith("/activate/password")) {
            if (session == null || session.getAttribute("otpVerified") == null || !(Boolean) session.getAttribute("otpVerified")) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }
            String password = request.getParameter("newPassword");
            String confirm = request.getParameter("confirmPassword");

            if (password == null || password.trim().isEmpty() || confirm == null || confirm.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập mật khẩu mới đầy đủ!");
                request.getRequestDispatcher("/views/auth/activate_password.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirm)) {
                request.setAttribute("error", "Xác nhận mật khẩu mới không trùng khớp!");
                request.getRequestDispatcher("/views/auth/activate_password.jsp").forward(request, response);
                return;
            }

            if (password.length() < 8) {
                request.setAttribute("error", "Mật khẩu bảo mật phải chứa tối thiểu từ 8 ký tự!");
                request.getRequestDispatcher("/views/auth/activate_password.jsp").forward(request, response);
                return;
            }

            String email = (String) session.getAttribute("otpEmail");
            KhachHang kh = khachHangService.getKhachHangByEmail(email);
            if (kh != null) {
                boolean success = khachHangService.resetPasswordWithOTP(email, (String) session.getAttribute("otpCode"), password);
                if (success) {
                    session.removeAttribute("otpEmail");
                    session.removeAttribute("otpCode");
                    session.removeAttribute("otpVerified");
                    request.setAttribute("success", "Kích hoạt tài khoản thành công! Bây giờ bạn có thể đăng nhập bằng mật khẩu vừa tạo.");
                    request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
                    return;
                }
            }
            request.setAttribute("error", "Kích hoạt mật khẩu thất bại. Vui lòng liên hệ quầy POS để được hỗ trợ!");
            request.getRequestDispatcher("/views/auth/activate_password.jsp").forward(request, response);
            return;
        }

        if (uri.endsWith("/activate/verify")) {
            if (session == null || session.getAttribute("otpEmail") == null) {
                response.sendRedirect(request.getContextPath() + "/customer/login");
                return;
            }
            String email = (String) session.getAttribute("otpEmail");
            StringBuilder otpBuilder = new StringBuilder();
            for (int i = 1; i <= 6; i++) {
                String digit = request.getParameter("otp" + i);
                if (digit != null) otpBuilder.append(digit.trim());
            }
            String otp = otpBuilder.toString();

            boolean success = khachHangService.verifyForgotPasswordOTP(email, otp);
            if (success) {
                session.setAttribute("otpVerified", true);
                session.setAttribute("otpCode", otp); // Lưu để gọi resetPasswordWithOTP
                response.sendRedirect(request.getContextPath() + "/activate/password");
            } else {
                request.setAttribute("error", "Mã xác thực OTP không chính xác hoặc đã hết hiệu lực!");
                request.getRequestDispatcher("/views/auth/activate_verify.jsp").forward(request, response);
            }
            return;
        }

        // POST /activate: Tìm kiếm SĐT/Email để gửi mã OTP kích hoạt
        String searchInput = request.getParameter("username"); // Số điện thoại hoặc Email
        if (searchInput == null || searchInput.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập Email hoặc Số điện thoại đăng ký tại quầy.");
            request.getRequestDispatcher("/views/auth/activate_account.jsp").forward(request, response);
            return;
        }

        KhachHang kh = khachHangService.getKhachHangBySdt(searchInput.trim());
        if (kh == null) {
            kh = khachHangService.getKhachHangByEmail(searchInput.trim());
        }

        if (kh == null) {
            request.setAttribute("error", "Không tìm thấy thông tin hội viên này trên hệ thống! Vui lòng kiểm tra lại.");
            request.getRequestDispatcher("/views/auth/activate_account.jsp").forward(request, response);
            return;
        }

        if (kh.getMatKhau() != null) {
            request.setAttribute("error", "Tài khoản hội viên này đã được kích hoạt từ trước! Vui lòng đăng nhập bình thường.");
            request.getRequestDispatcher("/views/auth/activate_account.jsp").forward(request, response);
            return;
        }

        // Gửi mã OTP khôi phục / kích hoạt mật khẩu về Email của khách hàng
        boolean sent = khachHangService.sendForgotPasswordOTP(kh.getEmail());
        if (sent) {
            session.setAttribute("otpEmail", kh.getEmail());
            session.setAttribute("otpType", "activation");
            session.setAttribute("otpRole", "customer");
            response.sendRedirect(request.getContextPath() + "/activate/verify");
        } else {
            request.setAttribute("error", "Hệ thống gặp sự cố khi gửi mã OTP! Vui lòng thử lại sau.");
            request.getRequestDispatcher("/views/auth/activate_account.jsp").forward(request, response);
        }
    }
}
