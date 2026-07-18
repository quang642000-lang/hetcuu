<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đăng Nhập Hội Viên CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <style>
        body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; height: 100vh; }
        .auth-card { width: 100%; max-width: 440px; background-color: #ffffff; border-radius: 16px; box-shadow: 0 10px 30px rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.1); overflow: hidden; }
        .brand-banner { background-color: #10b981; color: #ffffff; padding: 25px; text-align: center; }
    </style>
</head>
<body>
<div class="auth-card animate__animated animate__fadeIn">
    <div class="brand-banner">
        <div class="fs-1 mb-2"><i class="bi bi-cup-hot-fill"></i></div>
        <h4 class="fw-bold mb-0">TEA POS PORTAL</h4>
        <small class="opacity-90">Cổng đặt nước trực tuyến & Tích lũy điểm CRM</small>
    </div>
    <div class="p-4 text-start">
        <c:if test="${not empty requestScope.success}">
            <div class="alert alert-success small text-center mb-3 fw-bold"><i class="bi bi-check-circle-fill"></i> ${requestScope.success}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/customer/login" method="POST">
            <div class="mb-3">
                <label class="form-label fw-semibold text-dark small">Email hoặc Số điện thoại</label>
                <input type="text" class="form-control" name="username" placeholder="example@teapos.vn..." required>
            </div>
            <div class="mb-4">
                <div class="d-flex justify-content-between mb-1">
                    <label class="form-label fw-semibold text-dark small mb-0">Mật khẩu</label>
                    <!-- QUÊN MẬT KHẨU CHO KHÁCH HÀNG GẮN ROLE=CUSTOMER -->
                    <a href="${pageContext.request.contextPath}/forgot-password?role=customer" class="text-decoration-none small text-success fw-bold">Quên mật khẩu?</a>
                </div>
                <input type="password" class="form-control" name="password" placeholder="Nhập mật khẩu..." required>
            </div>
            <button type="submit" class="btn btn-success w-100 py-2.5 fw-bold text-uppercase"><i class="bi bi-box-arrow-in-right"></i> ĐĂNG NHẬP THÀNH VIÊN</button>
            <div class="text-center mt-3">
                <span class="text-muted small">Chưa có thẻ thành viên? </span>
                <a href="${pageContext.request.contextPath}/register" class="text-success text-decoration-none fw-bold small">Đăng ký ngay</a>
            </div>
        </form>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        <c:if test="${not empty requestScope.error}">
        Swal.fire({ icon: 'error', title: 'Thất bại', text: '${requestScope.error}', confirmButtonColor: '#ef4444' });
    </c:if>
</script>
</body>
</html>
