package filter;

import model.entity.NhanVien;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AdminAuthFilter", urlPatterns = "/admin/*")
public class AdminAuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        boolean loggedIn = false;
        boolean isAdmin = false;

        if (session != null) {
            Object userObj = session.getAttribute("user");
            if (userObj instanceof NhanVien) {
                NhanVien nhanVien = (NhanVien) userObj;
                loggedIn = true;
                if (nhanVien.getMaVt() == 1) { // 1: Admin
                    isAdmin = true;
                }
            }
        }

        if (loggedIn && isAdmin) {
            chain.doFilter(request, response);
        } else {
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Yêu cầu quyền quản trị viên! Vui lòng đăng nhập lại.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {}
}