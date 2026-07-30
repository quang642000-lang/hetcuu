package filter;

import model.entity.NhanVien;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * =========================================================================
 * TEA POS SYSTEM - POS SECURITY & AUTHENTICATION FILTER (AJAX COMPATIBLE)
 * Prevent unauthorized access and elegantly handle expired sessions with
 * clean JSON status code for Ajax fetch calls to prevent Syntax HTML Errors.
 * =========================================================================
 */
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
            // KIỂM TRA ĐẦU VÀO AJAX Giao diện quầy POS
            String requestedWith = httpRequest.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(requestedWith)
                    || httpRequest.getRequestURI().contains("/search-customer")
                    || httpRequest.getRequestURI().contains("/bill-detail")
                    || httpRequest.getRequestURI().contains("/checkout")
                    || httpRequest.getRequestURI().contains("/create-customer")
                    || httpRequest.getRequestURI().contains("/apply-voucher");

            if (isAjax) {
                // Trả về mã lỗi 401 JSON gọn nhẹ giúp JS quầy bắt lỗi và đẩy thông báo SweetAlert2 mượt mà
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json");
                httpResponse.setCharacterEncoding("UTF-8");
                httpResponse.getWriter().write("{\"status\":\"SESSION_EXPIRED\", \"message\":\"Phiên đăng nhập quầy POS đã hết hạn! Vui lòng đăng nhập lại.\"}");
            } else {
                // Nếu gọi liên kết trang tĩnh vật lý, forward bình thường sang màn hình login gốc
                session = httpRequest.getSession();
                session.setAttribute("errorMessage", "Vui lòng đăng nhập bằng tài khoản thu ngân hoặc quản lý để vào POS.");
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            }
        }
    }

    @Override
    public void destroy() {}
}
