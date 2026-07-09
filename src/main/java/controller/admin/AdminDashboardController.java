package controller.admin;

import model.dto.*;
import service.IThongKeService;
import service.impl.ThongKeServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    private final IThongKeService thongKeService = ThongKeServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Thiết lập khoảng thời gian mặc định (Từ đầu tháng hiện tại đến hôm nay)
        long nowMillis = System.currentTimeMillis();
        Date denNgay = new Date(nowMillis);

        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
        Date tuNgay = new Date(cal.getTimeInMillis());

        // 2. Tiếp nhận bộ lọc thời gian từ Client (nếu có)
        String tuNgayStr = request.getParameter("tuNgay");
        String denNgayStr = request.getParameter("denNgay");

        try {
            if (tuNgayStr != null && !tuNgayStr.trim().isEmpty()) {
                tuNgay = Date.valueOf(tuNgayStr);
            }
            if (denNgayStr != null && !denNgayStr.trim().isEmpty()) {
                denNgay = Date.valueOf(denNgayStr);
            }
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }

        // 3. Gọi Service thống kê dữ liệu
        DashboardKpiDTO kpis = thongKeService.getDashboardKpis(tuNgay, denNgay);
        List<DoanhThuNgayDTO> doanhThuNgay = thongKeService.getDoanhThuTheoNgay(tuNgay, denNgay);
        List<DoanhThuThangDTO> doanhThuThang = thongKeService.getDoanhThuTheoThang();
        List<TopSanPhamDTO> topSanPhams = thongKeService.getTop10SanPhamBanChay();
        List<TopNhanVienDTO> topNhanViens = thongKeService.getTop10NhanVienDoanhThu();
        List<DoanhThuDanhMucDTO> doanhThuDanhMuc = thongKeService.getDoanhThuTheoDanhMuc();

        // 4. Đẩy dữ liệu ra giao diện JSP hiển thị Dashboard
        request.setAttribute("kpis", kpis);
        request.setAttribute("doanhThuNgay", doanhThuNgay);
        request.setAttribute("doanhThuThang", doanhThuThang);
        request.setAttribute("topSanPhams", topSanPhams);
        request.setAttribute("topNhanViens", topNhanViens);
        request.setAttribute("doanhThuDanhMuc", doanhThuDanhMuc);
        request.setAttribute("tuNgay", tuNgay.toString());
        request.setAttribute("denNgay", denNgay.toString());

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}