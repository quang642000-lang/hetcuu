<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Thu Ngân & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Bootstrap 5, Icons, SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>

    <!-- Custom styling -->
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/pos.css" rel="stylesheet">
    <style>
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
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 12px 6px;
            border: 0;
            background: none;
            width: 100%;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s;
            color: #64748b;
            font-size: 11px;
            font-weight: 600;
        }
        .pos-category-btn:hover {
            background-color: #f8fafc;
            color: #10b981;
        }
        .pos-category-btn.active {
            background-color: #ecfdf5;
            color: #10b981;
            font-weight: bold;
            border-left: 4px solid #10b981;
        }
        .pos-menu-area {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .pos-menu-header {
            height: 60px;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            flex-shrink: 0;
        }
        .pos-search-wrapper {
            position: relative;
            width: 320px;
        }
        .pos-search-input {
            width: 100%;
            height: 38px;
            padding-left: 36px;
            border-radius: 20px;
            border: 1px solid #cbd5e1;
            font-size: 13px;
            outline: none;
            transition: all 0.2s;
        }
        .pos-search-input:focus {
            border-color: #10b981;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
        }
        .pos-search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        .pos-product-container {
            flex-grow: 1;
            overflow-y: auto;
            padding: 16px;
        }
        .pos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 12px;
        }
        .pos-card-wrapper {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 12px;
            text-align: center;
            cursor: pointer;
            position: relative;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
            transition: all 0.2s;
        }
        .pos-card-wrapper:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border-color: #10b981;
        }
        .pos-product-img {
            width: 100%;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 8px;
        }
        .pos-card-name {
            font-size: 12px;
            font-weight: 700;
            color: #1e293b;
            height: 34px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            margin-bottom: 4px;
            text-align: left;
        }
        .pos-card-price {
            font-size: 13px;
            color: #10b981;
            font-weight: 700;
            text-align: left;
        }
        .pos-checkout-sidebar {
            width: 380px;
            background: #ffffff;
            border-left: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow: hidden;
        }
        .pos-checkout-header {
            height: 60px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
        }
        .pos-cart-items-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            padding: 12px;
            background: #f8fafc;
        }
        .pos-bill-item {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 8px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
            text-align: left;
        }
        .pos-bill-item-title {
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
        }
        .pos-bill-item-options {
            font-size: 10px;
            color: #64748b;
            margin-top: 2px;
        }
        .pos-bill-item-price {
            font-size: 12px;
            font-weight: 700;
            color: #10b981;
            text-align: right;
        }
        .pos-crm-panel {
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
            padding: 12px;
            flex-shrink: 0;
        }
        .pos-summary-panel {
            background: #f8fafc;
            border-top: 1px solid #e2e8f0;
            padding: 12px;
            flex-shrink: 0;
        }
        .pos-line-price {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            margin-bottom: 4px;
            color: #64748b;
        }
        .pos-total-row {
            display: flex;
            justify-content: space-between;
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin-top: 6px;
            border-top: 1px solid #cbd5e1;
            padding-top: 6px;
        }
        .pos-cash-suggest-btn {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            font-size: 11px;
            padding: 4px 8px;
            font-weight: bold;
            transition: all 0.2s;
        }
        .pos-cash-suggest-btn:hover {
            background: #10b981;
            color: #ffffff;
            border-color: #10b981;
        }
    </style>
</head>
<body>
<!-- HEADER TOÀN NĂNG -->
<nav class="navbar navbar-dark bg-dark px-3" style="height: 60px;">
    <div class="container-fluid d-flex align-items-center">
        <div class="d-flex align-items-center gap-3">
            <a class="navbar-brand fw-bold text-success d-flex align-items-center mb-0" href="${pageContext.request.contextPath}/pos" style="color: #10b981 !important; font-size: 18px;">
                <i class="bi bi-cup-hot-fill me-2 fs-4 text-success"></i> TEA POS PRO
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

        <div class="d-flex align-items-center gap-3 text-white ms-auto">
            <div class="dropdown border-end pe-3 border-secondary d-none d-md-inline">
                <a class="dropdown-toggle text-decoration-none text-white small fw-semibold" href="#" role="button" id="adminProfileMenu" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-person-badge-fill me-1 text-success"></i> Thu ngân: <c:out value="${sessionScope.user.hoTen}"/>
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                    <li><a class="dropdown-item py-2" href="#" onclick="openPOSSettingsModal()"><i class="bi bi-gear-fill me-2 text-success"></i>Cài đặt cá nhân</a></li>
                </ul>
            </div>
            <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline">
                    <i class="bi bi-calendar3 text-success me-1"></i>
                    <span id="posCurrentClock">--:--:--</span>
                </span>

            <!-- NÚT ĐĂNG XUẤT NỔI BẬT CHỐT CA -->
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger fw-bold px-3 shadow-sm">
                <i class="bi bi-box-arrow-right me-1"></i> ĐĂNG XUẤT
            </a>
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase d-none d-lg-inline" style="font-size: 11px;">
                <i class="bi bi-shield-shaded me-1"></i> Quản trị
            </a>
        </div>
    </div>
