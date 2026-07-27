<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS Admin - Nhật Ký Hoạt Động & Kiểm Toán</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --slate-700: #334155;
            --slate-800: #1e293b;
            --slate-900: #0f172a;
            --border-color: #cbd5e1;
            --radius-md: 10px;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.05);
            --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: var(--slate-900);
        }

        /* Sidebar Styling for cohesion */
        .admin-sidebar {
            background-color: var(--slate-800);
            min-height: 100vh;
            color: #ffffff;
        }

        /* Card Customization */
        .audit-card {
            border: 1px solid #e2e8f0;
            border-radius: var(--radius-md);
            background: #ffffff;
            box-shadow: var(--shadow-sm);
            margin-bottom: 24px;
        }

        .audit-header {
            background-color: #ffffff;
            border-bottom: 1px solid #f1f5f9;
            padding: 16px 20px;
            border-top-left-radius: var(--radius-md);
            border-top-right-radius: var(--radius-md);
        }

        /* Stylized Badges for Action Types */
        .badge-login {
            background-color: #eff6ff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
            font-weight: 700;
            padding: 5px 10px;
            border-radius: 6px;
        }

        .badge-logout {
            background-color: #f1f5f9;
            color: #64748b;
            border: 1px solid #cbd5e1;
            font-weight: 700;
            padding: 5px 10px;
            border-radius: 6px;
        }

        .badge-insert {
            background-color: #f0fdf4;
            color: #16a34a;
            border: 1px solid #bbf7d0;
            font-weight: 700;
            padding: 5px 10px;
            border-radius: 6px;
        }

        .badge-update {
            background-color: #fffbeb;
            color: #d97706;
            border: 1px solid #fde68a;
            font-weight: 700;
            padding: 5px 10px;
            border-radius: 6px;
        }

        .badge-delete {
            background-color: #fef2f2;
            color: #dc2626;
            border: 1px solid #fca5a5;
            font-weight: 700;
            padding: 5px 10px;
            border-radius: 6px;
        }

        /* Table Design */
        .table-audit th {
            background-color: #f8fafc;
            color: var(--slate-700);
            font-weight: 700;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 12px 16px;
            border-bottom: 2px solid #e2e8f0;
        }

        .table-audit td {
            padding: 14px 16px;
            vertical-align: middle;
            font-size: 13px;
            border-bottom: 1px solid #f1f5f9;
        }

        /* Comparative JSON/Text viewer */
        .compare-box {
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 11.5px;
            border-radius: 6px;
            padding: 8px 12px;
            max-height: 120px;
            overflow-y: auto;
            white-space: pre-wrap;
            word-break: break-all;
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        .compare-old {
            border-left: 3px solid #f59e0b;
            color: #475569;
        }

        .compare-new {
            border-left: 3px solid #10b981;
            color: #0f172a;
        }

        .primary-key-badge {
            font-family: 'Consolas', monospace;
            background-color: #f1f5f9;
            color: #0f172a;
            border: 1px solid #cbd5e1;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 11px;
        }

        /* Pagination & Layout */
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            border-top: 1px solid #f1f5f9;
        }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- SIDEBAR -->
        <div class="col-md-3 col-lg-2 px-0 admin-sidebar d-none d-md-block">
            <jsp:include page="/views/layout/sidebar_admin.jsp" />
        </div>

        <!-- MAIN CONTENT AREA -->
        <div class="col-md-9 col-lg-10 px-md-4 py-4">
            <!-- HEADER NAV -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold text-slate-900 m-0"><i class="bi bi-shield-shaded text-success me-2"></i>Nhật Ký & Kiểm Toán</h3>
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
                <form action="${pageContext.request.contextPath}/admin/audit-log" method="GET">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label text-muted small fw-bold">Tìm kiếm tổng hợp</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                                <input type="text" name="search" class="form-control bg-light border-start-0 text-slate-800" placeholder="Mã đơn, sản phẩm, dữ liệu..." value="<c:out value='${param.search}'/>">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label text-muted small fw-bold">Hành động</label>
                            <select name="action" class="form-select bg-light">
                                <option value="">-- Tất cả hành động --</option>
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
                                <option value="">-- Tất cả bảng --</option>
                                <option value="DON_HANG" ${param.tableName == 'DON_HANG' ? 'selected' : ''}>Hóa đơn (DON_HANG)</option>
                                <option value="SAN_PHAM" ${param.tableName == 'SAN_PHAM' ? 'selected' : ''}>Sản phẩm (SAN_PHAM)</option>
                                <option value="TOPPING" ${param.tableName == 'TOPPING' ? 'selected' : ''}>Món ăn kèm (TOPPING)</option>
                                <option value="DAN_MUC" ${param.tableName == 'DAN_MUC' ? 'selected' : ''}>Danh mục (DAN_MUC)</option>
                                <option value="NHAN_VIEN" ${param.tableName == 'NHAN_VIEN' ? 'selected' : ''}>Nhân viên (NHAN_VIEN)</option>
                                <option value="KHACH_HANG" ${param.tableName == 'KHACH_HANG' ? 'selected' : ''}>Khách hàng (KHACH_HANG)</option>
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
                    <strong class="text-slate-800 fs-5"><i class="bi bi-list-stars text-success me-1"></i>Lịch sử kiểm toán</strong>
                    <span class="badge bg-light text-dark border px-3 py-1.5 fw-bold" style="border-radius: 20px;">
                        Tìm thấy ${logsList.size() != null ? logsList.size() : 0} mốc biến động
                    </span>
                </div>
                <div class="table-responsive">
                    <table class="table table-audit mb-0">
                        <thead>
                        <tr>
                            <th style="width: 50px;">ID</th>
                            <th style="width: 150px;">Thời gian</th>
                            <th style="width: 180px;">Nhân viên tác động</th>
                            <th style="width: 130px;">Hành động</th>
                            <th style="width: 180px;">Vùng tác động</th>
                            <th>Đối soát biến động dữ liệu</th>
                            <th style="width: 110px;">Địa chỉ IP</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty logsList}">
                                <c:forEach var="log" items="${logsList}">
                                    <tr>
                                        <td class="font-monospace fw-bold text-muted">${log.maLog}</td>
                                        <td class="font-monospace text-slate-800">
                                            <fmt:formatDate value="${log.thoiGian}" pattern="HH:mm:ss  dd/MM/yyyy" />
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                                                    <i class="bi bi-person-badge text-success"></i>
                                                </div>
                                                <div class="text-start">
                                                        <span class="d-block fw-bold text-slate-800">
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
                                                        <c:choose>
                                                            <c:when test="${not empty log.hoTenNhanVien}">
                                                                <c:out value="${log.hoTenNhanVien}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                Khách mua đặt online
                                                            </c:otherwise>
                                                        </c:choose>
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
                                        <td>
                                            <div class="text-start">
                                                <strong class="d-block text-slate-800" style="font-size: 12px;"><c:out value="${log.bangTacDong}"/></strong>
                                                <c:if test="${not empty log.recordTacDong}">
                                                        <span class="primary-key-badge mt-1 d-inline-block">
                                                            <i class="bi bi-key-fill text-warning me-0.5"></i> <c:out value="${log.recordTacDong}"/>
                                                        </span>
                                                </c:if>
                                            </div>
                                        </td>
                                        <td>
                                            <!-- ĐỐI SOÁT DỮ LIỆU CŨ VS MỚI -->
                                            <div class="row g-2">
                                                <!-- COLUMN CŨ -->
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU CŨ TRƯỚC BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-old">
                                                        <c:choose>
                                                            <c:when test="${not empty log.duLieuCu}">
                                                                <c:out value="${log.duLieuCu}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted font-monospace italic">[TRỐNG]</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <!-- COLUMN MỚI -->
                                                <div class="col-md-6">
                                                    <div class="text-muted small fw-bold mb-1" style="font-size: 10px;">DỮ LIỆU MỚI SAU BIẾN ĐỘNG:</div>
                                                    <div class="compare-box compare-new">
                                                        <c:choose>
                                                            <c:when test="${not empty log.duLieuMoi}">
                                                                <c:out value="${log.duLieuMoi}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted font-monospace italic">[TRỐNG]</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="font-monospace text-slate-700">
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
                <div class="pagination-container bg-white rounded-bottom-4">
                    <span class="small text-muted font-monospace">Trang 1 / 1 (Đã tối ưu hóa tải dynamic siêu tốc)</span>
                    <nav aria-label="Page navigation">
                        <ul class="pagination pagination-sm m-0">
                            <li class="page-item disabled">
                                <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Trước</a>
                            </li>
                            <li class="page-item active"><a class="page-link bg-success border-success" href="#">1</a></li>
                            <li class="page-item disabled">
                                <a class="page-link" href="#">Sau</a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
