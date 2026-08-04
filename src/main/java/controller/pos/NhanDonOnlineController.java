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
import java.util.ArrayList;
import java.util.List;

/**
 * =========================================================================
 * TEA POS SYSTEM - ONLINE ORDER RECEIVING CONTROLLER (v2 - Refund Aware)
 * Optimized to filter and ONLY display online orders (loai_don_hang = 3),
 * preventing POS in-store orders from cluttering the online dispatch UI.
 * Fully pre-loads all product details and toppings dynamically.
 * Supported manual refund operation on canceled paid orders.
 * =========================================================================
 */
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
        List<DonHang> rawOrders = donHangService.getDonHangByTrangThai(filterStatus);
        List<DonHang> onlineOrders = new ArrayList<>();

        // VỐN DĨ CHỈ LỌC ĐƠN ĐẶT ONLINE (loai_don_hang = 3) CHO TRANG ĐIỀU PHỐI ONLINE
        if (rawOrders != null) {
            for (DonHang dh : rawOrders) {
                if (dh.getLoaiDonHang() == 3) {
                    DonHang freshDh = donHangService.getDonHangById(dh.getMaDh());
                    if (freshDh != null) {
                        dh.setChiTietDonHangList(freshDh.getChiTietDonHangList());
                    }
                    onlineOrders.add(dh);
                }
            }
        }
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
        String action = request.getParameter("action");

        // NGHIỆP VỤ HOÀN TIỀN ĐƠN HỦY
        if ("refund".equals(action)) {
            boolean success = donHangService.updateTrangThaiThanhToan(maDh, 2); // 2: Đã hoàn tiền
            if (success) {
                String ip = util.WebUtil.getRemoteIP(request);
                repository.impl.NhatKyRepoImpl.recordActivity(
                        currentStaff.getMaNv(),
                        "HOÀN_TIỀN_ĐƠN_HỦY",
                        "DON_HANG",
                        maDh,
                        "Trạng thái thanh toán: 1 (Đã thanh toán)",
                        "Trạng thái thanh toán: 2 (Đã hoàn tiền)",
                        ip
                );
                response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=5&msg=updatesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=5&msg=updatefailed");
            }
            return;
        }

        // NGHIỆP VỤ CẬP NHẬT TRẠNG THÁI ĐƠN HÀNG THÔNG THƯỜNG
        int trangThaiMoi = Integer.parseInt(request.getParameter("trangThaiMoi"));
        String lyDoHuy = request.getParameter("lyDoHuy");
        boolean success = donHangService.updateTrangThaiDon(maDh, trangThaiMoi, currentStaff.getMaNv(), lyDoHuy);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=" + trangThaiMoi + "&msg=updatesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/pos/nhandon?status=" + trangThaiMoi + "&msg=updatefailed");
        }
    }
}
