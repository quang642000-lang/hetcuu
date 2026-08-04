<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Thanh Toán Chuyển Khoản VietQR</title>
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

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-5 text-center">
            <div class="card qr-card p-4 border-0 shadow" style="border-radius:16px; border:1px solid var(--border-color) !important;">
                <h4 class="fw-bold mb-2 text-success"><i class="bi bi-wallet2"></i> CỔNG THANH TOÁN VIETQR</h4>
                <p class="text-muted small mb-4">Vui lòng quét mã bên dưới bằng ứng dụng Ngân hàng (Mobile Banking) của bạn để chốt giao dịch tự động.</p>

                <!-- QR Box -->
                <div class="qr-image-box mb-4 position-relative text-center d-inline-block p-2 bg-light border border-success border-opacity-25 rounded-3">
                    <img id="vietQrImg" src="https://img.vietqr.io/image/TPB-0346406405-compact2.png?amount=${order.tongPhaiTra}&addInfo=${order.maDh}"
                         alt="VietQR Payment Code" class="img-fluid" style="max-width: 250px; object-fit: contain;">
                </div>

                <!-- Countdown & status info -->
                <div class="mb-4">
                    <small class="text-muted d-block uppercase fw-bold mb-1" style="font-size: 11px;">Mã Giao Dịch Chuyển Khoản</small>
                    <span class="badge bg-dark fs-6 px-3 py-1.5 font-monospace mb-3" style="letter-spacing: 1px; border-radius:6px; background-color:#1e293b !important;">${order.maDh}</span>
                    <small class="text-muted d-block uppercase fw-bold mb-1" style="font-size: 11px;">Số Tiền Cần Thanh Toán</small>
                    <h3 class="fw-bold text-danger mb-3"><fmt:formatNumber value="${order.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</h3>

                    <div class="d-flex align-items-center justify-content-center gap-2 mb-1">
                        <div class="spinner-border spinner-border-sm text-success" role="status"></div>
                        <span class="small text-success fw-bold">Hệ thống đang chờ tiền vào...</span>
                    </div>
                    <div class="countdown-timer text-danger fw-bold fs-4 font-monospace" id="timer">10:00</div>
                </div>

                <hr class="border-secondary border-dashed my-3">

                <!-- Security/Note instructions -->
                <div class="text-start p-3 bg-light rounded-3 border small text-muted mb-4" style="line-height: 1.5; font-size:11px;">
                    <div class="fw-bold text-dark mb-1"><i class="bi bi-info-circle-fill text-primary"></i> HƯỚNG DẪN CHUYỂN KHOẢN AN TOÀN:</div>
                    <div>1. Mở ứng dụng Ngân hàng và thực hiện tính năng quét mã <strong>QR Pay</strong>.</div>
                    <div>2. Đảm bảo số tiền thanh toán và <strong>Nội dung chuyển khoản (Memo)</strong> giữ nguyên đúng mã <strong>${order.maDh}</strong>.</div>
                    <div>3. Hệ thống sẽ tự động khớp lệnh và điều hướng trang sau khi giao dịch thành công.</div>
                </div>

                <a href="${pageContext.request.contextPath}/profile/orders" class="btn btn-outline-secondary w-100 py-2.5 fw-bold" style="border-radius:8px;">
                    <i class="bi bi-arrow-left"></i> Quay Lại Danh Sách Đơn Hàng
                </a>
            </div>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    let timeRemaining = 10 * 60;
    const timerElement = document.getElementById("timer");

    function startCountdown() {
        const interval = setInterval(() => {
            if (timeRemaining <= 0) {
                clearInterval(interval);
                timerElement.innerText = "HẾT HẠN";
                timerElement.className = "countdown-timer text-muted";
                Swal.fire({
                    icon: 'error',
                    title: 'Mã QR đã hết hạn',
                    text: 'Phiên quét mã thanh toán đã kết thúc. Vui lòng quay lại danh sách để nhận hỗ trợ!',
                    confirmButtonColor: '#ef4444'
                }).then(() => {
                    window.location.href = "${pageContext.request.contextPath}/profile/orders";
                });
            } else {
                timeRemaining--;
                const minutes = Math.floor(timeRemaining / 60);
                const seconds = timeRemaining % 60;
                timerElement.innerText = String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0');
            }
        }, 1000);
    }

    function checkPaymentStatus() {
        const orderId = "${order.maDh}";
        const intervalId = setInterval(() => {
            fetch("${pageContext.request.contextPath}/api/check-payment?id=" + orderId)
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'SUCCESS') {
                        clearInterval(intervalId);
                        Swal.fire({
                            icon: 'success',
                            title: 'Thanh toán thành công!',
                            text: 'Đơn hàng ' + orderId + ' đã được chuyển khoản khớp lệnh tự động qua cổng SePay!',
                            confirmButtonColor: '#10b981'
                        }).then(() => {
                            window.location.href = "${pageContext.request.contextPath}/profile/orders?msg=paymentsuccess";
                        });
                    }
                })
                .catch(err => console.error("Lỗi polling check payment:", err));
        }, 3000);
    }

    document.addEventListener("DOMContentLoaded", () => {
        startCountdown();
        checkPaymentStatus();
    });
</script>
</body>
</html>
