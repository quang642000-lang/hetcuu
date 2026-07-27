<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Nhật Ký Hoạt Động & Kiểm Toán</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --bg-main: #f1f5f9;
            --border-color: #cbd5e1;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --radius-md: 8px;
        }
        body {
            font-family: 'Inter', sans-serif !important;
            background-color: var(--bg-main) !important;
            color: var(--text-main) !important;
        }
        .audit-card {
            border: 1px solid var(--border-color) !important;
            border-radius: var(--radius-md) !important;
            background: #ffffff !important;
            box-shadow: var(--shadow-sm) !important;
            margin-bottom: 24px !important;
        }
        .audit-header {
            background-color: #ffffff !important;
            border-bottom: 1px solid var(--border-color) !important;
            padding: 20px !important;
            border-top-left-radius: var(--radius-md) !important;
            border-top-right-radius: var(--radius-md) !important;
        }
        .badge-login {
            background-color: #eff6ff !important;
            color: #2563eb !important;
            border: 1px solid #bfdbfe !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .badge-logout {
            background-color: #f1f5f9 !important;
            color: #475569 !important;
            border: 1px solid #cbd5e1 !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .badge-insert {
            background-color: #f0fdf4 !important;
            color: #16a34a !important;
            border: 1px solid #bbf7d0 !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .badge-update {
            background-color: #fffbeb !important;
            color: #d97706 !important;
            border: 1px solid #fde68a !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .badge-delete {
            background-color: #fef2f2 !important;
            color: #dc2626 !important;
            border: 1px solid #fca5a5 !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .table-audit th {
            background-color: #f8fafc !important;
            color: var(--text-muted) !important;
            font-weight: 700 !important;
            font-size: 11.5px !important;
            text-transform: uppercase !important;
            letter-spacing: 0.5px !important;
            padding: 14px 16px !important;
            border-bottom: 2px solid var(--border-color) !important;
        }
        .table-audit td {
            padding: 14px 16px !important;
            vertical-align: middle !important;
            font-size: 13.5px !important;
            border-bottom: 1px solid var(--border-color) !important;
        }
        .compare-box {
            font-family: 'Consolas', 'Courier New', monospace !important;
            font-size: 11.5px !important;
            border-radius: 6px !important;
            padding: 10px 14px !important;
            max-height: 120px !important;
            overflow-y: auto !important;
            white-space: pre-wrap !important;
            word-break: break-all !important;
            background-color: #f8fafc !important;
            border: 1px solid var(--border-color) !important;
        }
        .compare-old {
            border-left: 3px solid #f59e0b !important;
            color: #64748b !important;
        }
        .compare-new {
            border-left: 3px solid #10b981 !important;
            color: #0f172a !important;
        }
        .primary-key-badge {
            font-family: 'Consolas', monospace !important;
            background-color: #f1f5f9 !important;
            color: #0f172a !important;
            border: 1px solid #cbd5e1 !important;
            padding: 3px 8px !important;
            border-radius: 4px !important;
            font-weight: bold !important;
            font-size: 11px !important;
        }
        .pagination-container {
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            padding: 16px 20px !important;
            border-top: 1px solid var(--border-color) !important;
            background-color: #ffffff !important;
        }
    </style>
