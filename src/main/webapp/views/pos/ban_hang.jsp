<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Thu Ngân & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
</head>
<body>
<div class="pos-wrapper">
    <!-- POS TOP NAVBAR -->
    <nav class="navbar navbar-dark bg-dark px-3" style="height: 60px; flex-shrink: 0; z-index: 1040;">
        <div class="container-fluid d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center gap-3">
                <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
                    <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i> TEA POS PRO
                </a>
                <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
                    <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-success fw-bold px-3">
                        <i class="bi bi-cart-fill me-1 text-warning"></i> BÁN TẠI QUẦY
                    </a>
                    <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-outline-light fw-bold px-3">
                        <i class="bi bi-bell-fill me-1"></i> ĐƠN ONLINE
                    </a>
                </div>
            </div>
            <div class="d-flex align-items-center gap-3 text-white">
                <div class="dropdown border-end pe-3 border-secondary d-none d-md-inline">
                    <a class="dropdown-toggle text-decoration-none text-white small fw-semibold" href="#" role="button" id="adminProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posProfileModal"><i class="bi bi-person-circle me-2 text-success"></i>Cài đặt cá nhân</a></li>
                        <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posPasswordModal"><i class="bi bi-key-fill me-2 text-warning"></i>Đổi mật khẩu</a></li>
                    </ul>
                </div>
                <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline">
                    <i class="bi bi-calendar3 text-success me-1"></i>
                    <span id="posCurrentClock">--:--:--</span>
                </span>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase d-none d-sm-inline" style="font-size: 11px;">
                    <i class="bi bi-shield-lock-fill me-1"></i> Quản trị Admin
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger fw-bold px-3 shadow-sm" style="font-size: 12px; border-radius: 6px;">
                    <i class="bi bi-box-arrow-right me-1"></i> ĐĂNG XUẤT
                </a>
            </div>
        </div>
    </nav>

    <!-- POS MAIN WORKSPACE -->
    <div class="pos-main-container" id="posMainContainer">
        <!-- CATEGORIES SIDEBAR -->
        <div class="pos-category-sidebar">
            <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
                <i class="bi bi-grid-fill fs-4 mb-1"></i>
                <span>TẤT CẢ</span>
            </button>
            <c:forEach var="cat" items="${categories}">
                <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory('${cat.maDm}')">
                    <i class="bi bi-cup-straw fs-4 mb-1"></i>
                    <span class="text-uppercase"><c:out value="${cat.tenDm}"/></span>
                </button>
            </c:forEach>
        </div>

        <!-- MAIN PRODUCTS MENU GRID -->
        <div class="pos-menu-area">
            <div class="pos-menu-header">
                <div class="pos-search-wrapper">
                    <i class="bi bi-search pos-search-icon"></i>
                    <input type="text" id="posSearchProductInput" class="pos-search-input" placeholder="Tìm tên đồ uống hoặc mã sản phẩm..." onkeyup="searchPOSProduct()">
                </div>
                <div class="btn-group border bg-white shadow-sm" style="border-radius: 20px; padding: 2px;">
                    <button class="btn btn-sm px-3 border-0 rounded-pill btn-light active-filter" id="f_all" onclick="filterBadge('all')">Tất cả</button>
                    <button class="btn btn-sm px-3 border-0 rounded-pill text-warning fw-bold" id="f_new" onclick="filterBadge('new')">Mới ✨</button>
                    <button class="btn btn-sm px-3 border-0 rounded-pill text-danger fw-bold" id="f_hot" onclick="filterBadge('hot')">Bán chạy 🔥</button>
                </div>
            </div>

            <div class="pos-product-container">
                <div class="pos-grid" id="posProductGrid">
                    <c:forEach var="sp" items="${products}">
                        <div class="pos-card-wrapper">
                            <div class="pos-product-card" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}"
                                 onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                                <c:choose>
                                    <c:when test="${not empty sp.hinhAnh}">
                                        <img src="${sp.hinhAnh}" class="pos-product-img" alt="Pic">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bg-light rounded d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 100%; height: 90px;">
                                            <i class="bi bi-cup-straw fs-2 text-muted"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="pos-card-name"><c:out value="${sp.tenSp}"/></div>
                                <div class="pos-card-price text-success fw-bold">
                                    <c:forEach var="sz" items="${sp.sizesList}" end="0">
                                        <fmt:formatNumber value="${sz.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                    </c:forEach>
                                </div>
                                <c:if test="${sp.isNew}"><span class="position-absolute top-0 start-0 badge bg-warning text-dark small m-1" style="font-size: 9px; border-radius:4px;">NEW</span></c:if>
                                <c:if test="${sp.isBestseller}"><span class="position-absolute top-0 end-0 badge bg-danger text-white small m-1" style="font-size: 9px; border-radius:4px;">HOT</span></c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- RIGHT CHECKOUT SIDEBAR (PERMANENT ON DESKTOP, DRAWER ON MOBILE) -->
        <div class="pos-checkout-sidebar" id="posCheckoutSidebar">
            <div class="pos-checkout-header">
                <h5 class="fw-bold mb-0 text-dark d-flex align-items-center gap-2"><i class="bi bi-receipt-cutoff text-success"></i> GIỎ HÀNG</h5>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-sm btn-outline-secondary d-lg-none" onclick="toggleMobileCart()"><i class="bi bi-x-lg"></i> Đóng</button>
                    <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="clearFullPosCart()"><i class="bi bi-trash3-fill"></i> Hủy đơn</button>
                </div>
            </div>

            <div class="pos-cart-items-wrapper" id="posCartItems">
                <div class="text-center text-muted py-5 my-5">
                    <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>
                    <p class="small mt-2 fw-semibold">Giỏ hàng trống.<br>Hãy chọn đồ uống ở bên để thêm vào đơn hàng.</p>
                </div>
            </div>

            <!-- CRM MEMBERSHIP PANEL -->
            <div class="pos-crm-panel border-bottom">
                <div class="d-flex gap-2 mb-2">
                    <input type="text" id="customerPhoneSearch" class="form-control form-control-sm" placeholder="Nhập SĐT tìm hội viên CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                    <button class="btn btn-sm btn-success fw-bold" type="button" onclick="searchCustomerCRM()"><i class="bi bi-search"></i> Tìm</button>
                </div>
                <div class="p-2 border rounded bg-light mb-2 d-flex justify-content-between align-items-center">
                    <div class="text-start">
                        <small class="text-muted d-block" style="font-size: 9px; letter-spacing: 0.5px; font-weight: 700;">HỘI VIÊN THANH TOÁN</small>
                        <strong class="text-success small" id="customerNameResult">Khách lẻ vãng lai</strong>
                    </div>
                    <span class="badge bg-secondary text-white py-1.5 px-3" id="customerPoints" style="border-radius: 50px;">Hạng: Mới | 0 Điểm</span>
                </div>
                <div id="crmLoyaltyArea" class="mt-2 text-start" style="display: none !important;">
                    <div class="d-flex gap-1.5 mb-1">
                        <button type="button" class="btn btn-xs btn-outline-primary fw-bold flex-fill py-1.5" style="font-size: 11px;" onclick="applyPointsDiscount()"><i class="bi bi-coin"></i> TIÊU ĐIỂM CRM TÍCH LŨY</button>
                    </div>
                </div>
                <div id="posAddCustomerArea" class="mt-2 text-start" style="display: none !important;">
                    <button type="button" class="btn btn-xs btn-outline-success w-100 fw-bold py-1.5" style="font-size: 11px;" onclick="openQuickRegisterModal(document.getElementById('customerPhoneSearch').value)"><i class="bi bi-person-plus-fill"></i> ĐĂNG KÝ HỘI VIÊN NHANH</button>
                </div>
            </div>

            <!-- BILL SUMMARY & PAYMENT PANEL -->
            <div class="pos-summary-panel">
                <div class="d-flex gap-1.5 mb-2">
                    <input type="text" id="manualVoucherInput" class="form-control form-control-sm text-uppercase fw-bold" placeholder="Nhập mã Voucher..." style="height: 32px; letter-spacing:0.5px;">
                    <button type="button" class="btn btn-sm btn-dark fw-bold" style="height: 32px; font-size:11px;" onclick="applyManualVoucherCode()">ÁP MÃ</button>
                </div>
                <div class="pos-line-price">
                    <span>Tổng tiền gốc (Kèm Toppings):</span>
                    <strong id="totalRawPrice">0 đ</strong>
                </div>
                <div class="pos-line-price text-danger" id="summaryDiscountRow" style="display: none !important;">
                    <span>Khấu trừ Voucher (<span id="txtAppliedCode">N/A</span>):</span>
                    <strong id="totalDiscountPrice">-0 đ</strong>
                </div>
                <div class="pos-line-price text-primary" id="summaryPointsRow" style="display: none !important;">
                    <span>Quy đổi tích điểm <span id="txtUsedPoints" class="fw-bold">0</span> CRM:</span>
                    <strong id="totalPointsPrice">-0 đ</strong>
                </div>
                <div class="pos-line-price">
                    <span>Thuế GTGT VAT (8%):</span>
                    <strong class="text-dark" id="totalTaxPrice">0 đ</strong>
                </div>
                <div class="pos-total-row">
                    <span>TỔNG THỰC THU:</span>
                    <span class="text-success fs-5" id="totalPayablePrice">0 đ</span>
                </div>

                <!-- CASH SUGGESTION SECTION -->
                <div class="mt-2 text-start p-2 rounded bg-light border mb-2" id="cashCalculatorSection">
                    <div class="d-flex justify-content-between align-items-center mb-1.5">
                        <small class="fw-bold text-muted" style="font-size: 11px;"><i class="bi bi-cash-stack"></i> KHÁCH ĐƯA (VNĐ):</small>
                        <input type="number" class="form-control form-control-sm text-end fw-bold text-primary font-monospace bg-white" id="inputCustomerCash" placeholder="Nhập số tiền..." style="width: 120px; height: 28px;" oninput="calculateChangeRefund()">
                    </div>
                    <div class="d-flex justify-content-between gap-1 mb-1.5">
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(50000)">50k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(100000)">100k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(200000)">200k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(500000)">500k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(0)">ĐỦ</button>
                    </div>
                    <div class="d-flex justify-content-between text-dark fw-bold border-top pt-1.5 small" style="font-size: 11.5px;">
                        <span>TIỀN THỐI LẠI:</span>
                        <span id="txtCashRefund" class="text-success font-monospace fw-bold">0 đ</span>
                    </div>
                </div>

                <!-- PAYMENT METHODS SELECTOR -->
                <div class="mb-2 text-start">
                    <label class="form-label text-muted small fw-bold mb-1" style="font-size: 10px;"><i class="bi bi-wallet2"></i> PHƯƠNG THỨC THANH TOÁN:</label>
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_cash" value="1" checked onchange="changePaymentMethod(1)">
                        <label class="btn btn-outline-success py-1.5 fw-semibold small" for="pt_cash">
                            <i class="bi bi-cash-coin me-1"></i> TIỀN MẶT
                        </label>
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_qr" value="2" onchange="changePaymentMethod(2)">
                        <label class="btn btn-outline-success py-1.5 fw-semibold small" for="pt_qr">
                            <i class="bi bi-qr-code-scan me-1"></i> CHUYỂN KHOẢN QR
                        </label>
                    </div>
                </div>

                <!-- HIDDEN ORDER SUBMIT FORM -->
                <form id="posOrderForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST" style="display: none;">
                    <input type="hidden" name="maKh" id="submit_maKh" value="">
                    <input type="hidden" name="loaiDonHang" id="submit_loaiDonHang" value="1">
                    <input type="hidden" name="maPt" id="submit_maPt" value="1">
                    <input type="hidden" name="maKm" id="submit_maKm" value="">
                    <input type="hidden" name="tongTienHang" id="submit_tongTienHang" value="0">
                    <input type="hidden" name="tienGiamGia" id="submit_tienGiamGia" value="0">
                    <input type="hidden" name="diemSuDung" id="submit_diemSuDung" value="0">
                    <input type="hidden" name="tienTruDiem" id="submit_tienTruDiem" value="0">
                    <input type="hidden" name="tongPhaiTra" id="submit_tongPhaiTra" value="0">
                    <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_IN_STORE">
                    <div id="posFormItemsContainer"></div>
                </form>

                <button type="button" class="btn btn-primary-teapos w-100 py-2.5 fs-5 fw-bold" onclick="submitPOSOrderTransaction()">
                    <i class="bi bi-printer me-1"></i> CHỐT ĐƠN & GIAO DỊCH
                </button>
            </div>
        </div>
    </div>
