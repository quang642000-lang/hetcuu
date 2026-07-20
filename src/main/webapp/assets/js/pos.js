let posCart = [];
let customerInfo = null;
let appliedVoucher = null;
let appliedPoints = 0;
let posQrCountdownInterval = null;
let posQrPollInterval = null;
let posQrTimeout = null;
let isPosQrActive = false;
let currentPosQrOrderId = "";

function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
}

function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

function resetVoucherAndPoints() {
    appliedVoucher = null;
    appliedPoints = 0;
    const maKmEl = document.getElementById("submit_maKm");
    const valGiamEl = document.getElementById("submit_tienGiamGia");
    const dsuDungEl = document.getElementById("submit_diemSuDung");
    const valTruDiemEl = document.getElementById("submit_tienTruDiem");
    const sumDiscRow = document.getElementById("summaryDiscountRow");
    const sumPtsRow = document.getElementById("summaryPointsRow");
    const manualVoucherEl = document.getElementById("manualVoucherInput");

    if (maKmEl) maKmEl.value = "";
    if (valGiamEl) valGiamEl.value = "0";
    if (dsuDungEl) dsuDungEl.value = "0";
    if (valTruDiemEl) valTruDiemEl.value = "0";

    if (sumDiscRow) sumDiscRow.style.setProperty('display', 'none', 'important');
    if (sumPtsRow) sumPtsRow.style.setProperty('display', 'none', 'important');
    if (manualVoucherEl) manualVoucherEl.value = "";
}

function clearFullPosCart() {
    posCart = [];
    customerInfo = null;
    document.getElementById('submit_maKh').value = "";
    document.getElementById('customerPhoneSearch').value = "";
    const nameResult = document.getElementById('customerNameResult');
    if (nameResult) nameResult.innerText = "Khách lẻ vãng lai";
    const ptsResult = document.getElementById("customerPoints");
    if (ptsResult) ptsResult.innerText = "Hạng: Mới | 0 Điểm";
    const crmLoyaltyArea = document.getElementById("crmLoyaltyArea");
    if (crmLoyaltyArea) crmLoyaltyArea.style.setProperty('display', 'none', 'important');
    const posAddCustomerArea = document.getElementById("posAddCustomerArea");
    if (posAddCustomerArea) posAddCustomerArea.style.setProperty('display', 'none', 'important');
    const manualVoucherInput = document.getElementById("manualVoucherInput");
    if (manualVoucherInput) manualVoucherInput.value = "";
    resetVoucherAndPoints();
    renderPosCart();
}

function toggleToppingQty(checkbox, maTp) {
    const container = document.getElementById('tp_qty_container_' + maTp);
    const qtyInput = document.getElementById('tp_qty_' + maTp);
    if (checkbox.checked) {
        if (container) container.style.setProperty('display', 'flex', 'important');
        if (qtyInput) {
            qtyInput.value = 1;
            recalculatePopupPrice();
        }
    } else {
        if (container) container.style.setProperty('display', 'none', 'important');
        if (qtyInput) {
            qtyInput.value = 1;
            recalculatePopupPrice();
        }
    }
}

function changePopupTpQty(maTp, delta) {
    const qtyInput = document.getElementById('tp_qty_' + maTp);
    if (!qtyInput) return;
    let val = parseInt(qtyInput.value) || 1;
    val += delta;
    if (val < 1) val = 1;
    qtyInput.value = val;
    recalculatePopupPrice();
}

function recalculatePopupPrice() {
    const activeSize = document.querySelector('.size-radio:checked');
    if (!activeSize) return;
    let basePrice = parseInt(activeSize.dataset.price) || 0;
    let toppingSum = 0;
    document.querySelectorAll('.topping-check:checked').forEach(chk => {
        let price = parseInt(chk.dataset.price) || 0;
        let qtyInput = document.getElementById('tp_qty_' + chk.value);
        let qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
        toppingSum += (price * qty);
    });
    let total = basePrice + toppingSum;
    const totalEl = document.getElementById('popup_total');
    if (totalEl) totalEl.innerText = formatVND(total);
}

