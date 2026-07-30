<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Thu Ngân & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Link CSS Frameworks & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>

    <style>
        :root {
            --primary: #10b981;
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --border-color: #e2e8f0;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.05);
            --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);
        }

        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background-color: #f8fafc;
            color: var(--text-main);
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        /* 3-COLUMNS SYSTEM CONTAINER */
        .pos-main-container {
            display: flex;
            height: calc(100vh - 60px);
            overflow: hidden;
            background-color: #f1f5f9;
        }

        /* COLUMN 1: Category Sidebar (Left) */
        .pos-category-sidebar {
            width: 120px;
            background-color: #ffffff;
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            flex-shrink: 0;
            z-index: 10;
        }

        .pos-category-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 16px 8px;
            border: none;
            background: transparent;
            color: var(--text-muted);
            font-size: 11.5px;
            font-weight: 700;
            gap: 6px;
            cursor: pointer;
            transition: all 0.2s ease;
            border-bottom: 1px solid var(--border-color);
            text-align: center;
            text-transform: uppercase;
        }

        .pos-category-btn i {
            font-size: 22px;
        }

        .pos-category-btn:hover, .pos-category-btn.active {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        /* COLUMN 2: Products Menu Area (Center) */
        .pos-menu-area {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 16px;
            background-color: #f8fafc;
        }

        .pos-menu-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .pos-search-wrapper {
            position: relative;
            flex-grow: 1;
            max-width: 400px;
        }

        .pos-search-input {
            width: 100%;
            height: 40px;
            padding: 8px 16px 8px 40px;
            border: 1px solid var(--border-color);
            border-radius: 50px;
            font-size: 13.5px;
            outline: none;
            box-shadow: var(--shadow-sm);
            transition: all 0.15s;
        }

        .pos-search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }

        .pos-search-wrapper i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 16px;
        }

        .active-filter {
            background-color: var(--primary) !important;
            color: #ffffff !important;
        }

        /* Products Grid styling */
        .pos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 16px;
        }

        .pos-card-wrapper {
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .pos-card-wrapper:hover {
            transform: translateY(-4px);
        }

        .pos-product-card {
            background-color: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 12px;
            display: flex;
            flex-direction: column;
            height: 100%;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            position: relative;
            user-select: none;
        }

        .pos-card-img-container {
            width: 100%;
            height: 120px;
            border-radius: var(--radius-sm);
            overflow: hidden;
            background-color: #f1f5f9;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .pos-card-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .pos-card-name {
            font-size: 13.5px;
            font-weight: 700;
            color: var(--text-main);
            height: 38px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            margin-bottom: 4px;
            line-height: 1.4;
            text-align: left;
        }

        .pos-card-price {
            font-size: 13.5px;
            font-weight: 800;
            color: var(--primary-dark);
            margin-top: auto;
            text-align: left;
        }

        /* COLUMN 3: Checkout Sidebar (Right) */
        .pos-checkout-sidebar {
            width: 410px;
            background-color: #ffffff;
            border-left: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            height: 100%;
            flex-shrink: 0;
            z-index: 10;
        }

        .pos-checkout-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #fff;
        }

        .pos-cart-items-wrapper {
            flex-grow: 1;
            padding: 16px 20px;
            overflow-y: auto;
            background-color: #f8fafc;
        }

        /* Cart Item Styling */
        .pos-cart-item {
            background-color: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 12px;
            margin-bottom: 10px;
            box-shadow: var(--shadow-sm);
        }

        /* CRM Loyalty, Vouchers & Summary Panels */
        .pos-crm-panel {
            padding: 16px 20px;
            background-color: #ffffff;
            border-top: 1px solid var(--border-color);
        }

        .pos-summary-panel {
            padding: 16px 20px;
            background-color: #ffffff;
            border-top: 1px solid var(--border-color);
        }

        .pos-line-price {
            display: flex;
            justify-content: space-between;
            font-size: 12.5px;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .pos-total-row {
            display: flex;
            justify-content: space-between;
            font-weight: 800;
            font-size: 17px;
            color: var(--text-main);
            border-top: 1px dashed var(--border-color);
            padding-top: 10px;
            margin-top: 10px;
            margin-bottom: 12px;
        }

        .pos-cash-suggest-btn {
            background-color: #f1f5f9;
            border: 1px solid #cbd5e1;
            padding: 5px 10px;
            font-size: 11px;
            font-weight: 700;
            border-radius: 4px;
            color: #475569;
            flex: 1;
            transition: all 0.15s;
            cursor: pointer;
        }

        .pos-cash-suggest-btn:hover {
            background-color: #e2e8f0;
            color: #0f172a;
        }

        /* Receipt/Bill print template styling */
        .receipt-container {
            font-family: 'Courier New', Courier, monospace;
            color: #000;
        }

        /* RESPONSIVE LAYOUT BREAKPOINTS */
        @media (max-width: 1024px) {
            .pos-main-container {
                flex-direction: column !important;
            }

            .pos-category-sidebar {
                width: 100% !important;
                height: auto !important;
                flex-direction: row !important;
                overflow-x: auto !important;
                border-right: none !important;
                border-bottom: 1px solid var(--border-color) !important;
            }

            .pos-category-btn {
                min-width: 90px !important;
                padding: 10px !important;
                border-bottom: none !important;
                border-top: 3px solid transparent !important;
            }

            .pos-category-btn.active {
                border-top-color: var(--primary) !important;
                border-left: none !important;
            }

            .pos-grid {
                grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)) !important;
            }

            .pos-checkout-sidebar {
                width: 100% !important;
                height: 55vh !important;
                border-left: none !important;
                border-top: 2px solid var(--primary) !important;
                box-shadow: 0 -4px 15px rgba(0,0,0,0.05) !important;
            }
        }
    </style>
