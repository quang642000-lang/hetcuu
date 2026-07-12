let posCart = [];
let customerInfo = null;
let appliedVoucher = null;
let appliedPoints = 0; // Số điểm CRM khách muốn quy đổi

// Hàm lấy Context Path tự động tránh lỗi 404
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
    document.getElementById("manualVoucherInput").value = "";
}

// Bật/tắt số lượng Topping trên Popup
function toggleToppingQty(maTp) {
    const chk = document.getElementById('tp_' + maTp);
    const container = document.getElementById('tp_qty_container_' + maTp);
    const qtyInput = document.getElementById('tp_qty_' + maTp);
    if (chk && container && qtyInput) {
        if (chk.checked) {
            container.style.setProperty('display', 'flex', 'important');
            qtyInput.value = 1;
        } else {
            container.style.setProperty('display', 'none', 'important');
            qtyInput.value = 1;
        }
    }
    recalculatePopupPrice();
}

// Tăng/giảm số lượng Topping trên Popup
function adjustPopupToppingQty(maTp, delta) {
    const qtyInput = document.getElementById('tp_qty_' + maTp);
    if (qtyInput) {
        let val = parseInt(qtyInput.value) || 1;
        val += delta;
        if (val < 1) val = 1;
        qtyInput.value = val;
    }
    recalculatePopupPrice();
}

