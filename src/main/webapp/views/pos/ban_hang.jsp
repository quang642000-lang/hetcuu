<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS PRO - Quầy Thu Ngân & Điều Phối Đơn Hàng</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Bootstrap 5, Icons, SweetAlert2, Google Fonts -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>

    <style>
        :root {
            --primary: #10b981;
            --primary-hover: #059669;
            --primary-light: #ecfdf5;
            --dark-slate: #0f172a;
            --slate-medium: #1e293b;
            --slate-light: #334155;
            --bg-main: #f8fafc;
            --border-color: #e2e8f0;
            --text-main: #1e293b;
            --text-muted: #64748b;
        }

        body {
            font-family: 'Inter', sans-serif;
            color: var(--text-main);
            background-color: var(--bg-main);
            height: 100vh;
            overflow: hidden;
        }

        .pos-wrapper {
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .pos-main-container {
            display: flex;
            flex-grow: 1;
            overflow: hidden;
            height: calc(100vh - 60px);
        }

        /* Cột 1: Sidebar danh mục (Trái) */
        .pos-category-sidebar {
            width: 110px;
            background-color: #ffffff;
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow-y: auto;
        }

        .pos-category-btn {
            width: 100%;
            border: none;
            background: transparent;
            padding: 15px 10px;
            text-align: center;
            font-size: 11px;
            font-weight: 700;
            color: #475569;
            display: flex;
            flex-direction: column;
            align-items: center;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .pos-category-btn i {
            font-size: 20px;
        }

        .pos-category-btn.active, .pos-category-btn:hover {
            background-color: var(--primary-light);
            color: var(--primary);
            border-left: 4px solid var(--primary);
        }

        /* Cột 2: Lưới sản phẩm (Giữa) */
        .pos-menu-area {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 16px;
            background-color: var(--bg-main);
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
            padding: 10px 15px 10px 40px;
            border-radius: 99px;
            border: 1px solid #cbd5e1;
            outline: none;
            transition: all 0.2s;
            font-size: 14px;
        }

        .pos-search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
        }

        .pos-search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
        }

        .pos-product-container {
            flex-grow: 1;
            overflow-y: auto;
        }

        .pos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 16px;
        }

        .pos-product-card {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid var(--border-color);
            padding: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            position: relative;
        }

        .pos-product-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05);
            border-color: var(--primary);
        }

        .pos-product-img {
            width: 100%;
            height: 90px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .pos-card-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-main);
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
            color: var(--primary);
        }

        /* Cột 3: Hóa đơn & Giỏ hàng (Phải) */
        .pos-checkout-sidebar {
            width: 390px;
            background-color: #ffffff;
            border-left: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            box-shadow: -2px 0 10px rgba(0,0,0,0.02);
        }

        .pos-checkout-header {
            height: 60px;
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0;
            background-color: #ffffff;
        }

        .pos-cart-items-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            background-color: #f8fafc;
        }

        .pos-crm-panel {
            padding: 12px 15px;
            border-top: 1px solid var(--border-color);
            background-color: #ffffff;
            flex-shrink: 0;
        }

        .pos-summary-panel {
            padding: 15px;
            border-top: 1px solid var(--border-color);
            background-color: #ffffff;
            flex-shrink: 0;
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
            margin-bottom: 15px;
        }

        .btn-primary-teapos {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-hover) 100%) !important;
            border: none !important;
            color: #ffffff !important;
            border-radius: 8px !important;
            font-weight: 700 !important;
            transition: all 0.2s ease !important;
            cursor: pointer !important;
            box-shadow: 0 4px 10px rgba(16, 185, 129, 0.2) !important;
        }

        .btn-primary-teapos:hover {
            transform: translateY(-1px) !important;
            box-shadow: 0 6px 14px rgba(16, 185, 129, 0.3) !important;
        }

        .pos-cash-suggest-btn {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            font-size: 11px;
            padding: 4px 8px;
            font-weight: bold;
            transition: all 0.2s;
            cursor: pointer;
            flex-fill: 1;
        }

        .pos-cash-suggest-btn:hover {
            background: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 6px;
        }
        ::-webkit-scrollbar-track {
            background: #f1f5f9;
        }
        ::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
    </style>