</head>
<body>

<!-- CORE HEADER NAVIGATION -->
<nav class="navbar navbar-dark bg-dark px-3 sticky-top" style="height: 60px; z-index: 100;">
    <div class="container-fluid">
        <div class="d-flex align-items-center gap-3">
            <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
                <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
                <span>TEA POS PRO</span>
            </a>

            <!-- Tab Switching Panel -->
            <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
                <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-success fw-bold px-3">
                    <i class="bi bi-cart-fill me-1 text-warning"></i> BÁN TẠI QUẦY
                </a>
                <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-outline-light fw-bold px-3">
                    <i class="bi bi-bell-fill me-1"></i> ĐƠN ONLINE
                </a>
            </div>
        </div>

        <!-- Profile Clock and Cashier User settings -->
        <div class="d-flex align-items-center gap-3 text-white ms-auto">
            <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline" id="posHeaderClock">Loading...</span>

            <div class="dropdown">
                <a class="dropdown-toggle text-decoration-none text-white fw-bold small d-flex align-items-center gap-1.5" href="#" role="button" id="posProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-circle fs-5 text-success"></i>
                    <span><c:out value="${sessionScope.user.hoTen != null ? sessionScope.user.hoTen : 'Nhân viên'}"/></span>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2 rounded-3" aria-labelledby="posProfileMenu">
                    <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posProfileModal"><i class="bi bi-person-circle me-2 text-success"></i>Cài đặt cá nhân</a></li>
                    <li><a class="dropdown-item py-2" href="#" data-bs-toggle="modal" data-bs-target="#posPasswordModal"><i class="bi bi-key-fill me-2 text-warning"></i>Đổi mật khẩu</a></li>
                </ul>
            </div>

            <a href="${pageContext.request.contextPath}/logout" class="btn btn-xs btn-outline-danger fw-bold rounded px-2.5 py-1" style="font-size:11px;">
                <i class="bi bi-box-arrow-right me-1"></i> ĐĂNG XUẤT
            </a>
        </div>
    </div>
</nav>

