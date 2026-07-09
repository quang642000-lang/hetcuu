package controller.admin;

import model.entity.KhuyenMai;
import service.IKhuyenMaiService;
import service.impl.KhuyenMaiServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet(name = "VoucherController", urlPatterns = {"/admin/voucher"})
public class VoucherController extends HttpServlet {
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
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                performDelete(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<KhuyenMai> list = khuyenMaiService.getAllKhuyenMai();
        request.setAttribute("vouchers", list);
        request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
        request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        KhuyenMai km = khuyenMaiService.getKhuyenMaiById(id);
        if (km != null) {
            request.setAttribute("voucher", km);
            request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=notfound");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        khuyenMaiService.deleteKhuyenMai(id); // Xóa mềm
        response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=deletesuccess");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            performCreate(request, response);
        } else if ("edit".equals(action)) {
            performUpdate(request, response);
        }
    }

    private void performCreate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maKm = request.getParameter("maKm");
        String tenKm = request.getParameter("tenKm");
        String maCode = request.getParameter("maCode");
        String moTa = request.getParameter("moTaDieuKien");
        String hinhAnh = request.getParameter("hinhAnhUrl");
        int loaiGiam = Integer.parseInt(request.getParameter("loaiGiam"));
        int giaTriGiam = Integer.parseInt(request.getParameter("giaTriGiam"));
        int giamToiDa = Integer.parseInt(request.getParameter("giamToiDa"));
        int donToiThieu = Integer.parseInt(request.getParameter("donToiThieu"));
        int soLuong = Integer.parseInt(request.getParameter("soLuong"));
        boolean isPublic = "1".equals(request.getParameter("isPublic"));
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        // Định dạng datetime từ form: "2026-07-09T12:00" -> đổi sang Timestamp
        String ngayBdStr = request.getParameter("ngayBatDau").replace("T", " ") + ":00";
        String ngayKtStr = request.getParameter("ngayKetThuc").replace("T", " ") + ":00";

        Timestamp ngayBatDau = Timestamp.valueOf(ngayBdStr);
        Timestamp ngayKetThuc = Timestamp.valueOf(ngayKtStr);

        KhuyenMai km = new KhuyenMai(maKm, tenKm, maCode, moTa, hinhAnh, loaiGiam, giaTriGiam, giamToiDa, donToiThieu, isPublic, soLuong, ngayBatDau, ngayKetThuc, trangThai);

        if (ngayKetThuc.before(ngayBatDau)) {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Ngày kết thúc phải lớn hơn ngày bắt đầu khuyến mãi!");
            request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            return;
        }

        boolean success = khuyenMaiService.createKhuyenMai(km);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=createsuccess");
        } else {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Mã Code khuyến mãi bị trùng lặp trong hệ thống!");
            request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maKm = request.getParameter("maKm");
        String tenKm = request.getParameter("tenKm");
        String maCode = request.getParameter("maCode");
        String moTa = request.getParameter("moTaDieuKien");
        String hinhAnh = request.getParameter("hinhAnhUrl");
        int loaiGiam = Integer.parseInt(request.getParameter("loaiGiam"));
        int giaTriGiam = Integer.parseInt(request.getParameter("giaTriGiam"));
        int giamToiDa = Integer.parseInt(request.getParameter("giamToiDa"));
        int donToiThieu = Integer.parseInt(request.getParameter("donToiThieu"));
        int soLuong = Integer.parseInt(request.getParameter("soLuong"));
        boolean isPublic = "1".equals(request.getParameter("isPublic"));
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        String ngayBdStr = request.getParameter("ngayBatDau").replace("T", " ") + ":00";
        String ngayKtStr = request.getParameter("ngayKetThuc").replace("T", " ") + ":00";

        Timestamp ngayBatDau = Timestamp.valueOf(ngayBdStr);
        Timestamp ngayKetThuc = Timestamp.valueOf(ngayKtStr);

        KhuyenMai km = new KhuyenMai(maKm, tenKm, maCode, moTa, hinhAnh, loaiGiam, giaTriGiam, giamToiDa, donToiThieu, isPublic, soLuong, ngayBatDau, ngayKetThuc, trangThai);

        if (ngayKetThuc.before(ngayBatDau)) {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Ngày kết thúc phải lớn hơn ngày bắt đầu khuyến mãi!");
            request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            return;
        }

        boolean success = khuyenMaiService.updateKhuyenMai(km);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=updatesuccess");
        } else {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Không thể cập nhật Voucher!");
            request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
        }
    }
}