// Hàm mở Popup cấu hình trà sữa và toppings ăn kèm có số lượng và có hình ảnh
function openCustomizePopup(arg1, arg2, arg3) {
    let maSp, tenSp, rawOptions;
    if (typeof arg1 === 'object' && arg1 !== null) {
        // Gọi kiểu truyền cardElement
        maSp = arg1.dataset.masp || arg1.getAttribute('data-masp');
        tenSp = arg1.dataset.tensp || (arg1.querySelector('.pos-card-name') ? arg1.querySelector('.pos-card-name').innerText.trim() : '');
        const optionsStr = arg1.dataset.options || arg1.getAttribute('data-options');
        rawOptions = JSON.parse(decodeURIComponent(optionsStr));
    } else {
        // Gọi kiểu truyền maSp, tenSp, encodedOptions
        maSp = arg1;
        tenSp = arg2;
        rawOptions = JSON.parse(decodeURIComponent(arg3));
    }
    let html = '';
    html += '<div class="text-start" id="posCustomizer" data-masp="' + maSp + '" data-tensp="' + tenSp + '">';
    html += '<h5 class="fw-bold text-success mb-3">' + tenSp + '</h5>';

    // Chọn Size
    html += '<div class="mb-3">';
    html += '<label class="fw-semibold small mb-2 d-block">CHỌN KÍCH CỠ (SIZE)</label>';
    html += '<div class="selection-btn-group">';
    rawOptions.sizes.forEach((s, idx) => {
        let checkedAttr = (idx === 0) ? 'checked' : '';
        html += '<input type="radio" class="selection-radio-input size-radio" name="popup_size" ' +
            'id="sz_' + s.maSize + '" value="' + s.maSize + '" data-price="' + s.giaBan + '" data-name="' + s.tenSize + '" ' + checkedAttr + '>';
        html += '<label class="selection-label" for="sz_' + s.maSize + '">Size ' + s.tenSize + ' (+' + formatVND(s.giaBan) + ')</label>';
    });
    html += '</div></div>';

    // Chọn Đường
    if (rawOptions.choPhepDoiDuong) {
        html += '<div class="mb-3">';
        html += '<label class="fw-semibold small mb-2 d-block">MỨC ĐƯỜNG</label>';
        html += '<div class="selection-btn-group">';
        html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s100" value="100%" checked>';
        html += '<label class="selection-label" for="s100">100%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s70" value="70%">';
        html += '<label class="selection-label" for="s70">70%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s50" value="50%">';
        html += '<label class="selection-label" for="s50">50%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_sugar" id="s0" value="0%">';
        html += '<label class="selection-label" for="s0">0%</label>';
        html += '</div></div>';
    }

    // Chọn Đá
    if (rawOptions.choPhepDoiDa) {
        html += '<div class="mb-3">';
        html += '<label class="fw-semibold small mb-2 d-block">MỨC ĐÁ</label>';
        html += '<div class="selection-btn-group">';
        html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i100" value="100%" checked>';
        html += '<label class="selection-label" for="i100">100%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i70" value="70%">';
        html += '<label class="selection-label" for="i70">70%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i50" value="50%">';
        html += '<label class="selection-label" for="i50">50%</label>';
        html += '<input type="radio" class="selection-radio-input" name="popup_ice" id="i0" value="0%">';
        html += '<label class="selection-label" for="i0">0%</label>';
        html += '</div></div>';
    }

    // Chọn Topping có Hình ảnh và Số lượng
    html += '<div class="mb-3"><label class="fw-semibold small mb-2 d-block">THÊM TOPPING ĐI KÈM (CÓ THỂ CHỌN NHIỀU PHẦN)</label>';
    rawOptions.allToppings.forEach(tp => {
        let imgHtml = (tp.hinhAnh && tp.hinhAnh !== 'null' && tp.hinhAnh !== '')
            ? '<img src="' + tp.hinhAnh + '" class="rounded me-2" style="width: 36px; height: 36px; object-fit: cover; border: 1px solid #ddd;">'
            : '<div class="bg-light rounded me-2 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px; border: 1px solid #ddd;"><i class="bi bi-egg-fried text-muted"></i></div>';

        html += '<div class="form-check d-flex justify-content-between align-items-center mb-2 bg-light p-2 rounded border shadow-sm">';
        html += '  <div class="d-flex align-items-center flex-grow-1">';
        html += '    <input class="form-check-input topping-chk border-secondary me-2" type="checkbox" value="' + tp.maTp + '" ';
        html += '       data-price="' + tp.giaBan + '" data-name="' + tp.tenTp + '" id="tp_' + tp.maTp + '" onchange="toggleToppingQty(' + tp.maTp + ')">';
        html += '    <label class="form-check-label d-flex align-items-center mb-0 cursor-pointer" for="tp_' + tp.maTp + '">';
        html += imgHtml;
        html += '      <div>';
        html += '        <div class="fw-bold text-dark" style="font-size: 13px;">' + tp.tenTp + '</div>';
        html += '        <div class="text-success font-monospace" style="font-size: 11px;">+' + formatVND(tp.giaBan) + '</div>';
        html += '      </div>';
        html += '    </label>';
        html += '  </div>';
        html += '  <div class="input-group input-group-sm" id="tp_qty_container_' + tp.maTp + '" style="width: 80px; display: none !important;">';
        html += '    <button type="button" class="btn btn-outline-secondary px-2 py-0" onclick="adjustPopupToppingQty(' + tp.maTp + ', -1)">-</button>';
        html += '    <input type="text" id="tp_qty_' + tp.maTp + '" class="form-control text-center p-0 fw-bold border-secondary border-opacity-25" value="1" readonly style="font-size: 11px; height: 24px; background-color: #ffffff;">';
        html += '    <button type="button" class="btn btn-outline-secondary px-2 py-0 text-success" onclick="adjustPopupToppingQty(' + tp.maTp + ', 1)">+</button>';
        html += '  </div>';
        html += '</div>';
    });
    html += '</div>';

    // Ghi chú pha chế
    html += '<div class="mb-3">';
    html += '<label class="fw-semibold small mb-2">Ghi chú pha chế</label>';
    html += '<textarea class="form-control" id="popup_note" rows="2" placeholder="Ít đá, mang ly đá riêng..."></textarea>';
    html += '</div>';

    // Thành tiền và nút Thêm
    html += '<div class="d-flex justify-content-between align-items-center mt-4">';
    html += '<span class="fw-bold fs-5 text-success" id="popup_total">0 đ</span>';
    html += '<button class="btn btn-primary" onclick="addCustomizedToCart()">';
    html += '<i class="bi bi-cart-plus me-1"></i> Thêm vào đơn';
    html += '</button></div>';

    Swal.fire({
        title: 'TÙY BIẾN PHA CHẾ ĐỒ UỐNG',
        html: html,
        showConfirmButton: false,
        showCloseButton: true,
        didOpen: () => {
            document.querySelectorAll('.size-radio').forEach(el => {
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
        const tpId = tp.value;
        const qtyInput = document.getElementById('tp_qty_' + tpId);
        const qty = qtyInput ? parseInt(qtyInput.value) : 1;
        toppingPrice += parseInt(tp.dataset.price) * qty;
    });
    document.getElementById('popup_total').innerText = formatVND(sizePrice + toppingPrice);
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
        const tpId = parseInt(tp.value);
        const qtyInput = document.getElementById('tp_qty_' + tpId);
        const qty = qtyInput ? parseInt(qtyInput.value) : 1;
        toppingsList.push({
            maTp: tpId,
            tenTp: tp.dataset.name,
            giaTp: parseInt(tp.dataset.price),
            soLuongTp: qty
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

// Kết xuất giỏ hàng POS với toppings có số lượng hiển thị chi tiết
function renderPosCart() {
    const container = document.getElementById('posCartItems');
    if (posCart.length === 0) {
        container.innerHTML =
            '<div class="text-center text-muted py-5 my-5">' +
            '<i class="bi bi-cart-x fs-1 text-secondary opacity-50"></i>' +
            '<p class="small mt-2">Chưa chọn món. Chạm sản phẩm ở lưới giữa để tạo đơn.</p>' +
            '</div>';
        recalculatePOSBill(0);
        return;
    }
    container.innerHTML = '';
    let tongTienHang = 0;

    posCart.forEach((item, idx) => {
        let toppingTotal = item.toppings.reduce((sum, t) => sum + (t.giaTp * t.soLuongTp), 0);
        let rowPrice = (item.giaBan + toppingTotal) * item.soLuong;
        tongTienHang += rowPrice;

        let toppingsText = '';
        if (item.toppings && item.toppings.length > 0) {
            item.toppings.forEach(t => {
                toppingsText += '<br>+ Topping: ' + t.tenTp + ' (x' + t.soLuongTp + ')';
            });
        }

        container.innerHTML +=
            '<div class="pos-bill-item">' +
            '  <div class="pos-bill-item-details">' +
            '    <div class="pos-bill-item-title">' + item.tenSp + ' (Size ' + item.tenSize + ')</div>' +
            '    <div class="pos-bill-item-options">' +
            '      Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + toppingsText +
            '    </div>' +
            '    <div class="pos-bill-item-price">' + formatVND(rowPrice) + '</div>' +
            '  </div>' +
            '  <div class="d-flex flex-column align-items-end gap-2">' +
            '    <button type="button" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 11px;" onclick="removeCartItem(' + idx + ')">' +
            '      <i class="bi bi-trash"></i>' +
            '    </button>' +
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
                showToast('success', 'Tìm thấy thành viên: ' + data.tenKh);
                document.getElementById("crmLoyaltyArea").style.display = "block";
                document.getElementById("posAddCustomerArea").style.display = "none";
            } else {
                customerInfo = null;
                document.getElementById('submit_maKh').value = "";
                document.getElementById('customerNameResult').innerText = "Khách lẻ vãng lai";
                document.getElementById('customerPoints').innerText = "Hạng: Mới | 0 Điểm";
                document.getElementById("crmLoyaltyArea").style.display = "none";
                document.getElementById("posAddCustomerArea").style.display = "block";

                Swal.fire({
                    icon: 'question',
                    title: 'Số điện thoại mới!',
                    html: 'Số điện thoại <strong>' + sdt + '</strong> chưa đăng ký thành viên CRM. Quý khách có muốn tạo nhanh tài khoản tích điểm không?',
                    showCancelButton: true,
                    confirmButtonColor: '#10b981',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Tạo tài khoản mới',
                    cancelButtonText: 'Để sau'
                }).then((res) => {
                    if (res.isConfirmed) {
                        openQuickAddCustomerModal();
                    }
                });
                resetVoucherAndPoints();
                renderPosCart();
            }
        });
}

function openQuickAddCustomerModal() {
    const sdt = document.getElementById('customerPhoneSearch').value.trim();
    let html = '';
    html += '<div class="text-start">';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Số điện thoại di động</label>';
    html += '    <input type="text" class="form-control" id="reg_sdt" value="' + sdt + '" readonly style="background-color: #f1f5f9; font-weight: 700;">';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Họ tên thành viên <span class="text-danger">*</span></label>';
    html += '    <input type="text" class="form-control" id="reg_tenKh" placeholder="Nhập họ tên đầy đủ..." required>';
    html += '  </div>';
    html += '  <div class="mb-3">';
    html += '    <label class="fw-bold small mb-1">Địa chỉ Email <span class="text-danger">*</span></label>';
    html += '    <input type="email" class="form-control" id="reg_email" placeholder="khachhang@gmail.com..." required>';
    html += '  </div>';
    html += '</div>';

    Swal.fire({
        title: 'ĐĂNG KÝ HỘI VIÊN VIP',
        html: html,
        showCancelButton: true,
        confirmButtonColor: '#10b981',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Đăng Ký',
        cancelButtonText: 'Hủy Bỏ',
        preConfirm: () => {
            const tenKh = document.getElementById('reg_tenKh').value.trim();
            const email = document.getElementById('reg_email').value.trim();
            if (!tenKh || !email) {
                Swal.showValidationMessage('Vui lòng nhập đầy đủ Họ tên và Email!');
            }
            return { tenKh, email, sdt };
        }
    }).then((result) => {
        if (result.isConfirmed) {
            Swal.fire({
                title: 'Đang khởi tạo tài khoản...',
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); }
            });
            const url = getContextPath() + '/pos/create-customer';
            const params = new URLSearchParams();
            params.append('tenKh', result.value.tenKh);
            params.append('email', result.value.email);
            params.append('soDienThoai', result.value.sdt);

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
                        document.getElementById("crmLoyaltyArea").style.display = "block";
                        document.getElementById("posAddCustomerArea").style.display = "none";
                        Swal.fire({
                            icon: 'success',
                            title: 'Thành công',
                            text: 'Đã khởi tạo tài khoản CRM VIP cho thành viên ' + data.tenKh + '!',
                            confirmButtonColor: '#10b981'
                        });
                    } else {
                        Swal.fire({ icon: 'error', title: 'Đăng ký thất bại', text: data.message });
                    }
                })
                .catch(err => {
                    Swal.close();
                    console.error('Lỗi AJAX:', err);
                    showToast('error', 'Lỗi kết nối máy chủ!');
                });
        }
    });
}

