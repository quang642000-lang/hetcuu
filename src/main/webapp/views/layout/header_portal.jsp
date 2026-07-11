<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet" type="text/css">
</head>
<body>
<!-- BANNER MARQUEE -->
<div class="bg-success text-white text-center py-2 fs-6 fw-semibold" style="background-color: var(--primary-color) !important; font-size: 13px !important; letter-spacing: 0.5px;">
    🎉 THƯỞNG 1 ĐIỂM CRM CHO MỖI 10.000 VNĐ CHI TIÊU - TỰ ĐỘNG THĂNG HẠNG VÀ NHẬN VÍ VOUCHER VIP!
</div>
<!-- NAVBAR CHÍNH -->
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top py-3 shadow-sm">
    <div class="container">
        <!-- Logo -->
        <a class="navbar-brand d-flex align-items-center fw-bold text-success" href="${pageContext.request.contextPath}/home" style="color: var(--primary-color) !important; font-size: 22px;">
            <i class="bi bi-cup-hot-fill me-2 fs-3"></i>
            <span style="letter-spacing: -0.5px;">TEA POS PORTAL</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#portalNavbarCollapse" aria-controls="portalNavbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="portalNavbarCollapse">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4 gap-2">
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark px-3 py-2 rounded-2 ${pageContext.request.requestURI.endsWith('/home') ? 'bg-light text-success' : ''}" href="${pageContext.request.contextPath}/home">
                        <i class="bi bi-house-door me-1"></i> Trang chủ
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark px-3 py-2 rounded-2 ${pageContext.request.requestURI.contains('/products') || pageContext.request.requestURI.contains('/product/') ? 'bg-light text-success' : ''}" href="${pageContext.request.contextPath}/products">
                        <i class="bi bi-cup-straw me-1"></i> Thực đơn trà sữa
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark px-3 py-2 rounded-2 ${pageContext.request.requestURI.contains('/profile/orders') ? 'bg-light text-success' : ''}" href="${pageContext.request.contextPath}/profile/orders">
                        <i class="bi bi-clipboard-check me-1"></i> Theo dõi đơn hàng
                    </a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-3">
                <!-- Nút Giỏ hàng Badge động -->
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-success position-relative rounded-circle d-flex align-items-center justify-content-center" style="width: 44px; height: 44px; color: var(--primary-color); border-color: var(--primary-color); border-width: 2px;">
                    <i class="bi bi-cart3 fs-5"></i>
                    <c:if test="${not empty sessionScope.customer}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-circle bg-danger text-white border border-light" style="font-size: 10px; width: 22px; height: 22px; display: flex; align-items: center; justify-content: center; padding: 0;">
                            <c:out value="${not empty sessionScope.customerCartCount ? sessionScope.customerCartCount : '0'}" />
                        </span>
                    </c:if>
                </a>

                <!-- Dropdown Khách CRM -->
                <c:choose>
                    <c:when test="${not empty sessionScope.customer}">
                        <div class="dropdown">
                            <a class="d-flex align-items-center text-decoration-none dropdown-toggle text-dark" href="#" id="customerProfileDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <img src="${not empty sessionScope.customer.hinhAnhUrl ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" alt="Avatar" class="rounded-circle border border-2 border-success me-2" style="width: 38px; height: 38px; object-fit: cover;">
                                <div class="d-flex flex-column text-start me-1">
                                    <span class="fw-bold text-success" style="font-size: 13px;"><c:out value="${sessionScope.customer.tenKh}"/></span>
                                    <span class="text-muted" style="font-size: 11px; font-weight: 500;">Ví CRM: <c:out value="${sessionScope.customer.diemTichLuy}"/> điểm</span>
                                </div>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3 mt-2 py-2" aria-labelledby="customerProfileDropdown" style="min-width: 220px;">
                                <li>
                                    <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/profile">
                                        <i class="bi bi-person-vcard text-muted"></i>
                                        <span>Thông tin tài khoản</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/profile/orders">
                                        <i class="bi bi-clock-history text-muted"></i>
                                        <span>Lịch sử đặt nước</span>
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item py-2 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/profile/vouchers">
                                        <i class="bi bi-ticket-perforated text-muted"></i>
                                        <span>Ví Voucher cá nhân</span>
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item py-2 text-danger d-flex align-items-center gap-2 fw-semibold" href="${pageContext.request.contextPath}/logout">
                                        <i class="bi bi-box-arrow-right"></i>
                                        <span>Đăng xuất tài khoản</span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/login" class="btn btn-primary-teapos px-4 rounded-3 fw-bold shadow-sm d-flex align-items-center gap-1">
                            <i class="bi bi-box-arrow-in-right fs-5"></i> ĐĂNG NHẬP THÀNH VIÊN
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>