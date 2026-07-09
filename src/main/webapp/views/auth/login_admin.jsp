<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đăng Nhập Hệ Thống Quản Trị</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Nạp Bootstrap 5 & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Nạp SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        .auth-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        }
        .auth-card {
            width: 100%;
            max-width: 460px;
            border: none;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
            background-color: #ffffff;
            overflow: hidden;
        }
        .brand-banner {
            background-color: #2e7d32;
            color: #ffffff;
            padding: 30px;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="auth-container">
    <div class="auth-card">
        <!-- Banner nhận diện thương hiệu -->
        <div class="brand-banner">
            <div class="fs-1 mb-2"><i class="bi bi-shield-lock-fill"></i></div>
            <h4 class="fw-bold mb-0" style="letter-spacing: 1px;">TEA POS SYSTEM</h4>
            <small class="opacity-75">Hệ thống điều hành bán hàng & quản trị nội bộ</small>
        </div>

        <div class="p-4">
            <h5 class="fw-bold text-dark text-center mb-3">ĐĂNG NHẬP HỆ THỐNG</h5>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <!-- Tên đăng nhập -->
                <div class="mb-3">
                    <label for="username" class="form-label fw-semibold text-muted small">Tài khoản nhân viên</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-person-fill text-muted"></i></span>
                        <input type="text" class="form-control bg-light border-start-0 py-2" id="username" name="username"
                               placeholder="Nhập mã nhân viên hoặc tên đăng nhập..."
                               value="<c:out value='${username}'/>" required autocomplete="off">
                    </div>
                </div>

                <!-- Mật khẩu -->
                <div class="mb-4">
                    <div class="d-flex justify-content-between mb-1">
                        <label for="password" class="form-label fw-semibold text-muted small mb-0">Mật khẩu</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" class="text-decoration-none small text-success fw-medium">Quên mật khẩu?</a>
                    </div>
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-lock-fill text-muted"></i></span>
                        <input type="password" class="form-control bg-light border-start-0 py-2" id="password" name="password"
                               placeholder="Nhập mật khẩu của bạn..." required>
                        <button class="btn btn-outline-secondary border-start-0" type="button" id="togglePassword">
                            <i class="bi bi-eye-slash-fill" id="eyeIcon"></i>
                        </button>
                    </div>
                </div>

                <!-- Ghi nhớ mật khẩu -->
                <div class="mb-4 form-check">
                    <input type="checkbox" class="form-check-input" id="remember" name="remember" value="1">
                    <label class="form-check-label text-muted small" for="remember">Ghi nhớ phiên làm việc trên trình duyệt này</label>
                </div>

                <!-- Nút Submit -->
                <button type="submit" class="btn btn-primary-teapos w-100 py-2 fw-bold text-uppercase" style="border-radius: 8px;">
                    <i class="bi bi-box-arrow-in-right me-2"></i> Xác nhận vào ca
                </button>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
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

    // Tự động kiểm tra lỗi đẩy ra từ LoginController và AuthFilter
    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Đăng nhập thất bại',
            text: '${error}',
            confirmButtonColor: '#2e7d32',
            confirmButtonText: 'Đồng ý'
        });
        </c:if>
        <c:if test="${not empty errorMessage}">
        Swal.fire({
            icon: 'warning',
            title: 'Yêu cầu đăng nhập',
            text: '${errorMessage}',
            confirmButtonColor: '#2e7d32',
            confirmButtonText: 'Đồng ý'
        });
        <% session.removeAttribute("errorMessage"); %>
        </c:if>
    });
</script>
</body>
</html>