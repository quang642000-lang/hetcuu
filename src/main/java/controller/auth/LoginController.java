package controller.auth;

import model.entity.KhachHang;
import model.entity.NhanVien;
import model.entity.GioHang;
import service.IKhachHangService;
import service.INhanVienService;
import service.IGioHangService;
import service.impl.KhachHangServiceImpl;
import service.impl.NhanVienServiceImpl;
import service.impl.GioHangServiceImpl;
import repository.impl.NhatKyRepoImpl;

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
    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        // Nghiệp vụ Đăng xuất
        if (uri.endsWith("/logout")) {
            if (session != null) {
                NhanVien nv = (NhanVien) session.getAttribute("user");
                if (nv != null) {
                    // GHI NHẬN NHẬT KÝ ĐĂNG XUẤT CỦA NHÂN VIÊN
                    NhatKyRepoImpl.recordActivity(
                            nv.getMaNv(),
                            "LOGOUT",
                            "NHAN_VIEN",
                            nv.getMaNv(),
                            "Đăng nhập",
                            "Nhân viên đăng xuất rời hệ thống",
                            request.getRemoteAddr()
                    );
                }
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (uri.endsWith("/customer/login")) {
            request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(true);

        if (uri.endsWith("/customer/login")) {
            // ĐĂNG NHẬP KHÁCH HÀNG CRM (Không ghi nhận nhật ký của khách hàng để tránh dư thừa dữ liệu)
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Email/Số điện thoại và mật khẩu không được trống.");
                request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
                return;
            }

            KhachHang kh = khachHangService.loginCustomer(username, password);
            if (kh != null) {
                session.setAttribute("customer", kh);
                GioHang gh = gioHangService.getGioHangComplete(kh.getMaKh());
                int cartCount = (gh != null && gh.getChiTietGioHangList() != null) ? gh.getChiTietGioHangList().size() : 0;
                session.setAttribute("customerCartCount", cartCount);
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                request.setAttribute("error", "Tài khoản, mật khẩu không chính xác hoặc chưa được kích hoạt OTP.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/views/auth/login_customer.jsp").forward(request, response);
            }
        } else {
            // ĐĂNG NHẬP NHÂN VIÊN STAFF / QUẢN LÝ ADMIN
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String ipAddress = request.getRemoteAddr();

            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("error", "Tên đăng nhập và mật khẩu không được trống.");
                request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
                return;
            }

            if (nhanVienService.isAccountLocked(username)) {
                long remainTime = nhanVienService.getRemainingLockTime(username);
                request.setAttribute("error", "Tài khoản bị tạm khóa. Vui lòng thử lại sau " + remainTime + " giây.");
                request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
                return;
            }

            NhanVien nv = nhanVienService.loginNhanVien(username, password, ipAddress);
            if (nv != null) {
                session.setAttribute("user", nv);

                // GHI NHẬN NHẬT KÝ ĐĂNG NHẬP THÀNH CÔNG CỦA NHÂN VIÊN
                NhatKyRepoImpl.recordActivity(
                        nv.getMaNv(),
                        "LOGIN",
                        "NHAN_VIEN",
                        nv.getMaNv(),
                        null,
                        "Nhân viên '" + nv.getHoTen() + "' đăng nhập hệ thống thành công.",
                        ipAddress
                );

                if (nv.getMaVt() == 1) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/pos");
                }
            } else {
                if (nhanVienService.isAccountLocked(username)) {
                    request.setAttribute("error", "Tài khoản đã bị khóa tạm thời 5 phút do nhập sai mật khẩu liên tiếp 5 lần.");
                } else {
                    request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác.");
                }
                request.setAttribute("username", username);
                request.getRequestDispatcher("/views/auth/login_admin.jsp").forward(request, response);
            }
        }
    }
}
