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
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ TOPPING</h3>
                        <p class="text-muted small mb-0">Thiết lập đơn giá, định lượng và quản lý trạng thái cung cấp topping ăn kèm đồ uống tại quầy [25]</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateToppingModal()">
                        <i class="bi bi-plus-circle-fill"></i> Thêm Topping Mới
                    </button>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
                            <th style="width: 100px;">Mã TP</th>
                            <th>Tên Topping Ăn Kèm</th>
                            <th>Định Lượng</th>
                            <th class="text-center">Đơn Giá</th>
                            <th class="text-center">Sắp Xếp</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty toppings}">
                                <c:forEach var="item" items="${toppings}">
                                    <tr>
                                        <td><strong>TP${item.maTp}</strong></td>
                                        <td><span class="fw-bold text-dark"><c:out value="${item.tenTp}"/></span></td>
                                        <td><c:out value="${not empty item.dinhLuong ? item.dinhLuong : 'Mặc định'}"/></td>
                                        <td class="text-center fw-bold text-success"><fmt:formatNumber value="${item.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                        <td class="text-center"><span class="badge bg-secondary px-2 py-1">${item.thuTuHienThi}</span></td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThai ? 'bg-success text-success' : 'bg-danger text-danger'} bg-opacity-10 border px-3 py-1.5">
                                                        ${item.trangThai ? 'Còn hàng' : 'Tạm hết'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <a href="${pageContext.request.contextPath}/admin/topping?action=toggle&id=${item.maTp}&status=${item.trangThai ? 0 : 1}"
                                               class="btn btn-sm ${item.trangThai ? 'btn-outline-warning' : 'btn-outline-success'} fw-semibold me-1">
                                                    ${item.trangThai ? 'Tạm Ẩn' : 'Bật Bán'}
                                            </a>
                                            <button class="btn btn-sm btn-outline-primary fw-semibold me-1"
                                                    onclick="openEditToppingModal(${item.maTp}, '<c:out value="${item.tenTp}"/>', '<c:out value="${item.dinhLuong}"/>', ${item.giaBan}, ${item.thuTuHienThi}, ${item.trangThai ? 1 : 0})">
                                                Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger" onclick="confirmDeleteTopping(${item.maTp})">
                                                Xóa
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="text-center py-5 text-muted">Chưa ghi nhận Topping nào!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL FORM TOÀN NĂNG -->
<div class="modal fade" id="toppingFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color);">
                <h5 class="modal-title fw-bold" id="toppingModalTitle">THÊM TOPPING MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="toppingForm" action="${pageContext.request.contextPath}/admin/topping" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maTp" id="formMaTp" value="0">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="tenTp" class="form-label fw-bold small">Tên Topping <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenTp" name="tenTp" placeholder="Ví dụ: Trân châu hoàng kim..." required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="dinhLuong" class="form-label fw-bold small">Định lượng tiêu chuẩn</label>
                        <input type="text" class="form-control form-control-teapos" id="dinhLuong" name="dinhLuong" placeholder="Ví dụ: 30g...">
                    </div>
                    <div class="mb-3">
                        <label for="giaBan" class="form-label fw-bold small">Đơn giá bán (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control form-control-teapos" id="giaBan" name="giaBan" value="0" min="0" required>
                    </div>
                    <div class="mb-3">
                        <label for="thuTuHienThi" class="form-label fw-bold small">Thứ tự hiển thị</label>
                        <input type="number" class="form-control form-control-teapos" id="thuTuHienThi" name="thuTuHienThi" value="0" min="0" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-bold small d-block">Trạng thái bán</label>
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
                    <button type="submit" class="btn-teapos btn-primary-teapos fw-bold"><i class="bi bi-save me-1"></i> Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const tpFormModal = new bootstrap.Modal(document.getElementById('toppingFormModal'));

    function openCreateToppingModal() {
        document.getElementById("toppingForm").reset();
        document.getElementById("toppingModalTitle").innerText = "THÊM TOPPING MỚI";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaTp").value = "0";
        document.getElementById("statusActive").checked = true;
        tpFormModal.show();
    }

    function openEditToppingModal(maTp, tenTp, dinhLuong, giaBan, thuTu, trangThai) {
        document.getElementById("toppingModalTitle").innerText = "CẬP NHẬT TOPPING";
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaTp").value = maTp;
        document.getElementById("tenTp").value = tenTp;
        document.getElementById("dinhLuong").value = dinhLuong;
        document.getElementById("giaBan").value = giaBan;
        document.getElementById("thuTuHienThi").value = thuTu;
        if (trangThai === 1) {
            document.getElementById("statusActive").checked = true;
        } else {
            document.getElementById("statusInactive").checked = true;
        }
        tpFormModal.show();
    }

    function confirmDeleteTopping(maTp) {
        Swal.fire({
            title: 'Xóa Topping?',
            text: "Topping này sẽ bị xóa khỏi thực đơn hiển thị bán hàng [25]!",
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

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm Topping thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Cập nhật Topping thành công!');
        if (msg === 'deletesuccess') showToast('success', 'Xóa thành công Topping!');
    });
</script>
</body>
</html>
