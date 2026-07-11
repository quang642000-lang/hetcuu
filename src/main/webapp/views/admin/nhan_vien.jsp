<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Hành Nhân Sự Nội Bộ</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px;">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">HỒ SƠ NHÂN VIÊN CHUỖI CỬA HÀNG</h3>
                        <p class="text-muted small mb-0">Thiết lập tài khoản đăng nhập vào ca, phân chia vai trò và kiểm soát trạng thái nhân viên</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateEmployeeModal()">
                        <i class="bi bi-person-plus-fill"></i> Thêm Nhân Viên Mới
                    </button>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                        <tr class="table-light">
                            <th>Mã NV</th>
                            <th>Họ và tên nhân sự</th>
                            <th>Số điện thoại</th>
                            <th>Email</th>
                            <th>Tên đăng nhập</th>
                            <th class="text-center">Vai trò</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-end">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <c:forEach var="item" items="${employees}">
                                    <tr>
                                        <td><strong>${item.maNv}</strong></td>
                                        <td><strong><c:out value="${item.hoTen}"/></strong></td>
                                        <td>${item.soDienThoai}</td>
                                        <td>${item.email}</td>
                                        <td><code><c:out value="${item.tenDangNhap}"/></code></td>
                                        <td class="text-center">
<span class="badge ${item.maVt == 1 ? 'bg-danger text-danger border-danger' : 'bg-info text-info border-info'} bg-opacity-10 border px-2.5 py-1">
        ${item.maVt == 1 ? 'Quản lý (Admin)' : 'Thu ngân (Staff)'}
</span>
                                        </td>
                                        <td class="text-center">
<span class="badge ${item.trangThai ? 'bg-success text-success border-success' : 'bg-danger text-danger border-danger'} bg-opacity-10 border px-2.5 py-1">
        ${item.trangThai ? 'Đang làm việc' : 'Khóa ca'}
</span>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-warning fw-semibold px-2 me-1" onclick="openResetPasswordModal('${item.maNv}', '<c:out value="${item.hoTen}"/>')">
                                                <i class="bi bi-key-fill"></i> Reset
                                            </button>
                                            <!-- SỬA ĐỒNG BỘ: Sử dụng dataset chống gãy rụng dấu quote lồng nhau -->
                                            <button class="btn btn-sm btn-outline-primary fw-semibold px-2 me-1"
                                                    data-id="${item.maNv}"
                                                    data-name="${item.hoTen}"
                                                    data-phone="${item.soDienThoai}"
                                                    data-email="${item.email}"
                                                    data-user="${item.tenDangNhap}"
                                                    data-role="${item.maVt}"
                                                    data-status="${item.trangThai ? 1 : 0}"
                                                    onclick="handleEditEmployeeClick(this)">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger px-2 fw-bold" onclick="confirmDeleteEmployee('${item.maNv}')">
                                                Khóa
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="8" class="text-center py-5 text-muted">Chưa ghi nhận nhân sự nào!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- MODAL TOÀN NĂNG -->
<div class="modal fade" id="employeeFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color);">
                <h5 class="modal-title fw-bold" id="empModalTitle">THÊM NHÂN VIÊN MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="employeeForm" action="${pageContext.request.contextPath}/admin/nhanvien" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maNv" id="formMaNv">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="hoTen" class="form-label fw-bold small">Họ và tên đầy đủ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="hoTen" name="hoTen" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="soDienThoai" class="form-label fw-bold small">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="soDienThoai" name="soDienThoai" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label fw-bold small">Email nội bộ <span class="text-danger">*</span></label>
                        <input type="email" class="form-control form-control-teapos" id="email" name="email" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="tenDangNhap" class="form-label fw-bold small">Tên đăng nhập <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDangNhap" name="tenDangNhap" required autocomplete="off">
                    </div>
                    <div class="mb-3" id="passwordFieldGroup">
                        <label for="matKhau" class="form-label fw-bold small">Mật khẩu đăng nhập mặc định <span class="text-danger">*</span></label>
                        <input type="password" class="form-control form-control-teapos" id="matKhau" name="matKhau" placeholder="Mật khẩu từ 8 ký tự...">
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label for="maVt" class="form-label fw-bold small">Quyền vai trò</label>
                            <select name="maVt" id="maVt" class="form-select form-control-teapos">
                                <option value="1">Quản lý (Admin)</option>
                                <option value="2">Thu ngân (Staff)</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-bold small">Trạng thái công việc</label>
                            <select name="trangThai" id="trangThai" class="form-select form-control-teapos">
                                <option value="1">Đang làm việc</option>
                                <option value="0">Tạm dừng ca</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-secondary-teapos" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn-teapos btn-primary-teapos fw-bold"><i class="bi bi-save me-1"></i> Lưu thông tin</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!-- POPUP RESET MẬT KHẨU -->
