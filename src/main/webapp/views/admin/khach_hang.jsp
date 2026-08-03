<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
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
    <c:set var="trangThaiVal" value="true" />
    <c:if test="${not empty requestScope.customer}">
        <c:set var="maKh" value="${requestScope.customer.maKh}" />
        <c:set var="tenKh" value="${requestScope.customer.tenKh}" />
        <c:set var="soDienThoai" value="${requestScope.customer.soDienThoai}" />
        <c:set var="email" value="${requestScope.customer.email}" />
        <c:set var="ngaySinh" value="${requestScope.customer.ngaySinh}" />
        <c:set var="gioiTinh" value="${requestScope.customer.gioiTinh}" />
        <c:set var="diaChiLienHe" value="${requestScope.customer.diaChiLienHe}" />
        <c:set var="hinhAnhUrl" value="${requestScope.customer.hinhAnhUrl}" />
        <c:set var="diemTichLuy" value="${requestScope.customer.diemTichLuy}" />
        <c:set var="maHang" value="${requestScope.customer.maHang}" />
        <c:set var="trangThaiVal" value="${requestScope.customer.trangThai}" />
    </c:if>
    <title>TEA POS - Quản Lý Khách Hàng CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --bg-main: #f1f5f9;
            --border-color: #cbd5e1;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --radius-md: 8px;
        }
        .filter-wrapper {
            background-color: #ffffff !important;
            border: 1px solid var(--border-color) !important;
            border-radius: 12px !important;
            padding: 20px !important;
            box-shadow: var(--shadow-sm) !important;
        }
        .pagination-container {
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            padding: 16px 20px !important;
            background-color: #ffffff !important;
            border-top: 1px solid var(--border-color) !important;
        }
        .customer-img-circle {
            width: 38px;
            height: 38px;
            object-fit: cover;
            border-radius: 50%;
            border: 2px solid var(--primary);
            box-shadow: var(--shadow-sm);
        }
        .nav-tabs-teapos .nav-link.active {
            border-bottom: 3px solid var(--primary) !important;
            color: var(--primary) !important;
        }
    </style>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <c:choose>
                <%-- ==================== CASE 1: CRM DETAILS VIEW ==================== --%>
                <c:when test="${not empty requestScope.customer}">
                    <div class="mb-3 text-start">
                        <a href="${pageContext.request.contextPath}/admin/khachhang" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1.5 fw-bold" style="border-radius: 6px;">
                            <i class="bi bi-arrow-left"></i> Quay lại danh sách CRM
                        </a>
                    </div>
                    <div class="row g-4 text-start">
                        <div class="col-12 col-lg-4">
                            <div class="card card-teapos p-4 text-center bg-white shadow-sm" style="border-radius: 12px; border: 1px solid var(--border-color);">
                                <img src="${not empty hinhAnhUrl && hinhAnhUrl ne 'None' ? hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="rounded-circle border border-4 border-success mx-auto mb-3" style="width: 120px; height: 120px; object-fit: cover;">
                                <h4 class="fw-bold mb-1 text-dark"><c:out value="${tenKh}"/></h4>
                                <span class="badge bg-success bg-opacity-10 text-success border border-success px-3 py-1.5 fs-6 mb-3" style="border-radius: 50px;">
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
                                        <span class="fw-bold ${trangThaiVal ? 'text-success' : 'text-danger'}">
                                                ${trangThaiVal ? 'Đang hoạt động' : 'Tạm khóa'}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-lg-8">
                            <div class="card card-teapos p-4 bg-white shadow-sm" style="border-radius: 12px; border: 1px solid var(--border-color);">
                                <ul class="nav nav-tabs nav-tabs-teapos mb-4" id="crmDetailTab" role="tablist">
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link active fw-bold text-success border-0 bg-transparent" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile" type="button" role="tab">Hồ sơ cá nhân</button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link fw-bold text-success border-0 bg-transparent" id="orders-tab" data-bs-toggle="tab" data-bs-target="#orders" type="button" role="tab" onclick="initOrderPagination()">Lịch sử hóa đơn</button>
                                    </li>
                                    <li class="nav-item" role="presentation">
                                        <button class="nav-link fw-bold text-success border-0 bg-transparent" id="vouchers-tab" data-bs-toggle="tab" data-bs-target="#vouchers" type="button" role="tab">Kho Voucher khả dụng</button>
                                    </li>
                                </ul>
                                <div class="tab-content text-start" id="crmDetailTabContent">
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
                                                    <label class="form-label fw-semibold text-muted small">Ngày sinh nhật</label>
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
                                                    <label class="form-label fw-semibold text-muted small">Cấp hạng thành viên (Tính động)</label>
                                                    <select name="maHang" class="form-select form-control-teapos bg-light" disabled>
                                                        <option value="1" ${maHang == 1 ? 'selected' : ''}>Hạng Đồng</option>
                                                        <option value="2" ${maHang == 2 ? 'selected' : ''}>Hạng Bạc</option>
                                                        <option value="3" ${maHang == 3 ? 'selected' : ''}>Hạng Vàng</option>
                                                        <option value="4" ${maHang == 4 ? 'selected' : ''}>Hạng Kim Cương / VIP</option>
                                                    </select>
                                                </div>
                                                <div class="col-12">
                                                    <label class="form-label fw-semibold text-muted small">Địa chỉ liên hệ</label>
                                                    <textarea name="diaChiLienHe" class="form-control form-control-teapos" rows="2">${diaChiLienHe}</textarea>
                                                </div>
                                                <div class="col-12">
                                                    <label class="form-label fw-semibold text-muted small d-block">Trạng thái tài khoản</label>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input" type="radio" name="trangThai" id="statusKhTrue" value="1" ${trangThaiVal == 'true' || trangThaiVal == true ? 'checked' : ''}>
                                                        <label class="form-check-label text-success fw-medium" for="statusKhTrue">Đang hoạt động</label>
                                                    </div>
                                                    <div class="form-check form-check-inline">
                                                        <input class="form-check-input" type="radio" name="trangThai" id="statusKhFalse" value="0" ${trangThaiVal == 'false' || trangThaiVal == false ? 'checked' : ''}>
                                                        <label class="form-check-label text-danger" for="statusKhFalse">Đang tạm khóa</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <button type="submit" class="btn btn-success px-4 fw-bold mt-4" style="border-radius: 8px;">
                                                <i class="bi bi-save me-1"></i> Lưu thông tin CRM
                                            </button>
                                        </form>
                                    </div>
                                    <div class="tab-pane fade" id="orders" role="tabpanel">
                                        <div class="table-responsive">
                                            <table class="table table-hover align-middle text-center" id="customerOrdersTable">
                                                <thead>
                                                <tr class="table-light">
                                                    <th>Mã đơn</th>
                                                    <th>Thời gian đặt</th>
                                                    <th class="text-end">Tổng phải trả</th>
                                                    <th>Loại đơn</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                                </thead>
                                                <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty orders}">
                                                        <c:forEach var="ord" items="${orders}">
                                                            <tr class="order-sub-row">
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
                                                                <td>
                                                                    <button type="button" class="btn btn-sm btn-outline-success fw-bold" onclick="showReceiptDetail('${ord.maDh}')">
                                                                        <i class="bi bi-eye"></i> Xem chi tiết
                                                                    </button>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="6" class="text-center py-4 text-muted">Khách hàng chưa thực hiện bất kỳ giao dịch nào!</td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="pagination-container" id="orderSubPaginationBlock" style="display: none;">
                                            <span class="small text-muted" id="orderSubPaginationInfo">Hiển thị từ 1 đến 5 của 5 hóa đơn</span>
                                            <nav>
                                                <ul class="pagination pagination-sm mb-0 justify-content-end" id="orderSubPaginationButtons"></ul>
                                            </nav>
                                        </div>
                                    </div>
                                    <div class="tab-pane fade" id="vouchers" role="tabpanel">
                                        <div class="row g-3">
                                            <c:choose>
                                                <c:when test="${not empty vouchers}">
                                                    <c:forEach var="v" items="${vouchers}">
                                                        <div class="col-12 col-md-6">
                                                            <div class="border rounded p-3 bg-light d-flex justify-content-between align-items-center" style="border-radius: 8px;">
                                                                <div class="text-start">
                                                                    <span class="badge bg-dark text-white fw-bold mb-1">${v.maCode}</span>
                                                                    <h6 class="fw-bold text-success mb-1"><c:out value="${v.tenKm}"/></h6>
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
                <%-- ==================== CASE 2: MAIN LIST VIEW ==================== --%>
                <c:otherwise>
                    <div class="card card-teapos p-4 border-0 shadow-sm" style="border-radius: 12px; background-color: #ffffff;">
                        <div class="d-flex justify-content-between align-items-center mb-4 text-start">
                            <div>
                                <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-people-fill me-2"></i>HỆ THỐNG KHÁCH HÀNG CRM</h3>
                                <p class="text-muted small mb-0">Quản lý hội viên CRM và ví điểm tích lũy.</p>
                            </div>
                        </div>
                        <div class="filter-wrapper mb-4 text-start">
                            <div class="row g-3">
                                <div class="col-12 col-md-4">
                                    <label class="form-label fw-bold text-muted small"><i class="bi bi-search"></i> Tra cứu nhanh</label>
                                    <input type="text" id="customerSearchInput" class="form-control form-control-teapos bg-light" placeholder="Tìm tên, số điện thoại, hoặc email..." onkeyup="filterAndPaginateCustomers()">
                                </div>
                                <div class="col-6 col-md-3">
                                    <label class="form-label fw-bold text-muted small"><i class="bi bi-gem"></i> Hạng thành viên</label>
                                    <select id="filterRank" class="form-select form-control-teapos bg-light" onchange="filterAndPaginateCustomers()">
                                        <option value="">-- Tất cả các hạng --</option>
                                        <option value="1">ĐỒNG</option>
                                        <option value="2">BẠC</option>
                                        <option value="3">VÀNG 👑</option>
                                        <option value="4">VIP 💎</option>
                                    </select>
                                </div>
                                <div class="col-6 col-md-3">
                                    <label class="form-label fw-bold text-muted small"><i class="bi bi-toggle-on"></i> Trạng thái</label>
                                    <select id="filterStatus" class="form-select form-control-teapos bg-light" onchange="filterAndPaginateCustomers()">
                                        <option value="">-- Tất cả trạng thái --</option>
                                        <option value="1">Hoạt động</option>
                                        <option value="0">Đã Khóa</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-2 d-flex align-items-end">
                                    <button class="btn btn-secondary-teapos w-100 py-2 fw-bold" onclick="resetCustomerFilters()"><i class="bi bi-arrow-counterclockwise"></i> Reset</button>
                                </div>
                            </div>
                        </div>
                        <!-- VIEW 1: DESKTOP LAYOUT -->
                        <div class="d-none d-lg-block table-responsive admin-table-container">
                            <table class="table table-hover align-middle text-center admin-table" id="customerTable">
                                <thead>
                                <tr class="table-light">
                                    <th style="width: 80px;">STT</th>
                                    <th style="width: 100px;">Mã KH</th>
                                    <th class="text-start">Họ và tên thành viên</th>
                                    <th>Số điện thoại</th>
                                    <th>Địa chỉ Email</th>
                                    <th>Hạng thẻ</th>
                                    <th>Ví Điểm CRM</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end" style="width: 150px;">Hành động</th>
                                </tr>
                                </thead>
                                <tbody id="customerTableBody">
                                <c:choose>
                                    <c:when test="${not empty customers}">
                                        <c:forEach var="item" items="${customers}" varStatus="loop">
                                            <tr class="customer-row text-center" data-id="${item.maKh}" data-name="<c:out value="${item.tenKh}"/>" data-phone="${item.soDienThoai}" data-email="${item.email}" data-rank="${item.maHang}" data-status="${item.trangThai ? '1' : '0'}">
                                                <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                                <td><strong>${item.maKh}</strong></td>
                                                <td class="text-start">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <img src="${not empty item.hinhAnhUrl && item.hinhAnhUrl ne 'None' ? item.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="customer-img-circle shadow-sm" alt="Pic">
                                                        <strong><c:out value="${item.tenKh}"/></strong>
                                                    </div>
                                                </td>
                                                <td>${item.soDienThoai}</td>
                                                <td>${item.email}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.maHang == 1}"><span class="badge bg-secondary px-2.5 py-1.5" style="border-radius: 6px; font-size:11px;">ĐỒNG</span></c:when>
                                                        <c:when test="${item.maHang == 2}"><span class="badge bg-light text-dark border px-2.5 py-1.5" style="border-radius: 6px; font-size:11px;">BẠC</span></c:when>
                                                        <c:when test="${item.maHang == 3}"><span class="badge bg-warning text-dark fw-bold px-2.5 py-1.5" style="border-radius: 6px; font-size:11px;">VÀNG 👑</span></c:when>
                                                        <c:when test="${item.maHang == 4}"><span class="badge bg-info text-white fw-bold px-2.5 py-1.5" style="border-radius: 6px; font-size:11px;">VIP 💎</span></c:when>
                                                        <c:otherwise><span class="badge bg-light text-dark px-2.5 py-1.5" style="font-size:11px;">MỚI</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="fw-bold text-success font-monospace">${item.diemTichLuy} Điểm</td>
                                                <td>
                                                        <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                                ${item.trangThai ? 'Hoạt động' : 'Đã Khóa'}
                                                        </span>
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/admin/khachhang?action=view&id=${item.maKh}" class="btn btn-sm btn-outline-success fw-bold px-2.5">
                                                        <i class="bi bi-eye-fill"></i> Chi tiết
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="9" class="text-center py-5 text-muted">Không có thông tin khách hàng nào trên hệ thống!</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                        <!-- VIEW 2: MOBILE LAYOUT -->
                        <div class="d-block d-lg-none" id="customerMobileCards">
                            <c:choose>
                                <c:when test="${not empty customers}">
                                    <c:forEach var="item" items="${customers}" varStatus="loop">
                                        <div class="customer-card-col mb-3" data-id="${item.maKh}" data-name="<c:out value="${item.tenKh}"/>" data-phone="${item.soDienThoai}" data-email="${item.email}" data-rank="${item.maHang}" data-status="${item.trangThai ? '1' : '0'}">
                                            <div class="card p-3 border shadow-sm position-relative text-start" style="border-radius: 12px; background: #ffffff; border-color: var(--border-color) !important;">
                                                <div class="position-absolute" style="top: 15px; right: 15px; cursor: pointer; z-index: 10;" onclick="toggleMobileCardDetails(this)">
                                                    <span class="badge bg-light rounded-circle text-success d-flex align-items-center justify-content-center border" style="width: 28px; height: 28px; border-color: var(--border-color) !important;">
                                                        <i class="bi bi-chevron-down fs-6"></i>
                                                    </span>
                                                </div>
                                                <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 pe-4">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="badge bg-light text-success rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-weight: bold; border: 1px solid var(--border-color);">
                                                                ${loop.index + 1}
                                                        </span>
                                                        <code class="fw-bold text-dark font-monospace">${item.maKh}</code>
                                                    </div>
                                                    <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-2.5 py-1" style="border-radius: 50px; font-size: 11px;">
                                                            ${item.trangThai ? 'Hoạt động' : 'Đã khóa'}
                                                    </span>
                                                </div>
                                                <div class="d-flex align-items-center gap-3">
                                                    <img src="${not empty item.hinhAnhUrl && item.hinhAnhUrl ne 'None' ? item.hinhAnhUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="customer-img-circle shadow-sm" alt="Pic">
                                                    <div>
                                                        <h6 class="fw-bold text-dark mb-1"><c:out value="${item.tenKh}"/></h6>
                                                        <div>
                                                            <c:choose>
                                                                <c:when test="${item.maHang == 1}"><span class="badge bg-secondary p-1" style="font-size: 9px; border-radius: 4px;">ĐỒNG</span></c:when>
                                                                <c:when test="${item.maHang == 2}"><span class="badge bg-light text-dark border p-1" style="font-size: 9px; border-radius: 4px;">BẠC</span></c:when>
                                                                <c:when test="${item.maHang == 3}"><span class="badge bg-warning text-dark fw-bold p-1" style="font-size: 9px; border-radius: 4px;">VÀNG 👑</span></c:when>
                                                                <c:when test="${item.maHang == 4}"><span class="badge bg-info text-white fw-bold p-1" style="font-size: 9px; border-radius: 4px;">VIP 💎</span></c:when>
                                                            </c:choose>
                                                            <span class="text-success font-monospace fw-bold ms-1" style="font-size: 12px;">${item.diemTichLuy}đ</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="mobile-card-details border-top pt-2 mt-2 text-start small d-none" style="line-height: 1.6;">
                                                    <div class="text-muted d-flex justify-content-between">
                                                        <span>Số điện thoại:</span>
                                                        <strong class="text-dark">${item.soDienThoai}</strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Địa chỉ Email:</span>
                                                        <strong class="text-dark">${item.email}</strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Địa chỉ liên hệ:</span>
                                                        <strong class="text-dark text-wrap text-end" style="max-width: 60%;">${not empty item.diaChiLienHe ? item.diaChiLienHe : 'Chưa thiết lập'}</strong>
                                                    </div>
                                                </div>
                                                <div class="d-flex gap-2 border-top pt-2 mt-2">
                                                    <a href="${pageContext.request.contextPath}/admin/khachhang?action=view&id=${item.maKh}" class="btn btn-success btn-sm w-100 fw-bold py-2" style="border-radius: 8px;">
                                                        <i class="bi bi-eye-fill"></i> Xem chi tiết hồ sơ CRM
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5 text-muted bg-white rounded-3 border">Không tìm thấy thông tin khách hàng!</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <!-- PHÂN TRANG -->
                        <div class="pagination-container" id="paginationWrapper" style="display: none;">
                            <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 của 10 dòng khách hàng</span>
                            <nav>
                                <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                            </nav>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- RECEIPT MODAL -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; font-size: 11px; line-height: 1.5; text-align: left;">
                <div class="text-center mb-2">
                    <strong style="font-size: 15px; letter-spacing: 0.5px; text-align: center; display: block;">TEA POS CAFÉ</strong>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px; text-align: center; display: block;">HÓA ĐƠN CHI TIẾT</strong>
                    <span style="font-size: 9px; text-align: center; display: block;" id="billThoiGian"></span>
                </div>
                <div class="mb-2" style="font-size: 10px;">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Hình thức: <span id="billLoaiDon" class="fw-bold text-uppercase"></span></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                    <div>SĐT Khách: <span id="billSdtKh"></span></div>
                    <div>Hình thức TT: <span id="billPhuongThucTT" class="fw-bold"></span></div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer" style="font-size: 10px;"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="small" style="font-size: 10px;">
                    <div class="d-flex justify-content-between">
                        <span>Tổng tiền hàng:</span>
                        <strong id="billRawPrice"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger" id="billDiscountRow" style="display: none;">
                        <span>Voucher giảm giá:</span>
                        <strong id="billDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-primary" id="billPointsRow" style="display: none;">
                        <span>Tiêu điểm CRM:</span>
                        <strong id="billPointsDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span>Thuế VAT (8%):</span>
                        <strong id="billVatPrice"></strong>
                    </div>
                    <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                    <div class="d-flex justify-content-between fw-bold text-success fs-6" style="font-size: 12px;">
                        <span>THỰC THU (VNĐ):</span>
                        <span id="billFinalPayable"></span>
                    </div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="text-center mt-3" style="font-size: 9px; color: #444; text-align: center;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br>
                    <i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-secondary fw-bold" data-bs-dismiss="modal" style="font-size: 11px;">Đóng</button>
                <button type="button" class="btn btn-sm btn-success fw-bold" onclick="printReceipt()" style="font-size: 11px;"><i class="bi bi-printer"></i> In Ngay</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const receiptModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));
    function showReceiptDetail(maDh) {
        document.getElementById("billItemsContainer").innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success" role="status"></div><p class="small text-muted mt-2">Đang tải hóa đơn...</p></div>';
        receiptModal.show();
        fetch('${pageContext.request.contextPath}/admin/hoadon?action=detailJson&id=' + maDh)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById("billMaDh").innerText = data.maDh;
                    document.getElementById("billThoiGian").innerText = data.thoiGianTao;
                    document.getElementById("billTenKh").innerText = data.tenKhachHang ? data.tenKhachHang : 'Khách lẻ vãng lai';
                    document.getElementById("billSdtKh").innerText = data.sdtKhachHang ? data.sdtKhachHang : 'N/A';
                    document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Hệ thống tự động';
                    document.getElementById("billPhuongThucTT").innerText = data.tenPhuongThucTT ? data.tenPhuongThucTT : 'Tiền mặt';
                    document.getElementById("billLoaiDon").innerText = data.loaiDonHang ? data.loaiDonHang : 'Tại quầy';
                    document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';
                    if (data.tienGiamGia > 0) {
                        document.getElementById("billDiscountRow").style.display = 'flex';
                    } else {
                        document.getElementById("billDiscountRow").style.display = 'none';
                    }
                    if (data.diemSuDung > 0) {
                        document.getElementById("billPointsRow").style.display = 'flex';
                        document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                    } else {
                        document.getElementById("billPointsRow").style.display = 'none';
                    }
                    let billBeforeTax = data.tongTienHang - data.tienGiamGia - data.tienTruDiem;
                    if (billBeforeTax < 0) billBeforeTax = 0;
                    let vatPrice = Math.round(billBeforeTax * 0.08);
                    document.getElementById("billVatPrice").innerText = vatPrice.toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';
                    let container = document.getElementById("billItemsContainer");
                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div style="margin-bottom: 8px; border-bottom: 1px dashed #eee; padding-bottom: 4px; text-align: left;">';
                        html += '  <div class="d-flex justify-content-between">';
                        html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                        html += '    <strong>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</strong>';
                        html += '  </div>';
                        html += '  <small style="font-size: 9px; color: #555;">Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + '</small>';
                        if (item.toppings && item.toppings.length > 0) {
                            html += '  <div class="ps-2 small text-muted">';
                            item.toppings.forEach(tp => {
                                html += '<div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                            });
                            html += '  </div>';
                        }
                        html += '</div>';
                        container.innerHTML += html;
                    });
                } else {
                    showToast('error', 'Không tìm thấy hóa đơn!');
                    receiptModal.hide();
                }
            })
            .catch(err => {
                console.error("Lỗi:", err);
                showToast('error', 'Không thể nạp dữ liệu từ máy chủ!');
                receiptModal.hide();
            });
    }
    function printReceipt() {
        const printContent = document.getElementById("billPrintArea").innerHTML;
        const originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload();
    }
    function toggleMobileCardDetails(element) {
        const card = element.closest('.card');
        const details = card.querySelector('.mobile-card-details');
        const icon = element.querySelector('i');
        if (details.classList.contains('d-none')) {
            details.classList.remove('d-none');
            icon.className = 'bi bi-chevron-up fs-6';
        } else {
            details.classList.add('d-none');
            icon.className = 'bi bi-chevron-down fs-6';
        }
    }
    let currentCrmPage = 1;
    const ROWS_PER_PAGE_CRM = 10;
    let filteredCrmRows = [];
    let filteredCrmCards = [];
    function filterAndPaginateCustomers() {
        const searchInput = document.getElementById("customerSearchInput");
        if (!searchInput) return;
        const filterRank = document.getElementById("filterRank");
        const filterStatus = document.getElementById("filterStatus");
        const searchVal = searchInput.value.trim().toLowerCase();
        const rankVal = filterRank.value;
        const statusVal = filterStatus.value;
        const allRows = Array.from(document.querySelectorAll("#customerTableBody .customer-row"));
        filteredCrmRows = allRows.filter(row => {
            const name = row.dataset.name.toLowerCase();
            const phone = row.dataset.phone;
            const email = row.dataset.email.toLowerCase();
            const id = row.dataset.id.toLowerCase();
            const rank = row.dataset.rank;
            const status = row.dataset.status;
            const matchSearch = name.includes(searchVal) || phone.includes(searchVal) || email.includes(searchVal) || id.includes(searchVal);
            const matchRank = rankVal === "" || rank === rankVal;
            const matchStatus = statusVal === "" || status === statusVal;
            return matchSearch && matchRank && matchStatus;
        });
        const allCards = Array.from(document.querySelectorAll("#customerMobileCards .customer-card-col"));
        filteredCrmCards = allCards.filter(card => {
            const name = card.dataset.name.toLowerCase();
            const phone = card.dataset.phone;
            const email = card.dataset.email.toLowerCase();
            const id = card.dataset.id.toLowerCase();
            const rank = card.dataset.rank;
            const status = card.dataset.status;
            const matchSearch = name.includes(searchVal) || phone.includes(searchVal) || email.includes(searchVal) || id.includes(searchVal);
            const matchRank = rankVal === "" || rank === rankVal;
            const matchStatus = statusVal === "" || status === statusVal;
            return matchSearch && matchRank && matchStatus;
        });
        currentCrmPage = 1;
        renderCrmTableRows();
    }
    function renderCrmTableRows() {
        const allRows = document.querySelectorAll("#customerTableBody .customer-row");
        allRows.forEach(row => row.style.display = "none");
        const startIdx = (currentCrmPage - 1) * ROWS_PER_PAGE_CRM;
        const endIdx = startIdx + ROWS_PER_PAGE_CRM;
        const pageRows = filteredCrmRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });
        const allCards = document.querySelectorAll("#customerMobileCards .customer-card-col");
        allCards.forEach(card => card.style.setProperty('display', 'none', 'important'));
        const pageCards = filteredCrmCards.slice(startIdx, endIdx);
        pageCards.forEach(card => {
            card.style.setProperty('display', 'block', 'important');
        });
        updateCrmPaginationControls();
    }
    function updateCrmPaginationControls() {
        const totalRows = filteredCrmRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE_CRM) || 1;
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        if (!infoEl || !btnContainer) return;
        const start = totalRows > 0 ? (currentCrmPage - 1) * ROWS_PER_PAGE_CRM + 1 : 0;
        const end = Math.min(currentCrmPage * ROWS_PER_PAGE_CRM, totalRows);
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng khách hàng';
        btnContainer.innerHTML = "";
        const wrapper = document.getElementById("paginationWrapper");
        if (wrapper) {
            if (totalPages <= 1) {
                wrapper.style.setProperty('display', 'none', 'important');
                return;
            }
            wrapper.style.setProperty('display', 'flex', 'important');
        }
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentCrmPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changeCrmPage(' + (currentCrmPage - 1) + ')">&laquo; Trước</a>';
        btnContainer.appendChild(prevLi);
        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentCrmPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentCrmPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changeCrmPage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentCrmPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changeCrmPage(' + (currentCrmPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }
    function changeCrmPage(page) {
        const totalPages = Math.ceil(filteredCrmRows.length / ROWS_PER_PAGE_CRM) || 1;
        if (page < 1 || page > totalPages) return;
        currentCrmPage = page;
        renderCrmTableRows();
    }
    function resetCustomerFilters() {
        document.getElementById("customerSearchInput").value = "";
        document.getElementById("filterRank").selectedIndex = 0;
        document.getElementById("filterStatus").selectedIndex = 0;
        filterAndPaginateCustomers();
    }
    let currentSubPage = 1;
    const ROWS_PER_PAGE_SUB = 5;
    let subOrderRows = [];
    function initOrderPagination() {
        const orderTable = document.getElementById("customerOrdersTable");
        if (!orderTable) return;
        const orderRows = orderTable.querySelectorAll("tbody .order-sub-row");
        subOrderRows = Array.from(orderRows);
        currentSubPage = 1;
        renderSubOrderRows();
    }
    function renderSubOrderRows() {
        subOrderRows.forEach(row => row.style.display = "none");
        const startIdx = (currentSubPage - 1) * ROWS_PER_PAGE_SUB;
        const endIdx = startIdx + ROWS_PER_PAGE_SUB;
        const pageRows = subOrderRows.slice(startIdx, endIdx);
        pageRows.forEach(row => row.style.display = "table-row");
        updateSubPaginationControls();
    }
    function updateSubPaginationControls() {
        const totalRows = subOrderRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE_SUB) || 1;
        const infoEl = document.getElementById("orderSubPaginationInfo");
        const btnContainer = document.getElementById("orderSubPaginationButtons");
        if (!infoEl || !btnContainer) return;
        const start = totalRows > 0 ? (currentSubPage - 1) * ROWS_PER_PAGE_SUB + 1 : 0;
        const end = Math.min(currentSubPage * ROWS_PER_PAGE_SUB, totalRows);
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' trong tổng số ' + totalRows + ' hóa đơn đặt';
        btnContainer.innerHTML = "";
        const subBlock = document.getElementById("orderSubPaginationBlock");
        if (subBlock) {
            if (totalPages <= 1) {
                subBlock.style.setProperty('display', 'none', 'important');
                return;
            }
            subBlock.style.setProperty('display', 'flex', 'important');
        }
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentSubPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changeSubPage(' + (currentSubPage - 1) + ')">&laquo;</a>';
        btnContainer.appendChild(prevLi);
        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentSubPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentSubPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changeSubPage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentSubPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changeSubPage(' + (currentSubPage + 1) + ')">&raquo;</a>';
        btnContainer.appendChild(nextLi);
    }
    function changeSubPage(page) {
        const totalPages = Math.ceil(subOrderRows.length / ROWS_PER_PAGE_SUB) || 1;
        if (page < 1 || page > totalPages) return;
        currentSubPage = page;
        renderSubOrderRows();
    }
    document.addEventListener("DOMContentLoaded", function() {
        const isDetailView = ${not empty requestScope.customer ? 'true' : 'false'};
        if (isDetailView) {
            initOrderPagination();
        } else {
            filterAndPaginateCustomers();
        }
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') showToast('success', 'Cập nhật hồ sơ khách hàng thành công!');
    });
</script>
</body>
</html>