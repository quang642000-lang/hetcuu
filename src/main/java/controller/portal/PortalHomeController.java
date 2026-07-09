package controller.portal;

import model.entity.DanhMuc;
import model.entity.SanPham;
import service.IDanhMucService;
import service.ISanPhamService;
import service.impl.DanhMucServiceImpl;
import service.impl.SanPhamServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PortalHomeController", urlPatterns = {"/home", "/portal"})
public class PortalHomeController extends HttpServlet {
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Tải danh mục hoạt động
        List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
        // Tải sản phẩm Bestseller
        List<SanPham> bestsellers = sanPhamService.getBestsellers();
        // Tải sản phẩm Mới
        List<SanPham> newArrivals = sanPhamService.getNewArrivals();

        request.setAttribute("categories", categories);
        request.setAttribute("bestsellers", bestsellers);
        request.setAttribute("newArrivals", newArrivals);
        request.getRequestDispatcher("/views/portal/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}