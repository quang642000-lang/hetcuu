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
        <div class="p-4 admin-page-container">
            <div class="card card-teapos p-4 shadow-sm border-0" style="background-color: #ffffff;">
                <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-person-badge-fill me-2"></i>HỒ SƠ NHÂN VIÊN</h3>
                        <p class="text-muted small mb-0">Thiết lập tài khoản làm việc, phân chia quyền truy cập POS và kiểm soát trạng thái nhân viên</p>
                    </div>
                    <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateEmployeeModal()">
                        <i class="bi bi-person-plus-fill"></i> Thêm Nhân Viên Mới
                    </button>
                </div>

                <div class="table-responsive admin-table-container">
                    <table class="table admin-table align-middle" id="employeeTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 60px;">STT</th>
                            <th style="width: 100px;">Mã NV</th>
                            <th class="text-start">Họ và tên nhân sự</th>
                            <th>Số điện thoại</th>
                            <th>Email</th>
                            <th>Tên đăng nhập</th>
                            <th class="text-center" style="width: 150px;">Vai trò</th>
                            <th class="text-center" style="width: 150px;">Trạng Trạng</th>
                            <th style="width: 250px;">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody id="employeeTableBody">
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <c:forEach var="item" items="${employees}" varStatus="loop">
                                    <tr class="employee-row text-center">
                                        <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                        <td><code class="fw-bold text-dark">${item.maNv}</code></td>
                                        <td class="text-start"><strong><c:out value="${item.hoTen}"/></strong></td>
                                        <td>${item.soDienThoai}</td>
                                        <td>${item.email}</td>
                                        <td><code><c:out value="${item.tenDangNhap}"/></code></td>
                                        <td class="text-center">
                                            <span class="badge ${item.maVt == 1 ? 'bg-danger' : 'bg-info'} border px-2.5 py-1">
                                                    ${item.maVt == 1 ? 'Quản lý (Admin)' : 'Thu ngân (Staff)'}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge ${item.trangThai ? 'bg-success' : 'bg-danger'} border px-2.5 py-1">
                                                    ${item.trangThai ? 'Hoạt động' : 'Khóa ca'}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex justify-content-center gap-1.5">
                                                <!-- ĐỔI TRẠNG THÁI KHÓA CA / MỞ CA TOGGLE ĐỘNG -->
                                                <a href="${pageContext.request.contextPath}/admin/nhanvien?action=toggle&id=${item.maNv}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-outline-warning' : 'btn-outline-success'}">
                                                        ${item.trangThai ? 'Khóa Ca' : 'Mở Ca'}
                                                </a>
                                                <button type="button" class="btn btn-sm btn-outline-warning"
                                                        data-id="${item.maNv}"
                                                        data-name="${item.hoTen}"
                                                        onclick="handleResetPasswordClick(this)">
                                                    Reset
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-success"
                                                        data-id="${item.maNv}"
                                                        data-name="${item.hoTen}"
                                                        data-phone="${item.soDienThoai}"
                                                        data-email="${item.email}"
                                                        data-user="${item.tenDangNhap}"
                                                        data-role="${item.maVt}"
                                                        data-status="${item.trangThai ? 1 : 0}"
                                                        onclick="handleEditEmployeeClick(this)">
                                                    Sửa
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmDeleteEmployee('${item.maNv}')">
                                                    Xóa
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="9" class="text-center py-5 text-muted">Chưa ghi nhận nhân sự nào!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- PHÂN TRANG NHÂN VIÊN CLIENT SIDE -->
                <div class="pagination-container" id="empPaginationWrapper">
                    <span class="small text-muted" id="empPaginationInfo">Hiển thị từ 1 đến 10 dòng dữ liệu</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="empPaginationButtons"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL TOÀN NĂNG THÊM MỚI / CẬP NHẬT -->
