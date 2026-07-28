package controller.admin;

import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.impl.NhatKyRepoImpl;
import service.INhanVienService;
import service.impl.NhanVienServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AuditLogController", urlPatterns = {"/admin/auditlog", "/admin/audit-log", "/admin/nhatky", "/admin/nhat-ky"})
public class AuditLogController extends HttpServlet {
    private final NhatKyRepoImpl nhatKyRepo = NhatKyRepoImpl.getInstance();
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("view".equals(action)) {
            showLogDetail(request, response);
            return;
        }

        String search = request.getParameter("search");
        String filterAction = request.getParameter("actionFilter");
        if (filterAction == null) filterAction = request.getParameter("action"); // backup
        if ("view".equals(filterAction)) filterAction = ""; // avoid conflict

        String tableName = request.getParameter("tableName");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        // Handle Server-Side Pagination Parameter
        int page = 1;
        int pageSize = 10;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        // Gọi hàm phân trang Server-side cực kỳ nhanh gọn
        List<NhatKyHoatDong> logs = nhatKyRepo.getFilteredLogsServerSide(search, filterAction, tableName, startDate, endDate, page, pageSize);
        int totalLogs = nhatKyRepo.getFilteredLogsCount(search, filterAction, tableName, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalLogs / pageSize);
        if (totalPages <= 0) totalPages = 1;

        List<NhanVien> employees = nhanVienService.getAllNhanVien();

        request.setAttribute("employees", employees);
        request.setAttribute("logs", logs);
        request.setAttribute("logsList", logs); // Đồng bộ cả 2 mốc biến tránh lỗi EL JSTL

        // Cấu hình mốc phân trang gửi ra JSP
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalLogs", totalLogs);
        request.setAttribute("pageSize", pageSize);

        // Giữ lại trạng thái thanh công cụ tìm kiếm
        request.setAttribute("paramSearch", search);
        request.setAttribute("paramAction", filterAction);
        request.setAttribute("paramTableName", tableName);
        request.setAttribute("paramStartDate", startDate);
        request.setAttribute("paramEndDate", endDate);

        request.getRequestDispatcher("/views/admin/nhat_ky.jsp").forward(request, response);
    }

    private void showLogDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/audit-log?msg=error");
            return;
        }
        try {
            long id = Long.parseLong(idStr.trim());
            NhatKyHoatDong targetLog = null;
            List<NhatKyHoatDong> allLogs = nhatKyRepo.getAllLogs();
            if (allLogs != null) {
                for (NhatKyHoatDong log : allLogs) {
                    if (log.getMaLog() == id) {
                        targetLog = log;
                        break;
                    }
                }
            }
            if (targetLog != null) {
                List<NhanVien> employees = nhanVienService.getAllNhanVien();
                request.setAttribute("employees", employees);
                request.setAttribute("log", targetLog);
                request.getRequestDispatcher("/views/admin/nhat_ky.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/audit-log?msg=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/audit-log?msg=error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}