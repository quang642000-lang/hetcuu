<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Danh Sách Đơn Hàng Đặt Lấy</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
</head>
<body class="bg-light">

<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-5">
    <div class="row g-4">
        <!-- Sidebar Menu Trái -->
        <jsp:include page="/views/portal/profile-sidebar.jsp" />

        <!-- Cột Phải: Danh Sách Đơn Hàng -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <h4 class="fw-bold mb-4 text-dark"><i class="bi bi-clock-history text-success me-2"></i>LỊCH SỬ ĐƠN HÀNG</h4>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
                            <th>Mã Đơn</th>
                            <th>Thời Gian Tạo</th>
                            <th>Hẹn Đến Lấy</th>
                            <th class="text-end">Khách Thanh Toán</th>
                            <th class="text-center">Thanh Toán</th>
                            <th class="text-center">Vận Hành</th>
                            <th class="text-end">Chi tiết</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach var="item" items="${orders}">
                                    <tr>
                                        <td><strong>${item.maDh}</strong></td>
                                        <td class="small"><fmt:formatDate value="${item.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="small fw-semibold text-danger"><fmt:formatDate value="${item.thoiGianHenLay}" pattern="HH:mm dd/MM"/></td>
                                        <td class="text-end fw-bold text-success"><fmt:formatNumber value="${item.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThaiThanhToan == 1 ? 'bg-success bg-opacity-10 text-success' : 'bg-warning bg-opacity-10 text-warning'} border px-2.5 py-1">
                                                        ${item.trangThaiThanhToan == 1 ? 'Đã Trả' : 'Chờ Trả'}
                                                </span>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.trangThaiDon == 0}"><span class="badge bg-secondary">Chờ duyệt</span></c:when>
                                                <c:when test="${item.trangThaiDon == 1}"><span class="badge bg-info text-white">Đã XN</span></c:when>
                                                <c:when test="${item.trangThaiDon == 2}"><span class="badge bg-warning text-dark">Pha chế</span></c:when>
                                                <c:when test="${item.trangThaiDon == 3}"><span class="badge bg-primary text-white">Chờ lấy</span></c:when>
                                                <c:when test="${item.trangThaiDon == 4}"><span class="badge bg-success">Xong</span></c:when>
                                                <c:when test="${item.trangThaiDon == 5}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <a href="${pageContext.request.contextPath}/portal/order/detail?id=${item.maDh}" class="btn btn-sm btn-outline-success">
                                                <i class="bi bi-eye"></i> Xem
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">Bạn chưa đặt đơn hàng nào trên hệ thống!</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />

</body>
</html>
