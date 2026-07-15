package controller.admin;

import model.entity.DanhMuc;
import model.entity.KichCo;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import model.entity.NhatKyHoatDong;
import repository.IKichCoRepository;
import repository.impl.KichCoRepoImpl;
import repository.impl.NhatKyRepoImpl;
import service.IDanhMucService;
import service.ISanPhamService;
import service.impl.DanhMucServiceImpl;
import service.impl.SanPhamServiceImpl;
import config.DBConnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.JsonParserUtil;

@WebServlet(name = "SanPhamController", urlPatterns = {"/admin/sanpham"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50   // 50MB
)
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
            case "checkSizeOrder":
                performCheckSizeOrder(request, response);
                break;
            case "deleteSizeMasterAjax":
                performDeleteSizeMasterAjax(request, response);
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
            List<SanPhamKichCo> currentPrices = new ArrayList<>();
            String sql = "SELECT pk.ma_sp, pk.ma_size, pk.gia_ban, pk.dinh_luong, pk.trang_thai, kc.ten_size " +
                    "FROM SAN_PHAM_KICH_CO pk " +
                    "JOIN KICH_CO kc ON pk.ma_size = kc.ma_size " +
                    "WHERE pk.ma_sp = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        SanPhamKichCo spkc = new SanPhamKichCo(
                                rs.getString("ma_sp"),
                                rs.getInt("ma_size"),
                                rs.getInt("gia_ban"),
                                rs.getString("dinh_luong"),
                                rs.getBoolean("trang_thai")
                        );
                        spkc.setTenSize(rs.getString("ten_size"));
                        currentPrices.add(spkc);
                    }
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Lỗi nạp mảng size cấu hình trong showEditForm", e);
            }
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

    private void performToggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        boolean status = "1".equals(request.getParameter("status"));
        SanPham sp = sanPhamService.getSanPhamById(id);
        if (sp != null) {
            String oldJson = JsonParserUtil.toJson(sp);
            sp.setTrangThai(status);
            List<SanPhamKichCo> sizes = sanPhamService.getSizesBySanPham(id);
            boolean success = sanPhamService.updateSanPham(sp, sizes);
            if (success) {
                HttpSession session = request.getSession(false);
                String actorNv = "SYSTEM";
                if (session != null && session.getAttribute("user") != null) {
                    actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
                }
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv,
                        status ? "BẬT_MỞ_BÁN_SẢN_PHẨM" : "TẮT_MỞ_BÁN_SẢN_PHẨM",
                        "SAN_PHAM",
                        oldJson,
                        JsonParserUtil.toJson(sp),
                        request.getRemoteAddr(),
                        null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=updatesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=notfound");
        }
    }

    private void performDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("id");
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();
        boolean hasOrders = false;
        String checkSql = "SELECT COUNT(*) FROM CHI_TIET_DON_HANG WHERE ma_sp = ?";
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
            boolean softSuccess = sanPhamService.deleteSanPham(id);
            if (softSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "SOFT_DELETE_SẢN_PHẨM", "SAN_PHAM", "Mã SP: " + id, "Chuyển trạng thái hoạt động về 0 do có lịch sử bán lẻ.", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=softdeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=deletefailed");
            }
        } else {
            boolean hardSuccess = false;
            String deletePricesSql = "DELETE FROM SAN_PHAM_KICH_CO WHERE ma_sp = ?";
            String deleteSpSql = "DELETE FROM SAN_PHAM WHERE ma_sp = ?";
            try (Connection conn = DBConnect.getConnection()) {
                conn.setAutoCommit(false);
                try (PreparedStatement ps1 = conn.prepareStatement(deletePricesSql);
                     PreparedStatement ps2 = conn.prepareStatement(deleteSpSql)) {
                    ps1.setString(1, id);
                    ps1.executeUpdate();
                    ps2.setString(1, id);
                    int d2 = ps2.executeUpdate();
                    if (d2 > 0) {
                        hardSuccess = true;
                    }
                    conn.commit();
                } catch (SQLException e) {
                    conn.rollback();
                    e.printStackTrace();
                } finally {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            if (hardSuccess) {
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "HARD_DELETE_SẢN_PHẨM", "SAN_PHAM", "Mã SP: " + id, "Xóa hoàn toàn sản phẩm khỏi hệ thống (chưa từng giao dịch).", ip, null
                ));
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=harddeletesuccess");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/sanpham?msg=deletefailed");
            }
        }
    }

    private void performCheckSizeOrder(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String maSp = request.getParameter("maSp");
        String maSizeStr = request.getParameter("maSize");
        if (maSp == null || maSizeStr == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Tham số đầu vào bị thiếu!\"}");
            return;
        }
        try {
            int maSize = Integer.parseInt(maSizeStr);
            boolean hasOrders = false;
            String sql = "SELECT COUNT(*) FROM CHI_TIET_DON_HANG WHERE ma_sp = ? AND ma_size = ?";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, maSp);
                ps.setInt(2, maSize);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        hasOrders = true;
                    }
                }
            }
            if (hasOrders) {
                response.getWriter().write("{\"status\":\"HAS_ORDERS\"}");
            } else {
                response.getWriter().write("{\"status\":\"NO_ORDERS\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi kiểm tra lịch sử hóa đơn của biến thể size", e);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Lỗi hệ thống khi kiểm tra đơn!\"}");
        }
    }

    private void performDeleteSizeMasterAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String maSizeStr = request.getParameter("maSize");
        if (maSizeStr == null) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Mã kích cỡ bị trống!\"}");
            return;
        }
        try {
            int maSize = Integer.parseInt(maSizeStr);
            boolean deleted = kichCoRepository.delete(maSize);
            if (deleted) {
                response.getWriter().write("{\"status\":\"SUCCESS\"}");
            } else {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Không thể xóa kích cỡ này khỏi hệ thống do có sản phẩm liên kết!\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa cứng kích cỡ master", e);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Lỗi hệ thống khi xóa kích cỡ!\"}");
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

    private void performAddSizeAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String tenSize = request.getParameter("tenSize");
        if (tenSize == null || tenSize.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Tên kích cỡ không được trống!\"}");
            return;
        }
        try {
            String normalized = tenSize.trim().toUpperCase();
            KichCo existing = kichCoRepository.getByTenSize(normalized);
            if (existing != null) {
                response.getWriter().write("{\"status\":\"SUCCESS\",\"maSize\":" + existing.getMaSize() + ",\"tenSize\":\"" + existing.getTenSize() + "\",\"message\":\"Kích cỡ này đã có sẵn!\"}");
                return;
            }
            KichCo newSize = new KichCo();
            newSize.setTenSize(normalized);
            newSize.setThuTuHienThi(10);
            boolean added = kichCoRepository.add(newSize);
            if (added) {
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
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();
        try {
            String tenSp = request.getParameter("tenSp");
            String maDmStr = request.getParameter("maDm");
            if (tenSp == null || tenSp.trim().isEmpty() || maDmStr == null || maDmStr.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập đầy đủ Tên sản phẩm và chọn Danh mục!");
                showCreateForm(request, response);
                return;
            }
            String moTa = request.getParameter("moTa");
            String hinhAnh = "";
            String uploadType = request.getParameter("uploadType");
            if ("file".equals(uploadType)) {
                hinhAnh = uploadFile(request, "hinhAnhFile");
            } else {
                hinhAnh = request.getParameter("hinhAnhUrl");
            }
            boolean choPhepDoiDa = request.getParameter("choPhepDoiDa") != null;
            boolean choPhepDoiDuong = request.getParameter("choPhepDoiDuong") != null;
            boolean isNew = request.getParameter("isNew") != null;
            boolean isBestseller = request.getParameter("isBestseller") != null;
            boolean trangThai = "1".equals(request.getParameter("trangThai"));
            SanPham sp = new SanPham();
            sp.setTenSp(tenSp);
            sp.setMaDm(maDmStr);
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
                            boolean sizeStatus = request.getParameter("size_status_" + kc.getMaSize()) != null;
                            SanPhamKichCo spkc = new SanPhamKichCo(null, kc.getMaSize(), giaBan, dinhLuong, sizeStatus);
                            selectedSizes.add(spkc);
                        }
                    } catch (NumberFormatException e) {
                        LOGGER.log(Level.WARNING, "Lỗi định dạng giá bán cho kích cỡ mã " + kc.getMaSize(), e);
                    }
                }
            }
            java.util.Enumeration<String> parameterNames = request.getParameterNames();
            while (parameterNames.hasMoreElements()) {
                String paramName = parameterNames.nextElement();
                if (paramName.startsWith("size_active_")) {
                    int maSize = Integer.parseInt(paramName.replace("size_active_", ""));
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
                                boolean sizeStatus = request.getParameter("size_status_" + maSize) != null;
                                SanPhamKichCo spkc = new SanPhamKichCo(null, maSize, giaBan, dinhLuong, sizeStatus);
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
                NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                        actorNv, "THÊM_SẢN_PHẨM", "SAN_PHAM", null, JsonParserUtil.toJson(sp), ip, null
                ));
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
        HttpSession session = request.getSession(false);
        String actorNv = "SYSTEM";
        if (session != null && session.getAttribute("user") != null) {
            actorNv = ((model.entity.NhanVien) session.getAttribute("user")).getMaNv();
        }
        String ip = request.getRemoteAddr();
        try {
            String maSp = request.getParameter("maSp");
            String tenSp = request.getParameter("tenSp");
            String maDmStr = request.getParameter("maDm");
            if (maSp == null || tenSp == null || tenSp.trim().isEmpty() || maDmStr == null || maDmStr.trim().isEmpty()) {
                request.setAttribute("error", "Thông tin sản phẩm cập nhật bị khuyết thiếu!");
                showEditForm(request, response);
                return;
            }
            String moTa = request.getParameter("moTa");
            String hinhAnh = request.getParameter("currentHinhAnh");
            String uploadType = request.getParameter("uploadType");
            if ("file".equals(uploadType)) {
                String uploaded = uploadFile(request, "hinhAnhFile");
                if (uploaded != null && !uploaded.isEmpty()) {
                    hinhAnh = uploaded;
                }
            } else {
                String url = request.getParameter("hinhAnhUrl");
                if (url != null && !url.trim().isEmpty()) {
                    hinhAnh = url;
                }
            }
            boolean choPhepDoiDa = request.getParameter("choPhepDoiDa") != null;
            boolean choPhepDoiDuong = request.getParameter("choPhepDoiDuong") != null;
            boolean isNew = request.getParameter("isNew") != null;
            boolean isBestseller = request.getParameter("isBestseller") != null;
            boolean trangThai = "1".equals(request.getParameter("trangThai"));
            SanPham sp = sanPhamService.getSanPhamById(maSp);
            if (sp != null) {
                String oldJson = JsonParserUtil.toJson(sp);
                sp.setTenSp(tenSp);
                sp.setMaDm(maDmStr);
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
                                boolean sizeStatus = request.getParameter("size_status_" + kc.getMaSize()) != null;
                                SanPhamKichCo spkc = new SanPhamKichCo(maSp, kc.getMaSize(), giaBan, dinhLuong, sizeStatus);
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
                    NhatKyRepoImpl.getInstance().addLog(new NhatKyHoatDong(
                            actorNv, "SỬA_SẢN_PHẨM", "SAN_PHAM", oldJson, JsonParserUtil.toJson(sp), ip, null
                    ));
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

    private String uploadFile(HttpServletRequest request, String inputFieldName) {
        try {
            Part filePart = request.getPart(inputFieldName);
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                String fileExt = "";
                int dotIdx = fileName.lastIndexOf('.');
                if (dotIdx > 0) {
                    fileExt = fileName.substring(dotIdx);
                }
                String newFileName = System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + fileExt;
                String baseDir = System.getProperty("os.name").toLowerCase().contains("win") ? "C:/teapos_uploads/images/" : "/var/teapos_uploads/images/";
                File uploadDir = new File(baseDir);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                File file = new File(uploadDir, newFileName);
                filePart.write(file.getAbsolutePath());
                return request.getContextPath() + "/assets/images/" + newFileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}