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
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .filter-wrapper { background-color: #ffffff; border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; box-shadow: var(--shadow-sm); }
        .product-img-circle { width: 44px; height: 44px; object-fit: cover; border-radius: 50%; border: 2px solid var(--primary); box-shadow: var(--shadow-sm); }
        .pagination-container { display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; background-color: #ffffff; border-top: 1px solid var(--border-color); }
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
                    <a href="${pageContext.request.contextPath}/admin/sanpham?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2">
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
                <!-- BẢNG DANH SÁCH SẢN PHẨM -->
                <div class="table-responsive admin-table-container">
                    <table class="table table-hover align-middle admin-table" id="productTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 60px;">STT</th>
                            <th style="width: 120px;">Mã Đồ Uống</th>
                            <th style="width: 80px;">Hình Ảnh</th>
                            <th class="text-start">Tên Sản Phẩm</th>
                            <th class="text-start" style="width: 150px;">Danh Mục</th>
                            <th style="width: 150px;">Kích Cỡ Có Sẵn</th>
                            <th class="text-end" style="width: 110px;">Giá S</th>
                            <th class="text-end" style="width: 110px;">Giá L</th>
                            <th style="width: 140px;">Trạng Thái</th>
                            <th style="width: 250px;">Thao Tác</th>
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
                                                    <img src="${item.hinhAnh}" class="product-img-circle shadow-sm" alt="Pic">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded-circle border mx-auto" style="width: 44px; height: 44px;">
                                                        <i class="bi bi-cup-straw fs-5"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-start">
                                            <div class="fw-bold text-dark"><c:out value="${item.tenSp}"/></div>
                                            <small class="text-muted d-block text-truncate" style="max-width: 240px;"><c:out value="${item.moTa}"/></small>
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
                                                    <span class="badge bg-light text-success border border-success fw-bold px-2.5 py-1.5" style="font-size: 11px;">${activeSizes}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-danger border border-danger small">TẠM DỪNG BÁN</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end fw-bold text-dark">
                                            <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                        </td>
                                        <td class="text-end fw-bold text-success">
                                            <fmt:formatNumber value="${maxPrice}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                        </td>
                                        <td>
                                            <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                    ${item.trangThai ? 'Đang mở bán' : 'Tạm dừng bán'}
                                            </span>
                                        </td>
                                        <td>
                                            <!-- BỘ BA NÚT THAO TÁC ĐỒNG BỘ: SỬA, TRẠNG THÁI (BẬT/TẮT), XÓA -->
                                            <div class="d-flex justify-content-center gap-1.5 align-items-center">
                                                <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-action-edit" title="Cập nhật thông tin">
                                                    <i class="bi bi-pencil-square"></i> Sửa
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/sanpham?action=toggle&id=${item.maSp}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-action-warning' : 'btn-action-edit'}" title="Thay đổi trạng thái bán">
                                                    <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i> ${item.trangThai ? 'Tạm ẩn' : 'Bật bán'}
                                                </a>
                                                <button class="btn btn-sm btn-action-delete" onclick="confirmDeleteSanPham('${item.maSp}')" title="Xóa món ăn">
                                                    <i class="bi bi-trash3-fill"></i> Xóa
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
                <!-- Pagination block -->
                <div class="pagination-container" id="paginationWrapper">
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
    let filteredRows = [];

    function filterAndPaginateProducts() {
        const searchVal = document.getElementById("productSearchInput").value.trim().toLowerCase();
        const catVal = document.getElementById("filterCategory").value;
        const statusVal = document.getElementById("filterStatus").value;
        const newVal = document.getElementById("filterNew").value;
        const hotVal = document.getElementById("filterHot").value;
        const allRows = Array.from(document.querySelectorAll("#productTableBody .product-row"));
        filteredRows = allRows.filter(row => {
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
        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        const allRows = document.querySelectorAll("#productTableBody .product-row");
        allRows.forEach(row => row.style.display = "none");
        const startIdx = (currentPage - 1) * ROWS_PER_PAGE;
        const endIdx = startIdx + ROWS_PER_PAGE;
        const pageRows = filteredRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });
        updatePaginationControls();
    }

    function updatePaginationControls() {
        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE) || 1;
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const start = totalRows > 0 ? (currentPage - 1) * ROWS_PER_PAGE + 1 : 0;
        const end = Math.min(currentPage * ROWS_PER_PAGE, totalRows);
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng dữ liệu';
        btnContainer.innerHTML = "";
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="#" onclick="changePage(' + (currentPage - 1) + ')"><i class="bi bi-chevron-left"></i></a>';
        btnContainer.appendChild(prevLi);
        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? 'bg-success border-success text-white' : 'text-success') + '" href="#" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="#" onclick="changePage(' + (currentPage + 1) + ')"><i class="bi bi-chevron-right"></i></a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredRows.length / ROWS_PER_PAGE) || 1;
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