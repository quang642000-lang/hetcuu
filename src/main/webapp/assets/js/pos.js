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
    appliedVoucher = null;
    appliedPoints = 0;
    const phoneInput = document.getElementById("customerPhoneSearch");

    if (phoneInput) phoneInput.value = "";
    const nameResult = document.getElementById("customerNameResult");
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
    if (typeof showToast === 'function') {
        showToast('info', 'Đã hủy đơn hàng hiện tại và làm sạch giỏ hàng POS!');
    }
}

function toggleToppingQty(checkbox, maTp) {
    const container = document.getElementById('tp_qty_container_' + maTp);
    const qtyInput = document.getElementById('tp_qty_' + maTp);
    if (checkbox.checked) {
        if (container) container.style.setProperty('display', 'flex', 'important');
        if (qtyInput) {
            qtyInput.disabled = false;
            qtyInput.value = "1";
        }
    } else {
        if (container) container.style.setProperty('display', 'none', 'important');
        if (qtyInput) {
            qtyInput.disabled = true;
            qtyInput.value = "0";
        }
    }
    recalculatePopupPrice();
}

function changePopupTpQty(maTp, delta) {
    const input = document.getElementById('tp_qty_' + maTp);
    if (!input) return;
    let val = parseInt(input.value) + delta;
    if (val < 1) val = 1;
    input.value = val;
    recalculatePopupPrice();
}

