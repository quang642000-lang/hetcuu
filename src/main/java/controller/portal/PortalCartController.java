package controller.portal;

import model.entity.ChiTietToppingGioHang;
import model.entity.GioHang;
import model.entity.KhachHang;
import service.IGioHangService;
import service.impl.GioHangServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PortalCartController", urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/delete", "/cart/toggle-select"})
public class PortalCartController extends HttpServlet {
    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect(request.getContextPath() + "/customer/login");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
        GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());

        request.setAttribute("cart", gh);
        request.getRequestDispatcher("/views/portal/gio_hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("customer") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "SESSION_EXPIRED");
            return;
        }

        KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");

        if (uri.endsWith("/cart/add")) {
            performAddToCart(request, response, currentCustomer.getMaKh());
        } else if (uri.endsWith("/cart/update")) {
            performUpdateQuantity(request, response);
        } else if (uri.endsWith("/cart/delete")) {
            performDeleteCartItem(request, response);
        } else if (uri.endsWith("/cart/toggle-select")) {
            performToggleSelect(request, response);
        }
    }

    private void performAddToCart(HttpServletRequest request, HttpServletResponse response, String maKh) throws IOException {
        try {
            String maSp = request.getParameter("maSp");
            int maSize = Integer.parseInt(request.getParameter("maSize"));
            int soLuong = Integer.parseInt(request.getParameter("soLuong"));
            String mucDa = request.getParameter("mucDa");
            String mucDuong = request.getParameter("mucDuong");
            String ghiChuMon = request.getParameter("ghiChuMon");

            // Bóc tách danh sách Toppings chọn đi kèm ly nước này từ Form
            String[] arrToppings = request.getParameterValues("toppings[]");
            List<ChiTietToppingGioHang> toppingList = new ArrayList<>();
            if (arrToppings != null) {
                for (String tpIdStr : arrToppings) {
                    int maTp = Integer.parseInt(tpIdStr);
                    // Mặc định số lượng là 1 phần topping cho mỗi ly nước
                    toppingList.add(new ChiTietToppingGioHang(0L, maTp, 1));
                }
            }

            boolean success = gioHangService.addSanPhamToGioHang(maKh, maSp, maSize, soLuong, mucDa, mucDuong, ghiChuMon, toppingList);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/cart?msg=addsuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/product/detail?id=" + maSp + "&msg=addfailed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/products?msg=error");
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