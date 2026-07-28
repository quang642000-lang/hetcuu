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
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px; background-color: #ffffff;">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4 text-start">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-grid-1x2-fill me-2"></i>QUẢN LÝ DANH MỤC</h3>
                        <p class="text-muted small mb-0">Thiết lập nhóm phân loại đồ uống cho Menu bán hàng POS tại quầy và Website Portal đặt online</p>
                    </div>
                    <div class="d-flex gap-2 align-items-end">
                        <div class="input-group input-group-sm" style="width: 250px;">
                            <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                            <input type="text" id="categorySearchInput" class="form-control" placeholder="Tìm tên danh mục..." onkeyup="filterAndPaginateCategories()">
                        </div>
                        <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateModal()">
                            <i class="bi bi-plus-circle-fill"></i> Thêm Danh Mục
                        </button>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger d-flex align-items-center gap-2" style="border-radius: 8px;">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <span>${error}</span>
                    </div>
                </c:if>

                <div class="table-responsive admin-table-container">
                    <table class="table table-hover align-middle admin-table" id="categoryTable">
                        <thead>
                        <tr class="table-light text-center">
                            <th style="width: 80px;">STT</th>
                            <th style="width: 120px;">Mã nhóm</th>
                            <th style="width: 100px;">Ảnh minh họa</th>
                            <th class="text-start">Tên danh mục trà sữa</th>
                            <th style="width: 150px;">Thứ tự hiển thị</th>
                            <th style="width: 180px;">Trạng thái</th>
                            <th style="width: 250px;" class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody id="categoryTableBody">
                        <c:choose>
                            <c:when test="${not empty categories}">
                                <c:forEach var="item" items="${categories}" varStatus="loop">
                                    <tr class="category-row text-center"
                                        data-id="${item.maDm}"
                                        data-name="<c:out value='${item.tenDm}'/>"
                                        data-sort="${item.thuTuHienThi}"
                                        data-status="${item.trangThai ? 1 : 0}">
                                        <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                        <td><code class="fw-bold text-dark">${item.maDm}</code></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border" style="width: 44px; height: 44px; object-fit: cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 44px; height: 44px;">
                                                        <i class="bi bi-image fs-5"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-start"><span class="fw-bold text-dark"><c:out value="${item.tenDm}"/></span></td>
                                        <td><span class="badge bg-secondary px-2.5 py-1.5" style="border-radius: 6px;">${item.thuTuHienThi}</span></td>
                                        <td>
                                                    <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                            ${item.trangThai ? 'Đang hoạt động' : 'Ngừng bán'}
                                                    </span>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-1.5 align-items-center">
                                                <!-- NÚT BẬT/TẮT TRẠNG THÁI NHANH ĐỒNG BỘ -->
                                                <a href="${pageContext.request.contextPath}/admin/danhmuc?action=toggle&id=${item.maDm}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-action-warning' : 'btn-action-edit'}"
                                                   title="${item.trangThai ? 'Tạm ngưng hoạt động' : 'Kích hoạt hoạt động'}">
                                                    <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i>
                                                        ${item.trangThai ? 'Tạm ẩn' : 'Bật bán'}
                                                </a>

                                                <!-- NÚT SỬA ĐỒNG BỘ ICON -->
                                                <button class="btn btn-sm btn-action-edit"
                                                        data-id="${item.maDm}"
                                                        data-name="<c:out value='${item.tenDm}'/>"
                                                        data-img="${item.hinhAnh}"
                                                        data-sort="${item.thuTuHienThi}"
                                                        data-status="${item.trangThai ? 1 : 0}"
                                                        onclick="handleEditDanhMucClick(this)">
                                                    <i class="bi bi-pencil-square me-1"></i> Sửa
                                                </button>

                                                <!-- NÚT XÓA ĐỒNG BỘ ICON -->
                                                <button class="btn btn-sm btn-action-delete"
                                                        onclick="confirmDeleteDanhMuc('${item.maDm}')">
                                                    <i class="bi bi-trash3-fill me-1"></i> Xóa
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="text-center py-5 text-muted">Chưa có thông tin danh mục!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-container" id="paginationWrapper" style="display: none;">
                    <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 của 10 dòng dữ liệu</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL FORM -->
<div class="modal fade" id="danhMucFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%)">
                <h5 class="modal-title fw-bold" id="modalTitle">THÊM DANH MỤC</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="danhMucForm" action="${pageContext.request.contextPath}/admin/danhmuc" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maDm" id="formMaDm" value="">
                <input type="hidden" name="currentHinhAnh" id="currentHinhAnh" value="">
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label for="tenDm" class="form-label fw-bold small">Tên nhóm danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDm" name="tenDm" required autocomplete="off" placeholder="Ví dụ: Trà sữa...">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-dark d-block">Hình ảnh danh mục</label>
                        <ul class="nav nav-pills mb-2 bg-light p-1 rounded-pill" id="catImgTab" role="tablist">
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link active rounded-pill py-1 fs-12 w-100" id="cat-file-tab" data-bs-toggle="tab" data-bs-target="#catFilePanel" onclick="switchCatUploadType('file')">TẢI TỪ MÁY</button>
                            </li>
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link rounded-pill py-1 fs-12 w-100" id="cat-url-tab" data-bs-toggle="tab" data-bs-target="#catUrlPanel" onclick="switchCatUploadType('url')">DÁN LINK URL</button>
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
                            <label class="form-check-label text-success fw-bold" for="statusActive">Đang hoạt động</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0">
                            <label class="form-check-label text-danger" for="statusInactive">Ngừng bán</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-secondary-teapos" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary-teapos fw-bold"><i class="bi bi-save me-1"></i> Lưu dữ liệu</button>
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
        document.getElementById("formMaDm").value = "";
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
        document.getElementById("modalTitle").innerText = "CẬP NHẬT DANH MỤC: " + maDm;
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

    let currentPage = 1;
    const pageSize = 10;
    let filteredRows = [];

    function filterAndPaginateCategories() {
        const searchInput = document.getElementById("categorySearchInput");
        if (!searchInput) return;
        const searchVal = searchInput.value.trim().toLowerCase();
        const allRows = Array.from(document.querySelectorAll("#categoryTableBody .category-row"));
        filteredRows = allRows.filter(row => {
            const id = row.dataset.id.toLowerCase();
            const name = row.dataset.name.toLowerCase();
            return id.includes(searchVal) || name.includes(searchVal);
        });
        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        const allRows = document.querySelectorAll("#categoryTableBody .category-row");
        allRows.forEach(row => row.style.display = "none");
        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);
        const pageRows = filteredRows.slice(startIdx, endIdx);
        pageRows.forEach(row => row.style.display = "table-row");

        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const wrapper = document.getElementById("paginationWrapper");
        if (!infoEl || !btnContainer || !wrapper) return;

        const start = totalRows > 0 ? startIdx + 1 : 0;
        const end = endIdx;
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng danh mục';
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
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredRows.length / pageSize) || 1;
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTableRows();
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
                text: 'Hệ thống phát hiện danh mục này hiện đã liên kết với sản phẩm. Vui lòng gỡ các sản phẩm bên trong trước.',
                confirmButtonColor: '#10b981'
            });
        }
        filterAndPaginateCategories();
    });
</script>
</body>
</html>