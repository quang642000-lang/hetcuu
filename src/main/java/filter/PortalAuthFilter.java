package filter;

import model.entity.KhachHang;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "PortalAuthFilter", urlPatterns = { "/portal/*", "/cart", "/checkout", "/profile" })
public class PortalAuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean customerLoggedIn = false;
        if (session != null) {
            KhachHang khachHang = (KhachHang) session.getAttribute("customer"); // Đã đồng bộ Key "customer"
            if (khachHang != null) {
                customerLoggedIn = true;
            }
        }

        if (customerLoggedIn) {
            chain.doFilter(request, response);
        } else {
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Vui lòng đăng nhập tài khoản thành viên để thực hiện.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/customer/login");
        }
    }

    @Override
    public void destroy() {}
}