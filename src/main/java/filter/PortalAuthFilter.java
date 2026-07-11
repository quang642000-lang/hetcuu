package filter;

import model.entity.KhachHang;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// SỬA LỖI: Thêm /* vào sau các pattern để lọc toàn bộ các API con (AJAX) của giỏ hàng và thanh toán
@WebFilter(filterName = "PortalAuthFilter", urlPatterns = {
        "/portal/*",
        "/cart", "/cart/*",
        "/checkout", "/checkout/*",
        "/profile", "/profile/*",
        "/portal/order/*"
})
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
            KhachHang khachHang = (KhachHang) session.getAttribute("customer"); // Đồng bộ key "customer" [5]
            if (khachHang != null) {
                customerLoggedIn = true;
            }
        }

        if (customerLoggedIn) {
            chain.doFilter(request, response);
        } else {
            // Nhận diện nếu là cuộc gọi AJAX (X-Requested-With) hoặc gọi fetch từ JS
            String requestedWith = httpRequest.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(requestedWith)
                    || httpRequest.getRequestURI().contains("/update")
                    || httpRequest.getRequestURI().contains("/toggle-select");

            if (isAjax) {
                // Nếu là AJAX, trả về mã 401 kèm chuỗi ngắn gọn để JS xử lý hiển thị SweetAlert2 mượt mà
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.getWriter().write("SESSION_EXPIRED");
            } else {
                // Nếu là điều hướng trang vật lý, đưa về trang đăng nhập của khách hàng
                session = httpRequest.getSession();
                session.setAttribute("errorMessage", "Phiên đăng nhập đã hết hạn! Vui lòng đăng nhập tài khoản thành viên để tiếp tục.");
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/customer/login"); // [5]
            }
        }
    }

    @Override
    public void destroy() {}
}