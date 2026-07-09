<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Hành Nhân Sự Nội Bộ</title>
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
        <div class="card card-teapos p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">HỒ SƠ NHÂN VIÊN CHUỖI CỬA HÀNG</h3>
                    <p class="text-muted small mb-0">Thiết lập tài khoản đăng nhập vào ca, phân chia vai trò và kiểm soát trạng thái nhân viên</p>
                </div>
                <button class="btn btn-primary-teapos d-flex align-items-center gap-2" onclick="openCreateEmployeeModal()">
                    <i class="bi bi-person-plus-fill"></i> Thêm Nhân Viên Mới
                </button>
            </div>

            <!-- BẢNG LIÊN KẾT NHÂN VIÊN -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th>Mã NV</th>
                        <th>Họ và tên nhân sự</th>
                        <th>Số điện thoại</th>
                        <th>Địa chỉ Email</th>
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
                                        <c:choose>
                                            <c:when test="${item.maVt == 1}">
                                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger">Quản lý (Admin)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-info bg-opacity-10 text-info border border-info">Thu ngân (Staff)</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThai}">
                                                <span class="badge bg-success bg-opacity-10 text-success border border-success px-2 py-1">Đang làm việc</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger px-2 py-1">Nghỉ việc/Khóa</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <button class="btn btn-sm btn-outline-warning fw-semibold px-2" onclick="openResetPasswordModal('${item.maNv}', '<c:out value="${item.hoTen}"/>')">
                                                <i class="bi bi-key-fill"></i> Reset Pass
                                            </button>
                                            <button class="btn btn-sm btn-outline-primary fw-semibold px-2"
                                                    onclick="openEditEmployeeModal('${item.maNv}', '<c:out value="${item.hoTen}"/>', '${item.soDienThoai}', '${item.email}', '<c:out value="${item.tenDangNhap}"/>', ${item.maVt}, ${item.trangThai ? 1 : 0})">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger px-2" onclick="confirmDeleteEmployee('${item.maNv}')">
                                                <i class="bi bi-trash"></i> Khóa
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">Chưa nạp bất kỳ hồ sơ nhân viên nào!</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- MODAL FORM TOÀN NĂNG (THÊM / CẬP NHẬT NHÂN VIÊN) -->
<div class="modal fade" id="employeeFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header text-white py-3" style="background-color: var(--primary-color); border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title fw-bold" id="empModalTitle">THÊM NHÂN VIÊN MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form id="employeeForm" action="${pageContext.request.contextPath}/admin/nhanvien" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maNv" id="formMaNv">

                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label for="hoTen" class="form-label fw-bold text-dark small">Họ và tên đầy đủ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="hoTen" name="hoTen" required autocomplete="off">
                    </div>

                    <div class="mb-3">
                        <label for="soDienThoai" class="form-label fw-bold text-dark small">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="soDienThoai" name="soDienThoai" required autocomplete="off">
                    </div>

                    <div class="mb-3">
                        <label for="email" class="form-label fw-bold text-dark small">Email nội bộ <span class="text-danger">*</span></label>
                        <input type="email" class="form-control form-control-teapos" id="email" name="email" required autocomplete="off">
                    </div>

                    <div class="mb-3">
                        <label for="tenDangNhap" class="form-label fw-bold text-dark small">Tên đăng nhập hệ thống <span class="text-danger">*</span></label>
                        <input type="text" class="form-control form-control-teapos" id="tenDangNhap" name="tenDangNhap" required autocomplete="off">
                    </div>

                    <!-- Mật khẩu mặc định chỉ nạp khi tạo mới -->
                    <div class="mb-3" id="passwordFieldGroup">
                        <label for="matKhau" class="form-label fw-bold text-dark small">Mật khẩu đăng nhập mặc định <span class="text-danger">*</span></label>
                        <input type="password" class="form-control form-control-teapos" id="matKhau" name="matKhau" placeholder="Mật khẩu tối thiểu 8 chữ ký tự...">
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label for="maVt" class="form-label fw-bold text-dark small">Quyền vai trò</label>
                            <select name="maVt" id="maVt" class="form-select form-control-teapos">
                                <option value="1">Quản lý (Admin)</option>
                                <option value="2">Thu ngân (Staff)</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-bold text-dark small">Trạng thái công việc</label>
                            <select name="trangThai" id="trangThai" class="form-select form-control-teapos">
                                <option value="1">Đang làm việc</option>
                                <option value="0">Tạm dừng ca/Khóa</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light" style="border-bottom-left-radius: 16px; border-bottom-right-radius: 16px;">
                    <button type="button" class="btn btn-secondary-teapos px-4" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn-teapos btn-primary-teapos px-4 fw-bold"><i class="bi bi-save me-1"></i> Lưu thông tin</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- POPUP RESET MẬT KHẨU NHÂN VIÊN DÀNH RIÊNG CHO QUẢN LÝ -->
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
                    <p class="small text-muted mb-2">Đang thiết lập lại mật khẩu bảo mật cho nhân viên: <strong id="resetTenNv"></strong></p>
                    <div class="mb-1">
                        <label for="matKhauMoi" class="form-label fw-bold small">Mật khẩu mới</label>
                        <input type="password" name="matKhauMoi" class="form-control form-control-sm" required minlength="8" placeholder="Nhập mật khẩu mới...">
                    </div>
                </div>
                <div class="modal-footer p-2 bg-light">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-sm btn-warning fw-bold">Xác nhận reset</button>
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

        // Sửa hồ sơ không cần gõ mật khẩu mới
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
            text: "Chuyển trạng thái hoạt động về Ngừng làm việc để chặn truy cập POS/Admin!",
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

        if (msg === 'createsuccess') showToast('success', 'Thêm nhân viên và khởi tạo mật khẩu thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi hồ sơ nhân sự!');
        if (msg === 'deletesuccess') showToast('success', 'Đã chuyển trạng thái nhân viên sang khóa hoạt động!');
        if (msg === 'resetsuccess') showToast('success', 'Đặt lại mật khẩu thành công!');

        <c:if test="${not empty error}">
        Swal.fire({
            icon: 'error',
            title: 'Lỗi ràng buộc dữ liệu',
            text: '${error}',
            confirmButtonColor: '#2e7d32'
        });
        </c:if>
    });
</script>
</body>
</html>