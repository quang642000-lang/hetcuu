<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet" type="text/css">
</head>
<body>
<div class="bg-success text-white text-center py-2 fs-6 fw-semibold" style="background-color: var(--primary-color) !important; font-size: 13px !important; letter-spacing: 0.5px;">
    🎉 THƯỞNG 1 ĐIỂM CRM CHO MỖI 10.000 VNĐ CHI TIÊU - TỰ ĐỘNG THĂNG HẠNG VÀ NHẬN VÍ VOUCHER VIP!
</div>
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom sticky-top py-3">
    <div class="container">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/home">
            <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
            <span>TEA POS</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarPortal">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarPortal">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4">
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark" href="${pageContext.request.contextPath}/home">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold text-dark" href="${pageContext.request.contextPath}/products">Menu Đồ uống</a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-success position-relative" style="border-radius: 8px;">
                    <i class="bi bi-cart3"></i>
                    <c:if test="${not empty sessionScope.customerCartCount && sessionScope.customerCartCount > 0}">
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 10px;">
                                    ${sessionScope.customerCartCount}
                            </span>
                    </c:if>
                </a>
                <c:choose>
                    <c:when test="${not empty sessionScope.customer}">
                        <div class="dropdown">
                            <a class="dropdown-toggle text-decoration-none d-flex align-items-center" href="#" role="button" id="customerDropdownMenu" data-bs-toggle="dropdown" aria-expanded="false">
                                <img src="${not empty sessionScope.customer.hinhAnhUrl ? sessionScope.customer.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" alt="Avatar" class="rounded-circle border border-2 border-success me-2" style="width: 38px; height: 38px; object-fit: cover;">
                                <div class="d-flex flex-column text-start me-1">
                                    <span class="fw-bold text-success" style="font-size: 13px;"><c:out value="${sessionScope.customer.tenKh}"/></span>
                                </div>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2 py-2" aria-labelledby="customerDropdownMenu" style="min-width: 180px;">
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
                                    <a class="dropdown-item py-2 text-danger fw-semibold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/logout">
                                        <i class="bi bi-box-arrow-right"></i>
                                        <span>Đăng xuất</span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/login" class="btn btn-success fw-bold px-4" style="border-radius: 8px;">ĐĂNG NHẬP</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>