function openCustomizePopup(maSp, tenSp, encodedOptions) {
    const rawOptions = JSON.parse(decodeURIComponent(encodedOptions));

    let html = '';
    html += '<div id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '" class="text-start p-2">';

    // 1. CHỌN SIZE
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 text-secondary">1. CHỌN KÍCH CỠ LY NƯỚC (SIZE)</label>';
    html += '    <div class="row g-2">';

    let isFirstSize = true;
    rawOptions.sizesList.forEach(sz => {
        let sizeName = sz.maSize === 1 ? 'S' : (sz.maSize === 2 ? 'M' : 'L');
        let checked = isFirstSize ? 'checked' : '';
        html += '      <div class="col-4">';
        html += '        <input type="radio" class="btn-check size-radio" name="popup_size" id="size_' + sz.maSize + '" value="' + sz.maSize + '" data-price="' + sz.giaBan + '" data-name="' + sizeName + '" ' + checked + ' onchange="recalculatePopupPrice()">';
        html += '        <label class="btn btn-outline-success w-100 py-2 fw-bold text-center small" for="size_' + sz.maSize + '">';
        html += '          Size ' + sizeName + '<br><small class="text-muted fw-normal" style="font-size:10px;">+' + formatVND(sz.giaBan) + '</small>';
        html += '        </label>';
        html += '      </div>';
        isFirstSize = false;
    });

    html += '    </div>';
    html += '  </div>';

    // 2. MỨC ĐÁ
    if (rawOptions.choPhepDoiDa) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">2. MỨC ĐỘ ĐÁ LẠNH</label>';
        html += '    <div class="d-flex justify-content-between gap-1.5">';
        ['100% Đá', '70% Đá', '50% Đá', '0% Đá'].forEach((da, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_ice" id="ice_' + i + '" value="' + da + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2.5 py-1.5 text-center flex-fill" for="ice_' + i + '">' + da + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 3. MỨC ĐƯỜNG
    if (rawOptions.choPhepDoiDuong) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 text-secondary">3. MỨC ĐỘ ĐƯỜNG NGỌT</label>';
        html += '    <div class="d-flex justify-content-between gap-1.5">';
        ['100% Đường', '70% Đường', '50% Đường', '0% Đường'].forEach((duong, i) => {
            let checked = i === 0 ? 'checked' : '';
            html += '      <input type="radio" class="btn-check" name="popup_sugar" id="sugar_' + i + '" value="' + duong + '" ' + checked + '>';
            html += '      <label class="btn btn-sm btn-outline-secondary px-2.5 py-1.5 text-center flex-fill" for="sugar_' + i + '">' + duong + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }

    // 4. TOPPINGS (Chỉ render nếu sản phẩm mẹ cho phép Topping)
    if (rawOptions.choPhepTopping && rawOptions.allToppings && rawOptions.allToppings.length > 0) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">4. THÊM TOPPING DAI GIÒN SẦN SẬT</label>';
        html += '    <div style="max-height: 180px; overflow-y: auto;" class="custom-scrollbar pr-1">';

        rawOptions.allToppings.forEach(tp => {
            let imgHtml = tp.hinhAnh
                ? '<img src="' + tp.hinhAnh + '" alt="' + tp.tenTp + '" class="rounded me-2" style="width: 32px; height: 32px; object-fit: cover; border: 1px solid #ddd;">'
                : '<div class="bg-light rounded me-2 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; border: 1px solid #ddd;"><i class="bi bi-egg-fried text-muted"></i></div>';

            html += '      <div class="form-check d-flex justify-content-between align-items-center mb-1 bg-light p-1.5 rounded border shadow-sm" style="padding-left: 30px;">';
            html += '        <div class="d-flex align-items-center">';
            html += '          <input class="form-check-input topping-check me-2" type="checkbox" id="tp_' + tp.maTp + '" value="' + tp.maTp + '" data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" onchange="toggleToppingQty(this, \'' + tp.maTp + '\')">';
            html += imgHtml;
            html += '          <label class="form-check-label small fw-semibold text-dark" for="tp_' + tp.maTp + '">' + tp.tenTp + '<br><span class="text-success" style="font-size:10px;">+' + formatVND(tp.giaBan) + '</span></label>';
            html += '        </div>';
            html += '        <div class="input-group input-group-sm" id="tp_qty_container_' + tp.maTp + '" style="width: 80px; display: none !important;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-1.5 py-0" onclick="changePopupTpQty(\'' + tp.maTp + '\', -1)">-</button>';
            html += '          <input type="text" class="form-control text-center bg-white border-secondary border-opacity-25 px-0 fw-bold" id="tp_qty_' + tp.maTp + '" value="0" readonly style="font-size: 11px; height: 24px;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-1.5 py-0" onclick="changePopupTpQty(\'' + tp.maTp + '\', 1)">+</button>';
            html += '        </div>';
            html += '      </div>';
        });

        html += '    </div>';
        html += '  </div>';
    } else if (rawOptions.choPhepTopping === false) {
        html += '  <div class="mb-3 p-3 bg-light rounded border border-dashed text-center">';
        html += '    <span class="text-muted small fw-semibold"><i class="bi bi-info-circle text-warning"></i> Sản phẩm này không áp dụng ăn kèm Topping!</span>';
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
            showCloseButton: true,
            width: '500px',
            didOpen: () => {
                recalculatePopupPrice();
            }
        });
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

    // Check trùng khớp giỏ hàng POS
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
    if (typeof showToast === 'function') {
        showToast('success', 'Đã thêm cốc ' + tenSp + ' vào giỏ hàng POS!');
    }
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
    if (posCart.length === 0) {
        container.innerHTML =
            '<div class="text-center text-muted py-5 my-5">' +
            '  <i class="bi bi-cart-x fs-1 text-secondary opacity-30"></i>' +
            '  <p class="small mt-2 fw-semibold">Quầy POS chưa có sản phẩm nào.<br>Vui lòng chạm chọn món uống ở lưới bên.</p>' +
            '</div>';
        recalculatePOSBill(0);
        return;
    }

    container.innerHTML = '';
    let tongTienHang = 0;

    posCart.forEach((item, idx) => {
        let toppingSum = 0;
        let toppingsText = '';
        if (item.toppings && item.toppings.length > 0) {
            toppingsText += ' | Topping: ';
            item.toppings.forEach((t, tIdx) => {
                toppingSum += (t.giaTp * t.soLuongTp);
                toppingsText += t.tenTopping + ' (x' + t.soLuongTp + ')' + (tIdx < item.toppings.length - 1 ? ', ' : '');
            });
        }

        let lineTotal = (item.giaBan + toppingSum) * item.soLuong;
        tongTienHang += lineTotal;

        let noteText = item.ghiChuMon !== 'Normal' ? ' | Ghi chú: ' + item.ghiChuMon : '';

        let cardHtml =
            '<div class="pos-cart-item text-start animate__animated animate__fadeIn">' +
            '  <div class="pos-bill-item-details d-flex justify-content-between align-items-start">' +
            '    <div>' +
            '      <div class="pos-bill-item-title fw-bold text-dark">' + item.tenSp + ' (Size ' + item.tenSize + ')</div>' +
            '      <div class="pos-bill-item-options text-muted small mt-1">' +
            '        Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + noteText + toppingsText +
            '      </div>' +
            '    </div>' +
            '    <button type="button" class="btn btn-link text-danger p-0 border-0 ms-2" onclick="removeCartItem(' + idx + ')"><i class="bi bi-trash3-fill"></i></button>' +
            '  </div>' +
            '  <div class="d-flex justify-content-between align-items-center mt-2.5">' +
            '    <div class="pos-bill-item-price fw-bold text-success font-monospace">' + formatVND(lineTotal) + '</div>' +
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
                if (typeof showToast === 'function') {
                    showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
                }
            } else {
                customerInfo = null;
                document.getElementById('submit_maKh').value = "";
                document.getElementById('customerNameResult').innerText = "Khách lẻ vãng lai";
                document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                document.getElementById("crmLoyaltyArea").style.setProperty('display', 'none', 'important');
                document.getElementById("posAddCustomerArea").style.setProperty('display', 'block', 'important');

                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        title: 'Hội viên chưa đăng ký',
                        text: 'Số điện thoại này chưa được liên kết với bất kỳ tài khoản CRM nào. Tạo nhanh thành viên mới?',
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
            }
        })
        .catch(err => {
            console.error("Lỗi AJAX searchCustomer:", err);
            if (typeof showToast === 'function') {
                showToast('error', 'Lỗi đối soát thành viên!');
            }
        });
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
    html += '    <input type="text" class="form-control" id="reg_tenKh" placeholder="Nhập tên tiếng Việt..." required>';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Địa chỉ Email</label>';
    html += '    <input type="email" class="form-control" id="reg_email" placeholder="example@teapos.vn" required>';
    html += '  </div>';
    html += '</div>';

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'ĐĂNG KÝ NHANH THÀNH VIÊN CRM',
            html: html,
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Tạo tài khoản',
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
                Swal.fire({
                    title: 'Đang xử lý...',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                const url = getContextPath() + '/pos/create-customer';
                const params = new URLSearchParams();
                params.append('tenKh', result.value.tenKh);
                params.append('soDienThoai', result.value.sdt);
                params.append('email', result.value.email);

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
                            document.getElementById("crmLoyaltyArea").style.setProperty('display', 'block', 'important');
                            document.getElementById("posAddCustomerArea").style.setProperty('display', 'none', 'important');

                            Swal.fire({
                                icon: 'success',
                                title: 'Thành công',
                                text: 'Đã khởi tạo tài khoản CRM VIP cho thành viên ' + data.tenKh + '!',
                                confirmButtonColor: '#10b981'
                            });
                            resetVoucherAndPoints();
                            renderPosCart();
                        } else {
                            Swal.fire({ icon: 'error', title: 'Đăng ký thất bại', text: data.message });
                        }
                    })
                    .catch(err => {
                        Swal.close();
                        console.error('Lỗi đăng ký:', err);
                        if (typeof showToast === 'function') {
                            showToast('error', 'Lỗi kết nối máy chủ!');
                        }
                    });
            }
        });
    }
}

