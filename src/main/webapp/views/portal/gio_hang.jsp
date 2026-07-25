<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Giỏ Hàng Thành Viên CRM</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .cart-card {
            border-radius: 16px;
            background: #ffffff;
            border: none;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }
        .cart-item-row {
            transition: all 0.2s ease;
            border-radius: 12px;
            padding: 15px;
            background: #ffffff;
            border: 1px solid #f1f5f9;
        }
        .cart-item-row:hover {
            border-color: #10b981;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.05);
        }
        .item-image {
            width: 76px;
            height: 76px;
            object-fit: cover;
            border-radius: 10px;
        }
        .qty-btn {
            width: 28px;
            height: 28px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50% !important;
            padding: 0 !important;
            font-size: 14px;
        }
        .custom-checkbox {
            width: 20px;
            height: 20px;
            border-color: #cbd5e1;
            cursor: pointer;
        }
        .custom-checkbox:checked {
            background-color: #10b981;
            border-color: #10b981;
        }
        .sticky-summary {
            top: 80px;
            border-radius: 16px;
            border: none;
            background: #ffffff;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />
<div class="container py-5">
    <h3 class="fw-bold mb-4 text-dark text-start"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG CỦA BẠN</h3>
    <div class="row g-4">
        <!-- DANH SÁCH SẢN PHẨM TRONG GIỎ (BÊN TRÁI) -->
        <div class="col-12 col-lg-8">
            <div class="card cart-card p-4 text-start">
                <c:choose>
                    <c:when test="${not empty cart.chiTietGioHangList}">
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="item" items="${cart.chiTietGioHangList}">
                                <!-- Tính tổng giá toppings của ly trà sữa hiện tại -->
                                <c:set var="toppingSum" value="0"/>
                                <c:forEach var="tp" items="${item.toppingGioHangList}">
                                    <c:set var="toppingSum" value="${toppingSum + (tp.giaTp * tp.soLuongTp)}"/>
                                </c:forEach>
                                <c:set var="itemUnitTotal" value="${item.giaBan + toppingSum}"/>
                                <c:set var="itemRowTotal" value="${itemUnitTotal * item.soLuong}"/>

                                <!-- KHUNG SẢN PHẨM ĐẤU NỐI JS ĐỘNG CHO PHÉP TÍNH TOÁN REALTIME KHÔNG RELOAD -->
                                <div class="cart-item-row d-flex align-items-center gap-3"
                                     id="cart_row_${item.maCtgh}"
                                     data-ctgh="${item.maCtgh}"
                                     data-unit-price="${itemUnitTotal}">

                                    <!-- Checkbox Chọn mua -->
                                    <div class="flex-shrink-0">
                                        <input type="checkbox" class="form-check-input custom-checkbox"
                                               id="chk_${item.maCtgh}"
                                            ${item.isChonMua() ? 'checked' : ''}
                                               onchange="toggleCartSelectionRealtime(${item.maCtgh})">
                                    </div>

                                    <!-- Ảnh sản phẩm -->
                                    <div class="flex-shrink-0">
                                        <c:choose>
                                            <c:when test="${not empty item.hinhAnh}">
                                                <img src="${item.hinhAnh}" class="item-image border shadow-sm" alt="Beverage">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="bg-light rounded border text-center d-flex align-items-center justify-content-center item-image">
                                                    <i class="bi bi-cup-hot fs-2 text-success"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Thông tin cốc nước, size & toppings -->
                                    <div class="flex-grow-1 text-start">
                                        <h6 class="fw-bold mb-1 text-dark" style="font-size: 15px;">
                                            <c:out value="${item.tenSp}"/>
                                            <span class="badge bg-success bg-opacity-10 text-success border border-success ms-1" style="font-size:10px; border-radius:4px;">Size ${item.tenSize}</span>
                                        </h6>
                                        <div class="d-flex flex-wrap gap-1.5 mb-1.5">
                                            <span class="badge bg-light text-muted border" style="font-size:10.5px;">Đá: ${item.mucDa}</span>
                                            <span class="badge bg-light text-muted border" style="font-size:10.5px;">Đường: ${item.mucDuong}</span>
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
                                        <c:if test="${not empty item.ghiChuMon && item.ghiChuMon ne 'Quick Add' && item.ghiChuMon ne 'Normal'}">
                                            <small class="text-danger d-block mt-1" style="font-size: 11px; font-style: italic;">
                                                <i class="bi bi-pencil-fill"></i> Ghi chú: <c:out value="${item.ghiChuMon}"/>
                                            </small>
                                        </c:if>
                                    </div>

                                    <!-- Điều phối Số lượng & Giá trị -->
                                    <div class="flex-shrink-0 text-center d-flex flex-column align-items-end gap-2" style="min-width: 120px;">
                                        <!-- Nút chỉnh số lượng -->
                                        <div class="d-flex align-items-center justify-content-center border rounded bg-light p-0.5">
                                            <button type="button" class="btn btn-sm btn-light border-0 qty-btn shadow-none" onclick="updateCartQtyRealtime(${item.maCtgh}, -1)"><i class="bi bi-dash"></i></button>
                                            <span class="fw-bold px-3 text-dark font-monospace" id="qty_${item.maCtgh}" style="font-size: 14px;">${item.soLuong}</span>
                                            <button type="button" class="btn btn-sm btn-light border-0 qty-btn text-success shadow-none" onclick="updateCartQtyRealtime(${item.maCtgh}, 1)"><i class="bi bi-plus"></i></button>
                                        </div>
                                        <!-- Thành tiền dòng -->
                                        <div class="fw-bold text-success font-monospace" id="line_total_${item.maCtgh}" style="font-size: 14px;">
                                            <fmt:formatNumber value="${itemRowTotal}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                        </div>
                                    </div>

                                    <!-- Thao tác Sửa / Xóa -->
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
                            <a href="${pageContext.request.contextPath}/products" class="btn btn-success mt-3 fw-bold px-4 rounded-pill">XEM MENU ĐẶT MÓN NGAY</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- KHỐI THANH TOÁN (CỘT PHẢI) -->
        <div class="col-12 col-lg-4">
            <div class="card sticky-summary p-4 shadow-sm text-start">
                <h5 class="fw-bold mb-4 text-dark border-bottom pb-2">THÔNG TIN ĐƠN ĐẶT</h5>
                <c:choose>
                    <c:when test="${not empty cart.chiTietGioHangList}">
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
<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    // HÀM ĐỊNH DẠNG TIỀN VNĐ CHO ĐỒNG BỘ JS REALTIME
    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
    }

    // THUẬT TOÁN TÍNH TOÁN TIỀN REALTIME HOÀN TOÀN TRÊN CLIENT (Chống lag và reload trang đột ngột)
    function recalculatePortalCartTotals() {
        let subtotal = 0;
        const rows = document.querySelectorAll('.cart-item-row');

        rows.forEach(row => {
            const maCtgh = row.dataset.ctgh;
            const unitPrice = parseInt(row.dataset.unitPrice) || 0;
            const qtySpan = document.getElementById('qty_' + maCtgh);
            const qty = parseInt(qtySpan.innerText) || 0;
            const checkbox = document.getElementById('chk_' + maCtgh);

            // Cập nhật giá chốt dòng nước
            const lineTotal = unitPrice * qty;
            const lineTotalEl = document.getElementById('line_total_' + maCtgh);
            if (lineTotalEl) {
                lineTotalEl.innerText = formatVND(lineTotal);
            }

            // Nếu được chọn mua, cộng dồn vào tổng hóa đơn
            if (checkbox && checkbox.checked) {
                subtotal += lineTotal;
            }
        });

        const vat = Math.round(subtotal * 0.08);
        const total = subtotal + vat;

        // Cập nhật lên dải hiển thị tóm tắt thanh toán
        const subtotalEl = document.getElementById('subtotalCart');
        const vatEl = document.getElementById('vatCart');
        const totalEl = document.getElementById('finalPayableCart');
        const checkoutBtn = document.getElementById('checkoutBtn');

        if (subtotalEl) subtotalEl.innerText = formatVND(subtotal);
        if (vatEl) vatEl.innerText = formatVND(vat);
        if (totalEl) totalEl.innerText = formatVND(total);

        // Khóa/Mở khóa nút chốt đơn dựa trên dữ liệu thật
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

    // AJAX CẬP NHẬT TĂNG GIẢM SỐ LƯỢNG KHÔNG REBOOT TRANG (Buttery Smooth!)
    function updateCartQtyRealtime(maCtgh, delta) {
        const qtySpan = document.getElementById('qty_' + maCtgh);
        if (!qtySpan) return;

        let currentQty = parseInt(qtySpan.innerText) || 1;
        let newQty = currentQty + delta;

        if (newQty < 1) {
            confirmDeleteCartItem(maCtgh);
            return;
        }

        // ĐỔI HIỂN THỊ TỨC THÌ (Instant UI Update)
        qtySpan.innerText = newQty;
        recalculatePortalCartTotals();

        // Đồng bộ ngầm lên Server
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
                    // Nếu lỗi ngầm, rollback lại số lượng và báo động đỏ
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

    // AJAX THAY ĐỔI TRẠNG THÁI TICK CHỌN MUA SILENT (Chạy mượt sần sật)
    function toggleCartSelectionRealtime(maCtgh) {
        const checkbox = document.getElementById('chk_' + maCtgh);
        if (!checkbox) return;

        // Tính toán lại tổng tiền tức thì
        recalculatePortalCartTotals();

        const isChecked = checkbox.checked ? '1' : '0';

        // Đồng bộ ngầm lên Server
        fetch('${pageContext.request.contextPath}/cart/toggle-select?maCtgh=' + maCtgh + '&chon=' + isChecked, {
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
                    // Rollback nếu sập máy chủ
                    checkbox.checked = !checkbox.checked;
                    recalculatePortalCartTotals();
                    showToast('error', 'Đồng bộ danh sách thanh toán thất bại!');
                }
            })
            .catch(err => {
                checkbox.checked = !checkbox.checked;
                recalculatePortalCartTotals();
                console.error('Lỗi sync chọn mua:', err);
            });
    }

    // SWEETALERT2: Xóa món trong giỏ hàng cực đẹp
    function confirmDeleteCartItem(maCtgh) {
        Swal.fire({
            title: 'Gỡ món khỏi giỏ hàng?',
            text: 'Bạn có chắc chắn muốn gỡ cốc nước này và toàn bộ topping đi kèm khỏi giỏ hàng của mình?',
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

    // KÍCH HOẠT LẦN ĐẦU TIÊN KHI NẠP TRANG
    document.addEventListener("DOMContentLoaded", function() {
        recalculatePortalCartTotals();

        // Nạp thông điệp nếu có
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        if (msg === 'deletesuccess') showToast('success', 'Đã gỡ cốc nước thành công!');
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