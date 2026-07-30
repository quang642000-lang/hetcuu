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

function updatePOSClock() {
    const el = document.getElementById("posHeaderClock");
    if (el) {
        const now = new Date();
        const days = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"];
        const dayName = days[now.getDay()];
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        const dateStr = now.toLocaleDateString('vi-VN');
        el.innerText = dayName + ", " + hours + ":" + minutes + ":" + seconds + " | " + dateStr;
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

function filterCategory(maDm) {
    document.querySelectorAll('.pos-category-btn').forEach(btn => btn.classList.remove('active'));
    const allBtn = document.getElementById('btn_cat_all');
    const specificBtn = document.getElementById('btn_cat_' + maDm);

    if (maDm === 'all') {
        if (allBtn) allBtn.classList.add('active');
        document.querySelectorAll('#posProductGrid .pos-card-wrapper').forEach(card => {
            card.style.setProperty('display', 'block', 'important');
        });
    } else {
        if (specificBtn) specificBtn.classList.add('active');
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

function filterBadge(tag) {
    document.querySelectorAll('#f_all, #f_new, #f_hot').forEach(btn => btn.classList.remove('active-filter', 'btn-light'));
    const btn = document.getElementById('f_' + tag);
    if (btn) btn.classList.add('active-filter');

    document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
        const parent = card.closest('.pos-card-wrapper');
        const isNew = card.dataset.isnew === 'true';
        const isHot = card.dataset.ishot === 'true';

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

function searchPOSProduct() {
    const keyword = document.getElementById("posSearchProductInput").value.trim().toLowerCase();
    document.querySelectorAll('#posProductGrid .pos-product-card').forEach(card => {
        const parent = card.closest('.pos-card-wrapper');
        const name = card.querySelector('.pos-card-name').innerText.toLowerCase();
        const code = card.dataset.masp.toLowerCase();

        if (name.includes(keyword) || code.includes(keyword)) {
            parent.style.setProperty('display', 'block', 'important');
        } else {
            parent.style.setProperty('display', 'none', 'important');
        }
    });
}

function resetVoucherAndPoints() {
    appliedVoucher = null;
    appliedPoints = 0;

    const maKmEl = document.getElementById("submit_maKm");
    const valGiamEl = document.getElementById("submit_tienGiamGia");
    const dsuDungEl = document.getElementById("submit_diemSuDung");
    const ptsGiamEl = document.getElementById("submit_tienTruDiem");
    const manualVoucherEl = document.getElementById("manualVoucherInput");

    if (maKmEl) maKmEl.value = "";
    if (valGiamEl) valGiamEl.value = "0";
    if (dsuDungEl) dsuDungEl.value = "0";
    if (ptsGiamEl) ptsGiamEl.value = "0";

    const sumVoucherRow = document.getElementById("summaryDiscountRow");
    if (sumVoucherRow) sumVoucherRow.style.setProperty('display', 'none', 'important');

    const sumPtsRow = document.getElementById("summaryPointsRow");
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
        if (qtyInput) qtyInput.value = 0;
        recalculatePopupPrice();
    }
}

function adjustPopupToppingQty(maTp, delta) {
    const input = document.getElementById('tp_qty_' + maTp);
    if (input) {
        let val = parseInt(input.value) || 1;
        val += delta;
        if (val < 1) val = 1;
        input.value = val;
        recalculatePopupPrice();
    }
}

function recalculatePopupPrice() {
    const checkedSize = document.querySelector('.size-radio:checked');
    if (!checkedSize) return;
    let basePrice = parseInt(checkedSize.dataset.price) || 0;
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

function openCustomizePopup(maSp, tenSp) {
    const rawOptions = window['sp_opt_' + maSp];
    if (!rawOptions) return;

    let html = '';
    html += '<div id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '" class="text-start p-2">';

    // 1. Size Selection
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 text-secondary">1. CHỌN KÍCH CỠ LY NƯỚC (SIZE)</label>';
    html += '    <div class="row g-2">';
    if (rawOptions.sizesList && rawOptions.sizesList.length > 0) {
        let isFirstSize = true;
        rawOptions.sizesList.forEach(sz => {
            let sizeName = sz.tenSize || 'S';
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

    // 2. Ice Selection
    if (rawOptions.choPhepDoiDa) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">2. MỨC ĐỘ ĐÁ (ICE LEVEL)</label>';
        html += '    <div class="d-flex gap-2">';
        const iceOptions = ["100% Đá", "70% Đá", "50% Đá", "0% Đá"];
        iceOptions.forEach((ice, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_ice" id="ice_' + i + '" value="' + ice + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2 py-1.5 text-center flex-fill" for="ice_' + i + '">' + ice + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 3. Sugar Selection
    if (rawOptions.choPhepDoiDuong) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">3. MỨC ĐỘ ĐƯỜNG (SUGAR LEVEL)</label>';
        html += '    <div class="d-flex gap-2">';
        const sugarOptions = ["100% Đường", "70% Đường", "50% Đường", "0% Đường"];
        sugarOptions.forEach((duong, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_sugar" id="sugar_' + i + '" value="' + duong + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2 py-1.5 text-center flex-fill" for="sugar_' + i + '">' + duong + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 4. Toppings selection
    if (rawOptions.choPhepTopping && rawOptions.allToppings && rawOptions.allToppings.length > 0) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">4. THÊM TOPPING DAI GIÒN SẦN SẬT</label>';
        html += '    <div style="max-height: 180px; overflow-y: auto;" class="custom-scrollbar pr-1">';
        rawOptions.allToppings.forEach(tp => {
            let imgHtml = tp.hinhAnh ? '<img src="' + tp.hinhAnh + '" class="rounded me-2 border" style="width: 28px; height: 28px; object-fit: cover;">' : '';
            html += '      <div class="d-flex justify-content-between align-items-center p-1.5 border-bottom bg-white">';
            html += '        <div class="d-flex align-items-center">';
            html += '          <input class="form-check-input topping-check me-2" type="checkbox" id="tp_' + tp.maTp + '" value="' + tp.maTp + '" data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" onchange="toggleToppingQty(this, \'' + tp.maTp + '\')">';
            html += '          <label class="form-check-label text-dark small fw-semibold" for="tp_' + tp.maTp + '">' + imgHtml + tp.tenTp + '</label>';
            html += '        </div>';
            html += '        <div class="d-flex align-items-center gap-1.5">';
            html += '          <span class="text-success font-monospace small fw-bold me-2">+' + formatVND(tp.giaBan) + '</span>';
            html += '          <div class="input-group input-group-sm" id="tp_qty_container_' + tp.maTp + '" style="width: 84px; display: none !important;">';
            html += '            <button type="button" class="btn btn-outline-secondary px-2 py-0 border-end-0" onclick="adjustPopupToppingQty(\'' + tp.maTp + '\', -1)">-</button>';
            html += '            <input type="text" class="form-control text-center bg-white px-0 fw-bold border-secondary border-opacity-25" id="tp_qty_' + tp.maTp + '" value="0" readonly style="font-size: 11.5px; height: 24px;">';
            html += '            <button type="button" class="btn btn-outline-secondary px-2 py-0 text-success border-start-0" onclick="adjustPopupToppingQty(\'' + tp.maTp + '\', 1)">+</button>';
            html += '          </div>';
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

    // 5. Notes
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 text-secondary">5. GHI CHÚ PHA CHẾ</label>';
    html += '    <textarea class="form-control" id="popup_note" rows="2" placeholder="Ít đá, mang ly đá riêng..."></textarea>';
    html += '  </div>';

    // Bottom Section
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
    const rawOptions = window['sp_opt_' + maSp];

    const choPhepDoiDa = rawOptions ? rawOptions.choPhepDoiDa : true;
    const choPhepDoiDuong = rawOptions ? rawOptions.choPhepDoiDuong : true;

    const checkedSize = document.querySelector('.size-radio:checked');
    const maSize = parseInt(checkedSize.value);
    const tenSize = checkedSize.dataset.name;
    const giaBan = parseInt(checkedSize.dataset.price);

    const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
    const sugar = (choPhepDoiDuong && sugarEl) ? sugarEl.value : 'N/A';

    const iceEl = document.querySelector('input[name="popup_ice"]:checked');
    const ice = (choPhepDoiDa && iceEl) ? iceEl.value : 'N/A';

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
            choPhepDoiDa: choPhepDoiDa,
            choPhepDoiDuong: choPhepDoiDuong,
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

        let iceSugarText = '';
        if (item.choPhepDoiDa || item.choPhepDoiDuong) {
            let parts = [];
            if (item.choPhepDoiDa && item.mucDa !== 'N/A') parts.push('Đá: ' + item.mucDa);
            if (item.choPhepDoiDuong && item.mucDuong !== 'N/A') parts.push('Đường: ' + item.mucDuong);
            iceSugarText = parts.join(' | ') + noteText;
        } else {
            iceSugarText = (item.ghiChuMon !== 'Normal' && item.ghiChuMon !== '') ? '<span class="text-danger fw-semibold">Ghi chú: ' + item.ghiChuMon + '</span>' : '';
        }

        let cardHtml = '<div class="pos-cart-item p-2.5 bg-white border border-secondary border-opacity-10 rounded-3 mb-2 shadow-sm">' +
            '  <div class="d-flex justify-content-between align-items-start">' +
            '    <div class="text-start">' +
            '      <h6 class="fw-bold mb-0 text-dark small" style="font-size:12.5px;">' + item.tenSp +
            '        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 ms-1" style="font-size:9.5px;">' + item.tenSize + '</span>' +
            '      </h6>' +
            '      <div class="text-muted" style="font-size:10.5px; margin-top:2px;">' + iceSugarText + toppingsText + '</div>' +
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
                    cancelButtonText: 'Bỏ qua'
                }).then((result) => {
                    if (result.isConfirmed) {
                        openQuickRegisterModal(sdt);
                    }
                });
            }
        });
}

function openQuickRegisterModal(prefilledPhone = "") {
    Swal.fire({
        title: 'ĐĂNG KÝ HỘI VIÊN CRM NHANH',
        html:
            '<div class="text-start p-1 small">' +
            '  <div class="mb-3">' +
            '    <label class="form-label fw-bold mb-1 text-secondary">Số điện thoại hội viên</label>' +
            '    <input id="reg_sdt" class="form-control form-control-sm" placeholder="Nhập số điện thoại..." value="' + prefilledPhone + '">' +
            '  </div>' +
            '  <div class="mb-3">' +
            '    <label class="form-label fw-bold mb-1 text-secondary">Họ và tên thành viên</label>' +
            '    <input id="reg_ten" class="form-control form-control-sm" placeholder="Nhập tên khách hàng...">' +
            '  </div>' +
            '  <div class="mb-2">' +
            '    <label class="form-label fw-bold mb-1 text-secondary">Địa chỉ Email</label>' +
            '    <input id="reg_email" class="form-control form-control-sm" placeholder="username@gmail.com...">' +
            '  </div>' +
            '</div>',
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Kích hoạt thẻ CRM',
        cancelButtonText: 'Hủy bỏ',
        preConfirm: () => {
            const sdt = document.getElementById('reg_sdt').value.trim();
            const tenKh = document.getElementById('reg_ten').value.trim();
            const email = document.getElementById('reg_email').value.trim();

            if (!sdt || sdt.length < 10) {
                Swal.showValidationMessage('Số điện thoại không đúng chuẩn!');
                return false;
            }
            if (!tenKh) {
                Swal.showValidationMessage('Vui lòng điền tên khách hàng!');
                return false;
            }
            if (!email || !email.includes('@')) {
                Swal.showValidationMessage('Địa chỉ Email không hợp lệ!');
                return false;
            }
            return { tenKh: tenKh, email: email, sdt: sdt };
        }
    }).then((result) => {
        if (result.isConfirmed) {
            Swal.fire({ title: 'Đang xử lý...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });
            fetch(getContextPath() + '/pos/create-customer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams(result.value)
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'SUCCESS') {
                        customerInfo = data;
                        document.getElementById('submit_maKh').value = data.maKh;
                        document.getElementById('customerPhoneSearch').value = data.soDienThoai;
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

    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/[^0-9]/g, '')) || 0;
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
        cancelButtonText: 'Hủy bỏ',
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
            recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/[^0-9]/g, '')));
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

            document.getElementById("submit_maKm").value = appliedVoucher.maKm;
            document.getElementById("submit_tienGiamGia").value = discount.toString();
            document.getElementById("txtAppliedCode").innerText = appliedVoucher.maCode;
            document.getElementById("totalDiscountPrice").innerText = "-" + formatVND(discount);
            document.getElementById("summaryDiscountRow").style.setProperty('display', 'flex', 'important');
        } else {
            appliedVoucher = null;
            document.getElementById("submit_maKm").value = "";
            document.getElementById("submit_tienGiamGia").value = "0";
            document.getElementById("summaryDiscountRow").style.setProperty('display', 'none', 'important');
            showToast('warning', 'Đơn hàng không đạt giá trị tối thiểu của Voucher!');
        }
    }

    let pointsDiscount = appliedPoints * 1000;
    let maxRedeemableBill = rawSum - discount;
    if (pointsDiscount > maxRedeemableBill) {
        pointsDiscount = maxRedeemableBill;
        appliedPoints = Math.ceil(maxRedeemableBill / 1000);
    }

    if (appliedPoints > 0) {
        document.getElementById("submit_diemSuDung").value = appliedPoints.toString();
        document.getElementById("submit_tienTruDiem").value = pointsDiscount.toString();
        document.getElementById("txtUsedPoints").innerText = appliedPoints.toString();
        document.getElementById("totalPointsPrice").innerText = "-" + formatVND(pointsDiscount);
        document.getElementById("summaryPointsRow").style.setProperty('display', 'flex', 'important');
    } else {
        document.getElementById("submit_diemSuDung").value = "0";
        document.getElementById("submit_tienTruDiem").value = "0";
        document.getElementById("summaryPointsRow").style.setProperty('display', 'none', 'important');
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

    calculatePOSCashRefund();
}

function calculatePOSCashRefund() {
    const finalPrice = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;
    const cashInput = document.getElementById('inputCustomerCash');
    let cashGiven = parseInt(cashInput ? cashInput.value : "0") || 0;

    let refund = cashGiven - finalPrice;
    if (refund < 0) refund = 0;

    const refundEl = document.getElementById('txtCashRefund');
    if (refundEl) refundEl.innerText = formatVND(refund);
}

function suggestCashAmount(amount) {
    const finalPrice = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;
    const cashInput = document.getElementById('inputCustomerCash');

    if (cashInput) {
        if (amount === 0) {
            cashInput.value = finalPrice;
        } else {
            cashInput.value = amount;
        }
        calculatePOSCashRefund();
    }
}

function changePaymentMethod(maPt) {
    document.getElementById('submit_maPt').value = maPt;
    const cashSection = document.getElementById('cashCalculatorSection');

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

    document.getElementById("posQrSuccessOverlay").style.setProperty('display', 'none', 'important');
    document.getElementById("posQrExpiredOverlay").style.setProperty('display', 'none', 'important');

    const qrModalEl = document.getElementById('posQrModal');
    if (qrModalEl) {
        const modal = new bootstrap.Modal(qrModalEl);
        modal.show();

        // Start countdown
        let sec = 120;
        const cdText = document.getElementById("posQrCountdownText");
        cdText.innerText = sec;

        clearInterval(posQrCountdownInterval);
        posQrCountdownInterval = setInterval(() => {
            sec--;
            cdText.innerText = sec;
            if (sec <= 0) {
                clearInterval(posQrCountdownInterval);
                cancelQRPayment();
                document.getElementById("posQrExpiredOverlay").style.setProperty('display', 'flex', 'important');
            }
        }, 1000);

        // Start polling check payment
        clearInterval(posQrPollInterval);
        posQrPollInterval = setInterval(() => {
            fetch(getContextPath() + '/pos/bill-detail?id=' + orderId)
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'SUCCESS' && data.trangThaiThanhToan === 1) {
                        clearInterval(posQrPollInterval);
                        clearInterval(posQrCountdownInterval);
                        document.getElementById("posQrSuccessOverlay").style.setProperty('display', 'flex', 'important');

                        setTimeout(() => {
                            const modalInstance = bootstrap.Modal.getInstance(qrModalEl);
                            if (modalInstance) modalInstance.hide();
                            loadAndShowPrintReceipt(orderId);
                        }, 2000);
                    }
                });
        }, 3000);
    }
}

function cancelQRPayment() {
    clearInterval(posQrPollInterval);
    clearInterval(posQrCountdownInterval);
    isPosQrActive = false;
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
                document.getElementById("billTenNv").innerText = data.tenNhanVien ? data.tenNhanVien : 'Thu ngân quầy';

                document.getElementById("billRawPrice").innerText = parseInt(data.tongTienHang).toLocaleString('vi-VN') + ' đ';
                document.getElementById("billDiscount").innerText = '-' + parseInt(data.tienGiamGia).toLocaleString('vi-VN') + ' đ';

                if (data.tienGiamGia > 0) {
                    document.getElementById("billDiscountRow").style.display = 'flex';
                } else {
                    document.getElementById("billDiscountRow").style.display = 'none';
                }

                if (data.diemSuDung > 0) {
                    document.getElementById("billPointsRow").style.display = 'flex';
                    document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                } else {
                    document.getElementById("billPointsRow").style.display = 'none';
                }

                let billBeforeTax = data.tongTienHang - data.tienGiamGia - data.tienTruDiem;
                if (billBeforeTax < 0) billBeforeTax = 0;
                let vatPrice = Math.round(billBeforeTax * 0.08);

                document.getElementById("billVatPrice").innerText = vatPrice.toLocaleString('vi-VN') + ' đ';
                document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                // Refund display
                let cashGiven = parseInt(localStorage.getItem('last_cash_given_' + orderId)) || 0;
                if (cashGiven > 0) {
                    document.getElementById("billCashGivenRow").style.display = 'flex';
                    document.getElementById("billCashGiven").innerText = cashGiven.toLocaleString('vi-VN') + ' đ';

                    let refund = cashGiven - parseInt(data.tongPhaiTra);
                    if (refund < 0) refund = 0;
                    document.getElementById("billCashRefundRow").style.display = 'flex';
                    document.getElementById("billCashRefund").innerText = refund.toLocaleString('vi-VN') + ' đ';
                } else {
                    document.getElementById("billCashGivenRow").style.display = 'none';
                    document.getElementById("billCashRefundRow").style.display = 'none';
                }

                // Clear items list
                container.innerHTML = '';
                data.items.forEach(item => {
                    let html = '<div class="mb-2 border-bottom pb-1">';
                    html += '  <div class="d-flex justify-content-between">';
                    html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                    html += '    <span>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</span>';
                    html += '  </div>';

                    let printIceSugar = '';
                    let parts = [];
                    if (item.mucDa && item.mucDa !== 'N/A') parts.push('Đá: ' + item.mucDa);
                    if (item.mucDuong && item.mucDuong !== 'N/A') parts.push('Đường: ' + item.mucDuong);

                    if (parts.length > 0) {
                        printIceSugar = parts.join(' | ') + (item.ghiChuMon && item.ghiChuMon !== 'Normal' ? ' | Lưu ý: ' + item.ghiChuMon : '');
                    } else {
                        printIceSugar = (item.ghiChuMon && item.ghiChuMon !== 'Normal') ? 'Lưu ý: ' + item.ghiChuMon : '';
                    }

                    if (printIceSugar !== '') {
                        html += '  <div class="small text-muted">' + printIceSugar + '</div>';
                    }

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

                const receiptModalEl = document.getElementById('receiptDetailModal');
                if (receiptModalEl) {
                    const modal = new bootstrap.Modal(receiptModalEl);
                    modal.show();
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

    Swal.fire({ title: 'Đang lưu...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });
    fetch(getContextPath() + '/pos/update-profile', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ hoTen: hoTen, soDienThoai: sdt, email: email })
    })
        .then(res => res.json())
        .then(data => {
            Swal.close();
            if (data.status === 'SUCCESS') {
                Swal.fire({ icon: 'success', title: 'Thành công', text: 'Cập nhật thông tin cá nhân thành công!', confirmButtonColor: '#10b981' }).then(() => { location.reload(); });
            } else {
                Swal.fire({ icon: 'error', title: 'Thất bại', text: data.message });
            }
        });
}

function submitPosPassword() {
    const old = document.getElementById('pass_old').value;
    const passNew = document.getElementById('pass_new').value;
    const confirm = document.getElementById('pass_confirm').value;

    if (!old || !passNew || !confirm) {
        Swal.fire({ icon: 'warning', title: 'Khuyết thông tin', text: 'Vui lòng nhập đầy đủ mật khẩu!', confirmButtonColor: '#10b981' });
        return;
    }
    if (passNew.length < 8) {
        Swal.fire({ icon: 'warning', title: 'Mật khẩu yếu', text: 'Mật khẩu mới bắt buộc có tối thiểu 8 ký tự!', confirmButtonColor: '#10b981' });
        return;
    }
    if (passNew !== confirm) {
        Swal.fire({ icon: 'warning', title: 'Mật khẩu lệch', text: 'Xác nhận mật khẩu mới không trùng khớp!', confirmButtonColor: '#10b981' });
        return;
    }

    Swal.fire({ title: 'Đang xác thực...', allowOutsideClick: false, didOpen: () => { Swal.showLoading(); } });
    fetch(getContextPath() + '/pos/change-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ oldPassword: old, newPassword: passNew })
    })
        .then(res => res.json())
        .then(data => {
            Swal.close();
            if (data.status === 'SUCCESS') {
                Swal.fire({ icon: 'success', title: 'Thành công', text: 'Thay đổi mật khẩu đăng nhập thành công!', confirmButtonColor: '#10b981' }).then(() => { location.reload(); });
            } else {
                Swal.fire({ icon: 'error', title: 'Thất bại', text: data.message });
            }
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
            Swal.fire({ icon: 'warning', title: 'Thiếu tiền thu', text: 'Tiền mặt khách đưa chưa đủ để chốt hóa đơn thanh toán này!', confirmButtonColor: '#10b981' });
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

    const phaiTraVal = document.getElementById('submit_tongPhaiTra').value;
    const inputCash = document.getElementById('inputCustomerCash');
    const cashVal = inputCash ? parseInt(inputCash.value) : 0;

    // Save customer cash to local storage for print receipt tracking
    localStorage.setItem('last_cash_given_pending', cashVal.toString());

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
            // Save cash given mapped to orderId after redirection
            const form = document.getElementById('posOrderForm');
            if (form) {
                // Intercept submits to store the cash amount associated with next maDh
                form.submit();
            }
        }
    });
}

document.addEventListener("DOMContentLoaded", function() {
    const urlParams = new URLSearchParams(window.location.search);
    const msg = urlParams.get('msg');
    const orderId = urlParams.get('orderId');
    const maPt = urlParams.get('maPt');
    const payable = urlParams.get('payable');

    if (msg === 'createsuccess' && orderId) {
        // Map cash given of the last order
        const pendingCash = localStorage.getItem('last_cash_given_pending');
        if (pendingCash) {
            localStorage.setItem('last_cash_given_' + orderId, pendingCash);
            localStorage.removeItem('last_cash_given_pending');
        }

        if (maPt === '2') {
            showPosQrCodeModal(orderId, payable);
        } else {
            loadAndShowPrintReceipt(orderId);
        }
    }
});
