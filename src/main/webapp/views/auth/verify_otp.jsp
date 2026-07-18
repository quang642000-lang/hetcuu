<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Xác Minh Mã OTP</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .otp-bg {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        }
        .otp-card {
            width: 100%;
            max-width: 500px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(46, 125, 50, 0.15);
        }
        .otp-digit-input {
            width: 50px;
            height: 56px;
            font-size: 24px;
            font-weight: 700;
            text-align: center;
            border-radius: 8px;
            border: 2px solid var(--border-color);
            background-color: #f8fafc;
            margin: 0 4px;
            transition: all 0.2s ease;
        }
        .otp-digit-input:focus {
            border-color: #10b981;
            background-color: #ffffff;
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 125, 50, 0.15);
        }
    </style>
</head>
<body>
<div class="otp-bg">
    <div class="otp-card p-4 p-md-5">
        <div class="text-center mb-4">
            <div class="text-success fs-1 mb-2"><i class="bi bi-patch-check-fill"></i></div>
            <h4 class="fw-bold mb-1">XÁC MINH OTP EMAIL</h4>
            <p class="text-muted small">Chúng tôi đã gửi mã xác thực gồm 6 chữ số đến địa chỉ email đăng ký của bạn. Vui lòng kiểm tra và nhập chính xác để tiếp tục.</p>
        </div>

        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/verify-otp?type=${type}" method="POST" id="otpForm">
            <input type="hidden" name="type" value="${type}">
            <input type="hidden" name="role" value="${role}">
            <!-- 6 ô nhập mã OTP -->
            <div class="d-flex justify-content-center mb-4">
                <input type="text" class="otp-digit-input" id="otp1" name="otp1" maxlength="1" required autocomplete="off">
                <input type="text" class="otp-digit-input" id="otp2" name="otp2" maxlength="1" required autocomplete="off">
                <input type="text" class="otp-digit-input" id="otp3" name="otp3" maxlength="1" required autocomplete="off">
                <input type="text" class="otp-digit-input" id="otp4" name="otp4" maxlength="1" required autocomplete="off">
                <input type="text" class="otp-digit-input" id="otp5" name="otp5" maxlength="1" required autocomplete="off">
                <input type="text" class="otp-digit-input" id="otp6" name="otp6" maxlength="1" required autocomplete="off">
            </div>

            <!-- Bộ đếm ngược thời gian hiệu lực -->
            <div class="text-center mb-4">
                <span class="text-muted small">Mã xác thực sẽ hết hiệu lực trong vòng:</span>
                <span class="fw-bold text-danger fs-6 ps-1" id="countdownTimer">02:00</span>
            </div>

            <!-- Nút bấm xác nhận -->
            <button type="submit" class="btn btn-primary-teapos w-100 py-2 fw-bold text-uppercase shadow-sm mb-3" style="border-radius: 8px;">
                <i class="bi bi-shield-lock-fill me-2 fs-5"></i> Xác nhận mã OTP
            </button>

            <!-- Nút gửi lại mã qua AJAX không tải lại trang -->
            <div class="text-center mt-3">
                <span class="text-muted small">Không nhận được mã xác thực? </span>
                <button type="button" class="btn btn-link text-success p-0 fw-bold text-decoration-none small" id="resendOtpBtn">
                    Gửi lại mã OTP mới
                </button>
            </div>
        </form>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // 1. Logic tự động nhảy ô nhập liệu OTP (Auto-focus & Backspace)
        const inputs = document.querySelectorAll(".otp-digit-input");
        inputs.forEach((input, index) => {
            input.addEventListener("input", function () {
                this.value = this.value.replace(/[^0-9]/g, ''); // Chỉ cho phép nhập số
                if (this.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });
            input.addEventListener("keydown", function (e) {
                if (e.key === "Backspace" && this.value.length === 0 && index > 0) {
                    inputs[index - 1].focus();
                }
            });
        });

        // 2. Logic đồng hồ đếm ngược đúng 2 phút (120 giây)
        let timeLeft = 120;
        const timerElement = document.getElementById("countdownTimer");
        const resendBtn = document.getElementById("resendOtpBtn");

        resendBtn.disabled = true;
        resendBtn.classList.add("opacity-50");

        const countdownInterval = setInterval(function () {
            const minutes = String(Math.floor(timeLeft / 60)).padStart(2, '0');
            const seconds = String(timeLeft % 60).padStart(2, '0');
            timerElement.textContent = minutes + ":" + seconds;
            if (timeLeft <= 0) {
                clearInterval(countdownInterval);
                timerElement.textContent = "Hết hạn";
                resendBtn.disabled = false;
                resendBtn.classList.remove("opacity-50");
                Swal.fire({
                    icon: 'warning',
                    title: 'Mã OTP đã hết hiệu lực',
                    text: 'Vui lòng nhấn "Gửi lại mã OTP mới" để tiếp tục.',
                    confirmButtonColor: '#2e7d32'
                });
            }
            timeLeft--;
        }, 1000);

        // 3. Logic AJAX gọi gửi lại mã mới
        resendBtn.addEventListener("click", function () {
            Swal.fire({
                title: 'Đang gửi lại OTP...',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); }
            });
            fetch('${pageContext.request.contextPath}/verify-otp?action=resend-otp')
                .then(res => res.text())
                .then(data => {
                    Swal.close();
                    if (data.trim() === 'SUCCESS') {
                        Swal.fire({
                            icon: 'success',
                            title: 'Thành công',
                            text: 'Một mã xác thực OTP mới đã được gửi vào hòm thư điện tử của bạn!',
                            confirmButtonColor: '#2e7d32'
                        }).then(() => {
                            location.reload(); // Tải lại trang để reset bộ đếm giờ mới
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Thất bại',
                            text: 'Gửi lại OTP không thành công hoặc phiên của bạn đã hết hiệu lực.',
                            confirmButtonColor: '#2e7d32'
                        });
                    }
                })
                .catch(err => {
                    Swal.close();
                    console.error("Lỗi:", err);
                });
        });
    });
</script>
</body>
</html>