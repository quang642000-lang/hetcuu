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
                <img src="${not empty product.hinhAnh ? product.hinhAnh : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" class="w-100 rounded-4 shadow" style="object-fit: cover; max-height: 480px;" alt="Tea">
            </div>
        </div>
        <!-- BẢNG TÙY BIẾN PHA CHẾ BÊN PHẢI -->
        <div class="col-12 col-md-7">
            <div class="card p-4 border-0 shadow-sm bg-white" style="border-radius: 16px;">
                <span class="badge bg-success bg-opacity-10 text-success border border-success mb-2 px-3 py-1.5 fw-bold text-uppercase d-inline-block" style="max-width: fit-content;">Danh mục: SP${product.maSp}</span>
                <h2 class="fw-bold mb-2 text-dark"><c:out value="${product.tenSp}"/></h2>
                <p class="text-muted mb-4"><c:out value="${product.moTa}"/></p>

                <form id="addToCartForm" action="${pageContext.request.contextPath}/cart/add" method="POST">
                    <input type="hidden" name="maSp" value="${product.maSp}">

                    <!-- 1. CHỌN SIZE -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-dark d-block">1. Chọn kích cỡ cốc nước <span class="text-danger">*</span></label>
                        <div class="row g-2">
                            <c:forEach var="size" items="${sizes}" varStatus="loop">
                                <div class="col-4">
                                    <input type="radio" class="btn-check" name="maSize" id="size_${size.maSize}" value="${size.maSize}" data-price="${size.giaBan}" ${loop.first ? 'checked' : ''} onchange="calculateRealtimeTotal()">
                                    <label class="btn btn-outline-success py-2.5 w-100 text-center fw-bold" for="size_${size.maSize}">
                                            ${size.maSize == 1 ? 'Size S' : (size.maSize == 2 ? 'Size M' : 'Size L')} <br>
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
                                <select class="form-select form-control-teapos" id="mucDa" name="mucDa">
                                    <option value="100%">100% Đá (Mặc định)</option>
                                    <option value="70%">70% Đá (Ít đá)</option>
                                    <option value="50%">50% Đá</option>
                                    <option value="0%">0% Đá (Không đá)</option>
                                </select>
                            </div>
                        </c:if>
                        <c:if test="${product.choPhepDoiDuong}">
                            <div class="col-6">
                                <label for="mucDuong" class="form-label fw-bold text-dark small">3. Mức độ đường</label>
                                <select class="form-select form-control-teapos" id="mucDuong" name="mucDuong">
                                    <option value="100%">100% Đường (Mặc định)</option>
                                    <option value="70%">70% Đường (Ít ngọt)</option>
                                    <option value="50%">50% Đường</option>
                                    <option value="0%">0% Đường (Không ngọt)</option>
                                </select>
                            </div>
                        </c:if>
                    </div>

                    <!-- 3. TOPPING -->
                    <div class="mb-4">
                        <label class="form-label fw-bold text-dark d-block">4. Thêm Topping dai giòn sần sật</label>
                        <div class="row g-2">
                            <c:forEach var="tp" items="${toppings}">
                                <div class="col-12 col-md-6">
                                    <div class="border rounded p-2.5 d-flex justify-content-between align-items-center">
                                        <div class="form-check mb-0">
                                            <input class="form-check-input topping-check" type="checkbox" name="toppings[]" id="tp_${tp.maTp}" value="${tp.maTp}" data-price="${tp.giaBan}" onchange="calculateRealtimeTotal()">
                                            <label class="form-check-label fw-semibold text-dark small" for="tp_${tp.maTp}">
                                                <c:out value="${tp.tenTp}"/>
                                            </label>
                                        </div>
                                        <span class="text-success fw-bold small">+<fmt:formatNumber value="${tp.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 4. GHI CHÚ -->
                    <div class="mb-4">
                        <label for="ghiChuMon" class="form-label fw-bold text-dark small">5. Ghi chú của bạn cho thợ pha chế</label>
                        <textarea class="form-control" id="ghiChuMon" name="ghiChuMon" rows="2" placeholder="Ví dụ: Mang ly đá riêng, bọc kỹ màng nhôm mang đi xa..."></textarea>
                    </div>

                    <!-- 5. TỔNG TIỀN VÀ SỐ LƯỢNG -->
                    <div class="d-flex align-items-center justify-content-between border-top pt-4 mb-4">
                        <div>
                            <span class="text-muted d-block small fw-medium">Tổng giá trị cốc nước:</span>
                            <span class="fw-bold text-success fs-3" id="displayTotal">0 đ</span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <button type="button" class="btn btn-outline-secondary px-3 py-2" onclick="adjustQty(-1)"><i class="bi bi-dash-lg"></i></button>
                            <input type="number" id="qtyInput" name="soLuong" class="form-control text-center fw-bold fs-5 px-0" value="1" min="1" readonly style="width: 55px; border: 0;">
                            <button type="button" class="btn btn-outline-secondary px-3 py-2" onclick="adjustQty(1)"><i class="bi bi-plus-lg"></i></button>
                        </div>
                    </div>

                    <!-- PHẦN CẢI TIẾN THÊM BỘ ĐÔI NÚT SONG HÀNH -->
                    <div class="row g-3">
                        <div class="col-6">
                            <button type="button" class="btn btn-outline-success w-100 py-3 fw-bold fs-5 rounded-3" onclick="handleCartAction('add')">
                                <i class="bi bi-bag-plus-fill me-1"></i> THÊM VÀO GIỎ
                            </button>
                        </div>
                        <div class="col-6">
                            <button type="button" class="btn btn-success w-100 py-3 fw-bold fs-5 rounded-3" onclick="handleCartAction('buy')">
                                <i class="bi bi-cart-check-fill me-1"></i> MUA NGAY
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />
<script>
    function calculateRealtimeTotal() {
        let total = 0;
        const checkedSize = document.querySelector('input[name="maSize"]:checked');
        if (checkedSize) {
            total += parseInt(checkedSize.dataset.price);
        }
        const activeToppings = document.querySelectorAll('.topping-check:checked');
        activeToppings.forEach(tp => {
            total += parseInt(tp.dataset.price);
        });
        const qty = parseInt(document.getElementById('qtyInput').value);
        const finalPrice = total * qty;
        document.getElementById('displayTotal').innerText = finalPrice.toLocaleString('vi-VN') + ' đ';
    }

    function adjustQty(amount) {
        const input = document.getElementById('qtyInput');
        let currentVal = parseInt(input.value);
        currentVal += amount;
        if (currentVal < 1) currentVal = 1;
        input.value = currentVal;
        calculateRealtimeTotal();
    }

    // Logic điều phối AJAX cho bộ đôi nút bấm đặc thù
    function handleCartAction(action) {
        const form = document.getElementById("addToCartForm");
        const formData = new FormData(form);

        Swal.fire({
            title: 'Đang xử lý...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });

        fetch(form.action, {
            method: 'POST',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(formData)
        })
            .then(res => res.text())
            .then(data => {
                Swal.close();
                if (data === 'NOT_LOGGED_IN') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Yêu cầu đăng nhập',
                        text: 'Quý khách vui lòng đăng nhập tài khoản thành viên để thực hiện mua trà sữa!',
                        showCancelButton: true,
                        confirmButtonColor: '#2e7d32',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Đăng nhập ngay',
                        cancelButtonText: 'Bỏ qua'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.href = '${pageContext.request.contextPath}/customer/login';
                        }
                    });
                } else if (data.startsWith('SUCCESS')) {
                    const parts = data.split('|');
                    const cartCount = parts.length > 1 ? parts[12] : '0';

                    // Cập nhật badge giỏ hàng trên Header
                    const badge = document.querySelector('.navbar .badge');
                    if (badge) {
                        badge.innerText = cartCount;
                        badge.style.display = 'flex';
                    }

                    if (action === 'buy') {
                        // MUA NGAY: Chuyển thẳng sang trang kiểm toán đặt hàng checkout
                        window.location.href = '${pageContext.request.contextPath}/checkout';
                    } else {
                        // THÊM GIỎ: Ở lại trang, bắn thông báo thành công ngọt ngào
                        Swal.fire({
                            icon: 'success',
                            title: 'Đã thêm thành công!',
                            text: 'Món nước đã được xếp vào giỏ hàng trực tuyến.',
                            showCancelButton: true,
                            confirmButtonColor: '#10b981',
                            cancelButtonColor: '#64748b',
                            confirmButtonText: 'Đến giỏ hàng',
                            cancelButtonText: 'Tiếp tục xem Menu'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                window.location.href = '${pageContext.request.contextPath}/cart';
                            }
                        });
                    }
                } else {
                    showToast('error', 'Thao tác giỏ hàng thất bại!');
                }
            })
            .catch(err => {
                Swal.close();
                console.error('Lỗi kết nối:', err);
                showToast('error', 'Lỗi kết nối máy chủ!');
            });
    }

    document.addEventListener("DOMContentLoaded", function() {
        calculateRealtimeTotal();
    });
</script>
</body>
</html>