package filter;

import model.entity.NhanVien;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "POSAuthFilter", urlPatterns = "/pos/*")
public class POSAuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        boolean loggedIn = false;
        boolean hasAccess = false;

        if (session != null) {
            Object userObj = session.getAttribute("user");
            if (userObj instanceof NhanVien) {
                NhanVien nhanVien = (NhanVien) userObj;
                loggedIn = true;
                if (nhanVien.getMaVt() == 1 || nhanVien.getMaVt() == 2) { // Quản lý hoặc Thu ngân
                    hasAccess = true;
                }
            }
        }

        if (loggedIn && hasAccess) {
            chain.doFilter(request, response);
        } else {
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản thu ngân hoặc quản lý để vào POS.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {}
}