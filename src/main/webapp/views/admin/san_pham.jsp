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
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ SẢN PHẨM</h3>
                        <p class="text-muted small mb-0">Quản lý vòng đời đồ uống, các tùy biến pha chế và trạng thái mở bán [23]</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/sanpham?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold">
                        <i class="bi bi-plus-circle-fill"></i> Thêm Sản Phẩm Mới
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
                            <th style="width: 100px;">Mã SP</th>
                            <th style="width: 100px;" class="text-center">Hình Ảnh</th>
                            <th>Tên Sản Phẩm Đồ Uống</th>
                            <th class="text-center">Đặc Tính Pha Chế</th>
                            <th class="text-center">Nhãn Đặc Biệt</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty products}">
                                <c:forEach var="item" items="${products}">
                                    <tr>
                                        <td><strong>${item.maSp}</strong></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty item.hinhAnh}">
                                                    <img src="${item.hinhAnh}" class="rounded border" style="width: 50px; height: 50px; object-fit: cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="bg-light text-muted d-flex align-items-center justify-content-center rounded border mx-auto" style="width: 50px; height: 50px;">
                                                        <i class="bi bi-cup-straw fs-3"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${item.tenSp}"/></div>
                                            <small class="text-muted text-truncate d-block" style="max-width: 320px;">${item.moTa}</small>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge ${item.choPhepDoiDa ? 'bg-success text-success' : 'bg-secondary text-secondary'} bg-opacity-10 border px-2 py-1 small me-1">Đổi Đá</span>
                                            <span class="badge ${item.choPhepDoiDuong ? 'bg-info text-info' : 'bg-secondary text-secondary'} bg-opacity-10 border px-2 py-1 small">Đổi Đường</span>
                                        </td>
                                        <td class="text-center">
                                            <c:if test="${item.isNew}"><span class="badge bg-warning text-dark fw-bold border-warning px-2.5 py-1">MỚI ✨</span></c:if>
                                            <c:if test="${item.isBestseller}"><span class="badge bg-danger text-white fw-bold border-danger px-2.5 py-1 ms-1">HOT 🔥</span></c:if>
                                        </td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThai ? 'bg-success text-success' : 'bg-danger text-danger'} bg-opacity-10 border px-3 py-1.5">
                                                        ${item.trangThai ? 'Đang mở bán' : 'Đóng bán'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-outline-primary fw-semibold px-2.5 me-1">
                                                <i class="bi bi-gear-fill"></i> Cấu hình
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5" onclick="confirmDeleteSanPham('${item.maSp}')">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="text-center py-5 text-muted">Chưa ghi nhận sản phẩm nào!</td></tr>
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
    function confirmDeleteSanPham(maSp) {
        Swal.fire({
            title: 'Xóa mềm sản phẩm?',
            text: "Dữ liệu sẽ chuyển sang trạng thái ngừng hoạt động để bảo lưu kết cấu hóa đơn cũ [23]!",
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
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm mới món thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu cấu hình sản phẩm!');
        if (msg === 'deletesuccess') showToast('success', 'Đã xóa mềm sản phẩm!');
    });
</script>
</body>
</html>