<div class="modal fade" id="resetPasswordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-warning text-dark py-2.5">
                <h6 class="modal-title fw-bold"><i class="bi bi-key-fill"></i> RESET MẬT KHẨU</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/nhanvien" method="POST">
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="maNv" id="resetMaNv">
                <div class="modal-body p-3">
                    <p class="small text-muted mb-2">Đang reset mật khẩu của nhân viên: <strong id="resetTenNv"></strong></p>
                    <div class="mb-1">
                        <label for="matKhauMoi" class="form-label fw-bold small">Mật khẩu mới</label>
                        <input type="password" name="matKhauMoi" class="form-control form-control-sm" required minlength="8" placeholder="Tối thiểu 8 ký tự...">
                    </div>
                </div>
                <div class="modal-footer p-2 bg-light">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-sm btn-warning fw-bold">Xác nhận</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const empModal = new bootstrap.Modal(document.getElementById('employeeFormModal'));
    const passModal = new bootstrap.Modal(document.getElementById('resetPasswordModal'));
    function openCreateEmployeeModal() {
        document.getElementById("employeeForm").reset();
        document.getElementById("empModalTitle").innerText = "THÊM MỚI NHÂN VIÊN";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaNv").value = "";
        document.getElementById("passwordFieldGroup").style.display = "block";
        document.getElementById("matKhau").required = true;
        empModal.show();
    }
    function handleEditEmployeeClick(button) {
        const maNv = button.getAttribute("data-id");
        const hoTen = button.getAttribute("data-name");
        const soDienThoai = button.getAttribute("data-phone");
        const email = button.getAttribute("data-email");
        const username = button.getAttribute("data-user");
        const maVt = button.getAttribute("data-role");
        const trangThai = parseInt(button.getAttribute("data-status"));
        openEditEmployeeModal(maNv, hoTen, soDienThoai, email, username, maVt, trangThai);
    }
    function openEditEmployeeModal(maNv, hoTen, sdt, email, username, maVt, trangThai) {
        document.getElementById("empModalTitle").innerText = "CẬP NHẬT NHÂN VIÊN: " + maNv;
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaNv").value = maNv;
        document.getElementById("hoTen").value = hoTen;
        document.getElementById("soDienThoai").value = sdt;
        document.getElementById("email").value = email;
        document.getElementById("tenDangNhap").value = username;
        document.getElementById("maVt").value = maVt;
        document.getElementById("trangThai").value = trangThai;
        document.getElementById("passwordFieldGroup").style.display = "none";
        document.getElementById("matKhau").required = false;
        empModal.show();
    }
    function openResetPasswordModal(maNv, hoTen) {
        document.getElementById("resetMaNv").value = maNv;
        document.getElementById("resetTenNv").innerText = hoTen;
        passModal.show();
    }
    function confirmDeleteEmployee(maNv) {
        Swal.fire({
            title: 'Khóa tài khoản nhân viên?',
            text: "Nhân viên bị khóa sẽ không thể đăng nhập vào quầy POS bán hàng!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý khóa',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/nhanvien?action=delete&id=' + maNv;
            }
        });
    }
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm nhân viên thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi hồ sơ!');
        if (msg === 'deletesuccess') showToast('success', 'Đã khóa tài khoản nhân viên!');
        if (msg === 'resetsuccess') showToast('success', 'Reset mật khẩu thành công!');
    });
</script>
</body>
</html>