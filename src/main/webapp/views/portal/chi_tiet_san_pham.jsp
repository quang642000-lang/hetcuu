<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Cấu Hình Pha Chế Đồ Uống</title>
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
    <div class="row g-5">
        <!-- ẢNH ĐỒ UỐNG BÊN TRÁI -->
        <div class="col-12 col-md-5">
            <div class="sticky-top" style="top: 80px;">
                <img src="${not empty product.hinhAnh ? product.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded-4 shadow-sm border" style="object-fit: cover; max-height: 480px;" alt="Tea">
            </div>
        </div>
        <!-- BẢNG TÙY BIẾN PHA CHẾ BÊN PHẢI -->
        <div class="col-12 col-md-7">
            <div class="card p-4 border-0 shadow-sm bg-white" style="border-radius: 16px;">
                <span class="badge bg-success bg-opacity-10 text-success border border-success mb-2 px-3 py-1.5 fw-bold text-uppercase d-inline-block" style="max-width: fit-content;">Mã đồ uống: ${product.maSp}</span>
                <h2 class="fw-bold mb-2 text-dark"><c:out value="${product.tenSp}"/></h2>
                <p class="text-muted mb-4"><c:out value="${product.moTa}"/></p>
                <form id="addToCartForm" action="${pageContext.request.contextPath}/cart/add" method="POST">
                    <input type="hidden" name="maSp" value="${product.maSp}">
                    <!-- Truyền ID chi tiết giỏ hàng nếu đang sửa -->
                    <c:if test="${not empty editItem}">
                        <input type="hidden" name="maCtgh" value="${editItem.maCtgh}">
                    </c:if>
                    <!-- 1. CHỌN SIZE -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-dark d-block">1. Chọn kích cỡ cốc nước <span class="text-danger">*</span></label>
                        <div class="row g-2">
                            <c:forEach var="size" items="${sizes}" varStatus="loop">
                                <c:set var="isSizeChecked" value="false"/>
                                <c:choose>
                                    <c:when test="${not empty editItem}">
                                        <c:if test="${editItem.maSize == size.maSize}">
                                            <c:set var="isSizeChecked" value="true"/>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${loop.first}">
                                            <c:set var="isSizeChecked" value="true"/>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                                <div class="col-4">
                                    <input type="radio" class="btn-check" name="maSize" id="size_${size.maSize}" value="${size.maSize}" data-price="${size.giaBan}" ${isSizeChecked == 'true' ? 'checked' : ''} onchange="calculateRealtimeTotal()">
                                    <label class="btn btn-outline-success py-2.5 w-100 text-center fw-bold" for="size_${size.maSize}">
                                        Size ${size.tenSize == '1' ? "S" : (size.tenSize == '2' ? "M" : (size.tenSize == '3' ? "L" : size.tenSize))} <br>
                                        <small class="text-muted fw-normal" style="font-size: 11px;">+<fmt:formatNumber value="${size.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</small>
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <!-- 2. ĐÁ & ĐƯỜNG -->
                    <div class="row g-3 mb-4">
                        <c:if test="${product.choPhepDoiDa}">
                            <div class="col-6">
                                <label for="mucDa" class="form-label fw-bold text-dark small">2. Mức độ đá</label>
                                <select class="form-select form-control-teapos" id="mucDa" name="mucDa" onchange="calculateRealtimeTotal()">
                                    <option value="100%" ${editItem.mucDa eq '100%' ? 'selected' : ''}>100% Đá (Mặc định)</option>
                                    <option value="70%" ${editItem.mucDa eq '70%' ? 'selected' : ''}>70% Đá (Ít đá)</option>
                                    <option value="50%" ${editItem.mucDa eq '50%' ? 'selected' : ''}>50% Đá</option>
                                    <option value="0%" ${editItem.mucDa eq '0%' ? 'selected' : ''}>0% Đá (Không đá)</option>
                                </select>
                            </div>
                        </c:if>
                        <c:if test="${product.choPhepDoiDuong}">
                            <div class="col-6">
                                <label for="mucDuong" class="form-label fw-bold text-dark small">3. Mức độ đường</label>
                                <select class="form-select form-control-teapos" id="mucDuong" name="mucDuong" onchange="calculateRealtimeTotal()">
                                    <option value="100%" ${editItem.mucDuong eq '100%' ? 'selected' : ''}>100% Đường (Mặc định)</option>
                                    <option value="70%" ${editItem.mucDuong eq '70%' ? 'selected' : ''}>70% Đường (Ít ngọt)</option>
                                    <option value="50%" ${editItem.mucDuong eq '50%' ? 'selected' : ''}>50% Đường</option>
                                    <option value="0%" ${editItem.mucDuong eq '0%' ? 'selected' : ''}>0% Đường (Không ngọt)</option>
                                </select>
                            </div>
                        </c:if>
                    </div>
                    <!-- 3. TOPPING (NÂNG CẤP ĐỘNG CÓ SỐ LƯỢNG SPINNER VÀ HÌNH ẢNH) -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-dark d-block">4. Thêm Topping dai giòn sần sật (Có thể chọn nhiều phần)</label>
                        <div class="row g-2">
                            <c:forEach var="tp" items="${toppings}">
                                <c:set var="isTpChecked" value="false"/>
                                <c:set var="tpQty" value="1"/>
                                <c:if test="${not empty editItem}">
                                    <c:forEach var="et" items="${editItem.toppingGioHangList}">
                                        <c:if test="${et.maTp == tp.maTp}">
                                            <c:set var="isTpChecked" value="true"/>
                                            <c:set var="tpQty" value="${et.soLuongTp}"/>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <div class="col-12 col-md-6">
                                    <div class="border rounded p-2.5 d-flex justify-content-between align-items-center bg-white shadow-sm">
                                        <div class="form-check mb-0 d-flex align-items-center flex-grow-1">
                                            <!-- BỌC MÃ TOPPING CHUỖI TRONG NHÁY ĐƠN TRÊN ONCHANGE CHỐNG LỖI CÚ PHÁP -->
                                            <input class="form-check-input topping-check border-secondary me-2" type="checkbox" name="toppings[]" id="tp_${tp.maTp}" value="${tp.maTp}" data-price="${tp.giaBan}" onchange="toggleWebToppingQty('${tp.maTp}')" ${isTpChecked == 'true' ? 'checked' : ''}>
                                            <label class="form-check-label fw-semibold text-dark small" for="tp_${tp.maTp}">
                                                <c:out value="${tp.tenTp}"/> <br>
                                                <span class="text-success fw-bold font-monospace small">+<fmt:formatNumber value="${tp.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</span>
                                            </label>
                                        </div>
                                        <!-- Spinner tăng giảm số lượng topping - BỌC MÃ TOPPING CHUỖI TRONG NHÁY ĐƠN TRÊN ONCLICK -->
                                        <div class="input-group input-group-sm" id="web_tp_qty_container_${tp.maTp}" style="${isTpChecked == 'true' ? 'display: flex !important;' : 'display: none !important;'}">
                                            <button type="button" class="btn btn-outline-secondary px-2 py-0 border-opacity-50" onclick="adjustWebToppingQty('${tp.maTp}', -1)">-</button>
                                            <input type="text" id="web_tp_qty_${tp.maTp}" name="topping_qty_${tp.maTp}" class="form-control text-center p-0 fw-bold border-secondary border-opacity-25" value="${tpQty}" readonly style="font-size: 11px; height: 24px; background-color: #ffffff;">
                                            <button type="button" class="btn btn-outline-secondary px-2 py-0 text-success border-opacity-50" onclick="adjustWebToppingQty('${tp.maTp}', 1)">+</button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <!-- 4. GHI CHÚ -->
                    <div class="mb-4">
                        <label for="ghiChuMon" class="form-label fw-bold text-dark small">5. Ghi chú của bạn cho thợ pha chế</label>
                        <textarea class="form-control" id="ghiChuMon" name="ghiChuMon" rows="2" placeholder="Ví dụ: Mang ly đá riêng, bọc kỹ màng nhôm mang đi xa..."><c:out value="${not empty editItem ? editItem.ghiChuMon : ''}"/></textarea>
                    </div>
                    <!-- 5. TỔNG TIỀN VÀ SỐ LƯỢNG -->
                    <div class="d-flex align-items-center justify-content-between border-top pt-4 mb-4">
                        <div>
                            <span class="text-muted d-block small fw-medium">Tổng giá trị cốc nước:</span>
                            <span class="fw-bold text-success fs-3" id="displayTotal">0 đ</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <button type="button" class="btn btn-outline-secondary px-3 py-2" onclick="adjustQty(-1)"><i class="bi bi-dash-lg"></i></button>
                            <input type="number" id="qtyInput" name="soLuong" class="form-control text-center fw-bold fs-5 px-0" value="${not empty editItem ? editItem.soLuong : 1}" min="1" readonly style="width: 55px; border: 0; background: transparent;">
                            <button type="button" class="btn btn-outline-secondary px-3 py-2" onclick="adjustQty(1)"><i class="bi bi-plus-lg"></i></button>
                        </div>
                    </div>
                    <!-- BỘ ĐÔI NÚT SONG HÀNH -->
                    <div class="row g-3">
                        <c:choose>
                            <c:when test="${not empty editItem}">
                                <div class="col-12">
                                    <button type="button" class="btn btn-success w-100 py-3 fw-bold fs-5 rounded-3 d-flex align-items-center justify-content-center gap-2" onclick="handleCartAction('edit')">
                                        <i class="bi bi-check-circle-fill"></i> CẬP NHẬT GIỎ HÀNG
                                    </button>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="col-6">
                                    <button type="button" class="btn btn-outline-success w-100 py-3 fw-bold fs-5 rounded-3 d-flex align-items-center justify-content-center gap-2" onclick="handleCartAction('add')">
                                        <i class="bi bi-bag-plus-fill"></i> THÊM VÀO GIỎ
                                    </button>
                                </div>
                                <div class="col-6">
                                    <button type="button" class="btn btn-success w-100 py-3 fw-bold fs-5 rounded-3 d-flex align-items-center justify-content-center gap-2" onclick="handleCartAction('buy')">
                                        <i class="bi bi-cart-check-fill"></i> MUA NGAY ⚡
                                    </button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/views/layout/footer_portal.jsp" />
