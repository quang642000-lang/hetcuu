package controller.pos;

import model.entity.*;
import service.*;
import service.impl.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
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
        request.getRequestDispatcher("/views/pos/ban_hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        String action = request.getParameter("action");
        if (uri.endsWith("/pos/create-customer") || "createCustomer".equals(action)) {
            performCreateCustomer(request, response);
        } else if (uri.endsWith("/pos/apply-voucher") || "applyVoucher".equals(action)) {
            performApplyVoucher(request, response);
        } else if (uri.endsWith("/pos/checkout") || "checkout".equals(action)) {
            performCheckout(request, response);
        } else if (uri.endsWith("/pos/update-profile") || "updateProfile".equals(action)) {
            performUpdateProfile(request, response);
        } else if (uri.endsWith("/pos/change-password") || "changePassword".equals(action)) {
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
            // NÂNG CẤP ĐỘT PHÁ: Sử dụng mốc đơn hàng cực cao (99.999.999đ) để kéo về toàn bộ ví Voucher VIP khả dụng của khách hàng, tránh bị lọc oan do mốc đơn hàng nhỏ lẻ giả lập
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
                json.append("\"maKm\":\"").append(v.getMaKm()).append("\",");
                json.append("\"maCode\":\"").append(v.getMaCode()).append("\",");
                json.append("\"tenKm\":\"").append(v.getTenKm()).append("\",");
                json.append("\"loaiGiam\":").append(v.getLoaiGiam()).append(",");
                json.append("\"giaTriGiam\":").append(v.getGiaTriGiam()).append(",");
                json.append("\"giamToiDa\":").append(v.getGiamToiDa()).append(",");
                json.append("\"donToiThieu\":").append(v.getDonToiThieu());
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
        int tongTienHang = Integer.parseInt(tongTienHangStr);
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
            json.append("\"loaiGiam\":").append(km.getLoaiGiam()).append(",");
            json.append("\"giaTriGiam\":").append(km.getGiaTriGiam()).append(",");
            json.append("\"giamToiDa\":").append(km.getGiamToiDa()).append(",");
            json.append("\"donToiThieu\":").append(km.getDonToiThieu()).append(",");
            json.append("\"tienGiamGia\":").append(discount);
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
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            json.append("\"thoiGianTao\":\"").append(dh.getThoiGianTao() != null ? sdf.format(dh.getThoiGianTao()) : "N/A").append("\",");
            json.append("\"thoiGianHenLay\":\"").append(dh.getThoiGianHenLay() != null ? sdf.format(dh.getThoiGianHenLay()) : "N/A").append("\",");
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
            String tenNv = "Hệ thống tự động";
            if (dh.getMaNv() != null) {
                NhanVien nv = nhanVienService.getNhanVienById(dh.getMaNv());
                if (nv != null) {
                    tenNv = nv.getHoTen();
                }
            }
            json.append("\"tenNhanVien\":\"").append(tenNv).append("\",");
            json.append("\"tongTienHang\":").append(dh.getTongTienHang()).append(",");
            json.append("\"tienGiamGia\":").append(dh.getTienGiamGia()).append(",");
            json.append("\"diemSuDung\":").append(dh.getDiemSuDung()).append(",");
            json.append("\"tienTruDiem\":").append(dh.getTienTruDiem()).append(",");
            json.append("\"tongPhaiTra\":").append(dh.getTongPhaiTra()).append(",");
            json.append("\"ghiChuDon\":\"").append(dh.getGhiChuDon() != null ? dh.getGhiChuDon().replace("\"", "\\\"") : "").append("\",");
            json.append("\"trangThaiDon\":").append(dh.getTrangThaiDon()).append(",");
            json.append("\"trangThaiThanhToan\":").append(dh.getTrangThaiThanhToan()).append(",");
            json.append("\"toppings\":[],");
            json.append("\"items\":[");
            List<ChiTietDonHang> items = dh.getChiTietDonHangList();
            if (items != null) {
                for (int i = 0; i < items.size(); i++) {
                    ChiTietDonHang item = items.get(i);
                    json.append("{");
                    json.append("\"tenMon\":\"").append(item.getTenSp() != null ? item.getTenSp() : "Sản phẩm").append("\",");
                    json.append("\"tenSize\":\"").append(item.getTenSize() != null ? item.getTenSize() : "S").append("\",");
                    json.append("\"soLuong\":").append(item.getSoLuong()).append(",");
                    json.append("\"giaChot\":").append(item.getGiaChot()).append(",");
                    json.append("\"mucDa\":\"").append(item.getMucDa()).append("\",");
                    json.append("\"mucDuong\":\"").append(item.getMucDuong()).append("\",");
                    json.append("\"ghiChuMon\":\"").append(item.getGhiChuMon() != null ? item.getGhiChuMon().replace("\"", "\\\"") : "").append("\",");
                    json.append("\"toppings\":[");
                    List<ChiTietTopping> tps = donHangService.getDonHangById(dh.getMaDh()).getChiTietDonHangList().get(i).getToppingsList();
                    if (tps != null) {
                        for (int j = 0; j < tps.size(); j++) {
                            ChiTietTopping tp = tps.get(j);
                            json.append("{");
                            json.append("\"tenTopping\":\"").append(tp.getTenTopping() != null ? tp.getTenTopping() : "Topping").append("\",");
                            json.append("\"soLuong\":").append(tp.getSoLuong()).append(",");
                            json.append("\"giaChotTp\":").append(tp.getGiaChotTp());
                            json.append("}");
                            if (j < tps.size() - 1) json.append(",");
                        }
                    }
                    json.append("]");
                    json.append("}");
                    if (i < items.size() - 1) json.append(",");
                }
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
            int loaiDonHang = Integer.parseInt(request.getParameter("loaiDonHang"));
            int maPt = Integer.parseInt(request.getParameter("maPt"));
            String maKm = request.getParameter("maKm");
            int tongTienHang = Integer.parseInt(request.getParameter("tongTienHang"));
            int tienGiamGia = Integer.parseInt(request.getParameter("tienGiamGia"));
            int diemSuDung = Integer.parseInt(request.getParameter("diemSuDung"));
            int tienTruDiem = Integer.parseInt(request.getParameter("tienTruDiem"));
            int tongPhaiTra = Integer.parseInt(request.getParameter("tongPhaiTra"));
            String ghiChuDon = request.getParameter("ghiChuDon");
            String maDh = donHangService.generateNextMaDh();

            DonHang dh = new DonHang();
            dh.setMaDh(maDh);
            dh.setMaKh(maKh != null && !maKh.trim().isEmpty() ? maKh : null);
            dh.setMaNv(currentStaff.getMaNv());
            dh.setMaPt(maPt);
            dh.setMaKm(maKm != null && !maKm.trim().isEmpty() ? maKm : null);
            dh.setLoaiDonHang(loaiDonHang);
            dh.setTongTienHang(tongTienHang);
            dh.setTienGiamGia(tienGiamGia);
            dh.setDiemSuDung(diemSuDung);
            dh.setTienTruDiem(tienTruDiem);
            dh.setTongPhaiTra(tongPhaiTra);
            dh.setGhiChuDon(ghiChuDon != null && !ghiChuDon.trim().isEmpty() ? ghiChuDon : "POS_OFFLINE");
            dh.setTrangThaiThanhToan(1); // POS offline is pre-paid
            dh.setTrangThaiDon(4); // Completed

            String[] arrMaSp = request.getParameterValues("item_maSp[]");
            String[] arrMaSize = request.getParameterValues("item_maSize[]");
            String[] arrSoLuong = request.getParameterValues("item_soLuong[]");
            String[] arrGiaChot = request.getParameterValues("item_giaChot[]");
            String[] arrToppingKeys = request.getParameterValues("item_toppingKeys[]");

            List<ChiTietDonHang> items = new ArrayList<>();
            if (arrMaSp != null) {
                for (int i = 0; i < arrMaSp.length; i++) {
                    ChiTietDonHang ctdh = new ChiTietDonHang();
                    ctdh.setMaSp(arrMaSp[i]);
                    ctdh.setMaSize(Integer.parseInt(arrMaSize[i]));
                    ctdh.setSoLuong(Integer.parseInt(arrSoLuong[i]));
                    int giaChot = 0;
                    if (arrGiaChot != null && i < arrGiaChot.length) {
                        giaChot = Integer.parseInt(arrGiaChot[i]);
                    }
                    ctdh.setGiaChot(giaChot);
                    ctdh.setMucDa("100%");
                    ctdh.setMucDuong("100%");
                    ctdh.setGhiChuMon("POS Order");

                    List<ChiTietTopping> toppingsList = new ArrayList<>();
                    if (arrToppingKeys != null && i < arrToppingKeys.length && arrToppingKeys[i] != null && !arrToppingKeys[i].trim().isEmpty()) {
                        String[] tops = arrToppingKeys[i].split("\\|");
                        for (String rawTp : tops) {
                            String[] parts = rawTp.split("_");
                            if (parts.length == 3) {
                                String maTp = parts[0];
                                int soLuongTp = Integer.parseInt(parts[1]);
                                int giaChotTp = Integer.parseInt(parts[2]);
                                toppingsList.add(new ChiTietTopping(0, maTp, soLuongTp, giaChotTp));
                            }
                        }
                    }
                    ctdh.setToppingsList(toppingsList);
                    items.add(ctdh);
                }
            }

            boolean isCheckedOut = donHangService.checkoutPOS(dh, items, currentStaff.getMaNv());
            if (isCheckedOut) {
                response.sendRedirect(request.getContextPath() + "/pos?msg=createsuccess&orderId=" + dh.getMaDh());
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
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Số điện thoại hoặc Email đã được đăng ký ở tài khoản khác!\"}");
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
        boolean success = nhanVienService.changePassword(currentStaff.getMaNv(), oldPassword, newPassword);
        if (success) {
            response.getWriter().write("{\"status\":\"SUCCESS\"}");
        } else {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mật khẩu cũ không chính xác hoặc thay đổi thất bại!\"}");
        }
    }
}