package controller.portal;

import model.entity.DanhMuc;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import model.entity.Topping;
import model.entity.ChiTietGioHang;
import model.entity.GioHang;
import model.entity.KhachHang;
import service.IDanhMucService;
import service.ISanPhamService;
import service.IToppingService;
import service.IGioHangService;
import service.impl.DanhMucServiceImpl;
import service.impl.SanPhamServiceImpl;
import service.impl.ToppingServiceImpl;
import service.impl.GioHangServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Comparator;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PortalProductController", urlPatterns = {"/products", "/product/detail"})
public class PortalProductController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(PortalProductController.class.getName());
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final IToppingService toppingService = ToppingServiceImpl.getInstance();
    private final IGioHangService gioHangService = GioHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/product/detail".equals(path)) {
            showProductDetail(request, response);
        } else {
            showProductList(request, response);
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maDmStr = request.getParameter("category");
        String keyword = request.getParameter("search");
        String filter = request.getParameter("filter");
        String sort = request.getParameter("sort");

        List<SanPham> products;
        try {
            if (keyword != null && !keyword.trim().isEmpty()) {
                products = sanPhamService.searchSanPham(keyword.trim());
            } else if ("new".equals(filter)) {
                products = sanPhamService.getNewArrivals();
            } else if ("hot".equals(filter)) {
                products = sanPhamService.getBestsellers();
            } else if (maDmStr != null && !maDmStr.trim().isEmpty()) {
                products = sanPhamService.getSanPhamByDanhMuc(maDmStr.trim());
            } else {
                products = sanPhamService.getAllSanPham();
            }

            if (products == null) {
                products = new ArrayList<>();
            }

            for (SanPham sp : products) {
                List<SanPhamKichCo> sizes = sanPhamService.getSizesBySanPham(sp.getMaSp());
                sp.setSizesList(sizes);
            }

            if (sort != null && !sort.trim().isEmpty()) {
                if ("price_asc".equals(sort)) {
                    products.sort(new Comparator<SanPham>() {
                        @Override
                        public int compare(SanPham o1, SanPham o2) {
                            return Integer.compare(getMinPrice(o1), getMinPrice(o2));
                        }
                    });
                } else if ("price_desc".equals(sort)) {
                    products.sort(new Comparator<SanPham>() {
                        @Override
                        public int compare(SanPham o1, SanPham o2) {
                            return Integer.compare(getMinPrice(o2), getMinPrice(o1));
                        }
                    });
                }
            }

            int page = 1;
            int pageSize = 9;
            String pageStr = request.getParameter("page");
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr.trim());
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            int totalProducts = products.size();
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            if (page > totalPages && totalPages > 0) {
                page = totalPages;
            }

            int startIdx = (page - 1) * pageSize;
            int endIdx = Math.min(startIdx + pageSize, totalProducts);
            List<SanPham> paginatedProducts = new ArrayList<>();
            if (startIdx < totalProducts) {
                paginatedProducts = products.subList(startIdx, endIdx);
            }

            List<DanhMuc> categories = danhMucService.getActiveDanhMuc();

            request.setAttribute("products", paginatedProducts);
            request.setAttribute("categories", categories);
            request.setAttribute("selectedCategory", maDmStr);
            request.setAttribute("searchKeyword", keyword);
            request.setAttribute("currentFilter", filter);
            request.setAttribute("currentSort", sort);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalProducts", totalProducts);

            request.getRequestDispatcher("/views/portal/danh_sach_san_pham.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tải danh sách sản phẩm ngoài trang Portal", e);
            response.sendRedirect(request.getContextPath() + "/home?msg=error");
        }
    }

    private int getMinPrice(SanPham sp) {
        if (sp.getSizesList() == null || sp.getSizesList().isEmpty()) {
            return 0;
        }
        int min = Integer.MAX_VALUE;
        for (SanPhamKichCo sk : sp.getSizesList()) {
            if (sk.isTrangThai() && sk.getGiaBan() < min) {
                min = sk.getGiaBan();
            }
        }
        return min == Integer.MAX_VALUE ? 0 : min;
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

                String editCtghStr = request.getParameter("maCtgh");
                if (editCtghStr != null && !editCtghStr.trim().isEmpty()) {
                    try {
                        long editCtgh = Long.parseLong(editCtghStr.trim());
                        ChiTietGioHang editItem = null;
                        HttpSession session = request.getSession(false);
                        if (session != null && session.getAttribute("customer") != null) {
                            KhachHang currentCustomer = (KhachHang) session.getAttribute("customer");
                            GioHang gh = gioHangService.getGioHangComplete(currentCustomer.getMaKh());
                            if (gh != null && gh.getChiTietGioHangList() != null) {
                                for (ChiTietGioHang ct : gh.getChiTietGioHangList()) {
                                    if (ct.getMaCtgh() == editCtgh) {
                                        editItem = ct;
                                        break;
                                    }
                                }
                            }
                        }
                        request.setAttribute("editItem", editItem);
                    } catch (Exception ex) {
                        LOGGER.log(Level.WARNING, "Lỗi bóc tách mã chi tiết giỏ hàng chỉnh sửa", ex);
                    }
                }
                request.getRequestDispatcher("/views/portal/chi_tiet_san_pham.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/products?msg=notfound");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi truy xuất thông tin chi tiết của sản phẩm mã: " + id, e);
            response.sendRedirect(request.getContextPath() + "/products?msg=error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
