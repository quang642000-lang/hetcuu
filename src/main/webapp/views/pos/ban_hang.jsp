<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Bán Hàng Tại Chỗ & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
    <style>
        :root {
            --pos-bg: #f8fafc;
            --pos-panel-bg: #ffffff;
            --pos-primary: #10b981;
            --pos-primary-dark: #059669;
            --pos-secondary: #0f172a;
            --pos-border: #e2e8f0;
            --pos-active-light: #ecfdf5;
            --pos-text-main: #1e293b;
            --pos-text-muted: #64748b;
        }
        html, body {
            height: 100vh;
            overflow: hidden;
            background-color: var(--pos-bg);
            color: var(--pos-text-main);
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }
        .pos-layout {
            display: flex;
            height: calc(100vh - 60px);
            overflow: hidden;
        }
        .pos-category-sidebar {
            width: 110px;
            background-color: var(--pos-secondary);
            display: flex;
            flex-direction: column;
            border-right: 1px solid var(--pos-border);
            overflow-y: auto;
            flex-shrink: 0;
            z-index: 10;
        }
        .pos-category-btn {
            width: 100%;
            padding: 16px 8px;
            border: none;
            background: transparent;
            color: #94a3b8;
            font-size: 11px;
            font-weight: 700;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            cursor: pointer;
            transition: all 0.2s ease-in-out;
            border-bottom: 1px solid #1e293b;
        }
        .pos-category-btn i {
            font-size: 24px;
            transition: transform 0.2s ease;
        }
        .pos-category-btn:hover {
            color: #ffffff;
            background-color: #1e293b;
        }
        .pos-category-btn:hover i {
            transform: scale(1.1);
        }
        .pos-category-btn.active {
            color: #ffffff;
            background-color: var(--pos-primary);
            border-left: 4px solid #ffffff;
        }
        .pos-menu-area {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background-color: var(--pos-bg);
            overflow: hidden;
            border-right: 1px solid var(--pos-border);
        }
        .pos-menu-header {
            padding: 14px 20px;
            background-color: #ffffff;
            border-bottom: 1px solid var(--pos-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }
        .pos-search-wrapper {
            position: relative;
            flex-grow: 1;
            max-width: 480px;
        }
        .pos-search-input {
            width: 100%;
            padding: 10px 16px 10px 40px;
            font-size: 13.5px;
            font-weight: 500;
            border: 1.5px solid var(--pos-border);
            border-radius: 20px;
            background-color: var(--pos-bg);
            transition: all 0.25s ease;
        }
        .pos-search-input:focus {
            outline: none;
            border-color: var(--pos-primary);
            background-color: #ffffff;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }
        .pos-search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--pos-text-muted);
            font-size: 16px;
        }
        .pos-product-container {
            flex-grow: 1;
            overflow-y: auto;
            padding: 20px;
        }
        .pos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 16px;
        }
        .pos-card {
            background-color: #ffffff;
            border-radius: 12px;
            border: 1px solid var(--pos-border);
            padding: 10px;
            text-align: center;
            cursor: pointer;
            position: relative;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            user-select: none;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 190px;
        }
        .pos-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 18px rgba(0, 0, 0, 0.04);
            border-color: var(--pos-primary);
        }
        .pos-card-img-wrapper {
            position: relative;
            width: 100%;
            height: 95px;
            border-radius: 8px;
            overflow: hidden;
            background-color: var(--pos-bg);
            margin-bottom: 8px;
        }
        .pos-card-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .pos-card-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--pos-text-main);
            line-height: 1.4;
            height: 36px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            margin-bottom: 4px;
        }
        .pos-card-price {
            font-size: 13px;
            font-weight: 800;
            color: var(--pos-primary);
        }
        .pos-billing-area {
            width: 420px;
            background-color: #ffffff;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            z-index: 10;
        }
        .pos-billing-header {
            height: 60px;
            padding: 0 20px;
            border-bottom: 1px solid var(--pos-border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: #ffffff;
        }
        .pos-cart-items-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            background-color: #ffffff;
        }
        .pos-bill-item {
            padding: 14px 20px;
            border-bottom: 1px solid var(--pos-border);
            display: flex;
            align-items: flex-start;
            gap: 12px;
            transition: background-color 0.2s ease;
        }
        .pos-bill-item:hover {
            background-color: var(--pos-bg);
        }
        .pos-bill-item-details {
            flex-grow: 1;
        }
        .pos-bill-item-title {
            font-size: 13px;
            font-weight: 700;
            color: var(--pos-text-main);
            margin-bottom: 2px;
        }
        .pos-bill-item-options {
            font-size: 11px;
            color: var(--pos-text-muted);
            line-height: 1.5;
        }
        .pos-bill-item-price {
            font-size: 13px;
            font-weight: 700;
            color: var(--pos-primary);
            margin-top: 4px;
        }
        .pos-crm-panel {
            padding: 14px 20px;
            background-color: var(--pos-bg);
            border-top: 1.5px solid var(--pos-border);
            border-bottom: 1.5px solid var(--pos-border);
        }
        .pos-checkout-panel {
            padding: 16px 20px;
            background-color: #ffffff;
        }
        .pos-line-price {
            display: flex;
            justify-content: space-between;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 500;
            color: var(--pos-text-muted);
        }
        .pos-total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1.5px dashed var(--pos-border);
            margin-bottom: 12px;
        }
        .pos-total-label {
            font-size: 14px;
            font-weight: 800;
            color: var(--pos-text-main);
        }
        .pos-total-val {
            font-size: 22px;
            font-weight: 800;
            color: #dc2626;
        }
        .pos-cash-calculator {
            background-color: var(--pos-bg);
            border-radius: 8px;
            padding: 8px 12px;
            margin-bottom: 12px;
            border: 1px solid var(--pos-border);
        }
        .pos-cash-suggest-btn {
            background: #ffffff;
            border: 1px solid var(--pos-border);
            border-radius: 4px;
            padding: 4px 8px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .pos-cash-suggest-btn:hover {
            background-color: var(--pos-primary-dark);
            color: #ffffff;
            border-color: var(--pos-primary-dark);
        }
        .pos-btn-submit {
            background-color: var(--pos-primary);
            color: #ffffff;
            font-size: 15px;
            font-weight: 800;
            border: none;
            width: 100%;
            padding: 14px;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(16, 185, 129, 0.2);
            transition: all 0.2s ease-in-out;
        }
        .pos-btn-submit:hover {
            background-color: var(--pos-primary-dark);
            transform: translateY(-1px);
            box-shadow: 0 6px 14px rgba(16, 185, 129, 0.3);
        }
    </style>
</head>
<body>
<!-- HEADER MÁY POS -->
<nav class="navbar navbar-dark bg-dark px-3 shadow-sm" style="height: 60px; z-index: 100;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
            <i class="bi bi-cup-hot-fill me-2 fs-4 text-success"></i>
            <span>TEA POS PRO</span>
            <span class="badge bg-success-subtle text-success border border-success ms-2 font-monospace" style="font-size: 10px; padding: 3px 6px;">V2.5 STABLE</span>
        </a>
        <div class="d-flex align-items-center gap-2 border-start ps-3 border-secondary" style="height: 30px;">
            <a href="${pageContext.request.contextPath}/pos" class="btn btn-sm btn-success fw-bold px-3">
                <i class="bi bi-cart-fill me-1 text-warning"></i> BÁN TẠI QUẦY
            </a>
            <a href="${pageContext.request.contextPath}/pos/nhandon" class="btn btn-sm btn-outline-light fw-bold px-3">
                <i class="bi bi-bell-fill me-1"></i> ĐƠN ONLINE
            </a>
        </div>
        <div class="d-flex align-items-center gap-3 text-white ms-auto">
            <span class="small fw-semibold border-end pe-3 border-secondary d-none d-md-inline">
                <i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
            </span>
            <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline">
                <i class="bi bi-clock-fill me-1 text-warning"></i> <span id="posCurrentClock">00:00:00</span>
            </span>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-xs btn-outline-success border-2 fw-bold text-uppercase" style="font-size: 11px;">
                <i class="bi bi-shield-lock-fill me-1"></i> Quản trị Admin
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-xs btn-outline-danger border-2">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</nav>

<div class="pos-layout">
    <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÁI -->
    <div class="pos-category-sidebar">
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

    <!-- CỘT 2: LƯỚI SẢN PHẨM -->
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
                    <script>
                        window['sp_opt_' + '${sp.maSp}'] = {
                            choPhepDoiDa: ${sp.choPhepDoiDa},
                            choPhepDoiDuong: ${sp.choPhepDoiDuong},
                            sizes: [
                                <c:forEach var="sz" items="${sp.sizesList}" varStatus="sLoop">
                                { maSize: ${sz.maSize}, tenSize: '${sz.tenSize}', giaBan: ${sz.giaBan} }${not sLoop.last ? ',' : ''}
                                </c:forEach>
                            ],
                            allToppings: [
                                <c:forEach var="tp" items="${toppings}" varStatus="tLoop">
                                { maTp: ${tp.maTp}, tenTp: '${tp.tenTp}', giaBan: ${tp.giaBan}, hinhAnh: '${tp.hinhAnh}' }${not tLoop.last ? ',' : ''}
                                </c:forEach>
                            ]
                        };
                    </script>
                    <div class="pos-card-wrapper">
                        <!-- HOÀN TOÀN QUOTE-SAFE: Đọc dữ liệu qua data attribute để tránh lỗi gãy nháy compile JSP -->
                        <div class="pos-card"
                             data-masp="${sp.maSp}"
                             data-madm="${sp.maDm}"
                             data-isnew="${sp.isNew}"
                             data-ishot="${sp.isBestseller}"
                             data-tensp="${sp.tenSp}"
                             onclick="handlePosCardClick(this)">
                            <div class="pos-card-img-wrapper">
                                <c:choose>
                                    <c:when test="${not empty sp.hinhAnh}">
                                        <img src="${sp.hinhAnh}" class="pos-card-img" alt="Ảnh">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="w-100 h-100 d-flex align-items-center justify-content-center bg-light">
                                            <i class="bi bi-cup-straw fs-2 text-muted"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${sp.isNew}">
                                    <span class="position-absolute top-0 start-0 badge bg-warning text-dark m-1" style="font-size: 9px; font-weight: 800;">MỚI</span>
                                </c:if>
                                <c:if test="${sp.isBestseller}">
                                    <span class="position-absolute top-0 end-0 badge bg-danger text-white m-1" style="font-size: 9px; font-weight: 800;">HOT</span>
                                </c:if>
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

    <!-- CỘT 3: CHI TIẾT HÓA ĐƠN & THANH TOÁN -->
    <div class="pos-billing-area">
        <div class="pos-billing-header">
            <h6 class="fw-bold mb-0 text-dark d-flex align-items-center gap-2">
                <i class="bi bi-cart3 text-success fs-5"></i>
                <span>DANH SÁCH ORDER</span>
            </h6>
            <button type="button" class="btn btn-sm btn-outline-danger border-2 fw-bold" onclick="clearFullPosCart()">
                <i class="bi bi-trash3-fill"></i> Hủy đơn
            </button>
        </div>

        <div class="pos-cart-items-wrapper" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>
                <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>
            </div>
        </div>

        <!-- CRM ĐỐI SOÁT HỘI VIÊN -->
        <div class="pos-crm-panel">
            <div class="input-group input-group-sm mb-2 shadow-sm" style="border-radius: 6px; overflow: hidden;">
                <span class="input-group-text bg-white border-end-0 text-success"><i class="bi bi-telephone-fill"></i></span>
                <input type="text" class="form-control border-start-0 py-2" id="customerPhoneSearch" placeholder="Nhập Số Điện Thoại khách CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                <button class="btn btn-success fw-bold" type="button" onclick="searchCustomerCRM()">XÁC THỰC</button>
            </div>
            <div class="d-flex justify-content-between align-items-center">
                <div class="text-start">
                    <small class="text-muted d-block" style="font-size: 9px; letter-spacing: 0.5px; font-weight: 700;">HỘI VIÊN THANH TOÁN</small>
                    <strong class="text-success small" id="customerNameResult">Khách lẻ vãng lai</strong>
                </div>
                <span class="badge bg-secondary text-white py-1.5 px-3" id="customerPoints" style="border-radius: 50px;">Hạng: Mới | 0 Điểm</span>
            </div>
            <div id="posAddCustomerArea" style="display: none;" class="mt-2 border-top pt-2">
                <button type="button" class="btn btn-sm btn-primary w-100 fw-bold py-2" onclick="openQuickAddCustomerModal()">
                    <i class="bi bi-person-plus-fill"></i> ĐĂNG KÝ HỘI VIÊN VIP MỚI
                </button>
            </div>
            <div id="crmLoyaltyArea" style="display: none;" class="border-top pt-2 mt-2">
                <div class="row g-2">
                    <div class="col-6">
                        <button type="button" class="btn btn-sm btn-outline-success w-100 fw-bold py-2" onclick="showVoucherSelectionModal()"><i class="bi bi-ticket-perforated"></i> CHỌN VOUCHER</button>
                    </div>
                    <div class="col-6">
                        <button type="button" class="btn btn-sm btn-outline-primary w-100 fw-bold py-2" onclick="applyPointsDiscount()"><i class="bi bi-gem"></i> TIÊU ĐIỂM CRM</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- FORM GỬI THANH TOÁN -->
        <form id="posCheckoutForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST">
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

            <div class="pos-checkout-panel bg-white border-top">
                <div class="mb-2">
                    <div class="input-group input-group-sm shadow-sm" style="border-radius: 6px; overflow: hidden;">
                        <span class="input-group-text bg-white border-end-0 text-success"><i class="bi bi-ticket-perforated-fill"></i></span>
                        <input type="text" class="form-control border-start-0" id="manualVoucherInput" placeholder="Nhập mã Voucher thủ công...">
                        <button class="btn btn-outline-success fw-bold" type="button" onclick="applyManualVoucherCode()">ÁP MÃ</button>
                    </div>
                </div>
                <div class="pos-line-price">
                    <span>Tổng tiền nước & Toppings:</span>
                    <strong class="text-dark" id="totalRawPrice">0 đ</strong>
                </div>
                <div class="pos-line-price text-danger" id="summaryDiscountRow" style="display: none;">
                    <span>Khấu trừ Voucher giảm giá (<span id="txtAppliedCode" class="fw-bold"></span>):</span>
                    <strong id="totalDiscountPrice">-0 đ</strong>
                </div>
                <div class="pos-line-price text-primary" id="summaryPointsRow" style="display: none;">
                    <span>Quy đổi tích điểm <span id="txtUsedPoints" class="fw-bold">0</span> CRM:</span>
                    <strong id="totalPointsPrice">-0 đ</strong>
                </div>
                <div class="pos-line-price">
                    <span>Thuế GTGT VAT (8%):</span>
                    <strong class="text-dark" id="totalTaxPrice">0 đ</strong>
                </div>
                <div class="pos-total-row">
                    <span class="pos-total-label">TỔNG TIỀN PHẢI THU:</span>
                    <span class="pos-total-val" id="totalPayablePrice">0 đ</span>
                </div>

                <div class="pos-cash-calculator">
                    <div class="row align-items-center g-2 mb-2">
                        <div class="col-5">
                            <small class="fw-bold text-muted" style="font-size: 11px;">TIỀN KHÁCH ĐƯA:</small>
                        </div>
                        <div class="col-7">
                            <input type="number" id="inputCustomerCash" class="form-control form-control-sm text-end fw-bold" placeholder="Nhập số tiền..." onkeyup="calculateChangeRefund()" onchange="calculateChangeRefund()">
                        </div>
                    </div>
                    <div class="d-flex justify-content-between gap-1 mb-2">
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(100000)">100k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(200000)">200k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(500000)">500k</button>
                        <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(0)">ĐỦ</button>
                    </div>
                    <div class="d-flex justify-content-between text-dark fw-bold border-top pt-2 small">
                        <span>TIỀN THỐI LẠI KHÁCH:</span>
                        <span class="text-primary" id="txtCashRefund">0 đ</span>
                    </div>
                </div>

                <div class="mb-3">
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_cash" value="1" checked onclick="changePaymentMethod(1)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_cash"><i class="bi bi-cash-coin me-1"></i> TIỀN MẶT</label>
                        <input type="radio" class="btn-check" name="payment_method_group" id="pt_qr" value="2" onclick="changePaymentMethod(2)">
                        <label class="btn btn-outline-success py-2 fw-semibold" for="pt_qr"><i class="bi bi-qr-code-scan me-1"></i> CHUYỂN KHOẢN QR</label>
                    </div>
                </div>
                <button type="button" class="pos-btn-submit text-uppercase" onclick="submitPOSOrderTransaction()">
                    <i class="bi bi-printer-fill me-1"></i> Giao dịch & In hóa đơn
                </button>
            </div>
        </form>
    </div>
</div>

<!-- MODAL IN HÓA ĐƠN NHIỆT -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; font-size: 11px;">
                <div class="text-center mb-2">
                    <h6 class="fw-bold mb-0" style="letter-spacing: 0.5px; font-size: 13px;">TEA POS PRO - COFFEE & TEA</h6>
                    <span style="font-size: 9px; color: #555;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span><br>
                    <span style="font-size: 9px; color: #555;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px;">HÓA ĐƠN BÁN LẺ TẠI QUẦY</strong><br>
                    <span style="font-size: 9px;" id="billThoiGian"></span>
                </div>
                <div class="mb-2" style="font-size: 10px;">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer" style="font-size: 10px;"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="d-flex justify-content-between" style="font-size: 10px;">
                    <span>Tổng tiền nước:</span>
                    <strong id="billRawPrice"></strong>
                </div>
                <div class="d-flex justify-content-between text-danger" id="billDiscountRow" style="display: none; font-size: 10px;">
                    <span>Khấu trừ Voucher:</span>
                    <strong id="billDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between text-primary" id="billPointsRow" style="display: none; font-size: 10px;">
                    <span>Tiêu điểm CRM:</span>
                    <strong id="billPointsDiscount"></strong>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                <div class="d-flex justify-content-between fw-bold text-success fs-6" style="font-size: 12px;">
                    <span>CẦN THANH TOÁN:</span>
                    <span id="billFinalPayable"></span>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="text-center mt-3" style="font-size: 9px; color: #444;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br>
                    <i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light d-flex justify-content-between">
                <button type="button" class="btn btn-xs btn-secondary fw-bold" data-bs-dismiss="modal" style="font-size: 11px;">Đóng</button>
                <button type="button" class="btn btn-xs btn-success fw-bold" onclick="printReceipt()" style="font-size: 11px;"><i class="bi bi-printer"></i> In Ngay</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    // 1. Đồng hồ thời gian thực tại quầy thu ngân
    function updatePOSClock() {
        const now = new Date();
        document.getElementById('posCurrentClock').innerText = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    // 2. Định dạng SĐT và gọi Ajax tìm khách hàng CRM
    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    // 3. Tính toán tiền trả lại khách hàng
    function calculateChangeRefund() {
        const totalPayable = parseInt(document.getElementById('totalPayablePrice').innerText.replace(/\D/g, '')) || 0;
        const customerCash = parseInt(document.getElementById('inputCustomerCash').value) || 0;
        let refund = customerCash - totalPayable;
        if (refund < 0) {
            document.getElementById('txtCashRefund').innerText = 'Khách đưa thiếu';
            document.getElementById('txtCashRefund').className = 'text-danger';
        } else {
            document.getElementById('txtCashRefund').innerText = refund.toLocaleString('vi-VN') + ' đ';
            document.getElementById('txtCashRefund').className = 'text-primary fw-bold';
        }
    }

    // Gợi ý bấm nhanh tiền mặt
    function suggestCashAmount(amount) {
        const totalPayable = parseInt(document.getElementById('totalPayablePrice').innerText.replace(/\D/g, '')) || 0;
        if (amount === 0) {
            document.getElementById('inputCustomerCash').value = totalPayable;
        } else {
            document.getElementById('inputCustomerCash').value = amount;
        }
        calculateChangeRefund();
    }

    // 4. Lọc sản phẩm theo danh mục sidebar trái
    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        if (maDm === 'all') {
            document.getElementById('btn_cat_all').classList.add('active');
            document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => card.style.display = 'block');
        } else {
            document.getElementById('btn_cat_' + maDm).classList.add('active');
            document.querySelectorAll('#posProductGrid .pos-card').forEach(card => {
                const parent = card.closest('.pos-card-wrapper');
                if (parseInt(card.dataset.madm) === maDm) {
                    parent.style.display = 'block';
                } else {
                    parent.style.display = 'none';
                }
            });
        }
    }

    // 5. Lọc nhanh theo nhãn (NEW, HOT, ALL)
    function filterBadge(type) {
        document.querySelectorAll('.btn-group .btn').forEach(btn => btn.classList.remove('btn-light', 'active-filter'));
        document.querySelectorAll('.btn-group .btn').forEach(btn => btn.classList.add('btn-outline-secondary'));
        const activeBtn = document.getElementById('f_' + type);
        if (activeBtn) {
            activeBtn.classList.remove('btn-outline-secondary');
            activeBtn.classList.add('btn-light', 'active-filter');
        }
        document.querySelectorAll('#posProductGrid .pos-card').forEach(card => {
            const parent = card.closest('.pos-card-wrapper');
            if (type === 'all') {
                parent.style.display = 'block';
            } else if (type === 'new') {
                parent.style.display = card.dataset.isnew === 'true' ? 'block' : 'none';
            } else if (type === 'hot') {
                parent.style.display = card.dataset.ishot === 'true' ? 'block' : 'none';
            }
        });
    }

    // 6. Tra cứu nhanh realtime không độ trễ
    function searchPOSProduct() {
        const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
        document.querySelectorAll('#posProductGrid .pos-card').forEach(card => {
            const name = card.querySelector('.pos-card-name').innerText.toLowerCase();
            const id = card.dataset.masp.toLowerCase();
            const parent = card.closest('.pos-card-wrapper');
            if (name.includes(keyword) || id.includes(keyword)) {
                parent.style.display = 'block';
            } else {
                parent.style.display = 'none';
            }
        });
    }

    // 7. Hủy toàn bộ giỏ hàng
    function clearFullPosCart() {
        posCart = [];
        resetVoucherAndPoints();
        renderPosCart();
        document.getElementById('inputCustomerCash').value = '';
        document.getElementById('txtCashRefund').innerText = '0 đ';
    }

    function resetVoucherAndPoints() {
        appliedVoucher = null;
        appliedPoints = 0;
        document.getElementById("submit_maKm").value = "";
        document.getElementById("submit_tienGiamGia").value = "0";
        document.getElementById("submit_diemSuDung").value = "0";
        document.getElementById("submit_tienTruDiem").value = "0";
        document.getElementById("summaryDiscountRow").style.display = "none";
        document.getElementById("summaryPointsRow").style.display = "none";
        document.getElementById("manualVoucherInput").value = "";
    }

    // 8. Đổi phương thức thanh toán
    function changePaymentMethod(maPt) {
        document.getElementById('submit_maPt').value = maPt;
    }

    // 9. Submit đơn hàng POS - THỜI THƯỢNG, BẢO MẬT & QUOTE-SAFE
    function submitPOSOrderTransaction() {
        if (posCart.length === 0) {
            showToast('warning', 'Giỏ hàng POS trống, không thể in hóa đơn!');
            return;
        }
        const container = document.getElementById('submitItemsContainer');
        container.innerHTML = '';
        posCart.forEach(item => {
            container.innerHTML += '<input type="hidden" name="item_maSp[]" value="' + item.maSp + '">';
            container.innerHTML += '<input type="hidden" name="item_maSize[]" value="' + item.maSize + '">';
            container.innerHTML += '<input type="hidden" name="item_soLuong[]" value="' + item.soLuong + '">';
            container.innerHTML += '<input type="hidden" name="item_giaChot[]" value="' + item.giaBan + '">';
            container.innerHTML += '<input type="hidden" name="item_mucDa[]" value="' + item.mucDa + '">';
            container.innerHTML += '<input type="hidden" name="item_mucDuong[]" value="' + item.mucDuong + '">';
            container.innerHTML += '<input type="hidden" name="item_ghiChuMon[]" value="' + (item.ghiChuMon ? item.ghiChuMon : 'Normal') + '">';

            // Map mảng topping định dạng chuẩn: maTp_soLuong_giaTp
            let toppingKeys = item.toppings.map(t => t.maTp + "_" + t.soLuongTp + "_" + t.giaTp).join("|");
            container.innerHTML += '<input type="hidden" name="item_toppingKeys[]" value="' + toppingKeys + '">';
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
            text: 'Tiến hành in hóa đơn bán lẻ và đồng bộ ví điểm CRM cho khách hàng?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý & In Bill'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('posCheckoutForm').submit();
            }
        });
    }

    // 10. Đóng gói click card gọi openCustomizePopup an toàn tuyệt đối chống lỗi dấu nháy quote symbol
    function handlePosCardClick(cardElement) {
        const maSp = cardElement.getAttribute('data-masp');
        const tenSp = cardElement.getAttribute('data-tensp');
        const optionsObj = window['sp_opt_' + maSp];
        openCustomizePopup(maSp, tenSp, encodeURIComponent(JSON.stringify(optionsObj)));
    }
</script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
<script>
    // Lắng nghe xem có hóa đơn in từ backend trả về không
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const orderId = urlParams.get('orderId');
        if (orderId) {
            Swal.fire({
                icon: 'success',
                title: 'Thanh toán hoàn tất',
                html: 'Hóa đơn quầy <strong>' + orderId + '</strong> đã lưu thành công! Tiến hành xuất in Bill nhiệt và hoàn ca?',
                showCancelButton: true,
                confirmButtonColor: '#10b981',
                cancelButtonColor: '#64748b',
                confirmButtonText: '<i class="bi bi-printer"></i> In Hóa Đơn',
                cancelButtonText: 'Đơn Hàng Mới'
            }).then((result) => {
                if (result.isConfirmed) {
                    loadAndShowPrintReceipt(orderId);
                } else {
                    window.location.href = '${pageContext.request.contextPath}/pos';
                }
            });
        }
    });

    function getContextPath() {
        return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    }
</script>
</body>
</html>