</nav>

<div class="pos-layout">
    <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÁI -->
    <div class="pos-category-sidebar">
        <button class="pos-category-btn active" id="btn_cat_all" onclick="filterCategory('all')">
            <i class="bi bi-grid-fill fs-4 mb-1"></i>
            <span>TẤT CẢ</span>
        </button>
        <c:forEach var="cat" items="${categories}">
            <!-- ĐỒNG BỘ CÚ PHÁP TRUYỀN THAM SỐ CHUỖI CÓ NHÁY ĐƠN -->
            <button class="pos-category-btn" id="btn_cat_${cat.maDm}" onclick="filterCategory('${cat.maDm}')">
                <i class="bi bi-cup-straw fs-4 mb-1"></i>
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
                    <div class="pos-card-wrapper" id="row_prod_${sp.maSp}" data-masp="${sp.maSp}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}" data-madm="${sp.maDm}">
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
                                    { maTp: '${tp.maTp}', tenTp: '${tp.tenTp}', giaBan: ${tp.giaBan}, hinhAnh: '${tp.hinhAnh}' }${not tLoop.last ? ',' : ''}
                                    </c:forEach>
                                ]
                            };
                        </script>
                        <div onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                            <c:choose>
                                <c:when test="${not empty sp.hinhAnh}">
                                    <img src="${sp.hinhAnh}" class="pos-product-img rounded" alt="Pic">
                                </c:when>
                                <c:otherwise>
                                    <div class="bg-light rounded d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 100%; height: 80px;">
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
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- CỘT 3: SƯỜN GIỎ HÀNG CHỐT THANH TOÁN (SƯỜN PHẢI) -->
    <div class="pos-checkout-sidebar">
        <div class="pos-checkout-header">
            <h5 class="fw-bold mb-0 text-dark d-flex align-items-center gap-1.5"><i class="bi bi-receipt-cutoff text-success"></i> GIỎ HÀNG CHỜ IN</h5>
            <!-- Nút Hủy Đơn Sài Được Ngay Realtime -->
            <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="clearFullPosCart()">
                <i class="bi bi-trash3-fill"></i> Hủy đơn
            </button>
        </div>

        <!-- DANH SÁCH SẢN PHẨM TRONG GIỎ HÀNG POS -->
        <div class="pos-cart-items-wrapper" id="posCartItems">
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>
                <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>
            </div>
        </div>

        <!-- CRM ĐỐI SOÁT HỘI VIÊN -->
        <div class="pos-crm-panel">
            <div class="d-flex gap-2 mb-3">
                <input type="text" id="customerPhoneSearch" class="form-control form-control-sm" placeholder="Nhập SĐT tìm hội viên CRM..." onkeyup="restrictPhoneInputAndSearch(this)">
                <button class="btn btn-sm btn-success fw-bold" type="button" onclick="searchCustomerCRM()"><i class="bi bi-search"></i></button>
            </div>
            <div class="p-2 border rounded bg-light mb-2 d-flex justify-content-between align-items-center">
                <div class="text-start">
                    <small class="text-muted d-block" style="font-size: 9px; letter-spacing: 0.5px; font-weight: 700;">HỘI VIÊN THANH TOÁN</small>
                    <strong class="text-success small" id="customerNameResult">Khách lẻ vãng lai</strong>
                </div>
                <span class="badge bg-secondary text-white py-1.5 px-3" id="customerPoints" style="border-radius: 50px;">Hạng: Mới | 0 Điểm</span>
            </div>

            <!-- CRM LOYALTY AREA -->
            <div id="crmLoyaltyArea" class="mt-2" style="display: none;">
                <div class="d-flex gap-1.5 mb-2">
                    <button type="button" class="btn btn-xs btn-outline-success fw-bold flex-fill py-1.5" style="font-size: 11px;" onclick="showVoucherSelectionModal()"><i class="bi bi-ticket-perforated-fill"></i> HỘP VOUCHER VIP</button>
                    <button type="button" class="btn btn-xs btn-outline-primary fw-bold flex-fill py-1.5" style="font-size: 11px;" onclick="applyPointsDiscount()"><i class="bi bi-coin"></i> TIÊU ĐIỂM CRM</button>
                </div>
            </div>
            <div id="posAddCustomerArea" style="display: none;"></div>
        </div>

        <!-- TỔNG HỢP TIỀN BÁO CÁO -->
        <div class="pos-summary-panel">
            <div class="mb-2">
                <div class="input-group input-group-sm">
                    <span class="input-group-text bg-light text-muted small"><i class="bi bi-ticket-perforated-fill"></i> Gõ mã Voucher thủ công:</span>
                    <input type="text" class="form-control" id="manualVoucherInput" placeholder="Ví dụ: OPEN10K...">
                    <button class="btn btn-outline-success fw-bold text-uppercase px-3" type="button" onclick="applyManualVoucherCode()">ÁP MÃ</button>
                </div>
            </div>
            <div class="pos-line-price">
                <span>Tổng tiền hàng & Toppings:</span>
                <strong id="totalRawPrice">0 đ</strong>
            </div>
            <div class="pos-line-price text-danger" id="summaryDiscountRow" style="display: none;">
                <span>Khấu trừ Voucher (<span id="txtAppliedCode">N/A</span>):</span>
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
                <span>TỔNG THỰC THU:</span>
                <span class="text-success" id="totalPayablePrice">0 đ</span>
            </div>

            <!-- BỘ TÍNH TIỀN MẶT THỐI LẠI TRỰC QUAN -->
            <div class="mt-3 text-start" id="cashCalculatorSection">
                <div class="d-flex justify-content-between align-items-center mb-1.5">
                    <small class="fw-bold text-muted small"><i class="bi bi-cash-stack"></i> TIỀN MẶT KHÁCH ĐƯA (VNĐ):</small>
                    <input type="number" id="inputCustomerCash" class="form-control form-control-sm text-end fw-bold text-dark font-monospace" style="width: 140px; border-radius: 6px;" placeholder="Gõ số tiền..." onkeyup="calculateChangeRefund()">
                </div>
                <div class="d-flex gap-1 mb-2">
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(50000)">50k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(100000)">100k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(200000)">200k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(500000)">500k</button>
                    <button type="button" class="pos-cash-suggest-btn" onclick="suggestCashAmount(0)">ĐỦ</button>
                </div>
                <div class="d-flex justify-content-between text-dark fw-bold border-top pt-2 small">
                    <span>TIỀN THỐI LẠI KHÁCH:</span>
                    <span id="txtCashRefund" class="text-success">0 đ</span>
                </div>
            </div>

            <!-- PHÂN HỆ KHAI BÁO PHƯƠNG THỨC THANH TOÁN -->
            <div class="mb-3 mt-3 text-start">
                <label class="form-label text-muted small fw-bold"><i class="bi bi-wallet2"></i> PHƯƠNG THỨC THANH TOÁN:</label>
                <select id="select_maPt_UI" class="form-select form-select-sm fw-bold text-dark" style="border-radius: 8px;" onchange="changePaymentMethod(parseInt(this.value))">
                    <option value="1">TIỀN MẶT (BÁN TẠI QUẦY)</option>
                    <option value="2">CHUYỂN KHOẢN QR ĐỘNG (QUÉT MÃ)</option>
                </select>
            </div>

            <!-- FORM ĐỒNG BỘ POST LÊN SERVER -->
            <form id="posOrderForm" action="${pageContext.request.contextPath}/pos/checkout" method="POST" style="display: none;">
                <input type="hidden" name="maKh" id="submit_maKh" value="">
                <input type="hidden" name="loaiDonHang" id="submit_loaiDonHang" value="1">
                <input type="hidden" name="maPt" id="submit_maPt" value="1">
                <input type="hidden" name="maKm" id="submit_maKm" value="">
                <input type="hidden" name="tongTienHang" id="submit_tongTienHang">
                <input type="hidden" name="tienGiamGia" id="submit_tienGiamGia" value="0">
                <input type="hidden" name="diemSuDung" id="submit_diemSuDung" value="0">
                <input type="hidden" name="tienTruDiem" id="submit_tienTruDiem" value="0">
                <input type="hidden" name="tongPhaiTra" id="submit_tongPhaiTra">
                <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_OFFLINE">
                <div id="posFormItemsContainer"></div>
            </form>

            <button type="button" class="btn btn-primary-teapos w-100 py-3 fs-5 fw-bold" onclick="submitPOSOrderTransaction()">
                <i class="bi bi-printer me-1"></i> GIAO DỊCH & IN HOÁ ĐƠN
            </button>
        </div>
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
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Họ và tên hiển thị</label>
                                <input type="text" name="hoTen" id="pos_hoTen" class="form-control" value="<c:out value="${sessionScope.user.hoTen}"/>" required autocomplete="off">
                            </div>
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Số điện thoại di động</label>
                                <input type="text" name="soDienThoai" id="pos_sdt" class="form-control" value="${sessionScope.user.soDienThoai}" required autocomplete="off">
                            </div>
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Địa chỉ Email</label>
                                <input type="email" name="email" id="pos_email" class="form-control" value="${sessionScope.user.email}" required autocomplete="off">
                            </div>
                            <button type="submit" class="btn btn-success w-100 fw-bold py-2"><i class="bi bi-check-circle-fill me-1"></i> CẬP NHẬT HỒ SƠ</button>
                        </form>
                    </div>
                    <!-- Tab Panel 2: Sửa mật khẩu -->
                    <div class="tab-pane fade" id="posPassPanel" role="tabpanel">
                        <form id="posPassForm" onsubmit="submitPOSPassForm(event)">
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Mật khẩu cũ hiện tại</label>
                                <input type="password" name="oldPassword" id="pos_oldPass" class="form-control" required>
                            </div>
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Mật khẩu mới</label>
                                <input type="password" name="newPassword" id="pos_newPass" class="form-control" placeholder="Tối thiểu 8 ký tự..." minlength="8" required>
                            </div>
                            <div class="mb-3 text-start">
                                <label class="form-label fw-bold text-muted small">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" id="pos_confirmPass" class="form-control" placeholder="Nhập lại mật khẩu..." minlength="8" required>
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
            <div class="modal-body p-3 bg-white text-dark text-start" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; line-height: 1.4;">
                <div class="text-center mb-2">
                    <strong style="font-size: 14px; letter-spacing: 1px;">TEA POS CAFÉ</strong><br>
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
                <div class="d-flex justify-content-between fw-bold text-success" style="font-size: 12px;">
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

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
<script>
    function updatePOSClock() {
        const clockEl = document.getElementById('posCurrentClock');
        if (clockEl) {
            const now = new Date();
            clockEl.innerText = now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
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

    function changePaymentMethod(maPt) {
        const submitPt = document.getElementById('submit_maPt');
        const cashSection = document.getElementById('cashCalculatorSection');
        if (submitPt) submitPt.value = maPt;
        if (maPt === 2) {
            if (cashSection) cashSection.style.setProperty('display', 'none', 'important');
        } else {
            if (cashSection) cashSection.style.setProperty('display', 'block', 'important');
        }
    }

    // ĐỒNG BỘ: SỬA ĐÚNG CÚ PHÁP filterCategory nhận chuỗi string an toàn
    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-sidebar .pos-category-btn').forEach(btn => btn.classList.remove('active'));
        const activeBtn = document.getElementById('btn_cat_' + maDm);
        if (activeBtn) activeBtn.classList.add('active');

        document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => {
            if (maDm === 'all') {
                card.style.setProperty('display', 'block', 'important');
            } else {
                const cardDm = card.getAttribute('data-madm');
                if (cardDm === maDm) {
                    card.style.setProperty('display', 'block', 'important');
                } else {
                    card.style.setProperty('display', 'none', 'important');
                }
            }
        });
    }

    function filterBadge(type) {
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

    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        const orderId = urlParams.get('orderId');
        if (msg === 'createsuccess') {
            Swal.fire({
                icon: 'success',
                title: 'Thanh toán hoàn tất',
                html: 'Hóa đơn mã: <strong>' + orderId + '</strong> đã được xuất và in thành công! Đã tự động tích điểm CRM.',
                confirmButtonColor: '#10b981',
                confirmButtonText: 'Bán đơn mới'
            }).then(() => {
                window.location.href = '${pageContext.request.contextPath}/pos';
            });
        }
    });
</script>
</body>
</html>