<div class="modal fade" id="employeeFormModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header text-white py-3" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%)">
                <h5 class="modal-title fw-bold" id="empModalTitle">THÊM NHÂN VIÊN MỚI</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="employeeForm" action="${pageContext.request.contextPath}/admin/nhanvien" method="POST">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="maNv" id="formMaNv">
                <div class="modal-body p-4 text-start">
                    <div class="mb-3">
                        <label for="hoTen" class="form-label fw-bold small text-dark">Họ và tên đầy đủ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="hoTen" name="hoTen" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="soDienThoai" class="form-label fw-bold small text-dark">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="soDienThoai" name="soDienThoai" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label fw-bold small text-dark">Email nội bộ <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email" required autocomplete="off">
                    </div>
                    <div class="mb-3">
                        <label for="tenDangNhap" class="form-label fw-bold small text-dark">Tên đăng nhập <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="tenDangNhap" name="tenDangNhap" required autocomplete="off">
                    </div>
                    <div class="mb-3" id="passwordFieldGroup">
                        <label for="matKhau" class="form-label fw-bold small text-dark">Mật khẩu đăng nhập mặc định <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="matKhau" name="matKhau" placeholder="Mật khẩu từ 8 ký tự...">
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <label for="maVt" class="form-label fw-bold small text-dark">Quyền vai trò</label>
                            <select name="maVt" id="maVt" class="form-select">
                                <option value="1">Quản lý (Admin)</option>
                                <option value="2">Thu ngân (Staff)</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-bold small text-dark">Trạng thái công việc</label>
                            <select name="trangThai" id="trangThai" class="form-select">
                                <option value="1">Đang làm việc</option>
                                <option value="0">Tạm dừng ca</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light py-2.5" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary-teapos fw-bold"><i class="bi bi-save me-1"></i> Lưu thông tin</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- POPUP RESET MẬT KHẨU -->
