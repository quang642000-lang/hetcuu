<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet" type="text/css">
</head>
<body>
<!-- PROMOTION BAR WITH IMMUNE COLOR SYSTEM -->
<div class="portal-promo-bar text-center py-2 fw-semibold">
    🎉 THƯỞNG 1 ĐIỂM CRM CHO MỖI 10.000 VNĐ CHI TIÊU - TỰ ĐỘNG THĂNG HẠNG VÀ NHẬN VÍ VOUCHER VIP!
</div>

<!-- TOP STICKY NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top py-2.5 shadow-sm">
    <div class="container-fluid container-lg d-flex align-items-center justify-content-between">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/home" style="color: #059669 !important;">
            <i class="bi bi-cup-hot-fill me-1.5 fs-4 animate-pulse"></i>
            <span class="d-inline" style="font-size: 18px; letter-spacing: -0.5px;">TEA POS</span>
        </a>

        <div class="d-flex align-items-center gap-2.5 ms-auto order-lg-3">
            <!-- Cart Icon Button -->
            <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-success position-relative p-2" style="border-radius: 8px; border-color: var(--primary); color: var(--primary);">
                <i class="bi bi-cart3 fs-5"></i>
                <c:if test="${not empty sessionScope.customerCartCount && sessionScope.customerCartCount > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-flex align-items-center justify-content-center" style="font-size: 10px; width: 20px; height: 20px; padding: 0; border: 1.5px solid #ffffff;">
                                ${sessionScope.customerCartCount}
                        </span>
                </c:if>
            </a>

            <!-- Account Profile Dropdown -->
            <c:choose>
                <c:when test="${not empty sessionScope.customer}">
                    <div class="dropdown">
                        <a class="dropdown-toggle text-decoration-none d-flex align-items-center" href="#" role="button" id="customerDropdownMenu" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="${not empty sessionScope.customer.hinhAnhUrl && sessionScope.customer.hinhAnhUrl ne 'None' ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
                                 alt="Avatar" class="rounded-circle border border-2 border-success" style="width: 36px; height: 36px; object-fit: cover;">
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2 py-2 rounded-3" aria-labelledby="customerDropdownMenu" style="min-width: 190px;">
                            <li class="px-3 py-2 border-bottom border-light mb-1">
                                <small class="text-muted d-block" style="font-size:10px;">Đã đăng nhập</small>
                                <strong class="text-dark small text-truncate d-block" style="max-width: 155px;"><c:out value="${sessionScope.customer.tenKh}"/></strong>
                            </li>
                            <li>
                                <a class="dropdown-item py-2 d-flex align-items-center gap-2 small fw-semibold" href="${pageContext.request.contextPath}/profile">
                                    <i class="bi bi-person-vcard text-muted"></i>
                                    <span>Thông tin tài khoản</span>
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item py-2 d-flex align-items-center gap-2 small fw-semibold" href="${pageContext.request.contextPath}/profile/orders">
                                    <i class="bi bi-clock-history text-muted"></i>
                                    <span>Lịch sử đặt nước</span>
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item py-2 d-flex align-items-center gap-2 small fw-semibold text-success" href="${pageContext.request.contextPath}/profile/vouchers">
                                    <i class="bi bi-ticket-perforated-fill"></i>
                                    <span>Ví Voucher cá nhân</span>
                                </a>
                            </li>
                            <li><hr class="dropdown-divider my-1"></li>
                            <li>
                                <a class="dropdown-item py-2 text-danger fw-bold d-flex align-items-center gap-2 small" href="${pageContext.request.contextPath}/logout">
                                    <i class="bi bi-box-arrow-right"></i>
                                    <span>Đăng xuất</span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/customer/login" class="btn btn-success fw-bold px-3 btn-sm" style="border-radius: 8px; background-color: var(--primary); border: none;">ĐĂNG NHẬP</a>
                </c:otherwise>
            </c:choose>

            <!-- Navbar Toggler for mobile menus -->
            <button class="navbar-toggler border-0 p-1 d-lg-none" type="button" data-bs-toggle="collapse" data-bs-target="#navbarPortal">
                <span class="navbar-toggler-icon" style="width: 22px; height: 22px;"></span>
            </button>
        </div>

        <div class="collapse navbar-collapse" id="navbarPortal">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4 text-start">
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark py-2" href="${pageContext.request.contextPath}/home">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark py-2" href="${pageContext.request.contextPath}/products">Menu Đồ uống</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
