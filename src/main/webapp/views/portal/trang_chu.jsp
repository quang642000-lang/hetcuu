<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Cổng Đặt Nước Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .portal-banner {
            background: linear-gradient(135deg, #10b981 0%, #064e3b 100%);
            border-radius: 20px;
            color: white;
            padding: 60px 40px;
        }
        .category-card {
            transition: all 0.3s ease;
            cursor: pointer;
            border-radius: 16px;
        }
        .category-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.15);
        }
        .product-card {
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: #ffffff;
            border: 1px solid #f1f5f9;
        }
        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.06);
            border-color: #10b981;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4">
    <!-- BANNER CHƯƠNG TRÌNH KHUYẾN MÃI -->
    <div class="portal-banner mb-5 shadow-sm d-flex align-items-center">
        <div class="row w-100 align-items-center">
            <div class="col-12 col-md-7">
                <span class="badge bg-warning text-dark fw-bold px-3 py-2 mb-3">SIÊU ƯU ĐÃI CHÀO BẠN MỚI ✨</span>
                <h1 class="display-5 fw-bold mb-3">Trà Thơm Đậm Vị - Giao Nước Tận Tay</h1>
                <p class="fs-5 opacity-90 mb-4">Giảm ngay 20% cho đơn hàng đặt sớm Click & Collect tại quầy. Hãy đăng ký thành viên CRM để nhận điểm Loyalty!</p>
                <a href="${pageContext.request.contextPath}/products" class="btn btn-light text-success fw-bold px-4 py-2.5 shadow-sm">
                    <i class="bi bi-cup-hot-fill me-1"></i> Khám phá thực đơn
                </a>
            </div>
            <div class="col-5 d-none d-md-block text-center">
                <img src="https://static.vecteezy.com/system/resources/previews/034/770/583/non_2x/bubble-tea-ai-generative-free-png.png" class="img-fluid" style="max-height: 280px;" alt="Banner Tea">
            </div>
        </div>
    </div>

    <!-- KHU VỰC DANH MỤC SẢN PHẨM -->
    <div class="mb-5">
        <h4 class="fw-bold mb-3 d-flex align-items-center gap-2">
            <i class="bi bi-grid-fill text-success"></i> KHÁM PHÁ DANH MỤC ĐỒ UỐNG
        </h4>
        <div class="row g-3">
            <c:forEach var="cat" items="${categories}">
                <div class="col-6 col-md-3">
                    <div class="card category-card text-center border-0 p-3 bg-white" onclick="window.location.href='${pageContext.request.contextPath}/products?category=${cat.maDm}'">
                        <c:choose>
                            <c:when test="${not empty cat.hinhAnh}">
                                <img src="${cat.hinhAnh}" class="mx-auto rounded-circle mb-3 border" style="width: 70px; height: 70px; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                                <div class="mx-auto bg-success-subtle text-success rounded-circle d-flex align-items-center justify-content-center mb-3" style="width: 70px; height: 70px;">
                                    <i class="bi bi-cup-straw fs-2"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <span class="fw-bold text-dark text-uppercase small"><c:out value="${cat.tenDm}"/></span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- SẢN PHẨM BÁN CHẠY (BESTSELLERS) -->
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="fw-bold mb-0 d-flex align-items-center gap-2">
                <i class="bi bi-fire text-danger animate-pulse"></i> ĐỒ UỐNG BÁN CHẠY NHẤT
            </h4>
            <a href="${pageContext.request.contextPath}/products?filter=hot" class="text-success fw-semibold small text-decoration-none">Xem tất cả <i class="bi bi-chevron-right"></i></a>
        </div>
        <div class="row g-4">
            <c:forEach var="sp" items="${bestsellers}" end="3">
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="card product-card h-100 p-3">
                        <div class="position-relative mb-3">
                            <span class="position-absolute top-0 start-0 badge bg-danger text-white fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px;">🔥 HOT</span>
                            <img src="${not empty sp.hinhAnh ? sp.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded" style="height: 200px; object-fit: cover;">
                        </div>
                        <h6 class="fw-bold text-dark mb-1 text-truncate"><c:out value="${sp.tenSp}"/></h6>
                        <p class="text-muted small text-truncate mb-2"><c:out value="${sp.moTa}"/></p>
                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-2">
                            <strong class="text-success fs-5">
                                <c:forEach var="size" items="${sp.sizesList}" end="0">
                                    <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                </c:forEach>
                            </strong>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${sp.maSp}" class="btn btn-outline-success btn-sm px-2 fw-bold rounded-pill" style="font-size: 11px;">
                                    Chi tiết
                                </a>
                                <button type="button" class="btn btn-success btn-sm px-2.5 fw-bold rounded-pill" style="font-size: 11px;"
                                        onclick="quickAddToCart('${sp.maSp}', '<c:out value="${sp.tenSp}"/>')">
                                    <i class="bi bi-cart-plus"></i> Mua ngay
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- MÓN MỚI LÊN KỆ (NEW ARRIVALS) -->
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="fw-bold mb-0 d-flex align-items-center gap-2">
                <i class="bi bi-stars text-warning"></i> SẢN PHẨM MỚI LÊN KỆ
            </h4>
            <a href="${pageContext.request.contextPath}/products?filter=new" class="text-success fw-semibold small text-decoration-none">Xem tất cả <i class="bi bi-chevron-right"></i></a>
        </div>
        <div class="row g-4">
            <c:forEach var="sp" items="${newArrivals}" end="3">
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="card product-card h-100 p-3">
                        <div class="position-relative mb-3">
                            <span class="position-absolute top-0 start-0 badge bg-warning text-dark fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px;">✨ MỚI</span>
                            <img src="${not empty sp.hinhAnh ? sp.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded" style="height: 200px; object-fit: cover;">
                        </div>
                        <h6 class="fw-bold text-dark mb-1 text-truncate"><c:out value="${sp.tenSp}"/></h6>
                        <p class="text-muted small text-truncate mb-2"><c:out value="${sp.moTa}"/></p>
                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-2">
                            <strong class="text-success fs-5">
                                <c:forEach var="size" items="${sp.sizesList}" end="0">
                                    <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                </c:forEach>
                            </strong>
                            <div class="d-flex gap-1">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${sp.maSp}" class="btn btn-outline-success btn-sm px-2 fw-bold rounded-pill" style="font-size: 11px;">
                                    Chi tiết
                                </a>
                                <button type="button" class="btn btn-success btn-sm px-2.5 fw-bold rounded-pill" style="font-size: 11px;"
                                        onclick="quickAddToCart('${sp.maSp}', '<c:out value="${sp.tenSp}"/>')">
                                    <i class="bi bi-cart-plus"></i> Mua ngay
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
