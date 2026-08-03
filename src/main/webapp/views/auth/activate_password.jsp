<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
        body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: 'Inter', sans-serif; }
        .reset-card { width: 100%; max-width: 480px; background-color: #ffffff; border-radius: 16px; box-shadow: var(--shadow-lg); border: 1px solid var(--border-color); }
        .reset-header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 35px 25px; border-radius: 16px 16px 0 0; text-align: center; }
    </style>
</head>
<body>
<div class="reset-card">
    <div class="reset-header">
        <div class="fs-1 mb-2 text-white"><i class="bi bi-shield-lock-fill"></i></div>
        <h4 class="fw-bold mb-1 text-uppercase">TẠO MẬT KHẨU ĐĂNG NHẬP</h4>
        <p class="mb-0 small text-white-50">Cảm ơn bạn đã kích hoạt thẻ thành viên! Hãy bảo vệ tài khoản của bạn.</p>
    </div>
    <div class="p-4 p-md-5">
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/activate/password" method="POST" id="resetForm">
            <div class="mb-3 text-start">
                <label for="newPassword" class="form-label fw-semibold text-dark small">Tạo mật khẩu mới</label>
                <input type="password" class="form-control form-control-teapos py-2.5" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu..." required>
            </div>
            <div class="mb-4 text-start">
                <label for="confirmPassword" class="form-label fw-semibold text-dark small">Xác nhận mật khẩu mới</label>
                <input type="password" class="form-control form-control-teapos py-2.5" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu..." required>
            </div>
            <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold text-uppercase shadow-sm"><i class="bi bi-check-circle-fill me-1"></i> Hoàn thành kích hoạt</button>
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
