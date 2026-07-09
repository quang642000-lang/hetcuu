<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Hành Sản Phẩm Đồ Uống</title>
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
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ SẢN PHẨM</h3>
                    <p class="text-muted small mb-0">Quản lý vòng đời đồ uống, các tùy biến pha chế Đá/Đường và trạng thái phân phối ngoài cổng quầy [2]</p>
                </div>
                <!-- Nút chuyển tới form Thêm mới sản phẩm -->
                <a href="${pageContext.request.contextPath}/admin/sanpham?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2">
                    <i class="bi bi-plus-circle-fill"></i> Thêm Sản Phẩm Mới
                </a>
            </div>

            <!-- BẢNG DANH SÁCH SẢN PHẨM -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th style="width: 100px;">Mã SP</th>
                        <th style="width: 100px;" class="text-center">Hình Ảnh</th>
                        <th>Tên Sản Phẩm Đồ Uống</th>
                        <th class="text-center" style="width: 200px;">Đặc Tính Pha Chế</th>
                        <th class="text-center" style="width: 180px;">Nhãn Độc Quyền</th>
                        <th class="text-center" style="width: 180px;">Trạng Thái</th>
                        <th class="text-end" style="width: 180px;">Hành Động</th>
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
                                        <span class="badge ${item.choPhepDoiDa ? 'bg-success bg-opacity-10 text-success border border-success' : 'bg-secondary bg-opacity-10 text-secondary border border-secondary'} px-2 py-1 small me-1">Đổi Đá</span>
                                        <span class="badge ${item.choPhepDoiDuong ? 'bg-info bg-opacity-10 text-info border border-info' : 'bg-secondary bg-opacity-10 text-secondary border border-secondary'} px-2 py-1 small">Đổi Đường</span>
                                    </td>
                                    <td class="text-center">
                                        <c:if test="${item.isNew}">
                                            <span class="badge bg-warning text-dark fw-bold border border-warning px-2.5 py-1">MỚI ✨</span>
                                        </c:if>
                                        <c:if test="${item.isBestseller}">
                                            <span class="badge bg-danger text-white fw-bold border border-danger px-2.5 py-1 ms-1">HOT 🔥</span>
                                        </c:if>
                                        <c:if test="${not item.isNew && !item.isBestseller}">
                                            <span class="text-muted small">-</span>
                                        </c:if>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThai}">
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 badge-status">
                                                        <i class="bi bi-check-circle-fill me-1"></i> Đang mở bán
                                                    </span>
                                            </c:when>
                                            <c:otherwise>
                                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1.5 badge-status">
                                                        <i class="bi bi-x-circle-fill me-1"></i> Đã đóng bán
                                                    </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <a href="${pageContext.request.contextPath}/admin/sanpham?action=edit&id=${item.maSp}" class="btn btn-sm btn-outline-primary fw-semibold px-2.5">
                                                <i class="bi bi-gear-fill"></i> Cấu hình
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold px-2.5" onclick="confirmDeleteSanPham('${item.maSp}')">
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
                                    <i class="bi bi-cup-hot fs-1 d-block mb-2"></i>
                                    Hệ thống chưa lưu vết sản phẩm đồ uống nào!
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    // Áp dụng Soft Delete (Xóa mềm - Chuyển trạng thái hoạt động về 0) để bảo toàn báo cáo doanh thu tài chính [2]
    function confirmDeleteSanPham(maSp) {
        Swal.fire({
            title: 'Xóa mềm sản phẩm?',
            text: "Hệ thống sẽ chuyển trạng thái của sản phẩm về 'Ngừng hoạt động' nhằm bảo toàn lịch sử hóa đơn tài chính của quầy [2]!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa mềm',
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

        if (msg === 'createsuccess') showToast('success', 'Thêm mới trà sữa thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu cấu hình biến thể giá & kích cỡ sản phẩm!');
        if (msg === 'deletesuccess') showToast('success', 'Xóa mềm sản phẩm thành công!');
        if (msg === 'deletefailed') {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi thực thi!',
                text: 'Không thể xóa do ràng buộc dữ liệu tại CSDL SQL Server!',
                confirmButtonColor: '#2e7d32'
            });
        }
    });
</script>
</body>
</html>