function applyManualVoucherCode() {
    const code = document.getElementById("manualVoucherInput").value.trim();
    if (!code) {
        if (typeof showToast === 'function') showToast('warning', 'Vui lòng điền mã Voucher cần áp dụng!');
        return;
    }
    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
    if (totalRaw === 0) {
        if (typeof showToast === 'function') showToast('warning', 'Vui lòng chọn món nước uống trước khi áp Voucher!');
        return;
    }
    const maKh = document.getElementById("submit_maKh").value;

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Đang áp mã Voucher...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });
    }

    const url = getContextPath() + '/pos/apply-voucher';
    const params = new URLSearchParams();
    params.append('code', code);
    params.append('maKh', maKh);
    params.append('tongTienHang', totalRaw.toString());

    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            if (typeof Swal !== 'undefined') Swal.close();
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
                if (typeof showToast === 'function') showToast('success', 'Áp dụng mã Voucher ' + code + ' thành công!');
                recalculatePOSBill(totalRaw);
            } else {
                if (typeof Swal !== 'undefined') Swal.fire({ icon: 'error', title: 'Lỗi áp mã', text: data.message });
            }
        })
        .catch(err => {
            if (typeof Swal !== 'undefined') Swal.close();
            console.error('Lỗi AJAX:', err);
            if (typeof showToast === 'function') showToast('error', 'Lỗi kết nối quầy POS với máy chủ!');
        });
}

