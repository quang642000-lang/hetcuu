/**
 * =========================================================================
 * TEA POS SYSTEM - CORE UTILITIES & SWEETALERT INTEGRATIONS
 * =========================================================================
 */

// Safe lazy-initialization of SweetToast to prevent "Swal is not defined" reference errors
// when global.js is imported on pages without SweetAlert2 or loaded before it.
function getSweetToast() {
    if (typeof Swal !== 'undefined') {
        return Swal.mixin({
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
    }
    return null;
}

/**
 * Hiển thị Toast thông báo nhanh góc màn hình
 * @param {string} icon 'success' | 'error' | 'warning' | 'info'
 * @param {string} message
 */
function showToast(icon, message) {
    const toast = getSweetToast();
    if (toast) {
        toast.fire({
            icon: icon,
            title: message
        });
    } else {
        // Fallback to safe console logging if SweetAlert is not loaded
        console.log(`[TEA POS TOAST - ${icon.toUpperCase()}]: ${message}`);
    }
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
    if (!phone) return "";
    const cleaned = ('' + phone).replace(/\D/g, '');
    const match = cleaned.match(/^(\d{4})(\d{3})(\d{3})$/);
    if (match) {
        return match[1] + ' ' + match[2] + ' ' + match[3];
    }
    return phone;
}
