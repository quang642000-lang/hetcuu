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
    <nav class="navbar navbar-dark bg-dark px-2 px-sm-3 sticky-top" style="height: 60px; z-index: 1040; flex-shrink: 0;">
        <div class="container-fluid d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-1 gap-sm-3">
                <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 16px; font-size: 18px;">
                    <i class="bi bi-cup-hot-fill me-1 me-sm-2 fs-4 text-success animate-pulse"></i>
                    <span class="d-none d-sm-inline">TEA POS PRO</span>
                    <span class="d-inline d-sm-none">TEA POS</span>
                </a>
                <div class="d-flex align-items-center gap-1 gap-sm-2 border-start ps-1.5 ps-sm-3 border-secondary" style="height: 30px;">
                    <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-outline-light fw-bold px-2 px-sm-3 d-flex align-items-center gap-1" style="font-size: 11px; font-size: 12px;">
                        <i class="bi bi-cart-fill text-warning"></i>
                        <span class="d-none d-sm-inline">TẠI QUẦY</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-success fw-bold px-2 px-sm-3 d-flex align-items-center gap-1" style="font-size: 11px; font-size: 12px;">
                        <i class="bi bi-bell-fill me-1 text-warning animate-pulse"></i>
                        <span class="d-none d-sm-inline">ONLINE</span>
                    </a>
                </div>
            </div>

            <div class="d-flex align-items-center gap-1.5 gap-sm-3 text-white ms-auto">
                <span class="badge p-1.5 p-sm-2 px-sm-3 fw-bold live-polling-badge d-flex align-items-center gap-1" style="font-size: 10px; font-size: 11px;">
                    <span class="animate-pulse">🔴</span>
                    <span class="d-none d-sm-inline">LIVE POLLING</span>
                </span>

                <div class="dropdown border-end pe-1.5 pe-sm-3 border-secondary">
                    <a class="dropdown-toggle text-decoration-none text-white small fw-semibold d-flex align-items-center gap-1" href="#" role="button" id="adminProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-badge-fill text-success fs-5"></i>
                        <span class="d-none d-md-inline">Thu ngân: <c:out value="${sessionScope.user.hoTen}"/></span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posProfileModal"><i class="bi bi-person-circle me-2 text-success"></i>Cài đặt cá nhân</a></li>
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posPasswordModal"><i class="bi bi-key-fill me-2 text-warning"></i>Đổi mật khẩu</a></li>
                    </ul>
                </div>

                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase d-flex align-items-center gap-1 px-1.5 px-sm-2.5" style="font-size: 11px;" title="Quản trị Admin">
                    <i class="bi bi-shield-lock-fill"></i>
                    <span class="d-none d-md-inline">Admin</span>
                </a>

                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger fw-bold px-2 px-sm-3 shadow-sm d-flex align-items-center gap-1" style="font-size: 11px; font-size: 12px; border-radius: 6px;" title="Đăng xuất">
                    <i class="bi bi-box-arrow-right"></i>
                    <span class="d-none d-md-inline">ĐĂNG XUẤT</span>
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

            <c:if test="${currentStatus == 5}">
                <div class="mb-3 d-flex flex-wrap gap-2 justify-content-start animate-fade-in">
                    <button type="button" class="btn btn-sm btn-secondary active-sub-filter px-3 py-1.5 fw-bold rounded-pill shadow-sm" id="sub_filter_all" onclick="filterCanceledByPayment('all')">
                        Tất cả đơn hủy (${onlineOrders != null ? onlineOrders.size() : 0})
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-warning text-dark px-3 py-1.5 fw-bold rounded-pill shadow-sm" id="sub_filter_paid" onclick="filterCanceledByPayment('paid')">
                        <span class="spinner-grow spinner-grow-sm text-danger me-1" role="status" style="width: 8px; height: 8px; vertical-align: middle;"></span>
                        Đã thanh toán (Chờ hoàn tiền)
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary px-3 py-1.5 fw-bold rounded-pill shadow-sm" id="sub_filter_unpaid" onclick="filterCanceledByPayment('unpaid')">
                        Chưa thanh toán
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-success px-3 py-1.5 fw-bold rounded-pill shadow-sm" id="sub_filter_refunded" onclick="filterCanceledByPayment('refunded')">
                        Đã hoàn tiền ✓
                    </button>
                </div>
            </c:if>

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
                                     data-date="<fmt:formatDate value="${dh.thoiGianTao}" pattern="yyyy-MM-dd"/>"
                                     data-paymentstatus="${dh.trangThaiThanhToan}">
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
                                                        <c:choose>
                                                            <c:when test="${dh.trangThaiDon == 5 && dh.trangThaiThanhToan == 1}">
                                                                <button type="button" class="btn btn-danger btn-sm fw-bold px-2.5 d-flex align-items-center gap-1 shadow-sm" onclick="refundOnlineOrder('${dh.maDh}', '${dh.tongPhaiTra}')">
                                                                    <i class="bi bi-arrow-counterclockwise animate-spin"></i> HOÀN TIỀN
                                                                </button>
                                                            </c:when>
                                                            <c:when test="${dh.trangThaiDon == 5 && dh.trangThaiThanhToan == 2}">
                                                                <div class="text-center text-success small py-1 px-2.5 bg-success bg-opacity-10 border border-success rounded fw-bold" style="font-size: 10px;">
                                                                    Đã hoàn tiền ✓
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="text-center text-muted small py-1 px-2 bg-light rounded border" style="font-size: 10px;">
                                                                    Đã đóng 🔒
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
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
        <input type="hidden" name="action" id="action_type" value="updateStatus">
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
            const paymentStatus = card.getAttribute("data-paymentstatus");
            const matchSearch = searchKeyword === "" || cardId.includes(searchKeyword) || cardPhone.includes(searchKeyword);
            const matchDate = dateKeyword === "" || cardDate === dateKeyword;

            let matchPayment = true;
            if (${currentStatus == 5}) {
                if (currentPaymentFilter === 'paid') {
                    matchPayment = (paymentStatus === '1');
                } else if (currentPaymentFilter === 'unpaid') {
                    matchPayment = (paymentStatus === '0');
                } else if (currentPaymentFilter === 'refunded') {
                    matchPayment = (paymentStatus === '2');
                }
            }

            if (matchSearch && matchDate && matchPayment) {
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

    let currentPaymentFilter = 'all';

    function filterCanceledByPayment(filterType) {
        currentPaymentFilter = filterType;
        document.querySelectorAll('[id^="sub_filter_"]').forEach(btn => {
            btn.classList.remove('btn-secondary', 'btn-warning', 'btn-success', 'active-sub-filter', 'text-white', 'text-dark');
            btn.classList.add('btn-outline-secondary');
        });

        const activeBtn = document.getElementById('sub_filter_' + filterType);
        if (activeBtn) {
            activeBtn.classList.remove('btn-outline-secondary');
            if (filterType === 'all') {
                activeBtn.classList.add('btn-secondary', 'text-white', 'active-sub-filter');
            } else if (filterType === 'paid') {
                activeBtn.classList.add('btn-warning', 'text-dark', 'active-sub-filter');
            } else if (filterType === 'unpaid') {
                activeBtn.classList.add('btn-secondary', 'text-white', 'active-sub-filter');
            } else if (filterType === 'refunded') {
                activeBtn.classList.add('btn-success', 'text-white', 'active-sub-filter');
            }
        }

        filterAndPaginateOnlineOrders();
    }

    function refundOnlineOrder(maDh, amount) {
        Swal.fire({
            title: 'Xác nhận hoàn tiền?',
            html: 'Đơn hàng <strong>' + maDh + '</strong> đã thanh toán <strong class="text-danger">' + parseInt(amount).toLocaleString('vi-VN') + ' đ</strong>.<br>Bạn có chắc chắn đã chuyển hoàn tiền thủ công cho khách và muốn đánh dấu đơn này là <strong>Đã hoàn tiền</strong>?',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận đã hoàn',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('action_maDh').value = maDh;
                document.getElementById('action_trangThaiMoi').value = 5;
                document.getElementById('action_type').value = "refund";
                document.getElementById('action_lyDoHuy').value = "Đã chuyển trả lại tiền cho khách hàng.";
                document.getElementById('actionStatusForm').submit();
            }
        });
    }

    document.addEventListener("DOMContentLoaded", () => {
        filterAndPaginateOnlineOrders();
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
