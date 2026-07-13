<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="uri" value="${pageContext.request.requestURI}" />
<c:set var="fPath" value="${requestScope['jakarta.servlet.forward.servlet_path']}" />
<c:set var="cPath" value="${not empty fPath ? fPath : pageContext.request.servletPath}" />

<style>
    /* =========================================================================
       BULLETPROOF LAYOUT LOCKING & ELITE EMERALD-SLATE DESIGN FOR SIDEBAR
       ========================================================================= */
    /* 1. FORCE NO VIEWPORT VERTICAL DRIFT AT BODY LEVEL */
    html, body {
        height: 100vh !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important; /* Block master page scrolling */
    }

    /* 2. REINFORCE THE FLEX CONTAINER AT WRAPPER LEVEL */
    .admin-wrapper {
        display: flex !important;
        flex-direction: row !important;
        height: 100vh !important;
        width: 100vw !important;
        overflow: hidden !important;
    }

    /* 3. SIDEBAR ANCHORING - LOCK IT SOLID */
    .admin-sidebar {
        width: 260px !important;
        height: 100vh !important;
        background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%) !important; /* Premium Slate Dark Gradient */
        color: #f8fafc !important;
        display: flex !important;
        flex-direction: column !important;
        flex-shrink: 0 !important;
        z-index: 1030 !important;
        overflow-y: auto !important; /* Scroll nested menus only if they overflow */
        border-right: 1px solid #334155 !important;
        box-shadow: 4px 0 20px rgba(15, 23, 42, 0.15) !important;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    /* 4. MAIN CONTENT AREA SCROLL LOCK */
    .admin-content {
        flex-grow: 1 !important;
        min-width: 0 !important;
        height: 100vh !important;
        overflow-y: auto !important; /* ONLY SCROLLABLE AREA IN THE SYSTEM */
        display: flex !important;
        flex-direction: column !important;
        background-color: #f8fafc !important;
    }

    /* 5. GORGEOUS STYLING WITH SEMANTIC HOVERS */
    .sidebar-header {
        padding: 24px 20px !important;
        border-bottom: 1px solid #334155 !important;
        background-color: #0b0f19 !important;
        text-align: center !important;
    }

    .sidebar-menu {
        list-style: none !important;
        padding: 16px 12px !important;
        margin: 0 !important;
        flex-grow: 1 !important;
    }

    .sidebar-item {
        margin-bottom: 6px !important;
    }

    .sidebar-item a {
        display: flex !important;
        align-items: center !important;
        padding: 12px 16px !important;
        color: #94a3b8 !important;
        text-decoration: none !important;
        font-weight: 500 !important;
        border-radius: 8px !important;
        gap: 12px !important;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1) !important;
    }

    /* Hover translation effect */
    .sidebar-item a:hover {
        color: #ffffff !important;
        background-color: rgba(16, 185, 129, 0.08) !important; /* Smooth Emerald tint overlay */
        padding-left: 20px !important; /* Subtle slider slide-to-right */
    }

    /* Active Highlight emerald glow */
    .sidebar-item.active a {
        color: #ffffff !important;
        background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important; /* Radiant Emerald gradient */
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25) !important;
        font-weight: 600 !important;
    }

    .sidebar-item i {
        font-size: 1.15rem !important;
        transition: transform 0.2s ease !important;
    }

    .sidebar-item a:hover i {
        transform: scale(1.1) rotate(5deg) !important; /* Dynamic icon vibration on hover */
    }

    .sidebar-item.active i {
        color: #ffffff !important;
    }

    /* 6. MOBILE SLIDE-IN DRAWER MEDIA QUERY */
    @media (max-width: 991.98px) {
        .admin-sidebar {
            position: fixed !important;
            left: 0 !important;
            top: 0 !important;
            bottom: 0 !important;
            z-index: 1050 !important;
            transform: translateX(-100%) !important;
            transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
            width: 260px !important;
        }
        .admin-sidebar.show {
            transform: translateX(0) !important;
        }
        .sidebar-overlay {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            right: 0 !important;
            bottom: 0 !important;
            background: rgba(15, 23, 42, 0.6) !important;
            backdrop-filter: blur(4px) !important;
            z-index: 1040 !important;
            display: none !important;
            opacity: 0 !important;
            transition: opacity 0.3s ease !important;
        }
        .sidebar-overlay.show {
            display: block !important;
            opacity: 1 !important;
        }
    }
