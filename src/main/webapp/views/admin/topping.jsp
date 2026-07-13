<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Topping Ăn Kèm</title>
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
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-egg-fried me-2"></i>QUẢN LÝ TOPPING</h3>
                        <p class="text-muted small mb-0">Thiết lập đơn giá, định lượng và quản lý trạng thái cung cấp topping ăn kèm đồ uống tại quầy</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateToppingModal()">
                        <i class="bi bi-plus-circle-fill"></i> Thêm Topping Mới
                    </button>
                </div>

                <div class="table-responsive admin-table-container">
                    <table class="table table-hover align-middle admin-table" id="toppingTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 100px;">Mã TP</th>
                            <th style="width: 100px;" class="text-center">Hình Ảnh</th>
                            <th>Tên Topping Ăn Kèm</th>
                            <th>Định Lượng</th>
                            <th class="text-center">Đơn Giá</th>
                            <th class="text-center">Sắp Xếp</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-end" style="width: 250px;">Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty toppings}">
                                <c:forEach var="item" items="${toppings}">
                                    <tr class="topping-row text-center">
                                        <td><strong>TP${item.maTp}</strong></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border" style="width: 44px; height: 44px; object-fit: cover; border-color: var(--border-color);">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 44px; height: 44px; border-color: var(--border-color);">
                                                        <i class="bi bi-image fs-5"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><span class="fw-bold text-dark"><c:out value="${item.tenTp}"/></span></td>
                                        <td><c:out value="${not empty item.dinhLuong ? item.dinhLuong : 'Mặc định'}"/></td>
                                        <td class="text-center fw-bold text-success">
                                            <fmt:formatNumber value="${item.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                        </td>
                                        <td class="text-center"><span class="badge bg-secondary px-2.5 py-1.5" style="border-radius: 6px;">${item.thuTuHienThi}</span></td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                        ${item.trangThai ? 'Còn hàng' : 'Tạm hết'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2 align-items-center">
                                                <a href="${pageContext.request.contextPath}/admin/topping?action=toggle&id=${item.maTp}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-action-warning' : 'btn-action-edit'}">
                                                        ${item.trangThai ? 'Tạm Ẩn' : 'Bật Bán'}
                                                </a>
                                                <!-- Use data attributes to prevent quote symbol clashing causing 500 error -->
                                                <button type="button" class="btn btn-sm btn-action-edit"
                                                        data-id="${item.maTp}"
                                                        data-name="<c:out value="${item.tenTp}"/>"
                                                        data-volume="${item.dinhLuong}"
                                                        data-price="${item.giaBan}"
                                                        data-sort="${item.thuTuHienThi}"
                                                        data-status="${item.trangThai ? 1 : 0}"
                                                        data-img="${item.hinhAnh}"
                                                        onclick="handleEditToppingClick(this)">
                                                    Sửa
                                                </button>
                                                <button type="button" class="btn btn-sm btn-action-delete" onclick="confirmDeleteTopping(${item.maTp})">
                                                    Xóa
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="8" class="text-center py-5 text-muted">Chưa ghi nhận Topping nào!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Table Pagination controls -->
                <div class="pagination-container" id="adminPaginationArea">
                    <span class="small text-muted" id="paginatedInfo">Hiển thị từ 1 đến 10 dòng dữ liệu</span>
                    <nav aria-label="Table pagination">
                        <ul class="pagination pagination-sm justify-content-end mb-0" id="paginatedControls"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- FORM TOÀN NĂNG MODAL -->
<div class="modal fade" id="toppingFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary);">
                <h5 class="modal-title fw-bold" id="toppingModalTitle">THÊM TOPPING MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="toppingForm" action="${pageContext.request.contextPath}/admin/topping" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maTp" id="formMaTp" value="0">
                <input type="hidden" name="currentHinhAnh" id="currentHinhAnh" value="">
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label for="tenTp" class="form-label fw-bold small text-muted">Tên Topping <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenTp" name="tenTp" placeholder="Trân châu hoàng kim..." required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="dinhLuong" class="form-label fw-bold small text-muted">Định lượng tiêu chuẩn</label>
                        <input type="text" class="form-control form-control-teapos" id="dinhLuong" name="dinhLuong" placeholder="30g...">
                    </div>
                    <div class="mb-3">
                        <label for="giaBan" class="form-label fw-bold small text-muted">Đơn giá bán (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control form-control-teapos text-end fw-bold text-success" id="giaBan" name="giaBan" value="0" min="0" required>
                    </div>
                    <!-- TOPPING IMAGES (LOCAL COMPUTER UPLOADER) -->
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted d-block">Hình ảnh minh họa Topping</label>
                        <ul class="nav nav-pills mb-2 bg-light p-1 rounded-pill" id="imgTab" role="tablist">
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link active rounded-pill py-1 fs-12 w-100" id="file-tab" data-bs-toggle="tab" data-bs-target="#filePanel" onclick="switchToppingUploadType('file')">TẢI TỪ MÁY TÍNH</button>
                            </li>
                            <li class="nav-item flex-fill text-center">
                                <button type="button" class="nav-link rounded-pill py-1 fs-12 w-100" id="url-tab" data-bs-toggle="tab" data-bs-target="#urlPanel" onclick="switchToppingUploadType('url')">DÁN ĐƯỜNG DẪN URL</button>
                            </li>
                        </ul>
                        <input type="hidden" name="uploadType" id="uploadType" value="file">
                        <div class="tab-content" id="imgTabContent">
                            <div class="tab-pane show active p-2 border rounded bg-white" id="filePanel" role="tabpanel">
                                <input type="file" class="form-control form-control-sm" name="hinhAnhFile" id="hinhAnhFile" accept="image/*">
                            </div>
                            <div class="tab-pane p-2 border rounded bg-white" id="urlPanel" role="tabpanel" style="display: none;">
                                <input type="text" class="form-control form-control-sm" name="hinhAnhUrl" id="hinhAnhUrl" placeholder="https://image-path...">
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="thuTuHienThi" class="form-label fw-bold small text-muted">Thứ tự hiển thị</label>
                        <input type="number" class="form-control form-control-teapos" id="thuTuHienThi" name="thuTuHienThi" value="0" min="0" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-bold small text-muted d-block">Trạng thái bán</label>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1" checked>
                            <label class="form-check-label text-success fw-medium" for="statusActive">Còn hàng</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0">
                            <label class="form-check-label text-danger" for="statusInactive">Tạm hết hàng</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-secondary-teapos" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary-teapos"><i class="bi bi-save me-1"></i> Lưu lại</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const tpFormModal = new bootstrap.Modal(document.getElementById('toppingFormModal'));

    function switchToppingUploadType(type) {
        document.getElementById('uploadType').value = type;
        if (type === 'file') {
            document.getElementById('filePanel').style.setProperty('display', 'block', 'important');
            document.getElementById('urlPanel').style.setProperty('display', 'none', 'important');
        } else {
            document.getElementById('filePanel').style.setProperty('display', 'none', 'important');
            document.getElementById('urlPanel').style.setProperty('display', 'block', 'important');
        }
    }

    function openCreateToppingModal() {
        document.getElementById("toppingForm").reset();
        document.getElementById("toppingModalTitle").innerText = "THÊM TOPPING MỚI";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaTp").value = "0";
        document.getElementById("currentHinhAnh").value = "";
        document.getElementById("statusActive").checked = true;
        document.getElementById("hinhAnhFile").value = "";
        document.getElementById("hinhAnhUrl").value = "";
        switchToppingUploadType('file');
        tpFormModal.show();
    }

    function handleEditToppingClick(button) {
        const id = button.getAttribute("data-id");
        const name = button.getAttribute("data-name");
        const volume = button.getAttribute("data-volume");
        const price = button.getAttribute("data-price");
        const sort = button.getAttribute("data-sort");
        const status = parseInt(button.getAttribute("data-status"));
        const img = button.getAttribute("data-img");
        openEditToppingModal(id, name, volume, price, sort, status, img);
    }

    function openEditToppingModal(maTp, tenTp, dinhLuong, giaBan, thuTu, trangThai, hinhAnh) {
        document.getElementById("toppingModalTitle").innerText = "CẬP NHẬT TOPPING";
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaTp").value = maTp;
        document.getElementById("tenTp").value = tenTp;
        document.getElementById("dinhLuong").value = dinhLuong === "Mặc định" ? "" : dinhLuong;
        document.getElementById("giaBan").value = giaBan;
        document.getElementById("thuTuHienThi").value = thuTu;
        document.getElementById("currentHinhAnh").value = hinhAnh ? hinhAnh : "";
        document.getElementById("hinhAnhUrl").value = hinhAnh ? hinhAnh : "";
        document.getElementById("hinhAnhFile").value = "";
        if (trangThai === 1) {
            document.getElementById("statusActive").checked = true;
        } else {
            document.getElementById("statusInactive").checked = true;
        }
        switchToppingUploadType(hinhAnh && hinhAnh.startsWith('http') ? 'url' : 'file');
        tpFormModal.show();
    }

    function confirmDeleteTopping(maTp) {
        Swal.fire({
            title: 'Xóa Topping?',
            text: "Hệ thống tự động kiểm duyệt: Nếu Topping đã dính lịch sử hóa đơn bán lẻ, hệ thống tự động khóa tạm ẩn (Soft Delete = 0). Nếu chưa từng bán, Topping được xóa cứng vĩnh viễn khỏi CSDL!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/topping?action=delete&id=' + maTp;
            }
        });
    }

    // Client-side pagination logic
    let currentPage = 1;
    const pageSize = 10;

    function paginateAdminTable() {
        const rows = Array.from(document.querySelectorAll("#toppingTable tbody .topping-row"));
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

        // Previous Page Button
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<button class="page-link text-success" type="button" onclick="changeAdminPage(' + (currentPage - 1) + ')">&laquo;</button>';
        controls.appendChild(prevLi);

        // Page Numbers
        for (let i = 1; i <= totalPages; i++) {
            const pageLi = document.createElement("li");
            pageLi.className = "page-item " + (currentPage === i ? "active" : "");
            pageLi.innerHTML = '<button class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" type="button" onclick="changeAdminPage(' + i + ')">' + i + '</button>';
            controls.appendChild(pageLi);
        }

        // Next Page Button
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
        if (msg === 'createsuccess') showToast('success', 'Thêm Topping thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Cập nhật Topping thành công!');
        if (msg === 'softdeletesuccess') {
            Swal.fire({
                icon: 'info',
                title: 'Tạm ẩn Topping',
                text: 'Topping này đã dính đơn bán lẻ trong quá khứ! Hệ thống tự động chuyển trạng thái hoạt động về 0 để bảo lưu cấu trúc hóa đơn!',
                confirmButtonColor: '#10b981'
            });
        }
        if (msg === 'harddeletesuccess') showToast('success', 'Đã xóa cứng vĩnh viễn Topping khỏi CSDL!');
        paginateAdminTable();
    });
</script>
</body>
</html>