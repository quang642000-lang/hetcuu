<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đặt Lại Mật Khẩu Mới</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .reset-bg {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        }
        .reset-card {
            width: 100%;
            max-width: 480px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 8px 30px rgba(46, 125, 50, 0.15);
        }
    </style>
</head>
<body>
<div class="reset-bg">
    <div class="reset-card p-4 p-md-5">
        <div class="text-center mb-4">
            <div class="text-success fs-1 mb-2"><i class="bi bi-shield-lock-fill"></i></div>
            <h4 class="fw-bold mb-1">MẬT KHẨU MỚI</h4>
            <p class="text-muted small">Quý khách vui lòng tạo mật khẩu mới để bảo mật tài khoản (Yêu cầu tối thiểu từ 8 ký tự).</p>
        </div>

        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/reset-password" method="POST" id="resetForm">
            <!-- Mật khẩu mới -->
            <div class="mb-3 text-start">
                <label for="newPassword" class="form-label fw-semibold text-dark small">Mật khẩu mới</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control bg-white border-start-0 py-2" id="newPassword" name="newPassword"
                           placeholder="Nhập mật khẩu mới..." required>
                </div>
            </div>
            <!-- Xác nhận mật khẩu -->
            <div class="mb-4 text-start">
                <label for="confirmPassword" class="form-label fw-semibold text-dark small">Xác nhận mật khẩu</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-shield-fill-check"></i></span>
                    <input type="password" class="form-control bg-white border-start-0 py-2" id="confirmPassword" name="confirmPassword"
                           placeholder="Nhập lại mật khẩu trùng khớp..." required>
                </div>
            </div>
            <!-- Button Submit -->
            <button type="submit" class="btn btn-primary-teapos w-100 py-2 fw-bold text-uppercase shadow-sm" style="border-radius: 8px;">
                <i class="bi bi-check-circle-fill me-2 small"></i> Thay đổi mật khẩu
            </button>
        </form>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const form = document.getElementById("resetForm");
        form.addEventListener("submit", function(e) {
            const password = document.getElementById("newPassword").value;
            const confirm = document.getElementById("confirmPassword").value;
            if (password !== confirm) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Xác nhận không khớp',
                    text: 'Mật khẩu nhập lại phải trùng khớp với mật khẩu mới!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }
            if (password.length < 8) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Mật khẩu yếu',
                    text: 'Mật khẩu bắt buộc phải từ 8 ký tự trở lên!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }
        });
    });
</script>
</body>
</html>