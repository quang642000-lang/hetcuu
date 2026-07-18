<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Khôi Phục Mật Khẩu Hội Viên</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8fafc; display: flex; align-items: center; justify-content: center; height: 100vh; }
        .forgot-card { width: 100%; max-width: 460px; background-color: #ffffff; border-radius: 16px; box-shadow: 0 8px 30px rgba(16, 185, 129, 0.15); overflow: hidden; }
        .card-header-teapos { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; text-align: center; padding: 25px; }
    </style>
</head>
<body>
<div class="forgot-card">
    <div class="card-header-teapos">
        <div class="fs-1 mb-2 text-white"><i class="bi bi-cup-hot-fill"></i></div>
        <h4 class="fw-bold mb-1 text-uppercase">KHÔI PHỤC MẬT KHẨU</h4>
        <p class="mb-0 small text-white-50">Cơ chế xác thực an toàn OTP dành riêng cho Khách Hàng CRM</p>
    </div>
    <div class="p-4 text-start">
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger small text-center mb-3"><i class="bi bi-exclamation-triangle-fill"></i> ${requestScope.error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <input type="hidden" name="role" value="customer">
            <div class="mb-4">
                <label class="form-label fw-bold text-dark small">Nhập địa chỉ Email đăng ký tài khoản</label>
                <input type="email" class="form-control" name="email" value="<c:out value='${email}'/>" placeholder="Nhập email khách hàng..." required>
            </div>
            <button type="submit" class="btn btn-success w-100 py-2.5 fw-bold text-uppercase"><i class="bi bi-send-fill me-1"></i> Nhận mã OTP xác thực</button>
            <div class="text-center mt-3">
                <a href="${pageContext.request.contextPath}/customer/login" class="text-success text-decoration-none fw-bold small"><i class="bi bi-arrow-left"></i> Quay lại đăng nhập Portal</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>