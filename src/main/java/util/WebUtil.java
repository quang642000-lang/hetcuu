package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.entity.NhanVien;
import model.entity.KhachHang;

/**
 * =========================================================================
 * TEA POS SYSTEM - CENTRALIZED WEB & PARSING UTILITIES
 * Eliminates duplicate parameter parsing and session audit code across all Controllers.
 * =========================================================================
 */
public class WebUtil {

    private WebUtil() {}

    /**
     * Parse an integer value safely from a string. Fallbacks to default if format is invalid.
     * @param value Chuỗi ký tự số thô
     * @param defaultValue Mốc giá trị dự phòng
     * @return int
     */
    public static int parseIntSafe(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Lấy tham số kiểu int an toàn trực tiếp từ HttpServletRequest
     * @param request Servlet Request
     * @param paramName Tên tham số cần lấy
     * @param defaultValue Giá trị dự phòng
     * @return int
     */
    public static int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        return parseIntSafe(request.getParameter(paramName), defaultValue);
    }

    /**
     * Trích xuất an toàn mã nhân viên đang thao tác hệ thống từ Session JSTL
     * @param request Servlet Request
     * @return Mã nhân viên (ví dụ: NV00001) hoặc "SYSTEM" nếu không tìm thấy phiên làm việc
     */
    public static String getCurrentActor(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object userObj = session.getAttribute("user");
            if (userObj instanceof NhanVien) {
                return ((NhanVien) userObj).getMaNv();
            }
        }
        return "SYSTEM";
    }

    /**
     * Trích xuất an toàn khách hàng CRM đang hoạt động từ Session JSTL
     * @param request Servlet Request
     * @return Đối tượng KhachHang hoặc null nếu chưa đăng nhập
     */
    public static KhachHang getCurrentCustomer(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object customerObj = session.getAttribute("customer");
            if (customerObj instanceof KhachHang) {
                return (KhachHang) customerObj;
            }
        }
        return null;
    }

    /**
     * Lấy chính xác địa chỉ IP của Client truy cập, hỗ trợ bẫy lỗi các tầng Proxy/Load Balancer
     * @param request Servlet Request
     * @return Địa chỉ IP (IPv4 / IPv6)
     */
    public static String getRemoteIP(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        if ("0:0:0:0:0:0:0:1".equals(ip)) {
            return "127.0.0.1"; // Chuẩn hóa mốc Localhost IPv6
        }
        return ip;
    }
}
