<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Danh Sách Đơn Hàng Đặt Lấy</title>
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

        <!-- Cột Phải: Danh Sách Đơn Hàng -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px; border: 1px solid var(--border-color) !important;">
                <h4 class="fw-bold mb-4 text-dark text-start"><i class="bi bi-clock-history text-success me-2"></i>LỊCH SỬ ĐƠN HÀNG</h4>

                <!-- DESKTOP VIEW: STANDARD TABLE -->
                <div class="table-responsive d-none d-md-block">
                    <table class="table table-hover align-middle text-center" id="ordersDesktopTable">
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
                                <c:forEach var="item" items="${orders}" varStatus="loop">
                                    <tr class="desktop-order-row" data-id="${item.maDh}">
                                        <td><strong class="font-monospace text-success">${item.maDh}</strong></td>
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
                                            <a href="${pageContext.request.contextPath}/portal/order/detail?id=${item.maDh}" class="btn btn-sm btn-outline-success fw-bold px-2.5" style="border-radius: 6px;">
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

                <!-- MOBILE VIEW: BEAUTIFUL ACCORDION CARDS WITH BULLETPROOF COLLAPSIBLE BORDERS -->
                <div class="accordion d-block d-md-none" id="ordersAccordion">
                    <c:choose>
                        <c:when test="${not empty orders}">
                            <c:forEach var="item" items="${orders}" varStatus="loop">
                                <div class="accordion-item mobile-order-row mb-2 border rounded-3 overflow-hidden shadow-sm" data-id="${item.maDh}">
                                    <h2 class="accordion-header" id="heading_${item.maDh}">
                                        <button class="accordion-button collapsed py-3 px-3" type="button" data-bs-toggle="collapse" data-bs-target="#collapse_${item.maDh}" aria-expanded="false" aria-controls="collapse_${item.maDh}">
                                            <div class="w-100 d-flex justify-content-between align-items-center pe-3 text-start">
                                                <div>
                                                    <span class="fw-bold text-success font-monospace">${item.maDh}</span>
                                                    <div class="small text-muted mt-1"><fmt:formatDate value="${item.thoiGianTao}" pattern="dd/MM HH:mm"/></div>
                                                </div>
                                                <div class="text-end">
                                                    <strong class="text-danger d-block" style="font-size:14.5px;"><fmt:formatNumber value="${item.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</strong>
                                                    <span class="badge ${item.trangThaiThanhToan == 1 ? 'bg-success' : 'bg-warning'} text-white rounded-pill px-2 py-0.5 mt-1" style="font-size: 9px;">
                                                            ${item.trangThaiThanhToan == 1 ? 'Đã Trả' : 'Chờ Trả'}
                                                    </span>
                                                </div>
                                            </div>
                                        </button>
                                    </h2>
                                    <div id="collapse_${item.maDh}" class="accordion-collapse collapse" aria-labelledby="heading_${item.maDh}" data-bs-parent="#ordersAccordion">
                                        <div class="accordion-body bg-light text-start p-3 small">
                                            <div class="row g-2">
                                                <div class="col-6">
                                                    <span class="text-muted d-block" style="font-size:10px;">Hẹn đến lấy:</span>
                                                    <strong class="text-danger d-block" style="font-size:12.5px;"><fmt:formatDate value="${item.thoiGianHenLay}" pattern="HH:mm dd/MM"/></strong>
                                                </div>
                                                <div class="col-6">
                                                    <span class="text-muted d-block" style="font-size:10px;">Vận hành:</span>
                                                    <div class="mt-1">
                                                        <c:choose>
                                                            <c:when test="${item.trangThaiDon == 0}"><span class="badge bg-secondary px-2 py-1">Chờ duyệt</span></c:when>
                                                            <c:when test="${item.trangThaiDon == 1}"><span class="badge bg-info text-white px-2 py-1">Đã XN</span></c:when>
                                                            <c:when test="${item.trangThaiDon == 2}"><span class="badge bg-warning text-dark px-2 py-1">Pha chế</span></c:when>
                                                            <c:when test="${item.trangThaiDon == 3}"><span class="badge bg-primary text-white px-2 py-1">Chờ lấy</span></c:when>
                                                            <c:when test="${item.trangThaiDon == 4}"><span class="badge bg-success px-2 py-1">Xong</span></c:when>
                                                            <c:when test="${item.trangThaiDon == 5}"><span class="badge bg-danger px-2 py-1">Đã hủy</span></c:when>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="col-12 mt-3 pt-2 border-top d-flex justify-content-end">
                                                    <a href="${pageContext.request.contextPath}/portal/order/detail?id=${item.maDh}" class="btn btn-sm btn-success fw-bold px-3 py-1.5" style="border-radius: 6px; font-size:11.5px; border:none; background-color: var(--primary);">
                                                        <i class="bi bi-eye"></i> Xem Chi Tiết Đơn
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5 text-muted">Bạn chưa đặt đơn hàng nào trên hệ thống!</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- CLIENT-SIDE PAGINATION SYSTEM FOR HIGH-FIDELITY EXPERIENCE -->
                <div class="pagination-container d-flex flex-column flex-sm-row justify-content-between align-items-center mt-4 pt-3 border-top" id="ordersPaginationBlock" style="display: none;">
                    <span class="small text-muted mb-2 mb-sm-0" id="ordersPaginationInfo">Hiển thị từ 1 đến 5 đơn hàng</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="ordersPaginationButtons"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />

