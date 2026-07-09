<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Lấy URI hiện tại của trình duyệt để xử lý tô sáng menu tự động (Active State) -->
<c:set var="uri" value="${pageContext.request.requestURI}" />

<div class="admin-sidebar">
    <!-- Phần tiêu đề Sidebar -->
    <div class="sidebar-header d-flex flex-column align-items-center">
        <div class="fs-2 text-success mb-2" style="color: #10b981 !important;">
            <i class="bi bi-cup-hot-fill"></i>
        </div>
        <h5 class="fw-bold mb-0 text-white" style="letter-spacing: 1px;">TEA POS</h5>
        <small class="text-muted" style="font-size: 11px;">HỆ THỐNG QUẢN TRỊ VIÊN</small>
    </div>

    <!-- Danh sách Menu liên kết -->
    <ul class="sidebar-menu flex-grow-1 mb-0 ps-0">
        <!-- 1. Dashboard -->
        <li class="sidebar-item ${uri.contains('/admin/dashboard') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2 fs-5"></i>
                <span>Trang tổng quan</span>
            </a>
        </li>

        <!-- 2. Quản lý Danh mục -->
        <li class="sidebar-item ${uri.contains('/admin/danhmuc') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/danhmuc">
                <i class="bi bi-grid-1x2-fill fs-5"></i>
                <span>Quản lý danh mục</span>
            </a>
        </li>

        <!-- 3. Quản lý Sản phẩm -->
        <li class="sidebar-item ${uri.contains('/admin/sanpham') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/sanpham">
                <i class="bi bi-cup-straw fs-5"></i>
                <span>Quản lý sản phẩm</span>
            </a>
        </li>

        <!-- 4. Quản lý Topping -->
        <li class="sidebar-item ${uri.contains('/admin/topping') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/topping">
                <i class="bi bi-egg-fried fs-5"></i>
                <span>Quản lý topping</span>
            </a>
        </li>

        <!-- 5. Quản lý Voucher -->
        <li class="sidebar-item ${uri.contains('/admin/voucher') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/voucher">
                <i class="bi bi-ticket-perforated-fill fs-5"></i>
                <span>Khuyến mãi - Voucher</span>
            </a>
        </li>

        <!-- 6. Quản lý Hóa đơn -->
        <li class="sidebar-item ${uri.contains('/admin/hoadon') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/hoadon">
                <i class="bi bi-receipt fs-5"></i>
                <span>Lịch sử hóa đơn</span>
            </a>
        </li>

        <!-- 7. Quản lý Khách hàng -->
        <li class="sidebar-item ${uri.contains('/admin/khachhang') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/khachhang">
                <i class="bi bi-people-fill fs-5"></i>
                <span>Khách hàng (CRM)</span>
            </a>
        </li>

        <!-- 8. Quản lý Nhân viên -->
        <li class="sidebar-item ${uri.contains('/admin/nhanvien') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/nhanvien">
                <i class="bi bi-person-badge-fill fs-5"></i>
                <span>Hồ sơ nhân viên</span>
            </a>
        </li>

        <!-- 9. Nhật ký hoạt động -->
        <li class="sidebar-item ${uri.contains('/admin/auditlog') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/auditlog">
                <i class="bi bi-journal-text fs-5"></i>
                <span>Nhật ký hoạt động</span>
            </a>
        </li>

        <!-- 10. Cài đặt hệ thống -->
        <li class="sidebar-item ${uri.contains('/admin/settings') ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/settings">
                <i class="bi bi-gear-fill fs-5"></i>
                <span>Cài đặt cá nhân</span>
            </a>
        </li>
    </ul>

    <!-- Khu vực chuyển nhanh qua ca làm POS (Phục vụ phân quyền Admin chuyển tiếp) -->
    <div class="p-3 border-top border-secondary" style="background-color: #0f172a;">
        <a href="${pageContext.request.contextPath}/pos" class="btn btn-outline-success btn-sm w-100 py-2 d-flex align-items-center justify-content-center gap-2 border-2" style="border-radius: 6px;">
            <i class="bi bi-cart3"></i>
            <span class="fw-semibold">Vào quầy POS</span>
        </a>
    </div>
</div>