</head>
<body>
<div class="pos-wrapper">
    <!-- HEADER TOÀN NĂNG -->
    <nav class="navbar navbar-dark bg-dark px-3" style="height: 60px; flex-shrink: 0;">
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
                        <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/admin/settings"><i class="bi bi-gear-fill me-2 text-success"></i>Cài đặt cá nhân</a></li>
                    </ul>
                </div>
                <span class="small border-end pe-3 border-secondary font-monospace d-none d-md-inline">
                    <i class="bi bi-calendar3 text-success me-1"></i>
                    <span id="posCurrentClock">--:--:--</span>
                </span>
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline-success border-2 fw-bold text-uppercase d-none d-sm-inline" style="font-size: 11px;">
                    <i class="bi bi-shield-lock-fill me-1"></i> Quản trị Admin
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger fw-bold px-3 shadow-sm">
                    <i class="bi bi-box-arrow-right me-1"></i> ĐĂNG XUẤT
                </a>
            </div>
        </div>
    </nav>

    <!-- THÂN CHÍNH MÀN HÌNH POS -->
    <div class="pos-main-container">
        <!-- CỘT 1: SIDEBAR PHÂN LOẠI DANH MỤC TRÁI -->
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
                        <div class="pos-card-wrapper">
                            <div class="pos-product-card" data-masp="${sp.maSp}" data-madm="${sp.maDm}" data-isnew="${sp.isNew}" data-ishot="${sp.isBestseller}"
                                 onclick="openCustomizePopup('${sp.maSp}', '<c:out value="${sp.tenSp}"/>', encodeURIComponent(JSON.stringify(window['sp_opt_' + '${sp.maSp}'])))">
                                <c:choose>
                                    <c:when test="${not empty sp.hinhAnh}">
                                        <img src="${sp.hinhAnh}" class="pos-product-img rounded" alt="Pic">
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

        <!-- CỘT 3: SƯỜN GIỎ HÀNG CHỐT THANH TOÁN -->
        <div class="pos-checkout-sidebar">
            <div class="pos-checkout-header">
                <h5 class="fw-bold mb-0 text-dark d-flex align-items-center gap-1.5"><i class="bi bi-receipt-cutoff text-success"></i> GIỎ HÀNG</h5>
                <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="clearFullPosCart()">
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
                <div id="crmLoyaltyArea" class="mt-2" style="display: none !important;">
                    <div class="d-flex gap-1.5 mb-1">
                        <button type="button" class="btn btn-xs btn-outline-success fw-bold flex-fill py-1.5" style="font-size: 11px;" onclick="showVoucherSelectionModal()"><i class="bi bi-ticket-perforated-fill"></i> HỘP VOUCHER VIP</button>
                        <button type="button" class="btn btn-xs btn-outline-primary fw-bold flex-fill py-1.5" style="font-size: 11px;" onclick="applyPointsDiscount()"><i class="bi bi-coin"></i> TIÊU ĐIỂM CRM</button>
                    </div>
                </div>
                <div id="posAddCustomerArea" class="mt-2" style="display: none !important;">
                    <button type="button" class="btn btn-xs btn-outline-success w-100 fw-bold py-1.5" style="font-size: 11px;" onclick="openQuickRegisterModal(document.getElementById('customerPhoneSearch').value)"><i class="bi bi-person-plus-fill"></i> ĐĂNG KÝ HỘI VIÊN NHANH</button>
                </div>
            </div>

            <!-- TỔNG HỢP TIỀN BÁO CÁO -->
            <div class="pos-summary-panel">
                <div class="mb-3">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light text-muted small"><i class="bi bi-ticket-perforated-fill"></i> Voucher:</span>
                        <input type="text" class="form-control" id="manualVoucherInput" placeholder="OPEN10K...">
                        <button class="btn btn-outline-success fw-bold text-uppercase px-3" type="button" onclick="applyManualVoucherCode()">ÁP MÃ</button>
                    </div>
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

                <!-- BỘ TÍNH TIỀN MẶT THỐI LẠI TRỰC QUAN -->
                <div class="mt-2 text-start p-2.5 rounded bg-light border mb-3" id="cashCalculatorSection">
                    <div class="d-flex justify-content-between align-items-center mb-1.5">
                        <small class="fw-bold text-muted small"><i class="bi bi-cash-stack"></i> KHÁCH ĐƯA (VNĐ):</small>
                        <input type="number" class="form-control form-control-sm text-end fw-bold text-primary font-monospace bg-white" id="inputCustomerCash" placeholder="Nhập số tiền..." style="width: 140px; height: 30px;" oninput="calculateChangeRefund()">
                    </div>
                    <div class="d-flex justify-content-between gap-1 mb-2">
                        <button type="button" class="pos-cash-suggest-btn flex-fill" onclick="suggestCashAmount(50000)">50k</button>
                        <button type="button" class="pos-cash-suggest-btn flex-fill" onclick="suggestCashAmount(100000)">100k</button>
                        <button type="button" class="pos-cash-suggest-btn flex-fill" onclick="suggestCashAmount(200000)">200k</button>
                        <button type="button" class="pos-cash-suggest-btn flex-fill" onclick="suggestCashAmount(500000)">500k</button>
                        <button type="button" class="pos-cash-suggest-btn flex-fill" onclick="suggestCashAmount(0)">ĐỦ</button>
                    </div>
                    <div class="d-flex justify-content-between text-dark fw-bold border-top pt-2 small">
                        <span>TIỀN THỐI LẠI:</span>
                        <span id="txtCashRefund" class="text-success font-monospace fw-bold">0 đ</span>
                    </div>
                </div>

                <!-- PHÂN HỆ KHAI BÁO PHƯƠNG THỨC THANH TOÁN -->
                <div class="mb-3 text-start">
                    <label class="form-label text-muted small fw-bold"><i class="bi bi-wallet2"></i> HÌNH THỨC THANH TOÁN:</label>
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
                    <input type="hidden" name="tongTienHang" id="submit_tongTienHang" value="0">
                    <input type="hidden" name="tienGiamGia" id="submit_tienGiamGia" value="0">
                    <input type="hidden" name="diemSuDung" id="submit_diemSuDung" value="0">
                    <input type="hidden" name="tienTruDiem" id="submit_tienTruDiem" value="0">
                    <input type="hidden" name="tongPhaiTra" id="submit_tongPhaiTra" value="0">
                    <input type="hidden" name="ghiChuDon" id="submit_ghiChuDon" value="POS_OFFLINE">
                    <div id="posFormItemsContainer"></div>
                </form>

                <button type="button" class="btn btn-primary-teapos w-100 py-3 fs-5 fw-bold" onclick="submitPOSOrderTransaction()">
                    <i class="bi bi-printer me-1"></i> CHỐT ĐƠN & GIAO DỊCH
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL IN HÓA ĐƠN NHIỆT (THERMAL BILL) ==================== -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark text-start" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; line-height: 1.4; font-size: 11px;">
                <div class="text-center mb-2">
                    <strong style="font-size: 14px; letter-spacing: 1px; text-align: center; display: block;">TEA POS CAFÉ</strong>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px; text-align: center; display: block;">HÓA ĐƠN BÁN LẺ TẠI QUẦY</strong>
                    <span style="font-size: 9px; text-align: center; display: block;" id="billThoiGian"></span>
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
                <div class="text-center mt-3" style="font-size: 9px; color: #444; text-align: center;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br>
                    <i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-secondary fw-bold" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-sm btn-success fw-bold" onclick="printReceipt()"><i class="bi bi-printer"></i> In Hóa Đơn</button>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL THANH TOÁN QR ĐỘNG SEPAY ==================== -->
