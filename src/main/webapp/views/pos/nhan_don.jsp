<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Nhận Đơn Online - TEA POS</title>
    <!-- Stylesheets -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.7.32/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/global.css">
    <style>
        body {
            background-color: #f1f5f9;
            font-family: 'Inter', sans-serif;
            height: 100vh !important;
            overflow: hidden !important;
            display: flex;
            flex-direction: column;
        }
        .nd-header {
            height: 56px;
            background-color: #0f172a;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            flex-shrink: 0;
            z-index: 1030;
        }
        .nd-main {
            height: calc(100vh - 56px);
            display: flex;
            overflow: hidden;
        }
        .nd-sidebar {
            width: 260px;
            background-color: white;
            border-right: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            flex-shrink: 0;
            padding: 16px 0;
        }
        .nd-content {
            flex-grow: 1;
            overflow-y: auto;
            padding: 20px;
            background-color: #f8fafc;
        }
        .status-tab {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            color: #64748b;
            font-weight: 600;
            font-size: 13.5px;
            border-left: 4px solid transparent;
            transition: all 0.15s ease;
            text-decoration: none;
        }
        .status-tab:hover {
            background-color: #f8fafc;
            color: #10b981;
        }
        .status-tab.active {
            background-color: #ecfdf5;
            color: #10b981;
            border-left-color: #10b981;
        }
        .order-card {
            background-color: white;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            transition: all 0.2s ease;
            overflow: hidden;
        }
        .order-card:hover {
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        .order-card-header {
            background-color: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            padding: 12px 16px;
        }
        .order-card-body {
            padding: 16px;
        }
        .order-card-footer {
            background-color: #f8fafc;
            border-top: 1px dashed #e2e8f0;
            padding: 12px 16px;
        }
        .item-row {
            padding: 8px 0;
            border-bottom: 1px solid #f1f5f9;
        }
        .item-row:last-child {
            border-bottom: none;
        }
        .topping-tag {
            font-size: 11px;
            background-color: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
            border-radius: 4px;
            padding: 1px 6px;
            display: inline-block;
            margin-top: 2px;
            margin-right: 4px;
        }
    </style>
</head>
<body>

<!-- Header Navigation -->
<header class="nd-header">
    <div class="d-flex align-items-center gap-3">
        <h4 class="m-0 fw-bold text-success"><i class="bi bi-bell-fill"></i> NHẬN ĐƠN ONLINE</h4>
        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 py-1.5 px-2.5 small">
                Nhân viên quầy: <c:out value="${sessionScope.user.hoTen}"/>
            </span>
    </div>
    <div class="d-flex align-items-center gap-2">
        <a href="${pageContext.request.contextPath}/pos" class="btn btn-outline-success btn-sm fw-bold">
            <i class="bi bi-cup-hot-fill"></i> TRANG QUẦY POS
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger btn-sm fw-bold">
            <i class="bi bi-box-arrow-right"></i> ĐĂNG XUẤT
        </a>
    </div>
</header>

<!-- Main Container -->
<div class="nd-main">

    <!-- Status Tabs Sidebar -->
    <aside class="nd-sidebar">
        <div class="px-3 mb-3 text-start">
            <h6 class="text-uppercase text-secondary fw-bold small m-0" style="letter-spacing: 0.5px;">BỘ LỌC ĐƠN HÀNG</h6>
        </div>

        <a href="${pageContext.request.contextPath}/pos/nhandon?status=0" class="status-tab ${currentStatus == 0 ? 'active' : ''}">
            <span><i class="bi bi-hourglass-split me-2"></i> Chờ xác nhận</span>
            <span class="badge bg-warning text-dark rounded-pill" style="font-size:10px;">HOT</span>
        </a>
        <a href="${pageContext.request.contextPath}/pos/nhandon?status=1" class="status-tab ${currentStatus == 1 ? 'active' : ''}">
            <span><i class="bi bi-check-circle me-2"></i> Đã xác nhận</span>
        </a>
        <a href="${pageContext.request.contextPath}/pos/nhandon?status=2" class="status-tab ${currentStatus == 2 ? 'active' : ''}">
            <span><i class="bi bi-fire me-2"></i> Đang pha chế</span>
        </a>
        <a href="${pageContext.request.contextPath}/pos/nhandon?status=3" class="status-tab ${currentStatus == 3 ? 'active' : ''}">
            <span><i class="bi bi-box-seam me-2"></i> Chờ lấy hàng</span>
        </a>
        <a href="${pageContext.request.contextPath}/pos/nhandon?status=4" class="status-tab ${currentStatus == 4 ? 'active' : ''}">
            <span><i class="bi bi-flag-fill me-2"></i> Hoàn thành</span>
        </a>
        <a href="${pageContext.request.contextPath}/pos/nhandon?status=5" class="status-tab ${currentStatus == 5 ? 'active' : ''}">
            <span><i class="bi bi-x-octagon me-2"></i> Đã hủy</span>
        </a>
    </aside>

    <!-- Orders List Area -->
    <main class="nd-content">
        <div class="d-flex justify-content-between align-items-center mb-4 text-start">
            <div>
                <h3 class="fw-bold m-0 text-dark">
                    <c:choose>
                        <c:when test="${currentStatus == 0}">Đơn hàng Chờ xác nhận</c:when>
                        <c:when test="${currentStatus == 1}">Đơn hàng Đã xác nhận</c:when>
                        <c:when test="${currentStatus == 2}">Đơn hàng Đang pha chế</c:when>
                        <c:when test="${currentStatus == 3}">Đơn hàng Chờ lấy</c:when>
                        <c:when test="${currentStatus == 4}">Đơn hàng Hoàn tất</c:when>
                        <c:otherwise>Đơn hàng Đã hủy</c:otherwise>
                    </c:choose>
                </h3>
                <p class="text-muted m-0 small mt-1">Danh sách đơn đặt trước (Click & Collect) qua Website Portal của hội viên</p>
            </div>
            <button type="button" class="btn btn-outline-secondary btn-sm fw-bold" onclick="location.reload()">
                <i class="bi bi-arrow-clockwise"></i> Làm mới trang
            </button>
        </div>

        <c:choose>
            <c:when test="${empty onlineOrders}">
                <div class="text-center text-muted py-5 bg-white rounded-4 border border-dashed my-4">
                    <i class="bi bi-inbox fs-1 text-secondary opacity-25"></i>
                    <p class="mt-2 fw-semibold m-0">Không có đơn đặt online nào trong mục này.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row g-4">
                    <c:forEach var="dh" items="${onlineOrders}">
                        <div class="col-12 col-xl-6 text-start">
                            <div class="order-card">

                                <!-- Header: Code and Date -->
                                <div class="order-card-header d-flex justify-content-between align-items-center">
                                    <div>
                                        <span class="fw-bold text-success font-monospace" style="font-size: 15px;"><c:out value="${dh.maDh}"/></span>
                                        <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 ms-1.5" style="font-size:10px;">
                                                Đặt: <fmt:formatDate value="${dh.thoiGianTao}" pattern="HH:mm dd/MM"/>
                                            </span>
                                    </div>
                                    <div class="d-flex align-items-center gap-1.5">
                                        <i class="bi bi-clock-fill text-warning"></i>
                                        <span class="fw-bold text-warning font-monospace" style="font-size:13.5px;">
                                                Hẹn lấy: <fmt:formatDate value="${dh.thoiGianHenLay}" pattern="HH:mm"/>
                                            </span>
                                    </div>
                                </div>

                                <!-- Body: Customer and Items list -->
                                <div class="order-card-body">
                                    <div class="d-flex justify-content-between mb-3 border-bottom pb-2">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:13.5px;">
                                                <i class="bi bi-person"></i> <c:out value="${dh.maKh != null ? 'Hội viên' : 'Khách vãng lai'}"/>
                                            </div>
                                            <div class="small text-muted" style="font-size:11.5px; margin-top:1px;">
                                                <i class="bi bi-telephone"></i> SĐT: <c:out value="${dh.maKh != null ? '0909999999' : 'N/A'}"/>
                                            </div>
                                        </div>
                                        <div class="text-end">
                                            <div>
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25" style="font-size: 10px;">
                                                        <c:out value="${dh.maPt == 1 ? 'Tiền mặt' : 'Chuyển khoản VietQR'}"/>
                                                    </span>
                                            </div>
                                            <div class="small text-muted mt-1" style="font-size:11px;">
                                                Thanh toán:
                                                <span class="fw-bold ${dh.trangThaiThanhToan == 1 ? 'text-success' : 'text-danger'}">
                                                        <c:out value="${dh.trangThaiThanhToan == 1 ? 'Đã trả' : 'Chưa trả'}"/>
                                                    </span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Detail of drinks -->
                                    <div class="mb-3">
                                        <c:forEach var="item" items="${dh.chiTietDonHangList}">
                                            <div class="item-row">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div>
                                                        <span class="fw-bold text-dark" style="font-size:13.5px;"><c:out value="${item.tenSp}"/></span>
                                                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-20 ms-1" style="font-size: 9.5px;">Size <c:out value="${item.tenSize}"/></span>
                                                        <span class="text-muted fw-bold font-monospace ms-1.5" style="font-size:12.5px;">x<c:out value="${item.soLuong}"/></span>
                                                    </div>
                                                    <span class="fw-bold text-secondary font-monospace" style="font-size:13px;">
                                                            <fmt:formatNumber value="${item.giaChot * item.soLuong}" type="currency" currencySymbol=""/>đ
                                                        </span>
                                                </div>

                                                <!-- Ice, Sugar options -->
                                                <div class="text-muted small" style="font-size: 11px; margin-top:2px;">
                                                    <c:choose>
                                                        <c:when test="${item.mucDa != 'N/A' || item.mucDuong != 'N/A'}">
                                                            <c:if test="${item.mucDa != 'N/A'}">Đá: <c:out value="${item.mucDa}"/> | </c:if>
                                                            <c:if test="${item.mucDuong != 'N/A'}">Đường: <c:out value="${item.mucDuong}"/></c:if>
                                                            <c:if test="${not empty item.ghiChuMon && item.ghiChuMon != 'Normal'}"> | Ghi chú: <span class="text-danger fw-semibold"><c:out value="${item.ghiChuMon}"/></span></c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:if test="${not empty item.ghiChuMon && item.ghiChuMon != 'Normal' && item.ghiChuMon != ''}">Ghi chú: <span class="text-danger fw-semibold"><c:out value="${item.ghiChuMon}"/></span></c:if>
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
                                        <div class="p-2 border border-dashed rounded bg-light small mb-3 text-muted">
                                            <i class="bi bi-pencil-square text-warning"></i> <strong>Ý kiến của khách:</strong> <c:out value="${dh.ghiChuDon}"/>
                                        </div>
                                    </c:if>

                                    <c:if test="${dh.trangThaiDon == 5 && not empty dh.lyDoHuy}">
                                        <div class="p-2 border border-danger border-opacity-10 rounded bg-danger bg-opacity-5 small mb-3 text-danger">
                                            <i class="bi bi-exclamation-triangle-fill"></i> <strong>Lý do hủy đơn:</strong> <c:out value="${dh.lyDoHuy}"/>
                                        </div>
                                    </c:if>
                                </div>

                                <!-- Footer: Totals and Action Buttons -->
                                <div class="order-card-footer d-flex justify-content-between align-items-center">
                                    <div class="text-start">
                                        <small class="text-muted d-block" style="font-size:11px;">Phải thanh toán:</small>
                                        <span class="fw-bold text-danger font-monospace fs-5">
                                                <fmt:formatNumber value="${dh.tongPhaiTra}" type="currency" currencySymbol=""/>đ
                                            </span>
                                    </div>

                                    <div class="d-flex gap-2">
                                        <button type="button" class="btn btn-outline-success btn-sm fw-bold px-2.5" onclick="loadAndShowPrintReceipt('${dh.maDh}')">
                                            <i class="bi bi-printer"></i>
                                        </button>

                                        <c:choose>
                                            <c:when test="${dh.trangThaiDon == 0}">
                                                <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-2.5" onclick="cancelOnlineOrder('${dh.maDh}')">HỦY</button>
                                                <button type="button" class="btn btn-success btn-sm fw-bold px-3" onclick="updateOrderStatus('${dh.maDh}', 1)">XÁC NHẬN</button>
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
                                                <!-- Đơn đã hủy hoặc đã hoàn thành, không có thêm nút hành động -->
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<!-- Hidden Action Form for Status Updates -->
<form id="actionStatusForm" action="${pageContext.request.contextPath}/pos/nhandon" method="POST" style="display:none;">
    <input type="hidden" name="maDh" id="action_maDh">
    <input type="hidden" name="trangThaiMoi" id="action_trangThaiMoi">
    <input type="hidden" name="lyDoHuy" id="action_lyDoHuy">
</form>

<!-- Receipt Print Preview Modal -->
<div class="modal fade" id="receiptDetailModal" data-bs-backdrop="static" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered" style="width: 320px;">
        <div class="modal-content p-3 border-0 text-center" style="border-radius:12px;">
            <div id="billPrintArea" class="bg-white p-1 text-dark" style="font-family: 'Courier New', Courier, monospace; font-size:12px;">
                <h5 class="fw-bold m-0" style="font-size:16px;">TEA POS CAFE</h5>
                <p class="m-0 small" style="font-size:10px;">Đ/C: 123 Đường Sữa, CodeDevSquad 2026</p>
                <p class="m-0 small" style="font-size:10px;">Hotline: (+84) 123 456 789</p>
                <div class="my-2 border-bottom border-dark border-opacity-50"></div>
                <h6 class="fw-bold my-1" style="font-size:13px; text-transform: uppercase;">Hóa Đơn Thanh Toán</h6>
                <div class="text-start mb-2" style="font-size:10px; line-height: 1.4;">
                    <div>Mã đơn: <span id="billMaDh" class="fw-bold">TEAxxxx</span></div>
                    <div>Thời gian: <span id="billThoiGian">N/A</span></div>
                    <div>Khách hàng: <span id="billTenKh">Khách lẻ vãng lai</span></div>
                    <div>Nhân sự: <span id="billTenNv">N/A</span></div>
                </div>
                <div class="my-2 border-bottom border-dark border-opacity-50"></div>

                <!-- Items container -->
                <div id="billItemsContainer"></div>

                <div class="my-2 border-bottom border-dark border-opacity-50"></div>
                <div class="text-start" style="font-size:10.5px; line-height: 1.5;">
                    <div class="d-flex justify-content-between">
                        <span>Tiền hàng:</span>
                        <span id="billRawPrice" class="font-monospace">0đ</span>
                    </div>
                    <div class="d-flex justify-content-between" style="display:none !important;" id="billDiscountRow">
                        <span>Ưu đãi Voucher:</span>
                        <span id="billDiscount" class="font-monospace">-0đ</span>
                    </div>
                    <div class="d-flex justify-content-between" style="display:none !important;" id="billPointsRow">
                        <span>Trừ điểm CRM:</span>
                        <span id="billPointsDiscount" class="font-monospace">-0đ</span>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span>Thuế VAT (8%):</span>
                        <span id="billVatPrice" class="font-monospace">0đ</span>
                    </div>
                    <div class="d-flex justify-content-between fw-bold text-dark fs-6 pt-1 border-top border-dark border-opacity-25 mt-1">
                        <span>TỔNG CỘNG:</span>
                        <span id="billFinalPayable" class="font-monospace">0đ</span>
                    </div>
                </div>
                <div class="my-2 border-bottom border-dark border-opacity-50"></div>
                <div class="text-center small py-1" style="font-size: 10px; font-style: italic;">
                    Cảm ơn quý khách và hẹn gặp lại!<br>CodeDevSquad 2026
                </div>
            </div>
            <div class="d-flex gap-2 mt-3">
                <button type="button" class="btn btn-outline-secondary flex-fill fw-bold" data-bs-dismiss="modal">ĐÓNG</button>
                <button type="button" class="btn btn-success flex-fill fw-bold" onclick="printReceipt()"><i class="bi bi-printer-fill"></i> IN BILL</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.7.32/dist/sweetalert2.all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    function updateOrderStatus(maDh, status) {
        Swal.fire({
            title: 'Cập nhật trạng thái đơn?',
            text: 'Bạn có chắc muốn chuyển trạng thái đơn ' + maDh + ' không?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý',
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
            title: 'HỦY ĐƠN ĐẶT ONLINE',
            text: 'Vui lòng nhập lý do hủy đơn bắt buộc:',
            input: 'text',
            inputPlaceholder: 'Khách yêu cầu hủy, hết nguyên liệu pha chế...',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận hủy đơn',
            cancelButtonText: 'Đóng',
            preConfirm: (value) => {
                if (!value || value.trim() === "") {
                    Swal.showValidationMessage('Bạn phải nhập lý do hủy đơn!');
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
</script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
</body>
</html>