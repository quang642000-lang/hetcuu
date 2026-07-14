<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Thu Ngân & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <!-- Custom styling -->
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
    <style>
        /* Khóa cứng cuộn trang ngoài, đảm bảo quầy POS chuẩn chỉ cuộn trong khung quy định */
        html, body {
            height: 100vh;
            overflow: hidden;
            background-color: #f1f5f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .pos-layout {
            display: flex;
            height: calc(100vh - 60px);
            overflow: hidden;
        }
        /* CỘT 1: Sidebar phân loại danh mục (Trái) */
        .pos-category-sidebar {
            width: 110px;
            background: #ffffff;
            border-right: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            flex-shrink: 0;
        }
        .pos-category-btn {
            width: 100%;
            padding: 15px 5px;
            border: none;
            background: transparent;
            text-align: center;
            font-size: 11px;
            font-weight: 700;
            color: #64748b;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s ease;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }
        .pos-category-btn:hover {
            background-color: #f8fafc;
            color: #10b981;
        }
        .pos-category-btn.active {
            background-color: #ecfdf5;
            color: #10b981;
            border-left: 4px solid #10b981;
        }
        /* CỘT 2: LƯỚI SẢN PHẨM (Giữa) */
        .pos-menu-area {
            flex-grow: 1;
            padding: 16px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            background-color: #f8fafc;
        }
        .pos-menu-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            flex-shrink: 0;
            gap: 16px;
        }
        .pos-search-wrapper {
            position: relative;
            flex-grow: 1;
            max-width: 450px;
        }
        .pos-search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        .pos-search-input {
            width: 100%;
            padding: 10px 16px 10px 38px;
            border-radius: 20px;
            border: 1px solid #cbd5e1;
            font-size: 13px;
            outline: none;
            transition: all 0.2s ease;
        }
        .pos-search-input:focus {
            border-color: #10b981;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }
        .pos-product-container {
            flex-grow: 1;
            overflow-y: auto;
            padding-right: 4px;
        }
        .pos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 16px;
        }
        .pos-card-wrapper {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.2s ease;
            cursor: pointer;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            position: relative;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .pos-card-wrapper:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
            border-color: #10b981;
        }
        .pos-card-img-container {
            width: 100%;
            height: 110px;
            background-color: #f1f5f9;
            overflow: hidden;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .pos-product-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .pos-card-name {
            padding: 8px 10px 4px 8px;
            font-size: 13px;
            font-weight: 600;
            color: #1e293b;
            text-align: left;
            line-height: 1.3;
            flex-grow: 1;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .pos-card-price {
            padding: 0 10px 10px 10px;
            text-align: left;
            font-size: 13px;
            font-weight: 700;
            color: #10b981;
        }
        /* CỘT 3: HÓA ĐƠN & THANH TOÁN (Phải) */
        .pos-billing-area {
            width: 420px;
            background-color: #ffffff;
            border-left: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            box-shadow: -4px 0 10px rgba(0,0,0,0.02);
            flex-shrink: 0;
        }
        .pos-billing-header {
            padding: 14px 16px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 60px;
            flex-shrink: 0;
            background-color: #ffffff;
        }
        .pos-cart-items-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            background-color: #ffffff;
        }
        .pos-bill-item {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            padding: 12px;
            background-color: #f8fafc;
            border-radius: 8px;
            border: 1px solid #f1f5f9;
            gap: 12px;
        }
        .pos-bill-item-details {
            flex-grow: 1;
            text-align: left;
        }
        .pos-bill-item-title {
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 2px;
        }
        .pos-bill-item-options {
            font-size: 11px;
            color: #64748b;
            line-height: 1.4;
        }
        .pos-bill-item-price {
            font-size: 13px;
            font-weight: 700;
            color: #10b981;
            margin-top: 4px;
        }
        /* CRM Panel & Checkout Panel */
        .pos-crm-panel {
            padding: 14px 16px;
            background-color: #f8fafc;
            border-top: 1px solid #e2e8f0;
            border-bottom: 1px solid #e2e8f0;
            flex-shrink: 0;
        }
        .pos-checkout-panel {
            padding: 16px;
            flex-shrink: 0;
        }
        .pos-line-price {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #64748b;
            margin-bottom: 6px;
        }
        .pos-total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #f1f5f9;
            padding-top: 8px;
            margin-top: 6px;
            margin-bottom: 12px;
        }
        .pos-total-label {
            font-size: 13px;
            font-weight: 800;
            color: #1e293b;
        }
        .pos-total-val {
            font-size: 18px;
            font-weight: 800;
            color: #ef4444;
        }
        .pos-cash-calculator {
            background-color: #f8fafc;
            border-radius: 8px;
            padding: 10px;
            border: 1px solid #e2e8f0;
            margin-bottom: 12px;
        }
        .pos-cash-suggest-btn {
            flex-grow: 1;
            border: 1px solid #cbd5e1;
            background-color: #ffffff;
            color: #475569;
            font-size: 11px;
            font-weight: 700;
            padding: 5px;
            border-radius: 4px;
            transition: all 0.15s ease;
        }
        .pos-cash-suggest-btn:hover {
            border-color: #10b981;
            color: #10b981;
            background-color: #ecfdf5;
        }
        .btn-primary-teapos {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border: none;
            color: #ffffff;
            font-weight: 700;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.2);
            transition: all 0.2s ease;
        }
        .btn-primary-teapos:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.3);
        }
        /* Custom styling for SweetAlert customizer */
        .selection-btn-group {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 12px;
        }
        .selection-radio-input {
            display: none;
        }
        .selection-label {
            padding: 6px 12px;
            border: 1.5px solid #cbd5e1;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            color: #475569;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .selection-radio-input:checked + .selection-label {
            border-color: #10b981;
            background-color: #ecfdf5;
            color: #10b981;
        }
    </style>
