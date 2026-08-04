<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Giỏ Hàng Thành Viên CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/portal.css" rel="stylesheet">
</head>
<body class="bg-light">
<!-- NAV HEADER -->
<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-4">
    <h3 class="fw-bold mb-4 text-dark text-start"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG CỦA BẠN</h3>
    <div class="row g-4">
        <!-- DANH SÁCH SẢN PHẨM TRONG GIỎ (BÊN TRÁI) -->
        <div class="col-12 col-lg-8">
            <div class="card cart-card p-4 text-start border-0">
                <c:choose>
                    <c:when test="${not empty cart.getChiTietGioHangList()}">
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="item" items="${cart.getChiTietGioHangList()}">
                                <c:set var="toppingSum" value="0"/>
                                <c:forEach var="tp" items="${item.toppingGioHangList}">
                                    <c:set var="toppingSum" value="${toppingSum + (tp.giaTp * tp.soLuongTp)}"/>
                                </c:forEach>
                                <c:set var="itemUnitTotal" value="${item.giaBan + toppingSum}"/>
                                <c:set var="itemRowTotal" value="${itemUnitTotal * item.soLuong}"/>

                                <!-- ITEM ROW WITH INTEGRATED RESPONSIVE CLASSES -->
                                <div class="cart-item-row d-flex align-items-center gap-3 shadow-sm"
                                     id="cart_row_${item.maCtgh}"
                                     data-ctgh="${item.maCtgh}"
                                     data-unit-price="${itemUnitTotal}">
                                    <!-- Checkbox Chọn mua -->
                                    <div class="flex-shrink-0">
                                        <input type="checkbox" class="form-check-input custom-checkbox"
                                               id="chk_${item.maCtgh}"
                                            ${item.isChonMua() ? 'checked' : ''}
                                               onchange="toggleSelectCartItem(${item.maCtgh}, this)">
                                    </div>

                                    <!-- Ảnh sản phẩm -->
                                    <div class="flex-shrink-0">
                                        <c:choose>
                                            <c:when test="${not empty item.sanPham.hinhAnh}">
                                                <img src="${item.sanPham.hinhAnh}" class="item-image border shadow-sm" alt="Beverage">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="bg-light rounded border text-center d-flex align-items-center justify-content-center item-image">
                                                    <i class="bi bi-cup-hot fs-2 text-success"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Thông tin chi tiết, size & toppings -->
                                    <div class="flex-grow-1 text-start">
                                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 15px;">
                                            <c:out value="${item.sanPham.tenSp}"/>
                                            <span class="badge bg-success bg-opacity-10 text-success border border-success ms-1" style="font-size:10px; border-radius:4px;">Size ${item.tenSize}</span>
                                        </h6>
                                        <div class="d-flex flex-wrap gap-1.5 mb-1.5">
                                            <c:if test="${item.sanPham.choPhepDoiDa}">
                                                <span class="badge bg-light text-muted border" style="font-size:10.5px;">Đá: ${item.mucDa}</span>
                                            </c:if>
                                            <c:if test="${item.sanPham.choPhepDoiDuong}">
                                                <span class="badge bg-light text-muted border" style="font-size:10.5px;">Đường: ${item.mucDuong}</span>
                                            </c:if>
                                        </div>
                                        <!-- Toppings list -->
                                        <c:if test="${not empty item.toppingGioHangList}">
                                            <div class="ps-1 mt-1 small text-success d-flex flex-wrap gap-1 align-items-center" style="font-size: 11px;">
                                                <i class="bi bi-patch-plus"></i> Toppings:
                                                <c:forEach var="tp" items="${item.toppingGioHangList}" varStatus="loop">
                                                        <span class="text-success fw-bold">
                                                            <c:out value="${not empty tp.tenTp ? tp.tenTp : 'Topping #' += tp.maTp}"/> (x${tp.soLuongTp})
                                                        </span>${!loop.last ? ',' : ''}
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                        <!-- Ghi chú riêng -->
                                        <c:if test="${not empty item.ghiChuMon && item.ghiChuMon ne 'Quick Add' && item.ghiChuMon ne 'Normal' && item.ghiChuMon ne ''}">
                                            <small class="text-danger d-block mt-1" style="font-size: 11px; font-style: italic;">
                                                <i class="bi bi-pencil-fill"></i> Ghi chú: <c:out value="${item.ghiChuMon}"/>
                                            </small>
                                        </c:if>
                                    </div>

                                    <!-- Điều phối Số lượng & Giá trị (Bottom row in Mobile) -->
                                    <div class="flex-shrink-0 text-center d-flex flex-column align-items-end gap-2" style="min-width: 120px;">
                                        <div class="d-flex align-items-center justify-content-center border rounded bg-light p-0.5">
                                            <button type="button" class="btn btn-sm btn-light border-0 qty-btn shadow-none" onclick="updateCartQtyRealtime(${item.maCtgh}, -1)"><i class="bi bi-dash"></i></button>
                                            <span class="fw-bold px-3 text-dark font-monospace" id="qty_${item.maCtgh}" style="font-size: 14px;">${item.soLuong}</span>
                                            <button type="button" class="btn btn-sm btn-light border-0 qty-btn text-success shadow-none" onclick="updateCartQtyRealtime(${item.maCtgh}, 1)"><i class="bi bi-plus"></i></button>
                                        </div>
                                        <div class="fw-bold text-success font-monospace" id="line_total_${item.maCtgh}" style="font-size: 14.5px;">
                                            <fmt:formatNumber value="${itemRowTotal}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                        </div>
                                    </div>

                                    <!-- Thao tác Sửa / Xóa (Absolute layout top-right on Mobile) -->
                                    <div class="flex-shrink-0 d-flex flex-column gap-2 justify-content-center border-start ps-3 align-self-stretch" style="width: 44px;">
                                        <a href="${pageContext.request.contextPath}/product/detail?id=${item.maSp}&maCtgh=${item.maCtgh}" class="text-primary fs-5" title="Sửa tùy chọn pha chế"><i class="bi bi-pencil-square"></i></a>
                                        <button type="button" class="btn btn-link text-danger fs-5 p-0 border-0 shadow-none" title="Xóa món" onclick="confirmDeleteCartItem(${item.maCtgh})"><i class="bi bi-trash3-fill"></i></button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-cart-x fs-1 d-block mb-3 opacity-50 text-success"></i>
                            <h5 class="fw-bold text-dark">Giỏ hàng trực tuyến của bạn đang trống!</h5>
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-success mt-3 fw-bold px-4 rounded-pill btn-primary-teapos" style="border:none;">XEM MENU ĐẶT MÓN NGAY</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- KHỐI THANH TOÁN (CỘT PHẢI) -->
        <div class="col-12 col-lg-4">
            <div class="card sticky-summary p-4 shadow-sm text-start border-0" style="border-radius: 16px; border: 1px solid var(--border-color) !important;">
                <h5 class="fw-bold mb-4 text-dark border-bottom pb-2">THÔNG TIN ĐƠN ĐẶT</h5>
                <c:choose>
                    <c:when test="${not empty cart.getChiTietGioHangList()}">
                        <div class="d-flex flex-column gap-3">
                            <div class="d-flex justify-content-between align-items-center small">
                                <span class="text-muted">Tổng tiền cốc & Toppings:</span>
                                <strong class="text-dark fs-6 font-monospace" id="subtotalCart">0 đ</strong>
                            </div>
                            <div class="d-flex justify-content-between align-items-center small">
                                <span class="text-muted">Thuế VAT (8%):</span>
                                <strong class="text-dark font-monospace" id="vatCart">0 đ</strong>
                            </div>
                            <hr class="my-1 border-dashed">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="fw-bold text-dark" style="font-size: 15px;">THÀNH TIỀN THU (VNĐ):</span>
                                <span class="fw-bold text-danger fs-4 font-monospace" id="finalPayableCart">0 đ</span>
                            </div>
                            <div id="checkoutBtnContainer">
                                <a href="${pageContext.request.contextPath}/checkout"
                                   id="checkoutBtn"
                                   class="btn btn-primary-teapos w-100 py-3 fw-bold fs-5 shadow-sm rounded-3">
                                    TIẾN HÀNH ĐẶT HÀNG <i class="bi bi-arrow-right-short"></i>
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-4 text-muted small">
                            Vui lòng chọn mua ít nhất một cốc nước trong giỏ hàng để tiến hành chốt hóa đơn.
                        </div>
                        <button class="btn btn-secondary w-100 py-3 fw-bold fs-5 rounded-3" disabled>
                            TIẾN HÀNH ĐẶT HÀNG
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- FOOTER -->
<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
    }

    function recalculatePortalCartTotals() {
        let subtotal = 0;
        document.querySelectorAll('.cart-item-row').forEach(row => {
            const id = row.dataset.ctgh;
            const unitPrice = parseInt(row.dataset.unitPrice) || 0;
            const qtySpan = document.getElementById('qty_' + id);
            const qty = qtySpan ? (parseInt(qtySpan.innerText) || 1) : 1;
            const lineTotal = unitPrice * qty;
            const checkbox = document.getElementById('chk_' + id);

            const lineTotalEl = document.getElementById('line_total_' + id);
            if (lineTotalEl) {
                lineTotalEl.innerText = formatVND(lineTotal);
            }
            if (checkbox && checkbox.checked) {
                subtotal += lineTotal;
            }
        });

        const vat = Math.round(subtotal * 0.08);
        const total = subtotal + vat;

        const subtotalEl = document.getElementById('subtotalCart');
        const vatEl = document.getElementById('vatCart');
        const totalEl = document.getElementById('finalPayableCart');
        const checkoutBtn = document.getElementById('checkoutBtn');

        if (subtotalEl) subtotalEl.innerText = formatVND(subtotal);
        if (vatEl) vatEl.innerText = formatVND(vat);
        if (totalEl) totalEl.innerText = formatVND(total);

        if (checkoutBtn) {
            if (subtotal <= 0) {
                checkoutBtn.setAttribute('href', 'javascript:void(0)');
                checkoutBtn.classList.remove('btn-primary-teapos');
                checkoutBtn.classList.add('btn-secondary', 'disabled');
                checkoutBtn.innerHTML = 'CHƯA CHỌN MÓN';
            } else {
                checkoutBtn.setAttribute('href', '${pageContext.request.contextPath}/checkout');
                checkoutBtn.classList.add('btn-primary-teapos');
                checkoutBtn.classList.remove('btn-secondary', 'disabled');
                checkoutBtn.innerHTML = 'TIẾN HÀNH ĐẶT HÀNG <i class="bi bi-arrow-right-short"></i>';
            }
        }
    }

    function updateCartQtyRealtime(maCtgh, delta) {
        const qtySpan = document.getElementById('qty_' + maCtgh);
        if (!qtySpan) return;
        let currentQty = parseInt(qtySpan.innerText) || 1;
        let newQty = currentQty + delta;
        if (newQty < 1) {
            confirmDeleteCartItem(maCtgh);
            return;
        }
        qtySpan.innerText = newQty;
        recalculatePortalCartTotals();

        fetch('${pageContext.request.contextPath}/cart/update?maCtgh=' + maCtgh + '&soLuong=' + newQty, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(res => {
                if (res.status === 401) {
                    window.location.href = '${pageContext.request.contextPath}/customer/login';
                    throw new Error('SESSION_EXPIRED');
                }
                return res.text();
            })
            .then(data => {
                if (data.trim() !== 'SUCCESS') {
                    qtySpan.innerText = currentQty;
                    recalculatePortalCartTotals();
                    showToast('error', 'Không thể đồng bộ số lượng lên máy chủ!');
                }
            })
            .catch(err => {
                qtySpan.innerText = currentQty;
                recalculatePortalCartTotals();
                console.error('Lỗi sync giỏ hàng:', err);
            });
    }

    function confirmDeleteCartItem(maCtgh) {
        Swal.fire({
            title: 'Gỡ món khỏi giỏ hàng?',
            text: 'Bạn có chắc chắn muốn gỡ ly nước này và toàn bộ topping đi kèm khỏi giỏ hàng của mình?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#ef4444',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý xóa',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                window.location.href = '${pageContext.request.contextPath}/cart/delete?maCtgh=' + maCtgh;
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        recalculatePortalCartTotals();
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'deletesuccess') showToast('success', 'Đã gỡ ly nước thành công!');
        if (msg === 'updatesuccess') showToast('success', 'Đã cập nhật tùy chọn thành công!');
        if (msg === 'invalid_checkout_session') {
            Swal.fire({
                icon: 'warning',
                title: 'Đơn hàng đã được chốt!',
                text: 'Giao dịch này đã được thanh toán hoặc hết phiên làm việc. Trình duyệt đã chuyển về trạng thái an toàn.',
                confirmButtonColor: '#10b981'
            });
        }
    });
</script>
</body>
</html>
