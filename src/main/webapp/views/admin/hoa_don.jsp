<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Tra Cứu Hóa Đơn Bán Hàng</title>
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
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">LỊCH SỬ HÓA ĐƠN TÀI CHÍNH</h3>
                    <p class="text-muted small mb-0">Quản lý vòng đời hóa đơn, tra soát mốc doanh thu, kiểm tra phương thức thanh toán và chốt sổ cuối ngày</p>
                </div>

                <!-- Bộ lọc theo trạng thái -->
                <form action="${pageContext.request.contextPath}/admin/hoadon" method="GET" class="d-flex gap-2">
                    <select name="status" class="form-select form-select-sm" style="max-width: 200px;">
                        <option value="">Tất cả trạng thái đơn</option>
                        <option value="0" ${statusFilter eq '0' ? 'selected' : ''}>Chờ xác nhận</option>
                        <option value="1" ${statusFilter eq '1' ? 'selected' : ''}>Đã xác nhận</option>
                        <option value="2" ${statusFilter eq '2' ? 'selected' : ''}>Đang pha chế</option>
                        <option value="3" ${statusFilter eq '3' ? 'selected' : ''}>Sẵn sàng lấy nước</option>
                        <option value="4" ${statusFilter eq '4' ? 'selected' : ''}>Hoàn thành thành công</option>
                        <option value="5" ${statusFilter eq '5' ? 'selected' : ''}>Đã hủy bỏ</option>
                    </select>
                    <button type="submit" class="btn btn-sm btn-primary-teapos px-3"><i class="bi bi-funnel"></i> Lọc đơn</button>
                </form>
            </div>

            <!-- BẢNG HOÁ ĐƠN -->
            <div class="table-responsive">
                <table class="table table-hover table-teapos">
                    <thead>
                    <tr>
                        <th>Mã hoá đơn</th>
                        <th>Mã Khách</th>
                        <th>Thời gian lập hóa đơn</th>
                        <th class="text-end">Tiền hàng gốc</th>
                        <th class="text-end">Khấu trừ KM</th>
                        <th class="text-end">Khách phải trả</th>
                        <th class="text-center">Thanh Toán</th>
                        <th class="text-center">Trạng Thái Đơn</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty orders}">
                            <c:forEach var="item" items="${orders}">
                                <tr>
                                    <td><strong>${item.maDh}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty item.maKh}">
                                                <span class="badge bg-success bg-opacity-10 text-success border border-success">${item.maKh}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small">Khách vãng lai</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="small"><fmt:formatDate value="${item.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td class="text-end"><fmt:formatNumber value="${item.tongTienHang}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                    <td class="text-end text-danger">-<fmt:formatNumber value="${item.tienGiamGia + item.tienTruDiem}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                    <td class="text-end text-success fw-bold"><fmt:formatNumber value="${item.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThaiThanhToan == 1}">
                                                <span class="badge bg-success-subtle text-success border border-success">Đã thu tiền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning-subtle text-warning border border-warning">Chưa trả</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThaiDon == 0}"><span class="badge bg-secondary">Chờ duyệt</span></c:when>
                                            <c:when test="${item.trangThaiDon == 1}"><span class="badge bg-info text-white">Đã XN</span></c:when>
                                            <c:when test="${item.trangThaiDon == 2}"><span class="badge bg-warning text-dark">Đang pha chế</span></c:when>
                                            <c:when test="${item.trangThaiDon == 3}"><span class="badge bg-primary text-white">Chờ lấy</span></c:when>
                                            <c:when test="${item.trangThaiDon == 4}"><span class="badge bg-success">Hoàn thành</span></c:when>
                                            <c:when test="${item.trangThaiDon == 5}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex justify-content-end gap-2">
                                            <button class="btn btn-sm btn-outline-success fw-bold" onclick="showReceiptDetail('${item.maDh}')">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="9" class="text-center py-5 text-muted">Chưa ghi nhận hóa đơn nào khớp với điều kiện lọc!</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- POPUP CHI TIẾT HÓA ĐƠN & IN BILL POS (DYNAMIC MODAL) -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-printer-fill me-1"></i> HOÁ ĐƠN THANH TOÁN SỐ</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light" id="billPrintArea" style="font-family: Arial, sans-serif;">
                <!-- Phần tiêu đề Bill -->
                <div class="text-center mb-3">
                    <h5 class="fw-bold mb-0">TEA POS MANAGEMENT</h5>
                    <small class="text-muted">123 Đường Trà Sữa, Phường 10, Gò Vấp</small> <br>
                    <small class="text-muted">Hotline: (+84) 123 456 789</small>
                    <hr class="border-secondary border-dashed my-2">
                    <h6 class="fw-bold text-dark">PHIẾU THANH TOÁN COCKTAIL / TRÀ SỮA</h6>
                    <small class="text-muted" id="billThoiGian"></small>
                </div>

                <!-- Thông tin giao dịch -->
                <div class="small mb-3">
                    <div>Mã hóa đơn: <strong id="billMaDh" class="text-dark"></strong></div>
                    <div>Thành viên CRM: <strong id="billTenKh"></strong></div>
                    <div>Thu ngân phụ trách: <strong id="billTenNv"></strong></div>
                </div>

                <hr class="border-secondary border-dashed my-2">

                <!-- Chi tiết sản phẩm & topping -->
                <div id="billItemsContainer" class="small">
                    <!-- Script Javascript sẽ chèn chi tiết cốc nước vào đây -->
                </div>

                <hr class="border-secondary border-dashed my-2">

                <!-- Phần thanh toán tổng dồn -->
                <div class="small">
                    <div class="d-flex justify-content-between">
                        <span>Tổng tiền cốc & Topping:</span>
                        <strong id="billRawPrice"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger">
                        <span>Chiết khấu Voucher giảm giá:</span>
                        <strong id="billDiscount"></strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger" id="billPointsRow">
                        <span>Khấu trừ điểm tích lũy:</span>
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
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng cửa sổ</button>
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
        // Tự động gọi AJAX API nội bộ để lấy dữ liệu chi tiết hóa đơn (hoạt động đồng bộ)
        fetch('${pageContext.request.contextPath}/pos/search-customer?action=getBillDetail&id=' + maDh)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById("billMaDh").innerText = data.maDh;
                    document.getElementById("billThoiGian").innerText = data.thoiGianTao;
                    document.getElementById("billTenKh").innerText = data.tenKhachHang ? data.tenKhachHang : 'Khách vãng lai';
                    document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Hệ thống (Web)';
                    document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                    document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';

                    if (data.diemSuDung > 0) {
                        document.getElementById("billPointsRow").style.display = 'flex';
                        document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                    } else {
                        document.getElementById("billPointsRow").style.display = 'none';
                    }

                    document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                    // Vẽ lưới sản phẩm
                    let container = document.getElementById("billItemsContainer");
                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div class="mb-2 border-bottom pb-1">';
                        html += '<div class="d-flex justify-content-between">';
                        html += '<span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                        html += '<strong>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</strong>';
                        html += '</div>';
                        html += '<small class="text-muted d-block">Pha chế: Lượng đá ' + item.mucDa + ' | Lượng đường ' + item.mucDuong + '</small>';

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
                    showToast('error', 'Không tìm thấy thông tin chi tiết hóa đơn!');
                }
            })
            .catch(err => {
                console.error("Lỗi:", err);
                showToast('error', 'Đã xảy ra lỗi khi liên kết cơ sở dữ liệu!');
            });
    }

    function printReceipt() {
        const printContent = document.getElementById("billPrintArea").innerHTML;
        const originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload(); // Tải lại trang để khôi phục kịch bản Javascript đầy đủ
    }
</script>
</body>
</html>
