package controller.admin;

import model.entity.Topping;
import service.IToppingService;
import service.impl.ToppingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ToppingController", urlPatterns = {"/admin/topping"})
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
            toppingService.deleteTopping(id); // Xóa mềm
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=deletesuccess");
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
        String tenTp = request.getParameter("tenTp");
        String dinhLuong = request.getParameter("dinhLuong");
        int giaBan = Integer.parseInt(request.getParameter("giaBan"));
        int thuTu = Integer.parseInt(request.getParameter("thuTuHienThi"));
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        Topping tp = new Topping(0, tenTp, dinhLuong, giaBan, thuTu, trangThai);
        boolean success = toppingService.createTopping(tp);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=createsuccess");
        } else {
            request.setAttribute("topping", tp);
            request.setAttribute("error", "Lỗi tạo mới Topping!");
            request.setAttribute("formTitle", "THÊM TOPPING MỚI");
            request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int maTp = Integer.parseInt(request.getParameter("maTp"));
            String tenTp = request.getParameter("tenTp");
            String dinhLuong = request.getParameter("dinhLuong");
            int giaBan = Integer.parseInt(request.getParameter("giaBan"));
            int thuTu = Integer.parseInt(request.getParameter("thuTuHienThi"));
            boolean trangThai = "1".equals(request.getParameter("trangThai"));

            Topping tp = new Topping(maTp, tenTp, dinhLuong, giaBan, thuTu, trangThai);
            boolean success = toppingService.updateTopping(tp);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/topping?msg=updatesuccess");
            } else {
                request.setAttribute("topping", tp);
                request.setAttribute("error", "Lỗi cập nhật Topping!");
                request.setAttribute("formTitle", "CẬP NHẬT TOPPING");
                request.getRequestDispatcher("/views/admin/topping.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/topping?msg=error");
        }
    }
}