</div>

<!-- INCLUDES ALL THE REQUISITE MODALS (PROFILE, PASSWORD, RECEIPT, VIETQR) -->
<jsp:include page="/views/pos/pos_modals.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    function updatePOSClock() {
        const el = document.getElementById("posCurrentClock");
        if (el) {
            const now = new Date();
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            const dateStr = now.toLocaleDateString('vi-VN');
            el.innerText = hours + ":" + minutes + ":" + seconds + " | " + dateStr;
        }
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        if (maDm === 'all') {
            const btnAll = document.getElementById('btn_cat_all');
            if (btnAll) btnAll.classList.add('active');
            document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => card.style.setProperty('display', 'block', 'important'));
        } else {
            const btn = document.getElementById('btn_cat_' + maDm);
            if (btn) btn.classList.add('active');
            document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
                const parent = card.closest('.pos-card-wrapper');
                if (card.dataset.madm === maDm) {
                    parent.style.setProperty('display', 'block', 'important');
                } else {
                    parent.style.setProperty('display', 'none', 'important');
                }
            });
        }
    }

    function filterBadge(tag) {
        document.querySelectorAll('#f_all, #f_new, #f_hot').forEach(btn => btn.classList.remove('active-filter', 'btn-light'));
        const activeBtn = document.getElementById('f_' + tag);
        if (activeBtn) activeBtn.classList.add('active-filter', 'btn-light');
        document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
            const isNew = card.dataset.isnew === 'true';
            const isHot = card.dataset.ishot === 'true';
            const parent = card.closest('.pos-card-wrapper');
            if (tag === 'all') {
                parent.style.setProperty('display', 'block', 'important');
            } else if (tag === 'new') {
                if (isNew) parent.style.setProperty('display', 'block', 'important');
                else parent.style.setProperty('display', 'none', 'important');
            } else if (tag === 'hot') {
                if (isHot) parent.style.setProperty('display', 'block', 'important');
                else parent.style.setProperty('display', 'none', 'important');
            }
        });
    }

    function searchPOSProduct() {
        const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
        document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
            const name = card.querySelector('.pos-card-name').innerText.toLowerCase();
            const id = card.dataset.masp.toLowerCase();
            const parent = card.closest('.pos-card-wrapper');
            if (name.includes(keyword) || id.includes(keyword)) {
                parent.style.setProperty('display', 'block', 'important');
            } else {
                parent.style.setProperty('display', 'none', 'important');
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        const orderId = urlParams.get('orderId');
        const maPt = urlParams.get('maPt');
        const payable = urlParams.get('payable');
        if (msg === 'createsuccess' && orderId) {
            if (maPt === '2') {
                showPosQrCodeModal(orderId, payable);
            } else {
                loadAndShowPrintReceipt(orderId);
            }
        }
    });
</script>

<c:forEach var="sp" items="${products}">
    <script>
        window['sp_opt_' + '${sp.maSp}'] = {
            choPhepDoiDa: ${sp.choPhepDoiDa},
            choPhepDoiDuong: ${sp.choPhepDoiDuong},
            choPhepTopping: ${sp.choPhepTopping},
            allToppings: ${allToppingsJson},
            sizesList: [
                <c:forEach var="sz" items="${sp.sizesList}" varStatus="sLoop">
                {
                    maSize: ${sz.maSize},
                    tenSize: '${not empty sz.tenSize ? sz.tenSize : (sz.maSize == 1 ? "S" : (sz.maSize == 2 ? "M" : "L"))}',
                    giaBan: ${sz.giaBan}
                }${not sLoop.last ? ',' : ''}
                </c:forEach>
            ]
        };
    </script>
</c:forEach>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
</body>
</html>