document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll('.qty-input-portal').forEach(input => {
        input.addEventListener('change', function() {
            const maCtgh = this.dataset.mactgh;
            const soLuong = this.value;
            updatePortalCartQuantity(maCtgh, soLuong);
        });
    });
});

// Hàm lấy Context Path tự động từ thanh địa chỉ trình duyệt
function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
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
        .then(res => res.text())
        .then(data => {
            if (data === 'SUCCESS') {
                showToast('success', 'Đã cập nhật số lượng giỏ hàng.');
                setTimeout(() => { location.reload(); }, 600);
            } else {
                showToast('error', 'Cập nhật số lượng thất bại!');
            }
        })
        .catch(err => console.error('Lỗi kết nối:', err));
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
        .then(res => res.text())
        .then(data => {
            if (data === 'SUCCESS') {
                showToast('info', 'Đã thay đổi danh sách thanh toán.');
                setTimeout(() => { location.reload(); }, 600);
            } else {
                showToast('error', 'Xử lý lỗi hệ thống!');
            }
        });
}

function quickAddToCart(maSp, tenSp) {
    const formData = new FormData();
    formData.append('maSp', maSp);
    formData.append('maSize', '1');      // Mặc định Size S
    formData.append('soLuong', '1');     // Mặc định Số lượng 1 ly
    formData.append('mucDa', '100%');    // Mặc định 100% đá
    formData.append('mucDuong', '100%'); // Mặc định 100% đường
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
        .then(res => res.text())
        .then(data => {
            Swal.close();
            if (data === 'NOT_LOGGED_IN') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Yêu cầu đăng nhập',
                    text: 'Quý khách vui lòng đăng nhập tài khoản thành viên để đặt trà sữa tích điểm!',
                    showCancelButton: true,
                    confirmButtonColor: '#2e7d32',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Đăng nhập ngay',
                    cancelButtonText: 'Bỏ qua'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = getContextPath() + '/customer/login';
                    }
                });
            } else if (data.startsWith('SUCCESS')) {
                const parts = data.split('|');
                const cartCount = parts.length > 1 ? parts[12] : '1';

                const badge = document.querySelector('.navbar .badge');
                if (badge) {
                    badge.innerText = cartCount;
                    badge.style.display = 'flex';
                } else {
                    const cartBtn = document.querySelector('.navbar a[href*="/cart"]');
                    if (cartBtn) {
                        cartBtn.innerHTML += `<span class="position-absolute top-0 start-100 translate-middle badge rounded-circle bg-danger text-white border border-light" style="font-size: 10px; width: 22px; height: 22px; display: flex; align-items: center; justify-content: center; padding: 0;">${cartCount}</span>`;
                    }
                }
                showToast('success', `Đã thêm thành công ly ${tenSp} vào giỏ hàng!`);
            } else {
                showToast('error', 'Thêm vào giỏ hàng thất bại!');
            }
        })
        .catch(err => {
            Swal.close();
            console.error('Lỗi:', err);
            showToast('error', 'Lỗi kết nối máy chủ!');
        });
}