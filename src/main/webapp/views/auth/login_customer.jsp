<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS Portal - Đăng Nhập Khách Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet">
    <style>
        .customer-auth-bg {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        }
        .customer-auth-card {
            width: 100%;
            max-width: 480px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(46, 125, 50, 0.15);
            border: 1px solid rgba(46, 125, 50, 0.1);
        }
    </style>
</head>
<body>

<div class="customer-auth-bg">
    <div class="customer-auth-card p-4 p-md-5">
        <div class="text-center mb-4">
            <div class="text-success fs-1 mb-2"><i class="bi bi-cup-hot-fill"></i></div>
            <h3 class="fw-bold text-success mb-1">TEA POS PORTAL</h3>
            <p class="text-muted small">Đăng nhập tài khoản thành viên để tích điểm và đổi Voucher VIP</p>
        </div>

        <form action="${pageContext.request.contextPath}/customer/login" method="POST">
            <!-- Tài khoản: SĐT hoặc Email -->
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold text-dark small">Email hoặc Số điện thoại</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope-open-fill"></i></span>
                    <input type="text" class="form-control bg-white border-start-0 py-2" id="username" name="username"
                           placeholder="Nhập email hoặc số điện thoại..." required autocomplete="off">
                </div>
            </div>

            <!-- Mật khẩu -->
            <div class="mb-4">
                <div class="d-flex justify-content-between mb-1">
                    <label for="password" class="form-label fw-semibold text-dark small mb-0">Mật khẩu bảo mật</label>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="text-decoration-none small text-success fw-semibold">Quên mật khẩu?</a>
                </div>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-shield-lock-fill"></i></span>
                    <input type="password" class="form-control bg-white border-start-0 py-2" id="password" name="password"
                           placeholder="Nhập mật khẩu của bạn..." required>
                    <button class="btn btn-outline-secondary border-start-0" type="button" id="togglePassword">
                        <i class="bi bi-eye-slash-fill" id="eyeIcon"></i>
                    </button>
                </div>
            </div>

            <!-- Submit đăng nhập -->
            <button type="submit" class="btn btn-primary-teapos w-100 py-2 fw-bold mb-3 shadow-sm" style="border-radius: 8px;">
                <i class="bi bi-box-arrow-in-right me-2 fs-5"></i> ĐĂNG NHẬP NGAY
            </button>

            <!-- Đăng ký tài khoản mới -->
            <div class="text-center mt-3">
                <span class="text-muted small">Bạn chưa có tài khoản thành viên? </span>
                <a href="${pageContext.request.contextPath}/register" class="text-success text-decoration-none fw-bold small">Đăng ký ngay tại đây</a>
            </div>
        </form>
    </div>
</div>

<script>
    // Logic ẩn/hiện mật khẩu
    const togglePassword = document.querySelector('#togglePassword');
    const passwordInput = document.querySelector('#password');
    const eyeIcon = document.querySelector('#eyeIcon');

    togglePassword.addEventListener('click', function () {
        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);
        if (type === 'text') {
            eyeIcon.className = 'bi bi-eye-fill';
        } else {
            eyeIcon.className = 'bi bi-eye-slash-fill';
        }
    });

    // Đón bắt và thông báo kết quả
    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Đăng nhập thất bại',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
        <c:if test="${not empty success}">
        Swal.fire({
            icon: 'success',
            title: 'Thành công',
            text: '${success}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>