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
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4 admin-page-container">
            <div class="card card-teapos p-4 shadow-sm border-0" style="background-color: #ffffff; border-radius: 12px;">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4 border-bottom pb-3 text-start">
                    <div>
                        <h3 class="fw-bold mb-1 text-success text-uppercase"><i class="bi bi-person-badge-fill me-2"></i>HỒ SƠ NHÂN VIÊN</h3>
                        <p class="text-muted small mb-0">Thiết lập tài khoản làm việc, phân chia quyền truy cập POS và kiểm soát trạng thái nhân viên</p>
                    </div>
                    <div class="d-flex gap-2 align-items-end">
                        <div class="input-group input-group-sm" style="width: 250px;">
                            <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                            <input type="text" id="employeeSearchInput" class="form-control" placeholder="Tìm tên hoặc mã nhân viên..." onkeyup="filterAndPaginateEmployees()">
                        </div>
                        <button class="btn btn-primary-teapos d-flex align-items-center gap-2 fw-bold" onclick="openCreateEmployeeModal()">
                            <i class="bi bi-person-plus-fill"></i> Thêm Nhân Viên Mới
                        </button>
                    </div>
                </div>

                <!-- ==================== VIEW 1: DESKTOP LAYOUT (Màn hình lớn) ==================== -->
                <div class="d-none d-lg-block table-responsive admin-table-container">
                    <table class="table admin-table align-middle" id="employeeTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 80px;">STT</th>
                            <th style="width: 120px;">Mã NV</th>
                            <th class="text-start">Họ và tên nhân sự</th>
                            <th>Số điện thoại</th>
                            <th>Email</th>
                            <th>Tên đăng nhập</th>
                            <th class="text-center" style="width: 150px;">Vai trò</th>
                            <th class="text-center" style="width: 150px;">Trạng Thái</th>
                            <th style="width: 320px;" class="text-end">Thao Tác</th>
                        </tr>
                        </thead>
                        <tbody id="employeeTableBody">
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <c:forEach var="item" items="${employees}" varStatus="loop">
                                    <tr class="employee-row text-center" data-id="${item.maNv}" data-name="<c:out value='${item.hoTen}'/>">
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
                                                <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-2.5 py-1">
                                                        ${item.trangThai ? 'Hoạt động' : 'Khóa ca'}
                                                </span>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-1.5 align-items-center">
                                                <a href="${pageContext.request.contextPath}/admin/nhanvien?action=toggle&id=${item.maNv}&status=${item.trangThai ? 0 : 1}"
                                                   class="btn btn-sm ${item.trangThai ? 'btn-action-warning' : 'btn-action-edit'}"
                                                   title="${item.trangThai ? 'Khóa ca' : 'Mở ca'}">
                                                    <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i> ${item.trangThai ? 'Khóa Ca' : 'Mở Ca'}
                                                </a>
                                                <button type="button" class="btn btn-sm btn-action-info"
                                                        data-id="${item.maNv}" data-name="<c:out value='${item.hoTen}'/>"
                                                        onclick="handleResetPasswordClick(this)">
                                                    <i class="bi bi-key-fill me-1"></i> Reset
                                                </button>
                                                <button type="button" class="btn btn-sm btn-action-edit"
                                                        data-id="${item.maNv}"
                                                        data-name="<c:out value='${item.hoTen}'/>"
                                                        data-phone="${item.soDienThoai}"
                                                        data-email="${item.email}"
                                                        data-user="${item.tenDangNhap}"
                                                        data-role="${item.maVt}"
                                                        data-status="${item.trangThai ? 1 : 0}"
                                                        onclick="handleEditEmployeeClick(this)">
                                                    <i class="bi bi-pencil-square me-1"></i> Sửa
                                                </button>
                                                <button type="button" class="btn btn-sm btn-action-delete" onclick="confirmDeleteEmployee('${item.maNv}')">
                                                    <i class="bi bi-trash3-fill me-1"></i> Xóa
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

                <!-- ==================== VIEW 2: MOBILE LAYOUT (Màn hình điện thoại < 992px) ==================== -->
                <div class="d-block d-lg-none" id="employeeMobileCards">
                    <c:choose>
                        <c:when test="${not empty employees}">
                            <c:forEach var="item" items="${employees}" varStatus="loop">
                                <div class="employee-card-col mb-3" data-id="${item.maNv}" data-name="<c:out value='${item.hoTen}'/>">
                                    <div class="card p-3 border shadow-sm position-relative text-start" style="border-radius: 12px; background: #ffffff; border-color: var(--border-color) !important;">

                                        <!-- Expand/Collapse Chevron -->
                                        <div class="position-absolute" style="top: 15px; right: 15px; cursor: pointer; z-index: 10;" onclick="toggleMobileCardDetails(this)">
                                            <span class="badge bg-light rounded-circle text-success d-flex align-items-center justify-content-center border" style="width: 28px; height: 28px; border-color: var(--border-color) !important;">
                                                <i class="bi bi-chevron-down fs-6"></i>
                                            </span>
                                        </div>

                                        <!-- Header: STT, Mã NV, Vai Trò -->
                                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 pe-4">
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="badge bg-light text-success rounded-circle d-flex align-items-center justify-content-center" style="width: 28px; height: 28px; font-weight: bold; border: 1px solid var(--border-color);">
                                                        ${loop.index + 1}
                                                </span>
                                                <code class="fw-bold text-dark font-monospace">${item.maNv}</code>
                                            </div>
                                            <span class="badge ${item.maVt == 1 ? 'bg-danger' : 'bg-info'} text-white px-2.5 py-1" style="font-size: 11px;">
                                                    ${item.maVt == 1 ? 'Quản lý' : 'Thu ngân'}
                                            </span>
                                        </div>

                                        <!-- Body: Tên & Trạng Thái -->
                                        <div>
                                            <h6 class="fw-bold text-dark mb-1"><c:out value="${item.hoTen}"/></h6>
                                            <small class="text-muted">Trạng thái:
                                                <span class="badge ${item.trangThai ? 'bg-success bg-opacity-10 text-success' : 'bg-danger bg-opacity-10 text-danger'} border px-2 py-0.5" style="font-size: 10px;">
                                                        ${item.trangThai ? 'Đang hoạt động' : 'Đã khóa ca'}
                                                </span>
                                            </small>
                                        </div>

                                        <!-- Expandable panel (hidden by default) -->
                                        <div class="mobile-card-details border-top pt-2 mt-2 text-start small d-none" style="line-height: 1.6;">
                                            <div class="text-muted d-flex justify-content-between">
                                                <span>Số điện thoại:</span>
                                                <strong class="text-dark">${item.soDienThoai}</strong>
                                            </div>
                                            <div class="text-muted d-flex justify-content-between mt-1">
                                                <span>Địa chỉ Email:</span>
                                                <strong class="text-dark">${item.email}</strong>
                                            </div>
                                            <div class="text-muted d-flex justify-content-between mt-1">
                                                <span>Tên đăng nhập:</span>
                                                <strong class="text-dark"><code><c:out value="${item.tenDangNhap}"/></code></strong>
                                            </div>
                                        </div>

                                        <!-- Footer Actions -->
                                        <div class="d-flex flex-wrap gap-2 border-top pt-2 mt-2">
                                            <a href="${pageContext.request.contextPath}/admin/nhanvien?action=toggle&id=${item.maNv}&status=${item.trangThai ? 0 : 1}"
                                               class="btn btn-sm ${item.trangThai ? 'btn-outline-warning' : 'btn-outline-success'} fw-bold flex-grow-1" style="border-radius: 8px;">
                                                <i class="bi ${item.trangThai ? 'bi-toggle2-off' : 'bi-toggle2-on'}"></i> ${item.trangThai ? 'Khóa Ca' : 'Mở Ca'}
                                            </a>
                                            <button type="button" class="btn btn-outline-info btn-sm fw-bold flex-grow-1" style="border-radius: 8px;"
                                                    data-id="${item.maNv}" data-name="<c:out value='${item.hoTen}'/>"
                                                    onclick="handleResetPasswordClick(this)">
                                                <i class="bi bi-key-fill"></i> Reset
                                            </button>
                                            <button type="button" class="btn btn-outline-primary btn-sm fw-bold flex-grow-1" style="border-radius: 8px;"
                                                    data-id="${item.maNv}"
                                                    data-name="<c:out value='${item.hoTen}'/>"
                                                    data-phone="${item.soDienThoai}"
                                                    data-email="${item.email}"
                                                    data-user="${item.tenDangNhap}"
                                                    data-role="${item.maVt}"
                                                    data-status="${item.trangThai ? 1 : 0}"
                                                    onclick="handleEditEmployeeClick(this)">
                                                <i class="bi bi-pencil-square"></i> Sửa
                                            </button>
                                            <button type="button" class="btn btn-outline-danger btn-sm fw-bold flex-grow-1" style="border-radius: 8px;" onclick="confirmDeleteEmployee('${item.maNv}')">
                                                <i class="bi bi-trash3-fill"></i> Xóa
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5 text-muted bg-white rounded-3 border">Không tìm thấy thông tin nhân viên!</div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- PHÂN TRANG -->
                <div class="pagination-container" id="paginationWrapper" style="display: none;">
                    <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 dòng dữ liệu</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL FORM -->
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

    let currentPage = 1;
    const pageSize = 10;
    let filteredDesktopRows = [];
    let filteredMobileCards = [];

    function filterAndPaginateEmployees() {
        const searchInput = document.getElementById("employeeSearchInput");
        if (!searchInput) return;
        const searchVal = searchInput.value.trim().toLowerCase();

        // Filter Desktop Table Rows
        const allDesktopRows = Array.from(document.querySelectorAll("#employeeTableBody .employee-row"));
        filteredDesktopRows = allDesktopRows.filter(row => {
            const id = row.dataset.id.toLowerCase();
            const name = row.dataset.name.toLowerCase();
            return id.includes(searchVal) || name.includes(searchVal);
        });

        // Filter Mobile Cards list
        const allMobileCards = Array.from(document.querySelectorAll("#employeeMobileCards .employee-card-col"));
        filteredMobileCards = allMobileCards.filter(card => {
            const id = card.dataset.id.toLowerCase();
            const name = card.dataset.name.toLowerCase();
            return id.includes(searchVal) || name.includes(searchVal);
        });

        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        // Desktop Table Rows
        const allRows = document.querySelectorAll("#employeeTableBody .employee-row");
        allRows.forEach(row => row.style.display = "none");
        const totalRows = filteredDesktopRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        const pageRows = filteredDesktopRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });

        // Mobile Cards list
        const allCards = document.querySelectorAll("#employeeMobileCards .employee-card-col");
        allCards.forEach(card => card.style.setProperty('display', 'none', 'important'));
        const pageCards = filteredMobileCards.slice(startIdx, endIdx);
        pageCards.forEach(card => {
            card.style.setProperty('display', 'block', 'important');
        });

        updatePaginationControls();
    }

    function updatePaginationControls() {
        const totalRows = filteredDesktopRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const wrapper = document.getElementById("paginationWrapper");

        if (!infoEl || !btnContainer || !wrapper) return;
        const start = totalRows > 0 ? (currentPage - 1) * pageSize + 1 : 0;
        const end = Math.min(currentPage * pageSize, totalRows);

        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' dòng nhân viên';
        btnContainer.innerHTML = "";

        if (totalPages <= 1) {
            wrapper.style.setProperty('display', 'none', 'important');
            return;
        }
        wrapper.style.setProperty('display', 'flex', 'important');

        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
        btnContainer.appendChild(prevLi);

        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredDesktopRows.length / pageSize) || 1;
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTableRows();
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

    // EXPAND/COLLAPSE MOBILE CARD DETAILS
    function toggleMobileCardDetails(element) {
        const card = element.closest('.card');
        const details = card.querySelector('.mobile-card-details');
        const icon = element.querySelector('i');
        if (details.classList.contains('d-none')) {
            details.classList.remove('d-none');
            icon.className = 'bi bi-chevron-up fs-6';
        } else {
            details.classList.add('d-none');
            icon.className = 'bi bi-chevron-down fs-6';
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
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
        filterAndPaginateEmployees();
    });
</script>
</body>
</html>