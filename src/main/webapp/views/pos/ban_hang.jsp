<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Bán Hàng Tại Chỗ & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Nạp Thư viện CSS hiện đại nhất -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        /* =========================================================================
           THIẾT KẾ GIAO DIỆN CHUẨN MÁY POS CHUYÊN NGHIỆP (KIOTVIET, SAPO, IPOS)
           ========================================================================= */
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

        /* 3-Cột POS Layout */
        .pos-layout {
            display: flex;
            height: calc(100vh - 60px);
            overflow: hidden;
        }

        /* CỘT MỘT: THỰC ĐƠN DANH MỤC TRÁI (Category Sidebar) */
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

        /* CỘT HAI: LƯỚI SẢN PHẨM Ở GIỮA (Middle Product Grid Area) */
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

        /* Grid hiển thị sản phẩm dạng mượt mà */
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

        /* Card sản phẩm tinh tế, tăng tỉ lệ chạm gõ */
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

        /* CỘT BA: CHI TIẾT HÓA ĐƠN & VẬN HÀNH THANH TOÁN (Hữu khu điều phối bên phải) */
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

        /* Khu chứa danh sách giỏ hàng POS */
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

        /* CRM ví điểm & Khách hàng */
        .pos-crm-panel {
            padding: 14px 20px;
            background-color: var(--pos-bg);
            border-top: 1.5px solid var(--pos-border);
            border-bottom: 1.5px solid var(--pos-border);
        }

        /* Khu thanh toán hóa đơn chốt hạ */
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

        /* Bố cục bàn phím gõ nhanh tiền mặt thối lại chuẩn máy POS */
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

        /* Nút chốt đơn chính */
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

        .pos-btn-submit:active {
            transform: translateY(1px);
        }
    </style>
</head>
<body>

<!-- HEADER MÁY POS THƯƠNG HIỆU CAO CẤP -->
<nav class="navbar navbar-dark bg-dark px-3 shadow-sm" style="height: 60px; z-index: 100;">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success d-flex align-items-center" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
            <i class="bi bi-cup-hot-fill me-2 fs-4 text-success animate-pulse"></i>
            <span>TEA POS PRO</span>
            <span class="badge bg-success-subtle text-success border border-success ms-2 font-monospace" style="font-size: 10px; padding: 3px 6px;">V2.5 STABLE</span>
        </a>
        <div class="d-flex align-items-center gap-3 text-white">
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
    <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÒN DỌC (HÀNG TẬP TRUNG) -->
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

    <!-- CỘT 2: LƯỚI SẢN PHẨM & THANH TRA CỨU NHANH (GIỮA) -->
    <div class="pos-menu-area">
        <div class="pos-menu-header">
            <div class="pos-search-wrapper">
                <i class="bi bi-search pos-search-icon"></i>
                <input type="text" id="posSearchProductInput" class="pos-search-input" placeholder="Tìm tên đồ uống hoặc quét mã vạch sản phẩm..." onkeyup="searchPOSProduct()">
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
                    <!-- Đăng ký sẵn cấu hình Object JSON cho Javascript bóc tách khi chạm Card -->
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
                                { maTp: ${tp.maTp}, tenTp: '${tp.tenTp}', giaBan: ${tp.giaBan} }${not tLoop.last ? ',' : ''}
                                </c:forEach>
                            ]
                        };
                    </script>

                    <div class="pos-card-wrapper">
                        <div class="pos-card" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}"
                             onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
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
                                <!-- Tag nhỏ góc ảnh -->
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

    <!-- CỘT 3: CHI TIẾT HÓA ĐƠN, ĐỐI SOÁT & THANH TOÁN (PHẢI) -->
    <div class="pos-billing-area">
        <div class="pos-billing-header">
            <h6 class="fw-bold mb-0 text-dark d-flex align-items-center gap-2">
                <i class="bi bi-cart3 text-success fs-5"></i>
                <span>DANH SÁCH ORDER</span>
            </h6>
            <button class="btn btn-sm btn-outline-danger border-2 fw-bold" onclick="clearFullPosCart()">
                <i class="bi bi-trash3-fill"></i> Hủy đơn
            </button>
        </div>

        <!-- LIST SẢN PHẨM TRONG ĐƠN -->
        <div class="pos-cart-items-wrapper" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>
                <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>
            </div>
        </div>

        <!-- CRM ĐỐI SOÁT HỘI VIÊN CHUYÊN SÂU -->
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

            <!-- NÚT GỌI ĐĂNG KÝ NHANH THÀNH VIÊN CRM VIP NGAY TẠI QUẦY -->
            <div id="posAddCustomerArea" style="display: none;" class="mt-2 border-top pt-2">
                <button type="button" class="btn btn-sm btn-primary w-100 fw-bold py-2" onclick="openQuickAddCustomerModal()">
                    <i class="bi bi-person-plus-fill"></i> ĐĂNG KÝ HỘI VIÊN VIP MỚI
                </button>
            </div>

            <!-- Công cụ CRM dồn điểm thăng hạng và Voucher VIP -->
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

        <!-- FORM GỬI THANH TOÁN LÊN BACKEND -->
        <form id="posCheckoutForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST">
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
            <div id="submitItemsContainer"></div> <!-- Nơi lưu các mảng song song gửi về Java -->

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

                <!-- Phân hệ tính tiền thối lại realtime chuẩn máy quầy -->
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

                <!-- Chọn phương thức thanh toán -->
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

