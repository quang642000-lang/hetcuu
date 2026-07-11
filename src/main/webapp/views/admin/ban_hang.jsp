<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Hệ Thống Bán Hàng Tại Quầy POS</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
    <style>
        /* Khóa cứng cuộn trang ngoài, đảm bảo quầy POS chuẩn chỉ cuộn trong khung quy định */
        html, body {
            height: 100vh;
            overflow: hidden;
            background-color: #f1f5f9;
        }
        .pos-container {
            display: flex;
            height: calc(100vh - 60px);
            overflow: hidden;
        }
        .pos-categories-col {
            width: 110px;
            background: #ffffff;
            border-right: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }
        .pos-products-col {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }
        .pos-cart-col {
            width: 400px;
            background: #ffffff;
            border-left: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .pos-cart-items {
            flex-grow: 1;
            overflow-y: auto;
            padding: 12px;
        }
        .pos-product-card {
            position: relative;
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            padding: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.25s ease;
        }
        .pos-product-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 15px rgba(0,0,0,0.05);
            border-color: #10b981;
        }
        .pos-product-img {
            width: 100%;
            height: 100px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 8px;
        }
        .pos-product-name {
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
            height: 38px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
    </style>
</head>
<body>

<!-- HEADER TOÀN NĂNG -->
<nav class="navbar navbar-dark bg-dark px-3 shadow-sm" style="height: 60px;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important;">
            <i class="bi bi-cup-hot-fill me-2 fs-4"></i> TEA POS PRO
        </a>
        <div class="d-flex align-items-center gap-3 text-white">
            <span class="small fw-semibold border-end pe-3 border-secondary d-none d-md-inline">
                <i class="bi bi-person-badge-fill me-1"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
            </span>
            <span class="small d-none d-md-inline border-end pe-3 border-secondary">
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

<div class="pos-container">
    <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÒN [10] -->
    <div class="pos-categories-col">
        <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
            <i class="bi bi-grid-fill fs-4 d-block mb-1"></i>
            <span>TẤT CẢ</span>
        </button>
        <c:forEach var="cat" items="${categories}">
            <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory(${cat.maDm})">
                <i class="bi bi-cup-straw fs-4 d-block mb-1"></i>
                <span class="text-uppercase"><c:out value="${cat.tenDm}"/></span>
            </button>
        </c:forEach>
    </div>

    <!-- CỘT 2: LƯỚI SẢN PHẨM & THANH TRA CỨU NHANH [11] -->
    <div class="pos-products-col">
        <div class="d-flex flex-column flex-sm-row justify-content-between align-items-center gap-3 mb-3">
            <div class="input-group" style="max-width: 400px;">
                <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                <input type="text" id="posSearchProductInput" class="form-control border-start-0 py-2.5" placeholder="Mã món hoặc tên trà sữa..." onkeyup="searchPOSProduct()">
            </div>
            <div class="btn-group border bg-white shadow-sm" style="border-radius: 8px; padding: 3px;">
                <button class="btn btn-sm px-3 border-0 rounded-2 btn-light" onclick="filterBadge('all')">Tất cả</button>
                <button class="btn btn-sm px-3 border-0 rounded-2 text-warning fw-bold" onclick="filterBadge('new')">Món mới ✨</button>
                <button class="btn btn-sm px-3 border-0 rounded-2 text-danger fw-bold" onclick="filterBadge('hot')">Bán chạy 🔥</button>
            </div>
        </div>

        <div class="products-grid mt-1 row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-xl-5 g-3" id="posProductGrid">
            <c:forEach var="sp" items="${products}">
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
                <div class="col pos-card-container">
                    <div class="pos-product-card" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}"
                         onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                        <c:choose>
                            <c:when test="${not empty sp.hinhAnh}">
                                <img src="${sp.hinhAnh}" class="pos-product-img rounded">
                            </c:when>
                            <c:otherwise>
                                <div class="bg-light rounded d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 100%; height: 100px;">
                                    <i class="bi bi-cup-straw fs-2 text-muted"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <div class="pos-product-name"><c:out value="${sp.tenSp}"/></div>
                        <div class="pos-product-price text-success fw-bold mt-1">
                            <c:forEach var="sz" items="${sp.sizesList}" end="0">
                                <fmt:formatNumber value="${sz.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                            </c:forEach>
                        </div>
                        <c:if test="${sp.isNew}"><span class="position-absolute top-0 start-0 badge bg-warning text-dark small m-1" style="font-size: 9px;">NEW</span></c:if>
                        <c:if test="${sp.isBestseller}"><span class="position-absolute top-0 end-0 badge bg-danger text-white small m-1" style="font-size: 9px;">HOT</span></c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- CỘT 3: GIỎ HÀNG THU NGÂN & CHỐT HÓA ĐƠN CRM -->
    <div class="pos-cart-col">
        <div class="p-3 border-bottom d-flex justify-content-between align-items-center bg-white" style="height: 60px; flex-shrink: 0;">
            <h5 class="fw-bold mb-0 text-dark"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG</h5>
            <button class="btn btn-sm btn-outline-danger px-2.5 fw-bold" style="border-radius: 6px;" onclick="clearFullPosCart()"><i class="bi bi-trash"></i> Hủy hết</button>
        </div>

        <!-- Khung hiển thị các ly nước đã nạp -->
        <div class="pos-cart-items" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-50"></i>
                <p class="small mt-2">Chưa chọn món. Chạm sản phẩm ở lưới giữa để tạo đơn.</p>
            </div>
        </div>

        <!-- CRM ĐẤU NỐI THÀNH VIÊN VIP CHUYÊN SÂU -->
        <div class="p-3 bg-light border-top border-bottom" style="flex-shrink: 0;">
            <div class="input-group input-group-sm mb-2">
                <span class="input-group-text bg-white"><i class="bi bi-telephone-fill text-success"></i></span>
                <input type="text" class="form-control" id="customerPhoneSearch" placeholder="Quét/Nhập SĐT khách hàng CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                <button class="btn btn-success fw-bold" type="button" onclick="searchCustomerCRM()">TÌM</button>
            </div>
            <div class="d-flex justify-content-between align-items-center px-1">
                <div>
                    <small class="text-muted d-block" style="font-size: 9px; letter-spacing: 0.5px;">THÀNH VIÊN CRM</small>
                    <strong class="text-success small" id="customerNameResult">Khách vãng lai lẻ</strong>
                </div>
                <span class="badge bg-secondary text-white py-1.5 px-3" id="customerPoints">Hạng: MỚI | 0 Điểm</span>
            </div>

            <!-- Ví điểm và Chọn Voucher đặc quyền thành viên VIP (Tự động hiển thị khi tìm thấy khách) -->
            <div id="crmLoyaltyArea" style="display: none;" class="border-top pt-2 mt-2">
                <div class="row g-2">
                    <div class="col-6">
                        <button type="button" class="btn btn-sm btn-outline-success w-100 fw-bold py-1.5" id="btnOpenVoucher" onclick="showVoucherSelectionModal()">🎯 CHỌN MÃ KM</button>
                    </div>
                    <div class="col-6">
                        <button type="button" class="btn btn-sm btn-outline-primary w-100 fw-bold py-1.5" id="btnApplyPoints" onclick="applyPointsDiscount()">💎 TIÊU ĐIỂM CRM</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- FORM GỬI THANH TOÁN POST LÊN BACKEND CONTROLLER -->
        <form id="posCheckoutForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST" style="flex-shrink: 0;">
            <input type="hidden" name="maKh" id="submit_maKh">
            <input type="hidden" name="loaiDonHang" id="submit_loaiDonHang" value="1">
            <input type="hidden" name="maPt" id="submit_maPt" value="1">
            <input type="hidden" name="maKm" id="submit_maKm">
            <input type="hidden" name="tongTienHang" id="submit_tongTienHang">
            <input type="hidden" name="tienGiamGia" id="submit_tienGiamGia" value="0">
            <input type="hidden" name="diemSuDung" id="submit_diemSuDung" value="0">
            <input type="hidden" name="tienTruDiem" id="submit_tienTruDiem" value="0">
            <input type="hidden" name="tongPhaiTra" id="submit_tongPhaiTra">
            <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_OFFLINE">
            <div id="submitItemsContainer"></div>

            <div class="p-3 bg-white border-top">
                <div class="d-flex justify-content-between mb-1 small text-muted">
                    <span>Tổng tiền cốc & Toppings:</span>
                    <span class="fw-bold text-dark" id="totalRawPrice">0 đ</span>
                </div>
                <div class="d-flex justify-content-between mb-1 small text-danger" id="summaryDiscountRow" style="display: none;">
                    <span>Áp mã giảm giá (<span id="txtAppliedCode" class="fw-bold"></span>):</span>
                    <span class="fw-bold" id="totalDiscountPrice">-0 đ</span>
                </div>
                <div class="d-flex justify-content-between mb-1 small text-primary" id="summaryPointsRow" style="display: none;">
                    <span>Quy đổi <span id="txtUsedPoints" class="fw-bold">0</span> điểm CRM:</span>
                    <span class="fw-bold" id="totalPointsPrice">-0 đ</span>
                </div>
                <div class="d-flex justify-content-between mb-1 small text-muted">
                    <span>Thuế VAT (8%):</span>
                    <span class="fw-semibold text-dark" id="totalTaxPrice">0 đ</span>
                </div>
                <div class="d-flex justify-content-between align-items-center border-top pt-2 mt-2 mb-3">
                    <span class="fw-bold text-dark fs-6">THÀNH TIỀN THU (VNĐ):</span>
                    <span class="fw-bold text-danger fs-4" id="totalPayablePrice">0 đ</span>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold text-muted small d-block mb-1">PHƯƠNG THỨC THANH TOÁN</label>
                    <div class="btn-group w-100">
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_cash" value="1" checked onclick="changePaymentMethod(1)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_cash"><i class="bi bi-cash-coin me-1"></i> Tiền mặt</label>
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_qr" value="2" onclick="changePaymentMethod(2)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_qr"><i class="bi bi-qr-code-scan me-1"></i> Chuyển khoản QR</label>
                    </div>
                </div>

                <button type="button" class="btn btn-primary-teapos w-100 py-3 fs-5 fw-bold" onclick="submitPOSOrderTransaction()">
                    <i class="bi bi-printer me-1"></i> GIAO DỊCH & IN HOÁ ĐƠN
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
<script>
    // Khởi chạy đồng hồ thời gian thực tại quầy thu ngân
    function updatePOSClock() {
        const now = new Date();
        document.getElementById('posCurrentClock').innerText = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    // Ràng buộc input chỉ cho nhập số điện thoại chuẩn, tự tìm kiếm khi đủ 10 số
    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    // Bộ lọc danh mục nước uống đồng bộ tại quầy
    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        if (maDm === 'all') {
            document.getElementById('btn_cat_all').classList.add('active');
            document.querySelectorAll('#posProductGrid .col').forEach(card => card.style.display = 'block');
        } else {
            document.getElementById('btn_cat_' + maDm).classList.add('active');
            document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
                const parent = card.closest('.col');
                if (parseInt(card.dataset.madm) === maDm) {
                    parent.style.display = 'block';
                } else {
                    parent.style.display = 'none';
                }
            });
        }
    }

    // Bộ lọc tag đặc biệt (NEW, HOT, ALL)
    function filterBadge(type) {
        document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
            const parent = card.closest('.col');
            if (type === 'all') {
                parent.style.display = 'block';
            } else if (type === 'new') {
                parent.style.display = card.dataset.isnew === 'true' ? 'block' : 'none';
            } else if (type === 'hot') {
                parent.style.display = card.dataset.ishot === 'true' ? 'block' : 'none';
            }
        });
    }

    // Tra cứu nhanh sản phẩm qua ký tự gõ
    function searchPOSProduct() {
        const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
        document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
            const name = card.querySelector('.pos-product-name').innerText.toLowerCase();
            const id = card.dataset.masp.toLowerCase();
            const parent = card.closest('.col');
            if (name.includes(keyword) || id.includes(keyword)) {
                parent.style.display = 'block';
            } else {
                parent.style.display = 'none';
            }
        });
    }

    // Nút hủy giỏ hàng
    function clearFullPosCart() {
        posCart = [];
        resetVoucherAndPoints();
        renderPosCart();
    }

    // Đổi phương thức thanh toán
    function changePaymentMethod(maPt) {
        document.getElementById('submit_maPt').value = maPt;
    }

    // Form Submit chốt đơn POS
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

            // Map mảng topping định dạng chuẩn: maTp_soLuong_giaTp
            let toppingKeys = item.toppings.map(t => t.maTp + "_" + t.soLuongTp + "_" + t.giaTp).join("|");
            container.innerHTML += `<input type="hidden" name="item_toppingKeys[]" value="${toppingKeys}">`;
        });

        Swal.fire({
            title: 'Chốt giao dịch quầy POS',
            text: 'Xác nhận in hóa đơn tài chính và thu tiền của khách?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#2e7d32',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận & In Bill'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('posCheckoutForm').submit();
            }
        });
    }

    // Lắng nghe xem có hóa đơn in từ backend trả về không
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const orderId = urlParams.get('orderId');
        if (orderId) {
            Swal.fire({
                icon: 'success',
                title: 'Thanh toán hoàn tất',
                html: 'Hóa đơn mã: <strong>' + orderId + '</strong> đã được xuất và in thành công! Đã tự động tích điểm CRM.',
                confirmButtonColor: '#2e7d32',
                confirmButtonText: 'Bán đơn mới'
            }).then(() => {
                window.location.href = '${pageContext.request.contextPath}/pos';
            });
        }
    });
</script>
</body>
</html>