function openCustomizePopup(maSp, tenSp, encodedOptions) {
    const rawOptions = JSON.parse(decodeURIComponent(encodedOptions));
    let html = '';
    html += '<div id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '" class="text-start p-2">';

    // 1. CHỌN SIZE
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 text-secondary">1. CHỌN KÍCH CỠ LY NƯỚC (SIZE)</label>';
    html += '    <div class="row g-2">';
    if (rawOptions.sizesList && rawOptions.sizesList.length > 0) {
        let isFirstSize = true;
        rawOptions.sizesList.forEach(sz => {
            let sizeName = sz.tenSize || (sz.maSize === 1 ? 'S' : (sz.maSize === 2 ? 'M' : 'L'));
            let checked = isFirstSize ? 'checked' : '';
            html += '      <div class="col-4">';
            html += '        <input type="radio" class="btn-check size-radio" name="popup_size" id="size_' + sz.maSize + '" value="' + sz.maSize + '" data-price="' + sz.giaBan + '" data-name="' + sizeName + '" ' + checked + ' onchange="recalculatePopupPrice()">';
            html += '        <label class="btn btn-outline-success w-100 py-2 fw-bold text-center small" for="size_' + sz.maSize + '">';
            html += '          Size ' + sizeName + '<br><small class="text-muted fw-normal" style="font-size:10px;">+' + formatVND(sz.giaBan) + '</small>';
            html += '        </label>';
            html += '      </div>';
            isFirstSize = false;
        });
    }
    html += '    </div>';
    html += '  </div>';

    // 2. MỨC ĐÁ
    if (rawOptions.choPhepDoiDa) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">2. MỨC ĐỘ ĐÁ LẠNH</label>';
        html += '    <div class="d-flex justify-content-between gap-2">';
        ['100% Đá', '70% Đá', '50% Đá', '0% Đá'].forEach((da, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_ice" id="ice_' + i + '" value="' + da + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2 py-1.5 text-center flex-fill" for="ice_' + i + '">' + da + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 3. MỨC ĐƯỜNG
    if (rawOptions.choPhepDoiDuong) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">3. MỨC ĐỘ ĐƯỜNG NGỌT</label>';
        html += '    <div class="d-flex justify-content-between gap-2">';
        ['100% Đường', '70% Đường', '50% Đường', '0% Đường'].forEach((duong, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_sugar" id="sugar_' + i + '" value="' + duong + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2 py-1.5 text-center flex-fill" for="sugar_' + i + '">' + duong + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 4. TOPPINGS
    if (rawOptions.choPhepTopping && rawOptions.allToppings && rawOptions.allToppings.length > 0) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">4. THÊM TOPPING DAI GIÒN SẦN SẬT</label>';
        html += '    <div style="max-height: 180px; overflow-y: auto;" class="custom-scrollbar pr-1">';
        rawOptions.allToppings.forEach(tp => {
            let imgHtml = tp.hinhAnh ? '<img src="' + tp.hinhAnh + '" class="rounded me-2 border" style="width: 28px; height: 28px; object-fit: cover;">' : '';
            html += '      <div class="d-flex justify-content-between align-items-center p-1.5 border-bottom bg-white">';
            html += '        <div class="d-flex align-items-center">';
            html += '          <input class="form-check-input topping-check me-2" type="checkbox" id="tp_' + tp.maTp + '" value="' + tp.maTp + '" data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" onchange="toggleToppingQty(this, \'' + tp.maTp + '\')">';
            html += imgHtml;
            html += '          <label class="form-check-label small fw-semibold text-dark" for="tp_' + tp.maTp + '">' + tp.tenTp + '<br><span class="text-success" style="font-size:10px;">+' + formatVND(tp.giaBan) + '</span></label>';
            html += '        </div>';
            html += '        <div class="d-flex align-items-center gap-1" id="tp_qty_container_' + tp.maTp + '" style="display: none !important;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-1.5 py-0" onclick="changePopupTpQty(\'' + tp.maTp + '\', -1)">-</button>';
            html += '          <input type="text" class="form-control text-center p-0 fw-bold border-0" id="tp_qty_' + tp.maTp + '" value="1" readonly style="width: 24px; font-size:12px; background: transparent;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-1.5 py-0" onclick="changePopupTpQty(\'' + tp.maTp + '\', 1)">+</button>';
            html += '        </div>';
            html += '      </div>';
        });
        html += '    </div>';
        html += '  </div>';
    } else if (rawOptions.choPhepTopping === false) {
        html += '  <div class="mb-3 p-3 bg-light rounded border border-dashed text-center">';
        html += '    <span class="text-muted small fw-semibold"><i class="bi bi-info-circle text-warning"></i> Sản phẩm này không áp dụng Topping!</span>';
        html += '  </div>';
    }

    // 5. GHI CHÚ
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 text-secondary">5. GHI CHÚ PHA CHẾ</label>';
    html += '    <textarea class="form-control" id="popup_note" rows="2" placeholder="Ít đá, mang ly đá riêng..."></textarea>';
    html += '  </div>';

    // THÀNH TIỀN
    html += '  <div class="d-flex justify-content-between align-items-center mt-4 border-top pt-3">';
    html += '    <div>';
    html += '      <small class="text-muted d-block" style="font-size: 11px;">Thành tiền ly đơn:</small>';
    html += '      <span class="fw-bold fs-4 text-success" id="popup_total">0 đ</span>';
    html += '    </div>';
    html += '    <button class="btn btn-success fw-bold px-4 py-2.5" onclick="addCustomizedToCart()">';
    html += '      <i class="bi bi-cart-plus me-1"></i> THÊM VÀO ĐƠN';
    html += '    </button>';
    html += '  </div>';
    html += '</div>';

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'TÙY BIẾN PHA CHẾ ĐỒ UỐNG',
            html: html,
            showConfirmButton: false,
            width: '460px',
            didOpen: () => { recalculatePopupPrice(); }
        });
    }
}

