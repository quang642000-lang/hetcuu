<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Sản Phẩm Đồ Uống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <style>
        .price-range {
            font-size: 14px !important;
            font-weight: 700 !important;
            color: var(--primary) !important;
        }
    </style>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px; background-color: #ffffff;">
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                    <div class="text-start">
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-cup-straw me-2"></i>Quản Lý Sản Phẩm</h3>
                        <p class="text-muted small mb-0">Quản lý vòng đời đồ uống, các tùy biến pha chế và cấu hình biến thể kích cỡ bán</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/sanpham?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold">
                        <i class="bi bi-plus-circle-fill"></i> THÊM SẢN PHẨM MỚI
                    </a>
                </div>

                <!-- BỘ LỌC TÌM KIẾM SẢN PHẨM -->
                <div class="filter-wrapper mb-4">
                    <div class="row g-3 text-start">
                        <div class="col-12 col-md-3">
                            <label class="form-label fw-bold text-muted small"><i class="bi bi-search"></i> Tra cứu nhanh</label>
                            <input type="text" id="productSearchInput" class="form-control form-control-teapos" placeholder="Tìm tên hoặc mã sản phẩm..." onkeyup="filterAndPaginateProducts()">
                        </div>
                        <div class="col-6 col-md-2">
                            <label class="form-label fw-bold text-muted small"><i class="bi bi-tag-fill"></i> Nhóm danh mục</label>
                            <select id="filterCategory" class="form-select form-control-teapos" onchange="filterAndPaginateProducts()">
                                <option value="">-- Tất cả nhóm --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.maDm}"><c:out value="${cat.tenDm}"/></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-6 col-md-2">
                            <label class="form-label fw-bold text-muted small"><i class="bi bi-toggle-on"></i> Trạng thái</label>
                            <select id="filterStatus" class="form-select form-control-teapos" onchange="filterAndPaginateProducts()">
                                <option value="">-- Tất cả --</option>
                                <option value="1">Đang mở bán</option>
                                <option value="0">Tạm dừng bán</option>
                            </select>
                        </div>
                        <div class="col-6 col-md-2">
                            <label class="form-label fw-bold text-muted small"><i class="bi bi-star"></i> Nhãn mới</label>
                            <select id="filterNew" class="form-select form-control-teapos" onchange="filterAndPaginateProducts()">
                                <option value="">-- Tất cả --</option>
                                <option value="true">Sản phẩm mới ✨</option>
                                <option value="false">Sản phẩm thường</option>
                            </select>
                        </div>
                        <div class="col-6 col-md-2">
                            <label class="form-label fw-bold text-muted small"><i class="bi bi-fire text-danger"></i> Sức hút</label>
                            <select id="filterHot" class="form-select form-control-teapos" onchange="filterAndPaginateProducts()">
                                <option value="">-- Tất cả --</option>
                                <option value="true">Bán chạy nhất 🔥</option>
                                <option value="false">Bình thường</option>
                            </select>
                        </div>
                        <div class="col-12 col-md-1 d-flex align-items-end">
                            <button class="btn btn-secondary-teapos w-100 py-2" onclick="resetFilters()"><i class="bi bi-arrow-counterclockwise"></i> Reset</button>
                        </div>
                    </div>
                </div>

                <!-- ==================== VIEW 1: DESKTOP LAYOUT (Màn hình lớn) ==================== -->
                <div class="d-none d-lg-block table-responsive admin-table-container">
                    <table class="table table-hover align-middle admin-table" id="productTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 60px;">STT</th>
                            <th style="width: 120px;">Mã Đồ Uống</th>
                            <th style="width: 100px;">Hình Ảnh</th>
                            <th class="text-start">Tên Sản Phẩm</th>
                            <th class="text-start" style="width: 150px;">Danh Mục</th>
                            <th style="width: 150px;">Kích Cỡ Có Sẵn</th>
                            <th style="width: 90px;">Thứ tự</th>
                            <th class="text-end" style="width: 180px;">Giá Bán</th>
                            <th style="width: 140px;">Trạng Thái</th>
                            <th style="width: 250px;" class="text-end">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody id="productTableBody">
                        <c:choose>
                            <c:when test="${not empty products}">
                                <c:forEach var="item" items="${products}" varStatus="loop">
                                    <c:set var="minPrice" value="99999999"/>
                                    <c:set var="maxPrice" value="0"/>
                                    <c:set var="activeSizes" value=""/>
                                    <c:forEach var="szPrice" items="${item.sizesList}">
                                        <c:if test="${szPrice.trangThai}">
                                            <c:set var="activeSizes" value="${empty activeSizes ? szPrice.tenSize : activeSizes.concat(', ').concat(szPrice.tenSize)}"/>
                                            <c:if test="${szPrice.giaBan < minPrice}">
                                                <c:set var="minPrice" value="${szPrice.giaBan}"/>
                                            </c:if>
                                            <c:if test="${szPrice.giaBan > maxPrice}">
                                                <c:set var="maxPrice" value="${szPrice.giaBan}"/>
                                            </c:if>
                                        </c:if>
                                    </c:forEach>
                                    <c:if test="${minPrice == 99999999}">
                                        <c:set var="minPrice" value="0"/>
                                    </c:if>

                                    <tr class="product-row text-center"
                                        data-masp="${item.maSp}"
                                        data-tensp="<c:out value="${item.tenSp}"/>"
                                        data-madm="${item.maDm}"
                                        data-isnew="${item.isNew}"
                                        data-ishot="${item.isBestseller}"
                                        data-trangthai="${item.trangThai ? 1 : 0}">
                                        <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                        <td><code class="fw-bold text-dark">${item.maSp}</code></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="product-img-circle shadow-sm" style="width: 44px !important; height: 44px !important; min-width: 44px !important; min-height: 44px !important; object-fit: cover !important; border-radius: 50% !important; border: 2px solid #10b981 !important;" alt="Pic">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 44px; height: 44px;">
                                                        <i class="bi bi-image fs-5"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-start">
                                            <strong class="text-dark"><c:out value="${item.tenSp}"/></strong>
                                            <c:if test="${item.isNew}"><span class="badge bg-warning text-dark ms-1" style="font-size: 9px;">NEW ✨</span></c:if>
                                            <c:if test="${item.isBestseller}"><span class="badge bg-danger text-white ms-1" style="font-size: 9px;">HOT 🔥</span></c:if>
                                        </td>
                                        <td class="text-start text-dark fw-medium">
                                            <c:forEach var="cat" items="${categories}">
                                                <c:if test="${cat.maDm == item.maDm}">
                                                    <c:out value="${cat.tenDm}"/>
                                                </c:if>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty activeSizes}">
                                                    <span class="badge bg-light text-success border border-success fw-bold px-2.5 py-1.5" style="font-size: 11px;">Size ${activeSizes}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-danger border border-danger small px-2.5 py-1.5">TẠM DỪNG BÁN</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-secondary px-2.5 py-1.5 text-white" style="border-radius: 6px;">${item.thuTuHienThi}</span>
                                        </td>
                                        <td class="text-end fw-bold price-range font-monospace">
                                            <c:choose>
                                                <c:when test="${minPrice == maxPrice}">
                                                    <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ - <fmt:formatNumber value="${maxPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                                <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                        ${item.trangThai ? 'Đang mở bán' : 'Tạm dừng bán'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2 align-items-center">
                                                <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-action-edit" title="Cập nhật thông tin">
                                                    <i class="bi bi-pencil-square me-1"></i> Sửa
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/sanpham?action=toggle&id=${item.maSp}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-action-warning' : 'btn-action-edit'}" title="Thay đổi trạng thái bán">
                                                    <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i> ${item.trangThai ? 'Tạm ẩn' : 'Bật bán'}
                                                </a>
                                                <button class="btn btn-sm btn-action-delete" onclick="confirmDeleteSanPham('${item.maSp}')" title="Xóa món uống">
                                                    <i class="bi bi-trash3-fill me-1"></i> Xóa
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="10" class="text-center py-5 text-muted">
                                        <i class="bi bi-cup-hot fs-1 text-secondary opacity-50 d-block mb-2"></i>
                                        Chưa ghi nhận sản phẩm đồ uống nào hoạt động trong CSDL!
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- ==================== VIEW 2: MOBILE LAYOUT (Màn hình điện thoại < 992px) ==================== -->
                <div class="d-block d-lg-none" id="productMobileCards">
                    <c:choose>
                        <c:when test="${not empty products}">
                            <c:forEach var="item" items="${products}" varStatus="loop">
                                <c:set var="minPrice" value="99999999"/>
                                <c:set var="maxPrice" value="0"/>
                                <c:set var="activeSizes" value=""/>
                                <c:forEach var="szPrice" items="${item.sizesList}">
                                    <c:if test="${szPrice.trangThai}">
                                        <c:set var="activeSizes" value="${empty activeSizes ? szPrice.tenSize : activeSizes.concat(', ').concat(szPrice.tenSize)}"/>
                                        <c:if test="${szPrice.giaBan < minPrice}">
                                            <c:set var="minPrice" value="${szPrice.giaBan}"/>
                                        </c:if>
                                        <c:if test="${szPrice.giaBan > maxPrice}">
                                            <c:set var="maxPrice" value="${szPrice.giaBan}"/>
                                        </c:if>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${minPrice == 99999999}">
                                    <c:set var="minPrice" value="0"/>
                                </c:if>

                                <div class="product-card-col mb-3"
                                     data-masp="${item.maSp}"
                                     data-tensp="<c:out value="${item.tenSp}"/>"
                                     data-madm="${item.maDm}"
                                     data-isnew="${item.isNew}"
                                     data-ishot="${item.isBestseller}"
                                     data-trangthai="${item.trangThai ? 1 : 0}">
                                    <div class="card p-3 border shadow-sm position-relative text-start" style="border-radius: 12px; background: #ffffff; border-color: var(--border-color) !important;">

                                        <!-- Expand/Collapse Chevron -->
                                        <div class="position-absolute" style="top: 15px; right: 15px; cursor: pointer; z-index: 10;" onclick="toggleMobileCardDetails(this)">
                                            <span class="badge bg-light rounded-circle text-success d-flex align-items-center justify-content-center border" style="width: 28px; height: 28px; border-color: var(--border-color) !important;">
                                                <i class="bi bi-chevron-down fs-6"></i>
                                            </span>
                                        </div>

                                        <!-- Header: STT, Mã Đồ Uống, Trạng Thái -->
                                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 pe-4">
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="badge bg-light text-success rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-weight: bold; border: 1px solid var(--border-color);">
                                                        ${loop.index + 1}
                                                </span>
                                                <code class="fw-bold text-dark font-monospace">${item.maSp}</code>
                                            </div>
                                            <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-2.5 py-1" style="border-radius: 50px; font-size: 11px;">
                                                    ${item.trangThai ? 'Mở bán' : 'Tạm dừng'}
                                            </span>
                                        </div>

                                        <!-- Body: Ảnh, Tên, nhãn HOT/NEW -->
                                        <div class="d-flex align-items-center gap-3">
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border" style="width: 50px; height: 50px; object-fit: cover; border: 2px solid #10b981 !important;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border" style="width: 50px; height: 50px;">
                                                        <i class="bi bi-image fs-4"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <h6 class="fw-bold text-dark mb-1">
                                                    <c:out value="${item.tenSp}"/>
                                                    <c:if test="${item.isNew}"><span class="badge bg-warning text-dark" style="font-size: 8px; padding: 2px 4px;">NEW</span></c:if>
                                                    <c:if test="${item.isBestseller}"><span class="badge bg-danger text-white" style="font-size: 8px; padding: 2px 4px;">HOT</span></c:if>
                                                </h6>
                                                <div class="text-success fw-bold font-monospace" style="font-size: 13.5px;">
                                                    <c:choose>
                                                        <c:when test="${minPrice == maxPrice}">
                                                            <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ - <fmt:formatNumber value="${maxPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Expandable panel (hidden by default) -->
                                        <div class="mobile-card-details border-top pt-2 mt-2 text-start small d-none" style="line-height: 1.6;">
                                            <div class="text-muted d-flex justify-content-between">
                                                <span>Danh mục nhóm:</span>
                                                <strong class="text-dark">
                                                    <c:forEach var="cat" items="${categories}">
                                                        <c:if test="${cat.maDm == item.maDm}">
                                                            <c:out value="${cat.tenDm}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                </strong>
                                            </div>
                                            <div class="text-muted d-flex justify-content-between mt-1">
                                                <span>Ưu tiên hiển thị:</span>
                                                <strong class="text-dark">${item.thuTuHienThi}</strong>
                                            </div>
                                            <div class="text-muted d-flex justify-content-between mt-1">
                                                <span>Kích cỡ:</span>
                                                <strong class="text-success">Size ${not empty activeSizes ? activeSizes : 'Tạm hết'}</strong>
                                            </div>
                                        </div>

                                        <!-- Footer Actions -->
                                        <div class="d-flex gap-2 border-top pt-2 mt-2">
                                            <a href="${pageContext.request.contextPath}/admin/sanpham?action=toggle&id=${item.maSp}&status=${item.trangThai ? 0 : 1}"
                                               class="btn btn-sm ${item.trangThai ? 'btn-outline-warning' : 'btn-outline-success'} fw-bold flex-grow-1" style="border-radius: 8px;">
                                                <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i> ${item.trangThai ? 'Tạm ẩn' : 'Bật bán'}
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-outline-primary btn-sm fw-bold flex-grow-1" style="border-radius: 8px;">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </a>
                                            <button class="btn btn-outline-danger btn-sm fw-bold flex-grow-1" style="border-radius: 8px;" onclick="confirmDeleteSanPham('${item.maSp}')">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5 text-muted bg-white rounded-3 border">Không tìm thấy sản phẩm nào!</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- PHÂN TRANG -->
                <div class="pagination-container" id="paginationWrapper" style="display: none;">
                    <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 dòng dữ liệu</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const ROWS_PER_PAGE = 10;
    let currentPage = 1;
    let filteredDesktopRows = [];
    let filteredMobileCards = [];

    function filterAndPaginateProducts() {
        const searchVal = document.getElementById("productSearchInput").value.trim().toLowerCase();
        const catVal = document.getElementById("filterCategory").value;
        const statusVal = document.getElementById("filterStatus").value;
        const newVal = document.getElementById("filterNew").value;
        const hotVal = document.getElementById("filterHot").value;

        // Filter Desktop view rows
        const allDesktopRows = Array.from(document.querySelectorAll("#productTableBody .product-row"));
        filteredDesktopRows = allDesktopRows.filter(row => {
            const maSp = row.dataset.masp.toLowerCase();
            const tenSp = row.dataset.tensp.toLowerCase();
            const maDm = row.dataset.madm;
            const isNew = row.dataset.isnew;
            const isHot = row.dataset.ishot;
            const status = row.dataset.trangthai;

            let matchSearch = maSp.includes(searchVal) || tenSp.includes(searchVal);
            let matchCat = catVal === "" || maDm === catVal;
            let matchStatus = statusVal === "" || status === statusVal;
            let matchNew = newVal === "" || isNew === newVal;
            let matchHot = hotVal === "" || isHot === hotVal;

            return matchSearch && matchCat && matchStatus && matchNew && matchHot;
        });

        // Filter Mobile cards view
        const allMobileCards = Array.from(document.querySelectorAll("#productMobileCards .product-card-col"));
        filteredMobileCards = allMobileCards.filter(card => {
            const maSp = card.dataset.masp.toLowerCase();
            const tenSp = card.dataset.tensp.toLowerCase();
            const maDm = card.dataset.madm;
            const isNew = card.dataset.isnew;
            const isHot = card.dataset.ishot;
            const status = card.dataset.trangthai;

            let matchSearch = maSp.includes(searchVal) || tenSp.includes(searchVal);
            let matchCat = catVal === "" || maDm === catVal;
            let matchStatus = statusVal === "" || status === statusVal;
            let matchNew = newVal === "" || isNew === newVal;
            let matchHot = hotVal === "" || isHot === hotVal;

            return matchSearch && matchCat && matchStatus && matchNew && matchHot;
        });

        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        // Desktop table render
        const allDesktopRows = document.querySelectorAll("#productTableBody .product-row");
        allDesktopRows.forEach(row => row.style.display = "none");
        const totalRows = filteredDesktopRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        const startIdx = (currentPage - 1) * ROWS_PER_PAGE;
        const endIdx = Math.min(startIdx + ROWS_PER_PAGE, totalRows);

        const pageRows = filteredDesktopRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });

        // Mobile card list render
        const allMobileCards = document.querySelectorAll("#productMobileCards .product-card-col");
        allMobileCards.forEach(card => card.style.setProperty('display', 'none', 'important'));
        const pageMobileCards = filteredMobileCards.slice(startIdx, endIdx);
        pageMobileCards.forEach(card => {
            card.style.setProperty('display', 'block', 'important');
        });

        updatePaginationControls();
    }

    function updatePaginationControls() {
        const totalRows = filteredDesktopRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE) || 1;
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const wrapper = document.getElementById("paginationWrapper");

        if (!infoEl || !btnContainer || !wrapper) return;
        const start = totalRows > 0 ? (currentPage - 1) * ROWS_PER_PAGE + 1 : 0;
        const end = Math.min(currentPage * ROWS_PER_PAGE, totalRows);

        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng sản phẩm';
        btnContainer.innerHTML = "";

        if (totalPages <= 1) {
            wrapper.style.setProperty('display', 'none', 'important');
            return;
        }
        wrapper.style.setProperty('display', 'flex', 'important');

        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
        btnContainer.appendChild(prevLi);

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? 'bg-success border-success text-white' : 'text-success') + '" href="javascript:void(0)" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredDesktopRows.length / ROWS_PER_PAGE) || 1;
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTableRows();
    }

    function resetFilters() {
        document.getElementById("productSearchInput").value = "";
        document.getElementById("filterCategory").selectedIndex = 0;
        document.getElementById("filterStatus").selectedIndex = 0;
        document.getElementById("filterNew").selectedIndex = 0;
        document.getElementById("filterHot").selectedIndex = 0;
        filterAndPaginateProducts();
    }

    function confirmDeleteSanPham(maSp) {
        Swal.fire({
            title: 'Xác nhận xóa món uống?',
            text: "Cơ chế kiểm toán 2 lớp: Nếu sản phẩm đã dính lịch sử hóa đơn bán nước, hệ thống tự động gạt về trạng thái khóa tạm dừng (Soft Delete). Nếu chưa từng bán, sản phẩm sẽ được xóa cứng hoàn toàn khỏi cơ sở dữ liệu!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/sanpham?action=delete&id=' + maSp;
            }
        });
    }

    // EXPAND/COLLAPSE MOBILE CARD DETAILS
    function toggleMobileCardDetails(element) {
        const card = element.closest('.card');
        const details = card.querySelector('.mobile-card-details');
        const icon = element.querySelector('i');
        if (details.classList.contains('d-none')) {
            details.classList.remove('d-none');
            icon.className = 'bi bi-chevron-up fs-6';
        } else {
            details.classList.add('d-none');
            icon.className = 'bi bi-chevron-down fs-6';
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        filterAndPaginateProducts();
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm mới món uống thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu cấu hình sản phẩm!');
        if (msg === 'softdeletesuccess') {
            Swal.fire({
                icon: 'info',
                title: 'Tạm ẩn sản phẩm',
                text: 'Sản phẩm này đã có lịch sử hóa đơn! Hệ thống tự động chuyển trạng thái hoạt động về 0 (Soft Delete) để bảo lưu báo cáo tài chính!',
                confirmButtonColor: '#10b981'
            });
        }
        if (msg === 'harddeletesuccess') showToast('success', 'Đã xóa cứng vĩnh viễn sản phẩm khỏi CSDL!');
        if (msg === 'deletefailed') showToast('error', 'Cập nhật trạng thái sản phẩm thất bại!');
    });
</script>
</body>
</html>