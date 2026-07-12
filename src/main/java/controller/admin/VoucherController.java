package controller.admin;

import model.entity.KhuyenMai;
import model.entity.NhatKyHoatDong;
import repository.impl.NhatKyRepoImpl;
import service.IKhuyenMaiService;
import service.impl.KhuyenMaiServiceImpl;
import config.DBConnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import util.JsonParserUtil;

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
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();

        // 1. Kiểm tra xem Voucher đã phát sinh hóa đơn trong DON_HANG chưa
        boolean hasOrders = false;
        String checkSql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_km = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    hasOrders = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (hasOrders) {
            // Có đơn -> Chỉ cho phép xóa mềm (Đặt trang_thai = 0)
            boolean softSuccess = khuyenMaiService.deleteKhuyenMai(id);
            if (softSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SOFT_DELETE_VOUCHER", "CHUONG_TRINH_KHUYEN_MAI", "Mã KM: " + id,
                        "Chuyển trạng thái hoạt động về 0 do có lịch sử đặt đơn.", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=softdeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=deletefailed");
            }
        } else {
            // Chưa có đơn -> Xóa cứng hoàn toàn khỏi CSDL
            boolean hardSuccess = false;
            String deleteSql = "DELETE FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, id);
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    hardSuccess = true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }

            if (hardSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "HARD_DELETE_VOUCHER", "CHUONG_TRINH_KHUYEN_MAI", "Mã KM: " + id,
                        "Xóa hoàn toàn Voucher khỏi hệ thống (chưa từng giao dịch).", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=harddeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=deletefailed");
            }
        }
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
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();

        try {
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
                request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
                request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
                return;
            }

            boolean success = khuyenMaiService.createKhuyenMai(km);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "THÊM_VOUCHER", "CHUONG_TRINH_KHUYEN_MAI", null, JsonParserUtil.toJson(km), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=createsuccess");
            } else {
                request.setAttribute("voucher", km);
                request.setAttribute("error", "Lỗi: Mã Code khuyến mãi bị trùng lặp trong hệ thống!");
                request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
                request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=error");
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();

        try {
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

            KhuyenMai oldKm = khuyenMaiService.getKhuyenMaiById(maKm);
            String oldJson = JsonParserUtil.toJson(oldKm);

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
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SỬA_VOUCHER", "CHUONG_TRINH_KHUYEN_MAI", oldJson, JsonParserUtil.toJson(km), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=updatesuccess");
            } else {
                request.setAttribute("voucher", km);
                request.setAttribute("error", "Lỗi: Không thể cập nhật Voucher!");
                request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
                request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=error");
        }
    }
}