<!-- MODAL IN HÓA ĐƠN NHIỆT (Thermal Bill Receipt Modal) Chuẩn E-Commerce -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; font-size: 11.5px;">
                <div class="text-center mb-2">
                    <h6 class="fw-bold mb-0" style="letter-spacing: 0.5px;">TEA POS PRO - COFFEE & TEA</h6>
                    <span style="font-size: 9px; color: #555;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span><br>
                    <span style="font-size: 9px; color: #555;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px;">HÓA ĐƠN BÁN LẺ TẠI QUẦY</strong><br>
                    <span style="font-size: 9px;" id="billThoiGian"></span>
                </div>
                <div class="mb-2">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="d-flex justify-content-between">
                    <span>Tổng tiền nước:</span>
                    <strong id="billRawPrice"></strong>
                </div>
                <div class="d-flex justify-content-between text-danger" id="billDiscountRow" style="display: none;">
                    <span>Khấu trừ Voucher:</span>
                    <strong id="billDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between text-primary" id="billPointsRow" style="display: none;">
                    <span>Tiêu điểm CRM:</span>
                    <strong id="billPointsDiscount"></strong>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                <div class="d-flex justify-content-between fw-bold text-success fs-6">
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

    // 9. Submit đơn hàng POS - SỬA LỖI TRỰC TIẾP TRÁNH CLASH EL JAVASCRIPT
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

            // Định dạng chuỗi Topping gửi lên Java Controller: maTp_soLuong_giaChot
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

    // 10. Tùy biến popup pha chế - CHUYỂN TOÀN BỘ SANG CHUỒI KHÔNG CHỨA BIỂU THỨC EL ĐỂ AN TOÀN TUYỆT ĐỐI
    function openCustomizePopup(maSp, tenSp, optionsJsonStr) {
        const rawOptions = JSON.parse(decodeURIComponent(optionsJsonStr));
        let html = '';
        html += '<div class="text-start" id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '">';
        html += '<h5 class="fw-bold text-success mb-3">' + tenSp + '</h5>';

        html += '<div class="mb-3">';
        html += '<label class="fw-semibold small mb-2 d-block">CHỌN KÍCH CỠ (SIZE)</label>';
        html += '<div class="selection-btn-group">';

        rawOptions.sizes.forEach((s, idx) => {
            let checkedAttr = (idx === 0) ? 'checked' : '';
            html += '<input type="radio" class="selection-radio-input size-radio" name="popup_size" ' +
                'id="sz_' + s.maSize + '" value="' + s.maSize + '" data-price="' + s.giaBan + '" data-name="' + s.tenSize + '" ' + checkedAttr + '>';
            html += '<label class="selection-label" for="sz_' + s.maSize + '">Size ' + s.tenSize + ' (+' + formatVND(s.giaBan) + ')</label>';
        });
        html += '</div></div>';

        if (rawOptions.choPhepDoiDuong) {
            html += '<div class="mb-3">';
            html += '<label class="fw-semibold small mb-2 d-block">MỨC ĐƯỜNG</label>';
            html += '<div class="selection-btn-group">';
            html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s100" value="100%" checked>';
            html += '<label class="selection-label" for="s100">100%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s70" value="70%">';
            html += '<label class="selection-label" for="s70">70%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s50" value="50%">';
            html += '<label class="selection-label" for="s50">50%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s0" value="0%">';
            html += '<label class="selection-label" for="s0">0%</label>';
            html += '</div></div>';
        }

        if (rawOptions.choPhepDoiDa) {
            html += '<div class="mb-3">';
            html += '<label class="fw-semibold small mb-2 d-block">MỨC ĐÁ</label>';
            html += '<div class="selection-btn-group">';
            html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i100" value="100%" checked>';
            html += '<label class="selection-label" for="i100">100%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i70" value="70%">';
            html += '<label class="selection-label" for="i70">70%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i50" value="50%">';
            html += '<label class="selection-label" for="i50">50%</label>';
            html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i0" value="0%">';
            html += '<label class="selection-label" for="i0">0%</label>';
            html += '</div></div>';
        }

        html += '<div class="mb-3"><label class="fw-semibold small mb-2 d-block">THÊM TOPPING ĐI KÈM</label>';

        rawOptions.allToppings.forEach(tp => {
            html += '<div class="form-check d-flex justify-content-between align-items-center mb-2">';
            html += '<input class="form-check-input topping-chk" type="checkbox" value="' + tp.maTp + '" ';
            html += 'data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" id="tp_' + tp.maTp + '">';
            html += '<label class="form-check-label flex-grow-1 ms-2" for="tp_' + tp.maTp + '">';
            html += tp.tenTp + ' (+' + formatVND(tp.giaBan) + ')';
            html += '</label></div>';
        });

        html += '</div>';
        html += '<div class="mb-3">';
        html += '<label class="fw-semibold small mb-2">Ghi chú pha chế</label>';
        html += '<textarea class="form-control-teapos" id="popup_note" rows="2" placeholder="Ít đá, mang ly đá riêng..."></textarea>';
        html += '</div>';

        html += '<div class="d-flex justify-content-between align-items-center mt-4">';
        html += '<span class="fw-bold fs-5 text-success" id="popup_total">0 đ</span>';
        html += '<button class="btn-teapos btn-primary-teapos" onclick="addCustomizedToCart()">';
        html += '<i class="bi bi-cart-plus me-1"></i> Thêm vào đơn';
        html += '</button></div>';

        Swal.fire({
            title: 'TÙY BIẾN PHA CHẾ',
            html: html,
            showConfirmButton: false,
            showCloseButton: true,
            didOpen: () => {
                document.querySelectorAll('.size-radio, .topping-chk').forEach(el => {
                    el.addEventListener('change', recalculatePopupPrice);
                });
                recalculatePopupPrice();
            }
        });
    }

    // 11. Tính lại tiền trong Customize Popup
    function recalculatePopupPrice() {
        const checkedSize = document.querySelector('.size-radio:checked');
        let sizePrice = checkedSize ? parseInt(checkedSize.dataset.price) : 0;
        let toppingPrice = 0;
        document.querySelectorAll('.topping-chk:checked').forEach(tp => {
            toppingPrice += parseInt(tp.dataset.price);
        });
        document.getElementById('popup_total').innerText = formatVND(sizePrice + toppingPrice);
    }

    // 12. Thêm món sau cấu hình vào giỏ hàng POS
    function addCustomizedToCart() {
        const el = document.getElementById('posCustomizer');
        const maSp = el.dataset.masp;
        const tenSp = el.dataset.tensp;
        const checkedSize = document.querySelector('.size-radio:checked');
        const maSize = parseInt(checkedSize.value);

        // Tách nhãn tên size động từ dataset cực chuẩn
        const tenSize = checkedSize.dataset.name;
        const giaBan = parseInt(checkedSize.dataset.price);
        const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
        const mucDuong = sugarEl ? sugarEl.value : "100%";
        const iceEl = document.querySelector('input[name="popup_ice"]:checked');
        const mucDa = iceEl ? iceEl.value : "100%";
        const ghiChuMon = document.getElementById('popup_note').value;

        let toppingsList = [];
        document.querySelectorAll('.topping-chk:checked').forEach(tp => {
            toppingsList.push({
                maTp: parseInt(tp.value),
                tenTp: tp.dataset.name,
                giaTp: parseInt(tp.dataset.price),
                soLuongTp: 1
            });
        });

        const existing = posCart.find(item =>
            item.maSp === maSp && item.maSize === maSize &&
            item.mucDa === mucDa && item.mucDuong === mucDuong &&
            JSON.stringify(item.toppings) === JSON.stringify(toppingsList)
        );

        if (existing) {
            existing.soLuong++;
        } else {
            posCart.push({
                maSp, tenSp, maSize, tenSize, giaBan,
                mucDa, mucDuong, ghiChuMon, soLuong: 1,
                toppings: toppingsList
            });
        }
        Swal.close();
        renderPosCart();
    }

    // 13. Kết xuất giao diện giỏ hàng POS - SỬA LỖI JAVASCRIPT STRING CONCAT CHỐNG CLASH EL
    function renderPosCart() {
        const container = document.getElementById('posCartItems');
        if (posCart.length === 0) {
            container.innerHTML =
                '<div class="text-center text-muted py-5 my-5">' +
                '<i class="bi bi-cart-x fs-1 text-secondary opacity-50"></i>' +
                '<p class="small mt-2">Chưa chọn món. Chạm sản phẩm ở lưới giữa để tạo đơn.</p>' +
                '</div>';
            recalculatePOSBill(0);
            return;
        }
        container.innerHTML = '';
        let tongTienHang = 0;
        posCart.forEach((item, idx) => {
            let toppingTotal = item.toppings.reduce((sum, t) => sum + (t.giaTp * t.soLuongTp), 0);
            let rowPrice = (item.giaBan + toppingTotal) * item.soLuong;
            tongTienHang += rowPrice;

            // Khởi dựng chuỗi topping
            let toppingsText = '';
            if (item.toppings && item.toppings.length > 0) {
                item.toppings.forEach(t => {
                    toppingsText += '<br>+ Topping: ' + t.tenTp;
                });
            }

            container.innerHTML +=
                '<div class="pos-cart-item p-3 border-bottom d-flex justify-content-between align-items-center">' +
                '<div class="cart-item-details">' +
                '<span class="fw-bold text-dark d-block" style="font-size: 14px;">' + item.tenSp + ' (Size ' + item.tenSize + ')</span>' +
                '<div class="small text-muted" style="font-size: 11px; margin-top: 2px;">' +
                'Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + toppingsText +
                '</div>' +
                '<div class="text-success fw-bold mt-1" style="font-size: 13px;">' + formatVND(rowPrice) + '</div>' +
                '</div>' +
                '<div class="d-flex flex-column align-items-end gap-2">' +
                '<button class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 12px;" onclick="removeCartItem(' + idx + ')">' +
                '<i class="bi bi-trash"></i>' +
                '</button>' +
                '<div class="input-group input-group-sm" style="width: 80px;">' +
                '<button class="btn btn-outline-secondary px-2" onclick="changeQty(' + idx + ', -1)">-</button>' +
                '<span class="form-control text-center bg-white border-secondary border-opacity-25 px-0 fw-bold" style="font-size: 12px;">' + item.soLuong + '</span>' +
                '<button class="btn btn-outline-secondary px-2 text-success" onclick="changeQty(' + idx + ', 1)">+</button>' +
                '</div>' +
                '</div>' +
                '</div>';
        });
        recalculatePOSBill(tongTienHang);
    }

    // 14. Tăng giảm số lượng sản phẩm trong giỏ hàng
    function changeQty(idx, change) {
        posCart[idx].soLuong += change;
        if (posCart[idx].soLuong <= 0) {
            posCart.splice(idx, 1);
        }
        renderPosCart();
    }

    // 15. Xóa 1 phần tử trong giỏ hàng
    function removeCartItem(idx) {
        posCart.splice(idx, 1);
        renderPosCart();
    }

    // 16. Tính toán dồn tiền, chiết khấu, dồn mã KM
    function recalculatePOSBill(tongTienHang) {
        let rawSum = tongTienHang;
        let discount = 0;
        if (appliedVoucher) {
            if (rawSum >= appliedVoucher.donToiThieu) {
                if (appliedVoucher.loaiGiam === 1) {
                    discount = appliedVoucher.giaTriGiam;
                } else {
                    discount = Math.round((rawSum * appliedVoucher.giaTriGiam) / 100);
                    if (appliedVoucher.giamToiDa > 0 && discount > appliedVoucher.giamToiDa) {
                        discount = appliedVoucher.giamToiDa;
                    }
                }
                document.getElementById("summaryDiscountRow").style.display = "flex";
                document.getElementById("txtAppliedCode").innerText = appliedVoucher.maCode;
                document.getElementById("totalDiscountPrice").innerText = "-" + formatVND(discount);
                document.getElementById("submit_maKm").value = appliedVoucher.maKm;
                document.getElementById("submit_tienGiamGia").value = discount;
            } else {
                showToast('warning', 'Hóa đơn chưa đạt giá trị tối thiểu ' + formatVND(appliedVoucher.donToiThieu) + ' để giữ Voucher!');
                appliedVoucher = null;
                document.getElementById("summaryDiscountRow").style.display = "none";
                document.getElementById("submit_maKm").value = "";
                document.getElementById("submit_tienGiamGia").value = "0";
            }
        }

        let pointsDiscount = appliedPoints * 1000;
        if (pointsDiscount > (rawSum - discount)) {
            pointsDiscount = rawSum - discount;
        }

        if (appliedPoints > 0) {
            document.getElementById("summaryPointsRow").style.display = "flex";
            document.getElementById("txtUsedPoints").innerText = appliedPoints;
            document.getElementById("totalPointsPrice").innerText = "-" + formatVND(pointsDiscount);
            document.getElementById("submit_diemSuDung").value = appliedPoints;
            document.getElementById("submit_tienTruDiem").value = pointsDiscount;
        } else {
            document.getElementById("summaryPointsRow").style.display = "none";
            document.getElementById("submit_diemSuDung").value = "0";
            document.getElementById("submit_tienTruDiem").value = "0";
        }

        let billBeforeTax = rawSum - discount - pointsDiscount;
        if (billBeforeTax < 0) billBeforeTax = 0;
        let vatPrice = Math.round(billBeforeTax * 0.08);
        let finalPayable = billBeforeTax + vatPrice;

        document.getElementById('totalRawPrice').innerText = formatVND(rawSum);
        document.getElementById('totalTaxPrice').innerText = formatVND(vatPrice);
        document.getElementById('totalPayablePrice').innerText = formatVND(finalPayable);

        document.getElementById('submit_tongTienHang').value = rawSum;
        document.getElementById('submit_tongPhaiTra').value = finalPayable;
        calculateChangeRefund();
    }

    // 17. Gọi AJAX xác thực thành viên CRM bằng SĐT
    function searchCustomerCRM() {
        const sdt = document.getElementById('customerPhoneSearch').value.trim();
        if (!sdt || sdt.length < 10) return;

        fetch('${pageContext.request.contextPath}/pos/search-customer?sdt=' + sdt)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    customerInfo = data;
                    document.getElementById('submit_maKh').value = data.maKh;
                    document.getElementById('customerNameResult').innerText = data.tenKh;
                    let rankName = 'MỚI';
                    if (data.maHang === 1) rankName = 'ĐỒNG';
                    else if (data.maHang === 2) rankName = 'BẠC';
                    else if (data.maHang === 3) rankName = 'VÀNG 👑';
                    else if (data.maHang === 4) rankName = 'VIP 💎';

                    document.getElementById('customerPoints').innerText = 'Hạng: ' + rankName + ' | ' + data.diemTichLuy + ' Điểm';
                    showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
                    document.getElementById("crmLoyaltyArea").style.display = "block";
                    document.getElementById("posAddCustomerArea").style.display = "none";
                } else {
                    customerInfo = null;
                    document.getElementById('submit_maKh').value = "";
                    document.getElementById('customerNameResult').innerText = "Khách lẻ vãng lai";
                    document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                    document.getElementById("crmLoyaltyArea").style.display = "none";
                    document.getElementById("posAddCustomerArea").style.display = "block"; // Bật mở nút đăng ký nhanh

                    Swal.fire({
                        icon: 'question',
                        title: 'Số điện thoại mới!',
                        html: 'Số điện thoại <strong>' + sdt + '</strong> chưa đăng ký thành viên CRM. Quý khách có muốn tạo nhanh tài khoản tích điểm không?',
                        showCancelButton: true,
                        confirmButtonColor: '#10b981',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Tạo tài khoản mới',
                        cancelButtonText: 'Để sau'
                    }).then((res) => {
                        if (res.isConfirmed) {
                            openQuickAddCustomerModal();
                        }
                    });
                    resetVoucherAndPoints();
                    renderPosCart();
                }
            });
    }

    // 18. Popup Đăng Ký nhanh Hội viên mới qua Email & Tên
    function openQuickAddCustomerModal() {
        const sdt = document.getElementById('customerPhoneSearch').value.trim();
        let html = '';
        html += '<div class="text-start">';
        html += '<div class="mb-3">';
        html += '<label class="fw-bold small mb-1">Số điện thoại di động</label>';
        html += '<input type="text" class="form-control" id="reg_sdt" value="' + sdt + '" readonly style="background-color: #f1f5f9; font-weight: 700;">';
        html += '</div>';
        html += '<div class="mb-3">';
        html += '<label class="fw-bold small mb-1">Họ tên thành viên <span class="text-danger">*</span></label>';
        html += '<input type="text" class="form-control" id="reg_tenKh" placeholder="Nhập họ tên đầy đủ..." required>';
        html += '</div>';
        html += '<div class="mb-3">';
        html += '<label class="fw-bold small mb-1">Địa chỉ Email <span class="text-danger">*</span></label>';
        html += '<input type="email" class="form-control" id="reg_email" placeholder="khachhang@gmail.com..." required>';
        html += '<small class="text-muted" style="font-size: 10px;">Hệ thống sẽ gửi tài khoản và hướng dẫn đặt nước online qua Email này!</small>';
        html += '</div></div>';

        Swal.fire({
            title: 'ĐĂNG KÝ HỘI VIÊN VIP',
            html: html,
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đăng Ký Hoạt Động Ngay',
            cancelButtonText: 'Hủy Bỏ',
            preConfirm: () => {
                const tenKh = document.getElementById('reg_tenKh').value.trim();
                const email = document.getElementById('reg_email').value.trim();
                if (!tenKh || !email) {
                    Swal.showValidationMessage('Vui lòng nhập đầy đủ Họ tên và Email!');
                }
                return { tenKh, email, sdt };
            }
        }).then((result) => {
            if (result.isConfirmed) {
                Swal.fire({
                    title: 'Đang khởi tạo tài khoản...',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                const url = '${pageContext.request.contextPath}/pos/create-customer';
                const params = new URLSearchParams();
                params.append('tenKh', result.value.tenKh);
                params.append('email', result.value.email);
                params.append('soDienThoai', result.value.sdt);

                fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: params
                })
                    .then(res => res.json())
                    .then(data => {
                        Swal.close();
                        if (data.status === 'SUCCESS') {
                            customerInfo = data;
                            document.getElementById('submit_maKh').value = data.maKh;
                            document.getElementById('customerNameResult').innerText = data.tenKh;
                            document.getElementById('customerPoints').innerText = 'Hạng: ĐỒNG | 0 Điểm';
                            document.getElementById("crmLoyaltyArea").style.display = "block";
                            document.getElementById("posAddCustomerArea").style.display = "none";
                            Swal.fire({
                                icon: 'success',
                                title: 'Thành công',
                                text: 'Đã khởi tạo, gửi Email hướng dẫn và tự động kích hoạt tài khoản CRM VIP cho thành viên ' + data.tenKh + ' thành công!',
                                confirmButtonColor: '#10b981'
                            });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Đăng ký thất bại', text: data.message });
                        }
                    })
                    .catch(err => {
                        Swal.close();
                        console.error('Lỗi AJAX:', err);
                        showToast('error', 'Lỗi kết nối máy chủ!');
                    });
            }
        });
    }

    // 19. Áp dụng mã Voucher giảm giá thủ công tự gõ
    function applyManualVoucherCode() {
        const code = document.getElementById("manualVoucherInput").value.trim();
        if (!code) {
            showToast('warning', 'Vui lòng điền mã Voucher cần áp dụng!');
            return;
        }

        const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
        if (totalRaw === 0) {
            showToast('warning', 'Vui lòng chọn món nước uống trước khi áp Voucher!');
            return;
        }

        const maKh = document.getElementById("submit_maKh").value;
        Swal.fire({
            title: 'Đang áp mã Voucher...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });

        const url = '${pageContext.request.contextPath}/pos/apply-voucher';
        const params = new URLSearchParams();
        params.append('code', code);
        params.append('maKh', maKh);
        params.append('tongTienHang', totalRaw);

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
            .then(res => res.json())
            .then(data => {
                Swal.close();
                if (data.status === 'SUCCESS') {
                    appliedVoucher = data;
                    showToast('success', 'Đã áp dụng thành công Voucher: ' + code);
                    recalculatePOSBill(totalRaw);
                } else {
                    Swal.fire({ icon: 'error', title: 'Lỗi áp mã', text: data.message });
                }
            })
            .catch(err => {
                Swal.close();
                console.error('Lỗi AJAX:', err);
                showToast('error', 'Lỗi kết nối quầy POS với máy chủ!');
            });
    }

    // 20. Popup Chọn Voucher VIP có sẵn của khách hàng
    function showVoucherSelectionModal() {
        if (!customerInfo) {
            showToast('warning', 'Hãy xác thực thành viên CRM trước!');
            return;
        }
        if (posCart.length === 0) {
            showToast('warning', 'Vui lòng nêm cốc nước vào giỏ hàng trước khi áp mã!');
            return;
        }
        if (!customerInfo.vouchers || customerInfo.vouchers.length === 0) {
            Swal.fire({
                icon: 'info',
                title: 'Hộp mã trống',
                text: 'Thành viên hiện tại chưa có Voucher VIP khả dụng!',
                confirmButtonColor: '#10b981'
            });
            return;
        }

        let selectHtml = '<select id="posVoucherSelector" class="form-select mb-2"><option value="">-- Bỏ áp dụng Voucher --</option>';
        customerInfo.vouchers.forEach(v => {
            let txtType = v.loaiGiam === 1 ? formatVND(v.giaTriGiam) : v.giaTriGiam + "%";
            selectHtml += '<option value="' + v.maCode + '">' + v.maCode + ' (Giảm ' + txtType + ' | Đơn từ ' + formatVND(v.donToiThieu) + ')</option>';
        });
        selectHtml += '</select>';

        Swal.fire({
            title: 'KHO VOUCHER KHẢ DỤNG',
            html: selectHtml,
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Áp dụng mã',
            cancelButtonText: 'Đóng',
            preConfirm: () => {
                const code = document.getElementById("posVoucherSelector").value;
                return customerInfo.vouchers.find(v => v.maCode === code);
            }
        }).then((result) => {
            if (result.isConfirmed) {
                if (result.value) {
                    appliedVoucher = result.value;
                    showToast('success', 'Đã gán Voucher: ' + appliedVoucher.maCode);
                } else {
                    appliedVoucher = null;
                    showToast('info', 'Đã hủy áp dụng Voucher.');
                }
                recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
            }
        });
    }

    // 21. Quy đổi tiêu điểm CRM
    function applyPointsDiscount() {
        if (!customerInfo) {
            showToast('warning', 'Yêu cầu xác thực thành viên CRM trước!');
            return;
        }
        if (customerInfo.diemTichLuy <= 0) {
            Swal.fire({
                icon: 'warning',
                title: 'Ví điểm rỗng',
                text: 'Hội viên hiện chưa tích lũy đủ điểm thưởng để quy đổi!',
                confirmButtonColor: '#10b981'
            });
            return;
        }

        Swal.fire({
            title: 'QUY ĐỔI ĐIỂM CRM',
            text: 'Hội viên hiện đang sở hữu ' + customerInfo.diemTichLuy + ' điểm tích lũy. Nhập số điểm muốn tiêu dùng quy đổi (1 Điểm = 1.000 VNĐ):',
            input: 'number',
            inputAttributes: {
                min: 1,
                max: customerInfo.diemTichLuy,
                step: 1
            },
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Xác nhận trừ điểm',
            cancelButtonText: 'Hủy bỏ',
            preConfirm: (val) => {
                const pts = parseInt(val);
                if (isNaN(pts) || pts <= 0 || pts > customerInfo.diemTichLuy) {
                    Swal.showValidationMessage('Số lượng điểm nhập quy đổi không hợp lệ!');
                }
                return pts;
            }
        }).then((result) => {
            if (result.isConfirmed) {
                appliedPoints = result.value;
                showToast('success', 'Đồng ý khấu trừ ' + appliedPoints + ' điểm tích lũy của khách.');
                recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
            }
        });
    }

    // 22. BẬT POPUP IN HÓA ĐƠN NHIỆT (Thermal Bill Receipt) bằng AJAX nạp dữ liệu không bị chặn bởi Admin Filter
    const printModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));
    function loadAndShowPrintReceipt(maDh) {
        fetch('${pageContext.request.contextPath}/pos/bill-detail?id=' + maDh)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    document.getElementById('billMaDh').innerText = data.maDh;
                    document.getElementById('billThoiGian').innerText = data.thoiGianTao;
                    document.getElementById('billTenNv').innerText = data.tenNhanVien;
                    document.getElementById('billTenKh').innerText = data.tenKhachHang;
                    document.getElementById('billRawPrice').innerText = formatVND(data.tongTienHang);

                    if (data.tienGiamGia > 0) {
                        document.getElementById('billDiscountRow').style.display = 'flex';
                        document.getElementById('billDiscount').innerText = '-' + formatVND(data.tienGiamGia);
                    } else {
                        document.getElementById('billDiscountRow').style.display = 'none';
                    }

                    if (data.diemSuDung > 0) {
                        document.getElementById('billPointsRow').style.display = 'flex';
                        document.getElementById('billPointsDiscount').innerText = '-' + formatVND(data.tienTruDiem);
                    } else {
                        document.getElementById('billPointsRow').style.display = 'none';
                    }

                    document.getElementById('billFinalPayable').innerText = formatVND(data.tongPhaiTra);

                    let container = document.getElementById('billItemsContainer');
                    container.innerHTML = '';
                    data.items.forEach(item => {
                        let html = '<div style="margin-bottom: 6px;">';
                        html += '<div class="d-flex justify-content-between">';
                        html += '<span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                        html += '<span>' + item.soLuong + ' x ' + formatVND(item.giaChot) + '</span>';
                        html += '</div>';
                        html += '<div style="font-size: 8.5px; color: #555; padding-left: 6px;">Pha chế: Đá ' + item.mucDa + ' | Đường ' + item.mucDuong + '</div>';
                        if (item.toppings && item.toppings.length > 0) {
                            html += '<div style="font-size: 8.5px; color: #555; padding-left: 6px;">';
                            item.toppings.forEach(tp => {
                                html += '+ Topping: ' + tp.tenTopping + ' (x' + tp.soLuong + ' +' + formatVND(tp.giaChotTp) + ')<br>';
                            });
                            html += '</div>';
                        }
                        html += '</div>';
                        container.innerHTML += html;
                    });
                    printModal.show();
                } else {
                    showToast('error', 'Không thể lấy dữ liệu in hóa đơn!');
                }
            })
            .catch(err => {
                console.error('Lỗi AJAX lấy hóa đơn in:', err);
                showToast('error', 'Lỗi kết nối máy chủ in!');
            });
    }

    function printReceipt() {
        const printContent = document.getElementById("billPrintArea").innerHTML;
        const originalContent = document.body.innerHTML;
        document.body.innerHTML = printContent;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload();
    }

    // Đón bắt kết quả chốt đơn và mở hộp thoại in hóa đơn
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

    // Hàm phụ lấy context path tự động
    function getContextPath() {
        return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    }
</script>
</body>
</html>