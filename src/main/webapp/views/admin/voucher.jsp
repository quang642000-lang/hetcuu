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
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .progress-voucher {
            height: 8px;
            border-radius: 5px;
            background-color: #e2e8f0;
            margin-top: 8px;
            margin-bottom: 4px;
        }
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            background-color: #ffffff;
            border-top: 1px solid #cbd5e1;
        }
    </style>
</head>
<body class="bg-light">
<c:set var="maKm" value="" />
<c:set var="maCode" value="" />
<c:set var="tenKm" value="" />
<c:set var="loaiGiam" value="1" />
<c:set var="giaTriGiam" value="0" />
<c:set var="giamToiDa" value="0" />
<c:set var="donToiThieu" value="0" />
<c:set var="soLuong" value="100" />
<c:set var="isPublic" value="true" />
<c:set var="trangThai" value="true" />
<c:set var="hinhAnhUrl" value="" />
<c:set var="moTaDieuKien" value="" />
<c:set var="soLuotDungCaNhan" value="0" />
<c:set var="hangApDung" value="1" />
<c:set var="loaiVoucher" value="1" />
<c:set var="formattedStart" value=""/>
<c:set var="formattedEnd" value=""/>

<c:if test="${not empty voucher}">
    <c:set var="maKm" value="${voucher.maKm}" />
    <c:set var="maCode" value="${voucher.maCode}" />
    <c:set var="tenKm" value="${voucher.tenKm}" />
    <c:set var="loaiGiam" value="${voucher.loaiGiam}" />
    <c:set var="giaTriGiam" value="${voucher.giaTriGiam}" />
    <c:set var="giamToiDa" value="${voucher.giamToiDa}" />
    <c:set var="donToiThieu" value="${voucher.donToiThieu}" />
    <c:set var="soLuong" value="${voucher.soLuong}" />
    <c:set var="isPublic" value="${voucher.isPublic()}" />
    <c:set var="trangThai" value="${voucher.isTrangThai()}" />
    <c:set var="hinhAnhUrl" value="${voucher.hinhAnhUrl}" />
    <c:set var="moTaDieuKien" value="${voucher.moTaDieuKien}" />
    <c:set var="soLuotDungCaNhan" value="${voucher.soLuotDungCaNhan}" />
    <c:set var="hangApDung" value="${voucher.hangApDung}" />
    <c:set var="loaiVoucher" value="${voucher.loaiVoucher}" />
    <c:if test="${not empty voucher.ngayBatDau}">
        <c:set var="formattedStart" value="${voucher.ngayBatDau.toString().substring(0, 10)}T${voucher.ngayBatDau.toString().substring(11, 16)}"/>
    </c:if>
    <c:if test="${not empty voucher.ngayKetThuc}">
        <c:set var="formattedEnd" value="${voucher.ngayKetThuc.toString().substring(0, 10)}T${voucher.ngayKetThuc.toString().substring(11, 16)}"/>
    </c:if>
</c:if>

