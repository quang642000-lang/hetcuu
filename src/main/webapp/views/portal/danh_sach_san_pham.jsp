<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Menu Đồ Uống Trực Tuyến</title>
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
    <div class="row g-4">
        <!-- BỘ LỌC BÊN TRÁI (SIDEBAR / OFFCANVAS ON MOBILE) -->
        <div class="col-12 col-lg-3 text-start" id="portalFilterSidebar">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px; background-color: #ffffff; border: 1.5px solid var(--border-color) !important;">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark small text-uppercase mb-0" style="letter-spacing: 0.5px;"><i class="bi bi-search text-success"></i> Tìm kiếm đồ uống</h5>
                    <button type="button" class="btn-close d-lg-none" onclick="togglePortalFilter()"></button>
                </div>
                <form action="${pageContext.request.contextPath}/products" method="GET" class="mb-4">
                    <div class="input-group input-group-sm">
                        <input type="text" name="search" class="form-control form-control-teapos" placeholder="Tìm tên món nước..." value="<c:out value="${searchKeyword}"/>">
                        <button type="submit" class="btn btn-success fw-bold px-3" style="background-color: var(--primary); border: none;"><i class="bi bi-search"></i></button>
                    </div>
                </form>

                <!-- LỌC DANH MỤC SẢN PHẨM -->
                <h5 class="fw-bold mb-3 text-dark small text-uppercase" style="letter-spacing: 0.5px;"><i class="bi bi-grid-fill text-success"></i> Danh mục sản phẩm</h5>
                <div class="list-group list-group-flush gap-1">
                    <a href="${pageContext.request.contextPath}/products" class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold ${empty selectedCategory ? 'active-category text-white' : 'text-dark bg-transparent'}" style="font-size: 13.5px;">
                        Tất cả sản phẩm
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="${pageContext.request.contextPath}/products?category=${cat.maDm}" class="list-group-item list-group-item-action border-0 rounded-2 py-2.5 px-3 fw-semibold ${selectedCategory eq cat.maDm ? 'active-category text-white' : 'text-dark bg-transparent'}" style="font-size: 13.5px;">
                            <c:out value="${cat.tenDm}"/>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- LƯỚI SẢN PHẨM & LỌC SẮP XẾP BÊN PHẢI -->
        <div class="col-12 col-lg-9">
            <!-- TIÊU ĐỀ MENU VÀ LỌC GIÁ -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div class="text-start">
                    <h4 class="fw-bold mb-1 text-dark" style="letter-spacing: -0.5px;">THỰC ĐƠN TRÀ SỮA</h4>
                    <small class="text-muted">Tìm thấy <strong class="text-success">${totalProducts}</strong> món nước uống tuyệt hảo</small>
                </div>

                <!-- Bộ lọc sắp xếp thông minh -->
                <div class="btn-group border bg-white shadow-sm" style="border-radius: 20px; padding: 2px;">
                    <button class="btn btn-sm btn-light border-0 dropdown-toggle fw-bold text-dark px-3 py-1.5" type="button" data-bs-toggle="dropdown" style="font-size: 12.5px; border-radius: 18px;">
                        <c:choose>
                            <c:when test="${currentSort eq 'price_asc'}"><i class="bi bi-sort-numeric-down text-success"></i> Giá: Thấp đến Cao</c:when>
                            <c:when test="${currentSort eq 'price_desc'}"><i class="bi bi-sort-numeric-up-alt text-success"></i> Giá: Cao đến Thấp</c:when>
                            <c:otherwise><i class="bi bi-funnel-fill text-muted"></i> Sắp xếp theo giá</c:otherwise>
                        </c:choose>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 py-2 mt-1" style="border-radius: 8px;">
                        <li>
                            <a class="dropdown-item small fw-semibold py-2" href="${pageContext.request.contextPath}/products?sort=price_asc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}">
                                <i class="bi bi-sort-numeric-down text-success me-1"></i> Giá bán: Thấp đến Cao
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item small fw-semibold py-2" href="${pageContext.request.contextPath}/products?sort=price_desc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}">
                                <i class="bi bi-sort-numeric-up-alt text-success me-1"></i> Giá bán: Cao đến Thấp
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- LƯỚI SẢN PHẨM - TỐI ƯU SONG HÀNH 2 CỘT TRÊN DI ĐỘNG (row-cols-2) -->
            <div class="row row-cols-2 row-cols-md-2 row-cols-lg-3 g-3 g-md-4">
                <c:choose>
                    <c:when test="${not empty products}">
                        <c:forEach var="item" items="${products}">
                            <div class="col">
                                <div class="product-card p-2.5 p-md-3 shadow-sm position-relative">
                                    <!-- NHÃN HOT / NEW -->
                                    <c:if test="${item.isNew}">
                                        <span class="position-absolute top-0 start-0 badge bg-warning text-dark fw-bold m-2 px-2 py-1" style="border-radius: 6px; font-size: 9px; z-index: 5;">NEW ✨</span>
                                    </c:if>
                                    <c:if test="${item.isBestseller}">
                                        <span class="position-absolute top-0 end-0 badge bg-danger text-white fw-bold m-2 px-2 py-1" style="border-radius: 6px; font-size: 9px; z-index: 5;">HOT 🔥</span>
                                    </c:if>

                                    <!-- Ảnh minh họa -->
                                    <img src="${not empty item.hinhAnh ? item.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="product-card-img rounded mb-2.5" alt="Pic">

                                    <!-- Thông tin cốc nước -->
                                    <div class="product-card-body p-0">
                                        <h6 class="product-card-title text-start"><c:out value="${item.tenSp}"/></h6>
                                        <p class="text-muted small text-truncate mb-2.5 text-start d-none d-md-block product-card-desc"><c:out value="${item.moTa}"/></p>
                                    </div>

                                    <!-- Dải chốt giá bán và hành động đặt hàng -->
                                    <div class="d-flex flex-column gap-2 mt-auto border-top pt-2 product-card-footer">
                                        <div class="product-card-price-row">
                                            <span class="product-card-price-lbl">Giá từ:</span>
                                            <strong class="text-success product-card-price-val">
                                                <c:forEach var="size" items="${item.sizesList}" end="0">
                                                    <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                </c:forEach>
                                            </strong>
                                        </div>
                                        <!-- Nút tùy biến cấu hình pha chế -->
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${item.maSp}" class="btn btn-success btn-sm w-100 py-2 fw-bold text-center d-flex align-items-center justify-content-center gap-1 btn-customize-mobile" style="font-size: 11.5px; border-radius: 8px;">
                                            <i class="bi bi-eye-fill"></i> TÙY BIẾN
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 text-center py-5">
                            <i class="bi bi-search fs-1 text-muted d-block mb-3 opacity-40"></i>
                            <h5 class="fw-bold text-muted">Không tìm thấy sản phẩm nào!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- PHÂN TRANG -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-5">
                    <ul class="pagination pagination-sm justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link py-2 px-3 fw-semibold text-success" href="${pageContext.request.contextPath}/products?page=${currentPage - 1}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}" aria-label="Previous">
                                &laquo; Trước
                            </a>
                        </li>
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link py-2 px-3 fw-bold" href="${pageContext.request.contextPath}/products?page=${i}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link py-2 px-3 fw-semibold text-success" href="${pageContext.request.contextPath}/products?page=${currentPage + 1}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}" aria-label="Next">
                                Sau &raquo;
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />
</body>
</html>
