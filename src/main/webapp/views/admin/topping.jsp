<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Topping Ăn Kèm</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="/views/layout/header_admin.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body>

<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <div class="admin-content p-4">
        <div class="card card-teapos p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ TOPPING</h3>
                    <p class="text-muted small mb-0">Thiết lập đơn giá, định lượng và quản lý trạng thái cung cấp topping ăn kèm đồ uống tại quầy [3]</p>
                </div>
                <!-- Nút mở Modal thêm Topping -->
                <button class="btn btn-primary-teapos d-flex align-items-center gap-2" onclick="openCreateToppingModal()">
                    <i class="bi bi-plus-circle-fill"></i> Thêm Topping Mới
                </button>
            </div>

            <!-- BẢNG TOÀN BỘ TOPPINGS -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th style="width: 100px;">Mã TP</th>
                        <th>Tên Topping Ăn Kèm</th>
                        <th>Định Lượng Tiêu Chuẩn</th>
                        <th class="text-center" style="width: 150px;">Đơn Giá Bán</th>
                        <th class="text-center" style="width: 150px;">Thứ Tự Sắp Xếp</th>
                        <th class="text-center" style="width: 180px;">Trạng Thái Hàng</th>
                        <th class="text-end" style="width: 220px;">Hành Động</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty toppings}">
                            <c:forEach var="item" items="${toppings}">
                                <tr>
                                    <td><strong>TP${item.maTp}</strong></td>
                                    <td><span class="fw-bold text-dark"><c:out value="${item.tenTp}"/></span></td>
                                    <td><c:out value="${not empty item.dinhLuong ? item.dinhLuong : 'Theo công thức cốc'}"/></td>
                                    <td class="text-center fw-bold text-success">
                                        <fmt:formatNumber value="${item.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-secondary px-2.5 py-1.5 fs-6" style="border-radius: 6px;">${item.thuTuHienThi}</span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThai}">
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 badge-status">
                                                        <i class="bi bi-check-circle-fill me-1"></i> Còn hàng
                                                    </span>
                                            </c:when>
                                            <c:otherwise>
                                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1.5 badge-status">
                                                        <i class="bi bi-x-circle-fill me-1"></i> Tạm hết
                                                    </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <!-- Công tắc bật/tắt nhanh trạng thái Topping [3] -->
                                            <a href="${pageContext.request.contextPath}/admin/topping?action=toggle&id=${item.maTp}&status=${item.trangThai ? 0 : 1}"
                                               class="btn btn-sm ${item.trangThai ? 'btn-outline-warning' : 'btn-outline-success'} fw-semibold px-2">
                                                <i class="bi ${item.trangThai ? 'bi-eye-slash-fill' : 'bi-eye-fill'}"></i> ${item.trangThai ? 'Ẩn' : 'Bật'}
                                            </a>
                                            <button class="btn btn-sm btn-outline-primary fw-semibold px-2.5"
                                                    onclick="openEditToppingModal(${item.maTp}, '<c:out value="${item.tenTp}"/>', '<c:out value="${item.dinhLuong}"/>', ${item.giaBan}, ${item.thuTuHienThi}, ${item.trangThai ? 1 : 0})">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5"
                                                    onclick="confirmDeleteTopping(${item.maTp})">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="bi bi-egg-fried fs-1 d-block mb-2"></i>
                                    Chưa ghi nhận topping nào trong hệ thống!
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

<!-- MODAL FORM TOÀN NĂNG -->
<div class="modal fade" id="toppingFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color); border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title fw-bold" id="toppingModalTitle">THÊM TOPPING MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form id="toppingForm" action="${pageContext.request.contextPath}/admin/topping" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maTp" id="formMaTp" value="0">

                <div class="modal-body p-4">
                    <!-- Tên Topping -->
                    <div class="mb-3">
                        <label for="tenTp" class="form-label fw-bold text-dark small">Tên Topping <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenTp" name="tenTp" placeholder="Ví dụ: Trân Châu Trắng 3Q..." required autocomplete="off">
                    </div>

                    <!-- Định lượng -->
                    <div class="mb-3">
                        <label for="dinhLuong" class="form-label fw-bold text-dark small">Định lượng tiêu chuẩn (g, ml, hoặc muôi)</label>
                        <input type="text" class="form-control form-control-teapos" id="dinhLuong" name="dinhLuong" placeholder="Ví dụ: 30g...">
                    </div>

                    <!-- Đơn giá -->
                    <div class="mb-3">
                        <label for="giaBan" class="form-label fw-bold text-dark small">Đơn giá bán lẻ (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control form-control-teapos" id="giaBan" name="giaBan" value="0" min="0" required>
                    </div>

                    <!-- Thứ tự sắp xếp -->
                    <div class="mb-3">
                        <label id="lblThuTu" for="thuTuHienThi" class="form-label fw-bold text-dark small">Thứ tự hiển thị trên danh sách</label>
                        <input type="number" class="form-control form-control-teapos" id="thuTuHienThi" name="thuTuHienThi" value="0" min="0" required>
                    </div>

                    <!-- Trạng thái hoạt động -->
                    <div class="mb-2">
                        <label class="form-label fw-bold text-dark small d-block">Trạng thái bán</label>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1" checked>
                            <label class="form-check-label fw-medium text-success" for="statusActive">Còn hàng cung cấp</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0">
                            <label class="form-check-label class-inactive text-danger" for="statusInactive">Hết hàng cung cấp</label>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="modal-footer bg-light" style="border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;">
                    <button type="button" class="btn btn-secondary-teapos px-4" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn-teapos btn-primary-teapos px-4 fw-bold"><i class="bi bi-save me-1"></i> Lưu dữ liệu</button>
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

    // Xác nhận xóa Topping [3]
    function confirmDeleteTopping(maTp) {
        Swal.fire({
            title: 'Chốt xóa Topping?',
            text: "Dữ liệu Topping sẽ bị xóa mềm khỏi danh sách bán hàng tại quầy [3]!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa',
            cancelButtonText: 'Hủy bỏ'
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
        if (msg === 'deletesuccess') showToast('success', 'Xóa thành công Topping ăn kèm!');

        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Thao tác lỗi',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>
