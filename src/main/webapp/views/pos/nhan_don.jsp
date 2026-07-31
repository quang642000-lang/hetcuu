<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Điều Phối Nhận Đơn Online - TEA POS PRO</title>

    <!-- Stylesheets -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">

    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --slate-dark: #0f172a;
            --border-color: #e2e8f0;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --radius-md: 8px;
            --radius-lg: 12px;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background-color: #f8fafc;
            color: var(--text-main);
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* Layout Structure */
        .nhandon-layout {
            display: flex;
            flex: 1;
            overflow: hidden;
            height: calc(100vh - 60px);
        }

        .nd-sidebar {
            width: 280px;
            background-color: #ffffff;
            border-right: 1px solid var(--border-color);
            padding: 20px 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
            flex-shrink: 0;
            overflow-y: auto;
        }

        .nd-content {
            flex-grow: 1;
            padding: 24px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* Sidebar Status Tabs */
        .status-tab {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 20px;
            color: var(--text-muted);
            font-weight: 600;
            text-decoration: none;
            border-left: 4px solid transparent;
            transition: all 0.2s ease;
        }

        .status-tab:hover {
            background-color: #f1f5f9;
            color: var(--primary);
        }

        .status-tab.active {
            background-color: var(--primary-light);
            color: var(--primary);
            border-left-color: var(--primary);
        }

        /* Order Card Customization */
        .order-card {
            background-color: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            transition: all 0.2s ease;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .order-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        .order-card-header {
            background-color: #f8fafc;
            border-bottom: 1px solid var(--border-color);
            padding: 14px 20px;
        }

        .order-card-body {
            padding: 20px;
            flex-grow: 1;
        }

        .order-card-footer {
            background-color: #f8fafc;
            border-top: 1px dashed var(--border-color);
            padding: 14px 20px;
        }

        .item-row {
            padding: 8px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .item-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .topping-tag {
            display: inline-block;
            background-color: #f0fdf4;
            color: #15803d;
            font-size: 10.5px;
            font-weight: 600;
            padding: 2px 8px;
            border-radius: 4px;
            margin-right: 4px;
            margin-top: 2px;
            border: 1px solid rgba(21, 128, 61, 0.1);
        }

        /* Pagination Alignment */
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            background-color: #ffffff;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            margin-top: auto;
        }

        .pagination .page-item.active .page-link {
            background-color: var(--primary) !important;
            border-color: var(--primary) !important;
            color: #ffffff !important;
            font-weight: 600;
        }

        .pagination .page-link {
            color: var(--primary);
        }

        /* Receipt Print Container */
        .receipt-container {
            font-family: 'Courier New', Courier, monospace;
            font-size: 12px;
            line-height: 1.4;
            color: #000000;
            background-color: #ffffff;
            text-align: left;
        }

        .live-polling-badge {
            font-size: 11px;
            letter-spacing: 0.5px;
            animation: pulse-red 1.5s infinite;
        }

        @keyframes pulse-red {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.05); opacity: 0.8; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>

<!-- NAV HEADER -->
<nav class="navbar navbar-dark bg-dark px-3 sticky-top" style="height: 60px; z-index: 1040; flex-shrink: 0;">
    <div class="container-fluid d-flex align-items-center">
        <div class="d-flex align-items-center gap-3">
            <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: var(--primary) !important; font-size: 18px;">
                <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
                <span>TEA POS PRO</span>
            </a>

            <!-- NAVIGATION BUTTONS -->
            <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
                <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-outline-light fw-bold px-3">
                    <i class="bi bi-cart-fill me-1"></i> BÁN TẠI QUẦY
                </a>
                <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-success fw-bold px-3">
                    <i class="bi bi-bell-fill me-1 text-warning"></i> ĐƠN ONLINE
                </a>
            </div>
        </div>

        <div class="d-flex align-items-center gap-3 text-white ms-auto">
                <span class="badge bg-danger p-2 px-3 fw-bold border border-light live-polling-badge">
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

    <!-- SIDEBAR STATUS TABS -->
    <aside class="nd-sidebar">
        <div class="px-3 mb-3 text-start">
            <h6 class="text-uppercase text-secondary fw-bold small m-0" style="letter-spacing: 0.5px;">BỘ LỌC TRẠNG THÁI</h6>
        </div>

        <a href="${pageContext.request.contextPath}/pos/nhandon?status=0" class="status-tab ${currentStatus == 0 ? 'active' : ''}">
            <span><i class="bi bi-hourglass-split me-2"></i> Chờ Xác Nhận</span>
            <span class="badge bg-warning text-dark rounded-pill" style="font-size: 10px;">Yêu cầu</span>
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
        <div class="d-flex justify-content-between align-items-center text-start">
            <div>
                <h3 class="fw-bold m-0 text-dark">
                    <c:choose>
                        <c:when test="${currentStatus == 0}">Đơn hàng Chờ xác nhận</c:when>
                        <c:when test="${currentStatus == 1}">Đơn hàng Đã xác nhận</c:when>
                        <c:when test="${currentStatus == 2}">Đơn hàng Đang pha chế</c:when>
                        <c:when test="${currentStatus == 3}">Đơn hàng Chờ lấy hàng</c:when>
                        <c:when test="${currentStatus == 4}">Đơn hàng Hoàn thành</c:when>
                        <c:otherwise>Đơn hàng Đã hủy bỏ</c:otherwise>
                    </c:choose>
                </h3>
                <p class="text-muted m-0 small mt-1">Danh sách đơn đặt trước (Click & Collect) qua Website Portal của hội viên CRM</p>
            </div>
            <button type="button" class="btn btn-outline-secondary btn-sm fw-bold shadow-sm" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise"></i> LÀM MỚI TRANG
            </button>
        </div>

        <!-- THANH TÌM KIẾM & LỌC NGÀY ĐỒNG BỘ -->
        <div class="card card-teapos p-3 border-0 shadow-sm text-start" style="border-radius: 12px; background-color: #ffffff;">
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

        <!-- DANH SÁCH ĐƠN HÀNG HÓA CARD-GRID -->
        <div class="orders-grid-wrapper">
            <div class="row g-4" id="ordersGrid">
                <c:choose>
                    <c:when test="${not empty onlineOrders}">
                        <c:forEach var="dh" items="${onlineOrders}">
                            <div class="col-12 col-md-6 col-xl-4 order-card-col"
                                 data-madh="${dh.maDh}"
                                 data-makh="${dh.maKh}"
                                 data-sdt="${dh.maKh}"
                                 data-date="<fmt:formatDate value="${dh.thoiGianTao}" pattern="yyyy-MM-dd"/>">
                                <div class="order-card">

                                    <!-- Header đơn hàng -->
                                    <div class="order-card-header d-flex justify-content-between align-items-center">
                                        <div class="text-start">
                                            <h5 class="fw-bold mb-0 text-success font-monospace">${dh.maDh}</h5>
                                            <small class="text-muted" style="font-size: 11px;">Đặt: <fmt:formatDate value="${dh.thoiGianTao}" pattern="HH:mm dd/MM"/></small>
                                        </div>
                                        <span class="badge ${dh.trangThaiThanhToan == 1 ? 'bg-success' : 'bg-warning'} text-white rounded-pill px-2.5 py-1" style="font-size:10px;">
                                                ${dh.trangThaiThanhToan == 1 ? 'Đã thanh toán' : 'Chờ trả tiền mặt'}
                                        </span>
                                    </div>

                                    <!-- Body đơn hàng -->
                                    <div class="order-card-body">
                                        <!-- Mốc giờ hẹn lấy nước -->
                                        <div class="p-2.5 bg-light rounded text-dark small mb-3 border border-dashed border-success text-start">
                                            <i class="bi bi-alarm-fill text-danger me-1"></i> HẸN ĐẾN QUẦY LẤY:
                                            <strong><fmt:formatDate value="${dh.thoiGianHenLay}" pattern="HH:mm (dd/MM)"/></strong>
                                        </div>

                                        <div class="mb-3 border-bottom pb-2 text-start">
                                            <small class="text-muted d-block" style="font-size: 11px;">Hội viên thanh toán</small>
                                            <strong class="text-dark small"><i class="bi bi-person-fill text-success"></i> Khách hàng: <c:out value="${not empty dh.maKh ? dh.maKh : 'Khách lẻ vãng lai'}"/></strong>
                                        </div>

                                        <!-- Chi tiết các món uống nạp trước động -->
                                        <div class="mb-2 text-start">
                                            <c:forEach var="item" items="${dh.chiTietDonHangList}">
                                                <div class="item-row">
                                                    <div class="d-flex justify-content-between align-items-start">
                                                        <div>
                                                            <span class="fw-bold text-dark" style="font-size:13px;"><c:out value="${item.tenSp}"/></span>
                                                            <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-20 ms-1" style="font-size: 9.5px;">Size <c:out value="${item.tenSize}"/></span>
                                                            <span class="text-muted fw-bold font-monospace ms-1.5" style="font-size:12px;">x<c:out value="${item.soLuong}"/></span>
                                                        </div>
                                                        <span class="fw-bold text-secondary font-monospace" style="font-size:12.5px;">
                                                                <fmt:formatNumber value="${item.giaChot * item.soLuong}" type="currency" currencySymbol=""/>đ
                                                            </span>
                                                    </div>

                                                    <!-- Ice, Sugar options - ẨN KHI LÀ N/A (BÁNH NGỌT/ĐỒ ĂN) -->
                                                    <div class="text-muted small" style="font-size: 11px; margin-top:2px;">
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

                                                    <!-- Topping details -->
                                                    <c:if test="${not empty item.toppingsList}">
                                                        <div class="mt-1">
                                                            <c:forEach var="tp" items="${item.toppingsList}">
                                                                <span class="topping-tag">+ <c:out value="${tp.tenTopping}"/> (x<c:out value="${tp.soLuong}"/>)</span>
                                                            </c:forEach>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <c:if test="${not empty dh.ghiChuDon}">
                                            <div class="p-2 border border-dashed rounded bg-light small mb-2 text-muted text-start">
                                                <i class="bi bi-pencil-square text-warning"></i> <strong>Ghi chú đơn:</strong> <c:out value="${dh.ghiChuDon}"/>
                                            </div>
                                        </c:if>
                                        <c:if test="${dh.trangThaiDon == 5 && not empty dh.lyDoHuy}">
                                            <div class="p-2 border border-danger border-opacity-10 rounded bg-danger bg-opacity-5 small mb-2 text-danger text-start">
                                                <i class="bi bi-exclamation-triangle-fill"></i> <strong>Lý do hủy đơn:</strong> <c:out value="${dh.lyDoHuy}"/>
                                            </div>
                                        </c:if>
                                    </div>

                                    <!-- Footer đơn hàng -->
                                    <div class="order-card-footer d-flex justify-content-between align-items-center">
                                        <div class="text-start">
                                            <small class="text-muted d-block" style="font-size:11px;">Thành tiền:</small>
                                            <span class="fw-bold text-danger font-monospace fs-5">
                                                    <fmt:formatNumber value="${dh.tongPhaiTra}" type="currency" currencySymbol=""/>đ
                                                </span>
                                        </div>
                                        <div class="d-flex gap-1.5">
                                            <!-- Nút in hóa đơn nhanh -->
                                            <button type="button" class="btn btn-outline-success btn-sm fw-bold px-2.5" onclick="loadAndShowPrintReceipt('${dh.maDh}')">
                                                <i class="bi bi-printer"></i>
                                            </button>

                                            <!-- Các mốc điều hành trạng thái -->
                                            <c:choose>
                                                <c:when test="${dh.trangThaiDon == 0}">
                                                    <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-2.5" onclick="cancelOnlineOrder('${dh.maDh}')">HỦY</button>
                                                    <button type="button" class="btn btn-success btn-sm fw-bold px-3" onclick="updateOrderStatus('${dh.maDh}', 1)">DUYỆT</button>
                                                </c:when>
                                                <c:when test="${dh.trangThaiDon == 1}">
                                                    <button type="button" class="btn btn-warning text-dark btn-sm fw-bold px-3" onclick="updateOrderStatus('${dh.maDh}', 2)">PHA CHẾ</button>
                                                </c:when>
                                                <c:when test="${dh.trangThaiDon == 2}">
                                                    <button type="button" class="btn btn-info text-white btn-sm fw-bold px-3" onclick="updateOrderStatus('${dh.maDh}', 3)">CHO LẤY</button>
                                                </c:when>
                                                <c:when test="${dh.trangThaiDon == 3}">
                                                    <button type="button" class="btn btn-success btn-sm fw-bold px-3" onclick="updateOrderStatus('${dh.maDh}', 4)">HOÀN TẤT</button>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="text-center text-muted small py-1.5 px-2 bg-light rounded border" style="font-size: 11px;">
                                                        Đơn đã đóng 🔒
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
                            <i class="bi bi-clock-history fs-1 d-block mb-2 opacity-50 text-success"></i>
                            Không có đơn đặt online nào trong trạng thái lọc hiện hành!
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- PHÂN TRANG CARD-BASED ĐỒNG BỘ -->
        <div class="pagination-container" id="ordersPaginationBlock" style="display: none;">
            <span class="small text-muted" id="ordersPaginationInfo">Hiển thị từ 1 đến 6 đơn hàng đặt online</span>
            <nav>
                <ul class="pagination pagination-sm mb-0 justify-content-end" id="ordersPaginationButtons"></ul>
            </nav>
        </div>

    </main>
</div>

<!-- HIDDEN FORM GỬI CẬP NHẬT TRẠNG THÁI -->
<form id="actionStatusForm" action="${pageContext.request.contextPath}/pos/nhandon" method="POST" style="display:none;">
    <input type="hidden" name="maDh" id="action_maDh">
    <input type="hidden" name="trangThaiMoi" id="action_trangThaiMoi">
    <input type="hidden" name="lyDoHuy" id="action_lyDoHuy">
</form>

<!-- POPUP IN BILL THANH TOÁN (RECEIPT MODAL) -->
<div class="modal fade" id="receiptDetailModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 340px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark receipt-container" id="billPrintArea">
                <div class="text-center mb-2">
                    <strong style="font-size: 15px; letter-spacing: 1px; text-align: center; display: block;">TEA POS CAFÉ</strong>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px; text-align: center; display: block;">HÓA ĐƠN BÁN LẺ TẠI QUẦY</strong>
                    <span style="font-size: 10px; text-align: center; display: block;" id="billThoiGian"></span>
                </div>

                <div class="mb-2" style="font-size: 10px; line-height: 1.4;">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                </div>

                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer" style="font-size: 10.5px;"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>

                <div class="small" style="font-size: 10px; line-height: 1.5;">
                    <div class="d-flex justify-content-between mb-1">
                        <span>Tổng tiền nước gốc:</span>
                        <strong id="billRawPrice"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger mb-1" id="billDiscountRow" style="display: none;">
                        <span>Khấu trừ Voucher:</span>
                        <strong id="billDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-primary mb-1" id="billPointsRow" style="display: none;">
                        <span>Tiêu điểm CRM:</span>
                        <strong id="billPointsDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                        <span>Thuế VAT (8%):</span>
                        <strong id="billVatPrice"></strong>
                    </div>
                    <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                    <div class="d-flex justify-content-between fw-bold text-success" style="font-size: 12px; margin-bottom: 4px;">
                        <span>CẦN THANH TOÁN:</span>
                        <span id="billFinalPayable"></span>
                    </div>
                </div>

                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="text-center mt-3" style="font-size: 9px; color: #444; text-align: center;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br><i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light border-0 d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-secondary fw-bold px-3" data-bs-dismiss="modal">ĐÓNG</button>
                <button type="button" class="btn btn-sm btn-success fw-bold px-3" onclick="printReceipt()"><i class="bi bi-printer"></i> IN HÓA ĐƠN</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    // Cập nhật trạng thái đơn đặt online nhanh
    function updateOrderStatus(maDh, status) {
        Swal.fire({
            title: 'Cập nhật trạng thái đơn?',
            text: 'Xác nhận chuyển đổi trạng thái thực hiện pha chế cho đơn ' + maDh + '?',
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

    // Hủy đơn đặt online có nhập lý do
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

    // Khởi tạo Modal In hóa đơn
    const receiptModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));

    // Load và hiển thị popup hóa đơn tạm
    function loadAndShowPrintReceipt(orderId) {
        const container = document.getElementById("billItemsContainer");
        if (!container) return;

        container.innerHTML = '<div class="text-center py-4">' +
            '  <div class="spinner-border text-success" role="status"></div>' +
            '  <p class="small text-muted mt-2">Đang nạp thông tin hóa đơn...</p>' +
            '</div>';

        receiptModal.show();

        fetch('${pageContext.request.contextPath}/pos/bill-detail?id=' + orderId)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById("billMaDh").innerText = data.maDh;
                    document.getElementById("billThoiGian").innerText = data.thoiGianTao;
                    document.getElementById("billTenKh").innerText = data.tenKhachHang ? data.tenKhachHang : 'Khách lẻ vãng lai';
                    document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Đặt mua Online';

                    document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';

                    if (parseInt(data.tienGiamGia) > 0) {
                        document.getElementById("billDiscountRow").style.setProperty('display', 'flex', 'important');
                    } else {
                        document.getElementById("billDiscountRow").style.setProperty('display', 'none', 'important');
                    }

                    if (data.diemSuDung > 0) {
                        document.getElementById("billPointsRow").style.setProperty('display', 'flex', 'important');
                        document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                    } else {
                        document.getElementById("billPointsRow").style.setProperty('display', 'none', 'important');
                    }

                    let rawSum = parseInt(data.tongTienHang) || 0;
                    let disc = parseInt(data.tienGiamGia) || 0;
                    let ptsDisc = parseInt(data.tienTruDiem) || 0;
                    let billBeforeTax = rawSum - disc - ptsDisc;
                    if (billBeforeTax < 0) billBeforeTax = 0;
                    let vatPrice = Math.round(billBeforeTax * 0.08);

                    document.getElementById("billVatPrice").innerText = vatPrice.toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div class="mb-2 border-bottom pb-1">';
                        html += '  <div class="d-flex justify-content-between">';
                        html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                        html += '    <span>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</span>';
                        html += '  </div>';

                        // Ẩn Đá/Đường nếu cấu hình là N/A
                        let iceStr = item.mucDa !== 'N/A' ? 'Đá: ' + item.mucDa : '';
                        let sugarStr = item.mucDuong !== 'N/A' ? 'Đường: ' + item.mucDuong : '';
                        let delim = (iceStr && sugarStr) ? ' | ' : '';
                        let configLine = iceStr + delim + sugarStr;
                        if (item.ghiChuMon && item.ghiChuMon !== 'Normal') {
                            configLine += (configLine ? ' | ' : '') + 'Lưu ý: ' + item.ghiChuMon;
                        }
                        if (configLine) {
                            html += '  <div class="small text-muted">' + configLine + '</div>';
                        }

                        if (item.toppings && item.toppings.length > 0) {
                            html += '  <div class="text-success small pl-2" style="font-size: 10px;">';
                            item.toppings.forEach(tp => {
                                html += '    <div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                            });
                            html += '  </div>';
                        }
                        html += '</div>';
                        container.insertAdjacentHTML('beforeend', html);
                    });
                } else {
                    showToast('error', 'Không thể nạp thông tin hóa đơn!');
                    receiptModal.hide();
                }
            })
            .catch(err => {
                console.error("Lỗi nạp hóa đơn:", err);
                showToast('error', 'Không thể kết nối máy chủ!');
                receiptModal.hide();
            });
    }

    // In hóa đơn nhiệt tại quầy
    function printReceipt() {
        const printContent = document.getElementById("billPrintArea").innerHTML;
        const originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload();
    }

    // =====================================================================
    // PHÂN TRANG CARD-BASED & BỘ LỌC TÌM KIẾM ĐƠN HÀNG ONLINE
    // =====================================================================
    let currentPage = 1;
    const pageSize = 6; // Đặt cố định hiển thị 6 đơn hàng / trang cho ngăn nắp
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

        // Cập nhật thông số dải đếm dòng
        const infoEl = document.getElementById("ordersPaginationInfo");
        if (infoEl) {
            infoEl.innerText = 'Hiển thị từ ' + (totalRows > 0 ? (startIdx + 1) : 0) + ' đến ' + endIdx + ' dòng trên tổng số ' + totalRows + ' đơn đặt online';
        }

        // Vẽ dải nút phân trang màu Emerald mượt mà
        const buttonsContainer = document.getElementById("ordersPaginationButtons");
        if (buttonsContainer) {
            buttonsContainer.innerHTML = "";
            if (totalPages <= 1) {
                document.getElementById("ordersPaginationBlock").style.setProperty('display', 'none', 'important');
                return;
            }

            document.getElementById("ordersPaginationBlock").style.setProperty('display', 'flex', 'important');

            // Nút Trước
            const prevLi = document.createElement("li");
            prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
            prevLi.innerHTML = '<a class="page-link" href="javascript:void(0)" onclick="changeOrdersPage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
            buttonsContainer.appendChild(prevLi);

            // Trang số
            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement("li");
                li.className = "page-item " + (currentPage === i ? "active" : "");
                li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changeOrdersPage(' + i + ')">' + i + '</a>';
                buttonsContainer.appendChild(li);
            }

            // Nút Sau
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

        // Kiểm tra thông báo lưu thay đổi từ server chuyển về
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') {
            showToast('success', 'Đã chuyển trạng thái và gửi thông báo đơn hàng thành công!');
        } else if (msg === 'updatefailed') {
            showToast('error', 'Cập nhật trạng thái đơn thất bại!');
        }
    });

    // Ajax live polling rà soát đơn online mới 5 giây/lần
    setInterval(function() {
        fetch('${pageContext.request.contextPath}/pos/nhandon?action=checkPollingCount&status=' + ${currentStatus})
            .then(res => res.text())
            .then(data => {
                const currentCount = ${onlineOrders != null ? onlineOrders.size() : 0};
                if (parseInt(data) !== currentCount && parseInt(data) > 0) {
                    showToast('info', 'Phát hiện có đơn đặt online mới hoặc thanh toán qua SePay!');
                    setTimeout(() => { location.reload(); }, 1500);
                }
            })
            .catch(err => console.error("Lỗi Polling:", err));
    }, 5000);
</script>
</body>
</html>