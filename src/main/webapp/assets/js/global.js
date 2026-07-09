/**
 * =========================================================================
 * TEA POS SYSTEM - CORE UTILITIES & SWEETALERT INTEGRATIONS
 * =========================================================================
 */

// 1. Cấu hình Toast popup mượt mà từ SweetAlert2
const SweetToast = Swal.mixin({
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer);
        toast.addEventListener('mouseleave', Swal.resumeTimer);
    }
});

/**
 * Hiển thị Toast thông báo nhanh góc màn hình
 * @param {string} icon 'success' | 'error' | 'warning' | 'info'
 * @param {string} message
 */
function showToast(icon, message) {
    SweetToast.fire({
        icon: icon,
        title: message
    });
}

/**
 * Định dạng số nguyên sang chuỗi tiền tệ VNĐ (Ví dụ: 35000 -> 35.000 đ)
 * @param {number} amount
 * @returns {string}
 */
function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

/**
 * Định dạng SĐT thô sang SĐT Việt Nam dễ nhìn
 * @param {string} phone
 * @returns {string}
 */
function formatPhone(phone) {
    const cleaned = ('' + phone).replace(/\D/g, '');
    const match = cleaned.match(/^(\d{4})(\d{3})(\d{3})$/);
    if (match) {
        return match[7] + ' ' + match[8] + ' ' + match[9];
    }
    return phone;
}
