package filter;

import model.entity.NhanVien;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "POSAuthFilter", urlPatterns = "/pos/*")
public class POSAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần cấu hình
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean loggedIn = false;
        boolean hasAccess = false;

        if (session != null) {
            NhanVien nhanVien = (NhanVien) session.getAttribute("currentUser");
            if (nhanVien != null) {
                loggedIn = true;
                // Cho phép Admin (ma_vt = 1) và Thu ngân (ma_vt = 2) [2-4]
                if (nhanVien.getMaVt() == 1 || nhanVien.getMaVt() == 2) {
                    hasAccess = true;
                }
            }
        }

        if (loggedIn && hasAccess) {
            chain.doFilter(request, response);
        } else {
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản thu ngân hoặc quản lý để vào quầy POS.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login-admin");
        }
    }

    @Override
    public void destroy() {
        // Dọn dẹp tài nguyên
    }
}
