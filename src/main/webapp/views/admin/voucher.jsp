<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Quản Lý Chương Trình Khuyến Mãi</title>
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
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ KHUYẾN MÃI - VOUCHER</h3>
                    <p class="text-muted small mb-0">Cấu hình các chiến dịch Marketing, băm mã giảm giá và ràng buộc mốc giá trị hóa đơn [4]</p>
                </div>
                <!-- Nút chuyển tới form Tạo mới Voucher -->
                <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2">
                    <i class="bi bi-plus-circle-fill"></i> Tạo Mới Voucher KM
                </a>
            </div>

            <!-- BẢNG LƯU TRỮ VOUCHER -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th>Mã KM</th>
                        <th>Mã Code</th>
                        <th>Tên Chương Trình</th>
                        <th>Hình Thức Giảm</th>
                        <th class="text-center">Hạn Sử Dụng</th>
                        <th class="text-center">Số Lượng</th>
                        <th class="text-center">Phạm Vi</th>
                        <th class="text-center">Trạng Thái</th>
                        <th class="text-end" style="width: 120px;">Hành Động</th>
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
                                        <small class="text-muted text-truncate d-block" style="max-width: 250px;">${item.moTaDieuKien}</small>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.loaiGiam == 1}">
                                                Giảm trực tiếp: <strong class="text-success"><fmt:formatNumber value="${item.giaTriGiam}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</strong>
                                            </c:when>
                                            <c:otherwise>
                                                Giảm theo tỉ lệ: <strong class="text-success">${item.giaTriGiam}%</strong> <br>
                                                <small class="text-muted">(Giảm tối đa: <fmt:formatNumber value="${item.giamToiDa}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ)</small>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center small">
                                        Từ: <fmt:formatDate value="${item.ngayBatDau}" pattern="dd/MM/yyyy HH:mm"/> <br>
                                        Đến: <fmt:formatDate value="${item.ngayKetThuc}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td class="text-center fw-bold text-dark">${item.soLuong} mã</td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.isPublic}">
                                                <span class="badge bg-light text-success border border-success px-2 py-1">CÔNG KHAI</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-primary border border-primary px-2 py-1">HẠNG VIP 👑</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThai}">
                                                <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 badge-status">Đang chạy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1.5 badge-status">Ngừng chạy</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${item.maKm}" class="btn btn-sm btn-outline-primary fw-semibold">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </a>
                                            <button class="btn btn-sm btn-outline-danger fw-semibold" onclick="confirmDeleteVoucher('${item.maKm}')">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" class="text-center py-5 text-muted">
                                    <i class="bi bi-ticket-perforated fs-1 d-block mb-2"></i>
                                    Hệ thống chưa tạo mã Voucher khuyến mãi nào!
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
    // Áp dụng xóa mềm Voucher [5]
    function confirmDeleteVoucher(maKm) {
        Swal.fire({
            title: 'Xác nhận xóa Voucher?',
            text: "Dữ liệu Voucher sẽ được tắt và đưa về trạng thái ngừng hoạt động để bảo lưu kết cấu hóa đơn cũ!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý tắt',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/voucher?action=delete&id=' + maKm;
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');

        if (msg === 'createsuccess') showToast('success', 'Thiết lập thành công chương trình ưu đãi mới!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu cấu hình chương trình Voucher!');
        if (msg === 'deletesuccess') showToast('success', 'Đã tắt hoạt động của mã Voucher thành công!');
    });
</script>
</body>
</html>