function showVoucherSelectionModal() {
    if (!customerInfo) {
        if (typeof showToast === 'function') showToast('warning', 'Hãy xác thực thành viên CRM trước!');
        return;
    }
    if (posCart.length === 0) {
        if (typeof showToast === 'function') showToast('warning', 'Vui lòng chọn cốc nước trước khi áp mã!');
        return;
    }
    if (!customerInfo.vouchers || customerInfo.vouchers.length === 0) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'info',
                title: 'Hộp mã trống',
                text: 'Thành viên hiện tại chưa có Voucher VIP khả dụng!',
                confirmButtonColor: '#10b981'
            });
        }
        return;
    }

    let selectHtml = '<select id="posVoucherSelector" class="form-select mb-2"><option value="">-- Bỏ áp dụng Voucher --</option>';
    customerInfo.vouchers.forEach(v => {
        let txtType = v.loaiGiam === 1 ? formatVND(v.giaTriGiam) : v.giaTriGiam + "%";
        selectHtml += '<option value="' + v.maCode + '">' + v.maCode + ' (Giảm ' + txtType + ' | Đơn từ ' + formatVND(v.donToiThieu) + ')</option>';
    });
    selectHtml += '</select>';

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'HỘP THƯ VOUCHER THÀNH VIÊN',
            html: selectHtml,
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý áp dụng',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                const code = document.getElementById("posVoucherSelector").value;
                if (code) {
                    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
                    Swal.fire({
                        title: 'Đang tải...',
                        allowOutsideClick: false,
                        didOpen: () => { Swal.showLoading(); }
                    });

                    const url = getContextPath() + '/pos/apply-voucher';
                    const params = new URLSearchParams();
                    params.append('code', code);
                    params.append('maKh', customerInfo.maKh);
                    params.append('tongTienHang', totalRaw.toString());

                    fetch(url, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: params
                    })
                        .then(res => res.json())
                        .then(data => {
                            Swal.close();
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
                                if (typeof showToast === 'function') showToast('success', 'Đã lưu Voucher thành viên ' + code + '!');
                                recalculatePOSBill(totalRaw);
                            } else {
                                Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message });
                            }
                        });
                } else {
                    appliedVoucher = null;
                    if (typeof showToast === 'function') showToast('info', 'Đã hủy áp dụng Voucher.');
                    recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
                }
            }
        });
    }
}

function applyPointsDiscount() {
    if (!customerInfo) {
        if (typeof showToast === 'function') showToast('warning', 'Yêu cầu xác thực thành viên CRM trước!');
        return;
    }
    if (customerInfo.diemTichLuy <= 0) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'warning',
                title: 'Ví điểm rỗng',
                text: 'Hội viên hiện chưa tích lũy đủ điểm thưởng để quy đổi!',
                confirmButtonColor: '#10b981'
            });
        }
        return;
    }

    if (typeof Swal !== 'undefined') {
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
                if (typeof showToast === 'function') showToast('success', 'Đồng ý khấu trừ ' + appliedPoints + ' điểm tích lũy của khách.');
                recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
            }
        });
    }
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
            if (typeof showToast === 'function') showToast('warning', 'Hóa đơn chưa đạt giá trị tối thiểu ' + formatVND(appliedVoucher.donToiThieu) + ' để giữ Voucher!');
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

