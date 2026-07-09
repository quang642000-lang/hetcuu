<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Danh Mục Đồ Uống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="/views/layout/header_admin.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body>

<div class="admin-wrapper">
    <!-- Nhúng Sidebar dọc -->
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <!-- Khu vực nội dung Admin -->
    <div class="admin-content p-4">
        <div class="card card-teapos p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ DANH MỤC</h3>
                    <p class="text-muted small mb-0">Thiết lập nhóm phân loại đồ uống cho Menu bán hàng POS tại quầy và Website Portal đặt online [1]</p>
                </div>
                <!-- Nút mở Modal thêm mới danh mục -->
                <button class="btn btn-primary-teapos d-flex align-items-center gap-2" onclick="openCreateModal()">
                    <i class="bi bi-plus-circle-fill"></i> Thêm Danh Mục Mới
                </button>
            </div>

            <!-- Bảng dữ liệu danh mục -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th style="width: 100px;">Mã DM</th>
                        <th style="width: 120px;" class="text-center">Hình Ảnh</th>
                        <th>Tên Nhóm Danh Mục</th>
                        <th class="text-center" style="width: 150px;">Thứ Tự Hiển Thị</th>
                        <th class="text-center" style="width: 180px;">Trạng Thái Bật Bán</th>
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
                                                <img src="${item.hinhAnh}" class="rounded border border-secondary border-opacity-25" style="width: 55px; height: 55px; object-fit: cover;">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 55px; height: 55px;">
                                                    <i class="bi bi-image fs-4"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="fw-bold text-dark"><c:out value="${item.tenDm}"/></span></td>
                                    <td class="text-center">
                                        <span class="badge bg-secondary px-2.5 py-1.5 fs-6" style="border-radius: 6px;">${item.thuTuHienThi}</span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThai}">
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 badge-status">
                                                        <i class="bi bi-check-circle-fill me-1"></i> Đang hoạt động
                                                    </span>
                                            </c:when>
                                            <c:otherwise>
                                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1.5 badge-status">
                                                        <i class="bi bi-x-circle-fill me-1"></i> Ngừng bán
                                                    </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <button class="btn btn-sm btn-outline-primary fw-semibold px-2.5"
                                                    onclick="openEditModal(${item.maDm}, '<c:out value="${item.tenDm}"/>', '<c:out value="${item.hinhAnh}"/>', ${item.thuTuHienThi}, ${item.trangThai ? 1 : 0})">
                                                <i class="bi bi-pencil-square me-1"></i> Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5"
                                                    onclick="confirmDeleteDanhMuc(${item.maDm})">
                                                <i class="bi bi-trash3-fill me-1"></i> Xóa
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="bi bi-folder-x fs-1 d-block mb-2"></i>
                                    Chưa có thông tin danh mục nào trong hệ thống!
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

<!-- MODAL FORM ĐỘNG (THÊM / CẬP NHẬT) -->
<div class="modal fade" id="danhMucFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color); border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title fw-bold" id="modalTitle">THÊM DANH MỤC</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form id="danhMucForm" action="${pageContext.request.contextPath}/admin/danhmuc" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maDm" id="formMaDm" value="0">

                <div class="modal-body p-4">
                    <!-- Tên danh mục -->
                    <div class="mb-3">
                        <label for="tenDm" class="form-label fw-bold text-dark small">Tên nhóm danh mục <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDm" name="tenDm" placeholder="Ví dụ: Trà Trái Cây Nhiệt Đới..." required autocomplete="off">
                    </div>

                    <!-- Hình ảnh -->
                    <div class="mb-3">
                        <label for="hinhAnh" class="form-label fw-bold text-dark small">Đường dẫn hình ảnh minh họa (URL)</label>
                        <input type="text" class="form-control form-control-teapos" id="hinhAnh" name="hinhAnh" placeholder="https://domain.com/hinh-anh.png...">
                    </div>

                    <!-- Thứ tự hiển thị -->
                    <div class="mb-3">
                        <label id="lblThuTu" for="thuTuHienThi" class="form-label fw-bold text-dark small">Thứ tự ưu tiên hiển thị trên Menu</label>
                        <input type="number" class="form-control form-control-teapos" id="thuTuHienThi" name="thuTuHienThi" value="0" min="0" required>
                    </div>

                    <!-- Trạng thái -->
                    <div class="mb-2">
                        <label class="form-label fw-bold text-dark small d-block">Trạng thái bán</label>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusActive" value="1" checked>
                            <label class="form-check-label fw-medium text-success" for="statusActive">Đang hoạt động</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="trangThai" id="statusInactive" value="0">
                            <label class="form-check-label class-inactive text-danger" for="statusInactive">Ngừng hoạt động</label>
                        </div>
                    </div>
                </div>

                <!-- Nút thao tác -->
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
    // Khởi tạo thực thể modal Bootstrap
    const modalElement = document.getElementById('danhMucFormModal');
    const bsModal = new bootstrap.Modal(modalElement);

    // Mở modal thêm danh mục mới
    function openCreateModal() {
        document.getElementById("danhMucForm").reset();
        document.getElementById("modalTitle").innerText = "THÊM DANH MỤC MỚI";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaDm").value = "0";
        document.getElementById("statusActive").checked = true;
        bsModal.show();
    }

    // Mở modal cập nhật danh mục hiện tại
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

    // Xác nhận xóa cứng danh mục đồ uống (Sẽ chặn xóa nếu danh mục đã chứa sản phẩm mẹ [1])
    function confirmDeleteDanhMuc(maDm) {
        Swal.fire({
            title: 'Xác nhận xóa?',
            text: "Dữ liệu danh mục sẽ bị xóa vĩnh viễn khỏi CSDL và không thể hoàn tác!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa cứng',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/danhmuc?action=delete&id=' + maDm;
            }
        });
    }

    // Bắt các thông báo điều hướng thành công/thất bại từ Servlet chuyển về
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');

        if (msg === 'createsuccess') showToast('success', 'Thêm danh mục mới thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi thông tin danh mục!');
        if (msg === 'deletesuccess') showToast('success', 'Xóa thành công danh mục ra khỏi hệ thống!');
        if (msg === 'deletefailed') {
            Swal.fire({
                icon: 'error',
                title: 'Không thể xóa!',
                text: 'Hệ thống phát hiện danh mục này hiện đã liên kết với sản phẩm. Vui lòng xóa các sản phẩm bên trong trước [1].',
                confirmButtonColor: '#2e7d32'
            });
        }

        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Trùng lặp dữ liệu',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>