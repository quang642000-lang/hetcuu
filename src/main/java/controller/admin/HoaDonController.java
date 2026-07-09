package controller.admin;

import model.entity.DonHang;
import model.entity.NhanVien;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HoaDonController", urlPatterns = {"/admin/hoadon"})
public class HoaDonController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                showList(request, response);
                break;
            case "view":
                showDetail(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String statusStr = request.getParameter("status");
        List<DonHang> orders;

        if (statusStr != null && !statusStr.trim().isEmpty()) {
            int status = Integer.parseInt(statusStr);
            orders = donHangService.getDonHangByTrangThai(status);
        } else {
            orders = donHangService.getAllDonHang();
        }

        request.setAttribute("orders", orders);
        request.setAttribute("statusFilter", statusStr);
        request.getRequestDispatcher("/views/admin/hoa_don.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        DonHang dh = donHangService.getDonHangById(id);
        if (dh != null) {
            request.setAttribute("order", dh);
            request.getRequestDispatcher("/views/admin/hoa_don.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?msg=notfound");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            performUpdateStatus(request, response);
        }
    }

    private void performUpdateStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maDh = request.getParameter("maDh");
        int status = Integer.parseInt(request.getParameter("trangThaiDon"));
        String lyDoHuy = request.getParameter("lyDoHuy");

        HttpSession session = request.getSession(false);
        String maNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            maNv = ((NhanVien) session.getAttribute("user")).getMaNv();
        }

        boolean success = donHangService.updateTrangThaiDon(maDh, status, maNv, lyDoHuy);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/hoadon?action=view&id=" + maDh + "&msg=updatefailed");
        }
    }
}
