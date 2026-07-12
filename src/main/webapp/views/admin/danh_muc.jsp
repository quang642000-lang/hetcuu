<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Danh Mục Đồ Uống</title>
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
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px;">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-grid-1x2-fill me-2"></i>QUẢN LÝ DANH MỤC</h3>
                        <p class="text-muted small mb-0">Thiết lập nhóm phân loại đồ uống cho Menu bán hàng POS tại quầy và Website Portal đặt online</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateModal()">
                        <i class="bi bi-plus-circle-fill"></i> Thêm Danh Mục Mới
                    </button>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="categoryTable">
                        <thead>
                        <tr class="table-light text-center">
                            <th style="width: 100px;">Mã DM</th>
                            <th style="width: 120px;" class="text-center">Hình Ảnh</th>
                            <th>Tên Nhóm Danh Mục</th>
                            <th class="text-center" style="width: 150px;">Thứ Tự</th>
                            <th class="text-center" style="width: 180px;">Trạng Thái</th>
                            <th class="text-end" style="width: 200px;">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty categories}">
                                <c:forEach var="item" items="${categories}">
                                    <tr class="category-row text-center">
                                        <td><strong>DM${item.maDm}</strong></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border" style="width: 50px; height: 50px; object-fit: cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 50px; height: 50px;">
                                                        <i class="bi bi-image fs-4"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="fw-bold text-dark"><c:out value="${item.tenDm}"/></span></td>
                                        <td class="text-center"><span class="badge bg-secondary px-2.5 py-1.5" style="border-radius: 6px;">${item.thuTuHienThi}</span></td>
                                        <td class="text-center">
<span class="badge ${item.trangThai ? 'bg-success' : 'bg-danger'} bg-opacity-10 ${item.trangThai ? 'text-success' : 'text-danger'} border px-3 py-1.5">
        ${item.trangThai ? 'Đang hoạt động' : 'Ngừng bán'}
