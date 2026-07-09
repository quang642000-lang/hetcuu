package controller.auth;

import model.entity.KhachHang;
import model.entity.NhanVien;
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

@WebServlet(name = "LoginController", urlPatterns = {"/login", "/customer/login", "/logout"})
public class LoginController extends HttpServlet {
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        // Nghiệp vụ đăng xuất (Logout) hệ thống
        if (uri.endsWith("/logout")) {
            if (session != null) {
                session.invalidate(); // Hủy toàn bộ Session hiện tại
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Điều phối hiển thị giao diện đăng nhập tương ứng
        if (uri.endsWith("/customer/login")) {
            // Sửa gạch ngang (-) thành gạch dưới (_)
            request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
        } else {
            // Sửa login-staff.jsp thành login_admin.jsp cho đúng file của nhóm
            request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
        }}
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(true);

        if (uri.endsWith("/customer/login")) {
            // LUỒNG NGHIỆP VỤ: ĐĂNG NHẬP KHÁCH HÀNG (CUSTOMER PORTAL)
            String username = request.getParameter("username"); // Có thể nhập số điện thoại hoặc email [1]
            String password = request.getParameter("password");

            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Email/Số điện thoại và mật khẩu không được trống.");
                request.getRequestDispatcher("/views/auth/login-customer.jsp").forward(request, response);
                return;
            }

            KhachHang kh = khachHangService.loginCustomer(username, password);
            if (kh != null) {
                // Đăng nhập thành công -> Lưu thông tin vào Session và đưa về trang chủ Portal
                session.setAttribute("customer", kh);
                response.sendRedirect(request.getContextPath() + "/trang_chu");
            } else {
                request.setAttribute("error", "Tài khoản, mật khẩu không chính xác hoặc chưa được kích hoạt OTP.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/views/auth/login-customer.jsp").forward(request, response);
            }
        } else {
            // LUỒNG NGHIỆP VỤ: ĐĂNG NHẬP NHÂN VIÊN (STAFF POS / ADMIN SYSTEM)
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String ipAddress = request.getRemoteAddr(); // Trích xuất địa chỉ IP của client để lưu log [4]

            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Tên đăng nhập và mật khẩu không được trống.");
                request.getRequestDispatcher("/views/auth/login-staff.jsp").forward(request, response);
                return;
            }

            // ĐỐI SOÁT BẢO MẬT: Kiểm tra xem tài khoản có đang bị khóa tạm thời do gõ sai hay không
            if (nhanVienService.isAccountLocked(username)) {
                long remainTime = nhanVienService.getRemainingLockTime(username);
                request.setAttribute("error", "Tài khoản tạm thời bị khóa. Vui lòng thử lại sau " + remainTime + " giây.");
                request.getRequestDispatcher("/views/auth/login-staff.jsp").forward(request, response);
                return;
            }

            NhanVien nv = nhanVienService.loginNhanVien(username, password, ipAddress);
            if (nv != null) {
                session.setAttribute("user", nv);
                if (nv.getMaVt() == 1) { // 1: VAI TRÒ ADMIN [5]
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else { // 2: VAI TRÒ STAFF / CASHIER [5]
                    response.sendRedirect(request.getContextPath() + "/pos");
                }
            } else {
                // Trường hợp đăng nhập thất bại -> Kiểm tra xem tài khoản có vừa bị khóa hay không
                if (nhanVienService.isAccountLocked(username)) {
                    request.setAttribute("error", "Tài khoản của bạn đã bị khóa tạm thời 5 phút do nhập sai mật khẩu liên tiếp 5 lần.");
                } else {
                    request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác.");
                }
                request.setAttribute("username", username);
                request.getRequestDispatcher("/views/auth/login-staff.jsp").forward(request, response);
            }
        }
    }
}
