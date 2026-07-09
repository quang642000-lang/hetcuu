package filter;

import model.entity.KhachHang;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "PortalAuthFilter", urlPatterns = { "/portal/*", "/cart", "/checkout", "/profile" })
public class PortalAuthFilter implements Filter {

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

        boolean customerLoggedIn = false;

        if (session != null) {
            // Lấy thông tin khách hàng đang lưu trữ trong session
            KhachHang khachHang = (KhachHang) session.getAttribute("currentCustomer");
            if (khachHang != null) {
                customerLoggedIn = true;
            }
        }

        if (customerLoggedIn) {
            // Khách đã đăng nhập thành công, cho phép tiếp tục thao tác
            chain.doFilter(request, response);
        } else {
            // Khách vãng lai, chuyển hướng sang trang đăng nhập của khách hàng portal
            session = httpRequest.getSession();
            session.setAttribute("errorMessage", "Vui lòng đăng nhập tài khoản thành viên để thực hiện chức năng này.");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/auth/login-customer");
        }
    }

    @Override
    public void destroy() {
        // Dọn dẹp tài nguyên
    }
}