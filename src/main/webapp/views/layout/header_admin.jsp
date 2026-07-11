<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="admin-header shadow-sm bg-white">
    <!-- Phần 1: Tiêu đề mô tả phân hệ hiển thị động & Nút Hamburger cho Mobile -->
    <div class="d-flex align-items-center gap-3">
        <!-- Nút Hamburger Menu ẩn hiện Sidebar trên thiết bị di động -->
        <button class="btn btn-outline-success d-lg-none" type="button" onclick="toggleSidebar()" style="border-radius: 8px; border-width: 2px;">
            <i class="bi bi-list fs-5"></i>
        </button>
        <h4 class="fw-bold text-dark mb-0 fs-5 d-none d-md-flex align-items-center" style="letter-spacing: -0.5px;">
            <i class="bi bi-shield-lock-fill text-success me-2" style="color: var(--primary-color) !important;"></i>
            HỆ THỐNG ĐIỀU PHỐI VÀ QUẢN TRỊ CHUỒI CỬA HÀNG TEA POS
        </h4>
        <span class="badge bg-light text-success border border-success px-2 py-1 small fw-semibold d-none d-sm-inline">Phần cứng máy chủ: Sẵn sàng</span>
    </div>
    <!-- Phần 2: Đồng hồ hệ thống và thông tin tài khoản -->
    <div class="d-flex align-items-center gap-4">
        <!-- Đồng hồ realtime -->
        <div class="text-end d-none d-md-block border-end pe-3 border-2" style="height: 38px;">
            <div class="fw-bold text-success" id="clockTime" style="font-size: 14px; color: var(--primary-color);">00:00:00</div>
            <div class="text-muted" id="clockDate" style="font-size: 11px; font-weight: 500;">Chủ nhật, ngày 01/01/2026</div>
        </div>
        <!-- Chuông thông báo đơn hàng trực tuyến Click & Collect -->
        <div class="position-relative cursor-pointer" id="adminNotificationBell">
            <a href="${pageContext.request.contextPath}/pos/nhandon" class="text-secondary hover-text-dark" style="color: var(--text-muted);">
                <i class="bi bi-bell-fill fs-5 text-warning"></i>
                <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle animate-ping"></span>
            </a>
        </div>
        <!-- Thông tin người dùng đăng nhập & Dropdown menu -->
        <div class="dropdown">
            <a class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" href="#" id="adminProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                <img src="https://cdn-icons-png.flaticon.com/512/2206/2206368.png" alt="Admin Avatar" class="rounded-circle border border-2 border-success me-2" style="width: 36px; height: 36px; object-fit: cover;">
                <div class="d-flex flex-column text-start me-1">
                    <span class="fw-bold text-dark lh-sm" style="font-size: 13px;"><c:out value="${not empty sessionScope.user ? sessionScope.user.hoTen : 'Quản trị viên'}" /></span>
                    <span class="text-muted lh-1" style="font-size: 11px;">Mã: <c:out value="${not empty sessionScope.user ? sessionScope.user.maNv : 'ADMIN'}" /></span>
                </div>
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 mt-2 py-2" aria-labelledby="adminProfileMenu" style="min-width: 200px;">
                <li>
                    <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin/settings">
                        <i class="bi bi-person-circle text-muted"></i>
                        <span>Thông tin cá nhân</span>
                    </a>
                </li>
                <li>
                    <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin/settings?action=changePassword">
                        <i class="bi bi-key-fill text-muted"></i>
                        <span>Đổi mật khẩu bảo mật</span>
                    </a>
                </li>
                <li><hr class="dropdown-divider"></li>
                <li>
                    <a class="dropdown-item py-2 text-danger d-flex align-items-center gap-2 fw-semibold" href="${pageContext.request.contextPath}/logout">
                        <i class="bi bi-box-arrow-right"></i>
                        <span>Đăng xuất hệ thống</span>
                    </a>
                </li>
            </ul>
        </div>
    </div>
</header>
<!-- Đoạn script Javascript điều hành hoạt động của Đồng hồ Realtime trên Header Admin -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        function updateAdminClock() {
            const daysOfWeek = ["Chủ nhật", "Thứ hai", "Thứ ba", "Thứ tư", "Thứ năm", "Thứ sáu", "Thứ bảy"];
            const now = new Date();
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            const clockTimeEl = document.getElementById('clockTime');
            if (clockTimeEl) {
                clockTimeEl.textContent = hours + ":" + minutes + ":" + seconds;
            }
            const dayName = daysOfWeek[now.getDay()];
            const date = String(now.getDate()).padStart(2, '0');
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const year = now.getFullYear();
            const clockDateEl = document.getElementById('clockDate');
            if (clockDateEl) {
                clockDateEl.textContent = dayName + ", ngày " + date + "/" + month + "/" + year;
            }
        }
        updateAdminClock();
        setInterval(updateAdminClock, 1000);
    });
</script>