<div class="modal fade" id="resetPasswordModal" tabindex="-1" aria-hidden="true" style="z-index: 1065;">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-warning text-dark py-2.5" style="border-radius: 12px 12px 0 0;">
                <h6 class="modal-title fw-bold"><i class="bi bi-key-fill"></i> RESET MẬT KHẨU</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/nhanvien" method="POST">
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="maNv" id="resetMaNv">
                <div class="modal-body p-3 text-start bg-light">
                    <p class="small text-muted mb-2">Đang reset mật khẩu của nhân viên: <strong id="resetTenNv"></strong></p>
                    <div class="mb-1">
                        <label for="matKhauMoi" class="form-label fw-bold small text-dark">Mật khẩu mới</label>
                        <input type="password" name="matKhauMoi" class="form-control form-control-sm" required minlength="8" placeholder="Tối thiểu 8 ký tự...">
                    </div>
                </div>
                <div class="modal-footer p-2 bg-light" style="border-radius: 0 0 12px 12px;">
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-sm btn-warning fw-bold text-dark">Xác nhận</button>
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
    const ROWS_PER_PAGE_EMP = 10;
    let currentEmpPage = 1;
    let empRows = [];

    function paginateEmployees() {
        empRows = Array.from(document.querySelectorAll("#employeeTableBody .employee-row"));
        renderEmpRows();
    }

    function renderEmpRows() {
        empRows.forEach(row => row.style.display = "none");
        const startIdx = (currentEmpPage - 1) * ROWS_PER_PAGE_EMP;
        const endIdx = startIdx + ROWS_PER_PAGE_EMP;
        const pageRows = empRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });
        updateEmpPaginationControls();
    }

    function updateEmpPaginationControls() {
        const totalRows = empRows.length;
        const totalPages = Math.ceil(totalRows / ROWS_PER_PAGE_EMP) || 1;
        const infoEl = document.getElementById("empPaginationInfo");
        const btnContainer = document.getElementById("empPaginationButtons");
        if (!infoEl || !btnContainer) return;

        const start = totalRows > 0 ? (currentEmpPage - 1) * ROWS_PER_PAGE_EMP + 1 : 0;
        const end = Math.min(currentEmpPage * ROWS_PER_PAGE_EMP, totalRows);
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng';
        btnContainer.innerHTML = "";

        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentEmpPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link" href="#" onclick="changeEmpPage(' + (currentEmpPage - 1) + ')"><i class="bi bi-chevron-left"></i></a>';
        btnContainer.appendChild(prevLi);

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentEmpPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link" href="#" onclick="changeEmpPage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentEmpPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link" href="#" onclick="changeEmpPage(' + (currentEmpPage + 1) + ')"><i class="bi bi-chevron-right"></i></a>';
        btnContainer.appendChild(nextLi);
    }

    function changeEmpPage(page) {
        const totalPages = Math.ceil(empRows.length / ROWS_PER_PAGE_EMP) || 1;
        if (page < 1 || page > totalPages) return;
        currentEmpPage = page;
        renderEmpRows();
    }

    function openCreateEmployeeModal() {
        document.getElementById("employeeForm").reset();
        document.getElementById("empModalTitle").innerText = "THÊM MỚI NHÂN VIÊN";
        document.getElementById("formAction").value = "create";
        document.getElementById("formMaNv").value = "";
        document.getElementById("passwordFieldGroup").style.display = "block";
        document.getElementById("matKhau").required = true;
        empModal.show();
    }

    function handleResetPasswordClick(button) {
        const maNv = button.getAttribute("data-id");
        const hoTen = button.getAttribute("data-name");
        document.getElementById("resetMaNv").value = maNv;
        document.getElementById("resetTenNv").innerText = hoTen;
        passModal.show();
    }

    function handleEditEmployeeClick(button) {
        const maNv = button.getAttribute("data-id");
        const hoTen = button.getAttribute("data-name");
        const soDienThoai = button.getAttribute("data-phone");
        const email = button.getAttribute("data-email");
        const username = button.getAttribute("data-user");
        const maVt = button.getAttribute("data-role");
        const trangThai = parseInt(button.getAttribute("data-status"));

        document.getElementById("empModalTitle").innerText = "CẬP NHẬT NHÂN VIÊN: " + maNv;
        document.getElementById("formAction").value = "edit";
        document.getElementById("formMaNv").value = maNv;
        document.getElementById("hoTen").value = hoTen;
        document.getElementById("soDienThoai").value = soDienThoai;
        document.getElementById("email").value = email;
        document.getElementById("tenDangNhap").value = username;
        document.getElementById("maVt").value = maVt;
        document.getElementById("trangThai").value = trangThai;
        document.getElementById("passwordFieldGroup").style.display = "none";
        document.getElementById("matKhau").required = false;
        empModal.show();
    }

    function confirmDeleteEmployee(maNv) {
        Swal.fire({
            title: 'Xóa tài khoản nhân viên?',
            text: "Nếu tài khoản đã có lịch sử hóa đơn bán nước, hệ thống tự động gạt về trạng thái Khóa ca (Soft Delete). Nếu chưa từng lập bill, hệ thống cho phép xóa cứng vĩnh viễn khỏi CSDL!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/admin/nhanvien?action=delete&id=' + maNv;
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        paginateEmployees();
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'createsuccess') showToast('success', 'Thêm mới tài khoản nhân viên thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã lưu thay đổi hồ sơ nhân viên!');
        if (msg === 'softdeletesuccess') {
            Swal.fire({
                icon: 'info',
                title: 'Khóa ca nhân sự',
                text: 'Nhân viên này đã dính lịch sử hóa đơn tài chính! Hệ thống tự động gạt trạng thái về Khóa ca để bảo toàn lịch sử kinh doanh.',
                confirmButtonColor: '#10b981'
            });
        }
        if (msg === 'harddeletesuccess') showToast('success', 'Đã xóa cứng vĩnh viễn nhân viên khỏi CSDL!');
    });
</script>
</body>
</html>