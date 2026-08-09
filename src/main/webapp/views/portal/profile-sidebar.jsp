<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    // LẤY DỮ LIỆU TỔNG CHI TIÊU THỰC TẾ TRỌN ĐỜI CỦA KHÁCH HÀNG CRM ĐỂ TÍNH TIẾN TRÌNH THĂNG HẠNG
    model.entity.KhachHang cust = (model.entity.KhachHang) session.getAttribute("customer");
    int tongChiTieu = 0;
    if (cust != null) {
        tongChiTieu = service.impl.KhachHangServiceImpl.getInstance().getTongChiTieu(cust.getMaKh());
    }
    request.setAttribute("customerTongChiTieu", tongChiTieu);
%>

<c:set var="currentUri" value="${pageContext.request.requestURI}" />

<div class="col-12 col-md-3">
    <!-- ==================== DESKTOP SIDEBAR VERSION ==================== -->
    <div class="profile-sidebar-card d-none d-md-block text-center mb-4">
        <!-- Ảnh đại diện Avatar thành viên CRM -->
        <img src="${not empty sessionScope.customer.hinhAnhUrl && sessionScope.customer.hinhAnhUrl ne 'None' ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
             class="rounded-circle border border-4 border-success mx-auto mb-3 animate-pulse"
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

        <!-- TIẾN TRÌNH THĂNG HẠNG CRM ĐỘNG (DỰA TRÊN TỔNG TIỀN MUA SẮM THỰC TẾ) -->
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

            <c:choose>
                <c:when test="${sessionScope.customer.maHang == 1}">
                    <c:set var="targetMoney" value="500000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 2}">
                    <c:set var="targetMoney" value="2000000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 3}">
                    <c:set var="targetMoney" value="5000000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="pct" value="100"/>
                    <c:set var="moneyNeeded" value="0"/>
                </c:otherwise>
            </c:choose>
            <c:if test="${sessionScope.customer.maHang < 4}">
                <c:set var="pct" value="${(currentMoney / targetMoney) * 100}"/>
                <c:set var="moneyNeeded" value="${targetMoney - currentMoney}"/>
            </c:if>

            <div class="progress mb-2" style="height: 10px; border-radius: 5px;">
                <div class="progress-bar progress-bar-striped progress-bar-animated bg-success"
                     role="progressbar"
                     style="width: ${pct > 100 ? 100 : pct}%">
                </div>
            </div>
            <c:choose>
                <c:when test="${moneyNeeded > 0}">
                    <p class="mb-0 text-muted" style="font-size: 10px; line-height: 1.4;">
                        Tích lũy thực tế: <b><fmt:formatNumber value="${currentMoney}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</b>.<br>
                        Mua thêm: <strong class="text-danger"><fmt:formatNumber value="${moneyNeeded}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong> để thăng hạng!
                    </p>
                </c:when>
                <c:otherwise>
                    <p class="mb-0 text-success fw-bold" style="font-size: 10px;">
                        Chúc mừng! Bạn đã đạt thứ hạng thành viên tối đa.
                    </p>
                </c:otherwise>
            </c:choose>
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
        <!-- Danh sách menu điều hướng -->
        <div class="list-group list-group-flush text-start gap-1">
            <a href="${pageContext.request.contextPath}/profile"
               class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold d-flex align-items-center gap-2
               ${(currentUri.endsWith('/profile') || currentUri.contains('/ho_so.jsp')) ? 'bg-success text-white shadow-sm' : 'text-dark bg-white'}">
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
                <i class="bi bi-box-arrow-right fs-5"></i> Đăng xuất
            </a>
        </div>
    </div>

    <!-- ==================== MOBILE PREMIUM COMPACT MEMBER CARD VERSION (d-block d-md-none) ==================== -->
    <div class="card d-block d-md-none border-0 p-3 mb-3 shadow-sm rounded-4 text-start position-relative overflow-hidden"
         style="background: linear-gradient(135deg, #111827 0%, #064e3b 100%) !important; color: #ffffff !important; border: 1.5px solid rgba(16, 185, 129, 0.3) !important;">
        <!-- Background aesthetic matcha blur circles -->
        <div class="position-absolute" style="top: -20px; right: -20px; width: 100px; height: 100px; background: rgba(16, 185, 129, 0.15); border-radius: 50%; filter: blur(20px);"></div>

        <div class="d-flex align-items-center gap-3 mb-2.5">
            <img src="${not empty sessionScope.customer.hinhAnhUrl && sessionScope.customer.hinhAnhUrl ne 'None' ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
                 class="rounded-circle border border-2 border-success"
                 style="width: 50px; height: 50px; object-fit: cover;">
            <div>
                <h6 class="fw-bold mb-0.5 text-white" style="color: #ffffff !important;"><c:out value="${sessionScope.customer.tenKh}"/></h6>
                <div class="d-flex align-items-center gap-2">
                    <!-- High-contrast frosted glass premium badge for Hạng -->
                    <span class="badge border" style="font-size: 10px; padding: 4px 10px; background-color: rgba(255, 255, 255, 0.15) !important; color: #ffffff !important; border-color: rgba(255, 255, 255, 0.3) !important; border-radius: 6px;">
                        👑 Hạng:
                        <c:choose>
                            <c:when test="${sessionScope.customer.maHang == 1}">ĐỒNG</c:when>
                            <c:when test="${sessionScope.customer.maHang == 2}">BẠC</c:when>
                            <c:when test="${sessionScope.customer.maHang == 3}">VÀNG 👑</c:when>
                            <c:when test="${sessionScope.customer.maHang == 4}">VIP 💎</c:when>
                            <c:otherwise>MỚI</c:otherwise>
                        </c:choose>
                    </span>
                    <span style="font-size: 11px; color: rgba(255, 255, 255, 0.7) !important;">Mã: ${sessionScope.customer.maKh}</span>
                </div>
            </div>
        </div>

        <!-- Progress bar and points info with customized bright contrast styling -->
        <div class="p-2.5 rounded-3 bg-white bg-opacity-5 border border-white border-opacity-10 small" style="background-color: rgba(255, 255, 255, 0.05) !important; border-color: rgba(255, 255, 255, 0.1) !important;">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <span style="font-size: 11px; color: rgba(255, 255, 255, 0.8) !important;">Tiến trình thăng hạng:</span>
                <!-- Vibrant Mint Neon Green for current level target on dark bg -->
                <strong style="font-size: 11px; color: #34d399 !important;">
                    <c:choose>
                        <c:when test="${sessionScope.customer.maHang == 1}">Đồng ➔ Bạc</c:when>
                        <c:when test="${sessionScope.customer.maHang == 2}">Bạc ➔ Vàng</c:when>
                        <c:when test="${sessionScope.customer.maHang == 3}">Vàng ➔ VIP</c:when>
                        <c:otherwise>Hạng cao nhất 🎉</c:otherwise>
                    </c:choose>
                </strong>
            </div>

            <!-- Precalculate PCT and needed money based on TRUE LIFETIME SPENT -->
            <c:choose>
                <c:when test="${sessionScope.customer.maHang == 1}">
                    <c:set var="targetMoney" value="500000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 2}">
                    <c:set var="targetMoney" value="2000000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:when test="${sessionScope.customer.maHang == 3}">
                    <c:set var="targetMoney" value="5000000"/>
                    <c:set var="currentMoney" value="${customerTongChiTieu}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="pct" value="100"/>
                    <c:set var="moneyNeeded" value="0"/>
                </c:otherwise>
            </c:choose>
            <c:if test="${sessionScope.customer.maHang < 4}">
                <c:set var="pct" value="${(currentMoney / targetMoney) * 100}"/>
                <c:set var="moneyNeeded" value="${targetMoney - currentMoney}"/>
            </c:if>

            <!-- Bright vibrant green progress bar -->
            <div class="progress mb-2" style="height: 8px; border-radius: 4px; background-color: rgba(255, 255, 255, 0.15) !important;">
                <div class="progress-bar progress-bar-striped progress-bar-animated"
                     role="progressbar"
                     style="width: ${pct > 100 ? 100 : pct}% !important; background-color: #10b981 !important;">
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center" style="font-size: 10px;">
                <!-- Vivid neon mint green for wallet points -->
                <span style="color: rgba(255, 255, 255, 0.8) !important;">Tài khoản: <strong style="color: #34d399 !important;">${sessionScope.customer.diemTichLuy} điểm</strong></span>
                <c:choose>
                    <c:when test="${moneyNeeded > 0}">
                        <!-- Bright Amber Gold for remaining buy amount -->
                        <span style="color: rgba(255, 255, 255, 0.8) !important;">Mua thêm: <strong style="color: #fbbf24 !important;"><fmt:formatNumber value="${moneyNeeded}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong></span>
                    </c:when>
                    <c:otherwise>
                        <span style="color: #34d399 !important; font-weight: bold;">Đạt Mốc VIP Tối Đa! 💎</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- MOBILE HORIZONTAL SCROLL BAR VERSION (SOLVES STACKING SCROLL BOTTLENECK) -->
    <div class="profile-nav-mobile d-flex d-md-none">
        <a href="${pageContext.request.contextPath}/profile"
           class="profile-nav-mobile-link ${(currentUri.endsWith('/profile') || currentUri.contains('/ho_so.jsp')) ? 'active' : ''}">
            <i class="bi bi-person-vcard me-1"></i> Hồ sơ
        </a>
        <a href="${pageContext.request.contextPath}/profile/orders"
           class="profile-nav-mobile-link ${currentUri.contains('/profile/orders') || currentUri.contains('/theo_doi_don.jsp') || currentUri.contains('/chi_tiet_don.jsp') ? 'active' : ''}">
            <i class="bi bi-clock-history me-1"></i> Lịch sử đơn
        </a>
        <a href="${pageContext.request.contextPath}/profile/vouchers"
           class="profile-nav-mobile-link ${currentUri.contains('/profile/vouchers') || currentUri.contains('/kho_voucher.jsp') ? 'active' : ''}">
            <i class="bi bi-ticket-perforated-fill me-1 text-success"></i> Ví Voucher
        </a>
        <a href="${pageContext.request.contextPath}/logout"
           class="profile-nav-mobile-link profile-nav-mobile-link-danger">
            <i class="bi bi-box-arrow-right me-1"></i> Đăng xuất
        </a>
    </div>
</div>
