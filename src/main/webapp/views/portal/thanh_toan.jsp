<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
</head>
<body class="bg-light">

<jsp:include page="/views/layout/header_portal.jsp" />

<div class="container py-5">
    <h3 class="fw-bold mb-4 text-dark"><i class="bi bi-cash-coin text-success"></i> ĐẶT HÀNG CLICK & COLLECT</h3>

    <form action="${pageContext.request.contextPath}/checkout/place" method="POST" id="checkoutForm">
        <!-- Tham số tính toán gửi lên Controller -->
        <input type="hidden" name="tongTienHang" id="param_tongTienHang" value="${tongTienHang}">
        <input type="hidden" name="maKm" id="param_maKm">
        <input type="hidden" name="tienGiamGia" id="param_tienGiamGia" value="0">
        <input type="hidden" name="diemSuDung" id="param_diemSuDung" value="0">
        <input type="hidden" name="tienTruDiem" id="param_tienTruDiem" value="0">
        <input type="hidden" name="tongPhaiTra" id="param_tongPhaiTra" value="${tongTienHang}">

        <div class="row g-4">
            <!-- PHẦN 1: THÔNG TIN NHẬN NƯỚC (BÊN TRÁI) -->
            <div class="col-12 col-lg-7">
                <div class="card border-0 p-4 shadow-sm mb-4" style="border-radius: 16px;">
                    <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-clock-fill text-danger me-1"></i> RÀNG BUỘC HẸN GIỜ LẤY NƯỚC</h5>
                    <p class="small text-muted mb-3">Vui lòng thiết lập mốc thời gian nhận nước tại quầy (Đảm bảo tối thiểu cách 15 phút so với hiện tại để Barista kịp pha chế) [10, 11].</p>

                    <div class="mb-3">
                        <label for="thoiGianHenLay" class="form-label fw-bold small">Chọn ngày giờ đến lấy <span class="text-danger">*</span></label>
                        <input type="datetime-local" class="form-control form-control-teapos" id="thoiGianHenLay" name="thoiGianHenLay" required>
                    </div>

                    <div class="mb-3">
                        <label for="ghiChuDon" class="form-label fw-bold small">Lời nhắn dặn dò riêng</label>
                        <textarea class="form-control" id="ghiChuDon" name="ghiChuDon" rows="2" placeholder="Ghi chú thêm..."></textarea>
                    </div>
                </div>

                <!-- PHƯƠNG THỨC THANH TOÁN -->
                <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                    <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-wallet2 text-primary me-1"></i> PHƯƠNG THỨC THANH TOÁN</h5>
                    <div class="row g-3">
                        <div class="col-6">
                            <input type="radio" class="btn-check" name="maPt" id="pt_cash" value="1" checked>
                            <label class="btn btn-outline-success py-3 w-100 text-center fw-bold" for="pt_cash">
                                <i class="bi bi-cash fs-3 d-block mb-1"></i> Trả tiền mặt tại quầy
                            </label>
                        </div>
                        <div class="col-6">
                            <input type="radio" class="btn-check" name="maPt" id="pt_qr" value="2">
                            <label class="btn btn-outline-success py-3 w-100 text-center fw-bold" for="pt_qr">
                                <i class="bi bi-qr-code fs-3 d-block mb-1"></i> Chuyển khoản VietQR
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PHẦN 2: TỔNG HỢP HÓA ĐƠN & KHUYẾN MÃI (BÊN PHẢI) -->
            <div class="col-12 col-lg-5">
                <div class="card border-0 p-4 shadow-sm" style="border-radius: 16px;">
                    <h5 class="fw-bold mb-3 text-dark">TÓM TẮT ĐƠN HÀNG</h5>

                    <c:forEach var="item" items="${checkoutItems}">
                        <div class="d-flex justify-content-between align-items-center mb-2 small">
                            <span><strong>${item.soLuong} x</strong> SP${item.maSp} (Size ${item.maSize == 1 ? "S" : (item.maSize == 2 ? "M" : "L")})</span>
                            <span class="fw-bold text-dark"><fmt:formatNumber value="${item.giaBan * item.soLuong}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</span>
                        </div>
                    </c:forEach>
                    <hr>

                    <!-- KHỐI ÁP MÃ GIẢM GIÁ (VOUCHER) -->
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-dark">Mã Voucher Khuyến Mãi</label>
                        <div class="input-group">
                            <select class="form-select form-select-sm" id="selectVoucher" onchange="applyVoucherSelect()">
                                <option value="">-- Chọn Voucher khả dụng --</option>
                                <c:forEach var="v" items="${activeVouchers}">
                                    <option value="${v.maCode}" data-type="${v.loaiGiam}" data-value="${v.giaTriGiam}" data-max="${v.giamToiDa}" data-min="${v.donToiThieu}">
                                            ${v.maCode} (Giảm ${v.loaiGiam == 1 ? v.giaTriGiam : v.giaTriGiam.toString() += "%"})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <!-- KHU VỰC ĐỐI SOÁT TÍNH TIỀN HÓA ĐƠN -->
                    <div class="bg-light rounded p-3 mb-4 small">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tiền cốc nước gốc:</span>
                            <span class="fw-bold text-dark" id="display_rawPrice"><fmt:formatNumber value="${tongTienHang}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2 text-danger">
                            <span>Tiền giảm giá Voucher:</span>
                            <span class="fw-bold" id="display_discount">0 đ</span>
                        </div>
                        <div class="d-flex justify-content-between text-success fw-bold fs-5 border-top pt-2 mt-2">
                            <span>KHÁCH CẦN THÀNH TOÁN:</span>
                            <span id="display_finalPrice"><fmt:formatNumber value="${tongTienHang}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ</span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary-teapos w-100 py-3 fw-bold fs-5 shadow-sm">
                        XÁC NHẬN CHỐT ĐƠN <i class="bi bi-check-all"></i>
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>

