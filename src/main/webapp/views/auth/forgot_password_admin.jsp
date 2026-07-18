<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Khôi Phục Mật Khẩu Nội Bộ</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background-color: #f1f5f9; display: flex; align-items: center; justify-content: center; height: 100vh; }
        .forgot-card { width: 100%; max-width: 460px; background-color: #ffffff; border-radius: 16px; box-shadow: 0 8px 30px rgba(15, 23, 42, 0.15); overflow: hidden; }
        .card-header-teapos { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); color: white; text-align: center; padding: 25px; }
    </style>
</head>
<body>
<div class="forgot-card">
    <div class="card-header-teapos">
        <div class="fs-1 mb-2 text-success"><i class="bi bi-shield-lock-fill"></i></div>
        <h4 class="fw-bold mb-1 text-uppercase">KHÔI PHỤC MẬT KHẨU NỘI BỘ</h4>
        <p class="mb-0 small text-white-50">Cơ chế xác thực an toàn OTP dành riêng cho Nhân viên & Quản lý</p>
    </div>
    <div class="p-4 text-start">
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="role" value="employee">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark small">Nhập địa chỉ Email nội bộ đăng ký</label>
                <input type="email" class="form-control" name="email" value="<c:out value='${email}'/>" placeholder="Nhập email nhân viên..." required>
            </div>
            <button type="submit" class="btn btn-dark w-100 py-2.5 fw-bold text-uppercase" style="background-color: #0f172a; border-color: #0f172a;"><i class="bi bi-send-fill me-1"></i> Nhận mã OTP xác thực</button>
            <div class="text-center mt-3">
                <a href="${pageContext.request.contextPath}/login" class="text-secondary text-decoration-none fw-bold small"><i class="bi bi-arrow-left"></i> Quay lại đăng nhập Staff</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>