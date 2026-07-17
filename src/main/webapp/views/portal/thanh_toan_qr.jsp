<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Thanh Toán Chuyển Khoản VietQR</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .qr-card {
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(16, 185, 129, 0.1);
            background: #ffffff;
            border: 1px solid #e2e8f0;
        }
        .qr-image-box {
            border: 1.5px solid #10b981;
            padding: 8px;
            background: #f8fafc;
            border-radius: 12px;
            display: inline-block;
        }
        .countdown-timer {
            font-size: 24px;
            font-weight: 800;
            color: #ef4444;
            font-family: monospace;
        }
        .pulse-logo {
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.1); opacity: 0.7; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-5 text-center">
            <div class="card qr-card p-4">
                <h4 class="fw-bold mb-2 text-success"><i class="bi bi-wallet2"></i> CỔNG THANH TOÁN VIETQR</h4>
                <p class="text-muted small mb-4">Vui lòng quét mã bên dưới bằng ứng dụng Ngân hàng (Mobile Banking) của bạn để chốt giao dịch tự động.</p>

                <!-- QR Box -->
                <div class="qr-image-box mb-4 position-relative">
                    <!-- VietQR API integration dynamically displaying the amount & order ID as message -->
                    <img id="vietQrImg" src="https://img.vietqr.io/image/TPB-0346406405-compact2.png?amount=${order.tongPhaiTra}&addInfo=${order.maDh}"
                         alt="VietQR Payment Code" class="img-fluid" style="max-width: 280px; object-fit: contain;">
                </div>

                <!-- Countdown & status info -->
                <div class="mb-4">
                    <small class="text-muted d-block uppercase fw-bold mb-1" style="font-size: 11px;">Mã Giao Dịch Chuyển Khoản</small>
                    <span class="badge bg-dark fs-6 px-3 py-1.5 font-monospace mb-3" style="letter-spacing: 1px;">${order.maDh}</span>

                    <small class="text-muted d-block uppercase fw-bold mb-1" style="font-size: 11px;">Số Tiền Cần Thanh Toán</small>
                    <h3 class="fw-bold text-danger mb-3"><fmt:formatNumber value="${order.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</h3>

                    <div class="d-flex align-items-center justify-content-center gap-2 mb-1">
                        <div class="spinner-border spinner-border-sm text-success" role="status"></div>
                        <span class="small text-success fw-bold">Hệ thống đang chờ tiền vào...</span>
                    </div>
                    <div class="countdown-timer" id="timer">10:00</div>
                </div>

                <hr class="border-secondary border-dashed my-3">

                <!-- Security/Note instructions -->
                <div class="text-start p-3 bg-light rounded-3 border small text-muted mb-4" style="line-height: 1.5;">
                    <div class="fw-bold text-dark mb-1"><i class="bi bi-info-circle-fill text-primary"></i> HƯỚNG DẪN CHUYỂN KHOẢN AN TOÀN:</div>
                    <div>1. Mở ứng dụng Ngân hàng và thực hiện tính năng quét mã <strong>QR Pay</strong>.</div>
                    <div>2. Đảm bảo số tiền thanh toán và <strong>Nội dung chuyển khoản (Memo)</strong> giữ nguyên đúng mã <strong>${order.maDh}</strong>.</div>
                    <div>3. Hệ thống sẽ tự động khớp lệnh và điều hướng trang sau khi giao dịch thành công.</div>
                </div>

                <a href="${pageContext.request.contextPath}/profile/orders" class="btn btn-outline-secondary w-100 py-2.5 fw-bold">
                    <i class="bi bi-arrow-left"></i> Quay Lại Danh Sách Đơn Hàng
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    // Set countdown time in minutes
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

    // Active polling to check payment status on server
    function checkPaymentStatus() {
        const orderId = "${order.maDh}";
        const pollInterval = setInterval(() => {
            if (timeRemaining <= 0) {
                clearInterval(pollInterval);
                return;
            }

            fetch("${pageContext.request.contextPath}/api/check-payment?id=" + orderId)
                .then(res => res.json())
                .then(data => {
                    if (data.status === "SUCCESS") {
                        clearInterval(pollInterval);
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
        }, 3000); // Check every 3 seconds
    }

    document.addEventListener("DOMContentLoaded", () => {
        startCountdown();
        checkPaymentStatus();
    });
</script>
</body>
</html>