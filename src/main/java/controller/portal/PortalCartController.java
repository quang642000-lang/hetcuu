package controller.portal;

import model.entity.ChiTietToppingGioHang;
import model.entity.GioHang;
import model.entity.KhachHang;
import model.entity.ChiTietGioHang;
import service.IGioHangService;
import service.impl.GioHangServiceImpl;
import repository.impl.GioHangRepoImpl;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PortalCartController", urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/delete", "/cart/toggle-select"})
public class PortalCartController extends HttpServlet {
    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            request.getSession(true).setAttribute("errorMessage", "Vui lòng đăng nhập tài khoản thành viên để xem giỏ hàng!");
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }
        String uri = request.getRequestURI();
        if (uri.endsWith("/cart/delete")) {
            performDeleteCartItem(request, response);
            return;
        }
        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
        int cartCount = (gh != null && gh.getChiTietGioHangList() != null) ? gh.getChiTietGioHangList().size() : 0;
        request.getSession().setAttribute("customerCartCount", cartCount);
        request.setAttribute("cart", gh);
        request.getRequestDispatcher("/views/portal/gio_hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);
        String requestedWith = request.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith) || "true".equals(request.getParameter("ajax"));

        if (session == null || session.getAttribute("customer") == null) {
            if (isAjax) {
                response.getWriter().write("NOT_LOGGED_IN");
            } else {
                session = request.getSession(true);
                session.setAttribute("errorMessage", "Vui lòng đăng nhập tài khoản thành viên để thực hiện mua nước!");
                response.sendRedirect(request.getContextPath() + "/customer/login");
            }
            return;
        }
        if (uri.endsWith("/cart/update")) {
            performUpdateQuantity(request, response);
            return;
        }
        if (uri.endsWith("/cart/toggle-select")) {
            performToggleSelect(request, response);
            return;
        }
        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        String maKh = currentCustomer.getMaKh();
        try {
            String maSp = request.getParameter("maSp");
            int maSize = Integer.parseInt(request.getParameter("maSize"));
            int soLuong = Integer.parseInt(request.getParameter("soLuong"));

            // CHỐT CHẶN PHÒNG THỦ: Khi chọn bánh ngọt/cafe nóng không có đá/đường, tham số gửi lên sẽ là null.
            // Gán giá trị mặc định tránh lỗi khóa ngoại và NOT NULL trong DB.
            String mucDa = request.getParameter("mucDa");
            if (mucDa == null || mucDa.trim().isEmpty()) {
                mucDa = "100% Đá";
            }
            String mucDuong = request.getParameter("mucDuong");
            if (mucDuong == null || mucDuong.trim().isEmpty()) {
                mucDuong = "100% Đường";
            }
            String ghiChuMon = request.getParameter("ghiChuMon");
            if (ghiChuMon == null || ghiChuMon.trim().isEmpty()) {
                ghiChuMon = "Normal";
            }

            String[] arrToppings = request.getParameterValues("toppings[]");
            List<ChiTietToppingGioHang> toppingList = new ArrayList<>();
            if (arrToppings != null) {
                for (String tpIdStr : arrToppings) {
                    String maTp = tpIdStr; // STRING Key TPxxxxx
                    int qty = 1;
                    String qtyStr = request.getParameter("topping_qty_" + maTp);
                    if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                        try {
                            qty = Integer.parseInt(qtyStr.trim());
                        } catch (NumberFormatException e) {
                            qty = 1;
                        }
                    }
                    toppingList.add(new ChiTietToppingGioHang(0L, maTp, qty));
                }
            }
            String maCtghStr = request.getParameter("maCtgh");
            if (maCtghStr != null && !maCtghStr.trim().isEmpty()) {
                long maCtgh = Long.parseLong(maCtghStr.trim());
                boolean updated = updateCartItemDetails(maCtgh, maSize, soLuong, mucDa, mucDuong, ghiChuMon);
                if (updated) {
                    GioHangRepoImpl.getInstance().removeToppingsFromChiTiet(maCtgh);
                    if (!toppingList.isEmpty()) {
                        for (ChiTietToppingGioHang tp : toppingList) {
                            GioHangRepoImpl.getInstance().addToppingToGioHang(maCtgh, tp.getMaTp(), tp.getSoLuongTp());
                        }
                    }
                    if (isAjax) {
                        response.getWriter().write("SUCCESS|" + request.getSession().getAttribute("customerCartCount"));
                    } else {
                        response.sendRedirect(request.getContextPath() + "/cart?msg=updatesuccess");
                    }
                } else {
                    if (isAjax) {
                        response.getWriter().write("FAILED");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/cart?msg=updatefailed");
                    }
                }
                return;
            }
            boolean success = gioHangService.addSanPhamToGioHang(maKh, maSp, maSize, soLuong, mucDa, mucDuong, ghiChuMon, toppingList);
            if (isAjax) {
                if (success) {
                    GioHang gh = gioHangService.getGioHangComplete(maKh);
                    int cartCount = (gh != null && gh.getChiTietGioHangList() != null) ? gh.getChiTietGioHangList().size() : 0;
                    request.getSession().setAttribute("customerCartCount", cartCount);
                    response.getWriter().write("SUCCESS|" + cartCount);
                } else {
                    response.getWriter().write("FAILED");
                }
            } else {
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/cart?msg=addsuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/product/detail?id=" + maSp + "&msg=addfailed");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (isAjax) {
                response.getWriter().write("ERROR");
            } else {
                response.sendRedirect(request.getContextPath() + "/products?msg=error");
            }
        }
    }

    private boolean updateCartItemDetails(long maCtgh, int maSize, int soLuong, String mucDa, String mucDuong, String ghiChuMon) {
        String sql = "UPDATE CHI_TIET_GIO_HANG SET ma_size = ?, so_luong = ?, muc_da = ?, muc_duong = ?, ghi_chu_mon = ? WHERE ma_ctgh = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maSize);
            ps.setInt(2, soLuong);
            ps.setString(3, mucDa != null ? mucDa : "100% Đá");
            ps.setString(4, mucDuong != null ? mucDuong : "100% Đường");
            ps.setString(5, ghiChuMon != null ? ghiChuMon : "Normal");
            ps.setLong(6, maCtgh);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void performUpdateQuantity(HttpServletRequest request, HttpServletResponse response) throws IOException {
        long maCtgh = Long.parseLong(request.getParameter("maCtgh"));
        int soLuongMoi = Integer.parseInt(request.getParameter("soLuong"));
        boolean success = gioHangService.updateSoLuongChiTiet(maCtgh, soLuongMoi);
        if (success) {
            response.getWriter().write("SUCCESS");
        } else {
            response.getWriter().write("FAILED");
        }
    }

    private void performDeleteCartItem(HttpServletRequest request, HttpServletResponse response) throws IOException {
        long maCtgh = Long.parseLong(request.getParameter("maCtgh"));
        boolean success = gioHangService.deleteChiTietGioHang(maCtgh);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/cart?msg=deletesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/cart?msg=deletefailed");
        }
    }

    private void performToggleSelect(HttpServletRequest request, HttpServletResponse response) throws IOException {
        long maCtgh = Long.parseLong(request.getParameter("maCtgh"));
        boolean isChon = "1".equals(request.getParameter("chon"));
        boolean success = gioHangService.updateTrangThaiChonMua(maCtgh, isChon);
        if (success) {
            response.getWriter().write("SUCCESS");
        } else {
            response.getWriter().write("FAILED");
        }
    }
}