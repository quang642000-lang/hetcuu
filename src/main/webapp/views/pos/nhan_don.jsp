<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Điều Phối Nhận Đơn Online - TEA POS PRO</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/pos.css">
</head>
<body>
<div class="pos-wrapper">
    <!-- NAV HEADER -->
    <nav class="navbar navbar-dark bg-dark px-3 sticky-top" style="height: 60px; z-index: 1040; flex-shrink: 0;">
        <div class="container-fluid d-flex align-items-center">
            <div class="d-flex align-items-center gap-3">
                <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
                    <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
                    <span>TEA POS PRO</span>
                </a>
                <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
                    <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-outline-light fw-bold px-3">
                        <i class="bi bi-cart-fill me-1"></i> BÁN TẠI QUẦY
                    </a>
                    <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-success fw-bold px-3">
                        <i class="bi bi-bell-fill me-1 text-warning animate-pulse"></i> ĐƠN ONLINE
                    </a>
                </div>
            </div>
            <div class="d-flex align-items-center gap-3 text-white ms-auto">
                <span class="badge p-2 px-3 fw-bold live-polling-badge">
                    🔴 LIVE POLLING (5S/LẦN)
                </span>
                <span class="small fw-semibold border-end pe-3 border-secondary d-none d-md-inline">
                    <i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
                </span>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase d-none d-sm-inline" style="font-size: 11px;">
                    <i class="bi bi-shield-lock-fill me-1"></i> Quản trị Admin
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger fw-bold px-3 shadow-sm" style="font-size: 12px; border-radius: 6px;">
                    <i class="bi bi-box-arrow-right me-1"></i> ĐĂNG XUẤT
                </a>
            </div>
        </div>
    </nav>

    <!-- MAIN BODY SECTION -->
    <div class="nhandon-layout">
        <!-- BACKDROP CHO MOBILE SIDEBAR -->
        <div class="nd-sidebar-backdrop" id="ndSidebarBackdrop" onclick="toggleNhanDonSidebar()"></div>

        <!-- SIDEBAR STATUS TABS -->
        <aside class="nd-sidebar" id="ndSidebar">
            <div class="px-3 mb-3 text-start d-flex justify-content-between align-items-center">
                <h6 class="text-uppercase text-secondary fw-bold small m-0" style="letter-spacing: 0.5px;">TRẠNG THÁI ĐƠN HÀNG</h6>
                <button type="button" class="btn-close d-lg-none" onclick="toggleNhanDonSidebar()"></button>
            </div>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=0" class="status-tab ${currentStatus == 0 ? 'active' : ''}">
                <span><i class="bi bi-hourglass-split me-2"></i> Chờ Xác Nhận</span>
                <span class="badge bg-warning text-dark rounded-pill" style="font-size: 10px;">Mới</span>
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=1" class="status-tab ${currentStatus == 1 ? 'active' : ''}">
                <span><i class="bi bi-check-circle me-2"></i> Đã Xác Nhận</span>
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=2" class="status-tab ${currentStatus == 2 ? 'active' : ''}">
                <span><i class="bi bi-cup-straw me-2"></i> Đang Pha Chế</span>
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=3" class="status-tab ${currentStatus == 3 ? 'active' : ''}">
                <span><i class="bi bi-box-seam me-2"></i> Chờ Lấy Hàng</span>
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=4" class="status-tab ${currentStatus == 4 ? 'active' : ''}">
                <span><i class="bi bi-flag-fill me-2"></i> Đã Hoàn Thành</span>
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=5" class="status-tab ${currentStatus == 5 ? 'active' : ''}">
                <span><i class="bi bi-x-octagon me-2"></i> Đã Hủy Bỏ</span>
            </a>
        </aside>

        <!-- RIGHT MAIN AREA -->
        <main class="nd-content">
            <!-- HEADER TỔNG QUAN -->
            <div class="d-flex justify-content-between align-items-center text-start mb-3">
                <div>
                    <h4 class="fw-bold m-0 text-dark">
                        <c:choose>
                            <c:when test="${currentStatus == 0}">Đơn hàng Chờ xác nhận</c:when>
                            <c:when test="${currentStatus == 1}">Đơn hàng Đã xác nhận</c:when>
                            <c:when test="${currentStatus == 2}">Đơn hàng Đang pha chế</c:when>
                            <c:when test="${currentStatus == 3}">Đơn hàng Chờ lấy hàng</c:when>
                            <c:when test="${currentStatus == 4}">Đơn hàng Hoàn thành</c:when>
                            <c:otherwise>Đơn hàng Đã hủy bỏ</c:otherwise>
                        </c:choose>
                    </h4>
                    <p class="text-muted m-0 small mt-1">Quản lý và điều phối các đơn đặt trước (Click & Collect) online của khách hàng</p>
                </div>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-primary-teapos btn-sm fw-bold shadow-sm d-lg-none" onclick="toggleNhanDonSidebar()">
                        <i class="bi bi-funnel-fill"></i> Trạng thái
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm fw-bold shadow-sm" onclick="location.reload()">
                        <i class="bi bi-arrow-clockwise"></i> LÀM MỚI TRANG
                    </button>
                </div>
            </div>

            <!-- SEARCH & FILTERS -->
            <div class="card card-teapos p-3 border-0 shadow-sm text-start mb-3" style="border-radius: 12px; background-color: #ffffff;">
                <div class="row g-2 align-items-center">
                    <div class="col-12 col-md-6">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="orderSearchInput" class="form-control bg-light border-start-0" placeholder="Tìm theo mã đơn hàng, số điện thoại..." onkeyup="filterAndPaginateOnlineOrders()">
                        </div>
                    </div>
                    <div class="col-6 col-md-4">
                        <input type="date" id="orderDateInput" class="form-control bg-light fw-semibold text-dark" onchange="filterAndPaginateOnlineOrders()">
                    </div>
                    <div class="col-6 col-md-2">
                        <button type="button" class="btn btn-secondary-teapos w-100 fw-bold py-2 shadow-sm" onclick="resetOnlineFilters()">
                            <i class="bi bi-arrow-counterclockwise"></i> RESET
                        </button>
                    </div>
                </div>
            </div>

            <!-- ORDERS LIST - DUAL PANEL SYSTEM FOR DESKTOP, FLUID LIST FOR MOBILE -->
            <div class="orders-grid-wrapper">
                <div class="row g-3" id="ordersGrid">
                    <c:choose>
                        <c:when test="${not empty onlineOrders}">
                            <c:forEach var="dh" items="${onlineOrders}">
                                <div class="col-12 col-md-6 col-xl-4 order-card-col"
                                     data-madh="${dh.maDh}"
                                     data-makh="${dh.maKh}"
                                     data-sdt="${dh.maKh}"
                                     data-date="<fmt:formatDate value="${dh.thoiGianTao}" pattern="yyyy-MM-dd"/>">
                                    <div class="order-card p-3">
                                        <!-- Header đơn hàng -->
                                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                                            <div class="text-start">
                                                <h5 class="fw-bold mb-0 text-success font-monospace">${dh.maDh}</h5>
                                                <small class="text-muted" style="font-size: 11px;">Đặt: <fmt:formatDate value="${dh.thoiGianTao}" pattern="HH:mm dd/MM"/></small>
                                            </div>
                                            <span class="badge ${dh.trangThaiThanhToan == 1 ? 'bg-success' : 'bg-warning'} text-white rounded-pill px-2.5 py-1" style="font-size:10px;">
                                                    ${dh.trangThaiThanhToan == 1 ? 'Đã thanh toán' : 'Chờ trả tiền mặt'}
                                            </span>
                                        </div>

                                        <!-- Body đơn hàng -->
                                        <div class="order-card-body text-start">
                                            <!-- Mốc giờ hẹn lấy nước -->
                                            <div class="p-2 bg-light rounded text-dark small mb-2 border border-dashed border-success">
                                                <i class="bi bi-alarm-fill text-danger me-1"></i> HẸN ĐẾN QUẦY LẤY:
                                                <strong><fmt:formatDate value="${dh.thoiGianHenLay}" pattern="HH:mm (dd/MM)"/></strong>
                                            </div>
                                            <div class="mb-2">
                                                <small class="text-muted d-block" style="font-size: 10px;">Hội viên thanh toán</small>
                                                <strong class="text-dark small"><i class="bi bi-person-fill text-success"></i> Mã khách: <c:out value="${not empty dh.maKh ? dh.maKh : 'Khách vãng lai'}"/></strong>
                                            </div>

                                            <!-- Collapsible Items Section for Waiters -->
                                            <div class="order-items-mobile-trigger cursor-pointer d-flex justify-content-between align-items-center py-1 bg-light rounded px-2 mb-2" onclick="toggleMobileItems(this)">
                                                <span class="small fw-bold text-dark"><i class="bi bi-cup-straw text-success"></i> Xem chi tiết đồ uống</span>
                                                <i class="bi bi-chevron-down text-muted"></i>
                                            </div>

                                            <div class="order-items-mobile-content d-none border rounded p-2 mb-2 bg-white">
                                                <c:forEach var="item" items="${dh.chiTietDonHangList}">
                                                    <div class="mb-2 border-bottom pb-1">
                                                        <div class="d-flex justify-content-between align-items-start">
                                                            <div>
                                                                <span class="fw-bold text-dark" style="font-size:12.5px;"><c:out value="${item.tenSp}"/></span>
                                                                <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-20 ms-1" style="font-size: 9px; padding: 2px 4px;">Size <c:out value="${item.tenSize}"/></span>
                                                                <span class="text-muted fw-bold font-monospace ms-1.5" style="font-size:11px;">x<c:out value="${item.soLuong}"/></span>
                                                            </div>
                                                            <span class="fw-bold text-secondary font-monospace" style="font-size:12px;">
                                                                <fmt:formatNumber value="${item.giaChot * item.soLuong}" type="currency" currencySymbol=""/>đ
                                                            </span>
                                                        </div>
                                                        <div class="text-muted" style="font-size: 10.5px; margin-top:2px;">
                                                            <c:choose>
                                                                <c:when test="${item.mucDa != 'N/A' || item.mucDuong != 'N/A'}">
                                                                    <c:if test="${item.mucDa != 'N/A'}">Đá: <c:out value="${item.mucDa}"/> | </c:if>
                                                                    <c:if test="${item.mucDuong != 'N/A'}">Đường: <c:out value="${item.mucDuong}"/></c:if>
                                                                    <c:if test="${not empty item.ghiChuMon && item.ghiChuMon != 'Normal'}"> | Lưu ý: <span class="text-danger fw-semibold"><c:out value="${item.ghiChuMon}"/></span></c:if>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:if test="${not empty item.ghiChuMon && item.ghiChuMon != 'Normal'}">Lưu ý: <span class="text-danger fw-semibold"><c:out value="${item.ghiChuMon}"/></span></c:if>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <c:if test="${not empty item.toppingsList}">
                                                            <div class="mt-1 flex-wrap d-flex gap-1">
                                                                <c:forEach var="tp" items="${item.toppingsList}">
                                                                    <span class="topping-tag" style="font-size: 9px; padding: 2px 6px;">+ <c:out value="${tp.tenTopping}"/> (x<c:out value="${tp.soLuong}"/>)</span>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </c:forEach>
                                            </div>

                                            <c:if test="${not empty dh.ghiChuDon}">
                                                <div class="p-2 border border-dashed rounded bg-light small mb-2 text-muted" style="font-size: 11px;">
                                                    <i class="bi bi-pencil-square text-warning"></i> <strong>Ghi chú:</strong> <c:out value="${dh.ghiChuDon}"/>
                                                </div>
                                            </c:if>
                                            <c:if test="${dh.trangThaiDon == 5 && not empty dh.lyDoHuy}">
                                                <div class="p-2 border border-danger border-opacity-10 rounded bg-danger bg-opacity-5 small mb-2 text-danger" style="font-size: 11px;">
                                                    <i class="bi bi-exclamation-triangle-fill"></i> <strong>Lý do hủy:</strong> <c:out value="${dh.lyDoHuy}"/>
                                                </div>
                                            </c:if>
                                        </div>

                                        <!-- Footer đơn hàng với các nút bấm touchscreen-friendly -->
                                        <div class="d-flex justify-content-between align-items-center border-top pt-2 mt-2">
                                            <div class="text-start">
                                                <small class="text-muted d-block" style="font-size:10px;">Thành tiền:</small>
                                                <span class="fw-bold text-danger font-monospace" style="font-size: 15px;">
                                                    <fmt:formatNumber value="${dh.tongPhaiTra}" type="currency" currencySymbol=""/>đ
                                                </span>
                                            </div>
                                            <div class="d-flex gap-1.5">
                                                <button type="button" class="btn btn-outline-success btn-sm fw-bold px-2" onclick="loadAndShowPrintReceipt('${dh.maDh}')">
                                                    <i class="bi bi-printer"></i>
                                                </button>
                                                <c:choose>
                                                    <c:when test="${dh.trangThaiDon == 0}">
                                                        <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-2" onclick="cancelOnlineOrder('${dh.maDh}')">HỦY</button>
                                                        <button type="button" class="btn btn-success btn-sm fw-bold px-2.5" onclick="updateOrderStatus('${dh.maDh}', 1)">DUYỆT</button>
                                                    </c:when>
                                                    <c:when test="${dh.trangThaiDon == 1}">
                                                        <button type="button" class="btn btn-warning text-dark btn-sm fw-bold px-2.5" onclick="updateOrderStatus('${dh.maDh}', 2)">PHA CHẾ</button>
                                                    </c:when>
                                                    <c:when test="${dh.trangThaiDon == 2}">
                                                        <button type="button" class="btn btn-info text-white btn-sm fw-bold px-2.5" onclick="updateOrderStatus('${dh.maDh}', 3)">CHO LẤY</button>
                                                    </c:when>
                                                    <c:when test="${dh.trangThaiDon == 3}">
                                                        <button type="button" class="btn btn-success btn-sm fw-bold px-2.5" onclick="updateOrderStatus('${dh.maDh}', 4)">HOÀN TẤT</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="text-center text-muted small py-1 px-2 bg-light rounded border" style="font-size: 10px;">
                                                            Đã đóng 🔒
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="col-12 text-center py-5 text-muted">
                                <i class="bi bi-clock-history fs-1 d-block mb-2 opacity-50 text-success animate-pulse"></i>
                                <h5 class="fw-bold mt-2 text-dark" style="font-size: 14px;">Chưa phát sinh đơn hàng online nào!</h5>
                                <p class="small text-muted mb-0">Hệ thống đang dò quét đơn hàng mới tự động qua cổng SePay Webhook...</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- PAGINATION -->
            <div class="pagination-container" id="ordersPaginationBlock" style="display: none;">
                <span class="small text-muted" id="ordersPaginationInfo">Hiển thị từ 1 đến 6 đơn online</span>
                <nav>
                    <ul class="pagination pagination-sm mb-0 justify-content-end" id="ordersPaginationButtons"></ul>
                </nav>
            </div>
        </main>
    </div>

    <!-- HIDDEN STATUS CONTROLLER FORM -->
    <form id="actionStatusForm" action="${pageContext.request.contextPath}/pos/nhandon" method="POST" style="display:none;">
        <input type="hidden" name="maDh" id="action_maDh">
        <input type="hidden" name="trangThaiMoi" id="action_trangThaiMoi">
        <input type="hidden" name="lyDoHuy" id="action_lyDoHuy">
    </form>