</head>
<body>

<!-- CHÂN TRANG ĐẦU ĐỒNG BỘ ĐIỀU HÀNH -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark px-3" style="height: 60px; z-index: 1000; background-color: #0f172a !important;">
    <div class="container-fluid">
        <a class="navbar-brand d-flex align-items-center fw-bold text-success fs-5" href="${pageContext.request.contextPath}/home">
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
            <!-- Thu ngân profile & settings trigger dropdown -->
            <div class="dropdown border-end pe-3 border-secondary d-none d-md-inline">
                <a class="dropdown-toggle text-decoration-none text-white small fw-semibold" href="#" role="button" id="adminProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                    <li><a class="dropdown-item py-2" href="#" onclick="openPOSSettingsModal()"><i class="bi bi-gear-fill me-2 text-success"></i>Cài đặt cá nhân</a></li>
                </ul>
            </div>
            <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline">
                <i class="bi bi-calendar-event me-1 text-info"></i> <span id="posDate">13/07/2026</span>
            </span>
            <span class="small font-monospace text-warning d-flex align-items-center gap-1.5" style="width: 80px;">
                <i class="bi bi-clock-fill"></i> <strong id="posClock">00:00:00</strong>
            </span>
            <div class="border-start ps-3 border-secondary">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success fw-bold" style="border-radius: 6px;">
                    <i class="bi bi-shield-shaded me-1"></i> Quản trị
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="pos-layout">
    <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÁI -->
    <div class="pos-category-sidebar">
        <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
            <i class="bi bi-grid-fill fs-4"></i>
            <span>TẤT CẢ</span>
        </button>
        <c:forEach var="cat" items="${categories}">
            <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory('${cat.maDm}')">
                <i class="bi bi-cup-straw fs-4"></i>
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
                    <!-- CẤU HÌNH DỮ LIỆU TÙY CHỌN SẢN PHẨM VỚI DẢI MÃ CHUỖI AN TOÀN -->
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
                                { maTp: '${tp.maTp}', tenTp: '${tp.tenTp}', giaBan: ${tp.giaBan}, hinhAnh: '${tp.hinhAnh}' }${not tLoop.last ? ',' : ''}
                                </c:forEach>
                            ]
                        };
                    </script>

                    <div class="pos-card-wrapper" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}">
                        <div class="pos-card-img-container" onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                            <c:choose>
                                <c:when test="${not empty sp.hinhAnh}">
                                    <img src="${sp.hinhAnh}" class="pos-product-img rounded" alt="Pic">
                                </c:when>
                                <c:otherwise>
                                    <div class="bg-light rounded d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 100%; height: 100%;">
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
                        <div class="pos-card-name" onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))"><c:out value="${sp.tenSp}"/></div>
                        <div class="pos-card-price text-success fw-bold">
                            <c:forEach var="sz" items="${sp.sizesList}" end="0">
                                <fmt:formatNumber value="${sz.giaBan}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                            </c:forEach>
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
            <div class="input-group input-group-sm mb-2">
                <span class="input-group-text bg-white border-end-0 text-success"><i class="bi bi-telephone-fill"></i></span>
                <input type="text" class="form-control border-start-0 py-2" id="customerPhoneSearch" placeholder="Nhập SĐT khách hàng tích điểm CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                <button class="btn btn-success fw-bold px-3" type="button" onclick="searchCustomerCRM()"><i class="bi bi-search"></i></button>
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
                <div class="mb-3">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light text-muted small"><i class="bi bi-ticket-perforated-fill"></i> Gõ mã Voucher thủ công:</span>
                        <input type="text" class="form-control" id="manualVoucherInput" placeholder="Ví dụ: OPEN10K...">
                        <button class="btn btn-outline-success fw-bold text-uppercase px-3" type="button" onclick="applyManualVoucherCode()">ÁP MÃ</button>
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

                <div class="pos-cash-calculator" id="cashCalculatorSection">
                    <div class="row align-items-center g-2 mb-2">
                        <div class="col-5">
                            <small class="fw-bold text-muted" style="font-size: 11px;">TIỀN KHÁCH ĐƯA:</small>
                        </div>
                        <div class="col-7">
                            <input type="number" id="inputCustomerCash" class="form-control form-control-sm text-end fw-bold border-secondary" placeholder="Nhập số tiền..." onkeyup="calculateChangeRefund()" onchange="calculateChangeRefund()">
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

