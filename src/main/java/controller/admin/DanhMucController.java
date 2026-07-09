package controller.admin;

import model.entity.DanhMuc;
import service.IDanhMucService;
import service.impl.DanhMucServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DanhMucController", urlPatterns = {"/admin/danhmuc"})
public class DanhMucController extends HttpServlet {
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();

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
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                performDelete(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<DanhMuc> list = danhMucService.getAllDanhMuc();
        request.setAttribute("categories", list);
        request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("formTitle", "THÊM DANH MỤC MỚI");
        request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            DanhMuc dm = danhMucService.getDanhMucById(id);
            if (dm != null) {
                request.setAttribute("category", dm);
                request.setAttribute("formTitle", "CẬP NHẬT DANH MỤC");
                request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=error");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = danhMucService.deleteDanhMuc(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=deletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=deletefailed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            performCreate(request, response);
        } else if ("edit".equals(action)) {
            performUpdate(request, response);
        }
    }

    private void performCreate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tenDm = request.getParameter("tenDm");
        String hinhAnh = request.getParameter("hinhAnh");
        String thuTuHienThiStr = request.getParameter("thuTuHienThi");
        String trangThaiStr = request.getParameter("trangThai");

        int thuTu = 0;
        try {
            thuTu = Integer.parseInt(thuTuHienThiStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        boolean trangThai = "1".equals(trangThaiStr);

        DanhMuc dm = new DanhMuc(0, tenDm, hinhAnh, thuTu, trangThai);
        boolean success = danhMucService.createDanhMuc(dm);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=createsuccess");
        } else {
            request.setAttribute("category", dm);
            request.setAttribute("error", "Tên danh mục đã tồn tại trong hệ thống!");
            request.setAttribute("formTitle", "THÊM DANH MỤC MỚI");
            request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int maDm = Integer.parseInt(request.getParameter("maDm"));
            String tenDm = request.getParameter("tenDm");
            String hinhAnh = request.getParameter("hinhAnh");
            String thuTuHienThiStr = request.getParameter("thuTuHienThi");
            String trangThaiStr = request.getParameter("trangThai");

            int thuTu = 0;
            try {
                thuTu = Integer.parseInt(thuTuHienThiStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }

            boolean trangThai = "1".equals(trangThaiStr);

            DanhMuc dm = new DanhMuc(maDm, tenDm, hinhAnh, thuTu, trangThai);
            boolean success = danhMucService.updateDanhMuc(dm);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=updatesuccess");
            } else {
                request.setAttribute("category", dm);
                request.setAttribute("error", "Không thể cập nhật. Tên danh mục bị trùng lặp!");
                request.setAttribute("formTitle", "CẬP NHẬT DANH MỤC");
                request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=error");
        }
    }
}