<!-- CORE 3-COLUMNS SYSTEM CONTAINER -->
<div class="pos-main-container" id="posMainContainer">

    <!-- COLUMN 1: Category Sidebar (Left) -->
    <div class="pos-category-sidebar">
        <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
            <i class="bi bi-grid-fill fs-4 mb-1"></i>
            <span>TẤT CẢ</span>
        </button>
        <c:forEach var="cat" items="${categories}">
            <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory('${cat.maDm}')">
                <c:choose>
                    <c:when test="${not empty cat.hinhAnh}">
                        <img src="${cat.hinhAnh}" class="rounded-circle mb-1" style="width:24px; height:24px; object-fit:cover;">
                    </c:when>
                    <c:otherwise>
                        <i class="bi bi-cup-straw mb-1"></i>
                    </c:otherwise>
                </c:choose>
                <span><c:out value="${cat.tenDm}"/></span>
            </button>
        </c:forEach>
    </div>

    <!-- COLUMN 2: Products Area (Center Grid) -->
    <div class="pos-menu-area">
        <div class="pos-menu-header">
            <div class="pos-search-wrapper">
                <i class="bi bi-search"></i>
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
                             onclick="openCustomizePopup('${sp.maSp}', this.querySelector('.pos-card-name').innerText.trim())">
                            <div class="pos-card-img-container">
                                <c:choose>
                                    <c:when test="${not empty sp.hinhAnh}">
                                        <img src="${sp.hinhAnh}" alt="Pic">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="bi bi-cup-straw fs-2 text-muted"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="pos-card-name"><c:out value="${sp.tenSp}"/></div>
                            <div class="pos-card-price text-success fw-bold">
                                <c:forEach var="sz" items="${sp.sizesList}" end="0">
                                    <fmt:formatNumber value="${sz.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- COLUMN 3: POS Basket / Cart (Right) -->
    <div class="pos-checkout-sidebar">
        <div class="pos-checkout-header">
            <h5 class="fw-bold mb-0 text-dark d-flex align-items-center gap-1.5"><i class="bi bi-receipt-cutoff text-success"></i> GIỎ HÀNG</h5>
            <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="clearFullPosCart()">
                <i class="bi bi-trash3-fill"></i> Hủy đơn
            </button>
        </div>

        <!-- Dynamic basket items container -->
        <div class="pos-cart-items-wrapper" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>
                <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>
            </div>
        </div>

        <!-- CRM Loyalty Member Panel -->
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

        <!-- Receipt calculation and checkout panel -->
        <div class="pos-summary-panel">
            <div class="d-flex gap-1.5 mb-3">
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
                <span class="text-success" id="totalPayablePrice">0 đ</span>
            </div>

            <!-- Cash Calculator given vs refund -->
            <div class="mt-2 text-start p-2.5 rounded bg-light border mb-3" id="cashCalculatorSection">
                <div class="d-flex justify-content-between align-items-center mb-1.5">
                    <small class="fw-bold text-muted small"><i class="bi bi-cash-stack"></i> KHÁCH ĐƯA (VNĐ):</small>
                    <input type="number" class="form-control form-control-sm text-end fw-bold text-success font-monospace" id="inputCustomerCash" value="0" style="width: 140px; height: 28px;" onkeyup="calculatePOSCashRefund()">
                </div>
                <div class="d-flex gap-1 mb-2">
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(50000)">50k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(100000)">100k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(200000)">200k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(500000)">500k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(0)">ĐỦ</button>
                </div>
                <div class="d-flex justify-content-between text-dark fw-bold border-top pt-2 small">
                    <span>TIỀN THỐI LẠI:</span>
                    <span id="txtCashRefund" class="text-success font-monospace fw-bold">0 đ</span>
                </div>
            </div>

            <!-- Payment methods selection -->
            <div class="mb-3 text-start">
                <label class="form-label text-muted small fw-bold mb-1"><i class="bi bi-wallet2"></i> PHƯƠNG THỨC THANH TOÁN:</label>
                <div class="btn-group w-100" role="group">
                    <input type="radio" class="btn-check" name="payment_method_group" id="pt_cash" value="1" checked onchange="changePaymentMethod(1)">
                    <label class="btn btn-outline-success py-2 fw-semibold" for="pt_cash">
                        <i class="bi bi-cash-coin me-1"></i> TIỀN MẶT
                    </label>
                    <input type="radio" class="btn-check" name="payment_method_group" id="pt_qr" value="2" onchange="changePaymentMethod(2)">
                    <label class="btn btn-outline-success py-2 fw-semibold" for="pt_qr">
                        <i class="bi bi-qr-code-scan me-1"></i> CHUYỂN KHOẢN QR
                    </label>
                </div>
            </div>

            <!-- POS Hidden Forms for Transaction mapping -->
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
                <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_OFFLINE">
                <div id="posFormItemsContainer"></div>
            </form>

            <button type="button" class="btn btn-primary-teapos w-100 py-3 fs-5 fw-bold" onclick="submitPOSOrderTransaction()" style="background-color: var(--primary); border-color: var(--primary);">
                <i class="bi bi-printer me-1"></i> CHỐT ĐƠN & GIAO DỊCH
            </button>
        </div>
    </div>

