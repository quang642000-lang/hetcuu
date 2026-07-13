<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Tra Cứu Tiến Độ Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .timeline-steps { display: flex; justify-content: space-between; align-items: center; position: relative; margin-top: 30px; }
        .timeline-step { text-align: center; position: relative; z-index: 2; width: 20%; }
        .timeline-step .circle { width: 40px; height: 40px; border-radius: 50%; background-color: #e2e8f0; display: flex; align-items: center; justify-content: center; margin: 0 auto 8px auto; border: 4px solid #fff; font-weight: bold; }
        .timeline-step.active .circle { background-color: #10b981; color: white; }
        .timeline-progress { position: absolute; height: 4px; background-color: #cbd5e1; top: 18px; left: 10%; right: 10%; z-index: 1; }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />
<div class="container py-5">
    <div class="card border-0 p-4 shadow-sm mb-4" style="border-radius: 16px;">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-1 text-dark">ĐƠN HÀNG: ${order.maDh}</h4>
                <p class="text-muted small mb-0">Hẹn nhận lúc: <strong class="text-danger"><fmt:formatDate value="${order.thoiGianHenLay}" pattern="HH:mm dd/MM/yyyy"/></strong></p>
            </div>
            <c:if test="${order.trangThaiDon == 0}">
                <button class="btn btn-outline-danger btn-sm fw-bold px-3" onclick="confirmCancelOrder('${order.maDh}')">HỦY ĐƠN HÀNG</button>
            </c:if>
        </div>
        <!-- DÒNG TIẾN ĐỘ THỜI GIAN THỰC (TIMELINE) -->
        <div class="position-relative mb-5 py-2">
            <div class="timeline-progress"></div>
            <div class="timeline-steps">
                <div class="timeline-step ${order.trangThaiDon >= 0 ? 'active' : ''}">
                    <div class="circle">1</div>
                    <span class="small fw-semibold">Đã Đặt</span>
                </div>
                <div class="timeline-step ${order.trangThaiDon >= 1 ? 'active' : ''}">
                    <div class="circle">2</div>
                    <span class="small fw-semibold">Duyệt Đơn</span>
                </div>
                <div class="timeline-step ${order.trangThaiDon >= 2 ? 'active' : ''}">
                    <div class="circle">3</div>
                    <span class="small fw-semibold">Pha Chế</span>
                </div>
                <div class="timeline-step ${order.trangThaiDon >= 3 ? 'active' : ''}">
                    <div class="circle">4</div>
                    <span class="small fw-semibold">Chờ Lấy</span>
                </div>
                <div class="timeline-step ${order.trangThaiDon >= 4 ? 'active' : ''}">
                    <div class="circle">5</div>
                    <span class="small fw-semibold">Hoàn Tất</span>
                </div>
            </div>
        </div>
        <!-- CHI TIẾT SẢN PHẨM HOÁ ĐƠN -->
        <h5 class="fw-bold text-dark mb-3"><i class="bi bi-receipt"></i> Hóa đơn thanh toán chi tiết</h5>
        <div class="table-responsive">
            <table class="table">
                <thead>
                <tr>
                    <th>Tên món & Size</th>
                    <th>Cấu hình riêng & Toppings</th>
                    <th class="text-center">Số lượng</th>
                    <th class="text-end">Đơn giá</th>
                    <th class="text-end">Thành tiền</th>
                </tr>
                </thead>
                <tbody>
                <%-- SỬA ĐỔI CHÍ MẠNG: Đổi từ order.items (không tồn tại trong entity) sang order.chiTietDonHangList --%>
                <c:forEach var="item" items="${order.chiTietDonHangList}">
                    <tr>
                        <td>
                            <strong><c:out value="${item.maSp}"/></strong> (Size ${item.tenSize})
                        </td>
                        <td>
                            <div class="mb-1">
                                <span class="badge bg-light text-dark border">Đá: ${item.mucDa}</span>
                                <span class="badge bg-light text-dark border">Đường: ${item.mucDuong}</span>
                            </div>
                                <%-- BỔ SUNG: Hiển thị đầy đủ toppings đi kèm với tên tiếng Việt chuẩn có dấu --%>
                            <c:if test="${not empty item.toppingsList}">
                                <div class="text-success small mt-1">
                                    <i class="bi bi-plus-circle"></i> Toppings:
                                    <c:forEach var="tp" items="${item.toppingsList}" varStatus="tpLoop">
                                        <c:out value="${not empty tp.tenTopping ? tp.tenTopping : 'Topping #' += tp.maTp}"/> (x${tp.soLuong})${!tpLoop.last ? ', ' : ''}
                                    </c:forEach>
                                </div>
                            </c:if>
                            <c:if test="${not empty item.ghiChuMon && item.ghiChuMon ne 'Normal' && item.ghiChuMon ne 'Quick Add'}">
                                <div class="text-danger small font-monospace mt-1"><i class="bi bi-pencil-fill"></i> Ghi chú: ${item.ghiChuMon}</div>
                            </c:if>
                        </td>
                        <td class="text-center fw-bold">${item.soLuong}</td>
                        <td class="text-end"><fmt:formatNumber value="${item.giaChot}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                        <td class="text-end fw-bold text-success"><fmt:formatNumber value="${item.giaChot * item.soLuong}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>
<jsp:include page="/views/layout/footer_portal.jsp" />
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    function confirmCancelOrder(maDh) {
        Swal.fire({
            title: 'Hủy đơn hàng?',
            text: 'Bạn có chắc chắn muốn hủy đơn hàng online đặt trước này không?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý hủy đơn',
            cancelButtonText: 'Quay lại'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/portal/order/cancel?id=' + maDh;
            }
        });
    }
</script>
</body>
</html>