<!-- CLIENT SIDE PAGINATION & ENGINE SCRIPT -->
<script>
    let currentPage = 1;
    const pageSize = 5; // 5 orders per page

    function renderOrdersPage() {
        const desktopRows = document.querySelectorAll(".desktop-order-row");
        const mobileRows = document.querySelectorAll(".mobile-order-row");
        const totalRows = desktopRows.length; // or mobileRows.length

        const totalPages = Math.ceil(totalRows / pageSize) || 1;
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        // Render Desktop Table Rows
        desktopRows.forEach((row, idx) => {
            if (idx >= startIdx && idx < endIdx) {
                row.style.setProperty('display', 'table-row', 'important');
            } else {
                row.style.setProperty('display', 'none', 'important');
            }
        });

        // Render Mobile Accordion Cards
        mobileRows.forEach((row, idx) => {
            if (idx >= startIdx && idx < endIdx) {
                row.style.setProperty('display', 'block', 'important');
            } else {
                row.style.setProperty('display', 'none', 'important');
            }
        });

        // Update pagination text info
        const infoEl = document.getElementById("ordersPaginationInfo");
        if (infoEl) {
            infoEl.innerText = 'Hiển thị từ ' + (totalRows > 0 ? (startIdx + 1) : 0) + ' đến ' + endIdx + ' trên tổng số ' + totalRows + ' đơn hàng';
        }

        // Render pagination buttons
        const buttonsContainer = document.getElementById("ordersPaginationButtons");
        if (buttonsContainer) {
            buttonsContainer.innerHTML = "";
            if (totalPages <= 1) {
                document.getElementById("ordersPaginationBlock").style.setProperty('display', 'none', 'important');
                return;
            }
            document.getElementById("ordersPaginationBlock").style.setProperty('display', 'flex', 'important');

            // Previous Button
            const prevLi = document.createElement("li");
            prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
            prevLi.innerHTML = '<a class="page-link py-1.5 px-2.5 text-success" href="javascript:void(0)" onclick="changeOrdersPage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
            buttonsContainer.appendChild(prevLi);

            // Page Numbers
            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement("li");
                li.className = "page-item " + (currentPage === i ? "active" : "");
                li.innerHTML = '<a class="page-link py-1.5 px-3 ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changeOrdersPage(' + i + ')">' + i + '</a>';
                buttonsContainer.appendChild(li);
            }

            // Next Button
            const nextLi = document.createElement("li");
            nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
            nextLi.innerHTML = '<a class="page-link py-1.5 px-2.5 text-success" href="javascript:void(0)" onclick="changeOrdersPage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
            buttonsContainer.appendChild(nextLi);
        }
    }

    function changeOrdersPage(newPage) {
        currentPage = newPage;
        renderOrdersPage();
    }

    document.addEventListener("DOMContentLoaded", () => {
        renderOrdersPage();
    });
</script>
</body>
</html>