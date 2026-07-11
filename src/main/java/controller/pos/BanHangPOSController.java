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
        "/pos/checkout"
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

        // Mặc định nạp giao diện POS chính
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

        if (uri.endsWith("/pos/checkout")) {
            performPOSCheckout(request, response);
        } else if (uri.endsWith("/pos/create-customer")) {
            performCreateCustomer(request, response);
        } else if (uri.endsWith("/pos/apply-voucher")) {
            performApplyVoucher(request, response);
        }
    }

    /**
     * Tra cứu thành viên CRM qua SĐT
     */
    private void performSearchCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String sdt = request.getParameter("sdt");
        if (sdt == null || sdt.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"NOT_FOUND\"}");
            return;
        }

        KhachHang kh = khachHangService.getKhachHangBySdt(sdt.trim());
        if (kh != null && kh.isTrangThai()) {
            // Lấy danh sách Voucher khả dụng cho khách hàng này tại quầy (tính theo mốc đơn giả lập tối thiểu 10.000đ)
            List<KhuyenMai> vouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(10000, kh.getMaKh());

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

    /**
     * Đăng ký nhanh thành viên mới trực tiếp tại quầy POS và tự động kích hoạt
     */
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
            // Mật khẩu mặc định khi khởi tạo tại quầy là 12345678
            KhachHang kh = khachHangService.registerCustomer(tenKh, sdt, email, "12345678");
            if (kh != null) {
                // Đăng ký thành công -> Tiến hành kích hoạt hoạt động ngay lập tức tại quầy để nạp điểm
                kh.setTrangThai(true);
                khachHangService.updateCustomerProfile(kh);

                // Trả về thông tin khách hàng mới vừa đăng ký thành công
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"status\":\"SUCCESS\",");
                json.append("\"maKh\":\"").append(kh.getMaKh()).append("\",");
                json.append("\"tenKh\":\"").append(kh.getTenKh()).append("\",");
                json.append("\"diemTichLuy\":0,");
                json.append("\"maHang\":1,"); // Mặc định hạng ĐỒNG
                json.append("\"vouchers\":[]"); // Thành viên mới chưa có voucher
                json.append("}");
                response.getWriter().write(json.toString());
            } else {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Số điện thoại hoặc Email đã tồn tại trong hệ thống!\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tạo nhanh tài khoản khách hàng tại quầy POS", e);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Lỗi hệ thống máy chủ khi xử lý!\"}");
        }
    }

    /**
     * Xác thực và áp dụng Voucher thủ công do nhân viên nhập hoặc khách cung cấp
     */
    private void performApplyVoucher(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String code = request.getParameter("code");
        String maKh = request.getParameter("maKh");
        String tongTienHangStr = request.getParameter("tongTienHang");

        if (code == null || code.trim().isEmpty() || tongTienHangStr == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mã Voucher hoặc tổng tiền không hợp lệ!\"}");
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
            // Kiểm tra nguyên nhân không hợp lệ để phản hồi cụ thể cho nhân viên
            KhuyenMai km = khuyenMaiService.getKhuyenMaiByCode(code.trim());
            String errorMsg = "Mã Voucher không tồn tại hoặc đã ngừng hoạt động!";
            if (km != null) {
                if (km.getSoLuong() <= 0) {
                    errorMsg = "Mã Voucher " + code + " đã hết số lượng lượt sử dụng!";
                } else if (tongTienHang < km.getDonToiThieu()) {
                    errorMsg = "Hóa đơn chưa đạt giá trị tối thiểu " + String.format("%,d", km.getDonToiThieu()) + " đ để áp dụng mã!";
                } else if (!km.isPublic() && maKh != null) {
                    errorMsg = "Mã Voucher VIP này chỉ dành riêng cho các thành viên đạt thứ hạng cao!";
                }
            }
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + errorMsg + "\"}");
        }
    }

    /**
     * Lấy chi tiết hóa đơn (JSON) cho nhân viên thu ngân in bill mà không bị chặn bởi Admin Filter
     */
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

            // Tìm kiếm thông tin tên khách hàng hiển thị
            String tenKh = "Khách lẻ vãng lai";
            if (dh.getMaKh() != null) {
                KhachHang kh = khachHangService.getKhachHangById(dh.getMaKh());
                if (kh != null) tenKh = kh.getTenKh();
            }
            json.append("\"tenKhachHang\":\"").append(tenKh).append("\",");

            // Tìm kiếm thông tin tên nhân viên
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

                // Lấy tên sản phẩm hiển thị đầy đủ tiếng Việt có dấu
                String tenSp = "Sản phẩm " + item.getMaSp();
                SanPham sp = sanPhamService.getSanPhamById(item.getMaSp());
                if (sp != null) tenSp = sp.getTenSp();

                json.append("{");
                json.append("\"tenMon\":\"").append(tenSp).append("\",");
                json.append("\"tenSize\":\"").append(item.getMaSize() == 1 ? "S" : (item.getMaSize() == 2 ? "M" : "L")).append("\",");
                json.append("\"mucDa\":\"").append(item.getMucDa() != null ? item.getMucDa() : "100%").append("\",");
                json.append("\"mucDuong\":\"").append(item.getMucDuong() != null ? item.getMucDuong() : "100%").append("\",");
                json.append("\"soLuong\":").append(item.getSoLuong()).append(",");
                json.append("\"giaChot\":").append(item.getGiaChot()).append(",");
                json.append("\"toppings\":[");

                for (int j = 0; j < item.getToppingsList().size(); j++) {
                    ChiTietTopping tp = item.getToppingsList().get(j);

                    // Lấy tên topping hiển thị tiếng Việt có dấu
                    String tenTp = "Topping " + tp.getMaTp();
                    Topping topping = toppingService.getToppingById(tp.getMaTp());
                    if (topping != null) tenTp = topping.getTenTp();

                    json.append("{");
                    json.append("\"tenTopping\":\"").append(tenTp).append("\",");
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
    }

    /**
     * Nhận và chốt thanh toán hóa đơn quầy POS
     */
    private void performPOSCheckout(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
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

            // Chống lỗi lưu khóa chính bị NULL hoặc Race Condition: sinh ID duy nhất
            String maDh = "TEA" + System.currentTimeMillis();

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
            dh.setGhiChuDon(ghiChuDon);
            dh.setTrangThaiThanhToan(1); // POS luôn mặc định là Đã thanh toán
            dh.setTrangThaiDon(4);       // Hoàn thành luôn sau khi chốt giao dịch

            String[] arrMaSp = request.getParameterValues("item_maSp[]");
            String[] arrMaSize = request.getParameterValues("item_maSize[]");
            String[] arrSoLuong = request.getParameterValues("item_soLuong[]");
            String[] arrGiaChot = request.getParameterValues("item_giaChot[]");
            String[] arrMucDa = request.getParameterValues("item_mucDa[]");
            String[] arrMucDuong = request.getParameterValues("item_mucDuong[]");
            String[] arrGhiChuMon = request.getParameterValues("item_ghiChuMon[]");
            String[] arrToppingKeys = request.getParameterValues("item_toppingKeys[]");

            List<ChiTietDonHang> items = new ArrayList<>();
            if (arrMaSp != null) {
                for (int i = 0; i < arrMaSp.length; i++) {
                    ChiTietDonHang ctdh = new ChiTietDonHang();
                    ctdh.setMaSp(arrMaSp[i]);
                    ctdh.setMaSize(Integer.parseInt(arrMaSize[i]));
                    ctdh.setSoLuong(Integer.parseInt(arrSoLuong[i]));
                    ctdh.setGiaChot(Integer.parseInt(arrGiaChot[i]));
                    ctdh.setMucDa(arrMucDa[i]);
                    ctdh.setMucDuong(arrMucDuong[i]);
                    ctdh.setGhiChuMon(arrGhiChuMon[i]);

                    if (arrToppingKeys != null && i < arrToppingKeys.length && !arrToppingKeys[i].trim().isEmpty()) {
                        String[] toppingsRaw = arrToppingKeys[i].split("\\|");
                        List<ChiTietTopping> toppingsList = new ArrayList<>();
                        for (String tpRaw : toppingsRaw) {
                            String[] parts = tpRaw.split("_");
                            if (parts.length == 3) {
                                int maTp = Integer.parseInt(parts[0]);
                                int soLuongTp = Integer.parseInt(parts[1]);
                                int giaChotTp = Integer.parseInt(parts[2]);
                                toppingsList.add(new ChiTietTopping(0, maTp, soLuongTp, giaChotTp));
                            }
                        }
                        ctdh.setToppingsList(toppingsList);
                    }
                    items.add(ctdh);
                }
            }

            boolean isCheckedOut = donHangService.checkoutPOS(dh, items, currentStaff.getMaNv());
            if (isCheckedOut) {
                // Redirect kèm thông số tạo hóa đơn thành công
                response.sendRedirect(request.getContextPath() + "/pos?msg=createsuccess&orderId=" + dh.getMaDh());
            } else {
                request.setAttribute("error", "Đã xảy ra lỗi hệ thống trong quá trình chốt giao dịch POS!");
                doGet(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi định dạng dữ liệu đầu vào đơn hàng quầy POS", e);
            request.setAttribute("error", "Lỗi định dạng dữ liệu đầu vào đơn hàng!");
            doGet(request, response);
        }
    }
}