function addCustomizedToCart() {
    const el = document.getElementById('posCustomizer');
    const maSp = el.dataset.masp;
    const tenSp = el.dataset.tensp;
    const checkedSize = document.querySelector('.size-radio:checked');
    const maSize = parseInt(checkedSize.value);
    const tenSize = checkedSize.dataset.name;
    const giaBan = parseInt(checkedSize.dataset.price);

    const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
    const sugar = sugarEl ? sugarEl.value : '100% Đường';
    const iceEl = document.querySelector('input[name="popup_ice"]:checked');
    const ice = iceEl ? iceEl.value : '100% Đá';
    const note = document.getElementById('popup_note').value.trim() || 'Normal';

    let toppings = [];
    document.querySelectorAll('.topping-check:checked').forEach(chk => {
        let tpPrice = parseInt(chk.dataset.price) || 0;
        let tpName = chk.dataset.name;
        let tpQtyInput = document.getElementById('tp_qty_' + chk.value);
        let tpQty = tpQtyInput ? (parseInt(tpQtyInput.value) || 1) : 1;
        toppings.push({
            maTp: chk.value,
            tenTopping: tpName,
            soLuongTp: tpQty,
            giaTp: tpPrice
        });
    });

    let duplicateItem = posCart.find(item =>
        item.maSp === maSp &&
        item.maSize === maSize &&
        item.mucDa === ice &&
        item.mucDuong === sugar &&
        item.ghiChuMon === note &&
        isSameToppingsList(item.toppings, toppings)
    );

    if (duplicateItem) {
        duplicateItem.soLuong += 1;
    } else {
        posCart.push({
            maSp: maSp,
            tenSp: tenSp,
            maSize: maSize,
            tenSize: tenSize,
            giaBan: giaBan,
            mucDa: ice,
            mucDuong: sugar,
            ghiChuMon: note,
            toppings: toppings,
            soLuong: 1
        });
    }

    Swal.close();
    renderPosCart();
}

function isSameToppingsList(arr1, arr2) {
    if (arr1.length !== arr2.length) return false;
    for (let i = 0; i < arr1.length; i++) {
        let t1 = arr1[i];
        let t2 = arr2.find(x => x.maTp === t1.maTp);
        if (!t2 || t1.soLuongTp !== t2.soLuongTp) return false;
    }
    return true;
}

