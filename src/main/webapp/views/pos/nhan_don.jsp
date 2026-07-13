<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Điều Phối Đơn Hàng Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
    <style>
        :root {
            --pos-bg: #f8fafc;
            --pos-panel-bg: #ffffff;
            --pos-primary: #10b981;
            --pos-primary-dark: #059669;
            --pos-secondary: #0f172a;
            --pos-border: #e2e8f0;
            --pos-active-light: #ecfdf5;
            --pos-text-main: #1e293b;
            --pos-text-muted: #64748b;
        }
        html, body {
            height: 100vh;
            overflow: hidden;
            background-color: var(--pos-bg);
            color: var(--pos-text-main);
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }
        .nhandon-layout {
            height: calc(100vh - 60px);
            overflow-y: auto;
            padding: 24px;
        }
    </style>
</head>
<body class="bg-light">
<!-- HEADER CHỈ HUY NHẬN ĐƠN ĐỒNG BỘ HOÀN TOÀN VỚI QUẦY POS -->
<nav class="navbar navbar-dark bg-dark px-3 sticky-top" style="height: 60px; z-index: 100;">
    <div class="container-fluid">
        <div class="d-flex align-items-center gap-3">
            <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
                <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
                <span>TEA POS PRO</span>
            </a>
            <!-- BỘ ĐÔI TAB CHUYỂN PHÂN HỆ NGAY TRONG GIAO DIỆN POS -->
            <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
                <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-outline-light fw-bold px-3">
                    <i class="bi bi-cart-fill me-1"></i> BÁN TẠI QUẦY
                </a>
                <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-success fw-bold px-3">
                    <i class="bi bi-bell-fill me-1 text-warning"></i> ĐƠN ONLINE
                </a>
            </div>
        </div>
        <div class="d-flex align-items-center gap-3">
<span class="badge bg-danger p-2 px-3 fw-bold border border-light animate-pulse" style="font-size: 11px; letter-spacing: 0.5px;">
🔴 LIVE POLLING (5S/LẦN)
</span>
            <span class="small fw-semibold border-end pe-3 border-secondary d-none d-md-inline text-white">
<i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
</span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase" style="font-size: 11px;">
                <i class="bi bi-shield-lock-fill me-1"></i> Quản trị Admin
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger border-2">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</nav>

