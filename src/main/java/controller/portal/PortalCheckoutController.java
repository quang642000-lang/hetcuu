package controller.portal;

import model.entity.*;
import service.*;
import service.impl.*;
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
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PortalCheckoutController", urlPatterns = {"/checkout", "/checkout/place"})
public class PortalCheckoutController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PortalCheckoutController.class.getName());
    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();
    private final IKhuyenMaiService khuyenMaiService = KhuyenMaiServiceImpl.getInstance();
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private final IKhachHangService khachHangService = KhachHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        // Lấy thông tin tươi mới nhất từ Database để cập nhật ví điểm Loyalty CRM
        KhachHang freshCustomer = khachHangService.getKhachHangById(currentCustomer.getMaKh());
        session.setAttribute("customer", freshCustomer);

        GioHang gh = gioHangService.getGioHangComplete(freshCustomer.getMaKh());
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

        // Tải danh sách Voucher cá nhân khả dụng cho khách hàng dựa trên tổng tiền gốc
        List<KhuyenMai> activeVouchers = khuyenMaiService.getVouchersKhaDungForKhachHang(tongTienHang, freshCustomer.getMaKh());

        request.setAttribute("checkoutItems", checkoutItems);
        request.setAttribute("tongTienHang", tongTienHang);
        request.setAttribute("activeVouchers", activeVouchers);
        request.getRequestDispatcher("/views/portal/thanh_toan.jsp").forward(request, response);
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
            String henLayRaw = request.getParameter("thoiGianHenLay"); // Chỉ nhận "15:30" (Gi giờ lấy trong ngày)

            if (henLayRaw == null || henLayRaw.trim().isEmpty()) {
                request.setAttribute("error", "Bắt buộc phải hẹn giờ đến cửa hàng nhận nước!");
                doGet(request, response);
                return;
            }

            // CẢI TIẾN BẢO MẬT: Kiểm tra can thiệp điểm CRM trái phép từ phía Client
            KhachHang freshDbCustomer = khachHangService.getKhachHangById(currentCustomer.getMaKh());
            if (diemSuDung > freshDbCustomer.getDiemTichLuy()) {
                request.setAttribute("error", "Số điểm CRM yêu cầu khấu trừ vượt quá số dư tích lũy hiện có!");
                doGet(request, response);
                return;
            }
            if (tienTruDiem != (diemSuDung * 1000)) {
                request.setAttribute("error", "Thuật toán quy đổi tỷ lệ điểm CRM không hợp lệ (1 Điểm = 1.000 VNĐ)!");
                doGet(request, response);
                return;
            }

            // CẢI TIẾN: Gộp Giờ gõ từ Client ("15:30") với Ngày hôm nay (Today) thành mốc Timestamp đầy đủ
            LocalDate today = LocalDate.now();
            String fullDateTimeStr = today.toString() + " " + henLayRaw.trim() + ":00";
            Timestamp thoiGianHenLay = Timestamp.valueOf(fullDateTimeStr);

            // Sinh mã hóa đơn online tự động từ sequence của SQL Server
            String maDh = "TEA" + System.currentTimeMillis(); // Fallback
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT NEXT VALUE FOR seq_DonHang")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        maDh = "TEA" + rs.getLong(1);
                    }
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Lỗi khi nạp sequence sinh ma_dh cho đơn hàng online", e);
            }

            // Khởi tạo thực thể DonHang chuẩn bị ghi nhận CSDL
            DonHang dh = new DonHang();
            dh.setMaDh(maDh);
            dh.setMaKh(currentCustomer.getMaKh());
            dh.setMaPt(maPt);
            dh.setMaKm(maKm != null && !maKm.trim().isEmpty() ? maKm : null);
            dh.setLoaiDonHang(3); // 3: Đơn hàng online Click & Collect đặt trước
            dh.setThoiGianHenLay(thoiGianHenLay);
            dh.setTongTienHang(tongTienHang);
            dh.setTienGiamGia(tienGiamGia);
            dh.setDiemSuDung(diemSuDung);
            dh.setTienTruDiem(tienTruDiem);
            dh.setTongPhaiTra(tongPhaiTra);
            dh.setGhiChuDon(ghiChuDon);
            dh.setTrangThaiThanhToan(0); // 0: Chưa thanh toán
            dh.setTrangThaiDon(0);       // 0: Chờ duyệt/Chờ xác nhận

            // Ánh xạ chi tiết giỏ hàng sang chi tiết đơn hàng
            GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
            List<ChiTietDonHang> orderItems = new ArrayList<>();
            if (gh != null && gh.getChiTietGioHangList() != null) {
                for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                    if (item.isChonMua()) {
                        orderItems.add(mapCartToOrderDetail(item));
                    }
                }
            }

            // Đặt đơn hàng online an toàn trong một Transaction duy nhất
            boolean placed = donHangService.placeOrderOnline(dh, orderItems);
            if (placed) {
                // Xóa sạch các món đã thanh toán thành công khỏi giỏ hàng trực tuyến
                if (gh != null && gh.getChiTietGioHangList() != null) {
                    for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                        if (item.isChonMua()) {
                            gioHangService.deleteChiTietGioHang(item.getMaCtgh());
                        }
                    }
                }

                // Đồng bộ cập nhật lại Badge giỏ hàng tức thì
                GioHang freshGh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
                int remainCount = (freshGh != null && freshGh.getChiTietGioHangList() != null) ? freshGh.getChiTietGioHangList().size() : 0;
                session.setAttribute("customerCartCount", remainCount);

                if (maPt == 2) {
                    // Chuyển khoản VietQR: đưa sang cổng tạo QR hóa đơn tự động
                    response.sendRedirect(request.getContextPath() + "/portal/order/payment-qr?id=" + dh.getMaDh());
                } else {
                    // Tiền mặt: Chuyển hướng trực tiếp về trang lịch sử theo dõi đơn hàng
                    response.sendRedirect(request.getContextPath() + "/profile/orders?msg=order_placed");
                }
            } else {
                request.setAttribute("error", "Lỗi: Thời gian hẹn lấy phải cách thời điểm hiện tại tối thiểu 15 phút!");
                doGet(request, response);
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.SEVERE, "Lỗi phân tích cú pháp mốc thời gian hẹn lấy Click & Collect", e);
            request.setAttribute("error", "Định dạng giờ hẹn nhận nước không hợp lệ!");
            doGet(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi nghiệp vụ phát sinh trong quá trình thanh toán checkout online", e);
            request.setAttribute("error", "Hệ thống gặp sự cố trong quá trình ghi nhận đơn hàng!");
            doGet(request, response);
        }
    }

    private int calculateItemTotal(ChiTietGioHang item) {
        int toppingSum = 0;
        if (item.getToppingGioHangList() != null) {
            for (ChiTietToppingGioHang tp : item.getToppingGioHangList()) {
                toppingSum += tp.getGiaTp() * tp.getSoLuongTp();
            }
        }
        return (item.getGiaBan() + toppingSum) * item.getSoLuong();
    }

    private ChiTietDonHang mapCartToOrderDetail(ChiTietGioHang cartItem) {
        ChiTietDonHang ctdh = new ChiTietDonHang();
        ctdh.setMaSp(cartItem.getMaSp());
        ctdh.setMaSize(cartItem.getMaSize());
        ctdh.setSoLuong(cartItem.getSoLuong());
        ctdh.setGiaChot(cartItem.getGiaBan()); // Chốt giá sản phẩm gốc tại thời điểm mua
        ctdh.setMucDa(cartItem.getMucDa());
        ctdh.setMucDuong(cartItem.getMucDuong());
        ctdh.setGhiChuMon(cartItem.getGhiChuMon());

        List<ChiTietTopping> toppingsList = new ArrayList<>();
        if (cartItem.getToppingGioHangList() != null) {
            for (ChiTietToppingGioHang tp : cartItem.getToppingGioHangList()) {
                toppingsList.add(new ChiTietTopping(0, tp.getMaTp(), tp.getSoLuongTp(), tp.getGiaTp()));
            }
        }
        ctdh.setToppingsList(toppingsList);
        return ctdh;
    }
}
