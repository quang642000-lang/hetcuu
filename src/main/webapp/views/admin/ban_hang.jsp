<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Hệ Thống Bán Hàng Tại Quầy POS</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
</head>
<body class="bg-light overflow-hidden">

<!-- HEADER QUẦY POS -->
<nav class="navbar navbar-dark bg-dark px-3 shadow-sm" style="height: 60px;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important;">
            <i class="bi bi-cup-hot-fill me-2 fs-4"></i> TEA POS PRO
        </a>
        <div class="d-flex align-items-center gap-3 text-white">
            <span class="small fw-semibold border-end pe-3 border-secondary d-none d-md-inline">
                <i class="bi bi-person-badge-fill me-1"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
            </span>
            <span class="small d-none d-md-inline">
                <i class="bi bi-clock-fill me-1"></i> <span id="posCurrentClock">00:00:00</span>
            </span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold">
                <i class="bi bi-shield-lock-fill me-1"></i> Admin Panel
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-outline-danger border-2">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</nav>

<!-- KHUNG 3 CỘT ĐỘNG (POS DYNAMIC LAYOUT SYSTEM) [6] -->
<div class="pos-container">

    <!-- CỘT 1 (LEFT COLUMN): SIDEBAR CHỌN DANH MỤC TRÒN [7] -->
    <div class="pos-categories-col">
        <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
            <i class="bi bi-grid-fill"></i>
            <span>TẤT CẢ</span>
        </button>
        <c:forEach var="cat" items="${categories}">
            <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory(${cat.maDm})">
                <i class="bi bi-cup-straw"></i>
                <span class="text-uppercase"><c:out value="${cat.tenDm}"/></span>
            </button>
        </c:forEach>
    </div>

    <!-- CỘT 2 (MIDDLE COLUMN): LƯỚI SẢN PHẨM & TÌM KIẾM [8] -->
    <div class="pos-products-col flex-grow-1">
        <!-- Thanh bộ lọc và công cụ tìm kiếm -->
        <div class="d-flex justify-content-between align-items-center gap-3">
            <div class="input-group" style="max-width: 420px;">
                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                <input type="text" id="posSearchProductInput" class="form-control border-start-0 py-2.5" placeholder="Gõ tên món hoặc mã đồ uống để quét..." onkeyup="searchPOSProduct()">
            </div>
            <div class="btn-group border bg-white" style="border-radius: 8px; padding: 3px;">
                <button class="btn btn-sm px-3 border-0 rounded-2 btn-light" onclick="filterBadge('all')">Tất cả</button>
                <button class="btn btn-sm px-3 border-0 rounded-2 text-warning fw-bold" onclick="filterBadge('new')">Món mới ✨</button>
                <button class="btn btn-sm px-3 border-0 rounded-2 text-danger fw-bold" onclick="filterBadge('hot')">Bán chạy 🔥</button>
            </div>
        </div>

        <!-- Lưới sản phẩm [8] -->
        <div class="products-grid mt-2" id="posProductGrid">
            <c:forEach var="sp" items="${products}">
                <!-- Nạp sẵn JSON thuộc tính liên kết để mở Popup nhanh [8] -->
                <script>
                    window['sp_opt_' + '${sp.maSp}'] = {
                        choPhepDoiDa: ${sp.choPhepDoiDa},
                        choPhepDoiDuong: ${sp.choPhepDoiDuong},
                        sizes: [
                            <c:forEach var="sz" items="${sp.sizesList}" varStatus="sLoop">
                            { maSize: ${sz.maSize}, tenSize: '${sz.maSize == 1 ? "S" : (sz.maSize == 2 ? "M" : "L")}', giaBan: ${sz.giaBan} }${not sLoop.last ? ',' : ''}
                            </c:forEach>
                        ],
                        allToppings: [
                            <c:forEach var="tp" items="${toppings}" varStatus="tLoop">
                            { maTp: ${tp.maTp}, tenTp: '${tp.tenTp}', giaBan: ${tp.giaBan} }${not tLoop.last ? ',' : ''}
                            </c:forEach>
                        ]
                    };
                </script>

                <div class="pos-product-card" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}"
                     onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                    <c:choose>
                        <c:when test="${not empty sp.hinhAnh}">
                            <img src="${sp.hinhAnh}" class="pos-product-img rounded">
                        </c:when>
                        <c:otherwise>
                            <div class="bg-light rounded d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 90px; height: 90px;"><i class="bi bi-cup-straw fs-2 text-muted"></i></div>
                        </c:otherwise>
                    </c:choose>
                    <div class="pos-product-name"><c:out value="${sp.tenSp}"/></div>
                    <div class="pos-product-price text-success fw-bold">
                        <c:forEach var="sz" items="${sp.sizesList}" end="0">
                            <fmt:formatNumber value="${sz.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                        </c:forEach>
                    </div>
                    <!-- Badges -->
                    <c:if test="${sp.isNew}"><span class="position-absolute top-0 start-0 badge bg-warning text-dark small m-1" style="font-size: 10px;">NEW</span></c:if>
                    <c:if test="${sp.isBestseller}"><span class="position-absolute top-0 end-0 badge bg-danger text-white small m-1" style="font-size: 10px;">HOT</span></c:if>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- CỘT 3 (RIGHT COLUMN): GIỎ HÀNG CHỜ VÀ CHỐT THANH TOÁN [9] -->
    <div class="pos-cart-col">
        <!-- Tiêu đề giỏ hàng -->
        <div class="p-3 border-bottom d-flex justify-content-between align-items-center bg-white" style="height: 60px;">
            <h5 class="fw-bold mb-0 text-dark"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG POS</h5>
            <button class="btn btn-sm btn-outline-danger border-2 px-3 fw-bold" style="border-radius: 6px;" onclick="clearFullPosCart()"><i class="bi bi-trash"></i> Hủy hết</button>
        </div>

        <!-- Khối chứa danh sách cốc nước đã chọn -->
        <div class="pos-cart-items" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-50"></i>
                <p class="small mt-2">Giỏ hàng rỗng! Hãy chạm chọn sản phẩm ở lưới giữa để tạo món.</p>
            </div>
        </div>

        <!-- KHỐI ĐẤU NỐI THÀNH VIÊN CRM VIP [9] -->
        <div class="p-3 bg-light border-top border-bottom">
            <div class="input-group input-group-sm mb-2">
                <span class="input-group-text bg-white"><i class="bi bi-telephone-fill text-success"></i></span>
                <input type="text" class="form-control" id="customerPhoneSearch" placeholder="Tìm số điện thoại khách CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                <button class="btn btn-success fw-bold" type="button" onclick="searchCustomerCRM()">TÌM</button>
            </div>
            <div class="d-flex justify-content-between align-items-center px-1">
                <div>
                    <small class="text-muted d-block" style="font-size: 11px; font-weight: 500;">KHÁCH HÀNG CRM</small>
                    <strong class="text-success small" id="customerNameResult">Khách vãng lai lẻ</strong>
                </div>
                <span class="badge bg-secondary text-white py-1.5 px-3" id="customerPoints">Hạng: Mới | 0 Điểm</span>
            </div>
        </div>

        <!-- KHỐI TÍNH DOANH THU & CHỐT HÓA ĐƠN -->
        <form id="posCheckoutForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST">
            <!-- Các tham số ẩn gửi về BanHangPOSController -->
            <input type="hidden" name="maKh" id="submit_maKh">
            <input type="hidden" name="loaiDonHang" id="submit_loaiDonHang" value="1"> <!-- 1: Tại quán -->
            <input type="hidden" name="maPt" id="submit_maPt" value="1"> <!-- 1: Tiền mặt -->
            <input type="hidden" name="maKm" id="submit_maKm">
            <input type="hidden" name="tongTienHang" id="submit_tongTienHang">
            <input type="hidden" name="tienGiamGia" id="submit_tienGiamGia" value="0">
            <input type="hidden" name="diemSuDung" id="submit_diemSuDung" value="0">
            <input type="hidden" name="tienTruDiem" id="submit_tienTruDiem" value="0">
            <input type="hidden" name="tongPhaiTra" id="submit_tongPhaiTra">
            <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_OFFLINE">

            <div id="submitItemsContainer"></div> <!-- Parallel arrays container -->

            <div class="pos-checkout-section bg-white">
                <div class="pos-summary-line mb-1">
                    <span class="text-muted">Tổng tiền cốc & Topping</span>
                    <span class="fw-bold" id="totalRawPrice">0 đ</span>
                </div>
                <div class="pos-summary-line mb-1">
                    <span class="text-muted">Thuế giá trị gia tăng VAT (8%)</span>
                    <span id="totalTaxPrice" class="fw-medium text-dark">0 đ</span>
                </div>
                <div class="pos-total-line pos-summary-line mt-2">
                    <span class="fw-bold text-dark fs-6">TỔNG PHẢI TRẢ (VNĐ)</span>
                    <span class="fw-bold text-success fs-4" id="totalPayablePrice">0 đ</span>
                </div>

                <!-- Chọn phương thức thanh toán -->
                <div class="my-3">
                    <label class="form-label fw-bold text-muted small d-block">PHƯƠNG THỨC THANH TOÁN</label>
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_cash" value="1" checked onclick="changePaymentMethod(1)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_cash"><i class="bi bi-cash-coin me-1"></i> Tiền mặt</label>
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_qr" value="2" onclick="changePaymentMethod(2)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_qr"><i class="bi bi-qr-code-scan me-1"></i> QR Chuyển khoản</label>
                    </div>
                </div>

                <!-- Nút chốt bán hàng & in hóa đơn -->
                <button type="button" class="btn btn-primary-teapos w-100 py-3 fs-5 fw-bold" onclick="submitPOSOrderTransaction()">
                    <i class="bi bi-printer me-1"></i> THANH TOÁN & IN BILL
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>

