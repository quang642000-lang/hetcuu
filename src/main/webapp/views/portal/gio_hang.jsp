<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
                                <!-- Checkbox chọn mua -->
                                <div class="col-1 text-center">
                                    <input type="checkbox" class="form-check-input select-item-checkbox border-secondary"
                                           data-id="${item.maCtgh}" ${item.isChonMua ? 'checked' : ''} onchange="toggleCartSelection(this)">
                                </div>
                                <!-- Hình ảnh đồ uống thực tế -->
                                <div class="col-2">
                                    <c:choose>
                                        <c:when test="${not empty item.hinhAnh}">
                                            <img src="${item.hinhAnh}" class="w-100 rounded border shadow-sm" style="height: 70px; object-fit: cover;">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="bg-light rounded border text-center py-3" style="height: 70px;">
                                                <i class="bi bi-cup-hot fs-2 text-success"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <!-- Tên trà sữa và size nạp từ SQL -->
                                <div class="col-4">
                                    <strong class="text-dark d-block" style="font-size: 15px;"><c:out value="${item.tenSp}"/> (Size ${item.maSize == 1 ? "S" : (item.maSize == 2 ? "M" : "L")})</strong>
                                    <small class="text-muted d-block" style="font-size: 11px;">Đá: ${item.mucDa} | Đường: ${item.mucDuong}</small>
                                    <c:if test="${not empty item.toppingGioHangList}">
                                        <div class="ps-1 mt-1" style="font-size: 11px; color: var(--primary-color);">
                                            <i class="bi bi-patch-plus"></i> Toppings:
                                            <c:forEach var="tp" items="${item.toppingGioHangList}" varStatus="loop">
                                                TP${tp.maTp} (x${tp.soLuongTp})${!loop.last ? ', ' : ''}
                                            </c:forEach>
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
                                <!-- Thành tiền -->
                                <div class="col-2 text-end fw-bold text-success">
                                    <fmt:formatNumber value="${item.giaBan * item.soLuong}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                </div>
                                <div class="col-1 text-end">
                                    <a href="${pageContext.request.contextPath}/cart/delete?maCtgh=${item.maCtgh}" class="text-danger fs-5"><i class="bi bi-trash3-fill"></i></a>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-cart-x fs-1 d-block mb-3 opacity-50 text-success"></i>
                            <h5>Giỏ hàng trực tuyến của quý khách đang trống!</h5>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-success mt-3 fw-bold">XEM MENU ĐẶT MÓN</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <!-- KHỐI TỔNG DOANH THU & NÚT THANH TOÁN (CỘT PHẢI) -->
        <div class="col-12 col-lg-4">
            <div class="card border-0 p-4 shadow-sm sticky-top" style="top: 80px; border-radius: 16px;">
                <h5 class="fw-bold mb-4 text-dark">THÔNG TIN GIAO DỊCH</h5>
                <div class="d-flex justify-content-between mb-3 small">
                    <span class="text-muted">Tổng tiền cốc & Toppings:</span>
                    <strong class="text-dark" id="subtotalCart">Tự động chốt</strong>
                </div>
                <div class="d-flex justify-content-between mb-4 small">
                    <span class="text-muted">Thuế VAT (8%):</span>
                    <strong class="text-dark">Tự động cộng</strong>
                </div>
                <hr>
                <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary-teapos w-100 py-3 fw-bold fs-5 shadow-sm rounded-3">
                    TIẾN HÀNH ĐẶT HÀNG <i class="bi bi-arrow-right-short"></i>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />
<script>
    function updateQtyAJAX(maCtgh, delta) {
        const qtyEl = document.getElementById('qty_' + maCtgh);
        let currentQty = parseInt(qtyEl.innerText);
        let newQty = currentQty + delta;
        if (newQty < 1) return;

        fetch('${pageContext.request.contextPath}/cart/update?maCtgh=' + maCtgh + '&soLuong=' + newQty, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(res => res.text())
            .then(data => {
                if (data === 'SUCCESS') {
                    qtyEl.innerText = newQty;
                    showToast('success', 'Đã cập nhật số lượng giỏ hàng!');
                    setTimeout(() => location.reload(), 600);
                } else {
                    showToast('error', 'Cập nhật thất bại!');
                }
            });
    }

    function toggleCartSelection(checkbox) {
        const maCtgh = checkbox.dataset.id;
        const isChecked = checkbox.checked ? '1' : '0';
        fetch('${pageContext.request.contextPath}/cart/toggle-select?maCtgh=' + maCtgh + '&chon=' + isChecked, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(res => res.text())
            .then(data => {
                if (data === 'SUCCESS') {
                    showToast('success', 'Đã lưu lựa chọn đặt hàng!');
                    setTimeout(() => location.reload(), 600);
                }
            });
    }
</script>
</body>
</html>
