<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
        }
        .voucher-card:hover {
            transform: scale(1.02);
            box-shadow: 0 8px 16px rgba(16, 185, 129, 0.1);
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
                                <div class="col-12 col-md-6">
                                    <div class="voucher-card p-4 d-flex justify-content-between align-items-center">
                                        <div>
                                            <span class="badge bg-dark text-white fw-bold mb-2" style="letter-spacing: 0.5px;">${v.maCode}</span>
                                            <h6 class="fw-bold text-success mb-1"><c:out value="${v.tenKm}"/></h6>
                                            <small class="text-muted d-block" style="font-size: 11px;">Hạn sử dụng: <fmt:formatDate value="${v.ngayKetThuc}" pattern="dd/MM/yyyy"/></small>
                                            <small class="text-muted d-block" style="font-size: 11px;">Đơn tối thiểu: <fmt:formatNumber value="${v.donToiThieu}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</small>
                                        </div>
                                        <div class="text-end">
                                            <button class="btn btn-sm btn-success fw-bold px-3 rounded-pill" onclick="copyVoucherCode('${v.maCode}')">SAO CHÉP MÃ</button>
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