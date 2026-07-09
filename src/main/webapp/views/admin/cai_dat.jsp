<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Thiết Lập Hồ Sơ Cá Nhân</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="/views/layout/header_admin.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body>

<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <div class="admin-content p-4">
        <div class="row g-4">
            <!-- Cột 1: Thông tin cá nhân -->
            <div class="col-12 col-md-7">
                <div class="card card-teapos p-4">
                    <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                        <i class="bi bi-person-circle text-success"></i> Thông tin hồ sơ cá nhân
                    </h5>

                    <form action="${pageContext.request.contextPath}/admin/settings" method="POST">
                        <input type="hidden" name="action" value="updateInfo">

                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold">Họ và tên nhân viên</label>
                            <input type="text" name="hoTen" class="form-control form-control-teapos" value="<c:out value="${adminProfile.hoTen}"/>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold">Số điện thoại di động</label>
                            <input type="text" name="soDienThoai" class="form-control form-control-teapos" value="${adminProfile.soDienThoai}" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label text-muted small fw-semibold">Địa chỉ Email liên hệ</label>
                            <input type="email" name="email" class="form-control form-control-teapos" value="${adminProfile.email}" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label text-muted small fw-semibold">Tên đăng nhập nội bộ</label>
                            <input type="text" name="tenDangNhap" class="form-control form-control-teapos bg-light" value="<c:out value="${adminProfile.tenDangNhap}"/>" readonly>
                        </div>

                        <button type="submit" class="btn btn-primary-teapos px-4 fw-bold">
                            <i class="bi bi-check-circle-fill me-1"></i> Cập nhật hồ sơ
                        </button>
                    </form>
                </div>
            </div>

            <!-- Cột 2: Đổi mật khẩu an toàn -->
            <div class="col-12 col-md-5">
                <div class="card card-teapos p-4">
                    <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                        <i class="bi bi-shield-lock-fill text-danger"></i> Đổi mật khẩu đăng nhập
                    </h5>

                    <form action="${pageContext.request.contextPath}/admin/settings" method="POST" id="formPassword">
                        <input type="hidden" name="action" value="changePassword">

                        <div class="mb-3">
                            <label for="oldPassword" class="form-label text-muted small fw-semibold">Mật khẩu hiện tại</label>
                            <input type="password" id="oldPassword" name="oldPassword" class="form-control form-control-teapos" required placeholder="Nhập mật khẩu hiện hành...">
                        </div>
                        <div class="mb-3">
                            <label for="newPassword" class="form-label text-muted small fw-semibold">Mật khẩu mới</label>
                            <input type="password" id="newPassword" name="newPassword" class="form-control form-control-teapos" required placeholder="Tối thiểu 8 ký tự...">
                        </div>
                        <div class="mb-4">
                            <label for="confirmPassword" class="form-label text-muted small fw-semibold">Xác nhận mật khẩu mới</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control form-control-teapos" required placeholder="Nhập lại mật khẩu mới...">
                        </div>

                        <button type="submit" class="btn btn-primary-teapos w-100 fw-bold">
                            <i class="bi bi-key-fill"></i> Ghi nhận thay đổi mật khẩu
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Đón nhận tham số báo thành công từ URL redirect
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'infosuccess') showToast('success', 'Đã lưu thay đổi thông tin cá nhân của bạn!');
        if (msg === 'passwordsuccess') showToast('success', 'Đã cập nhật mật khẩu đăng nhập mới thành công!');

        // Đón nhận lỗi đổi mật khẩu sai ở Backend
        <c:if test="${not empty errorPassword}">
        Swal.fire({
            icon: 'warning',
            title: 'Thất bại',
            text: '${errorPassword}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>

        // Validation khớp mật khẩu tại Client-side
        const formPass = document.getElementById("formPassword");
        formPass.addEventListener("submit", function(e) {
            const newPass = document.getElementById("newPassword").value;
            const confirm = document.getElementById("confirmPassword").value;

            if (newPass.length < 8) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Mật khẩu yếu',
                    text: 'Mật khẩu bắt buộc phải từ 8 ký tự trở lên!',
                    confirmButtonColor: '#2e7d32'
                });
                return;
            }

            if (newPass !== confirm) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Xác nhận không khớp',
                    text: 'Mật khẩu nhập lại phải trùng khớp với mật khẩu mới!',
                    confirmButtonColor: '#2e7d32'
                });
            }
        });
    });
</script>
</body>
</html>