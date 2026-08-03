<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>TEA POS - Xác Minh OTP Kích Hoạt</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
  <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
  <style>
    body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: 'Inter', sans-serif; }
    .otp-card { width: 100%; max-width: 480px; background-color: #ffffff; border-radius: 16px; box-shadow: var(--shadow-lg); border: 1px solid var(--border-color); overflow: hidden; }
    .otp-header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 35px 25px; text-align: center; }
    .otp-digit-input { width: 44px; height: 50px; font-size: 24px; font-weight: 800; text-align: center; border: 1.5px solid var(--border-color); border-radius: 8px; margin: 0 4px; transition: all 0.2s; color: var(--text-main); }
    .otp-digit-input:focus { border-color: #10b981; outline: none; box-shadow: 0 0 0 3px rgba(16,185,129,0.15); }
  </style>
</head>
<body>
<div class="otp-card">
  <div class="otp-header">
    <div class="fs-1 mb-2 text-white animate-pulse"><i class="bi bi-shield-fill-check"></i></div>
    <h4 class="fw-bold mb-1 text-uppercase">XÁC MINH OTP KÍCH HOẠT</h4>
    <p class="mb-0 small text-white-50">Mã xác thực 6 chữ số đã được gửi tới Email liên kết của bạn.</p>
  </div>
  <div class="p-4 p-md-5 text-center">
    <c:if test="${not empty requestScope.error}">
      <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
    </c:if>
    <form action="${pageContext.request.contextPath}/activate/verify" method="POST" id="otpForm">
      <div class="d-flex justify-content-center mb-4">
        <input type="text" class="otp-digit-input" id="otp1" name="otp1" maxlength="1" required autocomplete="off">
        <input type="text" class="otp-digit-input" id="otp2" name="otp2" maxlength="1" required autocomplete="off">
        <input type="text" class="otp-digit-input" id="otp3" name="otp3" maxlength="1" required autocomplete="off">
        <input type="text" class="otp-digit-input" id="otp4" name="otp4" maxlength="1" required autocomplete="off">
        <input type="text" class="otp-digit-input" id="otp5" name="otp5" maxlength="1" required autocomplete="off">
        <input type="text" class="otp-digit-input" id="otp6" name="otp6" maxlength="1" required autocomplete="off">
      </div>
      <div class="text-center mb-4">
        <span class="text-muted small">Mã xác thực hết hiệu lực sau: </span>
        <span class="fw-bold text-danger fs-6" id="countdownTimer">02:00</span>
      </div>
      <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold text-uppercase shadow-sm"><i class="bi bi-shield-lock-fill me-1"></i> Xác minh kích hoạt</button>
    </form>
  </div>
</div>
<script>
  document.addEventListener("DOMContentLoaded", function () {
    const inputs = document.querySelectorAll(".otp-digit-input");
    inputs.forEach((input, index) => {
      input.addEventListener("input", function () {
        this.value = this.value.replace(/[^0-9]/g, '');
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

    let timeLeft = 120;
    const timerElement = document.getElementById("countdownTimer");
    const interval = setInterval(function () {
      if (timeLeft <= 0) {
        clearInterval(interval);
        timerElement.innerText = "Đã Hết Hạn";
        Swal.fire({
          icon: 'error',
          title: 'Mã OTP hết hạn',
          text: 'Vui lòng quay lại tìm kiếm tài khoản để nhận mã OTP mới!',
          confirmButtonColor: '#ef4444'
        }).then(() => {
          window.location.href = "${pageContext.request.contextPath}/activate";
        });
      } else {
        timeLeft--;
        const min = Math.floor(timeLeft / 60);
        const sec = String(timeLeft % 60).padStart(2, '0');
        timerElement.innerText = "0" + min + ":" + sec;
      }
    }, 1000);
  });
</script>
</body>
</html>
