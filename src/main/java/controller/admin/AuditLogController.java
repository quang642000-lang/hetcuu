package controller.admin;

import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.INhatKyRepository;
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

@WebServlet(name = "AuditLogController", urlPatterns = {"/admin/auditlog"})
public class AuditLogController extends HttpServlet {
    private final INhatKyRepository nhatKyRepository = NhatKyRepoImpl.getInstance();
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
        String filterNv = request.getParameter("filterNhanVien");
        List<NhatKyHoatDong> logs;
        if (filterNv != null && !filterNv.trim().isEmpty()) {
            logs = nhatKyRepository.getLogsByNhanVien(filterNv.trim());
        } else {
            logs = nhatKyRepository.getAllLogs();
        }

        // NẠP DANH SÁCH NHÂN VIÊN ĐỂ MAP TÊN THẬT TIẾNG VIỆT CÓ DẤU CHO AUDIT TRAIL
        List<NhanVien> employees = nhanVienService.getAllNhanVien();
        request.setAttribute("employees", employees);
        request.setAttribute("logs", logs);
        request.setAttribute("filterNhanVien", filterNv);
        request.getRequestDispatcher("/views/admin/nhat_ky.jsp").forward(request, response);
    }

    private void showLogDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/auditlog?msg=error");
            return;
        }
        try {
            long id = Long.parseLong(idStr.trim());
            NhatKyHoatDong targetLog = null;
            List<NhatKyHoatDong> allLogs = nhatKyRepository.getAllLogs();
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
                response.sendRedirect(request.getContextPath() + "/admin/auditlog?msg=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/auditlog?msg=error");
        }
    }
}
