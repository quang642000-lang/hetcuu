<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Lấy servlet path từ forward attributes của Tomcat, nếu trống thì lùi về servletPath mặc định --%>
<c:set var="fPath" value="${requestScope['jakarta.servlet.forward.servlet_path']}" />
<c:set var="cPath" value="${not empty fPath ? fPath : pageContext.request.servletPath}" />
<c:set var="uri" value="${pageContext.request.requestURI}" />

<style>
    /* =========================================================================
       CSS KHẮC PHỤC TRIỆT ĐỂ LỖI CHỒNG CHÉO LAYOUT SIDEBAR & ADMIN CONTENT
       ========================================================================= */
    .admin-wrapper {
        display: flex;
        min-height: 100vh;
        width: 100%;
        overflow-x: hidden; /* Ngăn chặn thanh cuộn ngang gây vỡ khung */
    }

    .admin-sidebar {
        width: 260px;
        background-color: #1e293b; /* Đen Slate sẫm màu */
        color: #f8fafc;
        flex-shrink: 0; /* Tuyệt đối không cho phép Sidebar bị co rút */
        display: flex;
        flex-direction: column;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 4px 0 10px rgba(0,0,0,0.1);
    }

    .admin-content {
        flex-grow: 1;
        min-width: 0; /* CỰC KỲ QUAN TRỌNG: Ép flex item (nội dung) không nở rộng quá container khi chứa bảng/card lớn */
        display: flex;
        flex-direction: column;
        background-color: #f8fafc;
    }

    /* CSS Slide Sidebar responsive cho Mobile và Tablet */
    @media (max-width: 991.98px) {
        .admin-sidebar {
            position: fixed;
            left: 0;
            top: 0;
            bottom: 0;
            z-index: 1050;
            transform: translateX(-100%);
            transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            width: 260px !important;
        }
        .admin-sidebar.show {
            transform: translateX(0);
            box-shadow: 4px 0 25px rgba(0, 0, 0, 0.15);
        }
        .sidebar-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 1040;
            display: none;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .sidebar-overlay.show {
            display: block;
            opacity: 1;
        }
    }
</style>

<!-- Overlay dùng để chạm tắt đóng Sidebar trên Mobile/Tablet -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>
<div class="admin-sidebar" id="adminSidebar">
    <!-- Phần tiêu đề Sidebar -->
    <div class="sidebar-header d-flex flex-column align-items-center position-relative">
        <!-- Nút đóng nhanh chỉ hiển thị trên mobile/tablet -->
        <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 d-lg-none" onclick="toggleSidebar()"></button>
        <div class="fs-2 text-success mb-2" style="color: #10b981 !important;">
            <i class="bi bi-cup-hot-fill animate-pulse"></i>
        </div>
        <h5 class="fw-bold mb-0 text-white" style="letter-spacing: 1px;">TEA POS</h5>
        <small class="text-muted" style="font-size: 11px;">HỆ THỐNG QUẢN TRỊ VIÊN</small>
    </div>

    <!-- Danh sách Menu liên kết với cơ chế đối soát thông minh (Khử trùng lắp JSP/Servlet path) -->
    <ul class="sidebar-menu flex-grow-1 mb-0 ps-0">
        <!-- 1. Dashboard -->
        <li class="sidebar-item ${cPath eq '/admin/dashboard' || uri.contains('dashboard.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2 fs-5"></i>
                <span>Trang tổng quan</span>
            </a>
        </li>
        <!-- 2. Quản lý Danh mục -->
        <li class="sidebar-item ${cPath eq '/admin/danhmuc' || uri.contains('danh_muc.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/danhmuc">
                <i class="bi bi-grid-1x2-fill fs-5"></i>
                <span>Quản lý danh mục</span>
            </a>
        </li>
        <!-- 3. Quản lý Sản phẩm -->
        <li class="sidebar-item ${cPath eq '/admin/sanpham' || uri.contains('san_pham.jsp') || uri.contains('sanpham-form.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/sanpham">
                <i class="bi bi-cup-straw fs-5"></i>
                <span>Quản lý sản phẩm</span>
            </a>
        </li>
        <!-- 4. Quản lý Topping -->
        <li class="sidebar-item ${cPath eq '/admin/topping' || uri.contains('topping.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/topping">
                <i class="bi bi-egg-fried fs-5"></i>
                <span>Quản lý topping</span>
            </a>
        </li>
        <!-- 5. Quản lý Voucher -->
        <li class="sidebar-item ${cPath eq '/admin/voucher' || uri.contains('voucher.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/voucher">
                <i class="bi bi-ticket-perforated-fill fs-5"></i>
                <span>Khuyến mãi - Voucher</span>
            </a>
        </li>
        <!-- 6. Quản lý Hóa đơn -->
        <li class="sidebar-item ${cPath eq '/admin/hoadon' || uri.contains('hoa_don.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/hoadon">
                <i class="bi bi-receipt fs-5"></i>
                <span>Lịch sử hóa đơn</span>
            </a>
        </li>
        <!-- 7. Quản lý Khách hàng -->
        <li class="sidebar-item ${cPath eq '/admin/khachhang' || uri.contains('khach_hang.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/khachhang">
                <i class="bi bi-people-fill fs-5"></i>
                <span>Khách hàng (CRM)</span>
            </a>
        </li>
        <!-- 8. Quản lý Nhân viên -->
        <li class="sidebar-item ${cPath eq '/admin/nhanvien' || uri.contains('nhan_vien.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/nhanvien">
                <i class="bi bi-person-badge-fill fs-5"></i>
                <span>Hồ sơ nhân viên</span>
            </a>
        </li>
        <!-- 9. Nhật ký hoạt động -->
        <li class="sidebar-item ${cPath eq '/admin/auditlog' || uri.contains('nhat_ky.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/auditlog">
                <i class="bi bi-journal-text fs-5"></i>
                <span>Nhật ký hoạt động</span>
            </a>
        </li>
        <!-- 10. Cài đặt hệ thống -->
        <li class="sidebar-item ${cPath eq '/admin/settings' || uri.contains('cai_dat.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/settings">
                <i class="bi bi-gear-fill fs-5"></i>
                <span>Cài đặt cá nhân</span>
            </a>
        </li>
    </ul>

    <!-- Khu vực chuyển nhanh qua ca làm POS -->
    <div class="p-3 border-top border-secondary" style="background-color: #0f172a;">
        <a href="${pageContext.request.contextPath}/pos" class="btn btn-outline-success btn-sm w-100 py-2 d-flex align-items-center justify-content-center gap-2 border-2" style="border-radius: 6px;">
            <i class="bi bi-cart3"></i>
            <span class="fw-semibold">Vào quầy POS</span>
        </a>
    </div>
</div>

<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('adminSidebar');
        const overlay = document.getElementById('sidebarOverlay');
        if (sidebar && overlay) {
            sidebar.classList.toggle('show');
            overlay.classList.toggle('show');
        }
    }
</script>