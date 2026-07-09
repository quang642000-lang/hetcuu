let posCart = [];
let customerInfo = null;

function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
}

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
            <label class="selection-label" for="sz_${s.maSize}">${s.tenSize} (+${formatVND(s.giaBan)})</label>
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

    html += `<div class="mb-3"><label class="fw-semibold small mb-2 d-block">THÊM TOPPING</label>`;
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
            <textarea class="form-control-teapos" id="popup_note" rows="2" placeholder="Ít ngọt, pha nhanh..."></textarea>
        </div>
        <div class="d-flex justify-content-between align-items-center mt-4">
            <span class="fw-bold fs-5 text-success" id="popup_total">0 đ</span>
            <button class="btn-teapos btn-primary-teapos" onclick="addCustomizedToCart()">
                <i class="bi bi-cart-plus me-1"></i> Thêm vào giỏ
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
    const tenSize = checkedSize.nextElementSibling.innerText.split(' ');
    const giaBan = parseInt(checkedSize.dataset.price);
    const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
    const mucDuong = sugarEl ? sugarEl.value : "100%";
    const iceEl = document.querySelector('input[name="popup_ice"]:checked');
    const mucDa = iceEl ? iceEl.value : "100%";
    const ghiChuMon = document.getElementById('popup_note').value;

    let toppingsList = [];
    document.querySelectorAll('.topping-chk:checked').forEach(tp => {
        // CHỈNH SỬA SỬA LỖI: Sửa hàm .add() sai cú pháp thành .push() đúng chuẩn JS
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
    container.innerHTML = '';
    let tongTienHang = 0;
    posCart.forEach((item, idx) => {
        let toppingTotal = item.toppings.reduce((sum, t) => sum + (t.giaTp * t.soLuongTp), 0);
        let rowPrice = (item.giaBan + toppingTotal) * item.soLuong;
        tongTienHang += rowPrice;
        container.innerHTML += `
            <div class="pos-cart-item">
                <div class="cart-item-details">
                    <span class="cart-item-title">${item.tenSp} (${item.tenSize})</span>
                    <div class="cart-item-options">
                        Đá: ${item.mucDa} | Đường: ${item.mucDuong}
                        ${item.toppings.map(t => `<br>+ ${t.tenTp}`).join('')}
                    </div>
                    <div class="cart-item-price">${formatVND(rowPrice)}</div>
                </div>
                <div class="d-flex flex-column align-items-end gap-2">
                    <button class="btn btn-sm btn-outline-danger" onclick="removeCartItem(${idx})">
                        <i class="bi bi-trash"></i>
                    </button>
                    <div class="input-group input-group-sm" style="width: 80px;">
                        <button class="btn btn-outline-secondary" onclick="changeQty(${idx}, -1)">-</button>
                        <span class="form-control text-center bg-white">${item.soLuong}</span>
                        <button class="btn btn-outline-secondary" onclick="changeQty(${idx}, 1)">+</button>
                    </div>
                </div>
            </div>
        `;
    });
    document.getElementById('totalRawPrice').innerText = formatVND(tongTienHang);
    let vatPrice = Math.round(tongTienHang * 0.08);
    document.getElementById('totalTaxPrice').innerText = formatVND(vatPrice);
    document.getElementById('totalPayablePrice').innerText = formatVND(tongTienHang + vatPrice);
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
    const sdt = document.getElementById('customerPhoneSearch').value;
    if (!sdt) return;

    // Ghép Context Path tự động tránh lỗi 404
    fetch(getContextPath() + '/pos/search-customer?sdt=' + sdt)
        .then(res => res.json())
        .then(data => {
            if (data.status === 'SUCCESS') {
                customerInfo = data;
                document.getElementById('customerNameResult').innerText = data.tenKh;
                document.getElementById('customerPoints').innerText = 'Hạng ' + (data.maHang === 1 ? 'Đồng' : data.maHang === 2 ? 'Bạc' : data.maHang === 3 ? 'Vàng' : 'Kim cương') + ' | ' + data.diemTichLuy + ' Điểm';
                showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
            } else {
                customerInfo = null;
                document.getElementById('customerNameResult').innerText = "Khách vãng lai";
                document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                showToast('warning', 'Không tìm thấy số điện thoại khách hàng!');
            }
        });
}