<!-- MODAL CÀI ĐẶT THÔNG TIN TÀI KHOẢN NHÂN VIÊN THU NGÂN (POS PROFILE SETTINGS) -->
<div class="modal fade" id="posSettingsModal" tabindex="-1" aria-hidden="true" style="z-index: 1070;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-3">
                <h5 class="modal-title fw-bold"><i class="bi bi-gear-fill text-success me-2"></i>CÀI ĐẶT TÀI KHOẢN CÁ NHÂN</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light">
                <!-- Nav Tabs đổi phần thiết lập -->
                <ul class="nav nav-pills mb-3 bg-white p-1.5 rounded-pill border shadow-sm" id="posSettingsTab" role="tablist">
                    <li class="nav-item flex-fill text-center" role="presentation">
                        <button class="nav-link active rounded-pill py-2 w-100 fw-bold" id="pos-info-tab" data-bs-toggle="tab" data-bs-target="#posInfoPanel" type="button" role="tab">HỒ SƠ CỦA TÔI</button>
                    </li>
                    <li class="nav-item flex-fill text-center" role="presentation">
                        <button class="nav-link rounded-pill py-2 w-100 fw-bold" id="pos-pass-tab" data-bs-toggle="tab" data-bs-target="#posPassPanel" type="button" role="tab">ĐỔI MẬT KHẨU</button>
                    </li>
                </ul>
                <div class="tab-content bg-white p-4 rounded-3 border" id="posSettingsTabContent">
                    <!-- Tab Panel 1: Sửa thông tin cá nhân -->
                    <div class="tab-pane fade show active" id="posInfoPanel" role="tabpanel">
                        <form id="posInfoForm" onsubmit="submitPOSInfoForm(event)">
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Họ và tên đầy đủ</label>
                                <input type="text" name="hoTen" id="pos_hoTen" class="form-control" value="<c:out value='${sessionScope.user.hoTen}'/>" required autocomplete="off">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Số điện thoại di động</label>
                                <input type="text" name="soDienThoai" id="pos_sdt" class="form-control" value="${sessionScope.user.soDienThoai}" required autocomplete="off">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Địa chỉ Email</label>
                                <input type="email" name="email" id="pos_email" class="form-control" value="${sessionScope.user.email}" required autocomplete="off">
                            </div>
                            <button type="submit" class="btn btn-success w-100 fw-bold py-2"><i class="bi bi-check-circle-fill me-1"></i> CẬP NHẬT HỒ SƠ</button>
                        </form>
                    </div>
                    <!-- Tab Panel 2: Sửa mật khẩu -->
                    <div class="tab-pane fade" id="posPassPanel" role="tabpanel">
                        <form id="posPassForm" onsubmit="submitPOSPassForm(event)">
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Mật khẩu cũ hiện tại</label>
                                <input type="password" name="oldPassword" id="pos_oldPass" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Mật khẩu mới thay đổi</label>
                                <input type="password" name="newPassword" id="pos_newPass" class="form-control" required minlength="8">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Nhập lại mật khẩu mới</label>
                                <input type="password" name="confirmPassword" id="pos_confirmPass" class="form-control" required minlength="8">
                            </div>
                            <button type="submit" class="btn btn-primary-teapos w-100 py-2"><i class="bi bi-key-fill me-1"></i> THAY ĐỔI MẬT KHẨU</button>
                        </form>
                    </div>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light border-top-0 text-center d-block">
                <small class="text-muted">Mọi thay đổi dữ liệu sẽ được ghi nhận vào Audit Trail hệ thống</small>
            </div>
        </div>
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

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- Global App JS -->
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<!-- POS Operations JS Bundle -->
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>

