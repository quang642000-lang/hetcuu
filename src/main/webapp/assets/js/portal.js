/**
 * =========================================================================
 * TEA PORTAL CUSTOMER RESPONSIVE INTERFACE SCRIPT (v3.0)
 * Handles offcanvas category sidebars, sticky purchase bars, and clipboard copying.
 * =========================================================================
 */

function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
}

// Global Toast notification utility
function showToast(icon, message) {
    if (typeof Swal !== 'undefined') {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2500,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer);
                toast.addEventListener('mouseleave', Swal.resumeTimer);
            }
        });
        Toast.fire({
            icon: icon,
            title: message
        });
    } else {
        alert(message);
    }
}

document.addEventListener("DOMContentLoaded", function() {
    // 1. Sidebar toggler setup for mobile category selection
    const sidebarFilter = document.querySelector('.col-12.col-lg-3.text-start');
    if (sidebarFilter) {
        // Create offcanvas trigger button dynamically
        if (!document.getElementById("portalMobileFilterTriggerBtn") && window.innerWidth <= 768) {
            const filterBtn = document.createElement("button");
            filterBtn.id = "portalMobileFilterTriggerBtn";
            filterBtn.type = "button";
            filterBtn.className = "portal-mobile-filter-trigger";
            filterBtn.innerHTML = '<i class="bi bi-funnel-fill text-white"></i> <span>DANH MỤC & LỌC</span>';
            filterBtn.onclick = togglePortalFilter;
            document.body.appendChild(filterBtn);
        }

        // Create backdrop for filtering
        if (!document.getElementById("portalFilterBackdrop")) {
            const backdrop = document.createElement("div");
            backdrop.id = "portalFilterBackdrop";
            backdrop.className = "portal-filter-backdrop";
            backdrop.onclick = togglePortalFilter;
            document.body.appendChild(backdrop);
        }
    }

    // 2. Quantity Input Listeners for Client Cart page
    document.querySelectorAll('.qty-input-portal').forEach(input => {
        input.addEventListener('change', function() {
            const maCtgh = this.dataset.mactgh;
            const soLuong = this.value;
            updatePortalCartQuantity(maCtgh, soLuong);
        });
    });

    // 3. Dynamic Sticky Bottom Bars for Mobile Screens
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

    fetch(getContextPath() + '/cart/add', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: new URLSearchParams(formData)
    })
        .then(res => {
            if (res.status === 401) {
                window.location.href = getContextPath() + '/customer/login';
                throw new Error('SESSION_EXPIRED');
            }
            return res.json();
        })
        .then(data => {
            if (data.status === 'SUCCESS') {
                showToast('success', 'Đã thêm nhanh ' + tenSp + ' vào giỏ hàng!');
                const badge = document.querySelector('.navbar .badge');
                if (badge) {
                    badge.innerText = data.cartCount;
                    badge.style.display = 'flex';
                }
            } else {
                showToast('error', data.message || 'Thao tác thất bại!');
            }
        })
        .catch(err => console.error('Lỗi:', err));
}

function copyVoucherCode(code) {
    navigator.clipboard.writeText(code).then(() => {
        showToast('success', 'Đã sao chép mã giảm giá: ' + code);
    });
}

function injectMobileCheckoutBar() {
    const totalEl = document.getElementById("finalPayableCart");
    if (!totalEl) return;

    const bar = document.createElement("div");
    bar.id = "portalMobileCheckoutBar";
    bar.className = "portal-mobile-checkout-bar";

    const info = document.createElement("div");
    info.className = "portal-mobile-checkout-info";
    info.innerHTML = `<span>Tổng thanh toán:</span><strong id="mobileTotalDisplay">${totalEl.innerText}</strong>`;

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

    // Observer price changes
    const observer = new MutationObserver(function() {
        document.getElementById("mobileTotalDisplay").innerText = totalEl.innerText;
        const currentCheckoutBtn = document.getElementById("checkoutBtn");
        const isDisabledNow = currentCheckoutBtn ? currentCheckoutBtn.classList.contains("disabled") : true;
        actionBtn.className = "btn " + (isDisabledNow ? "btn-secondary disabled" : "btn-success") + " portal-mobile-checkout-btn";
        actionBtn.innerText = isDisabledNow ? "Chưa chọn món" : "Đặt nước ngay";
    });
    observer.observe(totalEl, { childList: true, characterData: true, subtree: true });
}

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

    // Add To Cart Button
    const addBtn = document.createElement("button");
    addBtn.type = "button";
    addBtn.className = "btn btn-outline-success";
    addBtn.innerHTML = '<i class="bi bi-bag-plus-fill"></i> Thêm giỏ';
    addBtn.onclick = function() {
        if (typeof handleCartAction === "function") {
            handleCartAction('add');
        }
    };

    // Buy Now Button
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

    // Observer total price change
    const observer = new MutationObserver(function() {
        document.getElementById("mobileBuyTotalDisplay").innerText = totalEl.innerText;
    });
    observer.observe(totalEl, { childList: true, characterData: true, subtree: true });
}
