/**
 * =========================================================================
 * TEA PORTAL CUSTOMER RESPONSIVE INTERFACE SCRIPT
 * Dynamically injects Offcanvas drawer triggers, sticky checkout bars,
 * and sticky buy bars on mobile devices.
 * =========================================================================
 */
document.addEventListener("DOMContentLoaded", function() {
    // 1. Setup change listeners for cart quantity
    document.querySelectorAll('.qty-input-portal').forEach(input => {
        input.addEventListener('change', function() {
            const maCtgh = this.dataset.mactgh;
            const soLuong = this.value;
            updatePortalCartQuantity(maCtgh, soLuong);
        });
    });

    // 2. Dynamic Backdrop injection for filters
    if (!document.getElementById("portalFilterBackdrop")) {
        const backdrop = document.createElement("div");
        backdrop.id = "portalFilterBackdrop";
        backdrop.className = "portal-filter-backdrop";
        backdrop.onclick = togglePortalFilter;
        document.body.appendChild(backdrop);
    }

    // 3. Dynamic Filter Trigger Floating Button injection
    const sidebarFilter = document.querySelector('.col-12.col-lg-3.text-start');
    if (sidebarFilter && !document.getElementById("portalMobileFilterTriggerBtn")) {
        const filterBtn = document.createElement("button");
        filterBtn.id = "portalMobileFilterTriggerBtn";
        filterBtn.type = "button";
        filterBtn.className = "portal-mobile-filter-trigger";
        filterBtn.innerHTML = '<i class="bi bi-funnel-fill text-white"></i> <span>DANH MỤC & LỌC</span>';
        filterBtn.onclick = togglePortalFilter;
        document.body.appendChild(filterBtn);
    }

    // 4. Dynamic Sticky Bottom Bars for Mobile Screens
    const path = window.location.pathname;

    // CASE A: Cart page sticky bottom checkout bar
    if (path.includes("/cart") && !document.getElementById("portalMobileCheckoutBar") && window.innerWidth <= 768) {
        injectMobileCheckoutBar();
    }

    // CASE B: Product Detail page sticky bottom buy bar
    if (path.includes("/product/detail") && !document.getElementById("portalMobileBuyBar") && window.innerWidth <= 768) {
        injectMobileBuyBar();
    }
});

function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
}

function togglePortalFilter() {
    const sidebar = document.querySelector('.col-12.col-lg-3.text-start');
    const backdrop = document.getElementById('portalFilterBackdrop');
    if (sidebar && backdrop) {
        sidebar.classList.toggle('show');
        backdrop.classList.toggle('show');
        if (sidebar.classList.contains('show')) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
    }
}

function updatePortalCartQuantity(maCtgh, soLuong) {
    const formData = new FormData();
    formData.append('maCtgh', maCtgh);
    formData.append('soLuong', soLuong);
    fetch(getContextPath() + '/cart/update', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: new URLSearchParams(formData)
    })
        .then(res => {
            if (res.status === 401) {
                window.location.href = getContextPath() + '/customer/login';
                throw new Error('SESSION_EXPIRED');
            }
            return res.text();
        })
        .then(data => {
            if (data.trim() === 'SUCCESS') {
                showToast('success', 'Đã cập nhật số lượng giỏ hàng.');
                setTimeout(() => { location.reload(); }, 600);
            } else {
                showToast('error', 'Cập nhật số lượng thất bại!');
            }
        })
        .catch(err => console.error('Lỗi:', err));
}

function toggleSelectCartItem(maCtgh, checkboxElement) {
    const isChecked = checkboxElement.checked ? "1" : "0";
    const formData = new FormData();
    formData.append('maCtgh', maCtgh);
    formData.append('chon', isChecked);
    fetch(getContextPath() + '/cart/toggle-select', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: new URLSearchParams(formData)
    })
        .then(res => {
            if (res.status === 401) {
                window.location.href = getContextPath() + '/customer/login';
                throw new Error('SESSION_EXPIRED');
            }
            return res.text();
        })
        .then(data => {
            if (data.trim() === 'SUCCESS') {
                showToast('info', 'Đã thay đổi danh sách thanh toán.');
                setTimeout(() => { location.reload(); }, 600);
            } else {
                showToast('error', 'Xử lý lỗi hệ thống!');
            }
        })
        .catch(err => console.error('Lỗi:', err));
}

