<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Menu Đồ Uống Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .filter-badge {
            cursor: pointer;
            border-radius: 20px;
            padding: 8px 18px;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .filter-badge.active {
            background-color: var(--primary-color) !important;
            color: white !important;
        }
        /* CSS cho thẻ Card Sản Phẩm Độc Quyền */
        .product-card {
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: #ffffff;
            border: 1px solid #f1f5f9;
        }
        .product-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 20px rgba(16, 185, 129, 0.08);
            border-color: #10b981;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4">
    <div class="row g-4">
        <!-- BỘ LỌC BÊN TRÁI (SIDEBAR) -->
        <div class="col-12 col-lg-3">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <h5 class="fw-bold mb-3 text-dark">Tìm kiếm đồ uống</h5>
                <form action="${pageContext.request.contextPath}/products" method="GET" class="mb-4">
                    <div class="input-group">
                        <input type="text" name="search" class="form-control" placeholder="Tìm tên món..." value="<c:out value="${searchKeyword}"/>">
                        <button type="submit" class="btn btn-success"><i class="bi bi-search"></i></button>
                    </div>
                </form>

                <h5 class="fw-bold mb-3 text-dark">Danh Mục Đồ Uống</h5>
                <div class="list-group list-group-flush">
                    <a href="${pageContext.request.contextPath}/products" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center fw-medium border-0 py-2.5 px-0 text-dark">
                        <span>Tất cả menu</span>
                        <span class="badge bg-secondary rounded-pill bg-opacity-25 text-dark">${products.size()}</span>
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="${pageContext.request.contextPath}/products?category=${cat.maDm}" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center border-0 py-2.5 px-0 ${selectedCategory eq cat.maDm.toString() ? 'text-success fw-bold' : 'text-dark'}">
                            <span><c:out value="${cat.tenDm}"/></span>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- DANH SÁCH MENU SẢN PHẨM BÊN PHẢI -->
        <div class="col-12 col-lg-9">
            <div class="card border-0 p-3 mb-4 shadow-sm d-flex flex-row justify-content-between align-items-center" style="border-radius: 12px;">
                <span class="text-muted fw-medium">Tìm thấy <strong class="text-success">${products.size()}</strong> cốc nước thơm ngon</span>
                <div class="btn-group">
                    <button class="btn btn-sm btn-light border dropdown-toggle" type="button" data-bs-toggle="dropdown">Sắp xếp theo</button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item small" href="#">Giá bán: Thấp đến Cao</a></li>
                        <li><a class="dropdown-item small" href="#">Giá bán: Cao đến Thấp</a></li>
                    </ul>
                </div>
            </div>

            <!-- LƯỚI SẢN PHẨM -->
            <div class="row g-4">
                <c:choose>
                    <c:when test="${not empty products}">
                        <c:forEach var="item" items="${products}">
                            <div class="col-12 col-md-6 col-lg-4">
                                <div class="card product-card h-100 p-3">
                                    <div class="position-relative mb-3">
                                        <c:if test="${item.isNew}">
                                            <span class="position-absolute top-0 start-0 badge bg-warning text-dark fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px;">✨ MỚI</span>
                                        </c:if>
                                        <c:if test="${item.isBestseller}">
                                            <span class="position-absolute top-0 end-0 badge bg-danger text-white fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px;">HOT 🔥</span>
                                        </c:if>
                                        <img src="${not empty item.hinhAnh ? item.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded" style="height: 190px; object-fit: cover;">
                                    </div>
                                    <h6 class="fw-bold text-dark mb-1 text-truncate"><c:out value="${item.tenSp}"/></h6>
                                    <p class="text-muted small text-truncate mb-3" style="max-height: 38px;"><c:out value="${item.moTa}"/></p>

                                    <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-2.5">
                                        <strong class="text-success fs-5">
                                            <c:forEach var="size" items="${item.sizesList}" end="0">
                                                <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                            </c:forEach>
                                        </strong>

                                        <!-- PHẦN CẢI TIẾN: Thiết lập bộ đôi nút bấm đặc biệt -->
                                        <div class="d-flex gap-1.5">
                                            <a href="${pageContext.request.contextPath}/product/detail?id=${item.maSp}" class="btn btn-outline-success btn-sm px-2.5 fw-bold rounded-pill" style="font-size: 11px;">
                                                Chi tiết
                                            </a>
                                            <button type="button" class="btn btn-success btn-sm px-3 fw-bold rounded-pill d-flex align-items-center gap-1" style="font-size: 11px;"
                                                    onclick="quickAddToCart('${item.maSp}', '<c:out value="${item.tenSp}"/>')">
                                                <i class="bi bi-cart-plus"></i> Mua ngay
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 text-center py-5">
                            <i class="bi bi-search fs-1 text-muted d-block mb-3"></i>
                            <h5 class="fw-bold text-muted">Không tìm thấy sản phẩm nào khớp với từ khóa của bạn!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>