function renderPosCart() {
    const container = document.getElementById('posCartItems');
    if (!container) return;
    container.innerHTML = '';

    if (posCart.length === 0) {
        container.innerHTML = '<div class="text-center text-muted py-5 my-5">' +
            '  <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>' +
            '  <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>' +
            '</div>';
        recalculatePOSBill(0);

        // Update Mobile Cart count
        const mobileBadge = document.getElementById("mobileCartCount");
        if (mobileBadge) mobileBadge.innerText = "0";
        return;
    }

    let tongTienHang = 0;
    posCart.forEach((item, idx) => {
        let toppingsPrice = item.toppings.reduce((sum, t) => sum + (t.giaTp * t.soLuongTp), 0);
        let lineTotal = (item.giaBan + toppingsPrice) * item.soLuong;
        tongTienHang += lineTotal;

        let toppingsText = '';
        if (item.toppings.length > 0) {
            toppingsText = '<div class="text-success small" style="font-size: 10px; font-weight:600;">Toppings: ' +
                item.toppings.map(t => t.tenTopping + ' (x' + t.soLuongTp + ')').join(', ') + '</div>';
        }
        let noteText = item.ghiChuMon !== 'Normal' ? ' | Ghi chú: <span class="text-danger fw-semibold">' + item.ghiChuMon + '</span>' : '';

        let cardHtml = '<div class="pos-cart-item p-2.5 bg-white border border-secondary border-opacity-10 rounded-3 mb-2 shadow-sm">' +
            '  <div class="d-flex justify-content-between align-items-start">' +
            '    <div class="text-start">' +
            '      <span class="fw-bold text-dark" style="font-size:13px;">' + item.tenSp + '</span> <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25" style="font-size: 10px; border-radius: 4px;">Size ' + item.tenSize + '</span>' +
            '      <div class="text-muted" style="font-size:10.5px; margin-top:2px;">' +
            '        Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + noteText + toppingsText +
            '      </div>' +
            '    </div>' +
            '    <button type="button" class="btn btn-link text-danger p-0 border-0 ms-2 animate-pulse" onclick="removeCartItem(' + idx + ')"><i class="bi bi-trash3-fill"></i></button>' +
            '  </div>' +
            '  <div class="d-flex justify-content-between align-items-center mt-2">' +
            '    <div class="fw-bold text-success font-monospace">' + formatVND(lineTotal) + '</div>' +
            '    <div class="input-group input-group-sm" style="width: 80px;">' +
            '      <button type="button" class="btn btn-outline-secondary px-2 py-0" onclick="changeQty(' + idx + ', -1)">-</button>' +
            '      <span class="form-control text-center bg-white border-secondary border-opacity-25 px-0 fw-bold" style="font-size: 12px; height: 24px; display: flex; align-items: center; justify-content: center;">' + item.soLuong + '</span>' +
            '      <button type="button" class="btn btn-outline-secondary px-2 py-0 text-success" onclick="changeQty(' + idx + ', 1)">+</button>' +
            '    </div>' +
            '  </div>' +
            '</div>';
        container.insertAdjacentHTML('beforeend', cardHtml);
    });

    recalculatePOSBill(tongTienHang);

    // Update Mobile Cart count
    const mobileBadge = document.getElementById("mobileCartCount");
    if (mobileBadge) {
        mobileBadge.innerText = posCart.reduce((sum, item) => sum + item.soLuong, 0);
    }
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

function searchCustomerCRM() {
    const sdt = document.getElementById('customerPhoneSearch').value.trim();
    if (!sdt || sdt.length < 10) return;
    fetch(getContextPath() + '/pos/search-customer?sdt=' + sdt)
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
                document.getElementById("crmLoyaltyArea").style.setProperty('display', 'block', 'important');
                document.getElementById("posAddCustomerArea").style.setProperty('display', 'none', 'important');
                resetVoucherAndPoints();
                renderPosCart();
                Swal.fire({ icon: 'success', title: 'Thành viên', text: 'Tìm thấy: ' + data.tenKh, confirmButtonColor: '#10b981', timer: 1500 });
            } else {
                customerInfo = null;
                document.getElementById('submit_maKh').value = "";
                document.getElementById('customerNameResult').innerText = "Khách lẻ vãng lai";
                document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                document.getElementById("crmLoyaltyArea").style.setProperty('display', 'none', 'important');
                document.getElementById("posAddCustomerArea").style.setProperty('display', 'block', 'important');
                Swal.fire({
                    title: 'Hội viên chưa đăng ký',
                    text: 'Số điện thoại này chưa liên kết thẻ. Đăng ký nhanh CRM?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#10b981',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Đăng ký ngay',
                    cancelButtonText: 'Để sau'
                }).then((res) => {
                    if (res.isConfirmed) {
                        openQuickRegisterModal(sdt);
                    }
                });
            }
        })
        .catch(err => console.error("Lỗi đối soát CRM:", err));
}

function openQuickRegisterModal(sdt) {
    let html = '';
    html += '<div class="text-start p-2">';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Số điện thoại đăng ký</label>';
    html += '    <input type="text" class="form-control" id="reg_sdt" value="' + sdt + '" readonly>';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Họ và tên khách hàng</label>';
    html += '    <input type="text" class="form-control" id="reg_tenKh" placeholder="Nhập tên..." required>';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Email nhận mã OTP</label>';
    html += '    <input type="email" class="form-control" id="reg_email" placeholder="example@gmail.com..." required>';
    html += '  </div>';
    html += '</div>';

    Swal.fire({
        title: 'ĐĂNG KÝ HỘI VIÊN NHANH',
        html: html,
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Xác nhận tạo thẻ',
        cancelButtonText: 'Hủy bỏ',
        preConfirm: () => {
            const tenKh = document.getElementById("reg_tenKh").value.trim();
            const email = document.getElementById("reg_email").value.trim();
            if (!tenKh || !email) {
                Swal.showValidationMessage('Vui lòng điền họ tên và email hợp lệ!');
                return false;
            }
            return { tenKh: tenKh, email: email, sdt: sdt };
        }
    }).then((result) => {
        if (result.isConfirmed) {
            Swal.fire({ title: 'Đang xử lý...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });
            fetch(getContextPath() + '/pos/search-customer?action=quickRegister', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams(result.value)
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'SUCCESS') {
                        customerInfo = data;
                        document.getElementById('submit_maKh').value = data.maKh;
                        document.getElementById('customerNameResult').innerText = data.tenKh;
                        document.getElementById('customerPoints').innerText = 'Hạng: ĐỒNG | 0 Điểm';
                        document.getElementById("crmLoyaltyArea").style.setProperty('display', 'block', 'important');
                        document.getElementById("posAddCustomerArea").style.setProperty('display', 'none', 'important');
                        Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đăng ký thành công hội viên CRM!', confirmButtonColor: '#10b981' });
                        resetVoucherAndPoints();
                        renderPosCart();
                    } else {
                        Swal.fire({ icon: 'error', title: 'Thất bại', text: data.message });
                    }
                });
        }
    });
}

