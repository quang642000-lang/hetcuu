<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Kho Voucher Ưu Đãi CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .voucher-card {
            border: 1px dashed #10b981;
            border-radius: 12px;
            background-color: white;
            transition: all 0.2s ease;
            position: relative; /* Bắt buộc để đặt badge nổi ở góc phải */
            overflow: hidden;
        }
        .voucher-card:hover {
            transform: scale(1.02);
            box-shadow: 0 8px 16px rgba(16, 185, 129, 0.1);
        }
        .voucher-used-up {
            border: 1px solid #cbd5e1 !important;
            background-color: #f8fafc !important;
            opacity: 0.75;
        }
        .badge-multiplier {
            position: absolute;
            top: 0;
            right: 0;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            font-weight: 800;
            font-size: 13px;
            padding: 4px 14px;
            border-bottom-left-radius: 12px;
            box-shadow: var(--shadow-sm);
            z-index: 5;
        }
        .badge-multiplier-zero {
            background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%) !important;
        }
        .progress-voucher {
            height: 6px;
            border-radius: 5px;
            background-color: #e2e8f0;
            margin-top: 8px;
            margin-bottom: 4px;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />
<div class="container py-5">
    <div class="row g-4">
        <!-- Sidebar Menu Trái -->
        <jsp:include page="/views/portal/profile-sidebar.jsp" />
        <!-- Cột Phải: Kho Voucher -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <h4 class="fw-bold mb-4 text-dark"><i class="bi bi-ticket-perforated-fill text-success me-2"></i>KHO VOUCHER CỦA BẠN</h4>
                <div class="row g-3">
                    <c:choose>
                        <c:when test="${not empty vouchers}">
                            <c:forEach var="v" items="${vouchers}">
                                <c:set var="isUsedUp" value="${v.soLuotDungCaNhan > 0 && v.soLuotDaDungCaNhan >= v.soLuotDungCaNhan}" />
                                <div class="col-12 col-md-6">
                                    <div class="voucher-card p-4 d-flex justify-content-between align-items-center ${isUsedUp ? 'voucher-used-up' : ''}">

                                        <!-- 1. BADGE GÓC PHẢI NHÂN DIỆN xN LƯỢT SỬ DỤNG CÒN LẠI -->
                                        <c:if test="${v.soLuotDungCaNhan > 0}">
                                            <div class="badge-multiplier ${isUsedUp ? 'badge-multiplier-zero' : ''}">
                                                <c:choose>
                                                    <c:when test="${isUsedUp}">Hết lượt</c:when>
                                                    <c:otherwise>x${v.soLuotDungCaNhan - v.soLuotDaDungCaNhan}</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:if>

                                        <div class="text-start flex-grow-1">
                                            <span class="badge bg-dark text-white fw-bold mb-2" style="letter-spacing: 0.5px;">${v.maCode}</span>
                                            <h6 class="fw-bold text-success mb-1"><c:out value="${v.tenKm}"/></h6>
                                            <small class="text-muted d-block" style="font-size: 11px;">Hạn sử dụng: <fmt:formatDate value="${v.ngayKetThuc}" pattern="dd/MM/yyyy"/></small>
                                            <small class="text-muted d-block" style="font-size: 11px;">Đơn tối thiểu: <fmt:formatNumber value="${v.donToiThieu}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</small>

                                            <!-- ĐỐI SOÁT LƯỢT CÁ NHÂN -->
                                            <div class="mt-2 pt-2 border-top border-secondary border-opacity-10 small text-dark">
                                                <div style="font-size: 11px;"><i class="bi bi-clock-history"></i> Lượt tối đa / Khách: <strong class="text-success">${v.soLuotDungCaNhan == 0 ? "Vô hạn" : v.soLuotDungCaNhan += " Lần"}</strong></div>
                                                <div style="font-size: 11px;"><i class="bi bi-check-circle"></i> Đã sử dụng: <strong class="text-danger">${v.soLuotDaDungCaNhan} Lần</strong></div>
                                            </div>

                                            <!-- 2. THANH SỐ LƯỢNG VOUCHER CÒN LẠI TRONG TOÀN HỆ THỐNG (URGENCY) -->
                                            <c:if test="${v.soLuong > 0 && v.soLuong < 99999}">
                                                <c:set var="globalPct" value="${(v.soLuongDaDung * 100) / v.soLuong}" />
                                                <c:set var="globalLeft" value="${v.soLuong - v.soLuongDaDung}" />
                                                <div class="mt-2 pt-2 border-top border-secondary border-opacity-10">
                                                    <div class="d-flex justify-content-between text-muted" style="font-size: 10px;">
                                                        <span>Tiến trình sử dụng trong hệ thống:</span>
                                                        <span class="fw-bold ${globalLeft < 20 ? 'text-danger' : 'text-success'}">
                Còn ${globalLeft} / ${v.soLuong} lượt
            </span>
                                                    </div>
                                                    <div class="progress progress-voucher">
                                                        <div class="progress-bar ${globalLeft < 20 ? 'bg-danger' : 'bg-success'} progress-bar-striped progress-bar-animated"
                                                             role="progressbar"
                                                             style="width: ${globalPct > 100 ? 100 : globalPct}%"></div>
                                                    </div>
                                                    <c:if test="${globalLeft <= 15 && globalLeft > 0}">
                                                        <div class="text-danger fw-bold" style="font-size: 9px; line-height: 1.2;"><i class="bi bi-exclamation-triangle-fill"></i> Sắp hết! Hãy mua ngay kẻo lỡ ưu đãi!</div>
                                                    </c:if>
                                                </div>
                                            </c:if>

                                        </div>
                                        <div class="text-end ms-3 flex-shrink-0">
                                            <c:choose>
                                                <c:when test="${isUsedUp}">
                                                    <button class="btn btn-sm btn-secondary fw-bold px-3 rounded-pill" disabled style="opacity: 0.5;">HẾT LƯỢT</button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn btn-sm btn-success fw-bold px-3 rounded-pill" onclick="copyVoucherCode('${v.maCode}')">SAO CHÉP</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center py-5 text-muted">
                                <i class="bi bi-ticket fs-1 d-block mb-2"></i>
                                Không có Voucher nào khả dụng cho hạng thẻ hiện tại của bạn!
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/views/layout/footer_portal.jsp" />
<script>
    function copyVoucherCode(code) {
        navigator.clipboard.writeText(code).then(() => {
            showToast('success', 'Đã sao chép mã giảm giá: ' + code);
        });
    }
</script>
</body>
</html>