<script>
    // Bật/tắt ô số lượng topping ngoài Web
    function toggleWebToppingQty(maTp) {
        const chk = document.getElementById('tp_' + maTp);
        const container = document.getElementById('web_tp_qty_container_' + maTp);
        const qtyInput = document.getElementById('web_tp_qty_' + maTp);
        if (chk && container && qtyInput) {
            if (chk.checked) {
                container.style.setProperty('display', 'flex', 'important');
                qtyInput.value = 1;
            } else {
                container.style.setProperty('display', 'none', 'important');
                qtyInput.value = 1;
            }
        }
        calculateRealtimeTotal();
    }
    // Điều chỉnh số lượng topping ngoài Web
    function adjustWebToppingQty(maTp, delta) {
        const qtyInput = document.getElementById('web_tp_qty_' + maTp);
        if (qtyInput) {
            let val = parseInt(qtyInput.value) || 1;
            val += delta;
            if (val < 1) val = 1;
            qtyInput.value = val;
        }
        calculateRealtimeTotal();
    }
    // Tính toán tổng tiền realtime phía Client có nhân số lượng topping
    function calculateRealtimeTotal() {
        let total = 0;
        const checkedSize = document.querySelector('input[name="maSize"]:checked');
        if (checkedSize) {
            total += parseInt(checkedSize.dataset.price);
        }
        const activeToppings = document.querySelectorAll('.topping-check:checked');
        activeToppings.forEach(tp => {
            const tpId = tp.value;
            const qtyInput = document.getElementById('web_tp_qty_' + tpId);
            const qty = qtyInput ? parseInt(qtyInput.value) : 1;
            total += parseInt(tp.dataset.price) * qty;
        });
        const qty = parseInt(document.getElementById('qtyInput').value);
        const finalPrice = total * qty;
        document.getElementById('displayTotal').innerText = finalPrice.toLocaleString('vi-VN') + ' đ';
    }
    // Tăng giảm số lượng ly nước uống
    function adjustQty(amount) {
        const input = document.getElementById('qtyInput');
        let currentVal = parseInt(input.value);
        currentVal += amount;
        if (currentVal < 1) currentVal = 1;
        input.value = currentVal;
        calculateRealtimeTotal();
    }
    // Luồng xử lý điều phối AJAX tích hợp: Tự động chuyển qua đăng nhập mượt mà không lỗi
    function handleCartAction(action) {
        const form = document.getElementById("addToCartForm");
        const formData = new FormData(form);
        Swal.fire({
            title: 'Đang kết nối hệ thống...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });
        fetch(form.action, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: new URLSearchParams(formData)
        })
            .then(res => {
                if (res.status === 401) {
                    window.location.href = '${pageContext.request.contextPath}/customer/login';
                    throw new Error('SESSION_EXPIRED');
                }
                return res.text();
            })
            .then(cleanData => {
                Swal.close();
                if (cleanData.trim() === 'SESSION_EXPIRED' || cleanData.trim() === 'NOT_LOGGED_IN') {
                    window.location.href = '${pageContext.request.contextPath}/customer/login';
                    return;
                }
                if (cleanData.startsWith('SUCCESS')) {
                    const parts = cleanData.split('|');
                    const cartCount = parts.length > 1 ? parts[1] : '0';
                    const badge = document.querySelector('.navbar .badge');
                    if (badge) {
                        badge.innerText = cartCount;
                        badge.style.display = 'flex';
                    }
                    if (action === 'buy') {
                        window.location.href = '${pageContext.request.contextPath}/checkout';
                    } else if (action === 'edit') {
                        Swal.fire({
                            icon: 'success',
                            title: 'Đã lưu thay đổi!',
                            text: 'Cấu hình ly trà sữa này đã được cập nhật thành công trong giỏ hàng.',
                            confirmButtonColor: '#10b981',
                            confirmButtonText: 'Quay lại giỏ hàng'
                        }).then(() => {
                            window.location.href = '${pageContext.request.contextPath}/cart';
                        });
                    } else {
                        Swal.fire({
                            icon: 'success',
                            title: 'Đã xếp vào giỏ hàng!',
                            text: 'Món trà sữa của quý khách đã được chuẩn bị cấu hình pha chế trong giỏ hàng.',
                            showCancelButton: true,
                            confirmButtonColor: '#10b981',
                            cancelButtonColor: '#64748b',
                            confirmButtonText: 'Đến giỏ hàng xem ngay',
                            cancelButtonText: 'Tiếp tục xem đồ uống khác'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                window.location.href = '${pageContext.request.contextPath}/cart';
                            }
                        });
                    }
                } else {
                    showToast('error', 'Thao tác giỏ hàng thất bại! Vui lòng thử lại sau.');
                }
            })
            .catch(err => {
                Swal.close();
                console.error('Lỗi hệ thống kết nối AJAX:', err);
            });
    }
    document.addEventListener("DOMContentLoaded", function() {
        calculateRealtimeTotal();
    });
</script>
</body>
</html>