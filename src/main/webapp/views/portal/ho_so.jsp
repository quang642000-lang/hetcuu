<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Hồ Sơ Khách Hàng CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
</head>
<body class="bg-light">

<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-5">
    <div class="row g-4">
        <!-- Menu Trái -->
        <jsp:include page="/views/portal/profile-sidebar.jsp" />

        <!-- Form Điền Thông Tin Cá Nhân -->
        <div class="col-12 col-md-9">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <h4 class="fw-bold mb-4 text-dark"><i class="bi bi-person-fill text-success"></i> HỒ SƠ THÀNH VIÊN CRM</h4>

                <form action="${pageContext.request.contextPath}/profile/update" method="POST">
                    <div class="row g-3">
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

                    <button type="submit" class="btn btn-primary-teapos px-4 fw-bold mt-4">
                        Cập Nhật Hồ Sơ CRM
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

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