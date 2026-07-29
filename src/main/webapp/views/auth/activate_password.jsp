<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đặt Mật Khẩu Thành Viên</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .reset-card { width: 100%; max-width: 480px; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(16, 185, 129, 0.1); }
    </style>
</head>
<body>
<div class="reset-card p-4 p-md-5">
    <div class="text-center mb-4">
        <div class="text-success fs-1 mb-2"><i class="bi bi-shield-lock-fill"></i></div>
        <h4 class="fw-bold mb-1">TẠO MẬT KHẨU ĐĂNG NHẬP</h4>
        <p class="text-muted small">Cảm ơn bạn đã kích hoạt thẻ thành viên! Hãy tạo mật khẩu riêng tư để bảo vệ điểm tích lũy và sử dụng các tính năng đặt hàng online.</p>
    </div>
    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
    </c:if>
    <form action="${pageContext.request.contextPath}/activate/password" method="POST" id="resetForm">
        <div class="mb-3 text-start">
            <label for="newPassword" class="form-label fw-semibold text-dark small">Tạo mật khẩu mới</label>
            <input type="password" class="form-control form-control-teapos py-2" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu..." required>
        </div>
        <div class="mb-4 text-start">
            <label for="confirmPassword" class="form-label fw-semibold text-dark small">Xác nhận mật khẩu mới</label>
            <input type="password" class="form-control form-control-teapos py-2" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu..." required>
        </div>
        <button type="submit" class="btn btn-primary-teapos w-100 py-2.5 fw-bold text-uppercase"><i class="bi bi-check-circle-fill me-1"></i> Hoàn thành kích hoạt</button>
    </form>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const form = document.getElementById("resetForm");
        form.addEventListener("submit", function(e) {
            const password = document.getElementById("newPassword").value;
            const confirm = document.getElementById("confirmPassword").value;
            if (password !== confirm) {
                e.preventDefault();
                Swal.fire({ icon: 'warning', title: 'Không trùng khớp', text: 'Xác nhận mật khẩu nhập lại không chính xác!', confirmButtonColor: '#10b981' });
                return;
            }
            if (password.length < 8) {
                e.preventDefault();
                Swal.fire({ icon: 'warning', title: 'Mật khẩu yếu', text: 'Mật khẩu bảo mật bắt buộc phải dài từ 8 ký tự trở lên!', confirmButtonColor: '#10b981' });
                return;
            }
        });
    });
</script>
</body>
</html>