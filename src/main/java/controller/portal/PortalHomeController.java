package controller.portal;

import model.entity.DanhMuc;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
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
import java.util.ArrayList;
import java.util.List;

/**
 * =========================================================================
 * TEA POS SYSTEM - CLIENT WEBSITE ONLINE PORTAL HOME CONTROLLER (v2)
 * Synchronized with active categories and strict product-mother status constraints.
 * =========================================================================
 */
@WebServlet(name = "PortalHomeController", urlPatterns = {"/home", "/portal"})
public class PortalHomeController extends HttpServlet {
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
            List<String> activeCatIds = new ArrayList<>();
            if (categories != null) {
                for (DanhMuc cat : categories) {
                    activeCatIds.add(cat.getMaDm());
                }
            }

            List<SanPham> bestsellers = sanPhamService.getBestsellers();
            List<SanPham> newArrivals = sanPhamService.getNewArrivals();

            // MÀNG LỌC BẢO MẬT: Bestsellers phải đang mở bán và thuộc danh mục đang hoạt động kèm có kích cỡ hợp lệ
            List<SanPham> activeBestsellers = new ArrayList<>();
            if (bestsellers != null) {
                for (SanPham sp : bestsellers) {
                    if (sp.isTrangThai() && activeCatIds.contains(sp.getMaDm())) {
                        List<SanPhamKichCo> sizes = sanPhamService.getSizesBySanPham(sp.getMaSp());
                        if (sizes != null && !sizes.isEmpty()) {
                            sp.setSizesList(sizes);
                            activeBestsellers.add(sp);
                        }
                    }
                }
            }
            bestsellers = activeBestsellers;

            // MÀNG LỌC BẢO MẬT: New Arrivals phải đang mở bán và thuộc danh mục đang hoạt động kèm có kích cỡ hợp lệ
            List<SanPham> activeNewArrivals = new ArrayList<>();
            if (newArrivals != null) {
                for (SanPham sp : newArrivals) {
                    if (sp.isTrangThai() && activeCatIds.contains(sp.getMaDm())) {
                        List<SanPhamKichCo> sizes = sanPhamService.getSizesBySanPham(sp.getMaSp());
                        if (sizes != null && !sizes.isEmpty()) {
                            sp.setSizesList(sizes);
                            activeNewArrivals.add(sp);
                        }
                    }
                }
            }
            newArrivals = activeNewArrivals;

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