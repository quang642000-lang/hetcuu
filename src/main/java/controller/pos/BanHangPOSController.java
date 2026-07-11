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

            // Xây dựng chuỗi JSON trả về có cấu trúc lồng nhau
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
            dh.setTrangThaiThanhToan(1); // POS luôn mặc định là Đã thanh toán khi in hóa đơn thành công [13]
            dh.setTrangThaiDon(4); // Hoàn thành luôn

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