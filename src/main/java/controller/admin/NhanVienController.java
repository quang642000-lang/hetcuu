package controller.admin;

import model.entity.NhanVien;
import model.entity.NhatKyHoatDong;
import repository.impl.NhatKyRepoImpl;
import service.INhanVienService;
import service.impl.NhanVienServiceImpl;
import config.DBConnect;
import util.JsonParserUtil;
import util.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "NhanVienController", urlPatterns = {"/admin/nhanvien"})
public class NhanVienController extends HttpServlet {
    private final INhanVienService nhanVienService = NhanVienServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        switch (action) {
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
        List<NhanVien> list = nhanVienService.getAllNhanVien();
        request.setAttribute("employees", list);
        request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("formTitle", "THÊM NHÂN VIÊN MỚI");
        request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        NhanVien nv = nhanVienService.getNhanVienById(id);
        if (nv != null) {
            request.setAttribute("employee", nv);
            request.setAttribute("formTitle", "CẬP NHẬT NHÂN VIÊN");
            request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=notfound");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        String actorNv = WebUtil.getCurrentActor(request);
        String ip = WebUtil.getRemoteIP(request);
        boolean hasOrders = false;
        String checkSql = "SELECT COUNT(*) FROM DON_HANG WHERE ma_nv = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    hasOrders = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (hasOrders) {
            boolean softSuccess = nhanVienService.deleteNhanVien(id);
            if (softSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SOFT_DELETE_NHÂN_VIÊN", "NHAN_VIEN", "Mã NV: " + id, "Khóa tài khoản hoạt động do nhân sự có lịch sử lập hóa đơn.", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=softdeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=deletefailed");
            }
        } else {
            boolean hardSuccess = false;
            String deleteSql = "DELETE FROM NHAN_VIEN WHERE ma_nv = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, id);
                int deleted = ps.executeUpdate();
                if (deleted > 0) {
                    hardSuccess = true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if (hardSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "HARD_DELETE_NHÂN_VIÊN", "NHAN_VIEN", "Mã NV: " + id, "Xóa hoàn toàn nhân sự khỏi hệ thống (chưa từng chốt hóa đơn).", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=harddeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=deletefailed");
            }
        }
    }

    private void performToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        boolean status = "1".equals(request.getParameter("status"));
        String actorNv = WebUtil.getCurrentActor(request);
        String ip = WebUtil.getRemoteIP(request);

        NhanVien nv = nhanVienService.getNhanVienById(id);
        if (nv != null) {
            String oldJson = JsonParserUtil.toJson(nv);
            nv.setTrangThai(status);
            boolean success = nhanVienService.updateNhanVien(nv);
            if (success) {
                String actionTxt = status ? "MỞ_KHÓA_CA_NHÂN_VIÊN" : "KHÓA_CA_NHÂN_VIÊN";
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, actionTxt, "NHAN_VIEN", oldJson, JsonParserUtil.toJson(nv), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=updatesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=notfound");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            performCreate(request, response);
        } else if ("edit".equals(action)) {
            performUpdate(request, response);
        } else if ("resetPassword".equals(action)) {
            performResetPassword(request, response);
        }
    }

    private void performCreate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String actorNv = WebUtil.getCurrentActor(request);
        String ip = WebUtil.getRemoteIP(request);

        String hoTen = request.getParameter("hoTen");
        int maVt = WebUtil.getIntParameter(request, "maVt", 2);
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String username = request.getParameter("tenDangNhap");
        String matKhau = request.getParameter("matKhau");
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        NhanVien nv = new NhanVien(null, maVt, hoTen, sdt, email, username, matKhau, trangThai, null, null);
        boolean success = nhanVienService.createNhanVien(nv);
        if (success) {
            NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                    actorNv, "THÊM_NHÂN_VIÊN", "NHAN_VIEN", null, JsonParserUtil.toJson(nv), ip, null
            ));
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=createsuccess");
        } else {
            request.setAttribute("employee", nv);
            request.setAttribute("error", "Lỗi: Số điện thoại, Email hoặc Tên đăng nhập đã tồn tại!");
            request.setAttribute("formTitle", "THÊM NHÂN VIÊN MỚI");
            request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String actorNv = WebUtil.getCurrentActor(request);
        String ip = WebUtil.getRemoteIP(request);

        String maNv = request.getParameter("maNv");
        String hoTen = request.getParameter("hoTen");
        int maVt = WebUtil.getIntParameter(request, "maVt", 2);
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String username = request.getParameter("tenDangNhap");
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        NhanVien nv = nhanVienService.getNhanVienById(maNv);
        if (nv != null) {
            String oldJson = JsonParserUtil.toJson(nv);
            nv.setHoTen(hoTen);
            nv.setMaVt(maVt);
            nv.setSoDienThoai(sdt);
            nv.setEmail(email);
            nv.setTenDangNhap(username);
            nv.setTrangThai(trangThai);

            boolean success = nhanVienService.updateNhanVien(nv);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SỬA_NHÂN_VIÊN", "NHAN_VIEN", oldJson, JsonParserUtil.toJson(nv), ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=updatesuccess");
            } else {
                request.setAttribute("employee", nv);
                request.setAttribute("error", "Lỗi: Số điện thoại, Email hoặc Tên đăng nhập bị trùng lặp!");
                request.setAttribute("formTitle", "CẬP NHẬT NHÂN VIÊN");
                request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
            }
        }
    }

    private void performResetPassword(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String actorNv = WebUtil.getCurrentActor(request);
        String ip = WebUtil.getRemoteIP(request);

        String maNv = request.getParameter("maNv");
        String matKhauMoi = request.getParameter("matKhauMoi");
        NhanVien nv = nhanVienService.getNhanVienById(maNv);
        if (nv != null) {
            String oldJson = JsonParserUtil.toJson(nv);
            boolean success = nhanVienService.resetPasswordByAdmin(maNv, matKhauMoi);
            if (success) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "RESET_MẬT_KHẨU_NHÂN_VIÊN", "NHAN_VIEN", oldJson, "Đã đặt lại mật khẩu của nhân viên: " + maNv, ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=resetsuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=resetfailed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=notfound");
        }
    }
}
