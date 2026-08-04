<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Kho Voucher Ưu Đãi CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet">
</head>
<body class="bg-light">
<!-- NAV HEADER -->
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4 py-lg-5">
    <div class="row g-4">
        <!-- Sidebar Menu Trái -->
        <jsp:include page="/views/portal/profile-sidebar.jsp" />

        <!-- Cột Phải: Kho Voucher -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px; background-color: #ffffff; border: 1px solid var(--border-color) !important;">
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

                                                    <!-- ĐỒNG BỘ THANH TIẾN TRÌNH ĐẦY DẦN -->
                                                    <c:if test="${v.soLuong > 0 && v.soLuong < 99999}">
                                                        <c:set var="usedPct" value="${(v.soLuongDaDung * 100) / v.soLuong}" />
                                                        <c:set var="globalLeft" value="${v.soLuong - v.soLuongDaDung}" />
                                                        <div class="mt-3 pt-2 border-top border-secondary border-opacity-10">
                                                            <div class="d-flex justify-content-between text-muted" style="font-size: 10px;">
                                                                <span>Quỹ Voucher của cửa hàng:</span>
                                                                <span class="fw-bold text-success">Đã phát hành <fmt:formatNumber value="${usedPct}" maxFractionDigits="0"/>%</span>
                                                            </div>
                                                            <div class="progress progress-voucher">
                                                                <div class="progress-bar bg-success progress-bar-striped progress-bar-animated"
                                                                     role="progressbar"
                                                                     style="width: ${usedPct > 100 ? 100 : usedPct}%"></div>
                                                            </div>
                                                            <c:if test="${globalLeft <= 15 && globalLeft > 0}">
                                                                <div class="text-danger fw-bold mt-1" style="font-size: 9px; line-height: 1.2; animation: pulse 1.5s infinite;"><i class="bi bi-exclamation-triangle-fill"></i> Số lượng còn rất ít! Hãy đặt nước ngay!</div>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                </div>
                                                <div class="text-end ms-3 flex-shrink-0">
                                                    <button class="btn btn-sm btn-success fw-bold px-3 rounded-pill btn-primary-teapos" style="border:none;" onclick="copyVoucherCode('${v.maCode}')">COPY</button>
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

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />
</body>
</html>