<div class="modal fade" id="posQrModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false" style="z-index: 1065;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-2.5">
                <h6 class="modal-title fw-bold m-0"><i class="bi bi-qr-code-scan me-2 text-success"></i> QUÉT MÃ CHUYỂN KHOẢN</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="cancelQRPayment()"></button>
            </div>
            <div class="modal-body text-center bg-white p-4">
                <h3 class="text-danger fw-bold mb-1" id="posQrAmount">0 đ</h3>
                <p class="text-muted small mb-3">Mã đơn: <span class="fw-bold text-dark font-monospace" id="posQrCodeDisplay"></span></p>

                <div class="bg-light p-3 rounded-4 d-inline-block mb-3 position-relative border" style="border-radius: 12px !important;">
                    <img id="posQrImage" src="" alt="VietQR Payment Code" class="img-fluid" style="max-width: 200px; height: 200px; object-fit: contain;">
                    <!-- Success Overlay -->
                    <div id="posQrSuccessOverlay" class="position-absolute top-0 start-0 w-100 h-100 bg-white bg-opacity-90 d-flex flex-column justify-content-center align-items-center" style="display: none !important; z-index: 10; backdrop-filter: blur(2px); border-radius: 12px;">
                        <i class="bi bi-check-circle-fill text-success" style="font-size: 3.5rem;"></i>
                        <h6 class="text-success mt-2 fw-bold mb-0">Đã Khợp Số Dư!</h6>
                    </div>
                    <!-- Expired Overlay -->
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
                    <span style="font-size: 11px;">Hệ thống đang chờ tiền vào...</span>
                </div>
            </div>
            <div class="modal-footer border-0 p-2 bg-light d-flex justify-content-between rounded-bottom-4">
                <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="cancelQRPayment()">Hủy bỏ</button>
                <button type="button" class="btn btn-sm btn-success fw-bold rounded-pill px-3" onclick="forceSubmitCheckout()">Bỏ qua <i class="bi bi-arrow-right"></i></button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>