function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

function openPOSSettingsModal() {
    if (typeof bootstrap !== 'undefined') {
        const modal = new bootstrap.Modal(document.getElementById('posSettingsModal'));
        modal.show();
    }
}

function submitPOSInfoForm(event) {
    event.preventDefault();
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Đang lưu cài đặt...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });
    }
    const hoTen = document.getElementById("pos_hoTen").value.trim();
    const sdt = document.getElementById("pos_sdt").value.trim();
    const email = document.getElementById("pos_email").value.trim();

    const params = new URLSearchParams();
    params.append("hoTen", hoTen);
    params.append("soDienThoai", sdt);
    params.append("email", email);

    fetch(getContextPath() + "/pos/update-profile", {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            if (typeof Swal !== 'undefined') Swal.close();
            if (data.status === 'SUCCESS') {
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'success',
                        title: 'Lưu thành công',
                        text: 'Hồ sơ nhân sự của bạn đã được cập nhật rộng khắp!',
                        confirmButtonColor: '#10b981'
                    }).then(() => {
                        location.reload();
                    });
                }
            } else {
                if (typeof Swal !== 'undefined') Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message });
            }
        })
        .catch(err => {
            if (typeof Swal !== 'undefined') Swal.close();
            console.error('Lỗi lưu cài đặt:', err);
            if (typeof showToast === 'function') showToast('error', 'Lỗi kết nối máy chủ!');
        });
}

function submitPOSPassForm(event) {
    event.preventDefault();
    const oldPass = document.getElementById("pos_oldPass").value;
    const newPass = document.getElementById("pos_newPass").value;
    const confirmPass = document.getElementById("pos_confirmPass").value;

    if (newPass !== confirmPass) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({ icon: 'warning', title: 'Không trùng khớp', text: 'Xác nhận mật khẩu mới không đúng!', confirmButtonColor: '#ef4444' });
        }
        return;
    }

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Đang đổi mật khẩu...',
            allowOutsideClick: false,
            didOpen: () => { Swal.showLoading(); }
        });
    }

    const params = new URLSearchParams();
    params.append("oldPassword", oldPass);
    params.append("newPassword", newPass);

    fetch(getContextPath() + "/pos/change-password", {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            if (typeof Swal !== 'undefined') Swal.close();
            if (data.status === 'SUCCESS') {
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'success',
                        title: 'Đổi mật khẩu thành công',
                        text: 'Mật khẩu đăng nhập mới của bạn đã được áp dụng!',
                        confirmButtonColor: '#10b981'
                    }).then(() => {
                        location.reload();
                    });
                }
            } else {
                if (typeof Swal !== 'undefined') Swal.fire({ icon: 'error', title: 'Thất bại', text: data.message });
            }
        })
        .catch(err => {
            if (typeof Swal !== 'undefined') Swal.close();
            console.error('Lỗi đổi mật khẩu:', err);
            if (typeof showToast === 'function') showToast('error', 'Lỗi kết nối thay đổi mật khẩu!');
        });
}

function calculateChangeRefund() {
    const totalPayablePriceEl = document.getElementById('totalPayablePrice');
    const inputCustomerCashEl = document.getElementById('inputCustomerCash');
    const txtCashRefundEl = document.getElementById('txtCashRefund');
    if (!totalPayablePriceEl || !inputCustomerCashEl || !txtCashRefundEl) return;

    const totalPayable = parseInt(totalPayablePriceEl.innerText.replace(/\D/g, '')) || 0;
    const customerCash = parseInt(inputCustomerCashEl.value) || 0;
    const refund = customerCash - totalPayable;

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
        const totalPayablePriceEl = document.getElementById('totalPayablePrice');
        const totalPayable = parseInt(totalPayablePriceEl.innerText.replace(/\D/g, '')) || 0;
        inputCustomerCashEl.value = totalPayable.toString();
    } else {
        inputCustomerCashEl.value = amount.toString();
    }
    calculateChangeRefund();
}