</head>
<body>
<div class="admin-wrapper">
    <!-- SIDEBAR -->
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <!-- MAIN CONTENT AREA -->
    <div class="admin-content">
        <!-- HEADER -->
        <jsp:include page="/views/layout/header_admin.jsp" />

        <div class="p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="text-start">
                    <h3 class="fw-bold text-success m-0"><i class="bi bi-shield-shaded text-success me-2"></i>Nhật Ký & Kiểm Toán</h3>
                    <p class="text-muted small mb-0">Hộp đen bảo mật ghi nhận toàn bộ hoạt động đăng nhập, sửa đổi dữ liệu hệ thống TEA POS.</p>
                </div>
                <div>
                    <button class="btn btn-outline-secondary btn-sm fw-bold px-3 me-2" onclick="location.reload()">
                        <i class="bi bi-arrow-clockwise me-1"></i> Tải lại trang
                    </button>
                </div>
            </div>

            <!-- SEARCH & FILTERS PANEL -->
            <div class="card border-0 shadow-sm p-4 mb-4 rounded-4" style="background-color: #ffffff;">
                <form action="${pageContext.request.contextPath}/admin/auditlog" method="GET">
                    <div class="row g-3 text-start">
                        <div class="col-md-3">
                            <label class="form-label text-muted small fw-bold">Tìm kiếm tổng hợp</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" name="search" class="form-control bg-light border-start-0 text-slate-800" placeholder="Mã nhân viên, nội dung..." value="<c:out value='${param.search}'/>">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Hành động</label>
                            <select name="action" class="form-select bg-light">
                                <option value="">-- Tất cả --</option>
                                <option value="LOGIN" ${param.action == 'LOGIN' ? 'selected' : ''}>LOGIN (Đăng nhập)</option>
                                <option value="LOGOUT" ${param.action == 'LOGOUT' ? 'selected' : ''}>LOGOUT (Đăng xuất)</option>
                                <option value="INSERT" ${param.action == 'INSERT' ? 'selected' : ''}>INSERT (Thêm mới)</option>
                                <option value="UPDATE" ${param.action == 'UPDATE' ? 'selected' : ''}>UPDATE (Chỉnh sửa)</option>
                                <option value="DELETE" ${param.action == 'DELETE' ? 'selected' : ''}>DELETE (Xóa dữ liệu)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Bảng tác động</label>
                            <select name="tableName" class="form-select bg-light">
                                <option value="">-- Tất cả --</option>
                                <option value="SAN_PHAM" ${param.tableName == 'SAN_PHAM' ? 'selected' : ''}>Sản phẩm (SAN_PHAM)</option>
                                <option value="TOPPING" ${param.tableName == 'TOPPING' ? 'selected' : ''}>Món ăn kèm (TOPPING)</option>
                                <option value="DAN_MUC" ${param.tableName == 'DAN_MUC' ? 'selected' : ''}>Danh mục (DAN_MUC)</option>
                                <option value="NHAN_VIEN" ${param.tableName == 'NHAN_VIEN' ? 'selected' : ''}>Nhân viên (NHAN_VIEN)</option>
                                <option value="CHUONG_TRINH_KHUYEN_MAI" ${param.tableName == 'CHUONG_TRINH_KHUYEN_MAI' ? 'selected' : ''}>Voucher (KHUYEN_MAI)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Từ ngày</label>
                            <input type="date" name="startDate" class="form-control bg-light" value="${param.startDate}">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Đến ngày</label>
                            <input type="date" name="endDate" class="form-control bg-light" value="${param.endDate}">
                        </div>
                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-success w-100 fw-bold py-2 rounded-3">
                                <i class="bi bi-filter"></i> Lọc
                            </button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- AUDIT TRAIL DATA CARD -->
            <div class="audit-card">
                <div class="audit-header d-flex justify-content-between align-items-center">
                    <strong class="text-dark fs-5 text-uppercase"><i class="bi bi-list-stars text-success me-1"></i>Lịch sử kiểm toán</strong>
                    <span class="badge bg-light text-dark border px-3 py-1.5 fw-bold" style="border-radius: 20px;" id="matchCountBadge">
                        Đang tải...
                    </span>
                </div>
                <div class="table-responsive">
                    <table class="table table-audit mb-0" id="auditLogTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 100px;">Mã Log</th>
                            <th style="width: 170px;">Thời gian</th>
                            <th style="width: 200px;" class="text-start">Nhân viên tác động</th>
                            <th style="width: 130px;">Hành động</th>
                            <th style="width: 220px;" class="text-start">Vùng tác động</th>
                            <th class="text-start">Đối soát biến động dữ liệu</th>
                            <th style="width: 130px;">Địa chỉ IP</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty logsList}">
                                <c:forEach var="log" items="${logsList}">
                                    <tr class="audit-log-row text-center">
                                        <td class="font-monospace fw-bold text-success">#${log.maLog}</td>
                                        <td class="font-monospace text-dark">
                                            <fmt:formatDate value="${log.thoiGian}" pattern="HH:mm:ss  dd/MM/yyyy" />
                                        </td>
                                        <td class="text-start">
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                                                    <i class="bi bi-person-badge text-success"></i>
                                                </div>
                                                <div>
                                                        <span class="d-block fw-bold text-dark" style="font-size: 13px;">
                                                            <c:choose>
                                                                <c:when test="${not empty log.maNv}">
                                                                    <c:out value="${log.maNv}"/>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-primary font-monospace" style="font-size: 11px;">SYSTEM / PORTAL</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    <small class="text-muted" style="font-size: 11px;">
                                                        <c:out value="${log.hoTenNhanVien}"/>
                                                    </small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${log.hanhDong == 'LOGIN'}">
                                                    <span class="badge-login"><i class="bi bi-box-arrow-in-right me-1"></i>LOGIN</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'LOGOUT'}">
                                                    <span class="badge-logout"><i class="bi bi-box-arrow-left me-1"></i>LOGOUT</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'INSERT'}">
                                                    <span class="badge-insert"><i class="bi bi-plus-circle me-1"></i>INSERT</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'UPDATE'}">
                                                    <span class="badge-update"><i class="bi bi-pencil-square me-1"></i>UPDATE</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'DELETE'}">
                                                    <span class="badge-delete"><i class="bi bi-trash3-fill me-1"></i>DELETE</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary"><c:out value="${log.hanhDong}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-start">
                                            <div>
                                                <strong class="d-block text-dark" style="font-size: 12px;"><c:out value="${log.bangTacDong}"/></strong>
                                            </div>
                                        </td>
                                        <td class="text-start">
                                            <div class="row g-2">
                                                <!-- COLUMN CŨ -->
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU CŨ TRƯỚC BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-old"><c:choose><c:when test="${not empty log.duLieuCu}"><c:out value="${log.duLieuCu}"/></c:when><c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise></c:choose></div>
                                                </div>
                                                <!-- COLUMN MỚI -->
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU MỚI SAU BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-new"><c:choose><c:when test="${not empty log.duLieuMoi}"><c:out value="${log.duLieuMoi}"/></c:when><c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise></c:choose></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="font-monospace text-muted">
                                            <c:choose>
                                                <c:when test="${not empty log.ipAddress}">
                                                    <c:out value="${log.ipAddress}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    127.0.0.1
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-shield-slash fs-1 text-secondary opacity-30 d-block mb-2"></i>
                                        <span class="fw-semibold">Hộp đen trống trơn! Chưa có nhật ký hoạt động nào khớp với bộ lọc tìm kiếm.</span>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- PAGINATION BAR -->
                <div class="pagination-container bg-white rounded-bottom-4" id="paginationArea">
                    <span class="small text-muted font-monospace" id="paginationInfo">Trang 1 / 1</span>
                    <nav aria-label="Page navigation">
                        <ul class="pagination pagination-sm m-0" id="paginationButtons">
                            <!-- JS will inject buttons dynamically -->
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // PHÂN TRANG VÀ ĐỐI SOÁT ĐỘNG PHÍA CLIENT-SIDE REALTIME MƯỢT MÀ
    let currentPage = 1;
    const pageSize = 10;
    let filteredRows = [];

    function initClientPagination() {
        const allRows = Array.from(document.querySelectorAll("#auditLogTable tbody .audit-log-row"));
        filteredRows = allRows; // Đã lọc ở Backend, Client gánh phân trang và render

        // Cập nhật số lượng huy hiệu tìm thấy
        const badge = document.getElementById("matchCountBadge");
        if (badge) {
            badge.innerText = `Tìm thấy ${filteredRows.length} mốc biến động`;
        }

        renderPage(1);
    }

    function renderPage(page) {
        currentPage = page;
        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        // Ẩn tất cả các dòng
        const allRows = document.querySelectorAll("#auditLogTable tbody .audit-log-row");
        allRows.forEach(row => row.style.display = "none");

        // Hiển thị dải phân trang chỉ định
        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        for (let i = startIdx; i < endIdx; i++) {
            if (filteredRows[i]) {
                filteredRows[i].style.display = "table-row";
            }
        }

        // Cập nhật dòng thông tin phân trang
        const info = document.getElementById("paginationInfo");
        if (info) {
            info.innerText = `Hiển thị từ ${totalRows > 0 ? (startIdx + 1) : 0} đến ${endIdx} trong tổng số ${totalRows} dòng nhật ký`;
        }

        // Vẽ bộ phím điều hướng phân trang
        const buttonsContainer = document.getElementById("paginationButtons");
        if (buttonsContainer) {
            buttonsContainer.innerHTML = "";

            if (totalPages <= 1) {
                document.getElementById("paginationArea").style.setProperty('display', 'none', 'important');
                return;
            }
            document.getElementById("paginationArea").style.setProperty('display', 'flex', 'important');

            // Nút TRƯỚC (Prev)
            const prevLi = document.createElement("li");
            prevLi.className = `page-item ${currentPage == 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link text-success" href="javascript:void(0)" onclick="renderPage(${currentPage - 1})">&laquo; Trước</a>`;
            buttonsContainer.appendChild(prevLi);

            // Các trang số
            for (let i = 1; i <= totalPages; i++) {
                const li = document.createElement("li");
                li.className = `page-item ${currentPage == i ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link ${currentPage == i ? 'bg-success border-success text-white' : 'text-success'}" href="javascript:void(0)" onclick="renderPage(${i})">${i}</a>`;
                buttonsContainer.appendChild(li);
            }

            // Nút SAU (Next)
            const nextLi = document.createElement("li");
            nextLi.className = `page-item ${currentPage == totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link text-success" href="javascript:void(0)" onclick="renderPage(${currentPage + 1})">Sau &raquo;</a>`;
            buttonsContainer.appendChild(nextLi);
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        initClientPagination();
    });
</script>
</body>
</html>