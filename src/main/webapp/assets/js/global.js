/**
 * =========================================================================
 * TEA POS SYSTEM - CORE UTILITIES & ADAPTIVE ACCORDION MATRIX ENGINE (ACM v5)
 * Synchronized perfectly across all Admin panels (Voucher, Products, Audit Log, etc.)
 * =========================================================================
 */

// Safe lazy-initialization of SweetToast to prevent "Swal is not defined" reference errors
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

/**
 * =========================================================================
 * ACM ENGINE - ADAPTIVE COLUMN MORPHING & EXPANDABLE ACCORDION ROW
 * =========================================================================
 */
function optimizeAdminTables() {
    const tables = document.querySelectorAll('.admin-table, .table-audit');

    tables.forEach(table => {
        const container = table.closest('.admin-table-container, .table-responsive');
        if (!container) return;

        // Temporarily reset styles to measure the true layout overflow
        table.classList.remove('table-collapsed-cards');
        container.classList.remove('has-collapsed-cards');

        const isMobile = window.innerWidth <= 768;
        const doesOverflow = table.scrollWidth > container.clientWidth;

        if (isMobile || doesOverflow) {
            table.classList.add('table-collapsed-cards');
            container.classList.add('has-collapsed-cards');

            // Build dynamic data-labels using table header text
            const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.innerText.trim().replace(/:/g, ''));
            const rows = table.querySelectorAll('tbody tr');

            rows.forEach(row => {
                // If it's a placeholder row (no real data)
                if (row.cells.length === 1 && row.cells[0].colSpan > 1) {
                    row.classList.add('empty-placeholder-row');
                    return;
                }

                // Bind click listener for expandable accordion rows
                if (!row.dataset.accordionBound) {
                    row.dataset.accordionBound = "true";
                    row.addEventListener('click', function(e) {
                        // Avoid triggering toggle if clicking form fields or actions
                        if (e.target.closest('a, button, input, select, textarea, .btn')) {
                            return;
                        }

                        this.classList.toggle('expanded');
                        const chevron = this.querySelector('.row-chevron i');
                        if (chevron) {
                            if (this.classList.contains('expanded')) {
                                chevron.className = 'bi bi-chevron-up';
                            } else {
                                chevron.className = 'bi bi-chevron-down';
                            }
                        }
                    });
                }

                // Distribute columns precisely
                Array.from(row.cells).forEach((cell, idx) => {
                    const label = headers[idx] || '';
                    if (label && !cell.dataset.labelApplied) {
                        cell.setAttribute('data-label', label);
                        cell.dataset.labelApplied = "true";
                    }

                    // FIX CHÍ MẠNG: Xác định chính xác cột Hành Động thực sự (Actions)
                    // Không lấy nhầm cột Đơn giá (Giá S, Giá L) mặc dù chúng có class text-end
                    const isActionCol = idx === row.cells.length - 1 ||
                        cell.classList.contains('actions-col') ||
                        cell.querySelector('.btn-action-edit, .btn-action-delete, .btn-action-info, .btn-action-warning') ||
                        (idx > 5 && cell.querySelector('a, button, .d-flex'));

                    // Chỉ cho phép các cột nhận dạng cốt lõi (STT, Mã, Ảnh, Tên) nằm ở Header của Card
                    const isCoreIdentityCol = idx < 4; // STT, Mã, Ảnh, Tên

                    // Reset classes to prevent overlap mismatch
                    cell.classList.remove('card-header-col', 'card-action-col', 'card-detail-col');

                    if (isCoreIdentityCol) {
                        cell.classList.add('card-header-col');
                    } else if (isActionCol) {
                        cell.classList.add('card-action-col');
                    } else {
                        cell.classList.add('card-detail-col');
                    }
                });

                // Inject chevron handle if missing
                if (!row.querySelector('.row-chevron')) {
                    const chevronTd = document.createElement('td');
                    chevronTd.className = 'row-chevron';
                    chevronTd.innerHTML = '<i class="bi bi-chevron-down"></i>';
                    row.appendChild(chevronTd);
                }
            });
        } else {
            // Restore regular table state when layout fits completely
            table.classList.remove('table-collapsed-cards');
            container.classList.remove('has-collapsed-cards');
            const rows = table.querySelectorAll('tbody tr');
            rows.forEach(row => {
                row.classList.remove('expanded');
                const chevron = row.querySelector('.row-chevron');
                if (chevron) chevron.remove();
                Array.from(row.cells).forEach(cell => {
                    cell.classList.remove('card-header-col', 'card-action-col', 'card-detail-col');
                });
            });
        }
    });
}

// Initial execute and handlers
document.addEventListener("DOMContentLoaded", () => {
    optimizeAdminTables();
    window.addEventListener("resize", optimizeAdminTables);

    // Mutation Observer to support dynamic/client-side searching and pagination without breaking
    const tableBodies = document.querySelectorAll('.admin-table tbody, .table-audit tbody');
    tableBodies.forEach(tbody => {
        const observer = new MutationObserver(() => {
            optimizeAdminTables();
        });
        observer.observe(tbody, { childList: true, subtree: true, attributes: true, attributeFilter: ['style'] });
    });
});
