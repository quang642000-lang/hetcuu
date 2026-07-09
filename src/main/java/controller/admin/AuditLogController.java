package controller.admin;

import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;
import repository.impl.NhatKyRepoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AuditLogController", urlPatterns = {"/admin/auditlog"})
public class AuditLogController extends HttpServlet {
    private final INhatKyRepository nhatKyRepository = NhatKyRepoImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if ("view".equals(action)) {
            // Hiển thị chi tiết bản ghi vết dữ liệu cũ/mới dạng JSON
            showLogDetail(request, response);
        } else {
            // Liệt kê toàn bộ danh sách nhật ký hoạt động
            showLogList(request, response);
        }
    }

    private void showLogList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filterNv = request.getParameter("filterNhanVien");
        List<NhatKyHoatDong> logs;

        if (filterNv != null && !filterNv.trim().isEmpty()) {
            logs = nhatKyRepository.getLogsByNhanVien(filterNv.trim());
        } else {
            logs = nhatKyRepository.getAllLogs();
        }

        request.setAttribute("logs", logs);
        request.setAttribute("filterNhanVien", filterNv);
        request.getRequestDispatcher("/views/admin/audit-list.jsp").forward(request, response);
    }

    private void showLogDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        long id = Long.parseLong(request.getParameter("id"));
        NhatKyHoatDong targetLog = null;

        // Duyệt tìm nhật ký theo mã log
        List<NhatKyHoatDong> allLogs = nhatKyRepository.getAllLogs();
        for (NhatKyHoatDong log : allLogs) {
            if (log.getMaLog() == id) {
                targetLog = log;
                break;
            }
        }

        if (targetLog != null) {
            request.setAttribute("log", targetLog);
            request.getRequestDispatcher("/views/admin/audit-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/auditlog?msg=notfound");
        }
    }
}