function submitPOSOrderTransaction() {
    if (posCart.length === 0) {
        if (typeof showToast === 'function') showToast('warning', 'Giỏ hàng POS trống, không thể in hóa đơn!');
        return;
    }

    const maPt = parseInt(document.getElementById('submit_maPt').value) || 1;
    const totalPayable = parseInt(document.getElementById('submit_tongPhaiTra').value) || 0;

    if (maPt === 1) { // Cash method validation
        const inputCustomerCashEl = document.getElementById('inputCustomerCash');
        const customerCash = parseInt(inputCustomerCashEl.value) || 0;

        if (!inputCustomerCashEl.value.trim()) {
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu thông tin!',
                    text: 'Hãy nhập chính xác số tiền mặt khách đưa để hoàn tất giao dịch tại quầy!',
                    confirmButtonColor: '#10b981'
                });
            }
            inputCustomerCashEl.focus();
            return;
        }
        if (customerCash < totalPayable) {
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'error',
                    title: 'Không đủ tiền mặt!',
                    text: 'Số tiền khách đưa không đủ để thực hiện thanh toán hóa đơn này!',
                    confirmButtonColor: '#ef4444'
                });
            }
            return;
        }
    }

    // Build cart items dynamically into hidden inputs
    const container = document.getElementById('posFormItemsContainer');
    if (container) {
        container.innerHTML = '';
        posCart.forEach(item => {
            container.insertAdjacentHTML('beforeend', '<input type="hidden" name="item_maSp[]" value="' + item.maSp + '">');
            container.insertAdjacentHTML('beforeend', '<input type="hidden" name="item_maSize[]" value="' + item.maSize + '">');
            container.insertAdjacentHTML('beforeend', '<input type="hidden" name="item_soLuong[]" value="' + item.soLuong + '">');

            let toppingKeys = item.toppings.map(t => t.maTp + "_" + t.soLuongTp + "_" + t.giaTp).join("|");
            container.insertAdjacentHTML('beforeend', '<input type="hidden" name="item_toppingKeys[]" value="' + toppingKeys + '">');
        });
    }

    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
    document.getElementById('submit_tongTienHang').value = totalRaw.toString();
    document.getElementById('submit_tongPhaiTra').value = totalPayable.toString();

    if (customerInfo) {
        document.getElementById('submit_maKh').value = customerInfo.maKh.toString();
    }

    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Chốt giao dịch quầy POS',
            text: maPt === 2 ? 'Xác nhận tạo hóa đơn và xuất mã QR thanh toán?' : 'Tiến hành in hóa đơn bán lẻ và đồng bộ ví điểm CRM cho khách hàng?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#10b981',
            cancelButtonColor: '#64748b',
            confirmButtonText: 'Đồng ý chốt đơn',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                document.getElementById('posOrderForm').submit();
            }
        });
    } else {
        document.getElementById('posOrderForm').submit();
    }
}

