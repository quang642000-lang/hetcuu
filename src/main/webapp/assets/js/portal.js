document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll('.qty-input-portal').forEach(input => {
        input.addEventListener('change', function() {
            const maCtgh = this.dataset.mactgh;
            const soLuong = this.value;
            updatePortalCartQuantity(maCtgh, soLuong);
        });
    });
});

// Hàm tiện ích lấy Context Path tự động từ thanh địa chỉ trình duyệt
function getContextPath() {
    return window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
}

function updatePortalCartQuantity(maCtgh, soLuong) {
    const formData = new FormData();
    formData.append('maCtgh', maCtgh);
    formData.append('soLuong', soLuong);

    // Ghép Context Path tự động
    fetch(getContextPath() + '/cart/update', {
        method: 'POST',
        body: new URLSearchParams(formData)
    })
        .then(res => res.text())
        .then(data => {
            if (data === 'SUCCESS') {
                showToast('success', 'Đã cập nhật số lượng giỏ hàng.');
                setTimeout(() => { location.reload(); }, 1000);
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
        body: new URLSearchParams(formData)
    })
        .then(res => res.text())
        .then(data => {
            if (data === 'SUCCESS') {
                showToast('info', 'Đã thay đổi danh sách thanh toán.');
                setTimeout(() => { location.reload(); }, 800);
            } else {
                showToast('error', 'Xử lý lỗi hệ thống!');
            }
        });
}
