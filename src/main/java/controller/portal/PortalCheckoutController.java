package controller.portal;

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
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PortalCheckoutController", urlPatterns = {"/checkout", "/checkout/place"})
public class PortalCheckoutController extends HttpServlet {
    // Thay thế printStackTrace() bằng Logger chuẩn doanh nghiệp
    private static final Logger LOGGER = Logger.getLogger(PortalCheckoutController.class.getName());

    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());

        // Lọc ra các món được tick chọn mua và tính tổng tiền bằng Helper Method (Giải quyết trùng lặp)
        List<ChiTietGioHang> checkoutItems = new ArrayList<>();
        int tongTienHang = 0;

        if (gh != null && gh.getChiTietGioHangList() != null) {
            for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                if (item.isChonMua()) {
                    checkoutItems.add(item);
                    tongTienHang += calculateItemTotal(item);
                }
            }
        }

        if (checkoutItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?msg=empty_selection");
            return;
        }

        // Tải danh sách Voucher cá nhân khả dụng
        List<KhuyenMai> activeVouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(tongTienHang, currentCustomer.getMaKh());

        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("tongTienHang", tongTienHang);
        request.setAttribute("activeVouchers", activeVouchers);
        request.getRequestDispatcher("/views/portal/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");

        try {
            int tongTienHang = Integer.parseInt(request.getParameter("tongTienHang"));
            String maKm = request.getParameter("maKm");
            int tienGiamGia = Integer.parseInt(request.getParameter("tienGiamGia"));
            int diemSuDung = Integer.parseInt(request.getParameter("diemSuDung"));
            int tienTruDiem = Integer.parseInt(request.getParameter("tienTruDiem"));
            int tongPhaiTra = Integer.parseInt(request.getParameter("tongPhaiTra"));
            int maPt = Integer.parseInt(request.getParameter("maPt"));
            String ghiChuDon = request.getParameter("ghiChuDon");

            String henLayRaw = request.getParameter("thoiGianHenLay");
            if (henLayRaw == null || henLayRaw.trim().isEmpty()) {
                request.setAttribute("error", "Bắt buộc phải hẹn giờ đến cửa hàng nhận nước!");
                doGet(request, response);
                return;
            }
            Timestamp thoiGianHenLay = Timestamp.valueOf(henLayRaw.replace("T", " ") + ":00");

            // Khởi tạo thực thể DonHang [5]
            DonHang dh = new DonHang();
            dh.setMaKh(currentCustomer.getMaKh());
            dh.setMaPt(maPt);
            dh.setMaKm(maKm != null && !maKm.trim().isEmpty() ? maKm : null);
            dh.setLoaiDonHang(3);
            dh.setThoiGianHenLay(thoiGianHenLay);
            dh.setTongTienHang(tongTienHang);
            dh.setTienGiamGia(tienGiamGia);
            dh.setDiemSuDung(diemSuDung);
            dh.setTienTruDiem(tienTruDiem);
            dh.setTongPhaiTra(tongPhaiTra);
            dh.setGhiChuDon(ghiChuDon);
            dh.setTrangThaiThanhToan(0);
            dh.setTrangThaiDon(0);

            // Ánh xạ chi tiết giỏ sang chi tiết đơn thông qua Helper Method (Giải quyết trùng lặp code)
            GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
            List<ChiTietDonHang> orderItems = new ArrayList<>();

            if (gh != null && gh.getChiTietGioHangList() != null) {
                for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                    if (item.isChonMua()) {
                        orderItems.add(mapCartToOrderDetail(item));
                    }
                }
            }

            boolean placed = donHangService.placeOrderOnline(dh, orderItems);
            if (placed) {
                // Xóa sạch các món đã thanh toán khỏi giỏ hàng
                if (gh != null && gh.getChiTietGioHangList() != null) {
                    for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                        if (item.isChonMua()) {
                            gioHangService.deleteChiTietGioHang(item.getMaCtgh());
                        }
                    }
                }

                if (maPt == 2) {
                    response.sendRedirect(request.getContextPath() + "/portal/order/payment-qr?id=" + dh.getMaDh());
                } else {
                    response.sendRedirect(request.getContextPath() + "/profile/orders?msg=order_placed");
                }
            } else {
                request.setAttribute("error", "Lỗi: Thời gian hẹn đến lấy nước phải cách hiện tại tối thiểu 15 phút!");
                doGet(request, response);
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.SEVERE, "Lỗi phân tích cú pháp thời gian hẹn lấy nước đặt online", e);
            request.setAttribute("error", "Định dạng thời gian hẹn lấy không chính xác!");
            doGet(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xảy ra trong quá trình đặt hàng online", e);
            request.setAttribute("error", "Đã xảy ra sai sót trong quá trình xử lý giao dịch!");
            doGet(request, response);
        }
    }

    // ==========================================
    // CÁC PHƯƠNG THỨC HỖ TRỢ (HELPER METHODS) - CHỐNG TRÙNG LẶP CODE CỰC KỲ HIỆU QUẢ
    // ==========================================

    /**
     * Tính tổng giá trị của một món hàng trong giỏ bao gồm cả Toppings đi kèm.
     */
    private int calculateItemTotal(ChiTietGioHang item) {
        int toppingSum = 0;
        if (item.getToppingGioHangList() != null) {
            for (ChiTietToppingGioHang tp : item.getToppingGioHangList()) {
                toppingSum += tp.getGiaTp() * tp.getSoLuongTp(); // Gọi trực tiếp getter mới thêm
            }
        }
        return (item.getGiaBan() + toppingSum) * item.getSoLuong();
    }

    /**
     * Ánh xạ từ dòng chi tiết giỏ hàng sang chi tiết đơn hàng (Snapshot giá bán thực tế) [6].
     */
    private ChiTietDonHang mapCartToOrderDetail(ChiTietGioHang cartItem) {
        ChiTietDonHang ctdh = new ChiTietDonHang();
        ctdh.setMaSp(cartItem.getMaSp());
        ctdh.setMaSize(cartItem.getMaSize());
        ctdh.setSoLuong(cartItem.getSoLuong());
        ctdh.setGiaChot(cartItem.getGiaBan()); // Chốt giá sản phẩm
        ctdh.setMucDa(cartItem.getMucDa());
        ctdh.setMucDuong(cartItem.getMucDuong());
        ctdh.setGhiChuMon(cartItem.getGhiChuMon());

        List<ChiTietTopping> toppingsList = new ArrayList<>();
        if (cartItem.getToppingGioHangList() != null) {
            for (ChiTietToppingGioHang tp : cartItem.getToppingGioHangList()) {
                // Chốt giá trị Topping tại thời điểm đặt đơn [7, 8]
                toppingsList.add(new ChiTietTopping(0, tp.getMaTp(), tp.getSoLuongTp(), tp.getGiaTp()));
            }
        }
        ctdh.setToppingsList(toppingsList);
        return ctdh;
    }
}