</style>

<!-- Sidebar mobile touch overlay backdrop -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

<div class="admin-sidebar" id="adminSidebar">
    <!-- Sidebar Header branding -->
    <div class="sidebar-header d-flex flex-column align-items-center position-relative">
        <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 d-lg-none" onclick="toggleSidebar()"></button>
        <div class="fs-2 text-success mb-2" style="color: #10b981 !important;">
            <i class="bi bi-cup-hot-fill animate-pulse text-success"></i>
        </div>
        <h5 class="fw-bold mb-0 text-white" style="letter-spacing: 1px;">TEA POS</h5>
        <small class="text-muted" style="font-size: 11px;">HỆ THỐNG QUẢN TRỊ VIÊN</small>
    </div>

    <!-- Sidebar Menus -->
    <ul class="sidebar-menu flex-grow-1 mb-0 ps-0">
        <!-- 1. Dashboard -->
        <li class="sidebar-item ${cPath eq '/admin/dashboard' || uri.contains('dashboard.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i>
                <span>Trang tổng quan</span>
            </a>
        </li>
        <!-- 2. Quản lý Danh mục -->
        <li class="sidebar-item ${cPath eq '/admin/danhmuc' || uri.contains('danh_muc.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/danhmuc">
                <i class="bi bi-grid-1x2-fill"></i>
                <span>Quản lý danh mục</span>
            </a>
        </li>
        <!-- 3. Quản lý Sản phẩm -->
        <li class="sidebar-item ${cPath eq '/admin/sanpham' || uri.contains('san_pham.jsp') || uri.contains('sanpham-form.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/sanpham">
                <i class="bi bi-cup-straw"></i>
                <span>Quản lý sản phẩm</span>
            </a>
        </li>
        <!-- 4. Quản lý Topping -->
        <li class="sidebar-item ${cPath eq '/admin/topping' || uri.contains('topping.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/topping">
                <i class="bi bi-egg-fried"></i>
                <span>Quản lý topping</span>
            </a>
        </li>
        <!-- 5. Quản lý Voucher -->
        <li class="sidebar-item ${cPath eq '/admin/voucher' || uri.contains('voucher.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/voucher">
                <i class="bi bi-ticket-perforated-fill"></i>
                <span>Khuyến mãi - Voucher</span>
            </a>
        </li>
        <!-- 6. Quản lý Hóa đơn -->
        <li class="sidebar-item ${cPath eq '/admin/hoadon' || uri.contains('hoa_don.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/hoadon">
                <i class="bi bi-receipt"></i>
                <span>Lịch sử hóa đơn</span>
            </a>
        </li>
        <!-- 7. Quản lý Khách hàng -->
        <li class="sidebar-item ${cPath eq '/admin/khachhang' || uri.contains('khach_hang.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/khachhang">
                <i class="bi bi-people-fill"></i>
                <span>Khách hàng (CRM)</span>
            </a>
        </li>
        <!-- 8. Quản lý Nhân viên -->
        <li class="sidebar-item ${cPath eq '/admin/nhanvien' || uri.contains('nhan_vien.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/nhanvien">
                <i class="bi bi-person-badge-fill"></i>
                <span>Hồ sơ nhân viên</span>
            </a>
        </li>
        <!-- 9. Nhật ký hoạt động -->
        <li class="sidebar-item ${cPath eq '/admin/auditlog' || uri.contains('nhat_ky.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/auditlog">
                <i class="bi bi-journal-text"></i>
                <span>Nhật ký hoạt động</span>
            </a>
        </li>
        <!-- 10. Cài đặt hệ thống -->
        <li class="sidebar-item ${cPath eq '/admin/settings' || uri.contains('cai_dat.jsp') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/settings">
                <i class="bi bi-gear-fill"></i>
                <span>Cài đặt cá nhân</span>
            </a>
        </li>
    </ul>

    <!-- Quick back action to thu ngân POS quầy -->
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