function applyManualVoucherCode() {
    const code = document.getElementById("manualVoucherInput").value.trim();
    if (!code) {
        showToast('warning', 'Vui lòng điền mã Voucher cần áp dụng!');
        return;
    }
    const totalRaw = parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')) || 0;
    if (totalRaw === 0) {
        showToast('warning', 'Vui lòng chọn món nước uống trước khi áp Voucher!');
        return;
    }
    const maKh = document.getElementById("submit_maKh").value;

    Swal.fire({
        title: 'Đang áp mã Voucher...',
        allowOutsideClick: false,
        didOpen: () => { Swal.showLoading(); }
    });

    const url = getContextPath() + '/pos/apply-voucher';
    const params = new URLSearchParams();
    params.append('code', code);
    params.append('maKh', maKh);
    params.append('tongTienHang', totalRaw);

    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params
    })
        .then(res => res.json())
        .then(data => {
            Swal.close();
            if (data.status === 'SUCCESS') {
                appliedVoucher = data;
                showToast('success', 'Đã áp dụng thành công Voucher: ' + code);
                recalculatePOSBill(totalRaw);
            } else {
                Swal.fire({ icon: 'error', title: 'Lỗi áp mã', text: data.message });
            }
        })
        .catch(err => {
            Swal.close();
            console.error('Lỗi AJAX:', err);
            showToast('error', 'Lỗi kết nối quầy POS với máy chủ!');
        });
}

