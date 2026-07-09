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
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ DANH MỤC</h3>
                        <p class="text-muted small mb-0">Thiết lập nhóm phân loại đồ uống cho Menu bán hàng POS tại quầy và Website Portal đặt online [19]</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateModal()">
                        <i class="bi bi-plus-circle-fill"></i> Thêm Danh Mục Mới
                    </button>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
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
                                    <tr>
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
                                                    onclick="openEditModal(${item.maDm}, '<c:out value="${item.tenDm}"/>', '<c:out value="${item.hinhAnh}"/>', ${item.thuTuHienThi}, ${item.trangThai ? 1 : 0})">
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
            <form id="danhMucForm" action="${pageContext.request.contextPath}/admin/danhmuc" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maDm" id="formMaDm" value="0">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="tenDm" class="form-label fw-bold small">Tên nhóm danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDm" name="tenDm" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="hinhAnh" class="form-label fw-bold small">Đường dẫn hình ảnh (URL)</label>
                        <input type="text" class="form-control form-control-teapos" id="hinhAnh" name="hinhAnh">
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

    function openCreateModal() {
        document.getElementById("danhMucForm").reset();
        document.getElementById("modalTitle").innerText = "THÊM DANH MỤC MỚI";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaDm").value = "0";
        document.getElementById("statusActive").checked = true;
        bsModal.show();
    }

    function openEditModal(maDm, tenDm, hinhAnh, thuTu, trangThai) {
        document.getElementById("modalTitle").innerText = "CẬP NHẬT DANH MỤC";
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaDm").value = maDm;
        document.getElementById("tenDm").value = tenDm;
        document.getElementById("hinhAnh").value = hinhAnh;
        document.getElementById("thuTuHienThi").value = thuTu;
        if (trangThai === 1) {
            document.getElementById("statusActive").checked = true;
        } else {
            document.getElementById("statusInactive").checked = true;
        }
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
                text: 'Hệ thống phát hiện danh mục này hiện đã liên kết với sản phẩm. Vui lòng xóa các sản phẩm bên trong trước [19].',
                confirmButtonColor: '#2e7d32'
            });
        }
    });
</script>
</body>
</html>