<script>
    // 1. Đồng hồ thời gian hệ thống và ngày hiện hành
    function updatePOSClock() {
        const clockEl = document.getElementById('posClock');
        const dateEl = document.getElementById('posDate');
        if (clockEl) {
            const now = new Date();
            clockEl.innerText = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        }
        if (dateEl) {
            const now = new Date();
            const day = String(now.getDate()).padStart(2, '0');
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const year = now.getFullYear();
            dateEl.innerText = day + '/' + month + '/' + year;
        }
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    // 2. Định dạng SĐT và tự tìm khách hàng CRM khi đủ 10 số
    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    // 3. Thay đổi giao diện gợi ý tiền mặt và dọn dẹp khi chuyển QR
    function changePaymentMethod(maPt) {
        const submitPt = document.getElementById('submit_maPt');
        const cashSection = document.getElementById('cashCalculatorSection');
        if (submitPt) submitPt.value = maPt;

        if (maPt === 2) {
            // Chuyển khoản QR: Ẩn phần tiền mặt, bypass validation
            if (cashSection) cashSection.style.display = "none";
        } else {
            // Tiền mặt: Hiện lại calculator
            if (cashSection) cashSection.style.display = "block";
        }
    }

    // 4. Lọc sản phẩm theo danh mục sidebar trái - Hỗ trợ mốc chuỗi DMxxxxx
    function filterCategory(maDm) {
        // Active button styling
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.getElementById('btn_cat_' + maDm);
        if (activeBtn) activeBtn.classList.add('active');

        // Filter cards
        document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => {
            const rowMaDm = card.getAttribute('data-madm');
            if (maDm === 'all' || rowMaDm === maDm) {
                card.style.setProperty('display', 'block', 'important');
            } else {
                card.style.setProperty('display', 'none', 'important');
            }
        });
    }

    // 5. Bộ lọc tag đặc biệt (NEW, HOT, ALL)
    function filterBadge(type) {
        document.querySelectorAll('.btn-group .btn').forEach(btn => btn.classList.remove('btn-light', 'active-filter'));
        const activeBtn = document.getElementById('f_' + type);
        if (activeBtn) activeBtn.classList.add('btn-light', 'active-filter');

        document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => {
            if (type === 'all') {
                card.style.setProperty('display', 'block', 'important');
            } else if (type === 'new') {
                const isNew = card.getAttribute('data-isnew') === 'true';
                card.style.setProperty('display', isNew ? 'block' : 'none', 'important');
            } else if (type === 'hot') {
                const isHot = card.getAttribute('data-ishot') === 'true';
                card.style.setProperty('display', isHot ? 'block' : 'none', 'important');
            }
        });
    }

    // 6. Tra cứu nhanh realtime không độ trễ
    function searchPOSProduct() {
        const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
        document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => {
            const name = card.querySelector('.pos-card-name').innerText.toLowerCase();
            const id = card.getAttribute('data-masp').toLowerCase();
            if (name.includes(keyword) || id.includes(keyword)) {
                card.style.setProperty('display', 'block', 'important');
            } else {
                card.style.setProperty('display', 'none', 'important');
            }
        });
    }

    // 7. Lắng nghe xem có hóa đơn in từ backend trả về không sau khi redirect
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
</script>
</body>
</html>