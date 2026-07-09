package controller.admin;

import model.entity.DonHang;
import model.entity.KhachHang;
import model.entity.KhuyenMai;
import service.IKhachHangService;
import service.IDonHangService;
import service.IKhuyenMaiService;
import service.impl.KhachHangServiceImpl;
import service.impl.DonHangServiceImpl;
import service.impl.KhuyenMaiServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "KhachHangController", urlPatterns = {"/admin/khachhang"})
public class KhachHangController extends HttpServlet {
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                showList(request, response);
                break;
            case "view":
                showDetailTabs(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<KhachHang> list = khachHangService.getAllKhachHang();
        request.setAttribute("customers", list);
        request.getRequestDispatcher("/views/admin/khachhang-list.jsp").forward(request, response);
    }

    private void showDetailTabs(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        KhachHang kh = khachHangService.getKhachHangById(id);
        if (kh != null) {
            // Tab 1: Đã chứa đối tượng KhachHang kh
            // Tab 2: Lịch sử hóa đơn giao dịch của khách hàng
            List<DonHang> donHangs = donHangService.getDonHangByKhachHang(id);
            // Tab 3: Kho Voucher cá nhân đủ điều kiện sử dụng (lọc theo đơn giá 100.000đ tượng trưng)
            List<KhuyenMai> vouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(100000, id);

            request.setAttribute("customer", kh);
            request.setAttribute("orders", donHangs);
            request.setAttribute("vouchers", vouchers);
            request.getRequestDispatcher("/views/admin/khachhang-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/khachhang?msg=notfound");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        KhachHang kh = khachHangService.getKhachHangById(id);
        if (kh != null) {
            request.setAttribute("customer", kh);
            request.getRequestDispatcher("/views/admin/khachhang-form.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/khachhang?msg=notfound");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("edit".equals(action)) {
            performUpdate(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maKh = request.getParameter("maKh");
        String tenKh = request.getParameter("tenKh");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String ngaySinhStr = request.getParameter("ngaySinh");
        String gioiTinh = request.getParameter("gioiTinh");
        String diaChi = request.getParameter("diaChiLienHe");
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        KhachHang kh = khachHangService.getKhachHangById(maKh);
        if (kh != null) {
            kh.setTenKh(tenKh);
            kh.setSoDienThoai(sdt);
            kh.setEmail(email);
            kh.setGioiTinh(gioiTinh);
            kh.setDiaChiLienHe(diaChi);
            kh.setTrangThai(trangThai);

            if (ngaySinhStr != null && !ngaySinhStr.trim().isEmpty()) {
                kh.setNgaySinh(Date.valueOf(ngaySinhStr));
            }

            boolean success = khachHangService.updateCustomerProfile(kh);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/khachhang?msg=updatesuccess");
            } else {
                request.setAttribute("customer", kh);
                request.setAttribute("error", "Lỗi: Số điện thoại hoặc Email đã tồn tại ở tài khoản khác!");
                request.getRequestDispatcher("/views/admin/khachhang-form.jsp").forward(request, response);
            }
        }
    }
}