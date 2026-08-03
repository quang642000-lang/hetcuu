<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Kích Hoạt Thẻ Thành Viên Quầy</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; font-family: 'Inter', sans-serif; }
        .auth-card { width: 100%; max-width: 460px; background-color: #ffffff; border-radius: 16px; box-shadow: var(--shadow-lg); overflow: hidden; border: 1px solid var(--border-color); }
        .brand-banner { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; text-align: center; padding: 35px 25px; }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="brand-banner">
        <div class="fs-1 mb-2 text-white animate-pulse"><i class="bi bi-person-check-fill"></i></div>
        <h4 class="fw-bold mb-1 text-uppercase">KÍCH HOẠT THẺ THÀNH VIÊN</h4>
        <p class="mb-0 small text-white-50">Kích hoạt tài khoản quầy POS để đặt nước online, tích lũy điểm CRM</p>
    </div>
    <div class="p-4 text-start">
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/activate" method="POST">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark small">Số điện thoại hoặc Email đăng ký tại quầy</label>
                <input type="text" class="form-control form-control-teapos py-2.5" name="username" placeholder="Ví dụ: 0912345678..." required autocomplete="off">
            </div>
            <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold text-uppercase shadow-sm"><i class="bi bi-send-fill me-1"></i> Gửi mã OTP xác thực</button>
            <div class="text-center mt-4 border-top pt-3">
                <a href="${pageContext.request.contextPath}/customer/login" class="text-success text-decoration-none fw-bold small"><i class="bi bi-arrow-left"></i> Quay lại đăng nhập</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
