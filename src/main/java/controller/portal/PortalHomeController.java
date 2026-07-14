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
        try {
            List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
            List<SanPham> bestsellers = sanPhamService.getBestsellers();
            List<SanPham> newArrivals = sanPhamService.getNewArrivals();

            if (bestsellers != null) {
                for (SanPham sp : bestsellers) {
                    sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
                }
            }
            if (newArrivals != null) {
                for (SanPham sp : newArrivals) {
                    sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
                }
            }

            request.setAttribute("categories", categories);
            request.setAttribute("bestsellers", bestsellers);
            request.setAttribute("newArrivals", newArrivals);
            request.getRequestDispatcher("/views/portal/trang_chu.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home?msg=error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
