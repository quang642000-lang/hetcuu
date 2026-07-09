<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Khôi Phục Mật Khẩu</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .forgot-bg {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        }
        .forgot-card {
            width: 100%;
            max-width: 480px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(46, 125, 50, 0.15);
        }
    </style>
</head>
<body>

<div class="forgot-bg">
    <div class="forgot-card p-4 p-md-5">
        <div class="text-center mb-4">
            <div class="text-success fs-1 mb-2"><i class="bi bi-question-circle-fill"></i></div>
            <h4 class="fw-bold mb-1">KHÔI PHỤC MẬT KHẨU</h4>
            <p class="text-muted small">Hãy nhập địa chỉ Email đăng ký tài khoản của bạn để nhận mã xác thực OTP khôi phục [17]</p>
        </div>

        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <!-- Ô nhập Email -->
            <div class="mb-4">
                <label for="email" class="form-label fw-semibold text-dark small">Email đăng ký của bạn</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope-fill"></i></span>
                    <input type="email" class="form-control bg-white border-start-0 py-2" id="email" name="email"
                           placeholder="Nhập chính xác email để nhận OTP..." value="<c:out value='${email}'/>" required>
                </div>
            </div>

            <!-- Nút gửi yêu cầu -->
            <button type="submit" class="btn btn-primary-teapos w-100 py-2 fw-bold text-uppercase shadow-sm mb-3" style="border-radius: 8px;">
                <i class="bi bi-send-fill me-2 small"></i> Gửi mã OTP xác nhận
            </button>

            <!-- Quay lại đăng nhập -->
            <div class="text-center">
                <a href="${pageContext.request.contextPath}/customer/login" class="text-success text-decoration-none fw-bold small">
                    <i class="bi bi-arrow-left me-1"></i> Quay lại trang đăng nhập
                </a>
            </div>
        </form>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Không thể xử lý',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>