function showVoucherSelectionModal() {
    if (!customerInfo) {
        showToast('warning', 'Hãy xác thực thành viên CRM trước!');
        return;
    }
    if (posCart.length === 0) {
        showToast('warning', 'Vui lòng chọn cốc nước trước khi áp mã!');
        return;
    }
    if (!customerInfo.vouchers || customerInfo.vouchers.length === 0) {
        Swal.fire({
            icon: 'info',
            title: 'Hộp mã trống',
            text: 'Thành viên hiện tại chưa có Voucher VIP khả dụng!',
            confirmButtonColor: '#10b981'
        });
        return;
    }
    let selectHtml = '<select id="posVoucherSelector" class="form-select mb-2"><option value="">-- Bỏ áp dụng Voucher --</option>';
    customerInfo.vouchers.forEach(v => {
        let txtType = v.loaiGiam === 1 ? formatVND(v.giaTriGiam) : v.giaTriGiam + "%";
        selectHtml += '<option value="' + v.maCode + '">' + v.maCode + ' (Giảm ' + txtType + ' | Đơn từ ' + formatVND(v.donToiThieu) + ')</option>';
    });
    selectHtml += '</select>';

    Swal.fire({
        title: 'KHO VOUCHER KHẢ DỤNG',
        html: selectHtml,
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
            recalculatePOSBill(parseInt(document.getElementById('totalRawPrice').innerText.replace(/\D/g, '')));
        }
    });
}

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
        cancelButtonText: 'Hủy bộ',
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
            showToast('success', 'Đồng ý khấu trừ ' + appliedPoints + ' điểm tích lũy của khách.');
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
            document.getElementById("summaryDiscountRow").style.display = "flex";
            document.getElementById("txtAppliedCode").innerText = appliedVoucher.maCode;
            document.getElementById("totalDiscountPrice").innerText = "-" + formatVND(discount);
            document.getElementById("submit_maKm").value = appliedVoucher.maKm;
            document.getElementById("submit_tienGiamGia").value = discount;
        } else {
            showToast('warning', 'Hóa đơn chưa đạt giá trị tối thiểu ' + formatVND(appliedVoucher.donToiThieu) + ' để giữ Voucher!');
            appliedVoucher = null;
            document.getElementById("summaryDiscountRow").style.display = "none";
            document.getElementById("submit_maKm").value = "";
            document.getElementById("submit_tienGiamGia").value = "0";
        }
    }

    let pointsDiscount = appliedPoints * 1000;
    if (pointsDiscount > (rawSum - discount)) {
        pointsDiscount = rawSum - discount;
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

    let vatPrice = Math.round(billBeforeTax * 0.08);
    let finalPayable = billBeforeTax + vatPrice;

    document.getElementById('totalRawPrice').innerText = formatVND(rawSum);
    document.getElementById('totalTaxPrice').innerText = formatVND(vatPrice);
    document.getElementById('totalPayablePrice').innerText = formatVND(finalPayable);

    document.getElementById('submit_tongTienHang').value = rawSum;
    document.getElementById('submit_tongPhaiTra').value = finalPayable;

    calculateChangeRefund();
}

