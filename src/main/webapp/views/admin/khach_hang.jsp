<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <!-- Khởi tạo các biến an toàn để phòng tránh NullPointerException và lỗi PropertyNotFound trên Tomcat 11 / EL 6.0 -->
    <c:set var="maKh" value="" />
    <c:set var="tenKh" value="" />
    <c:set var="soDienThoai" value="" />
    <c:set var="email" value="" />
    <c:set var="ngaySinh" value="" />
    <c:set var="gioiTinh" value="Nam" />
    <c:set var="diaChiLienHe" value="" />
    <c:set var="hinhAnhUrl" value="" />
    <c:set var="diemTichLuy" value="0" />
    <c:set var="maHang" value="1" />
    <c:set var="trangThai" value="true" />

    <c:if test="${not empty customer}">
        <c:set var="maKh" value="${customer.maKh}" />
        <c:set var="tenKh" value="${customer.tenKh}" />
        <c:set var="soDienThoai" value="${customer.soDienThoai}" />
        <c:set var="email" value="${customer.email}" />
        <c:set var="ngaySinh" value="${customer.ngaySinh}" />
        <c:set var="gioiTinh" value="${customer.gioiTinh}" />
        <c:set var="diaChiLienHe" value="${customer.diaChiLienHe}" />
        <c:set var="hinhAnhUrl" value="${customer.hinhAnhUrl}" />
        <c:set var="diemTichLuy" value="${customer.diemTichLuy}" />
        <c:set var="maHang" value="${customer.maHang}" />
        <c:set var="trangThai" value="${customer.isTrangThai()}" />
    </c:if>

    <title>TEA POS - Quản Lý Hồ Sơ Khách Hàng CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <!-- Sidebar -->
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <!-- Nhập Header chuẩn ở đây, tuyệt đối không lồng trong <head> -->
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <c:choose>
                <%-- ==================== TRƯỜNG HỢP 1: HIỂN THỊ CHI TIẾT TABS KHÁCH HÀNG CRM ==================== --%>
                <c:when test="${not empty customer}">
                    <div class="mb-3">
                        <a href="${pageContext.request.contextPath}/admin/khachhang" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1">
                            <i class="bi bi-arrow-left"></i> Quay lại danh sách CRM
                        </a>
                    </div>
                    <div class="row g-4">
                        <!-- Khung thông tin nhanh bên trái -->
                        <div class="col-12 col-lg-4">
                            <div class="card card-teapos p-4 text-center">
                                <img src="${not empty hinhAnhUrl ? hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
                                     class="rounded-circle border border-4 border-success mx-auto mb-3" style="width: 120px; height: 120px; object-fit: cover;">
                                <h4 class="fw-bold mb-1 text-dark"><c:out value="${tenKh}"/></h4>
                                <span class="badge bg-success-subtle text-success border border-success px-3 py-1.5 fs-6 mb-3">
                                    👑 Hạng:
                                    <c:choose>
                                        <c:when test="${maHang == 1}">ĐỒNG</c:when>
                                        <c:when test="${maHang == 2}">BẠC</c:when>
                                        <c:when test="${maHang == 3}">VÀNG 👑</c:when>
                                        <c:when test="${maHang == 4}">VIP 💎</c:when>
                                        <c:otherwise>MỚI</c:otherwise>
                                    </c:choose>
                                </span>
                                <div class="bg-light rounded p-3 text-start">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted small">Mã thành viên:</span>
                                        <strong class="text-dark">${maKh}</strong>
                                    </div>
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted small">Điểm tích lũy:</span>
                                        <strong class="text-success">${diemTichLuy} điểm</strong>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span class="text-muted small">Trạng thái:</span>
                                        <span class="fw-bold ${trangThai ? 'text-success' : 'text-danger'}">
                                                ${trangThai ? 'Đang hoạt động' : 'Tạm khóa'}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Khối thông tin chi tiết Tabs bên phải -->
                        <div class="col-12 col-lg-8">
                            <div class="card card-teapos p-4">
                                <!-- Danh mục Tabs liên kết -->
                                <ul class="nav nav-tabs nav-tabs-teapos mb-4" id="crmDetailTab" role="tablist">
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link active" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile" type="button" role="tab">Hồ sơ cá nhân</button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link" id="orders-tab" data-bs-toggle="tab" data-bs-target="#orders" type="button" role="tab">Lịch sử hóa đơn</button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link" id="vouchers-tab" data-bs-toggle="tab" data-bs-target="#vouchers" type="button" role="tab">Kho Voucher khả dụng</button>
                                    </li>
                                </ul>
                                <div class="tab-content" id="crmDetailTabContent">
                                    <!-- TAB 1: THÔNG TIN CHI TIẾT & SỬA ĐỔI HỒ SƠ -->
                                    <div class="tab-pane fade show active" id="profile" role="tabpanel">
                                        <form action="${pageContext.request.contextPath}/admin/khachhang" method="POST">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="maKh" value="${maKh}">
                                            <div class="row g-3">
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Họ và tên khách hàng</label>
                                                    <input type="text" name="tenKh" class="form-control form-control-teapos" value="${tenKh}" required>
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Số điện thoại di động</label>
                                                    <input type="text" name="soDienThoai" class="form-control form-control-teapos" value="${soDienThoai}" required>
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Địa chỉ Email</label>
                                                    <input type="email" name="email" class="form-control form-control-teapos" value="${email}" required>
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Ngày sinh</label>
                                                    <input type="date" name="ngaySinh" class="form-control form-control-teapos" value="${ngaySinh}">
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Giới tính</label>
                                                    <select name="gioiTinh" class="form-select form-control-teapos">
                                                        <option value="Nam" ${gioiTinh eq 'Nam' ? 'selected' : ''}>Nam</option>
                                                        <option value="Nữ" ${gioiTinh eq 'Nữ' ? 'selected' : ''}>Nữ</option>
                                                        <option value="Khác" ${gioiTinh eq 'Khác' ? 'selected' : ''}>Khác</option>
                                                    </select>
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label class="form-label fw-semibold text-muted small">Cấp hạng thành viên</label>
                                                    <select name="maHang" class="form-select form-control-teapos" disabled>
                                                        <option value="1" ${maHang == 1 ? 'selected' : ''}>Hạng Đồng</option>
                                                        <option value="2" ${maHang == 2 ? 'selected' : ''}>Hạng Bạc</option>
                                                        <option value="3" ${maHang == 3 ? 'selected' : ''}>Hạng Vàng</option>
                                                        <option value="4" ${maHang == 4 ? 'selected' : ''}>Hạng Kim Cương</option>
                                                    </select>
                                                </div>
                                                <div class="col-12">
                                                    <label class="form-label fw-semibold text-muted small">Địa chỉ liên hệ</label>
                                                    <textarea name="diaChiLienHe" class="form-control form-control-teapos" rows="2">${diaChiLienHe}</textarea>
                                                </div>
                                                <div class="col-12">
                                                    <label class="form-label fw-semibold text-muted small d-block">Trạng thái khóa tài khoản</label>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input" type="radio" name="trangThai" id="statusKhTrue" value="1" ${trangThai == 'true' || trangThai == true ? 'checked' : ''}>
                                                        <label class="form-check-label text-success fw-medium" for="statusKhTrue">Đang hoạt động</label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input" type="radio" name="trangThai" id="statusKhFalse" value="0" ${trangThai == 'false' || trangThai == false ? 'checked' : ''}>
                                                        <label class="form-check-label text-danger" for="statusKhFalse">Đang tạm khóa</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <button type="submit" class="btn btn-primary-teapos px-4 fw-bold mt-4">
                                                <i class="bi bi-save me-1"></i> Lưu thông tin CRM
                                            </button>
                                        </form>
                                    </div>
                                    <!-- TAB 2: LỊCH SỬ GIAO DỊCH -->
                                    <div class="tab-pane fade" id="orders" role="tabpanel">
                                        <div class="table-responsive">
                                            <table class="table table-hover table-teapos align-middle text-center">
                                                <thead>
                                                <tr class="table-light">
                                                    <th>Mã đơn</th>
                                                    <th>Thời gian đặt</th>
                                                    <th class="text-end">Tổng tiền hàng</th>
                                                    <th>Loại đơn</th>
                                                    <th>Trạng thái</th>
                                                </tr>
                                                </thead>
                                                <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty orders}">
                                                        <c:forEach var="ord" items="${orders}">
                                                            <tr>
                                                                <td><strong>${ord.maDh}</strong></td>
                                                                <td class="small"><fmt:formatDate value="${ord.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                                <td class="text-end fw-bold text-success">
                                                                    <fmt:formatNumber value="${ord.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                                </td>
                                                                <td>
                                                                        <span class="badge bg-light text-dark border">
                                                                                ${ord.loaiDonHang == 1 ? 'Tại quầy' : (ord.loaiDonHang == 2 ? 'Mang đi' : 'Đặt online')}
                                                                        </span>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${ord.trangThaiDon == 4}">
                                                                            <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1">Hoàn thành</span>
                                                                        </c:when>
                                                                        <c:when test="${ord.trangThaiDon == 5}">
                                                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1">Đã hủy</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="badge bg-warning bg-opacity-10 text-warning border border-warning px-3 py-1">Đang xử lý</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="5" class="text-center py-4 text-muted">Khách hàng chưa thực hiện bất kỳ giao dịch nào!</td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    <!-- TAB 3: VOUCHER VIP KHẢ DỤNG -->
                                    <div class="tab-pane fade" id="vouchers" role="tabpanel">
                                        <div class="row g-3">
                                            <c:choose>
                                                <c:when test="${not empty vouchers}">
                                                    <c:forEach var="v" items="${vouchers}">
                                                        <div class="col-12 col-md-6">
                                                            <div class="border rounded p-3 bg-light d-flex justify-content-between align-items-center">
                                                                <div>
                                                                    <span class="badge bg-dark text-white fw-bold mb-1">${v.maCode}</span>
                                                                    <h6 class="fw-bold mb-1 text-success"><c:out value="${v.tenKm}"/></h6>
                                                                    <small class="text-muted d-block" style="font-size: 11px;">HSD: <fmt:formatDate value="${v.ngayKetThuc}" pattern="dd/MM/yyyy"/></small>
                                                                </div>
                                                                <div class="text-end">
                                                                    <strong class="text-danger small">Giảm tối đa: <br><fmt:formatNumber value="${v.giamToiDa}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="col-12 text-center py-4 text-muted">
                                                        Không có Voucher khuyến mãi VIP nào đủ điều kiện áp dụng cho hạng thẻ hiện tại của khách hàng.
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>
                <%-- ==================== TRƯỜNG HỢP 2: HIỂN THỊ DANH SÁCH KHÁCH HÀNG (LIST) ==================== --%>
                <c:otherwise>
                    <div class="card card-teapos p-4 border-0 shadow-sm">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h3 class="fw-bold mb-1" style="color: var(--primary-color);">HỆ THỐNG KHÁCH HÀNG CRM</h3>
                                <p class="text-muted small mb-0">Quản lý cơ sở dữ liệu thành viên, theo dõi ví điểm thưởng và phân hạng Loyalty</p>
                            </div>
                        </div>
                        <!-- Bảng dữ liệu CRM -->
                        <div class="table-responsive">
                            <table class="table table-hover table-teapos align-middle text-center">
                                <thead>
                                <tr class="table-light">
                                    <th>Mã KH</th>
                                    <th class="text-start">Họ và tên thành viên</th>
                                    <th>Số điện thoại</th>
                                    <th>Địa chỉ Email</th>
                                    <th>Hạng thẻ</th>
                                    <th>Ví Điểm Tích Lũy</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end" style="width: 150px;">Hành động</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty customers}">
                                        <c:forEach var="item" items="${customers}">
                                            <tr>
                                                <td><strong>${item.maKh}</strong></td>
                                                <td class="text-start">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <img src="${not empty item.hinhAnhUrl ? item.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}"
                                                             class="rounded-circle border" style="width: 32px; height: 32px; object-fit: cover;">
                                                        <strong><c:out value="${item.tenKh}"/></strong>
                                                    </div>
                                                </td>
                                                <td>${item.soDienThoai}</td>
                                                <td>${item.email}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.maHang == 1}"><span class="badge bg-secondary">ĐỒNG</span></c:when>
                                                        <c:when test="${item.maHang == 2}"><span class="badge bg-light text-dark border">BẠC</span></c:when>
                                                        <c:when test="${item.maHang == 3}"><span class="badge bg-warning text-dark fw-bold">VÀNG 👑</span></c:when>
                                                        <c:when test="${item.maHang == 4}"><span class="badge bg-info text-white fw-bold">VIP 💎</span></c:when>
                                                        <c:otherwise><span class="badge bg-light text-dark">MỚI</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="fw-bold text-success">${item.diemTichLuy} điểm</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.trangThai}">
                                                            <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 small" style="border-radius: 50px;">Hoạt động</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-3 py-1.5 small" style="border-radius: 50px;">Đã Khóa</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/admin/khachhang?action=view&id=${item.maKh}" class="btn btn-sm btn-outline-success fw-bold px-2.5">
                                                        <i class="bi bi-eye-fill"></i> Chi tiết CRM
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" class="text-center py-5 text-muted">Không có thông tin khách hàng nào trên hệ thống!</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') showToast('success', 'Cập nhật hồ sơ khách hàng thành công!');
        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Lỗi đồng bộ',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>
