<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Giỏ Hàng Trực Tuyến</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
</head>
<body class="bg-light">

<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-5">
    <h3 class="fw-bold mb-4 text-dark"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG CỦA BẠN</h3>

    <div class="row g-4">
        <!-- DANH SÁCH SẢN PHẨM TRONG GIỎ (BÊN TRÁI) -->
        <div class="col-12 col-lg-8">
            <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                <c:choose>
                    <c:when test="${not empty cart.chiTietGioHangList}">
                        <c:forEach var="item" items="${cart.chiTietGioHangList}">
                            <div class="row align-items-center mb-3 pb-3 border-bottom g-3">
                                <!-- Checkbox mua (Selective Checkout) -->
                                <div class="col-1 text-center">
                                    <input type="checkbox" class="form-check-input select-item-checkbox border-secondary"
                                           data-id="${item.maCtgh}" ${item.isChonMua ? 'checked' : ''} onchange="toggleCartSelection(this)">
                                </div>

                                <div class="col-2">
                                    <div class="bg-light rounded border text-center py-3">
                                        <i class="bi bi-cup-hot fs-2 text-success"></i>
                                    </div>
                                </div>

                                <div class="col-4">
                                    <strong class="text-dark d-block">SP${item.maSp} (Size ${item.maSize == 1 ? "S" : (item.maSize == 2 ? "M" : "L")})</strong>
                                    <small class="text-muted d-block" style="font-size: 11px;">Pha chế: Đá: ${item.mucDa} | Đường: ${item.mucDuong}</small>
                                    <c:if test="${not empty item.toppingGioHangList}">
                                        <div class="ps-1" style="font-size: 10.5px; color: var(--primary-color);">
                                            + Toppings: <c:forEach var="tp" items="${item.toppingGioHangList}">TP${tp.maTp} (SL:${tp.soLuongTp}) </c:forEach>
                                        </div>
                                    </c:if>
                                </div>

                                <!-- Bộ tăng giảm số lượng -->
                                <div class="col-2 text-center">
                                    <div class="d-flex align-items-center justify-content-center border rounded">
                                        <button class="btn btn-sm btn-light border-0" onclick="updateQtyAJAX(${item.maCtgh}, -1)"><i class="bi bi-dash"></i></button>
                                        <span class="fw-bold px-2.5" id="qty_${item.maCtgh}">${item.soLuong}</span>
                                        <button class="btn btn-sm btn-light border-0" onclick="updateQtyAJAX(${item.maCtgh}, 1)"><i class="bi bi-plus"></i></button>
                                    </div>
                                </div>

                                <div class="col-2 text-end fw-bold text-success">
                                    <fmt:formatNumber value="${item.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ
                                </div>

                                <div class="col-1 text-end">
                                    <a href="${pageContext.request.contextPath}/cart/delete?maCtgh=${item.maCtgh}" class="text-danger"><i class="bi bi-trash3-fill"></i></a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-cart-x fs-1 d-block mb-3 opacity-50"></i>
                            <h5>Giỏ hàng online hiện tại đang trống!</h5>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-success mt-3 fw-bold">QUAY LẠI MUA HÀNG</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- KHỐI TỔNG DOANH THU & NÚT CHUYỂN THANH TOÁN (CỘT PHẢI) -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 p-4 shadow-sm sticky-top" style="top: 80px; border-radius: 16px;">
                <h5 class="fw-bold mb-4 text-dark">THÔNG TIN GIAO DỊCH</h5>
                <div class="d-flex justify-content-between mb-3 small">
                    <span class="text-muted">Tổng tiền tạm tính:</span>
                    <strong class="text-dark" id="subtotalCart">Có chọn lọc</strong>
                </div>
                <div class="d-flex justify-content-between mb-4 small">
                    <span class="text-muted">Thuế VAT (8%):</span>
                    <strong class="text-dark">Tự động cộng</strong>
                </div>
                <hr>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <span class="fw-bold text-dark fs-6">SỐ TIỀN THANH TOÁN:</span>
                    <span class="fw-bold text-success fs-4">Đồng bộ chốt</span>
                </div>

                <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary-teapos w-100 py-3 fw-bold fs-5 shadow-sm">
                    TIẾN HÀNH ĐẶT HÀNG <i class="bi bi-arrow-right-short"></i>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    // 1. AJAX cập nhật số lượng ngay lập tức
    function updateQtyAJAX(maCtgh, delta) {
        const qtyEl = document.getElementById('qty_' + maCtgh);
        let currentQty = parseInt(qtyEl.innerText);
        let newQty = currentQty + delta;
        if (newQty < 1) return;

        fetch('${pageContext.request.contextPath}/cart/update?maCtgh=' + maCtgh + '&soLuong=' + newQty, { method: 'POST' })
            .then(res => res.text())
            .then(data => {
                if (data === 'SUCCESS') {
                    qtyEl.innerText = newQty;
                    showToast('success', 'Đã cập nhật số lượng giỏ hàng!');
                    setTimeout(() => location.reload(), 800);
                } else {
                    showToast('error', 'Cập nhật thất bại!');
                }
            });
    }

    // 2. AJAX đảo trạng thái tick chọn mua (Selective Checkout)
    function toggleCartSelection(checkbox) {
        const maCtgh = checkbox.dataset.id;
        const isChecked = checkbox.checked ? '1' : '0';

        fetch('${pageContext.request.contextPath}/cart/toggle-select?maCtgh=' + maCtgh + '&chon=' + isChecked, { method: 'POST' })
            .then(res => res.text())
            .then(data => {
                if (data === 'SUCCESS') {
                    showToast('success', 'Đã lưu lựa chọn đặt đồ uống!');
                    setTimeout(() => location.reload(), 800);
                }
            });
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('msg') === 'deletesuccess') showToast('success', 'Đã xóa trà sữa khỏi giỏ hàng!');
    });
</script>
</body>
</html>