<script>
    // Đồng hồ thời gian thực tại quầy thu ngân
    function updatePOSClock() {
        const el = document.getElementById("posCurrentClock");
        if (el) {
            const now = new Date();
            el.innerText = now.toTimeString().split(' ')[0] + " | " + now.toLocaleDateString('vi-VN');
        }
    }
    setInterval(updatePOSClock, 1000);
    updatePOSClock();

    // Ràng buộc số điện thoại
    function restrictPhoneInputAndSearch(el) {
        el.value = el.value.replace(/[^0-9]/g, '');
        if (el.value.length >= 10) {
            searchCustomerCRM();
        }
    }

    // Đổi phương thức thanh toán
    function changePaymentMethod(maPt) {
        const submitPt = document.getElementById('submit_maPt');
        const selectPtUi = document.getElementById('select_maPt_UI');
        const cashSection = document.getElementById('cashCalculatorSection');

        if (submitPt) submitPt.value = maPt;
        if (selectPtUi) selectPtUi.value = maPt;

        if (maPt === 2) {
            if (cashSection) cashSection.style.setProperty('display', 'none', 'important');
        } else {
            if (cashSection) cashSection.style.setProperty('display', 'block', 'important');
        }
    }

    // Bộ lọc danh mục đồ uống tại quầy
    function filterCategory(maDm) {
        document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
        if (maDm === 'all') {
            document.getElementById('btn_cat_all').classList.add('active');
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

    // Bộ lọc tag (NEW, HOT, ALL)
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

    // Tra cứu nhanh sản phẩm bằng từ khóa gõ
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

    // Lắng nghe các tham số trả về sau khi redirect từ Servlet
    document.addEventListener("DOMContentLoaded", function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        const orderId = urlParams.get('orderId');
        const maPt = urlParams.get('maPt');
        const payable = urlParams.get('payable');

        if (msg === 'createsuccess' && orderId) {
            if (maPt === '2') {
                // Hiển thị Modal quét mã QR SePay động và tiến hành Live Polling nhận tiền
                showPosQrCodeModal(orderId, payable);
            } else {
                // Tiền mặt: Hiện trực tiếp hóa đơn in bill nhiệt
                loadAndShowPrintReceipt(orderId);
            }
        }
    });
</script>

<!-- Metadata cấu hình sản phẩm động được chèn đồng bộ, chống lỗi ghi đè xóa mảng sizesList -->
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
                    tenSize: '${sz.maSize == 1 ? "S" : (sz.maSize == 2 ? "M" : "L")}',
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