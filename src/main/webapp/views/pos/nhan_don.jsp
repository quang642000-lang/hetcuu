<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Phối Đơn Hàng Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- HEADER CHỈ HUY NHẬN ĐƠN -->
<nav class="navbar navbar-dark bg-dark px-3 sticky-top" style="height: 60px;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center" href="${pageContext.request.contextPath}/pos/nhandon" style="color: #10b981 !important;">
            <i class="bi bi-bell-fill me-2 fs-4 text-warning"></i> TRẠM QUẢN LÝ ĐƠN HÀNG TRỰC TUYẾN
        </a>
        <div class="d-flex align-items-center gap-3">
            <span class="badge bg-danger p-2 px-3 fw-bold border border-light animate-pulse" style="font-size: 11px; letter-spacing: 0.5px;">
                🔴 AJAX LIVE POLING: HOẠT ĐỘNG (5S/LẦN)
            </span>
            <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-outline-success border-2 fw-bold">
                <i class="bi bi-cart3"></i> Vào quầy bán POS
            </a>
        </div>
    </div>
</nav>

<div class="container-fluid p-4">
    <!-- KHỐI BỘ LỌC TRẠNG THÁI TRỰC TUYẾN -->
    <div class="card card-teapos p-3 mb-4">
        <div class="d-flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=0" class="btn ${currentStatus == 0 ? 'btn-warning text-dark' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-clock-history"></i> Chờ Xác Nhận (${onlineOrders.stream().filter(o -> o.trangThaiDon == 0).count()})
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=1" class="btn ${currentStatus == 1 ? 'btn-info text-white' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-check2-all"></i> Đã Xác Nhận (${onlineOrders.stream().filter(o -> o.trangThaiDon == 1).count()})
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=2" class="btn ${currentStatus == 2 ? 'btn-primary' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-cup-straw"></i> Đang Pha Chế
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=3" class="btn ${currentStatus == 3 ? 'btn-success' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-box2-heart"></i> Sẵn Sàng Chờ Lấy
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=4" class="btn ${currentStatus == 4 ? 'btn-dark' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-check-circle-fill"></i> Đã Hoàn Thành
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=5" class="btn ${currentStatus == 5 ? 'btn-danger' : 'btn-light border'} fw-bold btn-sm">
                <i class="bi bi-x-circle-fill"></i> Đơn Hủy Bỏ
            </a>
        </div>
    </div>

    <!-- DANH SÁCH ĐƠN HÀNG TRỰC TUYẾN -->
    <div class="row g-4">
        <c:choose>
            <c:when test="${not empty onlineOrders}">
                <c:forEach var="order" items="${onlineOrders}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="card card-teapos shadow-sm border p-4 bg-white" style="border-radius: 12px; transition: transform 0.2s ease;">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <h5 class="fw-bold mb-0 text-success">${order.maDh}</h5>
                                    <small class="text-muted">Đặt lúc: <fmt:formatDate value="${order.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></small>
                                </div>
                                <span class="badge ${order.trangThaiThanhToan == 1 ? 'bg-success' : 'bg-warning'} text-white">
                                        ${order.trangThaiThanhToan == 1 ? 'Đã thanh toán (Chuyển khoản)' : 'Chờ trả tiền mặt'}
                                </span>
                            </div>

                            <!-- Mốc giờ Click & Collect hẹn lấy nước -->
                            <div class="p-2 bg-light rounded text-dark small mb-3 border border-dashed border-success">
                                <i class="bi bi-alarm-fill text-danger me-1"></i> HẸN ĐẾN QUẦY LẤY:
                                <strong><fmt:formatDate value="${order.thoiGianHenLay}" pattern="HH:mm (dd/MM)"/></strong>
                            </div>

                            <div class="mb-3">
                                <small class="text-muted d-block" style="font-size: 11px;">Thành viên CRM</small>
                                <strong class="text-dark small"><i class="bi bi-person-fill"></i> Khách hàng: <c:out value="${not empty order.maKh ? order.maKh : 'Khách vãng lai'}"/></strong>
                            </div>

                            <!-- Khối tính dồn tiền -->
                            <div class="d-flex justify-content-between align-items-center mb-4 border-top pt-2">
                                <div>
                                    <small class="text-muted d-block" style="font-size: 11px;">Giá trị thu</small>
                                    <strong class="text-danger fs-5"><fmt:formatNumber value="${order.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</strong>
                                </div>
                                <div class="text-end">
                                    <small class="text-muted d-block" style="font-size: 11px;">Hình thức đặt</small>
                                    <span class="badge bg-dark text-white fw-bold">CLICK & COLLECT</span>
                                </div>
                            </div>

                            <!-- Trục điều phối trạng thái -->
                            <form action="${pageContext.request.contextPath}/pos/nhandon" method="POST" id="formUpdate_${order.maDh}">
                                <input type="hidden" name="maDh" value="${order.maDh}">
                                <input type="hidden" name="trangThaiMoi" id="statusField_${order.maDh}">
                                <input type="hidden" name="lyDoHuy" id="cancelReason_${order.maDh}">

                                <div class="row g-2">
                                    <c:choose>
                                        <c:when test="${order.trangThaiDon == 0}">
                                            <div class="col-6">
                                                <button type="button" class="btn btn-sm btn-outline-danger w-100 fw-bold" onclick="cancelOnlineOrder('${order.maDh}')">HỦY ĐƠN</button>
                                            </div>
                                            <div class="col-6">
                                                <button type="button" class="btn btn-sm btn-success w-100 fw-bold" onclick="submitStatus('${order.maDh}', 1)">XÁC NHẬN</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 1}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-primary w-100 fw-bold" onclick="submitStatus('${order.maDh}', 2)">BẮT ĐẦU PHA CHẾ</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 2}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-success w-100 fw-bold" onclick="submitStatus('${order.maDh}', 3)">BÁO LÊN KỆ CHỜ LẤY</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 3}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-dark w-100 fw-bold" onclick="submitStatus('${order.maDh}', 4)">GIAO NƯỚC (HOÀN THÀNH)</button>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="col-12 text-center text-muted small py-2 bg-light rounded border">
                                                Giao dịch đã đóng (Locked)
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12 text-center py-5 text-muted">
                    <i class="bi bi-clock-history fs-1 d-block mb-2"></i>
                    Không có đơn hàng online nào thuộc trạng thái lọc hiện hành!
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    // 1. Submit chuyển đổi trạng thái đơn
    function submitStatus(maDh, targetStatus) {
        document.getElementById("statusField_" + maDh).value = targetStatus;
        document.getElementById("formUpdate_" + maDh).submit();
    }

    // 2. Popup hủy đơn kèm ràng buộc bắt nhập lý do
    function cancelOnlineOrder(maDh) {
        Swal.fire({
            title: 'Từ chối đơn hàng?',
            text: 'Vui lòng điền rõ lý do hủy đơn hàng online đặt trước này:',
            input: 'text',
            inputPlaceholder: 'Ví dụ: Hết nguyên liệu, hết đá sạch, ngoài giờ giao nước...',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý hủy',
            cancelButtonText: 'Quay lại',
            preConfirm: (reason) => {
                if (!reason || reason.trim() === '') {
                    Swal.showValidationMessage('Bạn bắt buộc phải nhập lý do hủy đơn!');
                }
                return reason;
            }
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById("statusField_" + maDh).value = 5; // Trạng thái hủy đơn
                document.getElementById("cancelReason_" + maDh).value = result.value;
                document.getElementById("formUpdate_" + maDh).submit();
            }
        });
    }

    // 3. KỊCH BẢN AJAX POLLING (Tự động tải lại danh sách sau 5 giây để đón đơn mới)
    setInterval(function() {
        // Thực hiện fetch không tải lại trang để kiểm tra biến động của hàng chờ đơn mới
        fetch('${pageContext.request.contextPath}/pos/nhandon?action=checkPollingCount&status=' + ${currentStatus})
            .then(res => res.text())
            .then(data => {
                const currentCount = ${onlineOrders.size()};
                if (parseInt(data) !== currentCount && parseInt(data) > 0) {
                    showToast('info', 'Phát hiện có đơn đặt online hoặc thanh toán tự động qua SePay vừa nạp vào hàng chờ!');
                    setTimeout(() => { location.reload(); }, 1500);
                }
            })
            .catch(err => console.error("Lỗi Polling:", err));
    }, 5000); // 5000 milliseconds = 5 giây
</script>
</body>
</html>