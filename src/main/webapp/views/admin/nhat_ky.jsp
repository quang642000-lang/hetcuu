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
            padding: 16px 20px !important;
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            border-radius: var(--radius-md) var(--radius-md) 0 0 !important;
        }
        .badge-login {
            background-color: #ecfdf5 !important;
            color: #047857 !important;
            border: 1px solid #a7f3d0 !important;
            font-weight: 700 !important;
            padding: 5px 12px !important;
            border-radius: 50px !important;
            font-size: 11px !important;
        }
        .badge-logout {
            background-color: #f8fafc !important;
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
        .compare-old {
            border-left: 3px solid #f59e0b !important;
            color: #64748b !important;
        }
        .compare-new {
            border-left: 3px solid #10b981 !important;
            color: #0f172a !important;
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
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="d-flex justify-content-between align-items-center mb-4 text-start">
                <div>
                    <h3 class="fw-bold text-success m-0"><i class="bi bi-shield-shaded text-success me-2"></i>Nhật Ký Hoạt Động & Kiểm Toán</h3>
                    <p class="text-muted small mb-0">Ghi nhận lịch sử kiểm toán hệ thống.</p>
                </div>
                <div>
                    <button class="btn btn-outline-secondary btn-sm fw-bold px-3 me-2" onclick="location.reload()">
                        <i class="bi bi-arrow-clockwise me-1"></i> Tải lại trang
                    </button>
                </div>
            </div>
            <!-- SEARCH & FILTERS PANEL -->
            <div class="card border-0 shadow-sm p-4 mb-4 rounded-4" style="background-color: #ffffff;">
                <form action="${pageContext.request.contextPath}/admin/auditlog" method="GET" id="filterForm">
                    <input type="hidden" name="page" id="pageField" value="${currentPage}">
                    <div class="row g-3 text-start">
                        <div class="col-md-3">
                            <label class="form-label text-muted small fw-bold">Tìm kiếm tổng hợp</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" name="search" class="form-control bg-light border-start-0 text-slate-800" placeholder="Mã nhân viên, nội dung..." value="<c:out value='${paramSearch}'/>">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Hành động</label>
                            <select name="actionFilter" class="form-select bg-light">
                                <option value="">-- Tất cả --</option>
                                <option value="LOGIN" ${paramAction == 'LOGIN' ? 'selected' : ''}>LOGIN (Đăng nhập)</option>
                                <option value="LOGOUT" ${paramAction == 'LOGOUT' ? 'selected' : ''}>LOGOUT (Đăng xuất)</option>
                                <option value="INSERT" ${paramAction == 'INSERT' ? 'selected' : ''}>INSERT (Thêm mới)</option>
                                <option value="UPDATE" ${paramAction == 'UPDATE' ? 'selected' : ''}>UPDATE (Chỉnh sửa)</option>
                                <option value="DELETE" ${paramAction == 'DELETE' ? 'selected' : ''}>DELETE (Xóa dữ liệu)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-slate-500 small fw-bold">Bảng tác động</label>
                            <select name="tableName" class="form-select bg-light">
                                <option value="">-- Tất cả --</option>
                                <option value="SAN_PHAM" ${paramTableName == 'SAN_PHAM' ? 'selected' : ''}>Sản phẩm (SAN_PHAM)</option>
                                <option value="TOPPING" ${paramTableName == 'TOPPING' ? 'selected' : ''}>Món ăn kèm (TOPPING)</option>
                                <option value="DAN_MUC" ${paramTableName == 'DAN_MUC' ? 'selected' : ''}>Danh mục (DAN_MUC)</option>
                                <option value="NHAN_VIEN" ${paramTableName == 'NHAN_VIEN' ? 'selected' : ''}>Nhân viên (NHAN_VIEN)</option>
                                <option value="CHUONG_TRINH_KHUYEN_MAI" ${paramTableName == 'CHUONG_TRINH_KHUYEN_MAI' ? 'selected' : ''}>Voucher (KHUYEN_MAI)</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Từ ngày</label>
                            <input type="date" name="startDate" class="form-control bg-light" value="${paramStartDate}">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Đến ngày</label>
                            <input type="date" name="endDate" class="form-control bg-light" value="${paramEndDate}">
                        </div>
                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-success w-100 fw-bold py-2 rounded-3" onclick="document.getElementById('pageField').value='1'">
                                <i class="bi bi-filter"></i> Lọc
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <!-- AUDIT TRAIL DATA CARD -->
            <div class="audit-card">
                <div class="audit-header">
                    <strong class="text-dark fs-5 text-uppercase"><i class="bi bi-list-stars text-success me-1"></i>Lịch sử kiểm toán (Server-side)</strong>
                    <span class="badge bg-light text-dark border px-3 py-1.5 fw-bold" style="border-radius: 20px;" id="matchCountBadge">
                        Tìm thấy ${totalLogs} mốc biến động
                    </span>
                </div>
                <!-- ==================== VIEW 1: DESKTOP LAYOUT ==================== -->
                <div class="d-none d-lg-block table-responsive">
                    <table class="table table-audit mb-0" id="auditLogTable">
                        <thead>
                        <tr class="text-center">
                            <th style="width: 100px;">Mã Log</th>
                            <th style="width: 170px;">Thời gian</th>
                            <th style="width: 200px;" class="text-start">Nhân viên tác động</th>
                            <th style="width: 130px;">Hành động</th>
                            <th style="width: 220px;" class="text-start">Vùng tác động</th>
                            <th class="text-start">Đối soát biến động dữ liệu</th>
                            <th style="width: 130px;">IP Address</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty logsList}">
                                <c:forEach var="log" items="${logsList}">
                                    <tr class="audit-log-row text-center">
                                        <td class="font-monospace fw-bold text-success">#${log.maLog}</td>
                                        <td class="font-monospace text-dark">
                                            <fmt:formatDate value="${log.thoiGian}" pattern="HH:mm:ss dd/MM/yyyy" />
                                        </td>
                                        <td class="text-start">
                                            <div class="d-flex align-items-center">
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
                                                    <span class="badge bg-secondary text-white"><c:out value="${log.hanhDong}"/></span>
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
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU CŨ TRƯỚC BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-old" style="font-family: monospace; font-size: 11px; max-height: 80px; overflow-y: auto; background: #fafafa; border-radius: 4px; padding: 4px; border-left: 3px solid #f59e0b; color: #64748b;"><c:choose><c:when test="${not empty log.duLieuCu}"><c:out value="${log.duLieuCu}"/></c:when><c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise></c:choose></div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU MỚI SAU BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-new" style="font-family: monospace; font-size: 11px; max-height: 80px; overflow-y: auto; background: #fafafa; border-radius: 4px; padding: 4px; border-left: 3px solid #10b981; color: #0f172a;"><c:choose><c:when test="${not empty log.duLieuMoi}"><c:out value="${log.duLieuMoi}"/></c:when><c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise></c:choose></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="font-monospace text-muted">
                                            <c:choose>
                                                <c:when test="${not empty log.ipAddress}">
                                                    <c:out value="${log.ipAddress}"/>
                                                </c:when>
                                                <c:otherwise>127.0.0.1</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="bi bi-badge-ad fs-1 text-secondary opacity-30 d-block mb-2"></i>
                                        <span class="fw-semibold">Hộp đen trống trơn! Chưa có nhật ký hoạt động nào khớp với bộ lọc tìm kiếm.</span>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
                <!-- ==================== VIEW 2: MOBILE LAYOUT ==================== -->
                <div class="d-block d-lg-none" id="auditLogMobileCards">
                    <c:choose>
                        <c:when test="${not empty logsList}">
                            <c:forEach var="log" items="${logsList}">
                                <div class="card mb-3 p-3 border shadow-sm position-relative text-start" style="border-radius: 12px; background: #ffffff; border-color: var(--border-color) !important;">
                                    <div class="position-absolute" style="top: 15px; right: 15px; cursor: pointer; z-index: 10;" onclick="toggleMobileCardDetails(this)">
                                        <span class="badge bg-light rounded-circle text-success d-flex align-items-center justify-content-center border" style="width: 28px; height: 28px; border-color: var(--border-color) !important;">
                                            <i class="bi bi-chevron-down fs-6"></i>
                                        </span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 pe-4">
                                        <div class="d-flex align-items-center gap-2">
                                            <span class="font-monospace fw-bold text-success" style="font-size: 13px;">#${log.maLog}</span>
                                            <span class="font-monospace text-muted small" style="font-size: 11px;">
                                                <fmt:formatDate value="${log.thoiGian}" pattern="HH:mm:ss dd/MM/yyyy" />
                                            </span>
                                        </div>
                                        <span>
                                            <c:choose>
                                                <c:when test="${log.hanhDong == 'LOGIN'}">
                                                    <span class="badge-login" style="padding: 3px 10px !important;"><i class="bi bi-box-arrow-in-right me-1"></i>LOGIN</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'LOGOUT'}">
                                                    <span class="badge-logout" style="padding: 3px 10px !important;"><i class="bi bi-box-arrow-left me-1"></i>LOGOUT</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'INSERT'}">
                                                    <span class="badge-insert" style="padding: 3px 10px !important;"><i class="bi bi-plus-circle me-1"></i>INSERT</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'UPDATE'}">
                                                    <span class="badge-update" style="padding: 3px 10px !important;"><i class="bi bi-pencil-square me-1"></i>UPDATE</span>
                                                </c:when>
                                                <c:when test="${log.hanhDong == 'DELETE'}">
                                                    <span class="badge-delete" style="padding: 3px 10px !important;"><i class="bi bi-trash3-fill me-1"></i>DELETE</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary text-white" style="font-size: 10px; padding: 3px 10px !important;"><c:out value="${log.hanhDong}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="small text-muted" style="line-height: 1.6;">
                                        <div class="d-flex justify-content-between">
                                            <span>Nhân viên:</span>
                                            <strong class="text-dark text-end">
                                                <c:choose>
                                                    <c:when test="${not empty log.maNv}">
                                                        <c:out value="${log.maNv}"/> - <c:out value="${log.hoTenNhanVien}"/>
                                                    </c:when>
                                                    <c:otherwise>SYSTEM / PORTAL</c:otherwise>
                                                </c:choose>
                                            </strong>
                                        </div>
                                        <div class="d-flex justify-content-between mt-1">
                                            <span>Vùng tác động:</span>
                                            <strong class="text-dark"><c:out value="${log.bangTacDong}"/></strong>
                                        </div>
                                        <div class="d-flex justify-content-between mt-1">
                                            <span>IP Address:</span>
                                            <span class="font-monospace text-dark">${not empty log.ipAddress ? log.ipAddress : '127.0.0.1'}</span>
                                        </div>
                                    </div>
                                    <div class="mobile-card-details border-top pt-2 mt-2 d-none">
                                        <div class="mb-2">
                                            <div class="text-muted fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU CŨ TRƯỚC BIẾN ĐỘNG:</div>
                                            <div class="compare-box compare-old p-2 bg-light rounded text-start" style="font-family: monospace; font-size: 11px; white-space: pre-wrap; overflow-x: auto; border-left: 3px solid #f59e0b; color: #64748b;">
                                                <c:choose>
                                                    <c:when test="${not empty log.duLieuCu}"><c:out value="${log.duLieuCu}"/></c:when>
                                                    <c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="text-muted fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU MỚI SAU BIẾN ĐỘNG:</div>
                                            <div class="compare-box compare-new p-2 bg-light rounded text-start" style="font-family: monospace; font-size: 11px; white-space: pre-wrap; overflow-x: auto; border-left: 3px solid #10b981; color: #0f172a;">
                                                <c:choose>
                                                    <c:when test="${not empty log.duLieuMoi}"><c:out value="${log.duLieuMoi}"/></c:when>
                                                    <c:otherwise><span class="text-muted font-monospace italic">[TRỐNG]</span></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5 text-muted bg-white rounded-3 shadow-sm border">
                                <i class="bi bi-shield-slash fs-1 text-secondary opacity-30 d-block mb-2"></i>
                                <span class="fw-semibold">Hộp đen trống trơn! Chưa có nhật ký hoạt động nào.</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <!-- SERVER-SIDE PAGINATION CONTROLS -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination-container" id="paginationWrapper">
                        <span class="small text-muted" id="paginationInfo">
                            Hiển thị từ ${(currentPage - 1) * pageSize + 1} đến ${currentPage * pageSize > totalLogs ? totalLogs : currentPage * pageSize} trên tổng số ${totalLogs} dòng nhật ký
                        </span>
                        <nav>
                            <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link text-success" href="javascript:void(0)" onclick="changePage(${currentPage - 1})">&laquo; Trước</a>
                                </li>
                                <c:forEach var="i" begin="1" end="${totalPages}">
                                    <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                                            <a class="page-link ${currentPage == i ? 'bg-success border-success text-white' : 'text-success'}" href="javascript:void(0)" onclick="changePage(${i})">${i}</a>
                                        </li>
                                    </c:if>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link text-success" href="javascript:void(0)" onclick="changePage(${currentPage + 1})">Sau &raquo;</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function changePage(page) {
        document.getElementById('pageField').value = page;
        document.getElementById('filterForm').submit();
    }
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
</script>
</body>
</html>