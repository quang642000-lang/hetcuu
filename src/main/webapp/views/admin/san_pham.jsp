<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Hành Sản Phẩm Đồ Uống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px; background-color: #ffffff;">

                <!-- TIÊU ĐỀ MODULE -->
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-cup-straw me-2"></i>Quản Lý Sản Phẩm</h3>
                        <p class="text-muted small mb-0">Quản lý vòng đời đồ uống, các tùy biến pha chế và trạng thái mở bán</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/sanpham?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold px-4 py-2.5 shadow-sm" style="border-radius: 8px;">
                        <i class="bi bi-plus-circle-fill"></i> THÊM SẢN PHẨM MỚI
                    </a>
                </div>

                <!-- THANH CÔNG CỤ: TÌM KIẾM VÀ BỘ LỌC CHUẨN MIEUTAHETHONG -->
                <div class="row g-3 mb-4 bg-light p-3 rounded" style="border: 1px solid var(--border-color);">
                    <!-- 1. Search Box -->
                    <div class="col-12 col-md-3">
                        <label class="form-label fw-semibold text-muted small"><i class="bi bi-search"></i> Tìm kiếm nhanh</label>
                        <input type="text" id="productSearchInput" class="form-control form-control-teapos" placeholder="Tìm tên hoặc mã sản phẩm..." onkeyup="filterProductsRealtime()">
                    </div>
                    <!-- 2. Filter theo Danh mục -->
                    <div class="col-6 col-md-2">
                        <label class="form-label fw-semibold text-muted small"><i class="bi bi-tag-fill"></i> Nhóm danh mục</label>
                        <select id="filterCategory" class="form-select form-control-teapos" onchange="filterProductsRealtime()">
                            <option value="">-- Tất cả nhóm --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.maDm}"><c:out value="${cat.tenDm}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <!-- 3. Filter theo Trạng thái -->
                    <div class="col-6 col-md-2">
                        <label class="form-label fw-semibold text-muted small"><i class="bi bi-toggle-on"></i> Trạng thái</label>
                        <select id="filterStatus" class="form-select form-control-teapos" onchange="filterProductsRealtime()">
                            <option value="">-- Tất cả --</option>
                            <option value="1">Đang mở bán</option>
                            <option value="0">Tạm dừng bán</option>
                        </select>
                    </div>
                    <!-- 4. Filter Sản phẩm MỚI -->
                    <div class="col-6 col-md-2">
                        <label class="form-label fw-semibold text-muted small"><i class="bi bi-star"></i> Nhãn mới</label>
                        <select id="filterNew" class="form-select form-control-teapos" onchange="filterProductsRealtime()">
                            <option value="">-- Tất cả --</option>
                            <option value="true">Sản phẩm mới ✨</option>
                            <option value="false">Sản phẩm thường</option>
                        </select>
                    </div>
                    <!-- 5. Filter Bestseller -->
                    <div class="col-6 col-md-2">
                        <label class="form-label fw-semibold text-muted small"><i class="bi bi-fire text-danger"></i> Sức hút</label>
                        <select id="filterHot" class="form-select form-control-teapos" onchange="filterProductsRealtime()">
                            <option value="">-- Tất cả --</option>
                            <option value="true">Bán chạy nhất 🔥</option>
                            <option value="false">Bình thường</option>
                        </select>
                    </div>
                    <!-- 6. Nút làm mới bộ lọc -->
                    <div class="col-12 col-md-1 d-flex align-items-end">
                        <button class="btn btn-secondary-teapos w-100 py-2.5 fw-semibold" onclick="resetFilters()"><i class="bi bi-arrow-counterclockwise"></i> Reset</button>
                    </div>
                </div>

                <!-- BẢNG SẢN PHẨM KHỚP 100% CÁC CỘT TRONG FILE MIEUTAHETHONG -->
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="productTable">
                        <thead>
                        <tr class="table-light text-center">
                            <th style="width: 60px;">STT</th>
                            <th style="width: 90px;">Mã</th>
                            <th style="width: 90px;">Ảnh</th>
                            <th class="text-start">Tên Sản Phẩm</th>
                            <th class="text-start">Danh Mục</th>
                            <th style="width: 140px;">Size Đang Bán</th>
                            <th class="text-end" style="width: 120px;">Giá Nhỏ Nhất</th>
                            <th class="text-end" style="width: 120px;">Giá Lớn Nhất</th>
                            <th style="width: 150px;">Trạng Thái</th>
                            <th style="width: 150px;">Ngày Tạo</th>
                            <th style="width: 180px;">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty products}">
                                <c:forEach var="item" items="${products}" varStatus="loop">
                                    <!-- Thuật toán JSTL bóc tách quy đổi giá trị min, max, size_list -->
                                    <c:set var="minPrice" value="99999999"/>
                                    <c:set var="maxPrice" value="0"/>
                                    <c:set var="activeSizes" value=""/>
                                    <c:forEach var="szPrice" items="${item.sizesList}">
                                        <c:if test="${szPrice.trangThai}">
                                            <!-- Đọc tên size động gửi lên -->
                                            <c:set var="sizeChar" value="${szPrice.maSize == 1 ? 'S' : (szPrice.maSize == 2 ? 'M' : (szPrice.maSize == 3 ? 'L' : 'KHÁC'))}"/>
                                            <c:set var="activeSizes" value="${empty activeSizes ? sizeChar : activeSizes.concat(', ').concat(sizeChar)}"/>
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

                                        <td><strong>${loop.index + 1}</strong></td>
                                        <td><code class="fw-bold text-dark">${item.maSp}</code></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border shadow-sm" style="width: 50px; height: 50px; object-fit: cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 50px; height: 50px;">
                                                        <i class="bi bi-cup-straw fs-4"></i>
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
                                        <td class="small text-muted">
                                            <fmt:formatDate value="${item.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <!-- ĐÃ BỎ NÚT XEM, ĐỔI NÚT XÓA THÀNH "NGỪNG HOẠT ĐỘNG / NGỪNG BÁN" AN TOÀN -->
                                            <div class="d-flex justify-content-center gap-2">
                                                <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-outline-primary fw-semibold px-2.5 py-1.5">
                                                    <i class="bi bi-pencil-square"></i> Sửa cấu hình
                                                </a>
                                                <c:choose>
                                                    <c:when test="${item.trangThai}">
                                                        <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5 py-1.5" onclick="confirmDeleteSanPham('${item.maSp}')">
                                                            <i class="bi bi-toggle2-off"></i> Ngừng bán
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- Nếu sản phẩm đang dừng hoạt động, hiển thị nút mở bán lại -->
                                                        <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-outline-success fw-semibold px-2.5 py-1.5">
                                                            <i class="bi bi-toggle2-on"></i> Mở bán lại
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="11" class="text-center py-5 text-muted">
                                        <i class="bi bi-cup-hot fs-1 text-secondary opacity-50 d-block mb-2"></i>
                                        Chưa ghi nhận sản phẩm đồ uống nào hoạt động trong CSDL!
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    function filterProductsRealtime() {
        const searchVal = document.getElementById("productSearchInput").value.trim().toLowerCase();
        const catVal = document.getElementById("filterCategory").value;
        const statusVal = document.getElementById("filterStatus").value;
        const newVal = document.getElementById("filterNew").value;
        const hotVal = document.getElementById("filterHot").value;

        const rows = document.querySelectorAll("#productTable tbody .product-row");
        rows.forEach(row => {
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

            if (matchSearch && matchCat && matchStatus && matchNew && matchHot) {
                row.style.display = "table-row";
            } else {
                row.style.display = "none";
            }
        });
    }

    function resetFilters() {
        document.getElementById("productSearchInput").value = "";
        document.getElementById("filterCategory").selectedIndex = 0;
        document.getElementById("filterStatus").selectedIndex = 0;
        document.getElementById("filterNew").selectedIndex = 0;
        document.getElementById("filterHot").selectedIndex = 0;
        filterProductsRealtime();
    }

    function confirmDeleteSanPham(maSp) {
        Swal.fire({
            title: 'Xác nhận dừng bán sản phẩm này?',
            text: "Cơ chế NGỪNG HOẠT ĐỘNG (Soft Delete) chuyển trạng thái của sản phẩm mẹ về Ngừng mở bán để bảo toàn tuyệt đối cơ cấu hóa đơn giao dịch cũ trong quá khứ!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý dừng bán',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/sanpham?action=delete&id=' + maSp;
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm mới món uống thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi cấu hình sản phẩm!');
        if (msg === 'deletesuccess') showToast('success', 'Đã cập nhật trạng thái Ngừng bán món uống!');
        if (msg === 'deletefailed') showToast('error', 'Hệ thống gặp sự cố khi cập nhật trạng thái sản phẩm!');
    });
</script>
</body>
</html>