<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px; background-color: #ffffff;">
                <c:choose>
                    <%-- CASE 1: CREATE / EDIT VOUCHER FORM VIEW --%>
                    <c:when test="${not empty formTitle}">
                        <div class="mb-3 border-start border-success border-3 ps-2 text-start">
                            <a href="${pageContext.request.contextPath}/admin/voucher" class="btn btn-sm btn-outline-secondary fw-bold" style="border-radius: 6px;">
                                <i class="bi bi-arrow-left"></i> Quay lại danh sách
                            </a>
                        </div>
                        <h4 class="fw-bold mb-4 text-success border-bottom pb-3 text-start">
                            <i class="bi bi-ticket-perforated-fill text-success me-2"></i> <c:out value="${formTitle}" />
                        </h4>
                        <form action="${pageContext.request.contextPath}/admin/voucher" method="POST">
                            <input type="hidden" name="action" value="${not empty voucher ? 'edit' : 'create'}">
                            <input type="hidden" name="maKm" id="maKm" value="${maKm}">
                            <div class="row g-3 text-start">
                                <div class="col-12 col-md-4">
                                    <label class="form-label fw-bold small">Mã Khuyến Mãi (Tự sinh)</label>
                                    <input type="text" class="form-control form-control-teapos bg-light" value="${not empty voucher ? maKm : 'KMxxxxx (Hệ thống tự sinh)'}" readonly style="font-weight: bold;">
                                </div>
                                <div class="col-12 col-md-4">
                                    <label for="maCode" class="form-label fw-bold small">Mã CODE áp dụng <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-teapos text-uppercase" id="maCode" name="maCode" value="${maCode}" placeholder="Ví dụ: GIAM20K..." required autocomplete="off" style="font-weight: 700; letter-spacing: 0.5px;">
                                </div>
                                <div class="col-12 col-md-4">
                                    <label for="tenKm" class="form-label fw-bold small">Tên Chiến Dịch Khuyến Mãi <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-teapos" id="tenKm" name="tenKm" value="${tenKm}" placeholder="Ví dụ: Tri ân khách hàng..." required autocomplete="off">
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="loaiVoucher" class="form-label fw-bold small">Loại Khuyến Mãi</label>
                                    <select name="loaiVoucher" id="loaiVoucher" class="form-select form-control-teapos" onchange="toggleVoucherScopeUI()">
                                        <option value="1" ${loaiVoucher == 1 ? 'selected' : ''}>Hội viên CRM theo Hạng</option>
                                        <option value="2" ${loaiVoucher == 2 ? 'selected' : ''}>Voucher Giấy công khai (Không cần CRM)</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3" id="hangApDungGroup">
                                    <label for="hangApDung" class="form-label fw-bold small">Hạng tối thiểu áp dụng</label>
                                    <select name="hangApDung" id="hangApDung" class="form-select form-control-teapos">
                                        <option value="1" ${hangApDung == 1 ? 'selected' : ''}>Hạng Đồng trở lên</option>
                                        <option value="2" ${hangApDung == 2 ? 'selected' : ''}>Hạng Bạc trở lên</option>
                                        <option value="3" ${hangApDung == 3 ? 'selected' : ''}>Hạng Vàng trở lên</option>
                                        <option value="4" ${hangApDung == 4 ? 'selected' : ''}>Hạng VIP / Kim Cương</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="loaiGiam" class="form-label fw-bold small">Hình thức giảm giá</label>
                                    <select name="loaiGiam" id="loaiGiam" class="form-select form-control-teapos">
                                        <option value="1" ${loaiGiam == 1 ? 'selected' : ''}>Trừ tiền mặt (VNĐ)</option>
                                        <option value="2" ${loaiGiam == 2 ? 'selected' : ''}>Trừ phần trăm (%)</option>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="giaTriGiam" class="form-label fw-bold small">Giá trị giảm <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control form-control-teapos text-end fw-bold" id="giaTriGiam" name="giaTriGiam" value="${giaTriGiam}" min="0" required>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="giamToiDa" class="form-label fw-bold small">Giảm tối đa (Phần trăm)</label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="giamToiDa" name="giamToiDa" value="${giamToiDa}" min="0" placeholder="0 nếu không chặn...">
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="donToiThieu" class="form-label fw-bold small">Đơn tối thiểu áp dụng</label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="donToiThieu" name="donToiThieu" value="${donToiThieu}" min="0">
                                </div>
                                <div class="col-12 col-md-6">
                                    <label for="ngayBatDau" class="form-label fw-bold small">Thời gian bắt đầu <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control form-control-teapos" id="ngayBatDau" name="ngayBatDau" value="${formattedStart}" required>
                                </div>
                                <div class="col-12 col-md-6">
                                    <label for="ngayKetThuc" class="form-label fw-bold small">Thời gian kết thúc <span class="text-danger">*</span></label>
                                    <input type="datetime-local" class="form-control form-control-teapos" id="ngayKetThuc" name="ngayKetThuc" value="${formattedEnd}" required>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="soLuong" class="form-label fw-bold small">Quỹ số lượng cài đặt <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="soLuong" name="soLuong" value="${soLuong}" min="1" required>
                                </div>
                                <div class="col-12 col-md-3" id="soLuotDungCaNhanGroup">
                                    <label for="soLuotDungCaNhan" class="form-label fw-bold small">Giới hạn / Cá nhân <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control form-control-teapos text-end" id="soLuotDungCaNhan" name="soLuotDungCaNhan" value="${soLuotDungCaNhan}" min="0" placeholder="0 nếu không giới hạn..." required>
                                </div>
                                <div class="col-12 col-md-3">
                                    <label for="trangThai" class="form-label fw-bold small">Trạng thái phát hành</label>
                                    <select name="trangThai" id="trangThai" class="form-select form-control-teapos">
                                        <option value="1" ${trangThai == 'true' || trangThai == true ? 'selected' : ''}>Đang hoạt động</option>
                                        <option value="0" ${trangThai == 'false' || trangThai == false ? 'selected' : ''}>Ngừng chạy</option>
                                    </select>
                                </div>
                                <input type="hidden" name="isPublic" value="1">
                                <div class="col-12">
                                    <label for="hinhAnhUrl" class="form-label fw-bold small">Ảnh minh họa (URL)</label>
                                    <input type="text" class="form-control form-control-teapos" id="hinhAnhUrl" name="hinhAnhUrl" value="${hinhAnhUrl}" placeholder="https://image-url...">
                                </div>
                                <div class="col-12">
                                    <label for="moTaDieuKien" class="form-label fw-bold small">Mô tả điều kiện áp dụng chi tiết</label>
                                    <textarea name="moTaDieuKien" id="moTaDieuKien" class="form-control" rows="2" placeholder="Ví dụ: Chỉ áp dụng cho hóa đơn tối thiểu 50k...">${moTaDieuKien}</textarea>
                                </div>
                                <div class="col-12 d-flex justify-content-end gap-2 border-top pt-4 mt-4">
                                    <a href="${pageContext.request.contextPath}/admin/voucher" class="btn btn-secondary-teapos px-4 py-2.5 fw-bold">HUỶ BỎ</a>
                                    <button type="submit" class="btn-teapos btn-primary-teapos px-5 py-2.5 fw-bold shadow-sm">
                                        <i class="bi bi-save me-1"></i> LƯU VOUCHER KHUYẾN MÃI
                                    </button>
                                </div>
                            </div>
                        </form>
                    </c:when>

                    <%-- CASE 2: LIST VIEW IN DEKSTOP & MOBILE SYNCED --%>
                    <c:otherwise>
                        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4 text-start">
                            <div>
                                <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-ticket-perforated-fill me-2"></i>QUẢN LÝ VOUCHER</h3>
                                <p class="text-muted small mb-0">Cấu hình các chiến dịch khuyến mãi, băm mã giảm giá, kiểm soát trạng thái và số lượng Voucher đã dùng thực tế</p>
                            </div>
                            <div class="d-flex gap-2 align-items-end">
                                <div class="input-group input-group-sm" style="width: 250px;">
                                    <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                                    <input type="text" id="voucherSearchInput" class="form-control" placeholder="Tìm tên hoặc mã voucher..." onkeyup="filterAndPaginateVouchers()">
                                </div>
                                <a href="${pageContext.request.contextPath}/admin/voucher?action=create" class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold">
                                    <i class="bi bi-plus-circle-fill"></i> Tạo Mới Voucher KM
                                </a>
                            </div>
                        </div>

                        <!-- ==================== VIEW 1: DESKTOP LAYOUT (Màn hình lớn) ==================== -->
                        <div class="d-none d-lg-block table-responsive">
                            <table class="table table-hover align-middle admin-table" id="voucherTable">
                                <thead>
                                <tr class="table-light text-center">
                                    <th style="width: 60px;">STT</th>
                                    <th>Mã KM</th>
                                    <th>Mã Code</th>
                                    <th class="text-start">Tên Chương Trình</th>
                                    <th>Hình Thức Giảm</th>
                                    <th>Hạn Sử Dụng</th>
                                    <th>Số Lượng (Đã dùng/Cài đặt)</th>
                                    <th>Phân loại</th>
                                    <th>Hạng áp dụng</th>
                                    <th>Giới hạn cá nhân</th>
                                    <th>Trạng Thái</th>
                                    <th style="width: 250px;" class="text-end">Hành Động</th>
                                </tr>
                                </thead>
                                <tbody id="voucherTableBody">
                                <c:choose>
                                    <c:when test="${not empty vouchers}">
                                        <c:forEach var="item" items="${vouchers}" varStatus="loop">
                                            <tr class="text-center voucher-row" data-id="${item.maKm}" data-code="<c:out value='${item.maCode}'/>" data-name="<c:out value='${item.tenKm}'/>">
                                                <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                                <td><code class="fw-bold text-dark">${item.maKm}</code></td>
                                                <td><span class="badge bg-dark text-white fw-bold px-2.5 py-1.5" style="letter-spacing: 0.5px; font-size:11px;">${item.maCode}</span></td>
                                                <td class="text-start">
                                                    <strong class="text-dark"><c:out value="${item.tenKm}"/></strong> <br>
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
                                                <td class="fw-bold text-dark"><span class="text-success">${item.soLuongDaDung}</span> / ${item.soLuong}</td>
                                                <td>
                                                        <span class="badge ${item.loaiVoucher == 1 ? 'bg-success bg-opacity-10 text-success' : 'bg-secondary bg-opacity-10 text-secondary'} border px-2.5 py-1.5">
                                                                ${item.loaiVoucher == 1 ? 'CRM HỘI VIÊN' : 'VOUCHER GIẤY 📄'}
                                                        </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.loaiVoucher == 2}"><span class="text-muted small">Mọi đối tượng</span></c:when>
                                                        <c:when test="${item.hangApDung == 1}"><span class="badge bg-secondary">ĐỒNG trở lên</span></c:when>
                                                        <c:when test="${item.hangApDung == 2}"><span class="badge bg-light text-dark border">BẠC trở lên</span></c:when>
                                                        <c:when test="${item.hangApDung == 3}"><span class="badge bg-warning text-dark">VÀNG trở lên 👑</span></c:when>
                                                        <c:when test="${item.hangApDung == 4}"><span class="badge bg-info text-white">VIP 💎</span></c:when>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                        <span class="badge bg-light text-dark border px-2.5 py-1.5">
                                                                ${item.loaiVoucher == 2 ? 'Vô hạn' : (item.soLuotDungCaNhan == 0 ? 'Vô hạn' : item.soLuotDungCaNhan += ' lần')}
                                                        </span>
                                                </td>
                                                <td>
                                                        <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-3 py-1.5" style="border-radius: 50px;">
                                                                ${item.trangThai ? 'Đang chạy' : 'Ngừng chạy'}
                                                        </span>
                                                </td>
                                                <td class="text-end">
                                                    <div class="d-flex justify-content-end gap-1.5 align-items-center">
                                                        <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${item.maKm}" class="btn btn-sm btn-action-edit" title="Sửa"><i class="bi bi-pencil-square me-1"></i> Sửa</a>
                                                        <c:choose>
                                                            <c:when test="${item.trangThai}">
                                                                <a href="${pageContext.request.contextPath}/admin/voucher?action=toggle&id=${item.maKm}&status=0" class="btn btn-sm btn-action-warning" title="Tạm ngưng"><i class="bi bi-toggle2-off me-1"></i> Ẩn</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a href="${pageContext.request.contextPath}/admin/voucher?action=toggle&id=${item.maKm}&status=1" class="btn btn-sm btn-action-edit" title="Kích hoạt"><i class="bi bi-toggle2-on me-1"></i> Bật</a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <button class="btn btn-sm btn-action-delete" onclick="confirmDeleteVoucher('${item.maKm}')" title="Xóa"><i class="bi bi-trash3-fill me-1"></i> Xóa</button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="12" class="text-center py-5 text-muted">Hệ thống chưa tạo mã khuyến mãi nào!</td></tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>

                        <!-- ==================== VIEW 2: MOBILE LAYOUT (Điện thoại < 992px) ==================== -->
                        <div class="d-block d-lg-none" id="vouchersMobileCards">
                            <c:choose>
                                <c:when test="${not empty vouchers}">
                                    <c:forEach var="item" items="${vouchers}" varStatus="loop">
                                        <div class="voucher-card-col mb-3" data-id="${item.maKm}" data-code="<c:out value='${item.maCode}'/>" data-name="<c:out value='${item.tenKm}'/>">
                                            <div class="card p-3 border shadow-sm position-relative text-start" style="border-radius: 12px; background: #ffffff; border-color: var(--border-color) !important;">
                                                <!-- Chevron Button for expansion -->
                                                <div class="position-absolute" style="top: 15px; right: 15px; cursor: pointer; z-index: 10;" onclick="toggleMobileCardDetails(this)">
                                                    <span class="badge bg-light rounded-circle text-success d-flex align-items-center justify-content-center border" style="width: 28px; height: 28px; border-color: var(--border-color) !important;">
                                                        <i class="bi bi-chevron-down fs-6"></i>
                                                    </span>
                                                </div>

                                                <!-- Header: STT, Mã CODE, và Trạng thái -->
                                                <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 pe-4">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="badge bg-light text-success rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-weight: bold; border: 1px solid var(--border-color);">
                                                                ${loop.index + 1}
                                                        </span>
                                                        <span class="badge bg-dark text-white fw-bold font-monospace" style="font-size: 11px;">${item.maCode}</span>
                                                    </div>
                                                    <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-2 py-0.5" style="font-size: 10px;">
                                                            ${item.trangThai ? 'Đang chạy' : 'Ngừng chạy'}
                                                    </span>
                                                </div>

                                                <!-- Body: Tên chương trình & Hình thức giảm -->
                                                <div class="text-start mb-2">
                                                    <h6 class="fw-bold text-dark mb-1"><c:out value="${item.tenKm}"/></h6>
                                                    <div class="text-muted small">
                                                        <c:choose>
                                                            <c:when test="${item.loaiGiam == 1}">
                                                                Giảm thẳng: <strong class="text-success"><fmt:formatNumber value="${item.giaTriGiam}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                Giảm %: <strong class="text-success">${item.giaTriGiam}%</strong> <small>(Chặn: <fmt:formatNumber value="${item.giamToiDa}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ)</small>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <!-- Card Expandable Details -->
                                                <div class="mobile-card-details border-top pt-2 mt-2 text-start small d-none" style="line-height: 1.6;">
                                                    <div class="text-muted d-flex justify-content-between">
                                                        <span>Mã Khuyến Mãi:</span>
                                                        <strong class="text-dark">${item.maKm}</strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Điều kiện đơn tối thiểu:</span>
                                                        <strong class="text-dark font-monospace"><fmt:formatNumber value="${item.donToiThieu}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Quỹ số lượng (Đã dùng/Tổng):</span>
                                                        <strong class="text-success">${item.soLuongDaDung} / ${item.soLuong}</strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Phân loại Voucher:</span>
                                                        <span class="badge ${item.loaiVoucher == 1 ? 'bg-success bg-opacity-10 text-success' : 'bg-secondary bg-opacity-10 text-secondary'} border px-2 py-0.5" style="font-size: 10px;">
                                                                ${item.loaiVoucher == 1 ? 'CRM HỘI VIÊN' : 'VOUCHER GIẤY 📄'}
                                                        </span>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Hạng áp dụng tối thiểu:</span>
                                                        <strong class="text-dark">
                                                            <c:choose>
                                                                <c:when test="${item.loaiVoucher == 2}">Mọi đối tượng</c:when>
                                                                <c:when test="${item.hangApDung == 1}">ĐỒNG trở lên</c:when>
                                                                <c:when test="${item.hangApDung == 2}">BẠC trở lên</c:when>
                                                                <c:when test="${item.hangApDung == 3}">VÀNG trở lên 👑</c:when>
                                                                <c:when test="${item.hangApDung == 4}">VIP 💎</c:when>
                                                            </c:choose>
                                                        </strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Giới hạn / Khách hàng:</span>
                                                        <strong class="text-dark">
                                                                ${item.loaiVoucher == 2 ? 'Vô hạn' : (item.soLuotDungCaNhan == 0 ? 'Vô hạn' : item.soLuotDungCaNhan += ' lần')}
                                                        </strong>
                                                    </div>
                                                    <div class="text-muted d-flex justify-content-between mt-1">
                                                        <span>Thời gian hiệu lực:</span>
                                                        <span class="text-dark fw-semibold">
                                                            <fmt:formatDate value="${item.ngayBatDau}" pattern="dd/MM/yyyy HH:mm"/> - <fmt:formatDate value="${item.ngayKetThuc}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </span>
                                                    </div>
                                                </div>

                                                <!-- Card Actions -->
                                                <div class="d-flex gap-2 border-top pt-2 mt-2">
                                                    <a href="${pageContext.request.contextPath}/admin/voucher?action=edit&id=${item.maKm}" class="btn btn-outline-success btn-sm w-100 fw-bold py-2" style="border-radius: 8px;">
                                                        <i class="bi bi-pencil-square"></i> Sửa
                                                    </a>
                                                    <c:choose>
                                                        <c:when test="${item.trangThai}">
                                                            <a href="${pageContext.request.contextPath}/admin/voucher?action=toggle&id=${item.maKm}&status=0" class="btn btn-outline-warning btn-sm w-100 fw-bold py-2" style="border-radius: 8px;">
                                                                <i class="bi bi-toggle2-off"></i> Ẩn
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/admin/voucher?action=toggle&id=${item.maKm}&status=1" class="btn btn-outline-success btn-sm w-100 fw-bold py-2" style="border-radius: 8px;">
                                                                <i class="bi bi-toggle2-on"></i> Bật
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <button class="btn btn-outline-danger btn-sm w-100 fw-bold py-2" style="border-radius: 8px;" onclick="confirmDeleteVoucher('${item.maKm}')">
                                                        <i class="bi bi-trash3-fill"></i> Xóa
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-5 text-muted bg-white rounded-3 shadow-sm border">
                                        <i class="bi bi-ticket-perforated fs-1 text-secondary opacity-30 d-block mb-2"></i>
                                        Chưa tạo voucher khuyến mãi nào!
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- PHÂN TRANG ĐỒNG BỘ -->
                        <div class="pagination-container" id="paginationWrapper" style="display: none;">
                            <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 của 10 Voucher</span>
                            <nav>
                                <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                            </nav>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleVoucherScopeUI() {
        const loaiVoucherEl = document.getElementById("loaiVoucher");
        if (!loaiVoucherEl) return;
        const loaiVoucher = loaiVoucherEl.value;
        const hangApDungGroup = document.getElementById("hangApDungGroup");
        const soLuotDungCaNhanGroup = document.getElementById("soLuotDungCaNhanGroup");
        if (loaiVoucher === "2") {
            if (hangApDungGroup) hangApDungGroup.style.setProperty('display', 'none', 'important');
            if (soLuotDungCaNhanGroup) soLuotDungCaNhanGroup.style.setProperty('display', 'none', 'important');
        } else {
            if (hangApDungGroup) hangApDungGroup.style.setProperty('display', 'block', 'important');
            if (soLuotDungCaNhanGroup) soLuotDungCaNhanGroup.style.setProperty('display', 'block', 'important');
        }
    }

    function confirmDeleteVoucher(maKm) {
        Swal.fire({
            title: 'Hủy/Xóa bỏ Voucher này?',
            text: "Dữ liệu Voucher sẽ được đưa về ngừng hoạt động vĩnh viễn (hoặc xóa sạch khỏi CSDL nếu chưa phát sinh đơn hàng nào) để bảo lưu báo cáo hóa đơn cũ!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận xóa'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/voucher?action=delete&id=' + maKm;
            }
        });
    }

    // EXPAND/COLLAPSE MOBILE CARD DETAILS
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

    // ==========================================
    // CLIENT-SIDE FILTER AND PAGINATION (SYNCED DESKTOP & MOBILE)
    // ==========================================
    let currentPage = 1;
    const pageSize = 10;
    let filteredVouchersList = [];
    let filteredMobileCards = [];

    function filterAndPaginateVouchers() {
        const searchInput = document.getElementById("voucherSearchInput");
        if (!searchInput) return;
        const searchVal = searchInput.value.trim().toLowerCase();

        // Filter Desktop Rows
        const allDesktopRows = Array.from(document.querySelectorAll("#voucherTableBody .voucher-row"));
        filteredVouchersList = allDesktopRows.filter(row => {
            const code = row.dataset.code.toLowerCase();
            const name = row.dataset.name.toLowerCase();
            return code.includes(searchVal) || name.includes(searchVal);
        });

        // Filter Mobile Cards
        const allMobileCards = Array.from(document.querySelectorAll("#vouchersMobileCards .voucher-card-col"));
        filteredMobileCards = allMobileCards.filter(card => {
            const code = card.dataset.code.toLowerCase();
            const name = card.dataset.name.toLowerCase();
            return code.includes(searchVal) || name.includes(searchVal);
        });

        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        // Desktop Render
        const allDesktopRows = document.querySelectorAll("#voucherTableBody .voucher-row");
        allDesktopRows.forEach(row => row.style.display = "none");

        const totalRows = filteredVouchersList.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        const pageRows = filteredVouchersList.slice(startIdx, endIdx);
        pageRows.forEach(row => row.style.display = "table-row");

        // Mobile Render
        const allMobileCards = document.querySelectorAll("#vouchersMobileCards .voucher-card-col");
        allMobileCards.forEach(card => card.style.setProperty('display', 'none', 'important'));

        const pageCards = filteredMobileCards.slice(startIdx, endIdx);
        pageCards.forEach(card => {
            card.style.setProperty('display', 'block', 'important');
        });

        // Pagination Panel Update
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const wrapper = document.getElementById("paginationWrapper");
        if (!infoEl || !btnContainer || !wrapper) return;

        const start = totalRows > 0 ? startIdx + 1 : 0;
        const end = endIdx;
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng Voucher';
        btnContainer.innerHTML = "";

        if (totalPages <= 1) {
            wrapper.style.setProperty('display', 'none', 'important');
            return;
        }
        wrapper.style.setProperty('display', 'flex', 'important');

        // Prev btn
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
        btnContainer.appendChild(prevLi);

        // Pages
        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        // Next btn
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredVouchersList.length / pageSize) || 1;
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTableRows();
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thiết lập Voucher mới thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã cập nhật chương trình Voucher!');
        if (msg === 'deletesuccess') showToast('success', 'Đã xóa Voucher thành công!');
        if (msg === 'softdeletesuccess') showToast('success', 'Voucher đã có giao dịch lịch sử, tự động đưa về tạm tắt!');
        if (msg === 'togglesuccess') showToast('success', 'Đã thay đổi trạng thái Voucher thành công!');
        if (msg === 'togglefailed') showToast('error', 'Cập nhật trạng thái Voucher thất bại!');

        toggleVoucherScopeUI();
        filterAndPaginateVouchers();
    });
</script>
</body>
</html>