<jsp:include page="/views/layout/footer_portal.jsp" />

<script>
    // Áp dụng tính toán giảm giá tự động dựa trên Voucher chọn lựa
    function applyVoucherSelect() {
        const select = document.getElementById("selectVoucher");
        const selectedOpt = select.options[select.selectedIndex];

        let subtotal = ${tongTienHang};
        let discount = 0;

        if (selectedOpt.value !== "") {
            const code = selectedOpt.value;
            const type = parseInt(selectedOpt.dataset.type); // 1: Trừ tiền, 2: Trừ %
            const value = parseInt(selectedOpt.dataset.value);
            const maxVal = parseInt(selectedOpt.dataset.max);
            const minVal = parseInt(selectedOpt.dataset.min);

            if (subtotal < minVal) {
                Swal.fire({ icon: 'warning', title: 'Không đạt mốc tối thiểu', text: 'Voucher này chỉ áp dụng cho đơn từ ' + minVal.toLocaleString() + ' đ trở lên!' });
                select.selectedIndex = 0;
                return;
            }

            if (type === 1) {
                discount = value;
            } else {
                discount = (subtotal * value) / 100;
                if (maxVal > 0 && discount > maxVal) {
                    discount = maxVal; // Áp dụng chặn mức giảm tối đa
                }
            }

            document.getElementById("param_maKm").value = code;
        } else {
            document.getElementById("param_maKm").value = "";
        }

        let finalPrice = subtotal - discount;
        if (finalPrice < 0) finalPrice = 0;

        // Lưu thông số vào các input ẩn
        document.getElementById("param_tienGiamGia").value = discount;
        document.getElementById("param_tongPhaiTra").value = finalPrice;

        // Cập nhật giao diện
        document.getElementById("display_discount").innerText = '-' + discount.toLocaleString() + ' đ';
        document.getElementById("display_finalPrice").innerText = finalPrice.toLocaleString() + ' đ';
    }
</script>
</body>
</html>