<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Chương Trình Khuyến Mãi</title>
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
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ KHUYẾN MÃI - VOUCHER</h3>
                        <p class="text-muted small mb-0">Cấu hình các chiến dịch Marketing, băm mã giảm giá và ràng buộc mốc giá trị hóa đơn [27]</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold">
                        <i class="bi bi-plus-circle-fill"></i> Tạo Mới Voucher KM
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
                            <th>Mã KM</th>
                            <th>Mã Code</th>
                            <th>Tên Chương Trình</th>
                            <th>Hình Thức Giảm</th>
                            <th class="text-center">Hạn Sử Dụng</th>
                            <th class="text-center">Số Lượng</th>
                            <th class="text-center">Phạm Vi</th>
                            <th class="text-center">Trạng Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty vouchers}">
                                <c:forEach var="item" items="${vouchers}">
                                    <tr>
                                        <td><strong>${item.maKm}</strong></td>
                                        <td><span class="badge bg-dark text-white fw-bold px-3 py-1.5 fs-6" style="letter-spacing: 1px;"><c:out value="${item.maCode}"/></span></td>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${item.tenKm}"/></div>
                                            <small class="text-muted d-block text-truncate" style="max-width: 250px;">${item.moTaDieuKien}</small>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.loaiGiam == 1}">
                                                    Giảm thẳng: <strong class="text-success"><fmt:formatNumber value="${item.giaTriGiam}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong>
                                                </c:when>
                                                <c:otherwise>
                                                    Giảm %: <strong class="text-success">${item.giaTriGiam}%</strong> <br>
                                                    <small class="text-muted">(Chặn: <fmt:formatNumber value="${item.giamToiDa}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ)</small>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small">
                                            Từ: <fmt:formatDate value="${item.ngayBatDau}" pattern="dd/MM HH:mm"/> <br>
                                            Đến: <fmt:formatDate value="${item.ngayKetThuc}" pattern="dd/MM HH:mm"/>
                                        </td>
                                        <td class="text-center fw-bold text-dark">${item.soLuong} mã</td>
                                        <td class="text-center">
                                                <span class="badge ${item.isPublic ? 'bg-success bg-opacity-10 text-success' : 'bg-primary bg-opacity-10 text-primary'} border px-2 py-1">
                                                        ${item.isPublic ? 'CÔNG KHAI' : 'HẠNG VIP 👑'}
                                                </span>
                                        </td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThai ? 'bg-success text-success' : 'bg-danger text-danger'} bg-opacity-10 border px-3 py-1.5">
                                                        ${item.trangThai ? 'Đang chạy' : 'Ngừng chạy'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${item.maKm}" class="btn btn-sm btn-outline-primary fw-semibold me-1">
                                                Sửa
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger" onclick="confirmDeleteVoucher('${item.maKm}')">
                                                Xóa
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="9" class="text-center py-5 text-muted">Hệ thống chưa tạo mã khuyến mãi nào!</td></tr>
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
    function confirmDeleteVoucher(maKm) {
        Swal.fire({
            title: 'Ngừng chạy Voucher?',
            text: "Dữ liệu Voucher sẽ được đưa về ngừng hoạt động nhằm bảo lưu báo cáo hóa đơn cũ [28]!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý ngừng',
            cancelButtonText: 'Hủy'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/voucher?action=delete&id=' + maKm;
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thiết lập Voucher mới thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã cập nhật chương trình Voucher!');
        if (msg === 'deletesuccess') showToast('success', 'Đã tắt Voucher thành công!');
    });
</script>
</body>
</html>