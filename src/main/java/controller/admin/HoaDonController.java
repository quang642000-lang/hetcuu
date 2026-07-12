package controller.admin;

import model.entity.DonHang;
import model.entity.ChiTietDonHang;
import model.entity.ChiTietTopping;
import model.entity.NhanVien;
import model.entity.KhachHang;
import service.IDonHangService;
import service.IKhachHangService;
import service.INhanVienService;
import service.impl.DonHangServiceImpl;
import service.impl.KhachHangServiceImpl;
import service.impl.NhanVienServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HoaDonController", urlPatterns = {"/admin/hoadon"})
public class HoaDonController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        if ("detailJson".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            String id = request.getParameter("id");
            DonHang dh = donHangService.getDonHangById(id);
            if (dh != null) {
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"status\":\"SUCCESS\",");
                json.append("\"maDh\":\"").append(dh.getMaDh()).append("\",");
                json.append("\"thoiGianTao\":\"").append(dh.getThoiGianTao().toString().substring(0, 19)).append("\",");
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
                for (int i = 0; i < dh.getChiTietDonHangList().size(); i++) {
                    ChiTietDonHang item = dh.getChiTietDonHangList().get(i);
                    json.append("{");
                    json.append("\"tenMon\":\"").append(item.getMaSp()).append("\",");
                    json.append("\"tenSize\":\"").append(item.getTenSize() != null ? item.getTenSize() : "M").append("\",");
                    json.append("\"mucDa\":\"").append(item.getMucDa() != null ? item.getMucDa() : "100%").append("\",");
                    json.append("\"mucDuong\":\"").append(item.getMucDuong() != null ? item.getMucDuong() : "100%").append("\",");
                    json.append("\"soLuong\":").append(item.getSoLuong()).append(",");
                    json.append("\"giaChot\":").append(item.getGiaChot()).append(",");
                    json.append("\"toppings\":[");
                    for (int j = 0; j < item.getToppingsList().size(); j++) {
                        ChiTietTopping tp = item.getToppingsList().get(j);
                        json.append("{");
                        json.append("\"tenTopping\":\"TP").append(tp.getMaTp()).append("\",");
                        json.append("\"soLuong\":").append(tp.getSoLuong()).append(",");
                        json.append("\"giaChotTp\":").append(tp.getGiaChotTp());
                        json.append("}");
                        if (j < item.getToppingsList().size() - 1) json.append(",");
                    }
                    json.append("]");
                    json.append("}");
                    if (i < dh.getChiTietDonHangList().size() - 1) json.append(",");
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
            int status = Integer.parseInt(statusStr);
            orders = donHangService.getDonHangByTrangThai(status);
        } else {
            orders = donHangService.getAllDonHang();
        }

        // NÂNG CẤP: Truy xuất toàn bộ danh sách nhân viên phục vụ bộ lọc nhân viên tại quầy Admin
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
        int status = Integer.parseInt(request.getParameter("trangThaiDon"));
        String lyDoHuy = request.getParameter("lyDoHuy");
        HttpSession session = request.getSession(false);
        String maNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
        }
        boolean success = donHangService.updateTrangThaiDon(maDh, status, maNv, lyDoHuy);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatefailed");
        }
    }
}