</div>

<!-- PROFILE SETTING MODAL -->
<div class="modal fade" id="posProfileModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-person-gear text-success me-1"></i> HỒ SƠ THU NGÂN</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Mã Nhân Viên</label>
                    <input type="text" class="form-control bg-light text-muted" value="${sessionScope.user.maNv}" readonly>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Họ và Tên</label>
                    <input type="text" class="form-control" id="profile_hoTen" value="<c:out value='${sessionScope.user.hoTen}'/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Số điện thoại</label>
                    <input type="text" class="form-control" id="profile_sdt" value="${sessionScope.user.soDienThoai}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Địa chỉ Email</label>
                    <input type="email" class="form-control" id="profile_email" value="${sessionScope.user.email}" required>
                </div>
                <div class="mb-0">
                    <label class="form-label fw-bold small text-muted">Tên Đăng Nhập</label>
                    <input type="text" class="form-control bg-light text-muted" value="<c:out value='${sessionScope.user.tenDangNhap}'/>" readonly>
                </div>
            </div>
            <div class="modal-footer bg-light border-top p-2.5">
                <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-success btn-sm px-3" onclick="submitPosProfile()"><i class="bi bi-save me-1"></i> Lưu thay đổi</button>
            </div>
        </div>
    </div>
</div>

<!-- PASSWORD MODAL -->
<div class="modal fade" id="posPasswordModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-shield-lock-fill text-warning me-1"></i> ĐỔI MẬT KHẨU BẢO MẬT</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start">
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Mật khẩu hiện tại</label>
                    <input type="password" class="form-control" id="pass_old" required>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold small text-muted">Mật khẩu mới (Tối thiểu 8 ký tự)</label>
                    <input type="password" class="form-control" id="pass_new" required>
                </div>
                <div class="mb-0">
                    <label class="form-label fw-bold small text-muted">Xác nhận mật khẩu mới</label>
                    <input type="password" class="form-control" id="pass_confirm" required>
                </div>
            </div>
            <div class="modal-footer bg-light border-top p-2.5">
                <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-warning btn-sm px-3 fw-bold" onclick="submitPosPassword()"><i class="bi bi-save me-1"></i> Lưu mật khẩu mới</button>
            </div>
        </div>
    </div>
</div>

<!-- RECEIPT MODAL -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 340px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark text-start receipt-container" id="billPrintArea">
                <div class="text-center mb-2">
                    <strong style="font-size: 15px; letter-spacing: 1px; text-align: center; display: block;">TEA POS CAFÉ</strong>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px; text-align: center; display: block;">HÓA ĐƠN BÁN LẺ TẠI QUẦY</strong>
                    <span style="font-size: 10px; text-align: center; display: block;" id="billThoiGian"></span>
                </div>
                <div class="mb-2" style="font-size: 10px;">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer" style="font-size: 10.5px;"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="d-flex justify-content-between" style="font-size: 10px; margin-bottom: 2px;">
                    <span>Tổng tiền nước gốc:</span>
                    <strong id="billRawPrice"></strong>
                </div>
                <div class="d-flex justify-content-between text-danger" id="billDiscountRow" style="display: none; font-size: 10px; margin-bottom: 2px;">
                    <span>Khấu trừ Voucher:</span>
                    <strong id="billDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between text-primary" id="billPointsRow" style="display: none; font-size: 10px; margin-bottom: 2px;">
                    <span>Tiêu điểm CRM:</span>
                    <strong id="billPointsDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between" style="font-size: 10px; margin-bottom: 2px;">
                    <span>Thuế VAT (8%):</span>
                    <strong id="billVatPrice"></strong>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                <div class="d-flex justify-content-between fw-bold text-success" style="font-size: 12px; margin-bottom: 4px;">
                    <span>CẦN THANH TOÁN:</span>
                    <span id="billFinalPayable"></span>
                </div>
                <div class="d-flex justify-content-between text-muted" id="billCashGivenRow" style="font-size: 10px; margin-bottom: 2px; display: none;">
                    <span>Tiền mặt khách đưa:</span>
                    <span id="billCashGiven" class="fw-bold text-dark"></span>
                </div>
                <div class="d-flex justify-content-between text-muted" id="billCashRefundRow" style="font-size: 10px; margin-bottom: 2px; display: none;">
                    <span>Tiền thối lại:</span>
                    <span id="billCashRefund" class="fw-bold text-success"></span>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="text-center" style="font-size: 9px; color: #555; line-height: 1.3; margin-top: 10px;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br><i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-secondary fw-bold" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-sm btn-success fw-bold" onclick="printReceipt()"><i class="bi bi-printer"></i> In Hóa Đơn</button>
            </div>
        </div>
    </div>
