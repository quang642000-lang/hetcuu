package controller.admin;

import model.entity.DonHang;
import model.entity.ChiTietDonHang;
import model.entity.ChiTietTopping;
import model.entity.NhanVien;
import model.entity.KhachHang;
import model.entity.SanPham;
import model.entity.Topping;
import service.IDonHangService;
import service.IKhachHangService;
import service.INhanVienService;
import service.ISanPhamService;
import service.IToppingService;
import service.impl.DonHangServiceImpl;
import service.impl.KhachHangServiceImpl;
import service.impl.NhanVienServiceImpl;
import service.impl.SanPhamServiceImpl;
import service.impl.ToppingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(name = "HoaDonController", urlPatterns = {"/admin/hoadon"})
public class HoaDonController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        if ("detailJson".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            String id = request.getParameter("id");
            if (id == null || id.trim().isEmpty()) {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mã hóa đơn bị thiếu!\"}");
                return;
            }
            DonHang dh = donHangService.getDonHangById(id);
            if (dh != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String formattedDate = dh.getThoiGianTao() != null ? sdf.format(dh.getThoiGianTao()) : "Chưa xác định";

                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"status\":\"SUCCESS\",");
                json.append("\"maDh\":\"").append(dh.getMaDh()).append("\",");
                json.append("\"thoiGianTao\":\"").append(formattedDate).append("\",");

                String tenKh = "Khách lẻ vãng lai";
                if (dh.getMaKh() != null) {
                    KhachHang kh = khachHangService.getKhachHangById(dh.getMaKh());
                    if (kh != null) tenKh = kh.getTenKh();
                }
                json.append("\"tenKhachHang\":\"").append(tenKh).append("\",");

                String tenNv = "Hệ thống tự động";
                if (dh.getMaNv() != null) {
                    NhanVien nv = nhanVienService.getNhanVienById(dh.getMaNv());
                    if (nv != null) tenNv = nv.getHoTen();
                }
                json.append("\"tenNhanVien\":\"").append(tenNv).append("\",");
                json.append("\"tongTienHang\":").append(dh.getTongTienHang()).append(",");
                json.append("\"tienGiamGia\":").append(dh.getTienGiamGia()).append(",");
                json.append("\"diemSuDung\":").append(dh.getDiemSuDung()).append(",");
                json.append("\"tienTruDiem\":").append(dh.getTienTruDiem()).append(",");
                json.append("\"tongPhaiTra\":").append(dh.getTongPhaiTra()).append(",");
                json.append("\"items\":[");

                List<ChiTietDonHang> items = dh.getChiTietDonHangList();
                for (int i = 0; i < items.size(); i++) {
                    ChiTietDonHang item = items.get(i);
                    String tenSp = "Sản phẩm " + item.getMaSp();
                    SanPham sp = sanPhamService.getSanPhamById(item.getMaSp());
                    if (sp != null) tenSp = sp.getTenSp();

                    json.append("{");
                    json.append("\"tenMon\":\"").append(tenSp).append("\",");
                    json.append("\"tenSize\":\"").append(item.getTenSize() != null ? item.getTenSize() : "M").append("\",");
                    json.append("\"mucDa\":\"").append(item.getMucDa() != null ? item.getMucDa() : "100%").append("\",");
                    json.append("\"mucDuong\":\"").append(item.getMucDuong() != null ? item.getMucDuong() : "100%").append("\",");
                    json.append("\"soLuong\":").append(item.getSoLuong()).append(",");
                    json.append("\"giaChot\":").append(item.getGiaChot()).append(",");
                    json.append("\"toppings\":[");

                    List<ChiTietTopping> toppings = item.getToppingsList();
                    for (int j = 0; j < toppings.size(); j++) {
                        ChiTietTopping tp = toppings.get(j);
                        String tenTp = "Topping " + tp.getMaTp();
                        Topping topping = toppingService.getToppingById(tp.getMaTp());
                        if (topping != null) tenTp = topping.getTenTp();

                        json.append("{");
                        json.append("\"tenTopping\":\"").append(tenTp).append("\",");
                        json.append("\"soLuong\":").append(tp.getSoLuong()).append(",");
                        json.append("\"giaChotTp\":").append(tp.getGiaChotTp());
                        json.append("}");
                        if (j < toppings.size() - 1) json.append(",");
                    }
                    json.append("]");
                    json.append("}");
                    if (i < items.size() - 1) json.append(",");
                }
                json.append("]");
                json.append("}");
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"status\":\"NOT_FOUND\"}");
            }
            return;
        }
        switch (action) {
            case "list":
                showList(request, response);
                break;
            case "view":
                showDetail(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String statusStr = request.getParameter("status");
        List<DonHang> orders;
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            try {
                int status = Integer.parseInt(statusStr);
                orders = donHangService.getDonHangByTrangThai(status);
            } catch (NumberFormatException e) {
                orders = donHangService.getAllDonHang();
            }
        } else {
            orders = donHangService.getAllDonHang();
        }
        List<NhanVien> employees = nhanVienService.getAllNhanVien();
        request.setAttribute("orders", orders);
        request.setAttribute("employees", employees);
        request.setAttribute("statusFilter", statusStr);
        request.getRequestDispatcher("/views/admin/hoa_don.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        DonHang dh = donHangService.getDonHangById(id);
        if (dh != null) {
            request.setAttribute("order", dh);
            request.getRequestDispatcher("/views/admin/hoa_don.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?msg=notfound");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            performUpdateStatus(request, response);
        }
    }

    private void performUpdateStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maDh = request.getParameter("maDh");
        String statusStr = request.getParameter("trangThaiDon");
        String lyDoHuy = request.getParameter("lyDoHuy");

        if (maDh == null || statusStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?msg=error");
            return;
        }

        try {
            int status = Integer.parseInt(statusStr);
            NhanVien user = null;
            jakarta.servlet.http.HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") instanceof NhanVien) {
                user = (NhanVien) session.getAttribute("user");
            }
            String maNv = user != null ? user.getMaNv() : "SYSTEM";
            boolean success = donHangService.updateTrangThaiDon(maDh, status, maNv, lyDoHuy);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatefailed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?msg=error");
        }
    }
}