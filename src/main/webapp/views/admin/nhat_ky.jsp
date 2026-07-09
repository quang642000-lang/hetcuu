<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Nhật Ký Hoạt Động Hệ Thống</title>
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
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">NHẬT KÝ HOẠT ĐỘNG (AUDIT TRAIL)</h3>
                    <p class="text-muted small mb-0">Hộp đen lưu vết tất cả thay đổi dữ liệu nhạy cảm, tra cứu mã nhân viên và địa chỉ IP vận hành</p>
                </div>

                <!-- Bộ lọc theo mã nhân viên -->
                <form action="${pageContext.request.contextPath}/admin/auditlog" method="GET" class="d-flex gap-2">
                    <input type="text" name="filterNhanVien" class="form-control form-control-sm" placeholder="Nhập mã NV..." value="<c:out value="${filterNhanVien}"/>" style="max-width: 180px;">
                    <button type="submit" class="btn btn-sm btn-primary-teapos px-3">
                        <i class="bi bi-search"></i> Tra cứu
                    </button>
                    <c:if test="${not empty filterNhanVien}">
                        <a href="${pageContext.request.contextPath}/admin/auditlog" class="btn btn-sm btn-outline-secondary">Xóa lọc</a>
                    </c:if>
                </form>
            </div>

            <!-- BẢNG DANH SÁCH NHẬT KÝ -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th style="width: 80px;">Mã log</th>
                        <th style="width: 180px;">Thời gian ghi nhận</th>
                        <th style="width: 120px;">Nhân sự</th>
                        <th style="width: 220px;">Hành động thực hiện</th>
                        <th style="width: 150px;">Bảng tác động</th>
                        <th style="width: 130px;">Địa chỉ IP</th>
                        <th class="text-end">Đối soát dữ liệu</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty logs}">
                            <c:forEach var="item" items="${logs}">
                                <tr>
                                    <td><code>#${item.maLog}</code></td>
                                    <td class="small"><fmt:formatDate value="${item.thoiGian}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                    <td><span class="badge bg-light text-dark border"><strong>${item.maNv}</strong></span></td>
                                    <td><span class="fw-bold text-dark"><c:out value="${item.hanhDong}"/></span></td>
                                    <td><code>${item.bangTacDong}</code></td>
                                    <td><small class="text-muted">${not empty item.ipAddress ? item.ipAddress : '127.0.0.1'}</small></td>
                                    <td>
                                        <div class="d-flex justify-content-end">
                                            <button class="btn btn-sm btn-outline-success fw-bold px-2.5 py-1 small"
                                                    onclick="viewAuditDiff('#${item.maLog}', '${item.maNv}', '<c:out value="${item.hanhDong}"/>', encodeURIComponent('${item.duLieuCu}'), encodeURIComponent('${item.duLieuMoi}'))">
                                                <i class="bi bi-file-earmark-diff"></i> So sánh dữ liệu
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">Không tìm thấy bản ghi nhật ký hoạt động nào hợp lệ!</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- MODAL BÓC TÁCH JSON ĐỐI SOÁT DỮ LIỆU CŨ VÀ MỚI (DIFF VIEWER) -->
<div class="modal fade" id="auditDiffModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-success text-white py-2.5">
                <h6 class="modal-title fw-bold"><i class="bi bi-patch-check-fill"></i> ĐỐI SOÁT KIỂM TOÁN LỊCH SỬ</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light">
                <div class="row g-2 mb-3">
                    <div class="col-4">
                        <small class="text-muted d-block">Mã ghi log</small>
                        <strong id="diffMaLog" class="text-dark"></strong>
                    </div>
                    <div class="col-4">
                        <small class="text-muted d-block">Người thực thi</small>
                        <strong id="diffMaNv" class="text-success"></strong>
                    </div>
                    <div class="col-4">
                        <small class="text-muted d-block">Loại nghiệp vụ</small>
                        <strong id="diffHanhDong" class="text-primary"></strong>
                    </div>
                </div>

                <div class="row g-3">
                    <!-- Khung Dữ liệu gốc cũ -->
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-bold text-danger small"><i class="bi bi-dash-circle-fill"></i> Trạng thái dữ liệu cũ (JSON)</label>
                        <pre id="jsonOld" class="p-3 border rounded text-dark bg-white overflow-auto small" style="max-height: 250px; font-family: monospace;"></pre>
                    </div>
                    <!-- Khung Dữ liệu lưu mới -->
                    <div class="col-12 col-md-6">
                        <label class="form-label fw-bold text-success small"><i class="bi bi-plus-circle-fill"></i> Trạng thái dữ liệu mới (JSON)</label>
                        <pre id="jsonNew" class="p-3 border rounded text-dark bg-white overflow-auto small" style="max-height: 250px; font-family: monospace;"></pre>
                    </div>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light">
                <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Đóng đối soát</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const diffModal = new bootstrap.Modal(document.getElementById('auditDiffModal'));

    function viewAuditDiff(maLog, maNv, hanhDong, encodedOld, encodedNew) {
        document.getElementById("diffMaLog").innerText = maLog;
        document.getElementById("diffMaNv").innerText = maNv;
        document.getElementById("diffHanhDong").innerText = hanhDong;

        // Giải mã ký tự đặc biệt
        let oldStr = decodeURIComponent(encodedOld).trim();
        let newStr = decodeURIComponent(encodedNew).trim();

        // Định dạng thụt lề JSON trực quan
        try {
            if (oldStr && oldStr !== 'null') {
                let parsedOld = JSON.parse(oldStr);
                document.getElementById("jsonOld").innerText = JSON.stringify(parsedOld, null, 2);
            } else {
                document.getElementById("jsonOld").innerText = "Chưa phát sinh (Tạo mới hoàn toàn)";
            }
        } catch (e) {
            document.getElementById("jsonOld").innerText = oldStr ? oldStr : "Không có dữ liệu cũ";
        }

        try {
            if (newStr && newStr !== 'null') {
                let parsedNew = JSON.parse(newStr);
                document.getElementById("jsonNew").innerText = JSON.stringify(parsedNew, null, 2);
            } else {
                document.getElementById("jsonNew").innerText = "Hủy bỏ / Xóa sạch";
            }
        } catch (e) {
            document.getElementById("jsonNew").innerText = newStr ? newStr : "Không có dữ liệu mới";
        }

        diffModal.show();
    }
</script>
</body>
</html>