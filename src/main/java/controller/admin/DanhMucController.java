package controller.admin;

import model.entity.DanhMuc;
import model.entity.NhatKyHoatDong;
import repository.impl.NhatKyRepoImpl;
import service.IDanhMucService;
import service.impl.DanhMucServiceImpl;
import config.DBConnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import util.JsonParserUtil;

@WebServlet(name = "DanhMucController", urlPatterns = {"/admin/danhmuc"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50   // 50MB
)
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
            HttpSession session = request.getSession(false);
            String actorNv = "SYSTEM";
            if (session != null && session.getAttribute("user") != null) {
                actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
            }
            String ip = request.getRemoteAddr();
            DanhMuc oldDm = danhMucService.getDanhMucById(id);
            if (oldDm != null) {
                String oldJson = JsonParserUtil.toJson(oldDm);
                boolean success = danhMucService.deleteDanhMuc(id);
                if (success) {
                    NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                            actorNv, "XÓA_DANH_MỤC", "DANH_MUC", oldJson, "Đã xóa vĩnh viễn danh mục mã: " + id, ip, null
                    ));
                    response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=deletesuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=deletefailed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=notfound");
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
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();
        try {
            String tenDm = request.getParameter("tenDm");
            String thuTuHienThiStr = request.getParameter("thuTuHienThi");
            String trangThaiStr = request.getParameter("trangThai");
            int thuTu = 0;
            try {
                thuTu = Integer.parseInt(thuTuHienThiStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            boolean trangThai = "1".equals(trangThaiStr);
            String hinhAnh = "";
            String uploadType = request.getParameter("uploadType");
            if ("file".equals(uploadType)) {
                hinhAnh = uploadFile(request, "hinhAnhFile");
            } else {
                hinhAnh = request.getParameter("hinhAnhUrl");
            }
            DanhMuc dm = new DanhMuc(0, tenDm, hinhAnh, thuTu, trangThai);
            boolean success = danhMucService.createDanhMuc(dm);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "THÊM_DANH_MỤC", "DANH_MUC", null, JsonParserUtil.toJson(dm), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=createsuccess");
            } else {
                request.setAttribute("category", dm);
                request.setAttribute("error", "Tên danh mục đã tồn tại trong hệ thống!");
                request.setAttribute("formTitle", "THÊM DANH MỤC MỚI");
                request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=error");
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();
        try {
            int maDm = Integer.parseInt(request.getParameter("maDm"));
            String tenDm = request.getParameter("tenDm");
            String thuTuHienThiStr = request.getParameter("thuTuHienThi");
            String trangThaiStr = request.getParameter("trangThai");
            int thuTu = 0;
            try {
                thuTu = Integer.parseInt(thuTuHienThiStr);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            boolean trangThai = "1".equals(trangThaiStr);
            String hinhAnh = request.getParameter("currentHinhAnh");
            String uploadType = request.getParameter("uploadType");
            if ("file".equals(uploadType)) {
                String uploaded = uploadFile(request, "hinhAnhFile");
                if (uploaded != null && !uploaded.isEmpty()) {
                    hinhAnh = uploaded;
                }
            } else {
                String url = request.getParameter("hinhAnhUrl");
                if (url != null && !url.trim().isEmpty()) {
                    hinhAnh = url;
                }
            }
            DanhMuc oldDm = danhMucService.getDanhMucById(maDm);
            String oldJson = JsonParserUtil.toJson(oldDm);
            DanhMuc dm = new DanhMuc(maDm, tenDm, hinhAnh, thuTu, trangThai);
            boolean success = danhMucService.updateDanhMuc(dm);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SỬA_DANH_MỤC", "DANH_MUC", oldJson, JsonParserUtil.toJson(dm), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=updatesuccess");
            } else {
                request.setAttribute("category", dm);
                request.setAttribute("error", "Không thể cập nhật. Tên danh mục bị trùng lặp!");
                request.setAttribute("formTitle", "CẬP NHẬT DANH MỤC");
                request.getRequestDispatcher("/views/admin/danh_muc.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/danhmuc?msg=error");
        }
    }

    private String uploadFile(HttpServletRequest request, String inputFieldName) {
        try {
            Part filePart = request.getPart(inputFieldName);
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                String fileExt = "";
                int dotIdx = fileName.lastIndexOf('.');
                if (dotIdx > 0) {
                    fileExt = fileName.substring(dotIdx);
                }
                String newFileName = System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + fileExt;

                // Lập trình lưu vĩnh viễn ngoài project (DocBase Mapping chuẩn)
                String baseDir = System.getProperty("os.name").toLowerCase().contains("win") ? "C:/teapos_uploads/images/" : "/var/teapos_uploads/images/";
                File uploadDir = new File(baseDir);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                File file = new File(uploadDir, newFileName);
                filePart.write(file.getAbsolutePath());
                return request.getContextPath() + "/assets/images/" + newFileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
