package controller.pos;

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

@WebServlet(name = "NhanDonOnlineController", urlPatterns = {"/pos/nhandon"})
public class NhanDonOnlineController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filterStatusStr = request.getParameter("status");
        int filterStatus = 0; // Mặc định hiển thị đơn Chờ xác nhận (status = 0)

        try {
            if (filterStatusStr != null && !filterStatusStr.trim().isEmpty()) {
                filterStatus = Integer.parseInt(filterStatusStr);
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        // Tải danh sách các đơn hàng theo trạng thái lọc
        List<DonHang> onlineOrders = donHangService.getDonHangByTrangThai(filterStatus);

        request.setAttribute("onlineOrders", onlineOrders);
        request.setAttribute("currentStatus", filterStatus);
        request.getRequestDispatcher("/views/pos/nhan_don.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        NhanVien currentStaff = (NhanVien) session.getAttribute("user");

        String maDh = request.getParameter("maDh");
        int trangThaiMoi = Integer.parseInt(request.getParameter("trangThaiMoi"));
        String lyDoHuy = request.getParameter("lyDoHuy");

        // Thực hiện cập nhật trạng thái đơn hàng kèm lưu nhật ký kiểm toán hệ thống
        boolean success = donHangService.updateTrangThaiDon(maDh, trangThaiMoi, currentStaff.getMaNv(), lyDoHuy);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=" + trangThaiMoi + "&msg=updatesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=" + trangThaiMoi + "&msg=updatefailed");
        }
    }
}