function quickAddToCart(maSp, tenSp) {
    const formData = new FormData();
    formData.append('maSp', maSp);
    formData.append('maSize', '1');
    formData.append('soLuong', '1');
    formData.append('mucDa', '100%');
    formData.append('mucDuong', '100%');
    formData.append('ghiChuMon', 'Quick Add');

    Swal.fire({
        title: 'Đang thêm vào giỏ hàng...',
        allowOutsideClick: false,
        didOpen: () => { Swal.showLoading(); }
    });

    fetch(getContextPath() + '/cart/add', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: new URLSearchParams(formData)
    })
        .then(res => {
            if (res.status === 401) {
                Swal.close();
                window.location.href = getContextPath() + '/customer/login';
                throw new Error('SESSION_EXPIRED');
            }
            return res.text();
        })
        .then(data => {
            Swal.close();
            const cleanData = data.trim();
            if (cleanData.startsWith('SUCCESS')) {
                const parts = cleanData.split('|');
                const cartCount = parts.length > 1 ? parts[1] : '1';
                const badge = document.querySelector('.navbar .badge');
                if (badge) {
                    badge.innerText = cartCount;
                    badge.style.display = 'flex';
                }
                showToast('success', 'Đã thêm thành công ly ' + tenSp + ' vào giỏ hàng!');
            } else {
                showToast('error', 'Thêm vào giỏ hàng thất bại!');
            }
        })
        .catch(err => {
            Swal.close();
            console.error('Lỗi:', err);
        });
}

/* =========================================================================
 * STICKY CHECKOUT BAR INJECTION FOR /cart PAGE ON MOBILE
 * ========================================================================= */
function injectMobileCheckoutBar() {
    const totalEl = document.getElementById("finalPayableCart");
    if (!totalEl) return;

    const bar = document.createElement("div");
    bar.id = "portalMobileCheckoutBar";
    bar.className = "portal-mobile-checkout-bar";

    const info = document.createElement("div");
    info.className = "portal-mobile-checkout-info";
    info.innerHTML = `<span>Tổng thanh toán (VAT 8%):</span><strong id="mobileTotalDisplay">${totalEl.innerText}</strong>`;

    const checkoutBtn = document.getElementById("checkoutBtn");
    const isBtnDisabled = checkoutBtn ? checkoutBtn.classList.contains("disabled") : true;

    const actionBtn = document.createElement("button");
    actionBtn.type = "button";
    actionBtn.className = "btn " + (isBtnDisabled ? "btn-secondary disabled" : "btn-success") + " portal-mobile-checkout-btn";
    actionBtn.innerText = isBtnDisabled ? "Chưa chọn món" : "Đặt nước ngay";

    actionBtn.onclick = function() {
        if (!isBtnDisabled && checkoutBtn) {
            checkoutBtn.click();
        }
    };

    bar.appendChild(info);
    bar.appendChild(actionBtn);
    document.body.appendChild(bar);

    // Sync price changes dynamically from JSTL/AJAX actions
    const observer = new MutationObserver(function() {
        document.getElementById("mobileTotalDisplay").innerText = totalEl.innerText;
        const currentCheckoutBtn = document.getElementById("checkoutBtn");
        const isDisabledNow = currentCheckoutBtn ? currentCheckoutBtn.classList.contains("disabled") : true;

        actionBtn.className = "btn " + (isDisabledNow ? "btn-secondary disabled" : "btn-success") + " portal-mobile-checkout-btn";
        actionBtn.innerText = isDisabledNow ? "Chưa chọn món" : "Đặt nước ngay";
    });
    observer.observe(totalEl, { childList: true, characterData: true, subtree: true });
}

/* =========================================================================
 * STICKY BUY BAR INJECTION FOR /product/detail PAGE ON MOBILE
 * ========================================================================= */
function injectMobileBuyBar() {
    const totalEl = document.getElementById("displayTotal");
    if (!totalEl) return;

    const bar = document.createElement("div");
    bar.id = "portalMobileBuyBar";
    bar.className = "portal-mobile-buy-bar";

    const info = document.createElement("div");
    info.className = "portal-mobile-buy-info";
    info.innerHTML = `<span>Tổng tạm tính:</span><strong id="mobileBuyTotalDisplay">${totalEl.innerText}</strong>`;

    const btnGroup = document.createElement("div");
    btnGroup.className = "portal-mobile-buy-btn-group";

    // Create Add To Cart Button
    const addBtn = document.createElement("button");
    addBtn.type = "button";
    addBtn.className = "btn btn-outline-success";
    addBtn.innerHTML = '<i class="bi bi-bag-plus-fill"></i> Thêm giỏ';
    addBtn.onclick = function() {
        if (typeof handleCartAction === "function") {
            handleCartAction('add');
        }
    };

    // Create Buy Now Button
    const buyBtn = document.createElement("button");
    buyBtn.type = "button";
    buyBtn.className = "btn btn-success";
    buyBtn.innerHTML = 'Mua ngay ⚡';
    buyBtn.onclick = function() {
        if (typeof handleCartAction === "function") {
            handleCartAction('buy');
        }
    };

    btnGroup.appendChild(addBtn);
    btnGroup.appendChild(buyBtn);
    bar.appendChild(info);
    bar.appendChild(btnGroup);
    document.body.appendChild(bar);

    // Sync price changes dynamically from radio sizes and checkbox toppings
    const observer = new MutationObserver(function() {
        document.getElementById("mobileBuyTotalDisplay").innerText = totalEl.innerText;
    });
    observer.observe(totalEl, { childList: true, characterData: true, subtree: true });
}
