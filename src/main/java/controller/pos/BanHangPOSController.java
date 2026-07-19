package controller.pos;

import config.DBConnect;
import model.entity.*;
import service.*;
import service.impl.*;
import util.SecurityUtil;

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
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "BanHangPOSController", urlPatterns = {
        "/pos",
        "/pos/search-customer",
        "/pos/create-customer",
        "/pos/apply-voucher",
        "/pos/bill-detail",
        "/pos/checkout",
        "/pos/update-profile",
        "/pos/change-password"
})
public class BanHangPOSController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(BanHangPOSController.class.getName());
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String uri = request.getRequestURI();
        if (uri.endsWith("/pos/search-customer")) {
            performSearchCustomer(request, response);
            return;
        }
        if (uri.endsWith("/pos/bill-detail")) {
            performGetBillDetail(request, response);
            return;
        }
        List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
        List<SanPham> products = sanPhamService.getAllSanPham();
        List<Topping> toppings = toppingService.getActiveTopping();
        for (SanPham sp : products) {
            sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
        }
        request.setAttribute("categories", categories);
        request.setAttribute("products", products);
        request.setAttribute("toppings", toppings);

        // Convert to JSON array of toppings for use in popup options
        StringBuilder toppingsJson = new StringBuilder();
        toppingsJson.append("[");
        for (int i = 0; i < toppings.size(); i++) {
            Topping t = toppings.get(i);
            toppingsJson.append("{");
            toppingsJson.append("\"maTp\":\"").append(t.getMaTp()).append("\",");
            toppingsJson.append("\"tenTp\":\"").append(t.getTenTp()).append("\",");
            toppingsJson.append("\"giaBan\":").append(t.getGiaBan()).append(",");
            toppingsJson.append("\"hinhAnh\":\"").append(t.getHinhAnh() != null ? t.getHinhAnh() : "").append("\"");
            toppingsJson.append("}");
            if (i < toppings.size() - 1) toppingsJson.append(",");
        }
        toppingsJson.append("]");
        request.setAttribute("allToppingsJson", toppingsJson.toString());
        request.getRequestDispatcher("/views/pos/ban_hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.endsWith("/pos/checkout")) {
            performCheckout(request, response);
        } else if (uri.endsWith("/pos/create-customer")) {
            performCreateCustomer(request, response);
        } else if (uri.endsWith("/pos/apply-voucher")) {
            performApplyVoucher(request, response);
        } else if (uri.endsWith("/pos/update-profile")) {
            performUpdateProfile(request, response);
        } else if (uri.endsWith("/pos/change-password")) {
            performChangePassword(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void performSearchCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String sdt = request.getParameter("sdt");
        if (sdt == null || sdt.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"NOT_FOUND\"}");
            return;
        }
        KhachHang kh = khachHangService.getKhachHangBySdt(sdt.trim());
        if (kh != null && kh.isTrangThai()) {
            List<KhuyenMai> vouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(99999999, kh.getMaKh());
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"status\":\"SUCCESS\",");
            json.append("\"maKh\":\"").append(kh.getMaKh()).append("\",");
            json.append("\"tenKh\":\"").append(kh.getTenKh()).append("\",");
            json.append("\"diemTichLuy\":").append(kh.getDiemTichLuy()).append(",");
            json.append("\"maHang\":").append(kh.getMaHang()).append(",");
            json.append("\"vouchers\":[");
            for (int i = 0; i < vouchers.size(); i++) {
                KhuyenMai v = vouchers.get(i);
                json.append("{");
                json.append("\"maCode\":\"").append(v.getMaCode()).append("\",");
                json.append("\"tenKm\":\"").append(v.getTenKm()).append("\",");
                json.append("\"loaiGiam\":").append(v.getLoaiGiam()).append(",");
                json.append("\"giaTriGiam\":").append(v.getGiaTriGiam()).append(",");
                json.append("\"giamToiDa\":").append(v.getGiamToiDa()).append(",");
                json.append("\"donToiThieu\":").append(v.getDonToiThieu()).append("");
                json.append("}");
                if (i < vouchers.size() - 1) json.append(",");
            }
            json.append("]");
            json.append("}");
            response.getWriter().write(json.toString());
        } else {
            response.getWriter().write("{\"status\":\"NOT_FOUND\"}");
        }
    }

    private void performCreateCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String tenKh = request.getParameter("tenKh");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        if (tenKh == null || tenKh.trim().isEmpty() || sdt == null || sdt.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Các trường thông tin không được để trống!\"}");
            return;
        }
        try {
            KhachHang kh = khachHangService.registerCustomer(tenKh, sdt, email, "12345678");
            if (kh != null) {
                kh.setTrangThai(true);
                khachHangService.updateCustomerProfile(kh);
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"status\":\"SUCCESS\",");
                json.append("\"maKh\":\"").append(kh.getMaKh()).append("\",");
                json.append("\"tenKh\":\"").append(kh.getTenKh()).append("\",");
                json.append("\"diemTichLuy\":0,");
                json.append("\"maHang\":1,");
                json.append("\"vouchers\":[]");
                json.append("}");
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Số điện thoại hoặc Email đã tồn tại trong hệ thống!\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tạo nhanh khách hàng POS", e);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Sự cố hệ thống máy chủ khi xử lý!\"}");
        }
    }

    private void performApplyVoucher(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String code = request.getParameter("code");
        String maKh = request.getParameter("maKh");
        String tongTienHangStr = request.getParameter("tongTienHang");
        if (code == null || code.trim().isEmpty() || tongTienHangStr == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Voucher không hợp lệ!\"}");
            return;
        }
        int tongTienHang = getIntParameter(request, "tongTienHang", 0);
        if (maKh != null && maKh.trim().isEmpty()) {
            maKh = null;
        }
        boolean isValid = khuyenMaiService.validateVoucher(code.trim(), tongTienHang, maKh);
        if (isValid) {
            KhuyenMai km = khuyenMaiService.getKhuyenMaiByCode(code.trim());
            int discount = khuyenMaiService.calculateDiscount(code.trim(), tongTienHang);
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"status\":\"SUCCESS\",");
            json.append("\"maKm\":\"").append(km.getMaKm()).append("\",");
            json.append("\"maCode\":\"").append(km.getMaCode()).append("\",");
            json.append("\"tenKm\":\"").append(km.getTenKm()).append("\",");
            json.append("\"loaiGiam\":").append(km.getLoaiGiam()).append(",");
            json.append("\"giaTriGiam\":").append(km.getGiaTriGiam()).append(",");
            json.append("\"giamToiDa\":").append(km.getGiamToiDa()).append(",");
            json.append("\"donToiThieu\":").append(km.getDonToiThieu()).append(",");
            json.append("\"discount\":").append(discount).append("");
            json.append("}");
            response.getWriter().write(json.toString());
        } else {
            KhuyenMai km = khuyenMaiService.getKhuyenMaiByCode(code.trim());
            String errorMsg = "Voucher không tồn tại hoặc đã hết hạn!";
            if (km != null) {
                if (km.getSoLuong() <= 0) {
                    errorMsg = "Voucher " + code + " đã hết số lượng sử dụng!";
                } else if (tongTienHang < km.getDonToiThieu()) {
                    errorMsg = "Đơn hàng chưa đạt giá trị tối thiểu " + km.getDonToiThieu() + " đ!";
                }
            }
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + errorMsg + "\"}");
        }
    }

    private void performGetBillDetail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String id = request.getParameter("id");
        if (id == null || id.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mã hóa đơn không hợp lệ!\"}");
            return;
        }
        DonHang dh = donHangService.getDonHangById(id);
        if (dh != null) {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"status\":\"SUCCESS\",");
            json.append("\"maDh\":\"").append(dh.getMaDh()).append("\",");
            json.append("\"thoiGianTao\":\"").append(dh.getThoiGianTao().toString().substring(0, 19)).append("\",");
            String tenKh = "Khách lẻ vãng lai";
            String sdtKh = "N/A";
            if (dh.getMaKh() != null) {
                KhachHang kh = khachHangService.getKhachHangById(dh.getMaKh());
                if (kh != null) {
                    tenKh = kh.getTenKh();
                    sdtKh = kh.getSoDienThoai();
                }
            }
            json.append("\"tenKhachHang\":\"").append(tenKh).append("\",");
            json.append("\"sdtKhachHang\":\"").append(sdtKh).append("\",");
            String textNhanVien = "Hệ thống tự động";
            if (dh.getMaNv() != null) {
                NhanVien nv = nhanVienService.getNhanVienById(dh.getMaNv());
                if (nv != null) textNhanVien = nv.getHoTen();
            }
            json.append("\"tenNhanVien\":\"").append(textNhanVien).append("\",");
            String tenPt = "Tiền mặt";
            if (dh.getMaPt() == 2) {
                tenPt = "Chuyển khoản QR";
            }
            json.append("\"tenPhuongThucTT\":\"").append(tenPt).append("\",");
            String strLoaiDon = "Tại quầy";
            if (dh.getLoaiDonHang() == 2) strLoaiDon = "Mang đi";
            else if (dh.getLoaiDonHang() == 3) strLoaiDon = "Đặt online";
            json.append("\"loaiDonHang\":\"").append(strLoaiDon).append("\",");
            json.append("\"tongTienHang\":").append(dh.getTongTienHang()).append(",");
            json.append("\"tienGiamGia\":").append(dh.getTienGiamGia()).append(",");
            json.append("\"diemSuDung\":").append(dh.getDiemSuDung()).append(",");
            json.append("\"tienTruDiem\":").append(dh.getTienTruDiem()).append(",");
            json.append("\"tongPhaiTra\":").append(dh.getTongPhaiTra()).append(",");
            json.append("\"items\":[");
            List<ChiTietDonHang> items = dh.getChiTietDonHangList();
            for (int i = 0; i < items.size(); i++) {
                ChiTietDonHang ctdh = items.get(i);
                json.append("{");
                json.append("\"tenMon\":\"").append(ctdh.getTenSp() != null ? ctdh.getTenSp() : ctdh.getMaSp()).append("\",");
                json.append("\"maSize\":").append(ctdh.getMaSize()).append(",");
                json.append("\"tenSize\":\"").append(ctdh.getTenSize()).append("\",");
                json.append("\"soLuong\":").append(ctdh.getSoLuong()).append(",");
                json.append("\"giaChot\":").append(ctdh.getGiaChot()).append(",");
                json.append("\"toppings\":[");
                List<ChiTietTopping> tps = ctdh.getToppingsList();
                if (tps != null) {
                    for (int j = 0; j < tps.size(); j++) {
                        ChiTietTopping tp = tps.get(j);
                        json.append("{");
                        json.append("\"tenTopping\":\"").append(tp.getTenTopping() != null ? tp.getTenTopping() : tp.getMaTp()).append("\",");
                        json.append("\"soLuong\":").append(tp.getSoLuong()).append(",");
                        json.append("\"giaChotTp\":").append(tp.getGiaChotTp()).append("");
                        json.append("}");
                        if (j < tps.size() - 1) json.append(",");
                    }
                }
                json.append("]");
                json.append("}");
                if (i < items.size() - 1) json.append(",");
            }
            json.append("]");
            json.append("}");
            response.getWriter().write(json.toString());
        } else {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Hóa đơn không tồn tại!\"}");
        }
    }

    private void performCheckout(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        NhanVien currentStaff = (NhanVien) session.getAttribute("user");
        try {
            String maKh = request.getParameter("maKh");
            int loaiDonHang = getIntParameter(request, "loaiDonHang", 1);
            int maPt = getIntParameter(request, "maPt", 1);
            String maKm = request.getParameter("maKm");
            int tongTienHang = getIntParameter(request, "tongTienHang", 0);
            int tienGiamGia = getIntParameter(request, "tienGiamGia", 0);
            int diemSuDung = getIntParameter(request, "diemSuDung", 0);
            int tienTruDiem = getIntParameter(request, "tienTruDiem", 0);
            int tongPhaiTra = getIntParameter(request, "tongPhaiTra", 0);
            String ghiChuDon = request.getParameter("ghiChuDon");

            DonHang dh = new DonHang();
            String maDh = donHangService.generateNextMaDh();
            dh.setMaDh(maDh);
            dh.setMaKh(maKh != null && !maKh.trim().isEmpty() ? maKh : null);
            dh.setMaPt(maPt);
            dh.setMaKm(maKm != null && !maKm.trim().isEmpty() ? maKm : null);
            dh.setLoaiDonHang(loaiDonHang);
            dh.setTongTienHang(tongTienHang);
            dh.setTienGiamGia(tienGiamGia);
            dh.setDiemSuDung(diemSuDung);
            dh.setTienTruDiem(tienTruDiem);
            dh.setTongPhaiTra(tongPhaiTra);
            dh.setGhiChuDon(ghiChuDon);

            // Set payment and order states based on method
            if (maPt == 2) { // QR dynamic code
                dh.setTrangThaiThanhToan(0); // Unpaid, waiting for webhook
                dh.setTrangThaiDon(0); // Pending/waiting approval
            } else { // Cash
                dh.setTrangThaiThanhToan(1); // Paid at counter
                dh.setTrangThaiDon(4); // Completed
            }

            // Build chi tiết hóa đơn
            List<ChiTietDonHang> items = new ArrayList<>();
            String[] itemMaSp = request.getParameterValues("item_maSp[]");
            String[] itemMaSize = request.getParameterValues("item_maSize[]");
            String[] itemSoLuong = request.getParameterValues("item_soLuong[]");
            String[] itemToppingKeys = request.getParameterValues("item_toppingKeys[]");

            if (itemMaSp != null) {
                for (int i = 0; i < itemMaSp.length; i++) {
                    ChiTietDonHang ctdh = new ChiTietDonHang();
                    ctdh.setMaDh(maDh);
                    ctdh.setMaSp(itemMaSp[i]);
                    ctdh.setMaSize(parseIntSafe(itemMaSize[i], 1));
                    ctdh.setSoLuong(parseIntSafe(itemSoLuong[i], 1));

                    // Lấy giá chốt size
                    int itemGiaChot = sanPhamService.getGiaKichCoSanPham(itemMaSp[i], parseIntSafe(itemMaSize[i], 1));
                    ctdh.setGiaChot(itemGiaChot);

                    // Toppings
                    List<ChiTietTopping> toppingsList = new ArrayList<>();
                    if (itemToppingKeys != null && i < itemToppingKeys.length && !itemToppingKeys[i].isEmpty()) {
                        String[] rawTps = itemToppingKeys[i].split("\\|");
                        for (String rtp : rawTps) {
                            String[] parts = rtp.split("_");
                            if (parts.length >= 3) {
                                ChiTietTopping ctt = new ChiTietTopping();
                                ctt.setMaTp(parts[0]);
                                ctt.setSoLuong(parseIntSafe(parts[1], 1));
                                ctt.setGiaChotTp(parseIntSafe(parts[2], 0));
                                toppingsList.add(ctt);
                            }
                        }
                    }
                    ctdh.setToppingsList(toppingsList);
                    items.add(ctdh);
                }
            }

            boolean isCheckedOut = donHangService.checkoutPOS(dh, items, currentStaff.getMaNv());
            if (isCheckedOut) {
                // REDIRECT WITH PAYMENT PARAMS TO TRIGGER THE QR MODAL DIRECTLY
                response.sendRedirect(request.getContextPath() + "/pos?msg=createsuccess&orderId=" + dh.getMaDh() + "&maPt=" + dh.getMaPt() + "&payable=" + dh.getTongPhaiTra());
            } else {
                request.setAttribute("error", "Đã xảy ra lỗi hệ thống trong quá trình chốt giao dịch POS!");
                doGet(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xử lý chốt hóa đơn POS", e);
            request.setAttribute("error", "Lỗi xử lý thông tin hóa đơn đầu vào!");
            doGet(request, response);
        }
    }

    private void performUpdateProfile(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Phiên làm việc đã hết hạn!\"}");
            return;
        }
        NhanVien currentStaff = (NhanVien) session.getAttribute("user");
        String hoTen = request.getParameter("hoTen");
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        if (hoTen == null || hoTen.trim().isEmpty() || sdt == null || sdt.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Các trường thông tin không được để trống!\"}");
            return;
        }
        currentStaff.setHoTen(hoTen.trim());
        currentStaff.setSoDienThoai(sdt.trim());
        currentStaff.setEmail(email.trim());
        boolean success = nhanVienService.updateNhanVien(currentStaff);
        if (success) {
            session.setAttribute("user", currentStaff);
            response.getWriter().write("{\"status\":\"SUCCESS\"}");
        } else {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Lỗi lưu cập nhật cơ sở dữ liệu!\"}");
        }
    }

    private void performChangePassword(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Phiên làm việc đã hết hạn!\"}");
            return;
        }
        NhanVien currentStaff = (NhanVien) session.getAttribute("user");
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        if (oldPassword == null || newPassword == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mật khẩu không được để trống!\"}");
            return;
        }
        String hashedOld = SecurityUtil.hashSHA256(oldPassword);
        if (!currentStaff.getMatKhau().equals(hashedOld)) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mật khẩu cũ không chính xác!\"}");
            return;
        }
        currentStaff.setMatKhau(SecurityUtil.hashSHA256(newPassword));
        boolean success = nhanVienService.updateNhanVien(currentStaff);
        if (success) {
            response.getWriter().write("{\"status\":\"SUCCESS\"}");
        } else {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mật khẩu cũ không chính xác hoặc thay đổi thất bại!\"}");
        }
    }

    // --- HELPER METHODS FOR ROBUST INTEGER PARSING ---
    private int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Lỗi phân tích cú pháp tham số: " + paramName + " = '" + value + "' -> Dùng fallback: " + defaultValue);
            return defaultValue;
        }
    }

    private int parseIntSafe(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Lỗi phân tích số: '" + value + "' -> Dùng fallback: " + defaultValue);
            return defaultValue;
        }
    }
}