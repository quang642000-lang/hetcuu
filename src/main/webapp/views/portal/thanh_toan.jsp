<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Đặt Hàng & Thanh Toán Click & Collect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <style>
        .checkout-card {
            border-radius: 16px;
            border: none;
            background: #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        }
        .item-thumbnail {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 10px;
        }
        .loyalty-box {
            background-color: #ecfdf5;
            border: 1px solid rgba(16, 185, 129, 0.15);
            border-radius: 12px;
            padding: 16px;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="/views/layout/header_portal.jsp" />
<div class="container py-5">
    <h3 class="fw-bold mb-4 text-dark"><i class="bi bi-cart3 text-success me-2"></i>GIỎ HÀNG CỦA BẠN</h3>
    <form action="${pageContext.request.contextPath}/checkout/place" method="POST" id="checkoutForm">
        <!-- Các trường dữ liệu ẩn gửi về Controller để chốt DB -->
        <input type="hidden" name="tongTienHang" id="param_tongTienHang" value="${tongTienHang}">
        <input type="hidden" name="maKm" id="param_maKm" value="">
        <input type="hidden" name="tienGiamGia" id="param_tienGiamGia" value="0">
        <input type="hidden" name="diemSuDung" id="param_diemSuDung" value="0">
        <input type="hidden" name="tienTruDiem" id="param_tienTruDiem" value="0">
        <input type="hidden" name="tongPhaiTra" id="param_tongPhaiTra" value="${tongTienHang}">
        <div class="row g-4">
            <!-- CỘT TRÁI: THÔNG TIN NHẬN NƯỚC & THANH TOÁN -->
            <div class="col-12 col-lg-7">
                <!-- 1. HẸN GIỜ LẤY NƯỚC (DÙNG DROPDOWN 24H) -->
                <div class="card checkout-card p-4 shadow-sm mb-4">
                    <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-clock-fill text-danger me-2"></i>RÀNG BUỘC HẸN GIỜ LẤY NƯỚC</h5>
                    <p class="small text-muted mb-3">Vui lòng chọn thời gian bạn đến cửa hàng nhận nước (Yêu cầu tối thiểu cách 15 phút so với hiện tại để Barista kịp pha chế chuẩn vị. Cửa hàng mở cửa từ 07:00 đến 22:30 hàng ngày).</p>
                    <div class="mb-3 text-start">
                        <label for="thoiGianHenLay" class="form-label fw-bold small text-dark">Thời gian đến lấy nước (24H Format) <span class="text-danger">*</span></label>
                        <select class="form-select form-control-teapos fw-bold text-success fs-5 py-2.5" id="thoiGianHenLay" name="thoiGianHenLay" required>
                            <!-- Các mốc giờ 24h sẽ được tự động nạp bằng JS phía dưới -->
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="ghiChuDon" class="form-label fw-bold small text-dark">Lời nhắn dặn dò riêng cho thợ pha chế</label>
                        <textarea class="form-control" id="ghiChuDon" name="ghiChuDon" rows="2" placeholder="Ví dụ: Lấy túi giấy mang đi xa, không đá mang về tự cho đá sau..."></textarea>
                    </div>
                </div>
                <!-- 2. PHƯƠNG THỨC THANH TOÁN -->
                <div class="card checkout-card p-4 shadow-sm">
                    <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-wallet2 text-primary me-2"></i>PHƯƠNG THỨC THANH TOÁN ĐỒ UỐNG</h5>
                    <div class="row g-3">
                        <div class="col-6">
                            <input type="radio" class="btn-check" name="maPt" id="pt_cash" value="1" checked>
                            <label class="btn btn-outline-success py-3 w-100 text-center fw-bold rounded-3" for="pt_cash">
                                <i class="bi bi-cash fs-3 d-block mb-1"></i> Trả tiền mặt tại quầy
                            </label>
                        </div>
                        <div class="col-6">
                            <input type="radio" class="btn-check" name="maPt" id="pt_qr" value="2">
                            <label class="btn btn-outline-success py-3 w-100 text-center fw-bold rounded-3" for="pt_qr">
                                <i class="bi bi-qr-code fs-3 d-block mb-1"></i> Chuyển khoản VietQR
                            </label>
                        </div>
                    </div>
                </div>
            </div>
            <!-- CỘT PHẢI: TÓM TẮT ĐƠN HÀNG, TOÀN BỘ TOPPINGS & ĐIỂM CRM -->
            <div class="col-12 col-lg-5">
                <div class="card checkout-card p-4 shadow-sm sticky-top" style="top: 80px;">
                    <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">TÓM TẮT ĐƠN ĐẶT NƯỚC</h5>
                    <!-- DANH SÁCH MÓN VÀ TOPPING CHI TIẾT -->
                    <div class="mb-4" style="max-height: 250px; overflow-y: auto;">
                        <c:forEach var="item" items="${checkoutItems}">
                            <!-- Tính tiền thực tế từng dòng bao gồm topping -->
                            <c:set var="itemToppingSum" value="0"/>
                            <c:forEach var="tp" items="${item.toppingGioHangList}">
                                <c:set var="itemToppingSum" value="${itemToppingSum + (tp.giaTp * tp.soLuongTp)}"/>
                            </c:forEach>
                            <c:set var="rowPriceWithToppings" value="${(item.giaBan + itemToppingSum) * item.soLuong}"/>
                            <div class="row align-items-center mb-3 g-2">
                                <div class="col-2">
                                    <c:choose>
                                        <c:when test="${not empty item.hinhAnh}">
                                            <img src="${item.hinhAnh}" class="item-thumbnail border shadow-sm">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="bg-light rounded border text-center py-2" style="width: 50px; height: 50px;">
                                                <i class="bi bi-cup-hot text-success"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="col-7">
                                    <strong class="text-dark small d-block"><c:out value="${item.tenSp}"/> (Size ${item.tenSize})</strong>
                                    <small class="text-muted d-block" style="font-size: 10px;">Đá: ${item.mucDa} | Đường: ${item.mucDuong} | SL: x${item.soLuong}</small>
                                    <!-- HIỂN THỊ ĐỦ TOPPINGS ĐÃ CHỌN -->
                                    <c:if test="${not empty item.toppingGioHangList}">
                                        <div class="text-success" style="font-size: 10px; font-weight: 500;">
                                            <i class="bi bi-plus-circle-fill"></i> Toppings:
                                            <c:forEach var="tp" items="${item.toppingGioHangList}" varStatus="loop">
                                                <c:out value="${tp.tenTp}"/> (x${tp.soLuongTp})${!loop.last ? ', ' : ''}
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </div>
                                <div class="col-3 text-end fw-bold text-success small">
                                    <fmt:formatNumber value="${rowPriceWithToppings}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <!-- TIÊU ĐIỂM CRM TÍCH LŨY -->
                    <div class="loyalty-box mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="fw-bold text-success" style="font-size: 13px;"><i class="bi bi-gem me-1"></i> VÍ ĐIỂM LOYALTY CRM</span>
                            <span class="badge bg-success" style="font-size: 11px;">Hiện có: ${sessionScope.customer.diemTichLuy} điểm</span>
                        </div>
                        <p class="text-muted mb-3" style="font-size: 11px; line-height: 1.4;">Quy đổi: 1 Điểm CRM = 1.000 VNĐ trừ thẳng vào hóa đơn. Quý khách muốn sử dụng bao nhiêu điểm?</p>
                        <div class="input-group input-group-sm">
                            <input type="number" id="inputRedeemPoints" class="form-control" placeholder="Nhập số điểm cần tiêu..." min="0" max="${sessionScope.customer.diemTichLuy}" onkeyup="calculateRedeemPointsRealtime()" onchange="calculateRedeemPointsRealtime()">
                            <button class="btn btn-success fw-bold" type="button" onclick="useMaxPoints()">DÙNG TỐI ĐA</button>
                        </div>
                    </div>
                    <!-- CHỌN MÃ KHUYẾN MÃI VOUCHER -->
                    <div class="mb-4">
                        <label class="form-label fw-bold small text-dark">Mã Voucher Khuyến Mãi</label>
                        <select class="form-select" id="selectVoucher" onchange="calculateRealtimeBill()">
                            <option value="">-- Chọn Voucher khả dụng --</option>
                            <c:forEach var="v" items="${activeVouchers}">
                                <option value="${v.maCode}" data-id="${v.maKm}" data-type="${v.loaiGiam}" data-value="${v.giaTriGiam}" data-max="${v.giamToiDa}" data-min="${v.donToiThieu}">
                                        ${v.maCode} (Giảm ${v.loaiGiam == 1 ? v.giaTriGiam : v.giaTriGiam.toString() += "%"})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <!-- ĐỐI SOÁT TÍNH TIỀN HÓA ĐƠN -->
                    <div class="bg-light rounded p-3 mb-4 small" style="border: 1px dashed var(--border-color);">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tiền cốc nước gốc (Kèm Toppings):</span>
                            <strong class="text-dark" id="display_rawPrice">
                                <fmt:formatNumber value="${tongTienHang}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                            </strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2 text-danger">
                            <span>Tiền giảm giá Voucher:</span>
                            <strong id="display_discount">-0 đ</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2 text-primary" id="displayPointsRow" style="display: none;">
                            <span>Khấu trừ điểm CRM (<span id="txtPointsRedeemed">0</span> điểm):</span>
                            <strong id="display_pointsDiscount">-0 đ</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Thuế VAT (8%):</span>
                            <strong class="text-dark" id="display_vat">0 đ</strong>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between text-success fw-bold fs-5 align-items-center">
                            <span class="fs-6 text-dark">TỔNG PHẢI TRẢ (VNĐ):</span>
                            <span id="display_finalPrice" class="text-danger">0 đ</span>
                        </div>
                    </div>
                    <!-- BUTTON XÁC NHẬN -->
                    <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold fs-5 shadow-sm rounded-3">
                        XÁC NHẬN CHỐT ĐƠN <i class="bi bi-check-all ms-1"></i>
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>
<jsp:include page="/views/layout/footer_portal.jsp" />
<script>
    const userMaxPointsAvailable = ${not empty sessionScope.customer.diemTichLuy ? sessionScope.customer.diemTichLuy : 0};
    const rawBillTotal = ${tongTienHang};

    document.addEventListener("DOMContentLoaded", function() {
        const selectTime = document.getElementById("thoiGianHenLay");
        if (selectTime) {
            selectTime.innerHTML = "";
            const now = new Date();

            // Mốc tối thiểu khả dụng: Hiện tại + 16 phút (dung sai an toàn vượt màng lọc server)
            const startLimit = new Date(now.getTime() + 16 * 60 * 1000);

            // Cửa hàng đóng cửa ngưng nhận đơn lúc 22:30
            const endLimit = new Date();
            endLimit.setHours(22, 30, 0, 0);

            if (startLimit.getTime() > endLimit.getTime()) {
                const opt = document.createElement("option");
                opt.value = "";
                opt.textContent = "Cửa hàng ngừng nhận đơn Click & Collect hôm nay (Đóng cửa lúc 22:30)";
                selectTime.appendChild(opt);
                selectTime.disabled = true;
            } else {
                // Làm tròn phút lên bội số của 5 để giao diện cực kỳ gọn gàng chuyên nghiệp
                let currentStep = new Date(startLimit.getTime());
                const rem = currentStep.getMinutes() % 5;
                if (rem !== 0) {
                    currentStep.setMinutes(currentStep.getMinutes() + (5 - rem));
                }
                currentStep.setSeconds(0, 0);

                // Generate các mốc giờ 24h cách nhau 5 phút
                while (currentStep.getTime() <= endLimit.getTime()) {
                    const hr = String(currentStep.getHours()).padStart(2, '0');
                    const mn = String(currentStep.getMinutes()).padStart(2, '0');
                    const timeStr = hr + ":" + mn;

                    const opt = document.createElement("option");
                    opt.value = timeStr;
                    opt.textContent = timeStr + " (Hôm nay)";
                    selectTime.appendChild(opt);

                    currentStep.setMinutes(currentStep.getMinutes() + 5);
                }
            }
        }
        calculateRealtimeBill();
    });

    function useMaxPoints() {
        const inputPoints = document.getElementById("inputRedeemPoints");
        if (inputPoints) {
            const select = document.getElementById("selectVoucher");
            let voucherDiscount = 0;
            if (select && select.selectedIndex > 0) {
                const selectedOpt = select.options[select.selectedIndex];
                const type = parseInt(selectedOpt.dataset.type);
                const value = parseInt(selectedOpt.dataset.value);
                const maxVal = parseInt(selectedOpt.dataset.max);
                if (type === 1) {
                    voucherDiscount = value;
                } else if (type === 2) {
                    voucherDiscount = (rawBillTotal * value) / 100;
                    if (maxVal > 0 && voucherDiscount > maxVal) {
                        voucherDiscount = maxVal;
                    }
                }
            }
            const remainingBill = rawBillTotal - voucherDiscount;
            const maxPointsToUse = Math.min(userMaxPointsAvailable, Math.floor(remainingBill / 1000));
            inputPoints.value = maxPointsToUse > 0 ? maxPointsToUse : 0;
            calculateRealtimeBill();
        }
    }
    function calculateRedeemPointsRealtime() {
        const inputPoints = document.getElementById("inputRedeemPoints");
        if (inputPoints) {
            let val = parseInt(inputPoints.value) || 0;
            if (val < 0) {
                inputPoints.value = 0;
            } else if (val > userMaxPointsAvailable) {
                inputPoints.value = userMaxPointsAvailable;
                showToast('warning', 'Quý khách chỉ có tối đa ' + userMaxPointsAvailable + ' điểm CRM!');
            }
        }
        calculateRealtimeBill();
    }
    function calculateRealtimeBill() {
        let rawSum = rawBillTotal;
        let voucherDiscount = 0;
        let pointsDiscount = 0;
        const select = document.getElementById("selectVoucher");
        const selectedOpt = select ? select.options[select.selectedIndex] : null;
        if (selectedOpt && selectedOpt.value !== "") {
            const code = selectedOpt.value;
            const type = parseInt(selectedOpt.dataset.type);
            const value = parseInt(selectedOpt.dataset.value);
            const maxVal = parseInt(selectedOpt.dataset.max);
            const minVal = parseInt(selectedOpt.dataset.min);
            if (rawSum < minVal) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Không đạt điều kiện',
                    text: 'Voucher ' + code + ' yêu cầu đơn nước đạt tối thiểu ' + minVal.toLocaleString('vi-VN') + ' đ!'
                });
                select.selectedIndex = 0;
                calculateRealtimeBill();
                return;
            }
            if (type === 1) {
                voucherDiscount = value;
            } else if (type === 2) {
                voucherDiscount = (rawSum * value) / 100;
                if (maxVal > 0 && voucherDiscount > maxVal) {
                    voucherDiscount = maxVal;
                }
            }
            if (voucherDiscount > rawSum) voucherDiscount = rawSum;
            document.getElementById("param_maKm").value = selectedOpt.dataset.id;
            document.getElementById("param_tienGiamGia").value = voucherDiscount;
            document.getElementById("display_discount").innerText = '-' + voucherDiscount.toLocaleString('vi-VN') + ' đ';
        } else {
            document.getElementById("param_maKm").value = "";
            document.getElementById("param_tienGiamGia").value = 0;
            document.getElementById("display_discount").innerText = '-0 đ';
        }
        const inputPoints = document.getElementById("inputRedeemPoints");
        let pointsToUse = parseInt(inputPoints.value) || 0;
        pointsDiscount = pointsToUse * 1000;
        const limitPrePoints = rawSum - voucherDiscount;
        if (pointsDiscount > limitPrePoints) {
            pointsDiscount = Math.floor(limitPrePoints / 1000) * 1000;
            pointsToUse = pointsDiscount / 1000;
            inputPoints.value = pointsToUse > 0 ? pointsToUse : "";
        }
        if (pointsToUse > 0) {
            document.getElementById("displayPointsRow").style.display = 'flex';
            document.getElementById("txtPointsRedeemed").innerText = pointsToUse;
            document.getElementById("display_pointsDiscount").innerText = '-' + pointsDiscount.toLocaleString('vi-VN') + ' đ';
            document.getElementById("param_diemSuDung").value = pointsToUse;
            document.getElementById("param_tienTruDiem").value = pointsDiscount;
        } else {
            document.getElementById("displayPointsRow").style.display = 'none';
            document.getElementById("param_diemSuDung").value = 0;
            document.getElementById("param_tienTruDiem").value = 0;
        }
        let billBeforeTax = rawSum - voucherDiscount - pointsDiscount;
        if (billBeforeTax < 0) billBeforeTax = 0;
        let vatPrice = Math.round(billBeforeTax * 0.08);
        let finalPayable = billBeforeTax + vatPrice;
        document.getElementById("display_vat").innerText = vatPrice.toLocaleString('vi-VN') + ' đ';
        document.getElementById("display_finalPrice").innerText = finalPayable.toLocaleString('vi-VN') + ' đ';
        document.getElementById("param_tongPhaiTra").value = finalPayable;
    }
</script>
</body>
</html>