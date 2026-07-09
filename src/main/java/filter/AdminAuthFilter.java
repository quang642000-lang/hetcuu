package filter;

import model.entity.NhanVien;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AdminAuthFilter", urlPatterns = "/admin/*")
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần cấu hình khởi động
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean loggedIn = false;
        boolean isAdmin = false;

        if (session != null) {
            // Lấy thông tin tài khoản nhân viên đang lưu trữ trong session
            NhanVien nhanVien = (NhanVien) session.getAttribute("currentUser");
            if (nhanVien != null) {
                loggedIn = true;
                // Kiểm tra vai trò [2-4]: mã vai trò Admin = 1
                if (nhanVien.getMaVt() == 1) {
                    isAdmin = true;
                }
            }
        }

        if (loggedIn && isAdmin) {
            // Đủ điều kiện bảo mật, cho phép truy cập tiếp
            chain.doFilter(request, response);
        } else {
            // Chưa đăng nhập hoặc sai quyền hạn, điều hướng về trang đăng nhập của nhân viên
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Yêu cầu quyền quản trị viên! Vui lòng đăng nhập lại.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login-admin");
        }
    }

    @Override
    public void destroy() {
        // Dọn dẹp tài nguyên
    }
}