function applyManualVoucherCode() {
    const code = document.getElementById("manualVoucherInput").value.trim().toUpperCase();
    if (!code) return;
    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
    if (totalRaw === 0) return;
    const maKh = document.getElementById("submit_maKh").value;

    fetch(getContextPath() + '/pos/apply-voucher', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ code: code, maKh: maKh, tongTienHang: totalRaw.toString() })
    })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                appliedVoucher = {
                    maKm: data.maKm,
                    maCode: data.maCode,
                    tenKm: data.tenKm,
                    loaiGiam: data.loaiGiam,
                    giaTriGiam: data.giaTriGiam,
                    giamToiDa: data.giamToiDa,
                    donToiThieu: data.donToiThieu
                };
                recalculatePOSBill(totalRaw);
                Swal.fire({ icon: 'success', title: 'Thành công', text: 'Áp dụng Voucher ' + code + ' thành công!', confirmButtonColor: '#10b981', timer: 1500 });
            } else {
                Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message });
            }
        });
}

function showVoucherSelectionModal() {
    if (!customerInfo) return;
    if (posCart.length === 0) return;
    if (!customerInfo.vouchers || customerInfo.vouchers.length === 0) {
        Swal.fire({ icon: 'info', title: 'Ví voucher rỗng', text: 'Hội viên hiện chưa có Voucher VIP khả dụng!', confirmButtonColor: '#10b981' });
        return;
    }

    let selectHtml = '<select id="posVoucherSelector" class="form-select mb-2"><option value="">-- Bỏ áp dụng Voucher --</option>';
    customerInfo.vouchers.forEach(v => {
        let txtType = v.loaiGiam === 1 ? formatVND(v.giaTriGiam) : v.giaTriGiam + "%";
        selectHtml += '<option value="' + v.maCode + '">' + v.maCode + ' (Giảm ' + txtType + ' | Đơn từ ' + formatVND(v.donToiThieu) + ')</option>';
    });
    selectHtml += '</select>';

    Swal.fire({
        title: 'HỘP THƯ VOUCHER THÀNH VIÊN',
        html: selectHtml,
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Đồng ý áp dụng',
        cancelButtonText: 'Hủy bộ'
    }).then((result) => {
        if (result.isConfirmed) {
            const code = document.getElementById("posVoucherSelector").value;
            if (code) {
                const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
                fetch(getContextPath() + '/pos/apply-voucher', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({ code: code, maKh: customerInfo.maKh, tongTienHang: totalRaw.toString() })
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.status === 'SUCCESS') {
                            appliedVoucher = {
                                maKm: data.maKm,
                                maCode: data.maCode,
                                tenKm: data.tenKm,
                                loaiGiam: data.loaiGiam,
                                giaTriGiam: data.giaTriGiam,
                                giamToiDa: data.giamToiDa,
                                donToiThieu: data.donToiThieu
                            };
                            recalculatePOSBill(totalRaw);
                        } else {
                            Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message });
                        }
                    });
            } else {
                appliedVoucher = null;
                recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
            }
        }
    });
}