<script>
    // 1. Đồng hồ thời gian thực ở quầy POS
    function updatePOSClock() {
        const now = new Date();
        document.getElementById('posCurrentClock').innerText = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    // 2. Tự động kiểm tra và khóa định dạng SĐT CRM
    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    // 3. Cơ cấu bộ lọc theo Sidebar Danh mục
    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        if (maDm === 'all') {
            document.getElementById('btn_cat_all').classList.add('active');
            document.querySelectorAll('.pos-product-card').forEach(card => card.style.display = 'block');
        } else {
            document.getElementById('btn_cat_' + maDm).classList.add('active');
            document.querySelectorAll('.pos-product-card').forEach(card => {
                if (parseInt(card.dataset.madm) === maDm) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }
    }

    // 4. Lọc nhanh sản phẩm mới và bán chạy
    function filterBadge(type) {
        document.querySelectorAll('.pos-product-card').forEach(card => {
            if (type === 'all') {
                card.style.display = 'block';
            } else if (type === 'new') {
                card.style.display = card.dataset.isnew === 'true' ? 'block' : 'none';
            } else if (type === 'hot') {
                card.style.display = card.dataset.ishot === 'true' ? 'block' : 'none';
            }
        });
    }

    // 5. Tìm kiếm realtime không trễ
    function searchPOSProduct() {
        const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
        document.querySelectorAll('.pos-product-card').forEach(card => {
            const name = card.querySelector('.pos-product-name').innerText.toLowerCase();
            const id = card.dataset.masp.toLowerCase();
            if (name.includes(keyword) || id.includes(keyword)) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // 6. Xóa giỏ hàng POS
    function clearFullPosCart() {
        posCart = [];
        renderPosCart();
    }

    // 7. Chuyển đổi phương thức thanh toán ẩn
    function changePaymentMethod(maPt) {
        document.getElementById('submit_maPt').value = maPt;
    }

    // 8. Chốt đơn và build Parallel Arrays đẩy lên Java Controller
    function submitPOSOrderTransaction() {
        if (posCart.length === 0) {
            showToast('warning', 'Giỏ hàng POS trống, không thể in hóa đơn!');
            return;
        }

        const container = document.getElementById('submitItemsContainer');
        container.innerHTML = '';

        posCart.forEach(item => {
            container.innerHTML += `<input type="hidden" name="item_maSp[]" value="${item.maSp}">`;
            container.innerHTML += `<input type="hidden" name="item_maSize[]" value="${item.maSize}">`;
            container.innerHTML += `<input type="hidden" name="item_soLuong[]" value="${item.soLuong}">`;
            container.innerHTML += `<input type="hidden" name="item_giaChot[]" value="${item.giaBan}">`;
            container.innerHTML += `<input type="hidden" name="item_mucDa[]" value="${item.mucDa}">`;
            container.innerHTML += `<input type="hidden" name="item_mucDuong[]" value="${item.mucDuong}">`;
            container.innerHTML += `<input type="hidden" name="item_ghiChuMon[]" value="${item.ghiChuMon ? item.ghiChuMon : 'Normal'}">`;

            // Đóng gói mảng Toppings của ly: "maTp_soLuong_giaChot|maTp_soLuong_giaChot"
            let toppingKeys = item.toppings.map(t => t.maTp + "_" + t.soLuongTp + "_" + t.giaTp).join("|");
            container.innerHTML += `<input type="hidden" name="item_toppingKeys[]" value="${toppingKeys}">`;
        });

        const totalPayable = parseInt(document.getElementById('totalPayablePrice').innerText.replace(/\D/g, ''));
        const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, ''));

        document.getElementById('submit_tongTienHang').value = totalRaw;
        document.getElementById('submit_tongPhaiTra').value = totalPayable;

        if (customerInfo) {
            document.getElementById('submit_maKh').value = customerInfo.maKh;
        }

        Swal.fire({
            title: 'Chốt giao dịch quầy POS',
            text: 'Tiến hành in hóa đơn bán lẻ cho khách hàng?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#2e7d32',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận & In hóa đơn'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('posCheckoutForm').submit();
            }
        });
    }

    // 9. Hiển thị Popup thành công và thông tin hóa đơn vừa chốt từ SQL Server [10]
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const orderId = urlParams.get('orderId');
        if (orderId) {
            Swal.fire({
                icon: 'success',
                title: 'Thanh toán hoàn tất',
                html: 'Hóa đơn mã: <strong>' + orderId + '</strong> đã được lưu thành công! Đã cộng điểm CRM và in hóa đơn tại quầy cho khách [10]!',
                confirmButtonColor: '#2e7d32',
                confirmButtonText: 'Đơn hàng mới'
            }).then(() => {
                window.location.href = '${pageContext.request.contextPath}/pos';
            });
        }
    });
</script>
</body>
</html>