</div>

<!-- RECEIPT PRINTER POPUP -->
<jsp:include page="/views/pos/pos_modals.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    function toggleNhanDonSidebar() {
        const sidebar = document.getElementById('ndSidebar');
        const backdrop = document.getElementById('ndSidebarBackdrop');
        if (sidebar && backdrop) {
            sidebar.classList.toggle('show');
            backdrop.classList.toggle('show');
            if (sidebar.classList.contains('show')) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        }
    }

    function toggleMobileItems(element) {
        const content = element.nextElementSibling;
        const icon = element.querySelector('.bi-chevron-down, .bi-chevron-up');
        if (content.classList.contains('d-none')) {
            content.classList.remove('d-none');
            if (icon) icon.className = 'bi bi-chevron-up text-success';
        } else {
            content.classList.add('d-none');
            if (icon) icon.className = 'bi bi-chevron-down text-muted';
        }
    }

    function updateOrderStatus(maDh, status) {
        Swal.fire({
            title: 'Cập nhật trạng thái?',
            text: 'Xác nhận chuyển đổi trạng thái thực hiện cho đơn ' + maDh + '?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý cập nhật',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('action_maDh').value = maDh;
                document.getElementById('action_trangThaiMoi').value = status;
                document.getElementById('action_lyDoHuy').value = "";
                document.getElementById('actionStatusForm').submit();
            }
        });
    }

    function cancelOnlineOrder(maDh) {
        Swal.fire({
            title: 'TỪ CHỐI ĐƠN ĐẶT ONLINE',
            text: 'Vui lòng nhập lý do hủy đơn bắt buộc:',
            input: 'text',
            inputPlaceholder: 'Khách yêu cầu hủy, hết nguyên liệu pha chế...',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận hủy đơn',
            cancelButtonText: 'Hủy bỏ',
            preConfirm: (value) => {
                if (!value || value.trim() === "") {
                    Swal.showValidationMessage('Bạn phải nhập lý do từ chối đơn hàng!');
                    return false;
                }
                return value.trim();
            }
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('action_maDh').value = maDh;
                document.getElementById('action_trangThaiMoi').value = 5; // HỦY ĐƠN = 5
                document.getElementById('action_lyDoHuy').value = result.value;
                document.getElementById('actionStatusForm').submit();
            }
        });
    }

    let currentPage = 1;
    const pageSize = 6;
    let filteredOrdersList = [];

    function filterAndPaginateOnlineOrders() {
        const searchKeyword = document.getElementById("orderSearchInput").value.trim().toLowerCase();
        const dateKeyword = document.getElementById("orderDateInput").value;
        const allCards = document.querySelectorAll("#ordersGrid .order-card-col");
        filteredOrdersList = [];

        allCards.forEach(card => {
            const cardId = card.getAttribute("data-madh").toLowerCase();
            const cardPhone = card.getAttribute("data-sdt").toLowerCase();
            const cardDate = card.getAttribute("data-date");
            const matchSearch = searchKeyword === "" || cardId.includes(searchKeyword) || cardPhone.includes(searchKeyword);
            const matchDate = dateKeyword === "" || cardDate === dateKeyword;

            if (matchSearch && matchDate) {
                filteredOrdersList.push(card);
            } else {
                card.style.setProperty('display', 'none', 'important');
            }
        });
        currentPage = 1;
        renderOnlineOrders();
    }

    function renderOnlineOrders() {
        const allCards = document.querySelectorAll("#ordersGrid .order-card-col");
        allCards.forEach(card => card.style.setProperty('display', 'none', 'important'));
        const totalRows = filteredOrdersList.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);
        const pageCards = filteredOrdersList.slice(startIdx, endIdx);
        pageCards.forEach(card => card.style.setProperty('display', 'block', 'important'));

        const infoEl = document.getElementById("ordersPaginationInfo");
        if (infoEl) {
            infoEl.innerText = 'Hiển thị từ ' + (totalRows > 0 ? (startIdx + 1) : 0) + ' đến ' + endIdx + ' của ' + totalRows + ' đơn online';
        }

        const buttonsContainer = document.getElementById("ordersPaginationButtons");
        if (buttonsContainer) {
            buttonsContainer.innerHTML = "";
            if (totalPages <= 1) {
                document.getElementById("ordersPaginationBlock").style.setProperty('display', 'none', 'important');
                return;
            }
            document.getElementById("ordersPaginationBlock").style.setProperty('display', 'flex', 'important');

            const prevLi = document.createElement("li");
            prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
            prevLi.innerHTML = '<a class="page-link" href="javascript:void(0)" onclick="changeOrdersPage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
            buttonsContainer.appendChild(prevLi);

            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement("li");
                li.className = "page-item " + (currentPage === i ? "active" : "");
                li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changeOrdersPage(' + i + ')">' + i + '</a>';
                buttonsContainer.appendChild(li);
            }

            const nextLi = document.createElement("li");
            nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
            nextLi.innerHTML = '<a class="page-link" href="javascript:void(0)" onclick="changeOrdersPage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
            buttonsContainer.appendChild(nextLi);
        }
    }

    function changeOrdersPage(newPage) {
        currentPage = newPage;
        renderOnlineOrders();
    }

    function resetOnlineFilters() {
        document.getElementById("orderSearchInput").value = "";
        document.getElementById("orderDateInput").value = "";
        filterAndPaginateOnlineOrders();
    }

    document.addEventListener("DOMContentLoaded", () => {
        filterAndPaginateOnlineOrders();
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') {
            showToast('success', 'Cập nhật trạng thái đơn hàng thành công!');
        } else if (msg === 'updatefailed') {
            showToast('error', 'Cập nhật trạng thái đơn thất bại!');
        }
    });

    setInterval(function() {
        fetch('${pageContext.request.contextPath}/pos/nhandon?action=checkPollingCount&status=' + ${currentStatus})
            .then(res => { if (res.ok) return res.text(); })
            .then(data => {
                const currentCount = ${onlineOrders != null ? onlineOrders.size() : 0};
                if (parseInt(data) !== currentCount && parseInt(data) > 0) {
                    showToast('info', 'Phát hiện có đơn đặt online mới hoặc thanh toán qua SePay!');
                    setTimeout(() => { location.reload(); }, 1500);
                }
            })
            .catch(err => console.log("Polling skipped or offline."));
    }, 5000);
</script>
</body>
</html>