function applyPointsDiscount() {
    if (!customerInfo || customerInfo.diemTichLuy <= 0) return;
    Swal.fire({
        title: 'QUY ĐỔI ĐIỂM CRM TÍCH LŨY',
        text: 'Hội viên đang có ' + customerInfo.diemTichLuy + ' điểm. Quy đổi điểm (1đ = 1.000đ):',
        input: 'number',
        inputAttributes: { min: 1, max: customerInfo.diemTichLuy, step: 1 },
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Xác nhận trừ điểm',
        cancelButtonText: 'Hủy bộ',
        preConfirm: (val) => {
            const pts = parseInt(val);
            if (isNaN(pts) || pts <= 0 || pts > customerInfo.diemTichLuy) {
                Swal.showValidationMessage('Số điểm quy đổi không hợp lệ!');
            }
            return pts;
        }
    }).then((result) => {
        if (result.isConfirmed) {
            appliedPoints = result.value;
            recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
        }
    });
}

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
            document.getElementById("summaryDiscountRow").style.setProperty('display', 'flex', 'important');
            document.getElementById("txtAppliedCode").innerText = appliedVoucher.maCode;
            document.getElementById("totalDiscountPrice").innerText = "-" + formatVND(discount);
            document.getElementById("submit_maKm").value = appliedVoucher.maKm.toString();
            document.getElementById("submit_tienGiamGia").value = discount.toString();
        } else {
            appliedVoucher = null;
            document.getElementById("summaryDiscountRow").style.setProperty('display', 'none', 'important');
            document.getElementById("submit_maKm").value = "";
            document.getElementById("submit_tienGiamGia").value = "0";
        }
    }

    let pointsDiscount = appliedPoints * 1000;
    if (pointsDiscount > (rawSum - discount)) {
        pointsDiscount = rawSum - discount;
    }

    if (appliedPoints > 0) {
        document.getElementById("summaryPointsRow").style.setProperty('display', 'flex', 'important');
        document.getElementById("txtUsedPoints").innerText = appliedPoints.toString();
        document.getElementById("totalPointsPrice").innerText = "-" + formatVND(pointsDiscount);
        document.getElementById("submit_diemSuDung").value = appliedPoints.toString();
        document.getElementById("submit_tienTruDiem").value = pointsDiscount.toString();
    } else {
        document.getElementById("summaryPointsRow").style.setProperty('display', 'none', 'important');
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

    document.getElementById('submit_tongTienHang').value = rawSum.toString();
    document.getElementById('submit_tongPhaiTra').value = finalPayable.toString();

    calculateChangeRefund();
}

function calculateChangeRefund() {
    let khachDua = parseInt(document.getElementById('inputCustomerCash').value) || 0;
    let phaiTra = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;
    let refund = khachDua - phaiTra;
    let txtCashRefundEl = document.getElementById('txtCashRefund');
    if (!txtCashRefundEl) return;

    if (refund < 0) {
        txtCashRefundEl.innerText = 'Khách đưa thiếu';
        txtCashRefundEl.className = 'text-danger fw-bold';
    } else {
        txtCashRefundEl.innerText = refund.toLocaleString('vi-VN') + ' đ';
        txtCashRefundEl.className = 'text-success fw-bold';
    }
}

function suggestCashAmount(amount) {
    const inputCustomerCashEl = document.getElementById('inputCustomerCash');
    if (!inputCustomerCashEl) return;
    if (amount === 0) {
        const phaiTra = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;
        inputCustomerCashEl.value = phaiTra;
    } else {
        inputCustomerCashEl.value = amount;
    }
    calculateChangeRefund();
}

function changePaymentMethod(maPt) {
    document.getElementById('submit_maPt').value = maPt;
    const cashSection = document.getElementById('cashCalculatorSection');
    const cashRadio = document.getElementById('pt_cash');
    const qrRadio = document.getElementById('pt_qr');

    if (maPt === 1 && cashRadio) cashRadio.checked = true;
    if (maPt === 2 && qrRadio) qrRadio.checked = true;

    if (maPt === 2) {
        if (cashSection) cashSection.style.setProperty('display', 'none', 'important');
    } else {
        if (cashSection) cashSection.style.setProperty('display', 'block', 'important');
    }
}

function showPosQrCodeModal(orderId, payable) {
    currentPosQrOrderId = orderId;
    isPosQrActive = true;
    document.getElementById("posQrAmount").innerText = formatVND(parseInt(payable));
    document.getElementById("posQrCodeDisplay").innerText = orderId;
    document.getElementById("posQrImage").src = `https://img.vietqr.io/image/TPB-0346406405-compact2.png?amount=${payable}&addInfo=${orderId}`;
    document.getElementById("posQrSuccessOverlay").style.setProperty("display", "none", "important");
    document.getElementById("posQrExpiredOverlay").style.setProperty("display", "none", "important");
    document.getElementById("posQrLoadingStatus").style.setProperty("display", "flex", "important");

    let secondsLeft = 120;
    const countdownText = document.getElementById("posQrCountdownText");
    countdownText.innerText = secondsLeft;

    const qrModalEl = document.getElementById("posQrModal");
    const qrModalInstance = new bootstrap.Modal(qrModalEl);
    qrModalInstance.show();

    clearInterval(posQrCountdownInterval);
    posQrCountdownInterval = setInterval(() => {
        secondsLeft--;
        countdownText.innerText = secondsLeft;
        if (secondsLeft <= 0) {
            clearInterval(posQrCountdownInterval);
            clearInterval(posQrPollInterval);
            isPosQrActive = false;
            document.getElementById("posQrExpiredOverlay").style.setProperty("display", "flex", "important");
            document.getElementById("posQrLoadingStatus").style.setProperty("display", "none", "important");
        }
    }, 1000);

    clearInterval(posQrPollInterval);
    posQrPollInterval = setInterval(() => {
        if (!isPosQrActive) return;
        fetch(getContextPath() + '/api/check-payment?id=' + orderId)
            .then(res => res.json())
            .then(data => {
                if (data.status === 'SUCCESS') {
                    clearInterval(posQrPollInterval);
                    clearInterval(posQrCountdownInterval);
                    document.getElementById("posQrSuccessOverlay").style.setProperty("display", "flex", "important");
                    document.getElementById("posQrLoadingStatus").style.setProperty("display", "none", "important");
                    setTimeout(() => {
                        qrModalInstance.hide();
                        loadAndShowPrintReceipt(orderId);
                    }, 1500);
                }
            })
            .catch(err => console.error("Lỗi polling check payment:", err));
    }, 3000);
}

