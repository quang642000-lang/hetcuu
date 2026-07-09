package controller.portal;

import model.entity.DonHang;
import model.entity.KhachHang;
import model.entity.KhuyenMai;
import service.IDonHangService;
import service.IKhachHangService;
import service.IKhuyenMaiService;
import service.impl.DonHangServiceImpl;
import service.impl.KhachHangServiceImpl;
import service.impl.KhuyenMaiServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "PortalProfileController", urlPatterns = {"/profile", "/profile/orders", "/profile/vouchers", "/profile/change-password"})
public class PortalProfileController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        // Đọc lại thông tin cá nhân CRM mới nhất từ cơ sở dữ liệu
        KhachHang freshCustomer = khachHangService.getKhachHangById(currentCustomer.getMaKh());
        session.setAttribute("customer", freshCustomer);

        String uri = request.getRequestURI();
        if (uri.endsWith("/profile/orders")) {
            // Tải lịch sử đơn hàng cá nhân tự đặt trước Click & Collect
            List<DonHang> myOrders = donHangService.getDonHangByKhachHang(freshCustomer.getMaKh());
            request.setAttribute("orders", myOrders);
            request.getRequestDispatcher("/views/portal/theo_doi_don.jsp").forward(request, response);
        } else if (uri.endsWith("/profile/vouchers")) {
            // Tải ví Voucher cá nhân tương thích theo mốc hạng thẻ
            List<KhuyenMai> myVouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(100000, freshCustomer.getMaKh());
            request.setAttribute("vouchers", myVouchers);
            request.getRequestDispatcher("/views/portal/kho_voucher.jsp").forward(request, response);
        } else {
            // Mặc định: Hiển thị giao diện sửa thông tin cá nhân
            request.setAttribute("customerProfile", freshCustomer);
            request.getRequestDispatcher("/views/portal/ho_so.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        String uri = request.getRequestURI();

        if (uri.endsWith("/profile/change-password")) {
            performChangePassword(request, response, currentCustomer.getMaKh());
        } else {
            performUpdateProfile(request, response, currentCustomer);
        }
    }

    private void performUpdateProfile(HttpServletRequest request, HttpServletResponse response, KhachHang kh) throws ServletException, IOException {
        String tenKh = request.getParameter("tenKh");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String gioiTinh = request.getParameter("gioiTinh");
        String diaChi = request.getParameter("diaChiLienHe");
        String ngaySinhStr = request.getParameter("ngaySinh");

        kh.setTenKh(tenKh);
        kh.setSoDienThoai(sdt);
        kh.setEmail(email);
        kh.setGioiTinh(gioiTinh);
        kh.setDiaChiLienHe(diaChi);

        if (ngaySinhStr != null && !ngaySinhStr.trim().isEmpty()) {
            kh.setNgaySinh(Date.valueOf(ngaySinhStr));
        }

        boolean success = khachHangService.updateCustomerProfile(kh);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/profile?msg=updatesuccess");
        } else {
            request.setAttribute("customerProfile", kh);
            request.setAttribute("error", "Lỗi: Số điện thoại hoặc Email đã được đăng ký ở tài khoản khác!");
            request.getRequestDispatcher("/views/portal/profile.jsp").forward(request, response);
        }
    }

    private void performChangePassword(HttpServletRequest request, HttpServletResponse response, String maKh) throws ServletException, IOException {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("errorPassword", "Xác nhận mật khẩu mới không trùng khớp!");
            doGet(request, response);
            return;
        }

        // Tái sử dụng nghiệp vụ cộng/trừ điểm hoặc các cơ chế cập nhật của Service để đổi mật khẩu
        KhachHang kh = khachHangService.getKhachHangById(maKh);
        if (kh != null) {
            String oldHashed = util.SecurityUtil.hashSHA256(oldPassword);
            if (kh.getMatKhau().equals(oldHashed)) {
                kh.setMatKhau(util.SecurityUtil.hashSHA256(newPassword));
                khachHangService.updateCustomerProfile(kh);
                response.sendRedirect(request.getContextPath() + "/profile?msg=passwordsuccess");
                return;
            }
        }

        request.setAttribute("errorPassword", "Mật khẩu cũ không chính xác!");
        doGet(request, response);
    }
}