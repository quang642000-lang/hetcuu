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

@WebServlet(name = "PortalProfileController", urlPatterns = {
        "/profile",
        "/profile/orders",
        "/profile/vouchers",
        "/profile/update",
        "/profile/change-password",
        "/portal/order/detail",
        "/portal/order/cancel",
        "/portal/order/payment-qr" // ADDED FOR PORTAL SEPAY QR FLOW
})
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
        KhachHang freshCustomer = khachHangService.getKhachHangById(currentCustomer.getMaKh());
        session.setAttribute("customer", freshCustomer);
        String uri = request.getRequestURI();

        // 1. NGHIỆP VỤ: XEM CHI TIẾT ĐƠN HÀNG
        if (uri.contains("/portal/order/detail")) {
            String id = request.getParameter("id");
            DonHang dh = donHangService.getDonHangById(id);
            if (dh != null && dh.getMaKh().equals(freshCustomer.getMaKh())) {
                request.setAttribute("order", dh);
                request.getRequestDispatcher("/views/portal/chi_tiet_don.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/profile/orders?msg=notfound");
            }
            return;
        }

        // 2. NGHIỆP VỤ: TRANG QUÉT MÃ QR THANH TOÁN SEPAY
        if (uri.contains("/portal/order/payment-qr")) {
            String id = request.getParameter("id");
            DonHang dh = donHangService.getDonHangById(id);
            if (dh != null && dh.getMaKh().equals(freshCustomer.getMaKh()) && dh.getTrangThaiThanhToan() == 0) {
                request.setAttribute("order", dh);
                request.getRequestDispatcher("/views/portal/thanh_toan_qr.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/profile/orders?msg=invalid_action");
            }
            return;
        }

        // 3. NGHIỆP VỤ: KHÁCH HÀNG CHỦ ĐỘNG HỦY ĐƠN ONLINE
        if (uri.contains("/portal/order/cancel")) {
            String id = request.getParameter("id");
            DonHang dh = donHangService.getDonHangById(id);
            if (dh != null && dh.getMaKh().equals(freshCustomer.getMaKh()) && dh.getTrangThaiDon() == 0) {
                boolean success = donHangService.updateTrangThaiDon(id, 5, "CUSTOMER", "Khách hàng chủ động hủy trên Website Portal.");
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/profile/orders?msg=cancelsuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile/orders?msg=cancelfailed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/profile/orders?msg=invalid_action");
            }
            return;
        }

        if (uri.endsWith("/profile/orders")) {
            List<DonHang> myOrders = donHangService.getDonHangByKhachHang(freshCustomer.getMaKh());
            request.setAttribute("orders", myOrders);
            request.getRequestDispatcher("/views/portal/theo_doi_don.jsp").forward(request, response);
        } else if (uri.endsWith("/profile/vouchers")) {
            List<KhuyenMai> myVouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(100000, freshCustomer.getMaKh());
            request.setAttribute("vouchers", myVouchers);
            request.getRequestDispatcher("/views/portal/kho_voucher.jsp").forward(request, response);
        } else {
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
            request.getRequestDispatcher("/views/portal/ho_so.jsp").forward(request, response);
        }
    }

    private void performChangePassword(HttpServletRequest request, HttpServletResponse response, String maKh) throws ServletException, IOException {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirm)) {
            request.setAttribute("errorPassword", "Xác nhận mật khẩu mới không đúng!");
            doGet(request, response);
            return;
        }
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