function showPosQrCodeModal(orderId, payable) {
    currentPosQrOrderId = orderId;
    isPosQrActive = true;

    // Format amount
    document.getElementById("posQrAmount").innerText = formatVND(parseInt(payable));
    document.getElementById("posQrCodeDisplay").innerText = orderId;

    // VietQR integration: TPBank, compact design, amount, description = orderId
    document.getElementById("posQrImage").src = `https://img.vietqr.io/image/TPB-0346406405-compact2.png?amount=${payable}&addInfo=${orderId}`;

    // Hide overlays
    document.getElementById("posQrSuccessOverlay").style.setProperty("display", "none", "important");
    document.getElementById("posQrExpiredOverlay").style.setProperty("display", "none", "important");
    document.getElementById("posQrLoadingStatus").style.setProperty("display", "flex", "important");

    // Show Modal
    const qrModal = new bootstrap.Modal(document.getElementById("posQrModal"));
    qrModal.show();

    // Countdown Timer (120 seconds)
    let timeLeft = 120;
    const countdownEl = document.getElementById("posQrCountdownText");
    if (countdownEl) countdownEl.innerText = timeLeft;

    if (posQrCountdownInterval) clearInterval(posQrCountdownInterval);
    posQrCountdownInterval = setInterval(() => {
        timeLeft--;
        if (countdownEl) countdownEl.innerText = timeLeft;
        if (timeLeft <= 0) {
            clearInterval(posQrCountdownInterval);
            document.getElementById("posQrExpiredOverlay").style.setProperty("display", "flex", "important");
            document.getElementById("posQrLoadingStatus").innerHTML = '<i class="bi bi-exclamation-circle text-danger me-1"></i><span class="text-danger small">Hết hạn thanh toán</span>';
        }
    }, 1000);

    // Polling check-payment API
    if (posQrPollInterval) clearInterval(posQrPollInterval);
    posQrPollInterval = setInterval(() => {
        if (!isPosQrActive) {
            clearInterval(posQrPollInterval);
            return;
        }
        fetch(getContextPath() + "/api/check-payment?id=" + orderId)
            .then(res => res.json())
            .then(data => {
                if (data.status === "SUCCESS" && isPosQrActive) {
                    isPosQrActive = false;
                    clearInterval(posQrPollInterval);
                    clearInterval(posQrCountdownInterval);

                    // Show success overlay
                    document.getElementById("posQrSuccessOverlay").style.setProperty("display", "flex", "important");
                    document.getElementById("posQrLoadingStatus").style.setProperty("display", "none", "important");

                    if (typeof showToast === "function") {
                        showToast("success", "Khách đã chuyển khoản thành công!");
                    }

                    // Close QR Modal and open Print Modal
                    setTimeout(() => {
                        const qrModalEl = document.getElementById("posQrModal");
                        const qrModalInstance = bootstrap.Modal.getInstance(qrModalEl);
                        if (qrModalInstance) qrModalInstance.hide();

                        // Show Print Modal
                        loadAndShowPrintReceipt(orderId);
                    }, 1500);
                }
            })
            .catch(err => console.error("Lỗi polling POS payment:", err));
    }, 3000);
}

function cancelQRPayment() {
    isPosQrActive = false;
    clearInterval(posQrPollInterval);
    clearInterval(posQrCountdownInterval);

    const qrModalEl = document.getElementById("posQrModal");
    const qrModalInstance = bootstrap.Modal.getInstance(qrModalEl);
    if (qrModalInstance) qrModalInstance.hide();

    if (typeof showToast === "function") {
        showToast("info", "Đã hủy luồng quét mã QR.");
    }
}

function forceSubmitCheckout() {
    isPosQrActive = false;
    clearInterval(posQrPollInterval);
    clearInterval(posQrCountdownInterval);

    const qrModalEl = document.getElementById("posQrModal");
    const qrModalInstance = bootstrap.Modal.getInstance(qrModalEl);
    if (qrModalInstance) qrModalInstance.hide();

    // Bypass and show print modal directly
    loadAndShowPrintReceipt(currentPosQrOrderId);
}

function loadAndShowPrintReceipt(orderId) {
    document.getElementById("billItemsContainer").innerHTML =
        '<div class="text-center py-4">' +
        '  <div class="spinner-border text-success" role="status"></div>' +
        '  <p class="small text-muted mt-2">Đang nạp thông tin hóa đơn...</p>' +
        '</div>';

    fetch(getContextPath() + '/admin/hoadon?action=detailJson&id=' + orderId)
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

                let container = document.getElementById("billItemsContainer");
                container.innerHTML = '';

                data.items.forEach(item => {
                    let html = '<div class="mb-2 border-bottom pb-1">';
                    html += '  <div class="d-flex justify-content-between">';
                    html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                    html += '    <span class="fw-bold font-monospace">' + formatVND(item.giaChot) + ' x ' + item.soLuong + '</span>';
                    html += '  </div>';

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
                if (typeof showToast === 'function') showToast('error', 'Không thể lấy dữ liệu in hóa đơn!');
            }
        })
        .catch(err => {
            console.error("Lỗi lấy dữ liệu hóa đơn:", err);
            if (typeof showToast === 'function') showToast('error', 'Lỗi lấy dữ liệu hóa đơn!');
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