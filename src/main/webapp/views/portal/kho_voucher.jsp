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
        :root {
            --primary: #10b981;
            --primary-hover: #059669;
            --primary-light: #ecfdf5;
            --border-color: #cbd5e1;
            --bg-main: #f1f5f9;
        }
        .voucher-card {
            border: 1px dashed #10b981;
            border-radius: 12px;
            background-color: white;
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
        }
        .voucher-card:hover {
            transform: scale(1.02);
            box-shadow: 0 8px 16px rgba(16, 185, 129, 0.1);
        }
        .voucher-used-up {
            border: 1px solid #cbd5e1 !important;
            background-color: #f8fafc !important;
            opacity: 0.65;
            filter: grayscale(85%);
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
            height: 8px;
            border-radius: 5px;
            background-color: #e2e8f0;
            margin-top: 8px;
            margin-bottom: 4px;
        }
        .nav-tabs-teapos .nav-link {
            font-weight: 700;
            color: #64748b;
            border: none;
            border-bottom: 3px solid transparent;
            background: transparent;
            padding: 10px 20px;
        }
        .nav-tabs-teapos .nav-link.active {
            color: var(--primary) !important;
            border-bottom: 3px solid var(--primary) !important;
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
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px; background-color: #ffffff;">
                <h4 class="fw-bold mb-4 text-dark text-start"><i class="bi bi-ticket-perforated-fill text-success me-2"></i>KHO VOUCHER CỦA BẠN</h4>

                <!-- HỆ TAB CHUYỂN ĐỔI: KHẢ DỤNG vs LỊCH SỬ -->
                <ul class="nav nav-tabs nav-tabs-teapos mb-4 border-bottom text-start" id="voucherTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="available-tab" data-bs-toggle="tab" data-bs-target="#availablePanel" type="button" role="tab">VOUCHER KHẢ DỤNG</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="history-tab" data-bs-toggle="tab" data-bs-target="#historyPanel" type="button" role="tab">LỊCH SỬ VOUCHER</button>
                    </li>
                </ul>

                <div class="tab-content" id="voucherTabContent">
                    <!-- PANEL 1: VOUCHER KHẢ DỤNG -->
                    <div class="tab-pane fade show active" id="availablePanel" role="tabpanel">
                        <div class="row g-3">
                            <c:choose>
                                <c:when test="${not empty vouchers}">
                                    <c:forEach var="v" items="${vouchers}">
                                        <div class="col-12 col-md-6">
                                            <div class="voucher-card p-4 d-flex justify-content-between align-items-center bg-white shadow-sm">
                                                <!-- MULTIPLIER BADGE GÓC PHẢI -->
                                                <c:if test="${v.soLuotDungCaNhan > 0}">
                                                    <div class="badge-multiplier">
                                                        x${v.soLuotDungCaNhan - v.soLuotDaDungCaNhan}
                                                    </div>
                                                </c:if>

                                                <div class="text-start flex-grow-1">
                                                    <span class="badge bg-dark text-white fw-bold mb-2" style="letter-spacing: 0.5px;">${v.maCode}</span>
                                                    <h6 class="fw-bold text-success mb-1"><c:out value="${v.tenKm}"/></h6>
                                                    <small class="text-muted d-block" style="font-size: 11px;">Hạn sử dụng: <fmt:formatDate value="${v.ngayKetThuc}" pattern="dd/MM/yyyy"/></small>
                                                    <small class="text-muted d-block" style="font-size: 11px;">Đơn tối thiểu: <fmt:formatNumber value="${v.donToiThieu}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</small>

                                                    <!-- ĐỒNG BỘ THANH TIẾN TRÌNH ĐẦY DẦN (REVERSED PROGRESS BAR) -->
                                                    <c:if test="${v.soLuong > 0 && v.soLuong < 99999}">
                                                        <!-- Tỷ lệ đầy dần = (Đã sử dụng * 100 / Tổng số lượng quỹ) -->
                                                        <c:set var="usedPct" value="${(v.soLuongDaDung * 100) / v.soLuong}" />
                                                        <c:set var="globalLeft" value="${v.soLuong - v.soLuongDaDung}" />

                                                        <div class="mt-3 pt-2 border-top border-secondary border-opacity-10">
                                                            <div class="d-flex justify-content-between text-muted" style="font-size: 10px;">
                                                                <span>Tiến độ chương trình trong hệ thống:</span>
                                                                <span class="fw-bold text-success">Đã phát hành <fmt:formatNumber value="${usedPct}" maxFractionDigits="0"/>%</span>
                                                            </div>
                                                            <div class="progress progress-voucher">
                                                                <div class="progress-bar bg-success progress-bar-striped progress-bar-animated"
                                                                     role="progressbar"
                                                                     style="width: ${usedPct > 100 ? 100 : usedPct}%"></div>
                                                            </div>
                                                            <c:if test="${globalLeft <= 15 && globalLeft > 0}">
                                                                <div class="text-danger fw-bold mt-1" style="font-size: 9px; line-height: 1.2; animation: pulse 1.5s infinite;"><i class="bi bi-exclamation-triangle-fill"></i> Sắp hết! Hãy đặt nước ngay kẻo lỡ ưu đãi!</div>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </div>
                                                <div class="text-end ms-3 flex-shrink-0">
                                                    <button class="btn btn-sm btn-success fw-bold px-3 rounded-pill" onclick="copyVoucherCode('${v.maCode}')">SAO CHÉP</button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="col-12 text-center py-5 text-muted">
                                        <i class="bi bi-ticket fs-1 d-block mb-2 text-success opacity-50"></i>
                                        Không có Voucher nào khả dụng cho hạng thẻ hiện tại của bạn!
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- PANEL 2: LỊCH SỬ VOUCHER (ĐÃ DÙNG/HẾT HẠN) -->
                    <div class="tab-pane fade" id="historyPanel" role="tabpanel">
                        <div class="row g-3">
                            <c:choose>
                                <c:when test="${not empty historyVouchers}">
                                    <c:forEach var="v" items="${historyVouchers}">
                                        <c:set var="usages" value="${v.soLuotDaDungCaNhan}" />
                                        <c:set var="isUsedUp" value="${v.soLuotDungCaNhan > 0 && usages >= v.soLuotDungCaNhan}" />
                                        <c:set var="globalLeft" value="${v.soLuong - v.soLuongDaDung}" />
                                        <c:set var="isSoldOut" value="${v.soLuong > 0 && globalLeft <= 0}" />

                                        <div class="col-12 col-md-6">
                                            <div class="voucher-card p-4 d-flex justify-content-between align-items-center voucher-used-up shadow-sm">
                                                <!-- MULTIPLIER BADGE ĐỎ / HẾT LƯỢT -->
                                                <c:if test="${v.soLuotDungCaNhan > 0}">
                                                    <div class="badge-multiplier badge-multiplier-zero">
                                                        <c:choose>
                                                            <c:when test="${isUsedUp}">Đã dùng hết</c:when>
                                                            <c:otherwise>Hết hạn</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:if>

                                                <div class="text-start flex-grow-1">
                                                    <span class="badge bg-secondary text-white fw-bold mb-2" style="letter-spacing: 0.5px;">${v.maCode}</span>
                                                    <h6 class="fw-bold text-muted mb-1"><c:out value="${v.tenKm}"/></h6>
                                                    <small class="text-muted d-block" style="font-size: 11px;">Hạn sử dụng: <fmt:formatDate value="${v.ngayKetThuc}" pattern="dd/MM/yyyy"/></small>
                                                    <small class="text-muted d-block" style="font-size: 11px;">Đơn tối thiểu: <fmt:formatNumber value="${v.donToiThieu}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</small>
                                                </div>
                                                <div class="text-end ms-3 flex-shrink-0">
                                                    <c:choose>
                                                        <c:when test="${isUsedUp}">
                                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2.5 py-1.5" style="font-size: 10px;">ĐÃ DÙNG HẾT</span>
                                                        </c:when>
                                                        <c:when test="${isSoldOut}">
                                                            <span class="badge bg-dark bg-opacity-10 text-dark border border-secondary px-2.5 py-1.5" style="font-size: 10px;">HẾT QUỸ PHÁT HÀNH</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2.5 py-1.5" style="font-size: 10px;">ĐÃ HẾT HẠN</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="col-12 text-center py-5 text-muted">
                                        <i class="bi bi-clock-history fs-1 d-block mb-2 text-secondary opacity-50"></i>
                                        Bạn chưa từng sử dụng Voucher nào trong lịch sử đặt hàng.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
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