function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

function loadAndShowPrintReceipt(orderId) {
    // Render loading indicator inside Modal Container to prevent caching issues
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
                    document.getElementById("billPointsRow").style.display = 'flex';
                    document.getElementById("billPointsDiscount").innerText = '-' + parseInt(data.tienTruDiem).toLocaleString('vi-VN') + ' đ';
                } else {
                    document.getElementById("billPointsRow").style.display = 'none';
                }

                document.getElementById("billFinalPayable").innerText = parseInt(data.tongPhaiTra).toLocaleString('vi-VN') + ' đ';

                let container = document.getElementById("billItemsContainer");
                container.innerHTML = '';

                data.items.forEach(item => {
                    let html = '<div style="margin-bottom: 8px; border-bottom: 1px dashed #eee; padding-bottom: 4px;">';
                    html += '  <div class="d-flex justify-content-between">';
                    html += '    <span><strong>' + item.tenMon + '</strong> (Size: ' + item.tenSize + ')</span>';
                    html += '    <strong>' + item.soLuong + ' x ' + parseInt(item.giaChot).toLocaleString('vi-VN') + ' đ</strong>';
                    html += '  </div>';
                    html += '  <small style="font-size: 9px; color: #555;">Đá: ' + item.mucDa + ' | Đường: ' + item.mucDuong + '</small>';

                    if (item.toppings && item.toppings.length > 0) {
                        html += '  <div style="padding-left: 8px; font-size: 9px; color: #555;">';
                        item.toppings.forEach(tp => {
                            html += '    <div>+ ' + tp.tenTopping + ' (SL: ' + tp.soLuong + ' x ' + parseInt(tp.giaChotTp).toLocaleString('vi-VN') + ' đ)</div>';
                        });
                        html += '  </div>';
                    }
                    html += '</div>';
                    container.innerHTML += html;
                });

                const printModal = new bootstrap.Modal(document.getElementById('receiptDetailModal'));
                printModal.show();
            } else {
                showToast('error', 'Không thể lấy dữ liệu in hóa đơn!');
            }
        })
        .catch(err => {
            console.error("Lỗi lấy dữ liệu hóa đơn:", err);
            showToast('error', 'Lỗi lấy dữ liệu hóa đơn!');
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
