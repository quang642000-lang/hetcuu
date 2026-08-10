package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.entity.NhanVien;
import model.entity.KhachHang;


public class WebUtil {

    private WebUtil() {}

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

    public static int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        return parseIntSafe(request.getParameter(paramName), defaultValue);
    }

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
