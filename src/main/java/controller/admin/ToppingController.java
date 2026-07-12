package controller.admin;

import model.entity.Topping;
import model.entity.NhatKyHoatDong;
import repository.impl.NhatKyRepoImpl;
import service.IToppingService;
import service.impl.ToppingServiceImpl;
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

@WebServlet(name = "ToppingController", urlPatterns = {"/admin/topping"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class ToppingController extends HttpServlet {
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();

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
            case "toggle":
                performToggle(request, response);
                break;
            default:
                showList(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Topping> list = toppingService.getAllTopping();
        request.setAttribute("toppings", list);
        request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("formTitle", "THÊM TOPPING MỚI");
        request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Topping tp = toppingService.getToppingById(id);
            if (tp != null) {
                request.setAttribute("topping", tp);
                request.setAttribute("formTitle", "CẬP NHẬT TOPPING");
                request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/topping?msg=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
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
            boolean hasOrders = false;
            String checkSql = "SELECT COUNT(*) FROM CHI_TIET_TOPPING WHERE ma_tp = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        hasOrders = true;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if (hasOrders) {
                boolean softSuccess = toppingService.deleteTopping(id);
                if (softSuccess) {
                    NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                            actorNv, "SOFT_DELETE_TOPPING", "TOPPING", "Mã TP: " + id, "Chuyển trạng thái hoạt động về 0 do có lịch sử chốt đơn.", ip, null
                    ));
                    response.sendRedirect(request.getContextPath() + "/admin/topping?msg=softdeletesuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
                }
            } else {
                boolean hardSuccess = false;
                String deleteSql = "DELETE FROM TOPPING WHERE ma_tp = ?";
                try (Connection conn = DBConnect.getConnection();
                     PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setInt(1, id);
                    int deleted = ps.executeUpdate();
                    if (deleted > 0) {
                        hardSuccess = true;
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                if (hardSuccess) {
                    NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                            actorNv, "HARD_DELETE_TOPPING", "TOPPING", "Mã TP: " + id, "Xóa hoàn toàn topping khỏi hệ thống (chưa từng giao dịch).", ip, null
                    ));
                    response.sendRedirect(request.getContextPath() + "/admin/topping?msg=harddeletesuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
                }
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
        }
    }

    private void performToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean status = "1".equals(request.getParameter("status"));
            toppingService.updateTrangThaiTopping(id, status);
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=updatesuccess");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
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
            String tenTp = request.getParameter("tenTp");
            String dinhLuong = request.getParameter("dinhLuong");
            int giaBan = Integer.parseInt(request.getParameter("giaBan"));
            int thuTu = Integer.parseInt(request.getParameter("thuTuHienThi"));
            boolean trangThai = "1".equals(request.getParameter("trangThai"));
            String hinhAnh = "";
            String uploadType = request.getParameter("uploadType");
            if ("file".equals(uploadType)) {
                hinhAnh = uploadFile(request, "hinhAnhFile");
            } else {
                hinhAnh = request.getParameter("hinhAnhUrl");
            }
            Topping tp = new Topping(0, tenTp, dinhLuong, giaBan, thuTu, trangThai, hinhAnh);
            boolean success = toppingService.createTopping(tp);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "THÊM_TOPPING", "TOPPING", null, JsonParserUtil.toJson(tp), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/topping?msg=createsuccess");
            } else {
                request.setAttribute("topping", tp);
                request.setAttribute("error", "Lỗi tạo mới Topping!");
                request.setAttribute("formTitle", "THÊM TOPPING MỚI");
                request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
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
            int maTp = Integer.parseInt(request.getParameter("maTp"));
            String tenTp = request.getParameter("tenTp");
            String dinhLuong = request.getParameter("dinhLuong");
            int giaBan = Integer.parseInt(request.getParameter("giaBan"));
            int thuTu = Integer.parseInt(request.getParameter("thuTuHienThi"));
            boolean trangThai = "1".equals(request.getParameter("trangThai"));
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
            Topping oldTp = toppingService.getToppingById(maTp);
            String oldJson = JsonParserUtil.toJson(oldTp);
            Topping tp = new Topping(maTp, tenTp, dinhLuong, giaBan, thuTu, trangThai, hinhAnh);
            boolean success = toppingService.updateTopping(tp);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SỬA_TOPPING", "TOPPING", oldJson, JsonParserUtil.toJson(tp), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/topping?msg=updatesuccess");
            } else {
                request.setAttribute("topping", tp);
                request.setAttribute("error", "Lỗi cập nhật Topping!");
                request.setAttribute("formTitle", "CẬP NHẬT TOPPING");
                request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
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
