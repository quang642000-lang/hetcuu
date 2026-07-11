<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="currentUri" value="${pageContext.request.requestURI}" />
<div class="col-12 col-md-3">
    <div class="card border-0 p-4 shadow-sm text-center mb-4" style="border-radius: 16px; background-color: #ffffff;">
        <!-- Ảnh đại diện Avatar thành viên CRM -->
        <img src="${not empty sessionScope.customer.hinhAnhUrl ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
             class="rounded-circle border border-4 border-success mx-auto mb-3"
             style="width: 100px; height: 100px; object-fit: cover;">

        <!-- Họ tên khách hàng -->
        <h5 class="fw-bold mb-1 text-dark"><c:out value="${sessionScope.customer.tenKh}"/></h5>

        <!-- Cấp hạng thành viên tương thích với CSDL -->
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

        <!-- TIẾN TRÌNH THĂNG HẠNG CRM ĐỘNG (DỰA TRÊN ĐƠN HÀNG/ĐIỂM SỐ QUY ĐỔI RA DOANH THU THỰC TẾ) -->
        <div class="text-start mb-4 p-2 bg-light rounded" style="border: 1px dashed #10b981;">
            <div class="d-flex justify-content-between align-items-center mb-1 small">
                <span class="text-muted fw-semibold" style="font-size: 11px;">Tiến trình thăng hạng:</span>
                <strong class="text-success" style="font-size: 11px;">
                    <c:choose>
                        <c:when test="${sessionScope.customer.maHang == 1}">Đồng ➔ Bạc</c:when>
                        <c:when test="${sessionScope.customer.maHang == 2}">Bạc ➔ Vàng</c:when>
                        <c:when test="${sessionScope.customer.maHang == 3}">Vàng ➔ VIP</c:when>
                        <c:otherwise>Hạng cao nhất 🎉</c:otherwise>
                    </c:choose>
                </strong>
            </div>

            <!-- Cấu hình chi tiết mốc thăng hạng CRM dựa trên tổng tiền hóa đơn đã mua (1 Điểm = 10.000 VNĐ chi tiêu) -->
            <c:choose>
                <c:when test="${sessionScope.customer.maHang == 1}">
                    <!-- Hạng Đồng -> Bạc: đích chi tiêu đạt 500.000đ (50 điểm) -->
                    <c:set var="targetMoney" value="500000"/>
                    <c:set var="currentMoney" value="${sessionScope.customer.diemTichLuy * 10000}"/>
                    <c:set var="pct" value="${(currentMoney / targetMoney) * 100}"/>
                    <c:set var="moneyNeeded" value="${targetMoney - currentMoney}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 2}">
                    <!-- Hạng Bạc -> Vàng: đích chi tiêu đạt 2.000.000đ (200 điểm) -->
                    <c:set var="targetMoney" value="2000000"/>
                    <c:set var="currentMoney" value="${sessionScope.customer.diemTichLuy * 10000}"/>
                    <c:set var="pct" value="${(currentMoney / targetMoney) * 100}"/>
                    <c:set var="moneyNeeded" value="${targetMoney - currentMoney}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 3}">
                    <!-- Hạng Vàng -> VIP: đích chi tiêu đạt 5.000.000đ (500 điểm) -->
                    <c:set var="targetMoney" value="5000000"/>
                    <c:set var="currentMoney" value="${sessionScope.customer.diemTichLuy * 10000}"/>
                    <c:set var="pct" value="${(currentMoney / targetMoney) * 100}"/>
                    <c:set var="moneyNeeded" value="${targetMoney - currentMoney}"/>
                </c:when>
                <c:otherwise>
                    <!-- Hạng VIP: Đã kịch mốc thăng hạng -->
                    <c:set var="pct" value="100"/>
                    <c:set var="moneyNeeded" value="0"/>
                </c:otherwise>
            </c:choose>

            <div class="progress mb-2" style="height: 10px; border-radius: 5px;">
                <div class="progress-bar progress-bar-striped progress-bar-animated bg-success"
                     role="progressbar"
                     style="width: ${pct > 100 ? 100 : pct}%"
                     aria-valuenow="${pct}"
                     aria-valuemin="0"
                     aria-valuemax="100">
                </div>
            </div>

            <c:choose>
                <c:when test="${moneyNeeded > 0}">
                    <p class="mb-0 text-muted" style="font-size: 10px; line-height: 1.4;">
                        Đã chi tiêu tích lũy: <b><fmt:formatNumber value="${currentMoney}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</b>.<br>
                        Cần mua thêm: <strong class="text-danger"><fmt:formatNumber value="${moneyNeeded}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong> để nâng hạng thẻ tiếp theo!
                    </p>
                </c:when>
                <c:otherwise>
                    <p class="mb-0 text-success fw-bold" style="font-size: 10px;">
                        Chúc mừng! Bạn đã đạt thứ hạng thành viên tối đa của TEA POS.
                    </p>
                </c:otherwise>
            </c:choose>

            <!-- Quy chế reset hạng 6 tháng cực kỳ thực tế -->
            <hr class="my-2 border-secondary border-dashed">
            <span class="d-block text-muted" style="font-size: 9px; font-style: italic; line-height: 1.3;">
                <i class="bi bi-info-circle-fill text-warning"></i> Chu kỳ xét hạng & duy trì hạng: 6 tháng. Đợt reset / hạ hạng duy trì kế tiếp: <b>31/12/2026</b>.
            </span>
        </div>

        <!-- Ví điểm CRM tích lũy -->
        <div class="bg-light rounded p-3 text-start mb-3" style="border: 1px solid var(--border-color);">
            <div class="d-flex justify-content-between mb-2">
                <span class="text-muted small">Mã CRM:</span>
                <strong class="text-dark small">${sessionScope.customer.maKh}</strong>
            </div>
            <div class="d-flex justify-content-between">
                <span class="text-muted small">Ví điểm Loyalty:</span>
                <strong class="text-success small">${sessionScope.customer.diemTichLuy} điểm</strong>
            </div>
        </div>
        <hr class="my-3">

        <!-- Danh sách menu điều hướng Portal Profile -->
        <div class="list-group list-group-flush text-start gap-1">
            <a href="${pageContext.request.contextPath}/profile"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${(currentUri.endsWith('/profile') || currentUri.contains('/profile.jsp') || currentUri.contains('/ho_so.jsp')) ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-person-vcard fs-5"></i> Hồ sơ cá nhân
            </a>
            <a href="${pageContext.request.contextPath}/profile/orders"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${currentUri.contains('/profile/orders') || currentUri.contains('/theo_doi_don.jsp') || currentUri.contains('/chi_tiet_don.jsp') ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-clock-history fs-5"></i> Lịch sử đặt nước
            </a>
            <a href="${pageContext.request.contextPath}/profile/vouchers"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${currentUri.contains('/profile/vouchers') || currentUri.contains('/kho_voucher.jsp') ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
                <i class="bi bi-ticket-perforated-fill fs-5"></i> Ví Voucher VIP
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold text-danger d-flex align-items-center gap-2 bg-white">
                <i class="bi bi-box-arrow-right fs-5"></i> Đăng xuất tài khoản
            </a>
        </div>
    </div>
</div>