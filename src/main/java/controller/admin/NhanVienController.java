package controller.admin;

import model.entity.NhanVien;
import service.INhanVienService;
import service.impl.NhanVienServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
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
        nhanVienService.deleteNhanVien(id); // Xóa mềm
        response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=deletesuccess");
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
        String hoTen = request.getParameter("hoTen");
        int maVt = Integer.parseInt(request.getParameter("maVt"));
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String username = request.getParameter("tenDangNhap");
        String matKhau = request.getParameter("matKhau");
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        NhanVien nv = new NhanVien(null, maVt, hoTen, sdt, email, username, matKhau, trangThai, null, null);
        boolean success = nhanVienService.createNhanVien(nv);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=createsuccess");
        } else {
            request.setAttribute("employee", nv);
            request.setAttribute("error", "Lỗi: Số điện thoại, Email hoặc Tên đăng nhập đã tồn tại!");
            request.setAttribute("formTitle", "THÊM NHÂN VIÊN MỚI");
            request.getRequestDispatcher("/views/admin/nhan_vien.jsp").forward(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maNv = request.getParameter("maNv");
        String hoTen = request.getParameter("hoTen");
        int maVt = Integer.parseInt(request.getParameter("maVt"));
        String sdt = request.getParameter("soDienThoai");
        String email = request.getParameter("email");
        String username = request.getParameter("tenDangNhap");
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        NhanVien nv = nhanVienService.getNhanVienById(maNv);
        if (nv != null) {
            nv.setHoTen(hoTen);
            nv.setMaVt(maVt);
            nv.setSoDienThoai(sdt);
            nv.setEmail(email);
            nv.setTenDangNhap(username);
            nv.setTrangThai(trangThai);

            boolean success = nhanVienService.updateNhanVien(nv);
            if (success) {
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
        String maNv = request.getParameter("maNv");
        String matKhauMoi = request.getParameter("matKhauMoi");

        boolean success = nhanVienService.resetPasswordByAdmin(maNv, matKhauMoi);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=resetsuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/nhanvien?msg=resetfailed");
        }
    }
}