</div>

<!-- VIETQR MODAL -->
<div class="modal fade" id="posQrModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false" style="z-index: 1065;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-2.5">
                <h6 class="modal-title fw-bold"><i class="bi bi-qr-code-scan text-success me-1"></i> VIETQR TỰ ĐỘNG</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="cancelQRPayment()"></button>
            </div>
            <div class="modal-body text-center bg-white p-4">
                <h3 class="text-danger fw-bold mb-1" id="posQrAmount">0 đ</h3>
                <p class="text-muted small mb-3">Mã đơn: <span class="fw-bold text-dark font-monospace" id="posQrCodeDisplay"></span></p>
                <div class="bg-light p-3 rounded-4 d-inline-block mb-3 position-relative border" style="border-radius: 12px !important;">
                    <img id="posQrImage" src="" alt="VietQR Payment Code" class="img-fluid" style="max-width: 200px; height: 200px; object-fit: contain;">
                    <div id="posQrSuccessOverlay" class="position-absolute top-0 start-0 w-100 h-100 bg-white bg-opacity-90 d-flex flex-column justify-content-center align-items-center" style="display: none !important; z-index: 10; backdrop-filter: blur(2px); border-radius: 12px;">
                        <i class="bi bi-check-circle-fill text-success" style="font-size: 3.5rem; animation: pulse 1.5s infinite;"></i>
                        <h6 class="text-success mt-2 fw-bold mb-0">Đã Khớp Số Dư!</h6>
                    </div>
                    <div id="posQrExpiredOverlay" class="position-absolute top-0 start-0 w-100 h-100 bg-white bg-opacity-90 d-flex flex-column justify-content-center align-items-center" style="display: none !important; z-index: 10; backdrop-filter: blur(2px); border-radius: 12px;">
                        <i class="bi bi-x-circle-fill text-danger" style="font-size: 3.5rem;"></i>
                        <h6 class="text-danger mt-2 fw-bold mb-0">Mã Đã Hết Hạn</h6>
                    </div>
                </div>
                <div class="text-danger fw-bold small mb-2 text-uppercase">
                    <i class="bi bi-clock-history"></i> Có hiệu lực trong <span id="posQrCountdownText" class="fs-5">120</span> giây
                </div>
                <div id="posQrLoadingStatus" class="text-success fw-bold small mb-0 d-flex align-items-center justify-content-center">
                    <div class="spinner-border spinner-border-sm text-success me-2" role="status"></div>
                    <span>Đang lắng nghe tài khoản ngân hàng...</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JAVASCRIPT GLOBAL OBJECTS BOOTSTRAP -->
<script>
    const allToppingsData = ${allToppingsJson != null ? allToppingsJson : "[]"};
</script>

<c:forEach var="sp" items="${products}">
    <script>
        window['sp_opt_' + '${sp.maSp}'] = {
            choPhepDoiDa: ${sp.choPhepDoiDa},
            choPhepDoiDuong: ${sp.choPhepDoiDuong},
            choPhepTopping: ${sp.choPhepTopping},
            allToppings: allToppingsData,
            sizesList: [
                <c:forEach var="sz" items="${sp.sizesList}" varStatus="sLoop">
                {
                    maSize: ${sz.maSize},
                    tenSize: '${sz.tenSize != null ? sz.tenSize : (sz.maSize == 1 ? "S" : (sz.maSize == 2 ? "M" : "L"))}',
                    giaBan: ${sz.giaBan}
                }${not sLoop.last ? ',' : ''}
                </c:forEach>
            ]
        };
    </script>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
</body>
</html>