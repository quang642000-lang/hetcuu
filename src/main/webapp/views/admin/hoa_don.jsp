<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Tra Cứu Hóa Đơn Bán Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
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
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            background-color: #ffffff;
            border-top: 1px solid var(--border-color);
        }
    </style>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <jsp:include page="/views/layout/sidebar_admin.jsp" />
    <div class="admin-content">
        <jsp:include page="/views/layout/header_admin.jsp" />
        <div class="p-4">
            <div class="card card-teapos p-4 shadow-sm border-0" style="border-radius: 12px;">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4 text-start">
                    <div>
                        <h3 class="fw-bold mb-1" style="color: var(--primary-color);">LỊCH SỬ HÓA ĐƠN TÀI CHÍNH</h3>
                        <p class="text-muted small mb-0">Quản lý vòng đời hóa đơn, tra soát mốc doanh thu, lọc nhân viên xử lý và in hóa đơn tại quầy</p>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/hoadon" method="GET" class="d-flex flex-wrap gap-2">
                        <select name="status" class="form-select form-select-sm" style="max-width: 200px;">
                            <option value="">Tất cả trạng thái</option>
                            <option value="0" ${statusFilter eq '0' ? 'selected' : ''}>Chờ xác nhận</option>
                            <option value="1" ${statusFilter eq '1' ? 'selected' : ''}>Đã xác nhận</option>
                            <option value="2" ${statusFilter eq '2' ? 'selected' : ''}>Đang pha chế</option>
                            <option value="3" ${statusFilter eq '3' ? 'selected' : ''}>Sẵn sàng lấy</option>
                            <option value="4" ${statusFilter eq '4' ? 'selected' : ''}>Hoàn thành</option>
                            <option value="5" ${statusFilter eq '5' ? 'selected' : ''}>Đã hủy</option>
                        </select>
                        <select id="filterNhanVien" class="form-select form-select-sm" style="max-width: 200px;" onchange="filterOrdersRealtime()">
                            <option value="">Tất cả nhân viên đảm nhiệm</option>
                            <option value="SYSTEM">Hệ thống tự động / Chưa nhận đơn</option>
                            <c:forEach var="nv" items="${employees}">
                                <option value="${nv.maNv}"><c:out value="${nv.hoTen}"/> (${nv.maNv})</option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn btn-sm btn-primary-teapos px-3"><i class="bi bi-funnel"></i> Lọc đơn</button>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle admin-table" id="ordersTable">
                        <thead>
                        <tr class="table-light text-center">
                            <th style="width: 60px;">STT</th>
                            <th>Mã hoá đơn</th>
                            <th>Mã Khách</th>
                            <th>Thời gian</th>
                            <th class="text-end">Tiền gốc</th>
                            <th class="text-end">Khấu trừ KM</th>
                            <th class="text-end">Thành tiền</th>
                            <th class="text-center">Thanh Toán</th>
                            <th class="text-center">Trạng Thái Đơn</th>
                            <th class="text-center">Nhân viên đảm nhiệm</th>
                            <th class="text-end" style="width: 150px;">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody id="ordersTableBody">
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach var="item" items="${orders}" varStatus="loop">
                                    <tr class="order-row text-center" data-manv="${not empty item.maNv ? item.maNv : 'SYSTEM'}">
                                        <td class="row-stt"><strong>${loop.index + 1}</strong></td>
                                        <td><strong>${item.maDh}</strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.maKh}">
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success">${item.maKh}</span>
                                                </c:when>
                                                <c:otherwise><span class="text-muted small">Khách vãng lai</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small"><fmt:formatDate value="${item.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="text-end"><fmt:formatNumber value="${item.tongTienHang}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                        <td class="text-end text-danger">-<fmt:formatNumber value="${item.tienGiamGia + item.tienTruDiem}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                        <td class="text-end text-success fw-bold"><fmt:formatNumber value="${item.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                        <td class="text-center">
                                                <span class="badge ${item.trangThaiThanhToan == 1 ? 'bg-success-subtle text-success border-success' : 'bg-warning-subtle text-warning border-warning'} border px-2.5 py-1">
                                                        ${item.trangThaiThanhToan == 1 ? 'Đã thanh toán' : 'Chưa trả'}
                                                </span>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.trangThaiDon == 0}"><span class="badge bg-secondary">Chờ duyệt</span></c:when>
                                                <c:when test="${item.trangThaiDon == 1}"><span class="badge bg-info text-white">Đã XN</span></c:when>
                                                <c:when test="${item.trangThaiDon == 2}"><span class="badge bg-warning text-dark">Pha chế</span></c:when>
                                                <c:when test="${item.trangThaiDon == 3}"><span class="badge bg-primary text-white">Chờ lấy</span></c:when>
                                                <c:when test="${item.trangThaiDon == 4}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                                <c:when test="${item.trangThaiDon == 5}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty item.maNv}">
                                                    <c:set var="matchedStaffName" value="${item.maNv}" />
                                                    <c:forEach var="nv" items="${employees}">
                                                        <c:if test="${nv.maNv eq item.maNv}">
                                                            <c:set var="matchedStaffName" value="${nv.hoTen}" />
                                                        </c:if>
                                                    </c:forEach>
                                                    <span class="badge bg-light text-dark border"><i class="bi bi-person-badge text-success me-1"></i><c:out value="${matchedStaffName}"/></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small">Chờ nhận đơn / Online</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-success fw-bold" onclick="showReceiptDetail('${item.maDh}')">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="11" class="text-center py-5 text-muted">Chưa ghi nhận hóa đơn nào!</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- PHÂN TRANG ĐỒNG BỘ -->
                <div class="pagination-container" id="paginationWrapper" style="display: none;">
                    <span class="small text-muted" id="paginationInfo">Hiển thị từ 1 đến 10 của 10 đơn hàng</span>
                    <nav>
                        <ul class="pagination pagination-sm mb-0 justify-content-end" id="paginationButtons"></ul>
                    </nav>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- POPUP CHI TIẾT HÓA ĐƠN & IN BILL POS -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-printer-fill me-1 text-success"></i> HOÁ ĐƠN THANH TOÁN</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-white text-dark text-start" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; font-size: 12px; line-height: 1.4;">
                <div class="text-center mb-3">
                    <h5 class="fw-bold mb-0">TEA POS SYSTEM</h5>
                    <small class="text-muted">123 Đường Trà Sữa, Phường 10, Gò Vấp</small> <br>
                    <small class="text-muted">Hotline: (+84) 123 456 789</small>
                    <hr class="border-secondary border-dashed my-2">
                    <h6 class="fw-bold text-dark">PHIẾU THANH TOÁN HÓA ĐƠN</h6>
                    <small class="text-muted" id="billThoiGian"></small>
                </div>
                <div class="small mb-3">
                    <div>Mã hóa đơn: <strong id="billMaDh" class="text-dark"></strong></div>
                    <div>Khách CRM: <strong id="billTenKh"></strong></div>
                    <div>Thu ngân: <strong id="billTenNv"></strong></div>
                </div>
                <hr class="border-secondary border-dashed my-2">
                <div id="billItemsContainer" class="small"></div>
                <hr class="border-secondary border-dashed my-2">
                <div class="small">
                    <div class="d-flex justify-content-between">
                        <span>Tổng tiền hàng & Topping:</span>
                        <strong id="billRawPrice"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger" id="billDiscountRow">
                        <span>Voucher giảm giá:</span>
                        <strong id="billDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger" id="billPointsRow">
                        <span>Điểm CRM tiêu dùng:</span>
                        <strong id="billPointsDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between fs-5 fw-bold text-success border-top pt-2 mt-1">
                        <span>THỰC THU (VNĐ):</span>
                        <span id="billFinalPayable"></span>
                    </div>
                </div>
                <div class="text-center mt-4 pt-2 border-top">
                    <p class="small text-muted mb-0">Cảm ơn quý khách hàng và hẹn gặp lại! <br> <i>Powered by CodeDevSquad</i></p>
                </div>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-primary" onclick="printReceipt()"><i class="bi bi-printer"></i> In hóa đơn</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    const receiptModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));

    function showReceiptDetail(maDh) {
        document.getElementById("billItemsContainer").innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success" role="status"></div><p class="small text-muted mt-2">Đang tải hóa đơn...</p></div>';
        fetch('${pageContext.request.contextPath}/admin/hoadon?action=detailJson&id=' + maDh)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById("billMaDh").innerText = data.maDh;
                    document.getElementById("billThoiGian").innerText = data.thoiGianTao;
                    document.getElementById("billTenKh").innerText = data.tenKhachHang ? data.tenKhachHang : 'Khách lẻ vãng lai';
                    document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Đặt mua Online';
                    document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';
                    if (data.tienGiamGia > 0) {
                        document.getElementById("billDiscountRow").style.setProperty('display', 'flex', 'important');
                    } else {
                        document.getElementById("billDiscountRow").style.setProperty('display', 'none', 'important');
                    }
                    if (data.diemSuDung > 0) {
                        document.getElementById("billPointsRow").style.setProperty('display', 'flex', 'important');
                        document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                    } else {
                        document.getElementById("billPointsRow").style.setProperty('display', 'none', 'important');
                    }
                    document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';
                    let container = document.getElementById("billItemsContainer");
                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div class="mb-2 border-bottom pb-1">';
                        html += '<div class="d-flex justify-content-between">';
                        html += '<span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                        html += '<strong>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</strong>';
                        html += '</div>';
                        html += '<small class="text-muted d-block">Pha chế: Đá ' + item.mucDa + ' | Đường ' + item.mucDuong + '</small>';
                        if (item.toppings && item.toppings.length > 0) {
                            html += '<div class="ps-2 small text-muted">';
                            item.toppings.forEach(tp => {
                                html += '<div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                            });
                            html += '</div>';
                        }
                        html += '</div>';
                        container.innerHTML += html;
                    });
                    receiptModal.show();
                } else {
                    showToast('error', 'Không tìm thấy hóa đơn!');
                }
            })
            .catch(err => {
                console.error("Lỗi:", err);
                showToast('error', 'Không thể nạp dữ liệu từ máy chủ!');
            });
    }

    function printReceipt() {
        const printContent = document.getElementById("billPrintArea").innerHTML;
        const originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload();
    }

    // ==========================================
    // PHÂN TRANG VÀ BỘ LỌC CLIENT SIDE ĐỒNG BỘ 100%
    // ==========================================
    let currentPage = 1;
    const pageSize = 10;
    let filteredRows = [];

    function filterOrdersRealtime() {
        const selectedNv = document.getElementById("filterNhanVien").value;
        const allRows = document.querySelectorAll("#ordersTableBody .order-row");
        filteredRows = [];

        allRows.forEach(row => {
            const rowNv = row.getAttribute("data-manv");
            if (selectedNv === "" || rowNv === selectedNv) {
                filteredRows.push(row);
            } else {
                row.style.display = "none";
            }
        });
        currentPage = 1;
        renderTableRows();
    }

    function renderTableRows() {
        const allRows = document.querySelectorAll("#ordersTableBody .order-row");
        allRows.forEach(row => row.style.display = "none");

        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;

        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);

        const pageRows = filteredRows.slice(startIdx, endIdx);
        pageRows.forEach((row, idx) => {
            row.style.display = "table-row";
            row.querySelector(".row-stt strong").innerText = startIdx + idx + 1;
        });

        updatePaginationControls();
    }

    function updatePaginationControls() {
        const totalRows = filteredRows.length;
        const totalPages = Math.ceil(totalRows / pageSize) || 1;
        const infoEl = document.getElementById("paginationInfo");
        const btnContainer = document.getElementById("paginationButtons");
        const wrapper = document.getElementById("paginationWrapper");

        if (!infoEl || !btnContainer || !wrapper) return;

        const start = totalRows > 0 ? (currentPage - 1) * pageSize + 1 : 0;
        const end = Math.min(currentPage * pageSize, totalRows);
        infoEl.innerText = 'Hiển thị từ ' + start + ' đến ' + end + ' dòng trên tổng số ' + totalRows + ' hóa đơn';

        btnContainer.innerHTML = "";
        if (totalPages <= 1) {
            wrapper.style.setProperty('display', 'none', 'important');
            return;
        }
        wrapper.style.setProperty('display', 'flex', 'important');

        // Nút Trước
        const prevLi = document.createElement("li");
        prevLi.className = "page-item " + (currentPage === 1 ? "disabled" : "");
        prevLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage - 1) + ')">&laquo; Trước</a>';
        btnContainer.appendChild(prevLi);

        // Trang số
        for (let i = 1; i <= totalPages; i++) {
            const li = document.createElement("li");
            li.className = "page-item " + (currentPage === i ? "active" : "");
            li.innerHTML = '<a class="page-link ' + (currentPage === i ? "bg-success border-success text-white" : "text-success") + '" href="javascript:void(0)" onclick="changePage(' + i + ')">' + i + '</a>';
            btnContainer.appendChild(li);
        }

        // Nút Sau
        const nextLi = document.createElement("li");
        nextLi.className = "page-item " + (currentPage === totalPages ? "disabled" : "");
        nextLi.innerHTML = '<a class="page-link text-success" href="javascript:void(0)" onclick="changePage(' + (currentPage + 1) + ')">Sau &raquo;</a>';
        btnContainer.appendChild(nextLi);
    }

    function changePage(page) {
        const totalPages = Math.ceil(filteredRows.length / pageSize) || 1;
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTableRows();
    }

    document.addEventListener("DOMContentLoaded", function() {
        const allRows = document.querySelectorAll("#ordersTableBody .order-row");
        filteredRows = Array.from(allRows);
        renderTableRows();

        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'updatesuccess') showToast('success', 'Cập nhật trạng thái đơn hàng thành công!');
    });
</script>
</body>
</html>