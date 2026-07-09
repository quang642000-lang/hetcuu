package controller.admin;

import model.entity.DanhMuc;
import model.entity.KichCo;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import repository.IKichCoRepository;
import repository.impl.KichCoRepoImpl;
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

@WebServlet(name = "SanPhamController", urlPatterns = {"/admin/sanpham"})
public class SanPhamController extends HttpServlet {
    private final ISanPhamService sanPhamService = SanPhamServiceImpl.getInstance();
    private final IDanhMucService danhMucService = DanhMucServiceImpl.getInstance();
    private final IKichCoRepository kichCoRepository = KichCoRepoImpl.getInstance();

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
        List<SanPham> list = sanPhamService.getAllSanPham();
        request.setAttribute("products", list);
        request.getRequestDispatcher("/views/admin/san_pham.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
        List<KichCo> sizes = kichCoRepository.getAll();

        request.setAttribute("categories", categories);
        request.setAttribute("sizes", sizes);
        request.setAttribute("formTitle", "THÊM SẢN PHẨM MỚI");
        request.getRequestDispatcher("/views/admin/san_pham.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        SanPham sp = sanPhamService.getSanPhamById(id);
        if (sp != null) {
            List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
            List<KichCo> sizes = kichCoRepository.getAll();
            List<SanPhamKichCo> currentPrices = sanPhamService.getSizesBySanPham(id);

            request.setAttribute("product", sp);
            request.setAttribute("categories", categories);
            request.setAttribute("sizes", sizes);
            request.setAttribute("currentPrices", currentPrices);
            request.setAttribute("formTitle", "CẬP NHẬT SẢN PHẨM");
            request.getRequestDispatcher("/views/admin/sanpham-form.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=notfound");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        boolean success = sanPhamService.deleteSanPham(id);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=deletesuccess");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=deletefailed");
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
        String tenSp = request.getParameter("tenSp");
        int maDm = Integer.parseInt(request.getParameter("maDm"));
        String moTa = request.getParameter("moTa");
        String hinhAnh = request.getParameter("hinhAnh");

        boolean choPhepDoiDa = request.getParameter("choPhepDoiDa") != null;
        boolean choPhepDoiDuong = request.getParameter("choPhepDoiDuong") != null;
        boolean isNew = request.getParameter("isNew") != null;
        boolean isBestseller = request.getParameter("isBestseller") != null;
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        SanPham sp = new SanPham();
        sp.setTenSp(tenSp);
        sp.setMaDm(maDm);
        sp.setMoTa(moTa);
        sp.setHinhAnh(hinhAnh);
        sp.setChoPhepDoiDa(choPhepDoiDa);
        sp.setChoPhepDoiDuong(choPhepDoiDuong);
        sp.setIsNew(isNew); // Đã sửa
        sp.setIsBestseller(isBestseller); // Đã sửa
        sp.setTrangThai(trangThai);

        // Đọc cấu hình kích cỡ (Sizes) từ Form gửi lên
        List<KichCo> allSizes = kichCoRepository.getAll();
        List<SanPhamKichCo> selectedSizes = new ArrayList<>();

        for (KichCo kc : allSizes) {
            String checkboxName = "size_active_" + kc.getMaSize();
            if (request.getParameter(checkboxName) != null) {
                try {
                    int giaBan = Integer.parseInt(request.getParameter("size_price_" + kc.getMaSize()));
                    String dinhLuong = request.getParameter("size_volume_" + kc.getMaSize());

                    SanPhamKichCo spkc = new SanPhamKichCo(null, kc.getMaSize(), giaBan, dinhLuong, true);
                    selectedSizes.add(spkc);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }

        boolean success = sanPhamService.createSanPham(sp, selectedSizes);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=createsuccess");
        } else {
            request.setAttribute("error", "Lỗi tạo mới sản phẩm hoặc cấu hình kích cỡ!");
            showCreateForm(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String maSp = request.getParameter("maSp");
        String tenSp = request.getParameter("tenSp");
        int maDm = Integer.parseInt(request.getParameter("maDm"));
        String moTa = request.getParameter("moTa");
        String hinhAnh = request.getParameter("hinhAnh");

        boolean choPhepDoiDa = request.getParameter("choPhepDoiDa") != null;
        boolean choPhepDoiDuong = request.getParameter("choPhepDoiDuong") != null;
        boolean isNew = request.getParameter("isNew") != null;
        boolean isBestseller = request.getParameter("isBestseller") != null;
        boolean trangThai = "1".equals(request.getParameter("trangThai"));

        SanPham sp = sanPhamService.getSanPhamById(maSp);
        if (sp != null) {
            sp.setTenSp(tenSp);
            sp.setMaDm(maDm);
            sp.setMoTa(moTa);
            sp.setHinhAnh(hinhAnh);
            sp.setChoPhepDoiDa(choPhepDoiDa);
            sp.setChoPhepDoiDuong(choPhepDoiDuong);
            sp.setIsNew(isNew); // Đã sửa
            sp.setIsBestseller(isBestseller); // Đã sửa
            sp.setTrangThai(trangThai);

            List<KichCo> allSizes = kichCoRepository.getAll();
            List<SanPhamKichCo> selectedSizes = new ArrayList<>();

            for (KichCo kc : allSizes) {
                String checkboxName = "size_active_" + kc.getMaSize();
                if (request.getParameter(checkboxName) != null) {
                    try {
                        int giaBan = Integer.parseInt(request.getParameter("size_price_" + kc.getMaSize()));
                        String dinhLuong = request.getParameter("size_volume_" + kc.getMaSize());

                        SanPhamKichCo spkc = new SanPhamKichCo(maSp, kc.getMaSize(), giaBan, dinhLuong, true);
                        selectedSizes.add(spkc);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }

            boolean success = sanPhamService.updateSanPham(sp, selectedSizes);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=updatesuccess");
            } else {
                request.setAttribute("error", "Lỗi cập nhật sản phẩm!");
                showEditForm(request, response);
            }
        }
    }
}