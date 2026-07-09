/**
 * =========================================================================
 * TEA POS - PORTAL CUSTOMER WEB CONTROLLER
 * =========================================================================
 */

document.addEventListener("DOMContentLoaded", function() {
    // Tự động lắng nghe thay đổi số lượng ở trang Portal Cart
    document.querySelectorAll('.qty-input-portal').forEach(input => {
        input.addEventListener('change', function() {
            const maCtgh = this.dataset.mactgh;
            const soLuong = this.value;

            updatePortalCartQuantity(maCtgh, soLuong);
        });
    });
});

/**
 * AJAX cập nhật số lượng ly nước trong giỏ hàng Portal
 */
function updatePortalCartQuantity(maCtgh, soLuong) {
    const formData = new FormData();
    formData.append('maCtgh', maCtgh);
    formData.append('soLuong', soLuong);

    fetch('/cart/update', {
        method: 'POST',
        body: new URLSearchParams(formData)
    })
        .then(res => res.text())
        .then(data => {
            if (data === 'SUCCESS') {
                showToast('success', 'Đã cập nhật số lượng giỏ hàng.');
                // Tải lại trang sau 1 giây để cập nhật lại tổng tiền hàng toàn trang
                setTimeout(() => { location.reload(); }, 1000);
            } else {
                showToast('error', 'Cập nhật số lượng thất bại!');
            }
        })
        .catch(err => console.error('Lỗi kết nối giỏ hàng:', err));
}

/**
 * AJAX thay đổi trạng thái tick chọn thanh toán (Selective Checkout)
 */
function toggleSelectCartItem(maCtgh, checkboxElement) {
    const isChecked = checkboxElement.checked ? "1" : "0";

    const formData = new FormData();
    formData.append('maCtgh', maCtgh);
    formData.append('chon', isChecked);

    fetch('/cart/toggle-select', {
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