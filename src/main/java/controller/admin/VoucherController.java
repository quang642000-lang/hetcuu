package controller.admin;

import model.entity.KhuyenMai;
import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;
import repository.impl.NhatKyRepoImpl;
import service.IKhuyenMaiService;
import service.impl.KhuyenMaiServiceImpl;
import util.JsonParserUtil;
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
import java.sql.Timestamp;
import java.util.List;
import config.DBConnect;

@WebServlet(name = "VoucherController", urlPatterns = {"/admin/voucher"})
public class VoucherController extends HttpServlet {
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();
    private final INhatKyRepository nhatKyRepository = NhatKyRepoImpl.getInstance();

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
            case "toggle":
                performToggle(request, response);
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

    private void performToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        boolean status = "1".equals(request.getParameter("status"));
        KhuyenMai km = khuyenMaiService.getKhuyenMaiById(id);
        if (km != null) {
            boolean oldStatus = km.isTrangThai();
            km.setTrangThai(status);
            boolean success = khuyenMaiService.updateKhuyenMai(km);
            if (success) {
                HttpSession session = request.getSession(false);
                String maNv = "SYSTEM";
                if (session != null && session.getAttribute("user") != null) {
                    maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
                }
                String oldJson = "{\"maKm\":\"" + id + "\",\"trangThai\":" + oldStatus + "}";
                String newJson = "{\"maKm\":\"" + id + "\",\"trangThai\":" + status + "}";
                nhatKyRepository.addLog(new NhatKyHoatDong(
                        maNv,
                        status ? "KÍCH_HOẠT_VOUCHER" : "TẠM_NGƯNG_VOUCHER",
                        "CHUONG_TRINH_KHUYEN_MAI",
                        oldJson,
                        newJson,
                        request.getRemoteAddr(),
                        null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=togglesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=togglefailed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=notfound");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        KhuyenMai km = khuyenMaiService.getKhuyenMaiById(id);
        if (km == null) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=notfound");
            return;
        }
        boolean hasOrders = false;
        String sql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_km = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    hasOrders = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        HttpSession session = request.getSession(false);
        String maNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
        }
        if (hasOrders) {
            km.setTrangThai(false);
            khuyenMaiService.updateKhuyenMai(km);
            nhatKyRepository.addLog(new NhatKyHoatDong(
                    maNv,
                    "TẠM_NGƯNG_VOUCHER",
                    "CHUONG_TRINH_KHUYEN_MAI",
                    JsonParserUtil.toJson(km),
                    "{\"status\":\"SOFT_DELETED_DUE_TO_ORDERS\"}",
                    request.getRemoteAddr(),
                    null
            ));
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=softdeletesuccess");
        } else {
            String deleteSql = "DELETE FROM CHUONG_TRINH_KHUYEN_MAI WHERE ma_km = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, id);
                ps.executeUpdate();
                nhatKyRepository.addLog(new NhatKyHoatDong(
                        maNv,
                        "XÓA_CỨNG_VOUCHER",
                        "CHUONG_TRINH_KHUYEN_MAI",
                        JsonParserUtil.toJson(km),
                        "{\"status\":\"HARD_DELETED_PERMANENTLY\"}",
                        request.getRemoteAddr(),
                        null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=deletesuccess");
            } catch (Exception e) {
                e.printStackTrace();
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

        // ĐẶT maKm BẰNG NULL ĐỂ DATABASE TỰ ĐỘNG SINH QUA SEQUENCE & STORED PROCEDURE sp_ThemVoucher
        KhuyenMai km = new KhuyenMai(null, tenKm, maCode, moTa, hinhAnh, loaiGiam, giaTriGiam, giamToiDa, donToiThieu, isPublic, soLuong, ngayBatDau, ngayKetThuc, trangThai);

        if (ngayKetThuc.before(ngayBatDau)) {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Ngày kết thúc phải lớn hơn ngày bắt đầu khuyến mãi!");
            request.setAttribute("formTitle", "TẠO MỚI MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            return;
        }
        boolean success = khuyenMaiService.createKhuyenMai(km);
        if (success) {
            HttpSession session = request.getSession(false);
            String maNv = "SYSTEM";
            if (session != null && session.getAttribute("user") != null) {
                maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
            }
            nhatKyRepository.addLog(new NhatKyHoatDong(
                    maNv,
                    "TẠO_VOUCHER_MỚI",
                    "CHUONG_TRINH_KHUYEN_MAI",
                    null,
                    JsonParserUtil.toJson(km),
                    request.getRemoteAddr(),
                    null
            ));
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

        KhuyenMai km = khuyenMaiService.getKhuyenMaiById(maKm);
        if (km == null) {
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=notfound");
            return;
        }
        String oldJson = JsonParserUtil.toJson(km);
        km.setTenKm(tenKm);
        km.setMaCode(maCode);
        km.setMoTaDieuKien(moTa);
        km.setHinhAnhUrl(hinhAnh);
        km.setLoaiGiam(loaiGiam);
        km.setGiaTriGiam(giaTriGiam);
        km.setGiamToiDa(giamToiDa);
        km.setDonToiThieu(donToiThieu);
        km.setSoLuong(soLuong);
        km.setPublic(isPublic);
        km.setNgayBatDau(ngayBatDau);
        km.setNgayKetThuc(ngayKetThuc);
        km.setTrangThai(trangThai);

        if (ngayKetThuc.before(ngayBatDau)) {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Ngày kết thúc phải lớn hơn ngày bắt đầu khuyến mãi!");
            request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
            return;
        }
        boolean success = khuyenMaiService.updateKhuyenMai(km);
        if (success) {
            HttpSession session = request.getSession(false);
            String maNv = "SYSTEM";
            if (session != null && session.getAttribute("user") != null) {
                maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
            }
            nhatKyRepository.addLog(new NhatKyHoatDong(
                    maNv,
                    "SỬA_THÔNG_TIN_VOUCHER",
                    "CHUONG_TRINH_KHUYEN_MAI",
                    oldJson,
                    JsonParserUtil.toJson(km),
                    request.getRemoteAddr(),
                    null
            ));
            response.sendRedirect(request.getContextPath() + "/admin/voucher?msg=updatesuccess");
        } else {
            request.setAttribute("voucher", km);
            request.setAttribute("error", "Lỗi: Không thể cập nhật Voucher!");
            request.setAttribute("formTitle", "CẬP NHẬT MÃ KHUYẾN MÃI");
            request.getRequestDispatcher("/views/admin/voucher.jsp").forward(request, response);
        }
    }
}