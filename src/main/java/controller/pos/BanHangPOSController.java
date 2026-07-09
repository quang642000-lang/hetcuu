package controller.pos;

import com.teapos.model.entity.*;
import com.teapos.service.*;
import com.teapos.service.impl.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "BanHangPOSController", urlPatterns = {"/pos", "/pos/search-customer", "/pos/checkout"})
public class BanHangPOSController extends HttpServlet {
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();

        if (uri.endsWith("/pos/search-customer")) {
            performSearchCustomer(request, response);
            return;
        }

        // LUỒNG MẶC ĐỊNH: TẢI GIAO DIỆN BÁN HÀNG TẠI QUẦY POS
        List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
        List<SanPham> products = sanPhamService.getAllSanPham();
        List<Topping> toppings = toppingService.getActiveTopping();

        // Nạp sẵn toàn bộ size biến thể kèm giá cho từng sản phẩm mẹ để Javascript xử lý realtime
        for (SanPham sp : products) {
            sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
        }

        request.setAttribute("categories", categories);
        request.setAttribute("products", products);
        request.setAttribute("toppings", toppings);
        request.getRequestDispatcher("/views/pos/pos.jsp").forward(request, response);
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
            // Trả về chuỗi JSON thông tin khách hàng thành viên CRM
            String json = String.format(
                    "{\"status\":\"SUCCESS\",\"maKh\":\"%s\",\"tenKh\":\"%s\",\"diemTichLuy\":%d,\"maHang\":%d}",
                    kh.getMaKh(), kh.getTenKh(), kh.getDiemTichLuy(), kh.getMaHang()
            );
            response.getWriter().write(json);
        } else {
            response.getWriter().write("{\"status\":\"NOT_FOUND\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        if (uri.endsWith("/pos/checkout")) {
            performPOSCheckout(request, response);
        }
    }

    private void performPOSCheckout(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        NhanVien currentStaff = (NhanVien) session.getAttribute("user");

        try {
            // 1. Đọc thông tin cơ bản của đơn hàng từ Form POS gửi lên
            String maKh = request.getParameter("maKh"); // Có thể trống nếu là khách vãng lai
            int loaiDonHang = Integer.parseInt(request.getParameter("loaiDonHang")); // 1: TẠI QUẦN, 2: MANG ĐI
            int maPt = Integer.parseInt(request.getParameter("maPt")); // Phương thức thanh toán (1: Tiền mặt, 2: QR Chuyển khoản)
            String maKm = request.getParameter("maKm"); // Có thể trống nếu không áp voucher
            int tongTienHang = Integer.parseInt(request.getParameter("tongTienHang"));
            int tienGiamGia = Integer.parseInt(request.getParameter("tienGiamGia"));
            int diemSuDung = Integer.parseInt(request.getParameter("diemSuDung"));
            int tienTruDiem = Integer.parseInt(request.getParameter("tienTruDiem"));
            int tongPhaiTra = Integer.parseInt(request.getParameter("tongPhaiTra"));
            String ghiChuDon = request.getParameter("ghiChuDon");

            // Khởi tạo đối tượng DonHang
            DonHang dh = new DonHang();
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
            dh.setTrangThaiThanhToan(1); // POS luôn mặc định là Đã thanh toán khi chốt đơn thành công
            dh.setTrangThaiDon(4); // Trạng thái: Hoàn thành luôn

            // 2. Bóc tách danh sách các ly nước và toppings tương ứng được gửi lên dưới dạng mảng song song (Parallel Arrays)
            String[] arrMaSp = request.getParameterValues("item_maSp[]");
            String[] arrMaSize = request.getParameterValues("item_maSize[]");
            String[] arrSoLuong = request.getParameterValues("item_soLuong[]");
            String[] arrGiaChot = request.getParameterValues("item_giaChot[]");
            String[] arrMucDa = request.getParameterValues("item_mucDa[]");
            String[] arrMucDuong = request.getParameterValues("item_mucDuong[]");
            String[] arrGhiChuMon = request.getParameterValues("item_ghiChuMon[]");
            String[] arrToppingKeys = request.getParameterValues("item_toppingKeys[]"); // Lưu chuỗi định dạng "maTp_soLuong|maTp_soLuong" của từng ly

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

                    // Bóc tách toppings đi kèm ly nước thứ i
                    if (arrToppingKeys != null && i < arrToppingKeys.length && !arrToppingKeys[i].trim().isEmpty()) {
                        String[] toppingsRaw = arrToppingKeys[i].split("\\|"); // Tách các loại Topping
                        List<ChiTietTopping> toppingsList = new ArrayList<>();
                        for (String tpRaw : toppingsRaw) {
                            String[] parts = tpRaw.split("_");
                            if (parts.length == 3) { // maTp_soLuong_giaChot
                                int maTp = Integer.parseInt(parts);
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

            // 3. Gọi Service chốt hóa đơn POS an toàn dưới dạng Transaction
            boolean isCheckedOut = donHangService.checkoutPOS(dh, items, currentStaff.getMaNv());
            if (isCheckedOut) {
                response.sendRedirect(request.getContextPath() + "/pos?msg=createsuccess&orderId=" + dh.getMaDh());
            } else {
                request.setAttribute("error", "Đã xảy ra lỗi hệ thống trong quá trình chốt giao dịch POS!");
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi định dạng dữ liệu đầu vào đơn hàng!");
            doGet(request, response);
        }
    }
}