<div class="nhandon-layout">
    <!-- KHỐI BỘ LỌC TRẠNG THÁI TRỰC TUYẾN -->
    <div class="card card-teapos p-3 mb-4 border-0 shadow-sm" style="border-radius: 12px;">
        <div class="d-flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=0" class="btn ${currentStatus == 0 ? 'btn-warning text-dark' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-clock-history"></i> Chờ Xác Nhận
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=1" class="btn ${currentStatus == 1 ? 'btn-info text-white' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-check2-all"></i> Đã Xác Nhận
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=2" class="btn ${currentStatus == 2 ? 'btn-primary' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-cup-straw"></i> Đang Pha Chế
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=3" class="btn ${currentStatus == 3 ? 'btn-success' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-box2-heart"></i> Sẵn Sàng Chờ Lấy
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=4" class="btn ${currentStatus == 4 ? 'btn-dark' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-check-circle-fill"></i> Đã Hoàn Thành
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon?status=5" class="btn ${currentStatus == 5 ? 'btn-danger' : 'btn-light border'} fw-bold btn-sm rounded-pill px-3">
                <i class="bi bi-x-circle-fill"></i> Đơn Hủy Bỏ
            </a>
        </div>
    </div>

    <!-- DANH SÁCH ĐƠN HÀNG TRỰC TUYẾN -->
    <div class="row g-4">
        <c:choose>
            <c:when test="${not empty onlineOrders}">
                <c:forEach var="order" items="${onlineOrders}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="card card-teapos shadow-sm border p-4 bg-white" style="border-radius: 12px; transition: transform 0.2s ease;">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <h5 class="fw-bold mb-0 text-success">${order.maDh}</h5>
                                    <small class="text-muted">Đặt lúc: <fmt:formatDate value="${order.thoiGianTao}" pattern="dd/MM/yyyy HH:mm"/></small>
                                </div>
                                <span class="badge ${order.trangThaiThanhToan == 1 ? 'bg-success' : 'bg-warning'} text-white">
                                        ${order.trangThaiThanhToan == 1 ? 'Đã thanh toán' : 'Chờ trả tiền mặt'}
                                </span>
                            </div>
                            <!-- Mốc giờ Click & Collect hẹn lấy nước -->
                            <div class="p-2 bg-light rounded text-dark small mb-3 border border-dashed border-success">
                                <i class="bi bi-alarm-fill text-danger me-1"></i> HẸN ĐẾN QUẦY LẤY:
                                <strong><fmt:formatDate value="${order.thoiGianHenLay}" pattern="HH:mm (dd/MM)"/></strong>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted d-block" style="font-size: 11px;">Thành viên CRM</small>
                                <strong class="text-dark small"><i class="bi bi-person-fill text-success"></i> Khách hàng: <c:out value="${not empty order.maKh ? order.maKh : 'Khách vãng lai lẻ'}"/></strong>
                            </div>

                            <!-- BỔ SUNG: NÚT XEM CHI TIẾT ĐƠN HÀNG ĐỂ NHÂN VIÊN BIẾT MÓN ĂN & TOPPINGS -->
                            <button type="button" class="btn btn-sm btn-outline-success w-100 fw-bold py-2 mb-3 shadow-sm" onclick="showOnlineOrderDetail('${order.maDh}')">
                                <i class="bi bi-receipt-cutoff me-1"></i> XEM CHI TIẾT MÓN & TOPPING
                            </button>

                            <!-- Khối tính dồn tiền -->
                            <div class="d-flex justify-content-between align-items-center mb-4 border-top pt-2">
                                <div>
                                    <small class="text-muted d-block" style="font-size: 11px;">Giá trị thu</small>
                                    <strong class="text-danger fs-5"><fmt:formatNumber value="${order.tongPhaiTra}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</strong>
                                </div>
                                <div class="text-end">
                                    <small class="text-muted d-block" style="font-size: 11px;">Hình thức đặt</small>
                                    <span class="badge bg-dark text-white fw-bold">CLICK & COLLECT</span>
                                </div>
                            </div>
                            <!-- Trục điều phối trạng thái -->
                            <form action="${pageContext.request.contextPath}/pos/nhandon" method="POST" id="formUpdate_${order.maDh}">
                                <input type="hidden" name="maDh" value="${order.maDh}">
                                <input type="hidden" name="trangThaiMoi" id="statusField_${order.maDh}">
                                <input type="hidden" name="lyDoHuy" id="cancelReason_${order.maDh}">
                                <div class="row g-2">
                                    <c:choose>
                                        <c:when test="${order.trangThaiDon == 0}">
                                            <div class="col-6">
                                                <button type="button" class="btn btn-sm btn-outline-danger w-100 fw-bold py-2" onclick="cancelOnlineOrder('${order.maDh}')">HỦY ĐƠN</button>
                                            </div>
                                            <div class="col-6">
                                                <button type="button" class="btn btn-sm btn-success w-100 fw-bold py-2" onclick="submitStatus('${order.maDh}', 1)">XÁC NHẬN</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 1}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-primary w-100 fw-bold py-2" onclick="submitStatus('${order.maDh}', 2)">BẮT ĐẦU PHA CHẾ</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 2}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-success w-100 fw-bold py-2" onclick="submitStatus('${order.maDh}', 3)">BÁO LÊN KỆ CHỜ LẤY</button>
                                            </div>
                                        </c:when>
                                        <c:when test="${order.trangThaiDon == 3}">
                                            <div class="col-12">
                                                <button type="button" class="btn btn-sm btn-dark w-100 fw-bold py-2" onclick="submitStatus('${order.maDh}', 4)">GIAO NƯỚC (HOÀN THÀNH)</button>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="col-12 text-center text-muted small py-2 bg-light rounded border">
                                                Giao dịch đã đóng (Locked)
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12 text-center py-5 text-muted">
                    <i class="bi bi-clock-history fs-1 d-block mb-2"></i>
                    Không có đơn hàng online nào thuộc trạng thái lọc hiện hành!
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- MODAL BẮT TRỌN CHI TIẾT ĐƠN HÀNG ONLINE CHO NHÂN VIÊN CHỐT PHA CHẾ -->
<div class="modal fade" id="onlineOrderDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-receipt-cutoff text-success me-2"></i>CHI TIẾT MÓN & TOPPING</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light text-start">
                <div class="mb-3 small">
                    <div>Mã hóa đơn: <strong id="modalMaDh" class="text-success"></strong></div>
                    <div>Thời gian đặt: <span id="modalThoiGian"></span></div>
                    <div>Hẹn nhận nước: <strong id="modalHenLay" class="text-danger"></strong></div>
                    <div>Tên khách hàng: <span id="modalKhachHang"></span></div>
                    <div>Số điện thoại: <strong id="modalSdt"></strong></div>
                    <div class="mt-1">Dặn dò của khách: <em id="modalGhiChu" class="text-muted fw-bold"></em></div>
                </div>
                <div style="border-bottom: 1.5px dashed #333; margin: 10px 0;"></div>
                <!-- Danh sách món nước uống + Topping + Định lượng -->
                <div id="modalItemsContainer"></div>
                <div style="border-bottom: 1.5px dashed #333; margin: 10px 0;"></div>
                <div class="small">
                    <div class="d-flex justify-content-between mb-1">
                        <span>Tổng tiền hàng gốc:</span>
                        <strong id="modalRawPrice">0 đ</strong>
                    </div>
                    <div class="d-flex justify-content-between text-danger mb-1">
                        <span>Giảm giá Voucher:</span>
                        <strong id="modalDiscount">-0 đ</strong>
                    </div>
                    <div class="d-flex justify-content-between text-primary mb-1" id="modalPointsRow" style="display: none;">
                        <span>Khấu trừ điểm CRM:</span>
                        <strong id="modalPointsDiscount">-0 đ</strong>
                    </div>
                    <div class="d-flex justify-content-between fs-5 fw-bold text-success border-top pt-2 mt-2">
                        <span>THỰC THU TRÊN WEB:</span>
                        <span id="modalFinalPayable">0 đ</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer bg-light p-2.5">
                <button type="button" class="btn btn-secondary px-3.5" data-bs-dismiss="modal">Đóng đối soát</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    function submitStatus(maDh, targetStatus) {
        document.getElementById("statusField_" + maDh).value = targetStatus;
        document.getElementById("formUpdate_" + maDh).submit();
    }

    function cancelOnlineOrder(maDh) {
        Swal.fire({
            title: 'Từ chối đơn hàng?',
            text: 'Vui lòng điền rõ lý do hủy đơn hàng online đặt trước này:',
            input: 'text',
            inputPlaceholder: 'Ví dụ: Hết nguyên liệu, hết đá sạch...',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý hủy',
            cancelButtonText: 'Quay lại',
            preConfirm: (reason) => {
                if (!reason || reason.trim() === '') {
                    Swal.showValidationMessage('Bạn bắt buộc phải nhập lý do hủy đơn!');
                }
                return reason;
            }
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById("statusField_" + maDh).value = 5; // Hủy đơn
                document.getElementById("cancelReason_" + maDh).value = result.value;
                document.getElementById("formUpdate_" + maDh).submit();
            }
        });
    }

    // Hàm lấy Context Path tự động
    function getContextPath() {
        return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    }

    // Hàm mở Modal đối soát bóc tách chi tiết món ăn + topping dành riêng cho nhân viên
    const onlineDetailModal = new bootstrap.Modal(document.getElementById('onlineOrderDetailModal'));
    function showOnlineOrderDetail(maDh) {
        document.getElementById("modalItemsContainer").innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success" role="status"></div><p class="small text-muted mt-2">Đang tải chi tiết đơn...</p></div>';
        onlineDetailModal.show();

        fetch(getContextPath() + '/pos/bill-detail?id=' + maDh)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById("modalMaDh").innerText = data.maDh;
                    document.getElementById("modalThoiGian").innerText = data.thoiGianTao;
                    document.getElementById("modalHenLay").innerText = data.thoiGianHenLay;
                    document.getElementById("modalKhachHang").innerText = data.tenKhachHang;
                    document.getElementById("modalSdt").innerText = data.sdtKhachHang;
                    document.getElementById("modalGhiChu").innerText = data.ghiChuDon ? data.ghiChuDon : "Không có";

                    document.getElementById("modalRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                    document.getElementById("modalDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';
                    if (data.diemSuDung > 0) {
                        document.getElementById("modalPointsRow").style.setProperty('display', 'flex', 'important');
                        document.getElementById("modalPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                    } else {
                        document.getElementById("modalPointsRow").style.setProperty('display', 'none', 'important');
                    }
                    document.getElementById("modalFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                    let container = document.getElementById("modalItemsContainer");
                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div class="mb-3 border-bottom pb-2">';
                        html += '  <div class="d-flex justify-content-between align-items-center">';
                        html += '    <span class="fs-6"><strong>' + item.tenMon + '</strong> (Size ' + item.tenSize + ')</span>';
                        html += '    <span class="badge bg-success py-1.5 px-3">SL: x' + item.soLuong + '</span>';
                        html += '  </div>';
                        html += '  <div class="mt-1 small text-muted">';
                        html += '    <span class="badge bg-light text-dark border me-1">Đá: ' + item.mucDa + '</span>';
                        html += '    <span class="badge bg-light text-dark border me-1">Đường: ' + item.mucDuong + '</span>';
                        if (item.ghiChuMon) {
                            html += '    <span class="badge bg-warning-subtle text-warning border border-warning">Dặn thợ: ' + item.ghiChuMon + '</span>';
                        }
                        html += '  </div>';
                        if (item.toppings && item.toppings.length > 0) {
                            html += '  <div class="ps-3 mt-2 border-start border-success border-2 small text-muted">';
                            html += '    <div class="fw-bold text-success mb-1" style="font-size: 11px;">Topping đi kèm:</div>';
                            item.toppings.forEach(tp => {
                                html += '    <div>+ ' + tp.tenTopping + ' (Số lượng phần: x' + tp.soLuong + ')</div>';
                            });
                            html += '  </div>';
                        }
                        html += '</div>';
                        container.innerHTML += html;
                    });
                } else {
                    showToast('error', 'Không tìm thấy chi tiết hóa đơn!');
                    onlineDetailModal.hide();
                }
            })
            .catch(err => {
                console.error("Lỗi:", err);
                showToast('error', 'Không thể nạp dữ liệu từ máy chủ!');
                onlineDetailModal.hide();
            });
    }

    // Ajax live polling every 5s
    setInterval(function() {
        fetch('${pageContext.request.contextPath}/pos/nhandon?action=checkPollingCount&status=' + ${currentStatus})
            .then(res => res.text())
            .then(data => {
                const currentCount = ${onlineOrders.size()};
                if (parseInt(data) !== currentCount && parseInt(data) > 0) {
                    showToast('info', 'Phát hiện có đơn đặt online mới hoặc thanh toán qua SePay!');
                    setTimeout(() => { location.reload(); }, 1500);
                }
            })
            .catch(err => console.error("Lỗi Polling:", err));
    }, 5000);
</script>
</body>
</html>