function cancelQRPayment() {
    isPosQrActive = false;
    clearInterval(posQrPollInterval);
    clearInterval(posQrCountdownInterval);
    const qrModalEl = document.getElementById("posQrModal");
    const qrModalInstance = bootstrap.Modal.getInstance(qrModalEl);
    if (qrModalInstance) qrModalInstance.hide();
}

function forceSubmitCheckout() {
    Swal.fire({
        title: 'Bỏ qua chuyển khoản?',
        text: 'Chốt đơn hàng thủ công (ghi nhận đã chuyển khoản ngoài)?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Xác nhận thu tiền',
        cancelButtonText: 'Hủy bỏ'
    }).then((res) => {
        if (res.isConfirmed) {
            clearInterval(posQrPollInterval);
            clearInterval(posQrCountdownInterval);
            const qrModalEl = document.getElementById("posQrModal");
            const qrModalInstance = bootstrap.Modal.getInstance(qrModalEl);
            if (qrModalInstance) qrModalInstance.hide();

            fetch(getContextPath() + '/admin/hoadon?action=updateStatus&maDh=' + currentPosQrOrderId + '&trangThaiDon=1', { method: 'POST' })
                .then(() => { loadAndShowPrintReceipt(currentPosQrOrderId); });
        }
    });
}

function loadAndShowPrintReceipt(orderId) {
    const container = document.getElementById("billItemsContainer");
    if (!container) return;
    container.innerHTML = '<div class="text-center py-4">' +
        '  <div class="spinner-border text-success" role="status"></div>' +
        '  <p class="small text-muted mt-2">Đang nạp thông tin hóa đơn...</p>' +
        '</div>';

    fetch(getContextPath() + '/pos/bill-detail?id=' + orderId)
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                document.getElementById("billMaDh").innerText = data.maDh;
                document.getElementById("billThoiGian").innerText = data.thoiGianTao;
                document.getElementById("billTenKh").innerText = data.tenKhachHang ? data.tenKhachHang : 'Khách lẻ vãng lai';
                document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Đặt mua Online';
                document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';

                if (data.diemSuDung > 0) {
                    document.getElementById("billPointsRow").style.setProperty('display', 'flex', 'important');
                    document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                } else {
                    document.getElementById("billPointsRow").style.setProperty('display', 'none', 'important');
                }
                document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                container.innerHTML = '';
                data.items.forEach(item => {
                    let html = '<div class="mb-2 border-bottom pb-1 text-start">';
                    html += '  <div class="d-flex justify-content-between">';
                    html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                    html += '    <span>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</span>';
                    html += '  </div>';
                    html += '  <div class="small text-muted">Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + (item.ghiChuMon ? ' | Lưu ý: ' + item.ghiChuMon : '') + '</div>';
                    if (item.toppings && item.toppings.length > 0) {
                        html += '  <div class="text-success small pl-2" style="font-size: 10px;">';
                        item.toppings.forEach(tp => {
                            html += '    <div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                        });
                        html += '  </div>';
                    }
                    html += '</div>';
                    container.insertAdjacentHTML('beforeend', html);
                });

                if (typeof bootstrap !== 'undefined') {
                    const printModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));
                    printModal.show();
                }
            } else {
                Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Không thể lấy dữ liệu in hóa đơn!' });
            }
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

function submitPosProfile() {
    const hoTen = document.getElementById('profile_hoTen').value.trim();
    const sdt = document.getElementById('profile_sdt').value.trim();
    const email = document.getElementById('profile_email').value.trim();

    if (!hoTen || !sdt || !email) {
        Swal.fire({ icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng điền đầy đủ các trường thông tin!', confirmButtonColor: '#10b981' });
        return;
    }

    const params = new URLSearchParams();
    params.append('hoTen', hoTen);
    params.append('soDienThoai', sdt);
    params.append('email', email);

    fetch(getContextPath() + '/pos/update-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đã cập nhật thông tin cá nhân!', confirmButtonColor: '#10b981' })
                    .then(() => { location.reload(); });
            } else {
                Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Cập nhật hồ sơ thất bại!' });
            }
        })
        .catch(err => {
            console.error('Lỗi profile:', err);
            Swal.fire({ icon: 'error', title: 'Sự cố kết nối', text: 'Không thể gửi dữ liệu lên máy chủ!' });
        });
}

