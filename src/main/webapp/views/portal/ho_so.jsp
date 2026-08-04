<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Hồ Sơ Khách Hàng CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet">
</head>
<body class="bg-light">
<!-- NAV HEADER -->
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4 py-lg-5">
    <div class="row g-4">
        <!-- Menu Trái -->
        <jsp:include page="/views/portal/profile-sidebar.jsp" />

        <!-- Form Điền Thông Tin Cá Nhân -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px; border: 1px solid var(--border-color) !important;">
                <h4 class="fw-bold mb-4 text-dark text-start"><i class="bi bi-person-fill text-success"></i> HỒ SƠ THÀNH VIÊN CRM</h4>
                <form action="${pageContext.request.contextPath}/profile/update" method="POST">
                    <div class="row g-3 text-start">
                        <div class="col-12 col-md-6">
                            <label class="form-label text-muted small fw-bold">Họ và tên thành viên</label>
                            <input type="text" name="tenKh" class="form-control form-control-teapos" value="<c:out value="${customerProfile.tenKh}"/>" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-muted small fw-bold">Số điện thoại di động</label>
                            <input type="text" name="soDienThoai" class="form-control form-control-teapos" value="${customerProfile.soDienThoai}" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-muted small fw-bold">Địa chỉ Email nhận OTP</label>
                            <input type="email" name="email" class="form-control form-control-teapos" value="${customerProfile.email}" required>
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-muted small fw-bold">Ngày sinh nhật</label>
                            <input type="date" name="ngaySinh" class="form-control form-control-teapos" value="${customerProfile.ngaySinh}">
                        </div>
                        <div class="col-12 col-md-6">
                            <label class="form-label text-muted small fw-bold">Giới tính</label>
                            <select name="gioiTinh" class="form-select form-control-teapos">
                                <option value="Nam" ${customerProfile.gioiTinh eq 'Nam' ? 'selected' : ''}>Nam</option>
                                <option value="Nữ" ${customerProfile.gioiTinh eq 'Nữ' ? 'selected' : ''}>Nữ</option>
                                <option value="Khác" ${customerProfile.gioiTinh eq 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-muted small fw-bold">Địa chỉ liên hệ và giao nước</label>
                            <textarea name="diaChiLienHe" class="form-control form-control-teapos" rows="2"><c:out value="${customerProfile.diaChiLienHe}"/></textarea>
                        </div>
                    </div>
                    <div class="text-start">
                        <button type="submit" class="btn btn-primary-teapos px-4 fw-bold mt-4">
                            Cập Nhật Hồ Sơ CRM
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi hồ sơ cá nhân thành công!');
    });
</script>
</body>
</html>
