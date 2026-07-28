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
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * =========================================================================
 * TEA POS SYSTEM - CLIENT WEBSITE ONLINE CHECKOUT CONTROLLER
 * Fully optimized with Server-side Recalculation and Validation of totals.
 * Triet tieu hoan toan rui ro gian lan va thieu dong bo gia khi admin thay doi!
 * =========================================================================
 */
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

        // Anti-Browser Cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Generate Idempotency Token
        String checkoutToken = UUID.randomUUID().toString();
        session.setAttribute("checkoutToken", checkoutToken);
        request.setAttribute("checkoutToken", checkoutToken);

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        // Lay thong tin tuoi moi nhat tu Database de cap nhat vi diem Loyalty CRM
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

        // Tai danh sach Voucher ca nhan kha dung cho khach hang dua tren tong tien goc
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

        // 1. Chot chan bao mat Idempotency Token chong Double Checkout / Spam  Back
        String sessionToken = (String) session.getAttribute("checkoutToken");
        String paramToken = request.getParameter("checkoutToken");
        if (sessionToken == null || paramToken == null || !sessionToken.equals(paramToken)) {
            LOGGER.log(Level.WARNING, "⚠️ Phat hien hanh vi Double Checkout hoac Spam nut Back cua trinh duyet! Huy giao dich.");
            response.sendRedirect(request.getContextPath() + "/cart?msg=double_checkout_detected");
            return;
        }

        // Huy Token ngay lap tuc truoc khi xu ly nghiep vu de khoa luong chong trung lap
        session.removeAttribute("checkoutToken");

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        try {
            // ĐỌC CÁC THAM SỐ GỐC TỪ CLIENT ĐỂ ĐỐI SOÁT BẢO MẬT
            String maKm = request.getParameter("maKm");
            int diemSuDung = 0;
            try {
                String ptsParam = request.getParameter("diemSuDung");
                if (ptsParam != null && !ptsParam.trim().isEmpty()) {
                    diemSuDung = Integer.parseInt(ptsParam.trim());
                }
            } catch (NumberFormatException e) {
                diemSuDung = 0;
            }

            int maPt = 1;
            try {
                String ptParam = request.getParameter("maPt");
                if (ptParam != null && !ptParam.trim().isEmpty()) {
                    maPt = Integer.parseInt(ptParam.trim());
                }
            } catch (NumberFormatException e) {
                maPt = 1;
            }

            String ghiChuDon = request.getParameter("ghiChuDon");
            String henLayRaw = request.getParameter("thoiGianHenLay"); // Nhan moc gio tu select 24h
            if (henLayRaw == null || henLayRaw.trim().isEmpty()) {
                request.setAttribute("error", "Bat buoc phai hen gio den cua hang nhan nuoc!");
                doGet(request, response);
                return;
            }

            // ----------------================---------------------------------
            // TỐI ƯU ARCHITECTURE: TỰ ĐỘNG TÍNH LẠI VÀ THẨM ĐỊNH GIÁ TRÊN SERVER-SIDE
            // Triet tieu hoan toan rui ro khach can thiep gia de mua gia re hoac loi lech pha gia!
            // ----------------================---------------------------------
            GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
            List<ChiTietDonHang> orderItems = new ArrayList<>();
            int freshTongTienHang = 0;

            if (gh != null && gh.getChiTietGioHangList() != null) {
                for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                    if (item.isChonMua()) {
                        orderItems.add(mapCartToOrderDetail(item));
                        freshTongTienHang += calculateItemTotal(item);
                    }
                }
            }

            if (orderItems.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/cart?msg=empty_selection");
                return;
            }

            // A. Tinh lai gia tri giam gia Voucher tu Database an toan
            int freshTienGiamGia = 0;
            if (maKm != null && !maKm.trim().isEmpty() && !maKm.equalsIgnoreCase("null")) {
                KhuyenMai voucher = khuyenMaiService.getKhuyenMaiById(maKm.trim());
                if (voucher != null) {
                    boolean isVoucherValid = khuyenMaiService.validateVoucher(voucher.getMaCode(), freshTongTienHang, currentCustomer.getMaKh());
                    if (isVoucherValid) {
                        freshTienGiamGia = khuyenMaiService.calculateDiscount(voucher.getMaCode(), freshTongTienHang);
                    } else {
                        LOGGER.log(Level.WARNING, "⚠️ Phat hien hanh vi gian lan Voucher {0} khong hop le cho gio hang!", voucher.getMaCode());
                        maKm = null; // Vo hieu hoa voucher rác
                    }
                } else {
                    maKm = null;
                }
            }

            // B. Thm dinh diem tich luy CRM Loyalty de chong gian lan diem am/diem ao
            KhachHang freshDbCustomer = khachHangService.getKhachHangById(currentCustomer.getMaKh());
            if (diemSuDung > freshDbCustomer.getDiemTichLuy()) {
                LOGGER.log(Level.WARNING, "⚠️ Phat hien hanh vi can thiep diem CRM trai phep! Co su dung: {0}, Thuc te: {1}", new Object[]{diemSuDung, freshDbCustomer.getDiemTichLuy()});
                diemSuDung = freshDbCustomer.getDiemTichLuy();
            }
            if (diemSuDung < 0) diemSuDung = 0;

            int freshTienTruDiem = diemSuDung * 1000;
            int limitPrePoints = freshTongTienHang - freshTienGiamGia;
            if (limitPrePoints < 0) limitPrePoints = 0;
            if (freshTienTruDiem > limitPrePoints) {
                freshTienTruDiem = limitPrePoints;
                diemSuDung = freshTienTruDiem / 1000;
            }

            // C. Tinh toan thue VAT 8% va Tong phai tra cuoi cung chot cung dong nhat
            int billBeforeTax = freshTongTienHang - freshTienGiamGia - freshTienTruDiem;
            if (billBeforeTax < 0) billBeforeTax = 0;
            int freshVat = (int) Math.round(billBeforeTax * 0.08);
            int freshTongPhaiTra = billBeforeTax + freshVat;

            // GAN HOAN TOAN CAC GIA TRI MOI DUOC QUYET TOAN DUOI TANG SERVER
            int tongTienHang = freshTongTienHang;
            int tienGiamGia = freshTienGiamGia;
            int tienTruDiem = freshTienTruDiem;
            int tongPhaiTra = freshTongPhaiTra;

            // Gop Gio go tu Client ("15:30") voi Ngay hom nay (Today) thanh moc Timestamp day du
            LocalDate today = LocalDate.now();
            String fullDateTimeStr = today.toString() + " " + henLayRaw.trim() + ":00";
            Timestamp thoiGianHenLay = Timestamp.valueOf(fullDateTimeStr);

            // ĐỒNG BỘ CHUẨN HÓA MÃ HÓA ĐƠN AUTO-GENERATE TỪ SEQUENCE
            String maDh = donHangService.generateNextMaDh();

            // Khoi tao thuc the DonHang chuan bi ghi nhan CSDL
            DonHang dh = new DonHang();
            dh.setMaDh(maDh);
            dh.setMaKh(currentCustomer.getMaKh());
            dh.setMaPt(maPt);
            dh.setMaKm(maKm != null && !maKm.trim().isEmpty() ? maKm : null);
            dh.setLoaiDonHang(3); // 3: Don hang online Click & Collect dat truoc
            dh.setThoiGianHenLay(thoiGianHenLay);
            dh.setTongTienHang(tongTienHang);
            dh.setTienGiamGia(tienGiamGia);
            dh.setDiemSuDung(diemSuDung);
            dh.setTienTruDiem(tienTruDiem);
            dh.setTongPhaiTra(tongPhaiTra);
            dh.setGhiChuDon(ghiChuDon);
            dh.setTrangThaiThanhToan(0); // 0: Chua thanh toan
            dh.setTrangThaiDon(0);       // 0: Cho duyet/Cho xac nhan

            // Dat don hang online an toan trong mot Transaction duy nhat
            boolean placed = donHangService.placeOrderOnline(dh, orderItems);
            if (placed) {
                // Xoa sach cac mon da thanh toan thanh cong khoi gio hang truc tuyen
                if (gh != null && gh.getChiTietGioHangList() != null) {
                    for (ChiTietGioHang item : gh.getChiTietGioHangList()) {
                        if (item.isChonMua()) {
                            gioHangService.deleteChiTietGioHang(item.getMaCtgh());
                        }
                    }
                }

                // CẬP NHẬT LẠI VÍ ĐIỂM CỦA KHÁCH TRONG SESSION NGAY LẬP TỨC SAU KHI TRỪ ĐIỂM THÀNH CÔNG!
                KhachHang customerFreshAfterCheckout = khachHangService.getKhachHangById(currentCustomer.getMaKh());
                session.setAttribute("customer", customerFreshAfterCheckout);

                // Dong bo cap nhat lai Badge gio hang tuc thi
                GioHang freshGh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
                int remainCount = (freshGh != null && freshGh.getChiTietGioHangList() != null) ? freshGh.getChiTietGioHangList().size() : 0;
                session.setAttribute("customerCartCount", remainCount);

                if (maPt == 2) {
                    // Chuyen khoan VietQR: dua sang cong tao QR hoa don tu dong
                    response.sendRedirect(request.getContextPath() + "/portal/order/payment-qr?id=" + dh.getMaDh());
                } else {
                    // Tien mat: Chuyen huong truc tiep ve trang lich su theo doi don hang
                    response.sendRedirect(request.getContextPath() + "/profile/orders?msg=order_placed");
                }
            } else {
                request.setAttribute("error", "Loi: Thoi gian hen lay phai cach thoi diem hien tai toi thieu 15 phut!");
                doGet(request, response);
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.SEVERE, "Loi phan tich cu phap moc thoi gian hen lay Click & Collect", e);
            request.setAttribute("error", "Dinh dang gio hen nhan nuoc khong hop le!");
            doGet(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loi nghiep vu phat sinh trong qua trinh thanh toan checkout online", e);
            request.setAttribute("error", "He thong gap su co trong qua trinh ghi nhan don hang!");
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
        ctdh.setGiaChot(cartItem.getGiaBan()); // Chot gia san pham gốc tai thoi diem mua (Moi tuong thich dynamic)
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