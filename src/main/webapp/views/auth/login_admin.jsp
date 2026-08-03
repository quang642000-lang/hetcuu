<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đăng Nhập Hệ Thống Quản Trị</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        body { background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; height: 100vh; font-family: 'Inter', sans-serif; }
        .auth-card { width: 100%; max-width: 420px; background-color: #ffffff; border-radius: 16px; box-shadow: var(--shadow-lg); overflow: hidden; border: 1px solid var(--border-color); }
        .brand-banner { background-color: #0f172a; color: #ffffff; padding: 30px 25px; text-align: center; border-bottom: 1px solid #1e293b; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="brand-banner">
        <div class="fs-1 mb-2 text-success animate-pulse"><i class="bi bi-shield-lock-fill"></i></div>
        <h4 class="fw-bold mb-0" style="letter-spacing: 1px;">TEA POS SYSTEM</h4>
        <small class="opacity-75">Đăng nhập quầy thu ngân & Quản trị hệ thống</small>
    </div>
    <div class="p-4">
        <c:if test="${not empty requestScope.success}">
            <div class="alert alert-success small text-center mb-3 fw-bold"><i class="bi bi-check-circle-fill"></i> ${requestScope.success}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/login" method="POST">
            <div class="mb-3 text-start">
                <label class="form-label fw-bold text-muted small">Tài khoản nhân viên</label>
                <input type="text" class="form-control form-control-teapos" name="username" placeholder="Nhập tên tài khoản..." value="<c:out value='${username}'/>" required>
            </div>
            <div class="mb-4 text-start">
                <div class="d-flex justify-content-between mb-1">
                    <label class="form-label fw-bold text-muted small mb-0">Mật khẩu</label>
                    <a href="${pageContext.request.contextPath}/forgot-password?role=employee" class="text-decoration-none small text-success fw-bold">Quên mật khẩu?</a>
                </div>
                <input type="password" class="form-control form-control-teapos" name="password" placeholder="Nhập mật khẩu..." required>
            </div>
            <button type="submit" class="btn btn-success w-100 py-2.5 fw-bold text-uppercase" style="background-color: #059669; border: none;"><i class="bi bi-box-arrow-in-right me-1"></i> VÀO CA LÀM VIỆC</button>
        </form>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty requestScope.error}">
        Swal.fire({ icon: 'error', title: 'Thất bại', text: '${requestScope.error}', confirmButtonColor: '#ef4444' });
        </c:if>
    });
</script>
</body>
</html>
