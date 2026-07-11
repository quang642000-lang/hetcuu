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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "SanPhamController", urlPatterns = {"/admin/sanpham"})
public class SanPhamController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(SanPhamController.class.getName());

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
        if (list != null) {
            for (SanPham sp : list) {
                sp.setSizesList(sanPhamService.getSizesBySanPham(sp.getMaSp()));
            }
        }
        List<DanhMuc> categories = danhMucService.getAllDanhMuc();
        request.setAttribute("products", list);
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/views/admin/san_pham.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<DanhMuc> categories = danhMucService.getActiveDanhMuc();
        List<KichCo> sizes = kichCoRepository.getAll();
        request.setAttribute("categories", categories);
        request.setAttribute("sizes", sizes);
        request.setAttribute("formTitle", "THÊM SẢN PHẨM MỚI");
        request.getRequestDispatcher("/views/admin/sanpham-form.jsp").forward(request, response);
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
        } else if ("addSizeAjax".equals(action)) {
            performAddSizeAjax(request, response);
        }
    }

    /**
     * Endpoint API AJAX: Thêm nhanh tên kích cỡ mới vào bảng KICH_CO
     */
    private void performAddSizeAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String tenSize = request.getParameter("tenSize");
        if (tenSize == null || tenSize.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Tên kích cỡ không được trống!\"}");
            return;
        }

        try {
            // Chuẩn hóa tên viết hoa
            String normalized = tenSize.trim().toUpperCase();
            KichCo existing = kichCoRepository.getByTenSize(normalized);
            if (existing != null) {
                // Đã tồn tại -> Trả về thông tin của size đã có sẵn
                response.getWriter().write("{\"status\":\"SUCCESS\",\"maSize\":" + existing.getMaSize() + ",\"tenSize\":\"" + existing.getTenSize() + "\",\"message\":\"Kích cỡ này đã có sẵn!\"}");
                return;
            }

            // Chưa tồn tại -> Thêm mới
            KichCo newSize = new KichCo();
            newSize.setTenSize(normalized);
            newSize.setThuTuHienThi(10); // Thứ tự hiển thị ưu tiên mặc định

            boolean added = kichCoRepository.add(newSize);
            if (added) {
                // Truy vấn lại để lấy ma_size IDENTITY vừa tự sinh từ SQL Server
                KichCo saved = kichCoRepository.getByTenSize(normalized);
                if (saved != null) {
                    response.getWriter().write("{\"status\":\"SUCCESS\",\"maSize\":" + saved.getMaSize() + ",\"tenSize\":\"" + saved.getTenSize() + "\"}");
                } else {
                    response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Không tìm thấy kích cỡ vừa khởi tạo!\"}");
                }
            } else {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Không thể lưu kích cỡ mới vào cơ sở dữ liệu!\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi thêm kích cỡ AJAX trong SanPhamController", e);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Sự cố hệ thống khi thêm nhanh kích cỡ!\"}");
        }
    }

    private void performCreate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String tenSp = request.getParameter("tenSp");
            String maDmStr = request.getParameter("maDm");
            if (tenSp == null || tenSp.trim().isEmpty() || maDmStr == null) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ Tên sản phẩm và chọn Danh mục!");
                showCreateForm(request, response);
                return;
            }

            int maDm = Integer.parseInt(maDmStr);
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
            sp.setIsNew(isNew);
            sp.setIsBestseller(isBestseller);
            sp.setTrangThai(trangThai);

            List<KichCo> allSizes = kichCoRepository.getAll();
            List<SanPhamKichCo> selectedSizes = new ArrayList<>();
            for (KichCo kc : allSizes) {
                String checkboxName = "size_active_" + kc.getMaSize();
                if (request.getParameter(checkboxName) != null) {
                    try {
                        String priceParam = request.getParameter("size_price_" + kc.getMaSize());
                        if (priceParam != null && !priceParam.trim().isEmpty()) {
                            int giaBan = Integer.parseInt(priceParam.trim());
                            String dinhLuong = request.getParameter("size_volume_" + kc.getMaSize());
                            SanPhamKichCo spkc = new SanPhamKichCo(null, kc.getMaSize(), giaBan, dinhLuong, true);
                            selectedSizes.add(spkc);
                        }
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "Lỗi định dạng giá bán cho kích cỡ mã " + kc.getMaSize(), e);
                    }
                }
            }

            // Đọc thêm các size mới sinh động có thể được thêm trực tiếp từ client-side AJAX
            // Chúng ta quét toàn bộ tham số gửi lên để tìm các checkbox có dạng size_active_X mà có thể chưa có trong danh sách allSizes cũ
            java.util.Enumeration<String> parameterNames = request.getParameterNames();
            while (parameterNames.hasMoreElements()) {
                String paramName = parameterNames.nextElement();
                if (paramName.startsWith("size_active_")) {
                    int maSize = Integer.parseInt(paramName.replace("size_active_", ""));
                    // Kiểm tra xem đã thêm size này vào selectedSizes chưa
                    boolean alreadyProcessed = false;
                    for (SanPhamKichCo sk : selectedSizes) {
                        if (sk.getMaSize() == maSize) {
                            alreadyProcessed = true;
                            break;
                        }
                    }
                    if (!alreadyProcessed) {
                        try {
                            String priceParam = request.getParameter("size_price_" + maSize);
                            if (priceParam != null && !priceParam.trim().isEmpty()) {
                                int giaBan = Integer.parseInt(priceParam.trim());
                                String dinhLuong = request.getParameter("size_volume_" + maSize);
                                SanPhamKichCo spkc = new SanPhamKichCo(null, maSize, giaBan, dinhLuong, true);
                                selectedSizes.add(spkc);
                            }
                        } catch (NumberFormatException e) {
                            LOGGER.log(Level.WARNING, "Lỗi định dạng giá bán cho kích cỡ động mã " + maSize, e);
                        }
                    }
                }
            }

            if (selectedSizes.isEmpty()) {
                request.setAttribute("error", "Sản phẩm mới bắt buộc phải cấu hình tối thiểu một kích cỡ và giá bán đi kèm!");
                request.setAttribute("product", sp);
                showCreateForm(request, response);
                return;
            }

            boolean success = sanPhamService.createSanPham(sp, selectedSizes);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=createsuccess");
            } else {
                request.setAttribute("error", "Ghi nhận sản phẩm vào cơ sở dữ liệu thất bại!");
                request.setAttribute("product", sp);
                showCreateForm(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Sập luồng tạo mới sản phẩm", e);
            request.setAttribute("error", "Sự cố hệ thống không mong muốn!");
            showCreateForm(request, response);
        }
    }

    private void performUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String maSp = request.getParameter("maSp");
            String tenSp = request.getParameter("tenSp");
            String maDmStr = request.getParameter("maDm");
            if (maSp == null || tenSp == null || tenSp.trim().isEmpty() || maDmStr == null) {
                request.setAttribute("error", "Thông tin sản phẩm cập nhật bị khuyết thiếu!");
                showEditForm(request, response);
                return;
            }

            int maDm = Integer.parseInt(maDmStr);
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
                sp.setIsNew(isNew);
                sp.setIsBestseller(isBestseller);
                sp.setTrangThai(trangThai);

                List<SanPhamKichCo> selectedSizes = new ArrayList<>();
                java.util.Enumeration<String> parameterNames = request.getParameterNames();
                while (parameterNames.hasMoreElements()) {
                    String paramName = parameterNames.nextElement();
                    if (paramName.startsWith("size_active_")) {
                        try {
                            int maSize = Integer.parseInt(paramName.replace("size_active_", ""));
                            String priceParam = request.getParameter("size_price_" + maSize);
                            if (priceParam != null && !priceParam.trim().isEmpty()) {
                                int giaBan = Integer.parseInt(priceParam.trim());
                                String dinhLuong = request.getParameter("size_volume_" + maSize);
                                SanPhamKichCo spkc = new SanPhamKichCo(maSp, maSize, giaBan, dinhLuong, true);
                                selectedSizes.add(spkc);
                            }
                        } catch (NumberFormatException e) {
                            LOGGER.log(Level.WARNING, "Lỗi định dạng tham số cấu hình kích cỡ", e);
                        }
                    }
                }

                if (selectedSizes.isEmpty()) {
                    request.setAttribute("error", "Không thể lưu: Sản phẩm phải có ít nhất một kích cỡ hoạt động!");
                    showEditForm(request, response);
                    return;
                }

                boolean success = sanPhamService.updateSanPham(sp, selectedSizes);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=updatesuccess");
                } else {
                    request.setAttribute("error", "Cập nhật sản phẩm thất bại trong CSDL!");
                    showEditForm(request, response);
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=notfound");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi luồng cập nhật sản phẩm", e);
            request.setAttribute("error", "Lỗi xử lý nghiệp vụ cập nhật!");
            showEditForm(request, response);
        }
    }
}