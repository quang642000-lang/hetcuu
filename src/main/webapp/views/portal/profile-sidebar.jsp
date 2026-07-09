<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%-- THAY THẾ DÒNG URI CŨ BỊ ĐỎ SANG CHUẨN JAKARTA EE MỚI --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Lấy URI hiện tại của trình duyệt để xử lý tô sáng menu tự động (Active State) -->
<c:set var="currentUri" value="${pageContext.request.requestURI}" />

<div class="col-12 col-md-3">
    <div class="card border-0 p-4 shadow-sm text-center mb-4" style="border-radius: 16px; background-color: #ffffff;">
        <!-- Ảnh đại diện Avatar thành viên CRM -->
        <img src="${not empty sessionScope.customer.hinhAnhUrl ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
             class="rounded-circle border border-4 border-success mx-auto mb-3"
             style="width: 100px; height: 100px; object-fit: cover;">

        <!-- Họ tên khách hàng đăng nhập -->
        <h5 class="fw-bold mb-1 text-dark"><c:out value="${sessionScope.customer.tenKh}"/></h5>

        <!-- Badge hiển thị Hạng thẻ VIP tương thích với CSDL -->
        <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 small mb-3">
            👑 Hạng:
            <c:choose>
                <c:when test="${sessionScope.customer.maHang == 1}">ĐỒNG</c:when>
                <c:when test="${sessionScope.customer.maHang == 2}">BẠC</c:when>
                <c:when test="${sessionScope.customer.maHang == 3}">VÀNG 👑</c:when>
                <c:when test="${sessionScope.customer.maHang == 4}">VIP 💎</c:when>
                <c:otherwise>MỚI</c:otherwise>
            </c:choose>
        </span>

        <!-- Ví điểm CRM tích lũy của khách hàng -->
        <div class="bg-light rounded p-3 text-start mb-3" style="border: 1px solid var(--border-color);">
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted small">Mã CRM:</span>
                <strong class="text-dark small">${sessionScope.customer.maKh}</strong>
            </div>
            <div class="d-flex justify-content-between">
                <span class="text-muted small">Điểm tích lũy:</span>
                <strong class="text-success small">${sessionScope.customer.diemTichLuy} điểm</strong>
            </div>
        </div>

        <hr class="my-3">

        <!-- Danh sách menu điều hướng Portal Profile -->
        <div class="list-group list-group-flush text-start gap-1">
            <!-- Link 1: Sửa đổi thông tin cá nhân -->
            <a href="${pageContext.request.contextPath}/profile"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${(currentUri.endsWith('/profile') || currentUri.contains('/profile.jsp')) ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-person-vcard fs-5"></i> Hồ sơ cá nhân
            </a>

            <!-- Link 2: Danh sách đơn hàng đã đặt Click & Collect -->
            <a href="${pageContext.request.contextPath}/profile/orders"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${currentUri.contains('/profile/orders') ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-clock-history fs-5"></i> Lịch sử đặt nước
            </a>

            <!-- Link 3: Ví ưu đãi mã giảm giá khả dụng -->
            <a href="${pageContext.request.contextPath}/profile/vouchers"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${currentUri.contains('/profile/vouchers') ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-ticket-perforated-fill fs-5"></i> Ví Voucher VIP
            </a>

            <!-- Link 4: Đăng xuất tài khoản an toàn -->
            <a href="${pageContext.request.contextPath}/logout"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold text-danger d-flex align-items-center gap-2 bg-white">
                <i class="bi bi-box-arrow-right fs-5"></i> Đăng xuất tài khoản
            </a>
        </div>
    </div>
</div>