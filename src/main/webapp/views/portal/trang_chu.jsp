<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Cổng Đặt Nước Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet">
</head>
<body class="bg-light">
<!-- NAV HEADER -->
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4">
    <!-- BANNER CHƯƠNG TRÌNH KHUYẾN MÃI + Ô TÌM KIẾM TRỰC QUAN -->
    <div class="portal-banner shadow-sm mb-4 bg-success text-white">
        <h1 class="fw-bold mb-2 text-white text-uppercase">HƯƠNG VỊ THẬT - ĐAM MÊ THẬT!</h1>
        <p class="mb-4 text-white">Đặt nước nhanh chóng, nhận ngay tại quầy qua phương thức Click & Collect tiện lợi.</p>

        <!-- THANH TÌM KIẾM HOẠT ĐỘNG CHUẨN XÁC CHUẨN CHỈ -->
        <form action="${pageContext.request.contextPath}/products" method="GET" class="d-flex mx-auto bg-white p-1.5 rounded-pill shadow-sm" style="max-width: 600px; padding: 4px;">
            <input type="text" name="search" class="form-control border-0 bg-transparent px-3 py-2 text-dark" placeholder="Tìm kiếm đồ uống yêu thích của bạn..." style="outline: none !important; box-shadow: none;">
            <button type="submit" class="btn btn-success px-4 rounded-pill fw-bold" style="background-color: var(--primary); border: none;">
                <i class="bi bi-search me-1"></i> TÌM KIẾM
            </button>
        </form>
    </div>

    <!-- DANH MỤC TRÒN NỔI BẬT -->
    <div class="mb-5 text-center">
        <h4 class="fw-bold mb-4 d-flex align-items-center justify-content-center gap-2 text-dark">
            <i class="bi bi-grid-fill text-success"></i> DANH MỤC ĐỒ UỐNG
        </h4>
        <div class="row row-cols-2 row-cols-md-4 g-3 g-md-4 justify-content-center">
            <c:forEach var="cat" items="${categories}">
                <div class="col">
                    <div class="category-circle-card p-3 border rounded-3 bg-white shadow-sm" onclick="window.location.href='${pageContext.request.contextPath}/products?category=${cat.maDm}'">
                        <c:choose>
                            <c:when test="${not empty cat.hinhAnh}">
                                <img src="${cat.hinhAnh}" class="mx-auto rounded-circle mb-3 border border-2 border-success" style="width: 70px; height: 70px; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                                <div class="mx-auto bg-success-subtle text-success rounded-circle d-flex align-items-center justify-content-center mb-3" style="width: 70px; height: 70px;">
                                    <i class="bi bi-cup-straw fs-2"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <span class="fw-bold text-dark text-uppercase small d-block"><c:out value="${cat.tenDm}"/></span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- SẢN PHẨM BÁN CHẠY (BESTSELLERS) -->
    <div class="mb-5 text-start">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold mb-0 d-flex align-items-center gap-2 text-dark">
                <i class="bi bi-fire text-danger animate-pulse"></i> ĐỒ UỐNG BÁN CHẠY NHẤT (HOT)
            </h4>
            <a href="${pageContext.request.contextPath}/products?filter=hot" class="text-success fw-semibold small text-decoration-none">Xem tất cả <i class="bi bi-chevron-right"></i></a>
        </div>
        <div class="row g-3 g-md-4 row-cols-1 row-cols-md-2 row-cols-lg-3">
            <c:forEach var="sp" items="${bestsellers}">
                <div class="col">
                    <div class="product-card p-2.5 p-md-3 shadow-sm position-relative">
                        <span class="position-absolute top-0 end-0 badge bg-danger text-white fw-bold m-2 px-2.5 py-1.5 shadow-sm" style="border-radius: 8px; font-size: 10px; z-index: 10;">BESTSELLER 🔥</span>
                        <img src="${not empty sp.hinhAnh ? sp.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded mb-3 product-card-img" style="height: 180px; object-fit: cover;" alt="Product">
                        <h6 class="fw-bold text-dark mb-1 text-truncate product-card-title"><c:out value="${sp.tenSp}"/></h6>
                        <p class="text-muted small text-truncate mb-3 d-none d-md-block product-card-desc"><c:out value="${sp.moTa}"/></p>

                        <div class="d-flex flex-column gap-2 mt-auto border-top pt-2.5 product-card-footer">
                            <div class="product-card-price-row">
                                <span class="product-card-price-lbl">Giá khởi điểm:</span>
                                <strong class="product-card-price-val">
                                    <c:forEach var="size" items="${sp.sizesList}" end="0">
                                        <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                    </c:forEach>
                                </strong>
                            </div>
                            <a href="${pageContext.request.contextPath}/product/detail?id=${sp.maSp}" class="btn btn-success btn-sm w-100 py-2.5 fw-bold text-center d-flex align-items-center justify-content-center gap-1 btn-customize-mobile" style="font-size: 12px; border-radius: 8px;">
                                <i class="bi bi-eye-fill"></i> TÙY BIẾN PHA CHẾ
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- MÓN MỚI LÊN KỆ (NEW ARRIVALS) -->
    <div class="mb-5 text-start">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold mb-0 d-flex align-items-center gap-2 text-dark">
                <i class="bi bi-stars text-warning animate-pulse"></i> SẢN PHẨM MỚI LÊN KỆ
            </h4>
            <a href="${pageContext.request.contextPath}/products?filter=new" class="text-success fw-semibold small text-decoration-none">Xem tất cả <i class="bi bi-chevron-right"></i></a>
        </div>
        <div class="row g-3 g-md-4 row-cols-1 row-cols-md-2 row-cols-lg-3">
            <c:forEach var="sp" items="${newArrivals}">
                <div class="col">
                    <div class="product-card p-3 shadow-sm position-relative">
                        <span class="position-absolute top-0 end-0 badge bg-warning text-dark fw-bold m-2 px-2.5 py-1.5 shadow-sm" style="border-radius: 8px; font-size: 10px; z-index: 10;">NEW ✨</span>
                        <img src="${not empty sp.hinhAnh ? sp.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded mb-3 product-card-img" style="height: 180px; object-fit: cover;" alt="Product">
                        <h6 class="fw-bold text-dark mb-1 text-truncate product-card-title"><c:out value="${sp.tenSp}"/></h6>
                        <p class="text-muted small text-truncate mb-3 d-none d-md-block product-card-desc"><c:out value="${sp.moTa}"/></p>

                        <div class="d-flex flex-column gap-2 mt-auto border-top pt-2.5 product-card-footer">
                            <div class="product-card-price-row">
                                <span class="product-card-price-lbl">Giá khởi điểm:</span>
                                <strong class="product-card-price-val">
                                    <c:forEach var="size" items="${sp.sizesList}" end="0">
                                        <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                    </c:forEach>
                                </strong>
                            </div>
                            <a href="${pageContext.request.contextPath}/product/detail?id=${sp.maSp}" class="btn btn-success btn-sm w-100 py-2.5 fw-bold text-center d-flex align-items-center justify-content-center gap-1 btn-customize-mobile" style="font-size: 12px; border-radius: 8px;">
                                <i class="bi bi-eye-fill"></i> TÙY BIẾN PHA CHẾ
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />
</body>
</html>
