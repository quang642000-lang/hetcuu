package controller.admin;

import model.entity.NhanVien;
import service.INhanVienService;
import service.impl.NhanVienServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminSettingController", urlPatterns = {"/admin/settings"})
public class AdminSettingController extends HttpServlet {
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        NhanVien currentAdmin = (NhanVien) session.getAttribute("user");
        // Nạp lại thông tin mới nhất từ database
        NhanVien freshAdmin = nhanVienService.getNhanVienById(currentAdmin.getMaNv());

        request.setAttribute("adminProfile", freshAdmin);
        request.getRequestDispatcher("/views/admin/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updateInfo".equals(action)) {
            performUpdateProfile(request, response);
        } else if ("changePassword".equals(action)) {
            performChangePassword(request, response);
        }
    }

    private void performUpdateProfile(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        NhanVien freshAdmin = (NhanVien) session.getAttribute("user");

        String hoTen = request.getParameter("hoTen");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String username = request.getParameter("tenDangNhap");

        freshAdmin.setHoTen(hoTen);
        freshAdmin.setSoDienThoai(sdt);
        freshAdmin.setEmail(email);
        freshAdmin.setTenDangNhap(username);

        boolean success = nhanVienService.updateNhanVien(freshAdmin);
        if (success) {
            session.setAttribute("user", freshAdmin); // Lưu trữ session mới
            response.sendRedirect(request.getContextPath() + "/admin/settings?msg=updatesuccess");
        } else {
            request.setAttribute("adminProfile", freshAdmin);
            request.setAttribute("errorProfile", "Cập nhật không thành công. Số điện thoại, Email hoặc Username đã tồn tại!");
            request.getRequestDispatcher("/views/admin/settings.jsp").forward(request, response);
        }
    }

    private void performChangePassword(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        NhanVien currentAdmin = (NhanVien) session.getAttribute("user");

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("errorPassword", "Mật khẩu mới và mật khẩu xác nhận không trùng khớp!");
            doGet(request, response);
            return;
        }

        boolean success = nhanVienService.changePassword(currentAdmin.getMaNv(), oldPassword, newPassword);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/settings?msg=passwordsuccess");
        } else {
            request.setAttribute("errorPassword", "Đổi mật khẩu thất bại. Mật khẩu cũ không chính xác!");
            doGet(request, response);
        }
    }
}