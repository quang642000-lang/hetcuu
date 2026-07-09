package controller.portal;

import model.entity.DanhMuc;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import model.entity.Topping;
import service.IDanhMucService;
import service.ISanPhamService;
import service.IToppingService;
import service.impl.DanhMucServiceImpl;
import service.impl.SanPhamServiceImpl;
import service.impl.ToppingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PortalProductController", urlPatterns = {"/products", "/product/detail"})
public class PortalProductController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PortalProductController.class.getName());

    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uri = request.getRequestURI();

        if (uri.endsWith("/product/detail")) {
            showProductDetail(request, response);
        } else {
            showProductList(request, response);
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maDmStr = request.getParameter("category");
        String keyword = request.getParameter("search");

        List<SanPham> products;
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                products = sanPhamService.searchSanPham(keyword.trim());
            } else if (maDmStr != null && !maDmStr.trim().isEmpty()) {
                int maDm = Integer.parseInt(maDmStr);
                products = sanPhamService.getSanPhamByDanhMuc(maDm);
            } else {
                products = sanPhamService.getAllSanPham();
            }

            // Gọi hàm setSizesList đã được thêm thành công vào lớp thực thể SanPham
            if (products != null) {
                for (SanPham sp : products) {
                    sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
                }
            }

            List<DanhMuc> categories = danhMucService.getActiveDanhMuc();

            request.setAttribute("products", products);
            request.setAttribute("categories", categories);
            request.setAttribute("selectedCategory", maDmStr);
            request.setAttribute("searchKeyword", keyword);
            request.getRequestDispatcher("/views/portal/danh_sach_san_pham.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Định dạng mã danh mục không hợp lệ: " + maDmStr, e);
            response.sendRedirect(request.getContextPath() + "/products?msg=error");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tải danh sách sản phẩm ngoài trang Portal", e);
            response.sendRedirect(request.getContextPath() + "/home?msg=error");
        }
    }

    private void showProductDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        try {
            SanPham sp = sanPhamService.getSanPhamById(id);

            if (sp != null) {
                List<SanPhamKichCo> sizes = sanPhamService.getSizesBySanPham(id);
                List<Topping> toppings = toppingService.getActiveTopping();

                request.setAttribute("product", sp);
                request.setAttribute("sizes", sizes);
                request.setAttribute("toppings", toppings);
                request.getRequestDispatcher("/views/portal/chi_tiet_san_pham.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/products?msg=notfound");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy xuất thông tin chi tiết của sản phẩm mã: " + id, e);
            response.sendRedirect(request.getContextPath() + "/products?msg=error");
        }
    }
}