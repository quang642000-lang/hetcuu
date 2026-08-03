<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đăng Ký Tài Khoản Thành Viên</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .register-container { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%); padding: 40px 15px; font-family: 'Inter', sans-serif; }
        .register-card { width: 100%; max-width: 550px; background-color: #ffffff; border-radius: 16px; box-shadow: var(--shadow-lg); border: 1px solid var(--border-color); }
    </style>
</head>
<body>
<div class="register-container">
    <div class="register-card p-4 p-md-5">
        <div class="text-center mb-4">
            <h3 class="fw-bold text-success mb-1">TẠO TÀI KHOẢN MỚI</h3>
            <p class="text-muted small">Gia nhập thành viên TEA Shop để nhận ngay các quyền lợi tích điểm độc quyền</p>
        </div>
        <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm">
            <div class="mb-3 text-start">
                <label for="tenKh" class="form-label fw-semibold text-dark small">Họ và tên khách hàng</label>
                <input type="text" class="form-control form-control-teapos" id="tenKh" name="tenKh" placeholder="Nhập họ và tên đầy đủ..." value="<c:out value='${tenKh}'/>" required>
            </div>
            <div class="mb-3 text-start">
                <label for="soDienThoai" class="form-label fw-semibold text-dark small">Số điện thoại di động</label>
                <input type="text" class="form-control form-control-teapos" id="soDienThoai" name="soDienThoai" placeholder="Nhập số điện thoại (Ví dụ: 0912345678)..." value="<c:out value='${soDienThoai}'/>" required>
                <div class="form-text text-muted" style="font-size: 11px;">Hệ thống sẽ gửi OTP kích hoạt đến số điện thoại và email đăng ký này.</div>
            </div>
            <div class="mb-3 text-start">
                <label for="email" class="form-label fw-semibold text-dark small">Địa chỉ Email cá nhân</label>
                <input type="email" class="form-control form-control-teapos" id="email" name="email" placeholder="Nhập email đăng ký (Ví dụ: khachhang@gmail.com)..." value="<c:out value='${email}'/>" required>
            </div>
            <div class="mb-3 text-start">
                <label for="password" class="form-label fw-semibold text-dark small">Mật khẩu đăng nhập</label>
                <input type="password" class="form-control form-control-teapos" id="password" name="password" placeholder="Mật khẩu tối thiểu 8 ký tự..." required>
            </div>
            <div class="mb-3 text-start">
                <label for="confirmPassword" class="form-label fw-semibold text-dark small">Xác nhận mật khẩu mới</label>
                <input type="password" class="form-control form-control-teapos" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu để xác nhận..." required>
            </div>
            <div class="mb-4 form-check text-start">
                <input type="checkbox" class="form-check-input" id="dongYDieuKhoan" name="dongYDieuKhoan" value="1" required>
                <label class="form-check-label text-muted small" for="dongYDieuKhoan">
                    Tôi hoàn toàn đồng ý với <a href="#" class="text-success text-decoration-none fw-semibold">Điều khoản sử dụng</a> và <a href="#" class="text-success text-decoration-none fw-semibold">Chính sách bảo mật</a> của TEA POS.
                </label>
            </div>
            <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold text-uppercase shadow-sm mb-3">
                <i class="bi bi-person-plus-fill me-2 fs-5"></i> Đăng ký thành viên
            </button>
            <div class="text-center">
                <span class="text-muted small">Đã có tài khoản thành viên? </span>
                <a href="${pageContext.request.contextPath}/customer/login" class="text-success text-decoration-none fw-bold small">Đăng nhập tại đây</a>
            </div>
        </form>
    </div>
</div>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const form = document.getElementById("registerForm");
        const sdtInput = document.getElementById("soDienThoai");

        sdtInput.addEventListener("input", function() {
            this.value = this.value.replace(/[^0-9]/g, '');
        });

        form.addEventListener("submit", function(e) {
            const sdt = sdtInput.value.trim();
            const password = document.getElementById("password").value;
            const confirmPassword = document.getElementById("confirmPassword").value;

            if (sdt.length < 10 || sdt.length > 11) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Số điện thoại không hợp lệ',
                    text: 'Số điện thoại phải từ 10 đến 11 chữ số đúng chuẩn Việt Nam!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }
            if (password !== confirmPassword) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Xác nhận mật khẩu sai',
                    text: 'Mật khẩu nhập lại không khớp với mật khẩu đã đặt!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }
            if (password.length < 8) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Mật khẩu chưa đủ mạnh',
                    text: 'Mật khẩu bắt buộc phải chứa tối thiểu 8 ký tự để bảo mật!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }
        });

        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Đăng ký lỗi',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>