function submitPosPassword() {
    const oldPass = document.getElementById('password_old').value;
    const newPass = document.getElementById('password_new').value;
    const confirmPass = document.getElementById('password_confirm').value;

    if (!oldPass || !newPass || !confirmPass) {
        Swal.fire({ icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng điền đủ 3 mốc mật khẩu!', confirmButtonColor: '#10b981' });
        return;
    }
    if (newPass !== confirmPass) {
        Swal.fire({ icon: 'warning', title: 'Mật khẩu không khớp', text: 'Xác nhận mật khẩu mới không trùng khớp!', confirmButtonColor: '#10b981' });
        return;
    }
    if (newPass.length < 8) {
        Swal.fire({ icon: 'warning', title: 'Mật khẩu yếu', text: 'Mật khẩu mới bắt buộc phải chứa tối thiểu từ 8 ký tự!', confirmButtonColor: '#10b981' });
        return;
    }

    const params = new URLSearchParams();
    params.append('oldPassword', oldPass);
    params.append('newPassword', newPass);

    fetch(getContextPath() + '/pos/change-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đổi mật khẩu bảo mật thành công!', confirmButtonColor: '#10b981' })
                    .then(() => {
                        const modalEl = document.getElementById('posPasswordModal');
                        const inst = bootstrap.Modal.getInstance(modalEl);
                        if (inst) inst.hide();
                        document.getElementById('password_old').value = "";
                        document.getElementById('password_new').value = "";
                        document.getElementById('password_confirm').value = "";
                    });
            } else {
                Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Mật khẩu cũ không đúng!' });
            }
        })
        .catch(err => {
            console.error('Lỗi pass:', err);
            Swal.fire({ icon: 'error', title: 'Sự cố kết nối', text: 'Không thể kết nối máy chủ!' });
        });
}

function submitPOSOrderTransaction() {
    if (posCart.length === 0) {
        showToast('warning', 'Giỏ hàng POS trống, không thể in hóa đơn!');
        return;
    }

    const maPt = parseInt(document.getElementById('submit_maPt').value) || 1;
    if (maPt === 1) {
        const phaiTra = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;
        const cashInput = document.getElementById('inputCustomerCash');
        const khachDua = parseInt(cashInput ? cashInput.value : "0") || 0;
        if (khachDua < phaiTra) {
            Swal.fire({
                icon: 'warning',
                title: 'Chưa đủ tiền mặt',
                text: 'Vui lòng nhập số tiền khách đưa tối thiểu ' + phaiTra.toLocaleString('vi-VN') + ' đ!',
                confirmButtonColor: '#10b981'
            });
            return;
        }
    }

    const container = document.getElementById('posFormItemsContainer');
    if (!container) {
        showToast('error', 'Lỗi cấu trúc trang: Không tìm thấy posFormItemsContainer!');
        return;
    }
    container.innerHTML = '';

    posCart.forEach(item => {
        container.innerHTML += '<input type="hidden" name="item_maSp[]" value="' + item.maSp + '">';
        container.innerHTML += '<input type="hidden" name="item_maSize[]" value="' + item.maSize + '">';
        container.innerHTML += '<input type="hidden" name="item_soLuong[]" value="' + item.soLuong + '">';
        container.innerHTML += '<input type="hidden" name="item_giaChot[]" value="' + item.giaBan + '">';
        container.innerHTML += '<input type="hidden" name="item_mucDa[]" value="' + item.mucDa + '">';
        container.innerHTML += '<input type="hidden" name="item_mucDuong[]" value="' + item.mucDuong + '">';
        container.innerHTML += '<input type="hidden" name="item_ghiChuMon[]" value="' + (item.ghiChuMon ? item.ghiChuMon : 'Normal') + '">';
        let toppingKeys = item.toppings.map(t => t.maTp + "_" + t.soLuongTp + "_" + t.giaTp).join("|");
        container.innerHTML += '<input type="hidden" name="item_toppingKeys[]" value="' + toppingKeys + '">';
    });

    Swal.fire({
        title: 'Chốt giao dịch quầy POS',
        text: 'Xác nhận xuất hóa đơn tài chính và tiến hành giao dịch?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Xác nhận & Chốt đơn'
    }).then((result) => {
        if (result.isConfirmed) {
            const form = document.getElementById('posOrderForm');
            if (form) form.submit();
        }
    });
}
