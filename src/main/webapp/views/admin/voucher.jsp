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
    <style>
        .form-card {
            border-radius: 12px;
            background: #ffffff;
            border: none;
        }
    </style>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px;">

                <c:choose>
                    <%-- ==================== TRƯỜNG HỢP 1: THÊM MỚI / CHỈNH SỬA VOUCHER FORM ==================== --%>
                    <c:when test="${not empty formTitle}">
                        <div class="mb-3">
                            <a href="${pageContext.request.contextPath}/admin/voucher" class="btn btn-sm btn-outline-secondary fw-bold" style="border-radius: 6px;">
                                <i class="bi bi-arrow-left"></i> Quay lại danh sách
                            </a>
                        </div>

                        <h4 class="fw-bold mb-4 text-success border-bottom pb-3">
                            <i class="bi bi-ticket-perforated-fill text-success me-2"></i> ${formTitle}
                        </h4>

                        <!-- ĐỒNG BỘ: Sử dụng direct EL `${...}` thay thế hoàn toàn cho <c:out> lồng HTML attribute để tránh lỗi quote Tomcat 11 -->
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="POST">
                            <input type="hidden" name="action" value="${not empty voucher ? 'edit' : 'create'}">

                            <div class="row g-3">
                                <div class="col-12 col-md-4">
                                    <label for="maKm" class="form-label fw-bold small">Mã Khuyến Mãi <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-teapos" id="maKm" name="maKm"
                                           value="${voucher.maKm}" ${not empty voucher ? 'readonly style="background-color: #e2e8f0; font-weight: bold;"' : ''}
                                           placeholder="Ví dụ: KM001..." required autocomplete="off">
                                </div>
                                <div class="col-12 col-md-4">
                                    <label for="maCode" class="form-label fw-bold small">Mã CODE áp dụng <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-teapos text-uppercase" id="maCode" name="maCode"
                                           value="${voucher.maCode}" placeholder="Ví dụ: GIAM20K..." required autocomplete="off" style="font-weight: 700; letter-spacing: 0.5px;">
                                </div>
                                <div class="col-12 col-md-4">
                                    <label for="tenKm" class="form-label fw-bold small">Tên Chiến Dịch Khuyến Mãi <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-teapos" id="tenKm" name="tenKm"
                                           value="${voucher.tenKm}" placeholder="Ví dụ: Tri ân khách hàng mới..." required autocomplete="off">
                                </div>

                                <div class="col-12 col-md-3">
                                    <label for="loaiGiam" class="form-label fw-bold small">Hình thức giảm giá</label>
                                    <select name="loaiGiam" id="loaiGiam" class="form-select form-control-teapos">
                                        <option value="1" ${voucher.loaiGiam == 1 ? 'selected' : ''}>Trừ tiền mặt (VNĐ)</option>
                                        <option value="2" ${voucher.loaiGiam == 2 ? 'selected' : ''}>Trừ phần trăm (%)</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="giaTriGiam" class="form-label fw-bold small">Giá trị giảm <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control form-control-teapos text-end fw-bold" id="giaTriGiam" name="giaTriGiam"
                                           value="${not empty voucher ? voucher.giaTriGiam : 0}" min="0" required>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="giamToiDa" class="form-label fw-bold small">Giảm tối đa (Phần trăm)</label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="giamToiDa" name="giamToiDa"
                                           value="${not empty voucher ? voucher.giamToiDa : 0}" min="0" placeholder="0 nếu không chặn...">
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="donToiThieu" class="form-label fw-bold small">Đơn tối thiểu áp dụng</label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="donToiThieu" name="donToiThieu"
                                           value="${not empty voucher ? voucher.donToiThieu : 0}" min="0">
                                </div>

                                <div class="col-12 col-md-6">
                                    <label for="ngayBatDau" class="form-label fw-bold small">Thời gian bắt đầu <span class="text-danger">*</span></label>
                                    <!-- Chuẩn hóa hiển thị datetime-local từ timestamp DB -->
                                    <c:set var="formattedStart" value=""/>
                                    <c:if test="${not empty voucher.ngayBatDau}">
                                        <c:set var="formattedStart" value="${voucher.ngayBatDau.toString().substring(0, 10)}T${voucher.ngayBatDau.toString().substring(11, 16)}"/>
                                    </c:if>
                                    <input type="datetime-local" class="form-control form-control-teapos" id="ngayBatDau" name="ngayBatDau"
                                           value="${formattedStart}" required>
                                </div>
                                <div class="col-12 col-md-6">
                                    <label for="ngayKetThuc" class="form-label fw-bold small">Thời gian kết thúc <span class="text-danger">*</span></label>
                                    <c:set var="formattedEnd" value=""/>
                                    <c:if test="${not empty voucher.ngayKetThuc}">
                                        <c:set var="formattedEnd" value="${voucher.ngayKetThuc.toString().substring(0, 10)}T${voucher.ngayKetThuc.toString().substring(11, 16)}"/>
                                    </c:if>
                                    <input type="datetime-local" class="form-control form-control-teapos" id="ngayKetThuc" name="ngayKetThuc"
                                           value="${formattedEnd}" required>
                                </div>

                                <div class="col-12 col-md-3">
                                    <label for="soLuong" class="form-label fw-bold small">Số lượng phát hành <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="soLuong" name="soLuong"
                                           value="${not empty voucher ? voucher.soLuong : 100}" min="0" required>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="isPublic" class="form-label fw-bold small">Phạm vi áp dụng</label>
                                    <select name="isPublic" id="isPublic" class="form-select form-control-teapos">
                                        <option value="1" ${voucher.isPublic ? 'selected' : ''}>Mã công khai (Mọi thành viên)</option>
                                        <option value="0" ${not empty voucher && not voucher.isPublic ? 'selected' : ''}>Mã riêng tư (VIP 👑)</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="trangThai" class="form-label fw-bold small">Trạng thái phát hành</label>
                                    <select name="trangThai" id="trangThai" class="form-select form-control-teapos">
                                        <option value="1" ${voucher.trangThai || empty voucher ? 'selected' : ''}>Đang kích hoạt (Khai hỏa)</option>
                                        <option value="0" ${not empty voucher && not voucher.trangThai ? 'selected' : ''}>Ngừng kích hoạt (Tạm tắt)</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="hinhAnhUrl" class="form-label fw-bold small">Ảnh minh họa (URL)</label>
                                    <input type="text" class="form-control form-control-teapos" id="hinhAnhUrl" name="hinhAnhUrl"
                                           value="${voucher.hinhAnhUrl}" placeholder="https://image-url...">
                                </div>

                                <div class="col-12">
                                    <label for="moTaDieuKien" class="form-label fw-bold small">Mô tả điều kiện áp dụng chi tiết</label>
                                    <textarea name="moTaDieuKien" id="moTaDieuKien" class="form-control" rows="2" placeholder="Ví dụ: Chỉ áp dụng cho ly size L vàng, hóa đơn tối thiểu 50k...">${voucher.moTaDieuKien}</textarea>
                                </div>

                                <div class="col-12 d-flex justify-content-end gap-2 border-top pt-3 mt-4">
                                    <a href="${pageContext.request.contextPath}/admin/voucher" class="btn btn-secondary-teapos px-4 py-2.5 fw-bold">HUỶ BỎ</a>
                                    <button type="submit" class="btn-teapos btn-primary-teapos px-5 py-2.5 fw-bold shadow-sm">
                                        <i class="bi bi-save me-1"></i> LƯU VOUCHER KHUYẾN MÃI
                                    </button>
                                </div>
                            </div>
                        </form>
                    </c:when>

                    <%-- ==================== TRƯỜNG HỢP 2: DANH SÁCH VOUCHER (LIST) ==================== --%>
                    <c:otherwise>
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h3 class="fw-bold mb-1" style="color: var(--primary-color);">QUẢN LÝ KHUYẾN MÃI - VOUCHER</h3>
                                <p class="text-muted small mb-0">Cấu hình các chiến dịch Marketing, băm mã giảm giá và ràng buộc mốc giá trị hóa đơn</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold">
                                <i class="bi bi-plus-circle-fill"></i> Tạo Mới Voucher KM
                            </a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                <tr class="table-light text-center">
                                    <th>Mã KM</th>
                                    <th>Mã Code</th>
                                    <th class="text-start">Tên Chương Trình</th>
                                    <th>Hình Thức Giảm</th>
                                    <th>Hạn Sử Dụng</th>
                                    <th>Số Lượng</th>
                                    <th>Phạm Vi</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end" style="width: 150px;">Hành Động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty vouchers}">
                                        <c:forEach var="item" items="${vouchers}">
                                            <tr class="text-center">
                                                <td><strong>${item.maKm}</strong></td>
                                                <td><span class="badge bg-dark text-white fw-bold px-3 py-1.5 fs-6" style="letter-spacing: 1px;"><c:out value="${item.maCode}"/></span></td>
                                                <td class="text-start">
                                                    <div class="fw-bold text-dark"><c:out value="${item.tenKm}"/></div>
                                                    <small class="text-muted d-block text-truncate" style="max-width: 250px;"><c:out value="${item.moTaDieuKien}"/></small>
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
                                                <td class="fw-bold text-dark">${item.soLuong} mã</td>
                                                <td>
<span class="badge ${item.isPublic ? 'bg-success bg-opacity-10 text-success' : 'bg-primary bg-opacity-10 text-primary'} border px-2.5 py-1.5">
        ${item.isPublic ? 'CÔNG KHAI' : 'HẠNG VIP 👑'}
</span>
                                                </td>
                                                <td>
<span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
        ${item.trangThai ? 'Đang chạy' : 'Ngừng chạy'}
</span>
                                                </td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-1.5">
                                                        <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${item.maKm}" class="btn btn-sm btn-outline-primary fw-semibold px-2.5">
                                                            Sửa
                                                        </a>
                                                        <button class="btn btn-sm btn-outline-danger px-2.5" onclick="confirmDeleteVoucher('${item.maKm}')">
                                                            Xóa
                                                        </button>
                                                    </div>
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
                    </c:otherwise>
                </c:choose>

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
            text: "Dữ liệu Voucher sẽ được đưa về ngừng hoạt động nhằm bảo lưu báo cáo hóa đơn cũ!",
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