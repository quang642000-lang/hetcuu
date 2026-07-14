<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Menu Đồ Uống Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        .product-card {
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s ease;
            background: #ffffff;
            border: 1px solid #f1f5f9;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .product-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 20px rgba(16, 185, 129, 0.08);
            border-color: #10b981;
        }
        .list-group-item.active-category {
            background-color: #10b981 !important;
            border-color: #10b981 !important;
            color: #ffffff !important;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4">
    <div class="row g-4">
        <!-- BỘ LỌC BÊN TRÁI (SIDEBAR) -->
        <div class="col-12 col-lg-3 text-start">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <h5 class="fw-bold mb-3 text-dark">Tìm kiếm đồ uống</h5>
                <form action="${pageContext.request.contextPath}/products" method="GET" class="mb-4">
                    <div class="input-group">
                        <input type="text" name="search" class="form-control" placeholder="Tìm tên món nước..." value="<c:out value="${searchKeyword}"/>">
                        <button type="submit" class="btn btn-success"><i class="bi bi-search"></i></button>
                    </div>
                </form>

                <h5 class="fw-bold mb-3 text-dark">Danh mục sản phẩm</h5>
                <div class="list-group list-group-flush gap-1">
                    <a href="${pageContext.request.contextPath}/products" class="list-group-item list-group-item-action border-0 rounded-2 py-2 px-3 fw-semibold ${empty selectedCategory ? 'active-category text-white' : 'text-dark bg-transparent'}">
                        Tất cả sản phẩm
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="${pageContext.request.contextPath}/products?category=${cat.maDm}" class="list-group-item list-group-item-action border-0 rounded-2 py-2 px-3 fw-semibold ${selectedCategory eq cat.maDm ? 'active-category text-white' : 'text-dark bg-transparent'}">
                            <c:out value="${cat.tenDm}"/>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- LƯỚI SẢN PHẨM & LỌC PHẢI -->
        <div class="col-12 col-lg-9">
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <div class="text-start">
                    <h4 class="fw-bold mb-1 text-dark">THỰC ĐƠN TRÀ SỮA</h4>
                    <small class="text-muted">Tìm thấy <strong class="text-success">${totalProducts}</strong> sản phẩm uống tươi ngon</small>
                </div>

                <!-- BỘ SẮP XẾP THEO GIÁ HOẠT ĐỘNG HOÀN HẢO -->
                <div class="btn-group border bg-white shadow-sm" style="border-radius: 8px;">
                    <button class="btn btn-sm btn-light border-0 dropdown-toggle fw-semibold text-dark px-3 py-2" type="button" data-bs-toggle="dropdown">
                        <c:choose>
                            <c:when test="${currentSort eq 'price_asc'}">Giá bán: Thấp đến Cao</c:when>
                            <c:when test="${currentSort eq 'price_desc'}">Giá bán: Cao đến Thấp</c:when>
                            <c:otherwise>Sắp xếp theo giá</c:otherwise>
                        </c:choose>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0 py-2">
                        <li>
                            <a class="dropdown-item small fw-semibold" href="${pageContext.request.contextPath}/products?sort=price_asc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}">
                                Giá bán: Thấp đến Cao
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item small fw-semibold" href="${pageContext.request.contextPath}/products?sort=price_desc${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}">
                                Giá bán: Cao đến Thấp
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- LƯỚI SẢN PHẨM MẠNG -->
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                <c:choose>
                    <c:when test="${not empty products}">
                        <c:forEach var="item" items="${products}">
                            <div class="col">
                                <div class="product-card p-3 shadow-sm position-relative">
                                    <c:if test="${item.isNew}">
                                        <span class="position-absolute top-0 start-0 badge bg-success text-white fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px; z-index: 10;">NEW ✨</span>
                                    </c:if>
                                    <c:if test="${item.isBestseller}">
                                        <span class="position-absolute top-0 end-0 badge bg-danger text-white fw-bold m-2 px-2.5 py-1.5" style="border-radius: 8px; font-size: 10px; z-index: 10;">HOT 🔥</span>
                                    </c:if>
                                    <img src="${not empty item.hinhAnh ? item.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded mb-3" style="height: 190px; object-fit: cover;" alt="Pic">
                                    <h6 class="fw-bold text-dark mb-1 text-truncate text-start"><c:out value="${item.tenSp}"/></h6>
                                    <p class="text-muted small text-truncate mb-3 text-start"><c:out value="${item.moTa}"/></p>
                                    <div class="d-flex flex-column gap-2 mt-auto border-top pt-2.5">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="text-muted small">Giá từ:</span>
                                            <strong class="text-success fs-5">
                                                <c:forEach var="size" items="${item.sizesList}" end="0">
                                                    <fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                </c:forEach>
                                            </strong>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${item.maSp}" class="btn btn-success btn-sm w-100 py-2.5 fw-bold text-center d-flex align-items-center justify-content-center gap-1" style="font-size: 12px; border-radius: 8px;">
                                            <i class="bi bi-eye-fill"></i> TÙY BIẾN PHA CHẾ
                                        </a>
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

            <!-- PHÂN TRANG -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-5">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/products?page=${currentPage - 1}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}" aria-label="Previous">
                                <span aria-hidden="true">&laquo; Trang trước</span>
                            </a>
                        </li>
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/products?page=${i}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/products?page=${currentPage + 1}${not empty selectedCategory ? '&category='.concat(selectedCategory) : ''}${not empty searchKeyword ? '&search='.concat(searchKeyword) : ''}${not empty currentSort ? '&sort='.concat(currentSort) : ''}" aria-label="Next">
                                <span aria-hidden="true">Trang sau &raquo;</span>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />
</body>
</html>