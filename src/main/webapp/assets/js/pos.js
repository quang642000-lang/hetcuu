let posCart = [];
let customerInfo = null;
let appliedVoucher = null;
let appliedPoints = 0;
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
    const input = document.getElementById('tp_qty_' + maTp);
    if (checkbox.checked) {
        if (container) container.style.setProperty('display', 'flex', 'important');
        if (input) input.value = 1;
    } else {
        if (container) container.style.setProperty('display', 'none', 'important');
        if (input) input.value = 1;
    }
    recalculatePopupPrice();
}
function adjustPopupToppingQty(event, maTp, change) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    const input = document.getElementById('tp_qty_' + maTp);
    if (input) {
        let val = parseInt(input.value) || 1;
        val += change;
        if (val < 1) val = 1;
        input.value = val;
    }
    recalculatePopupPrice();
}
function recalculatePopupPrice() {
    const checkedSize = document.querySelector('.size-radio:checked');
    if (!checkedSize) return;
    const basePrice = parseInt(checkedSize.dataset.price) || 0;
    let toppingsSum = 0;
    document.querySelectorAll('.topping-chk:checked').forEach(chk => {
        const maTp = chk.value;
        const qtyInput = document.getElementById('tp_qty_' + maTp);
        const qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
        const price = parseInt(chk.dataset.price) || 0;
        toppingsSum += price * qty;
    });
    const total = basePrice + toppingsSum;
    const totalEl = document.getElementById('popup_total');
    if (totalEl) totalEl.innerText = formatVND(total);
}
function openCustomizePopup(maSp, tenSp, encodedOptions) {
    let rawOptions;
    try {
        rawOptions = JSON.parse(decodeURIComponent(encodedOptions));
    } catch (e) {
        console.error("Lỗi parse cấu hình sản phẩm:", e);
        return;
    }
    let html = '';
    html += '<div class="text-start" id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '">';
    html += '  <h5 class="fw-bold text-success mb-3">' + tenSp + '</h5>';
// 1. CHỌN SIZE
    html += '  <div class="mb-3">';
    html += '    <label class="fw-semibold small mb-2 d-block text-secondary">1. CHỌN KÍCH CỠ (SIZE)</label>';
    html += '    <div class="selection-btn-group d-flex gap-2">';
    rawOptions.sizes.forEach((s, idx) => {
        let checkedAttr = (idx === 0) ? 'checked' : '';
        html += '      <input type="radio" class="btn-check size-radio" name="popup_size" ' +
            '             id="sz_' + s.maSize + '" value="' + s.maSize + '" data-price="' + s.giaBan + '" data-name="' + s.tenSize + '" ' + checkedAttr + ' onchange="recalculatePopupPrice()">';
        html += '      <label class="btn btn-outline-success btn-sm flex-fill" for="sz_' + s.maSize + '">Size ' + s.tenSize + ' (+' + formatVND(s.giaBan) + ')</label>';
    });
    html += '    </div>';
    html += '  </div>';
// 2. CHỌN ĐƯỜNG
    if (rawOptions.choPhepDoiDuong) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">2. CHỌN MỨC ĐƯỜNG</label>';
        html += '    <div class="selection-btn-group d-flex gap-1">';
        const sugars = ["100%", "70%", "50%", "0%"];
        sugars.forEach((sugar, idx) => {
            let checkedAttr = (idx === 0) ? 'checked' : '';
            html += '      <input type="radio" class="btn-check sugar-radio" name="popup_sugar" ' +
                '             id="sg_' + idx + '" value="' + sugar + '" ' + checkedAttr + '>';
            html += '      <label class="btn btn-outline-secondary btn-sm flex-fill" for="sg_' + idx + '">' + sugar + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }
// 3. CHỌN ĐÁ
    if (rawOptions.choPhepDoiDa) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">3. CHỌN MỨC ĐÁ</label>';
        html += '    <div class="selection-btn-group d-flex gap-1">';
        const ices = ["100%", "70%", "50%", "0%"];
        ices.forEach((ice, idx) => {
            let checkedAttr = (idx === 0) ? 'checked' : '';
            html += '      <input type="radio" class="btn-check ice-radio" name="popup_ice" ' +
                '             id="ic_' + idx + '" value="' + ice + '" ' + checkedAttr + '>';
            html += '      <label class="btn btn-outline-secondary btn-sm flex-fill" for="ic_' + idx + '">' + ice + '</label>';
        });
        html += '    </div>';
        html += '  </div>';
    }
// 4. CHỌN TOPPING ĐA LƯỢNG (CHECKS FOR SẢN PHẨM MẸ CHO PHÉP TOPPING)
    if (rawOptions.choPhepTopping !== false && rawOptions.allToppings && rawOptions.allToppings.length > 0) {
        html += '  <div class="mb-3">';
        html += '    <label class="fw-semibold small mb-2 d-block text-secondary">4. THÊM TOPPING DAI GIÒN SẦN SẬT</label>';
        html += '    <div style="max-height: 180px; overflow-y: auto; padding-right: 4px;">';
        rawOptions.allToppings.forEach(tp => {
            let imgHtml = tp.hinhAnh && tp.hinhAnh !== "None" && tp.hinhAnh !== ""
                ? '<img src="' + tp.hinhAnh + '" alt="' + tp.tenTp + '" class="rounded me-2" style="width: 32px; height: 32px; object-fit: cover; border: 1px solid #ddd;">'
                : '<div class="bg-light rounded me-2 d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; border: 1px solid #ddd;"><i class="bi bi-egg-fried text-muted"></i></div>';
            html += '      <div class="form-check d-flex justify-content-between align-items-center mb-1 bg-light p-1.5 rounded border shadow-sm" style="padding-left: 30px;">';
            html += '        <div class="d-flex align-items-center">';
            html += '          <input class="form-check-input topping-chk me-2" type="checkbox" value="' + tp.maTp + '" id="tp_' + tp.maTp + '" data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" onchange="toggleToppingQty(this, \'' + tp.maTp + '\')">';
            html += '          <label class="form-check-label d-flex align-items-center cursor-pointer" for="tp_' + tp.maTp + '">';
            html += imgHtml;
            html += '            <div>';
            html += '              <div class="fw-bold text-dark" style="font-size: 12px;">' + tp.tenTp + '</div>';
            html += '              <div class="text-success font-monospace" style="font-size: 10px;">+' + formatVND(tp.giaBan) + '</div>';
            html += '            </div>';
            html += '          </label>';
            html += '        </div>';
            html += '        <div class="input-group input-group-sm" id="tp_qty_container_' + tp.maTp + '" style="width: 80px; display: none !important;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-2 py-0 border-opacity-50" onclick="adjustPopupToppingQty(event, \'' + tp.maTp + '\', -1)">-</button>';
            html += '          <input type="text" class="form-control text-center bg-white border-secondary border-opacity-25 px-0 fw-bold" id="tp_qty_' + tp.maTp + '" value="1" readonly style="font-size: 11px; height: 24px;">';
            html += '          <button type="button" class="btn btn-outline-secondary px-2 py-0 text-success border-opacity-50" onclick="adjustPopupToppingQty(event, \'' + tp.maTp + '\', 1)">+</button>';
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
function addCustomizedToCart() {
    const el = document.getElementById('posCustomizer');
    const maSp = el.dataset.masp;
    const tenSp = el.dataset.tensp;
    const checkedSize = document.querySelector('.size-radio:checked');
    const maSize = parseInt(checkedSize.value);
    const tenSize = checkedSize.dataset.name;
    const giaBan = parseInt(checkedSize.dataset.price);
    const sugarEl = document.querySelector('input[name="popup_sugar"]:checked');
    const mucDuong = sugarEl ? sugarEl.value : "100%";
    const iceEl = document.querySelector('input[name="popup_ice"]:checked');
    const mucDa = iceEl ? iceEl.value : "100%";
    const ghiChuMon = document.getElementById('popup_note').value;
    let toppingsList = [];
    document.querySelectorAll('.topping-chk:checked').forEach(tp => {
        const tpId = tp.value; // string key
        const qtyInput = document.getElementById('tp_qty_' + tpId);
        const qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
        toppingsList.push({
            maTp: tpId,
            tenTp: tp.dataset.name,
            giaTp: parseInt(tp.dataset.price),
            soLuongTp: qty
        });
    });
    let matchedIdx = -1;
    for (let i = 0; i < posCart.length; i++) {
        let item = posCart[i];
        if (item.maSp === maSp && item.maSize === maSize && item.mucDa === mucDa && item.mucDuong === mucDuong && item.ghiChuMon === ghiChuMon) {
            if (isSameToppingsList(item.toppings, toppingsList)) {
                matchedIdx = i;
                break;
            }
        }
    }
    if (matchedIdx > -1) {
        posCart[matchedIdx].soLuong += 1;
    } else {
        posCart.push({
            maSp: maSp,
            tenSp: tenSp,
            maSize: maSize,
            tenSize: tenSize,
            giaBan: giaBan,
            mucDa: mucDa,
            mucDuong: mucDuong,
            ghiChuMon: ghiChuMon,
            soLuong: 1,
            toppings: toppingsList
        });
    }
    if (typeof Swal !== 'undefined') Swal.close();
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
        item.toppings.forEach(t => {
            toppingSum += t.giaTp * t.soLuongTp;
            toppingsText += ', ' + t.tenTp + ' (x' + t.soLuongTp + ')';
        });
        const singleUnitSum = item.giaBan + toppingSum;
        const lineTotal = singleUnitSum * item.soLuong;
        tongTienHang += lineTotal;
        let noteText = item.ghiChuMon && item.ghiChuMon.trim() !== "" ? ' | Ghi chú: ' + item.ghiChuMon : '';
        container.innerHTML +=
            '<div class="pos-bill-item shadow-sm mb-2 p-3 bg-white rounded border">' +
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
                if (typeof showToast === 'function') {
                    showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
                }
                document.getElementById("crmLoyaltyArea").style.setProperty('display', 'block', 'important');
                document.getElementById("posAddCustomerArea").style.setProperty('display', 'none', 'important');
                resetVoucherAndPoints();
                renderPosCart();
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
    html += '    <label class="fw-bold small mb-1">Họ tên thành viên <span class="text-danger">*</span></label>';
    html += '    <input type="text" class="form-control" id="reg_tenKh" placeholder="Nhập họ tên đầy đủ..." required autocomplete="off">';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Địa chỉ Email nhận OTP <span class="text-danger">*</span></label>';
    html += '    <input type="email" class="form-control" id="reg_email" placeholder="Nhập email..." required autocomplete="off">';
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
    if (maPt === 1) {
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
            inputCustomerCashEl.focus();
            return;
        }
    }
    const container = document.getElementById('posFormItemsContainer');
    container.innerHTML = '';
    posCart.forEach((item) => {
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
    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
    document.getElementById('submit_tongTienHang').value = totalRaw.toString();
    document.getElementById('submit_tongPhaiTra').value = totalPayable.toString();
    if (customerInfo) {
        document.getElementById('submit_maKh').value = customerInfo.maKh.toString();
    }
    if (typeof Swal !== 'undefined') {
        Swal.fire({
            title: 'Chốt giao dịch quầy POS',
            text: 'Tiến hành in hóa đơn bán lẻ và đồng bộ ví điểm CRM cho khách hàng?',
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
                    html += '    <strong>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</strong>';
                    html += '  </div>';
                    html += '  <small style="font-size: 9px; color: #555;">Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + '</small>';
                    if (item.toppings && item.toppings.length > 0) {
                        html += '  <div style="padding-left: 8px; font-size: 9px; color: #555;">';
                        tp.toppings.forEach(tp => {
                            html += '    <div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                        });
                        html += '  </div>';
                    }
                    html += '</div>';
                    container.innerHTML += html;
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