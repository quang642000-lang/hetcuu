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
        if (action == null) {
            action = "list";
        }
        if ("view".equals(action)) {
            showLogDetail(request, response);
        } else {
            showLogList(request, response);
        }
    }

    private void showLogList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Collect dynamic filter parameters
        String search = request.getParameter("search");
        String filterAction = request.getParameter("action"); // Overriding list action with search action if specified
        if ("list".equalsIgnoreCase(filterAction) || "view".equalsIgnoreCase(filterAction)) {
            filterAction = ""; // Do not treat default route actions as search action types
        }

        String tableName = request.getParameter("tableName");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        List<NhatKyHoatDong> logs = nhatKyRepo.getFilteredLogs(search, filterAction, tableName, startDate, endDate);

        List<NhanVien> employees = nhanVienService.getAllNhanVien();
        request.setAttribute("employees", employees);

        // Match both 'logs' and 'logsList' variables to prevent any JSP EL redundant mismatch
        request.setAttribute("logs", logs);
        request.setAttribute("logsList", logs);

        // Preserve state of search inputs
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
