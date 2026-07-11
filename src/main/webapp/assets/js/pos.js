let posCart = [];
let customerInfo = null;

// Quản lý trạng thái chiết khấu thành viên CRM
let appliedVoucher = null;
let appliedPoints = 0; // Số điểm CRM khách muốn quy đổi

// Hàm tiện ích lấy Context Path tự động từ trình duyệt tránh lỗi 404
function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
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
}

// Hàm mở Popup cấu hình trà sữa và toppings ăn kèm
function openCustomizePopup(maSp, tenSp, optionsJsonStr) {
    const rawOptions = JSON.parse(decodeURIComponent(optionsJsonStr));
    let html = `
        <div class="text-start" id="posCustomizer" data-masp="${maSp}" data-tensp="${tenSp}">
            <h5 class="fw-bold text-success mb-3">${tenSp}</h5>
            <div class="mb-3">
                <label class="fw-semibold small mb-2 d-block">CHỌN KÍCH CỠ (SIZE)</label>
                <div class="selection-btn-group">
    `;
    rawOptions.sizes.forEach((s, idx) => {
        html += `
            <input type="radio" class="selection-radio-input size-radio" name="popup_size"
                id="sz_${s.maSize}" value="${s.maSize}" data-price="${s.giaBan}" ${idx === 0 ? 'checked' : ''}>
            <label class="selection-label" for="sz_${s.maSize}">Size ${s.tenSize} (+${formatVND(s.giaBan)})</label>
        `;
    });
    html += `</div></div>`;

    if (rawOptions.choPhepDoiDuong) {
        html += `
            <div class="mb-3">
                <label class="fw-semibold small mb-2 d-block">MỨC ĐƯỜNG</label>
                <div class="selection-btn-group">
                    <input type="radio" class="selection-radio-input" name="popup_sugar" id="s100" value="100%" checked>
                    <label class="selection-label" for="s100">100%</label>
                    <input type="radio" class="selection-radio-input" name="popup_sugar" id="s70" value="70%">
                    <label class="selection-label" for="s70">70%</label>
                    <input type="radio" class="selection-radio-input" name="popup_sugar" id="s50" value="50%">
                    <label class="selection-label" for="s50">50%</label>
                    <input type="radio" class="selection-radio-input" name="popup_sugar" id="s0" value="0%">
                    <label class="selection-label" for="s0">0%</label>
                </div>
            </div>
        `;
    }

    if (rawOptions.choPhepDoiDa) {
        html += `
            <div class="mb-3">
                <label class="fw-semibold small mb-2 d-block">MỨC ĐÁ</label>
                <div class="selection-btn-group">
                    <input type="radio" class="selection-radio-input" name="popup_ice" id="i100" value="100%" checked>
                    <label class="selection-label" for="i100">100%</label>
                    <input type="radio" class="selection-radio-input" name="popup_ice" id="i70" value="70%">
                    <label class="selection-label" for="i70">70%</label>
                    <input type="radio" class="selection-radio-input" name="popup_ice" id="i50" value="50%">
                    <label class="selection-label" for="i50">50%</label>
                    <input type="radio" class="selection-radio-input" name="popup_ice" id="i0" value="0%">
                    <label class="selection-label" for="i0">0%</label>
                </div>
            </div>
        `;
    }

    html += `<div class="mb-3"><label class="fw-semibold small mb-2 d-block">THÊM TOPPING ĐI KÈM</label>`;
    rawOptions.allToppings.forEach(tp => {
        html += `
            <div class="form-check d-flex justify-content-between align-items-center mb-2">
                <input class="form-check-input topping-chk" type="checkbox" value="${tp.maTp}"
                    data-price="${tp.giaBan}" data-name="${tp.tenTp}" id="tp_${tp.maTp}">
                <label class="form-check-label flex-grow-1 ms-2" for="tp_${tp.maTp}">
                    ${tp.tenTp} (+${formatVND(tp.giaBan)})
                </label>
            </div>
        `;
    });
    html += `</div>`;

    html += `
        <div class="mb-3">
            <label class="fw-semibold small mb-2">Ghi chú pha chế</label>
            <textarea class="form-control-teapos" id="popup_note" rows="2" placeholder="Ít đá, mang ly đá riêng..."></textarea>
        </div>
        <div class="d-flex justify-content-between align-items-center mt-4">
            <span class="fw-bold fs-5 text-success" id="popup_total">0 đ</span>
            <button class="btn-teapos btn-primary-teapos" onclick="addCustomizedToCart()">
                <i class="bi bi-cart-plus me-1"></i> Thêm vào đơn
            </button>
        </div>
    `;

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

function recalculatePopupPrice() {
    const checkedSize = document.querySelector('.size-radio:checked');
    let sizePrice = checkedSize ? parseInt(checkedSize.dataset.price) : 0;
    let toppingPrice = 0;
    document.querySelectorAll('.topping-chk:checked').forEach(tp => {
        toppingPrice += parseInt(tp.dataset.price);
    });
    document.getElementById('popup_total').innerText = formatVND(sizePrice + toppingPrice);
}

function addCustomizedToCart() {
    const el = document.getElementById('posCustomizer');
    const maSp = el.dataset.masp;
    const tenSp = el.dataset.tensp;
    const checkedSize = document.querySelector('.size-radio:checked');
    const maSize = parseInt(checkedSize.value);

    // Tối ưu bóc tách lấy chuẩn kí tự chữ cái của Size (ví dụ: S, M, L) tránh rác mảng
    const rawTextLabel = checkedSize.nextElementSibling.innerText.trim();
    const tenSize = rawTextLabel.startsWith("Size") ? rawTextLabel.substring(5, 6) : rawTextLabel.substring(0, 1);

    const giaBan = parseInt(checkedSize.dataset.price);
    const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
    const mucDuong = sugarEl ? sugarEl.value : "100%";
    const iceEl = document.querySelector('input[name="popup_ice"]:checked');
    const mucDa = iceEl ? iceEl.value : "100%";
    const ghiChuMon = document.getElementById('popup_note').value;

    let toppingsList = [];
    document.querySelectorAll('.topping-chk:checked').forEach(tp => {
        // SỬA LỖI TẠI TURN TRƯỚC: Thay thế hàm .add() sai sang .push() đúng chuẩn mảng JS
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

function renderPosCart() {
    const container = document.getElementById('posCartItems');
    if (posCart.length === 0) {
        container.innerHTML = `
            <div class="text-center text-muted py-5 my-5">
                <i class="bi bi-cart-x fs-1 text-secondary opacity-50"></i>
                <p class="small mt-2">Chưa chọn món. Chạm sản phẩm ở lưới giữa để tạo đơn.</p>
            </div>`;
        recalculatePOSBill(0);
        return;
    }

    container.innerHTML = '';
    let tongTienHang = 0;
    posCart.forEach((item, idx) => {
        let toppingTotal = item.toppings.reduce((sum, t) => sum + (t.giaTp * t.soLuongTp), 0);
        let rowPrice = (item.giaBan + toppingTotal) * item.soLuong;
        tongTienHang += rowPrice;
        container.innerHTML += `
            <div class="pos-cart-item p-3 border-bottom d-flex justify-content-between align-items-center">
                <div class="cart-item-details">
                    <span class="fw-bold text-dark d-block" style="font-size: 14px;">${item.tenSp} (Size ${item.tenSize})</span>
                    <div class="small text-muted" style="font-size: 11px; margin-top: 2px;">
                        Đá: ${item.mucDa} | Đường: ${item.mucDuong}
                        ${item.toppings.map(t => `<br>+ Topping: ${t.tenTp}`).join('')}
                    </div>
                    <div class="text-success fw-bold mt-1" style="font-size: 13px;">${formatVND(rowPrice)}</div>
                </div>
                <div class="d-flex flex-column align-items-end gap-2">
                    <button class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 12px;" onclick="removeCartItem(${idx})">
                        <i class="bi bi-trash"></i>
                    </button>
                    <div class="input-group input-group-sm" style="width: 80px;">
                        <button class="btn btn-outline-secondary px-2" onclick="changeQty(${idx}, -1)">-</button>
                        <span class="form-control text-center bg-white border-secondary border-opacity-25 px-0 fw-bold" style="font-size: 12px;">${item.soLuong}</span>
                        <button class="btn btn-outline-secondary px-2 text-success" onclick="changeQty(${idx}, 1)">+</button>
                    </div>
                </div>
            </div>
        `;
    });

    recalculatePOSBill(tongTienHang);
}

// Thuật toán dồn tiền hóa đơn tích hợp khấu trừ Voucher và Điểm thưởng VIP
function recalculatePOSBill(tongTienHang) {
    let rawSum = tongTienHang;
    let discount = 0;

    // 1. Áp dụng khấu trừ mã Voucher Khuyến Mãi nếu có
    if (appliedVoucher) {
        if (rawSum >= appliedVoucher.donToiThieu) {
            if (appliedVoucher.loaiGiam === 1) { // Trực tiếp trừ tiền mặt
                discount = appliedVoucher.giaTriGiam;
            } else { // Trừ chiết khấu %
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
            showToast('warning', 'Hóa đơn chưa đạt ngưỡng tối thiểu ' + formatVND(appliedVoucher.donToiThieu) + ' để sử dụng mã!');
            appliedVoucher = null;
            document.getElementById("summaryDiscountRow").style.display = "none";
            document.getElementById("submit_maKm").value = "";
            document.getElementById("submit_tienGiamGia").value = "0";
        }
    }

    // 2. Quy đổi tích điểm CRM của khách hàng (1 điểm đổi 1.000 VNĐ)
    let pointsDiscount = appliedPoints * 1000;
    if (pointsDiscount > (rawSum - discount)) {
        pointsDiscount = rawSum - discount; // Chống dồn âm tiền đơn hàng
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

    // 3. Tính thuế GTGT VAT 8% tiêu chuẩn quốc gia
    let vatPrice = Math.round(billBeforeTax * 0.08);
    let finalPayable = billBeforeTax + vatPrice;

    // Nạp các giá trị ra giao diện UI
    document.getElementById('totalRawPrice').innerText = formatVND(rawSum);
    document.getElementById('totalTaxPrice').innerText = formatVND(vatPrice);
    document.getElementById('totalPayablePrice').innerText = formatVND(finalPayable);

    // Nạp giá trị vào input ẩn nộp lên Controller
    document.getElementById('submit_tongTienHang').value = rawSum;
    document.getElementById('submit_tongPhaiTra').value = finalPayable;
}

function changeQty(idx, change) {
    posCart[idx].soLuong += change;
    if (posCart[idx].soLuong <= 0) {
        posCart.splice(idx, 1);
    }
    renderPosCart();
}

function removeCartItem(idx) {
    posCart.splice(idx, 1);
    renderPosCart();
}

// Kết nối động Cổng dữ liệu thành viên CRM qua cuộc gọi AJAX
function searchCustomerCRM() {
    const sdt = document.getElementById('customerPhoneSearch').value;
    if (!sdt) return;

    // Ghép Context Path tự động để máy thu ngân load mượt mà không lỗi 404
    fetch(getContextPath() + '/pos/search-customer?sdt=' + sdt)
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                customerInfo = data;
                document.getElementById('submit_maKh').value = data.maKh;
                document.getElementById('customerNameResult').innerText = data.tenKh;

                // Đối soát tên hạng hội viên
                let rankName = 'MỚI';
                if (data.maHang === 1) rankName = 'ĐỒNG';
                else if (data.maHang === 2) rankName = 'BẠC';
                else if (data.maHang === 3) rankName = 'VÀNG 👑';
                else if (data.maHang === 4) rankName = 'VIP 💎';

                document.getElementById('customerPoints').innerText = 'Hạng: ' + rankName + ' | ' + data.diemTichLuy + ' Điểm';
                showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
                document.getElementById("crmLoyaltyArea").style.display = "block";
            } else {
                customerInfo = null;
                document.getElementById('submit_maKh').value = "";
                document.getElementById('customerNameResult').innerText = "Khách lẻ vãng lai";
                document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                document.getElementById("crmLoyaltyArea").style.display = "none";
                resetVoucherAndPoints();
                renderPosCart();
            }
        });
}

// Hộp thoại lựa chọn Voucher VIP cho thành viên ngay tại quầy
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
            text: 'Thành viên hiện tại chưa tích lũy được Voucher VIP khả dụng nào!',
            confirmButtonColor: '#10b981'
        });
        return;
    }

    let selectHtml = '<select id="posVoucherSelector" class="form-select mb-2"><option value="">-- Bỏ áp dụng Voucher --</option>';
    customerInfo.vouchers.forEach(v => {
        let txtType = v.loaiGiam === 1 ? formatVND(v.giaTriGiam) : v.giaTriGiam + "%";
        selectHtml += `<option value="${v.maCode}">${v.maCode} (Giảm ${txtType} | Đơn từ ${formatVND(v.donToiThieu)})</option>`;
    });
    selectHtml += '</select>';

    Swal.fire({
        title: 'KHO VOUCHER KHẢ DỤNG',
        html: `<p class="small text-muted text-start mb-3">Hệ thống Loyalty phát hiện thành viên có các ưu đãi sau. Hãy chọn một mã để kích hoạt:</p>${selectHtml}`,
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
            renderPosCart();
        }
    });
}

// Hộp thoại quy đổi điểm Loyalty CRM tại quầy
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
        text: `Hội viên hiện đang sở hữu ${customerInfo.diemTichLuy} điểm tích lũy. Nhập số điểm muốn tiêu dùng quy đổi (1 Điểm = 1.000 VNĐ):`,
        input: 'number',
        inputAttributes: {
            min: 1,
            max: customerInfo.diemTichLuy,
            step: 1
        },
        showCancelButton: true,
        confirmButtonColor: '#2563eb',
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
            showToast('success', `Đồng ý khấu trừ ${appliedPoints} điểm tích lũy của khách.`);
            renderPosCart();
        }
    });
}

// Hàm format tiền tệ VNĐ dễ nhìn
function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}