</span>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-primary fw-semibold px-2.5 me-1"
                                                    data-id="${item.maDm}"
                                                    data-name="${item.tenDm}"
                                                    data-img="${item.hinhAnh}"
                                                    data-sort="${item.thuTuHienThi}"
                                                    data-status="${item.trangThai ? 1 : 0}"
                                                    onclick="handleEditDanhMucClick(this)">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5"
                                                    onclick="confirmDeleteDanhMuc(${item.maDm})">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="6" class="text-center py-5 text-muted">Chưa có thông tin danh mục!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
                <!-- THANH ĐIỀU KHIỂN PHÂN TRANG ĐỘNG Ở TRANG QUẢN TRỊ ADMIN -->
                <div class="d-flex justify-content-between align-items-center mt-4 border-top pt-3" id="adminPaginationArea">
                    <div class="small text-muted">Hiển thị <span id="paginatedInfo">0</span> dòng dữ liệu lọc</div>
                    <nav aria-label="Table pagination">
                        <ul class="pagination pagination-sm justify-content-end mb-0" id="paginatedControls">
                            <!-- Nạp động nút phân trang bằng JS -->
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
<!-- MODAL FORM ĐỘNG -->
<div class="modal fade" id="danhMucFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color);">
                <h5 class="modal-title fw-bold" id="modalTitle">THÊM DANH MỤC</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="danhMucForm" action="${pageContext.request.contextPath}/admin/danhmuc" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maDm" id="formMaDm" value="0">
                <input type="hidden" name="currentHinhAnh" id="currentHinhAnh" value="">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="tenDm" class="form-label fw-bold small">Tên nhóm danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDm" name="tenDm" required autocomplete="off">
                    </div>
                    <!-- Hỗ trợ uploader từ máy tính -->
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-dark d-block">Hình ảnh danh mục</label>
                        <ul class="nav nav-pills mb-2 bg-light p-1 rounded-pill" id="catImgTab" role="tablist">
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link active rounded-pill py-1 fs-12 w-100" id="cat-file-tab" data-bs-toggle="tab" data-bs-target="#catFilePanel" onclick="switchCatUploadType('file')">TẢI TỪ MÁY TÍNH</button>
                            </li>
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link rounded-pill py-1 fs-12 w-100" id="cat-url-tab" data-bs-toggle="tab" data-bs-target="#catUrlPanel" onclick="switchCatUploadType('url')">DÁN ĐƯỜNG DẪN URL</button>
                            </li>
                        </ul>
                        <input type="hidden" name="uploadType" id="uploadType" value="file">
                        <div class="tab-content" id="catImgTabContent">
                            <div class="tab-pane show active p-2 border rounded bg-white" id="catFilePanel" role="tabpanel">
                                <input type="file" class="form-control form-control-sm" name="hinhAnhFile" id="hinhAnhFile" accept="image/*">
                            </div>
                            <div class="tab-pane p-2 border rounded bg-white" id="catUrlPanel" role="tabpanel" style="display: none;">
                                <input type="text" class="form-control form-control-sm" name="hinhAnhUrl" id="hinhAnhUrl" placeholder="Dán link ảnh https://image-path...">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="thuTuHienThi" class="form-label fw-bold small">Thứ tự ưu tiên hiển thị</label>
                        <input type="number" class="form-control form-control-teapos" id="thuTuHienThi" name="thuTuHienThi" value="0" min="0" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-bold small d-block">Trạng thái bán</label>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1" checked>
                            <label class="form-check-label text-success fw-medium" for="statusActive">Đang hoạt động</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0">
                            <label class="form-check-label text-danger" for="statusInactive">Ngừng hoạt động</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-secondary-teapos" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn-teapos btn-primary-teapos fw-bold"><i class="bi bi-save me-1"></i> Lưu dữ liệu</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const modalElement = document.getElementById('danhMucFormModal');
    const bsModal = new bootstrap.Modal(modalElement);
    function switchCatUploadType(type) {
        document.getElementById('uploadType').value = type;
        if (type === 'file') {
            document.getElementById('catFilePanel').style.setProperty('display', 'block', 'important');
            document.getElementById('catUrlPanel').style.setProperty('display', 'none', 'important');
        } else {
            document.getElementById('catFilePanel').style.setProperty('display', 'none', 'important');
            document.getElementById('catUrlPanel').style.setProperty('display', 'block', 'important');
        }
    }
    function openCreateModal() {
        document.getElementById("danhMucForm").reset();
        document.getElementById("modalTitle").innerText = "THÊM DANH MỤC MỚI";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaDm").value = "0";
        document.getElementById("currentHinhAnh").value = "";
        document.getElementById("statusActive").checked = true;
        document.getElementById("hinhAnhFile").value = "";
        document.getElementById("hinhAnhUrl").value = "";
        switchCatUploadType('file');
        bsModal.show();
    }
    function handleEditDanhMucClick(button) {
        const id = button.getAttribute("data-id");
        const name = button.getAttribute("data-name");
        const img = button.getAttribute("data-img");
        const sort = button.getAttribute("data-sort");
        const status = parseInt(button.getAttribute("data-status"));
        openEditModal(id, name, img, sort, status);
    }
    function openEditModal(maDm, tenDm, hinhAnh, thuTu, trangThai) {
        document.getElementById("modalTitle").innerText = "CẬP NHẬT DANH MỤC";
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaDm").value = maDm;
        document.getElementById("tenDm").value = tenDm;
        document.getElementById("currentHinhAnh").value = hinhAnh ? hinhAnh : "";
        document.getElementById("hinhAnhUrl").value = hinhAnh ? hinhAnh : "";
        document.getElementById("hinhAnhFile").value = "";
        document.getElementById("thuTuHienThi").value = thuTu;
        if (trangThai === 1) {
            document.getElementById("statusActive").checked = true;
        } else {
            document.getElementById("statusInactive").checked = true;
        }
        switchCatUploadType(hinhAnh && hinhAnh.startsWith('http') ? 'url' : 'file');
        bsModal.show();
    }
    function confirmDeleteDanhMuc(maDm) {
        Swal.fire({
            title: 'Xác nhận xóa?',
            text: "Dữ liệu danh mục sẽ bị xóa vĩnh viễn khỏi CSDL và không thể hoàn tác!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/danhmuc?action=delete&id=' + maDm;
            }
        });
    }
    // CẤU HÌNH PHÂN TRANG CLIENT SIDE THÔNG MINH CHO ADMIN DANH MỤC
    let currentPage = 1;
    const pageSize = 10; // 10 bản ghi trên một trang
    function paginateAdminTable() {
        const rows = Array.from(document.querySelectorAll("#categoryTable tbody .category-row"));
        const totalRecords = rows.length;
        const totalPages = Math.ceil(totalRecords / pageSize);
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
        const startIndex = (currentPage - 1) * pageSize;
        const endIndex = startIndex + pageSize;
        rows.forEach((row, idx) => {
            if (idx >= startIndex && idx < endIndex) {
                row.style.display = "table-row";
            } else {
                row.style.display = "none";
            }
        });
// Render bộ nút phân trang
        const infoEl = document.getElementById("paginatedInfo");
        if (infoEl) {
            infoEl.innerText = (totalRecords > 0 ? (startIndex + 1) : 0) + " đến " + Math.min(endIndex, totalRecords) + " trong tổng số " + totalRecords;
        }
        renderPaginationButtons(totalPages);
    }
    function renderPaginationButtons(totalPages) {
        const controls = document.getElementById("paginatedControls");
        if (!controls) return;
        controls.innerHTML = "";
        if (totalPages <= 1) {
            const area = document.getElementById("adminPaginationArea");
            if (area) area.style.display = "none";
            return;
        }
        const area = document.getElementById("adminPaginationArea");
        if (area) area.style.display = "flex";
// Nút Trang trước
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<button class="page-link text-success" type="button" onclick="changeAdminPage(' + (currentPage - 1) + ')">&laquo;</button>';
        controls.appendChild(prevLi);
// Các mốc số trang
        for (let i = 1; i <= totalPages; i++) {
            const pageLi = document.createElement("li");
            pageLi.className = "page-item " + (currentPage === i ? "active" : "");
            pageLi.innerHTML = '<button class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" type="button" onclick="changeAdminPage(' + i + ')">' + i + '</button>';
            controls.appendChild(pageLi);
        }
// Nút Trang sau
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<button class="page-link text-success" type="button" onclick="changeAdminPage(' + (currentPage + 1) + ')">&raquo;</button>';
        controls.appendChild(nextLi);
    }
    function changeAdminPage(newPage) {
        currentPage = newPage;
        paginateAdminTable();
    }
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm danh mục mới thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi thông tin danh mục!');
        if (msg === 'deletesuccess') showToast('success', 'Xóa thành công danh mục!');
        if (msg === 'deletefailed') {
            Swal.fire({
                icon: 'error',
                title: 'Không thể xóa!',
                text: 'Hệ thống phát hiện danh mục này hiện đã liên kết với sản phẩm. Vui lòng xóa các sản phẩm bên trong trước.',
                confirmButtonColor: '#2e7d32'
            });
        }
        paginateAdminTable();
    });
</script>
</body>
</html>