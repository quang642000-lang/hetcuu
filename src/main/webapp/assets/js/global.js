/**
 * =========================================================================
 * TEA POS SYSTEM - CORE UTILITIES, SWEETALERT & AUTO-MORPHING ACCORDION
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
 * AUTOMATIC ADAPTIVE MORPHING RESPONSIVE TABLE ENGINE (ACM v6)
 * Evaluates tables dynamically based on window width and actual overflow.
 * Synchronized perfectly across all Admin panels (Voucher, Products, Audit Log, etc.)
 * =========================================================================
 */

function optimizeAdminTables() {
    const tables = document.querySelectorAll('.admin-table, .table-audit');

    tables.forEach(table => {
        const container = table.closest('.admin-table-container, .table-responsive');
        if (!container) return;

        // Remove styling temporarily to measure the actual flat layout width
        table.classList.remove('table-collapsed-cards');
        container.classList.remove('has-collapsed-cards');

        // Dynamic detection of layout limitations or device viewport boundaries (< 1200px)
        const isMobile = window.innerWidth <= 1200;
        const doesOverflow = table.scrollWidth > container.clientWidth;
        const allRows = table.querySelectorAll('tbody tr');

        if (isMobile || doesOverflow) {
            table.classList.add('table-collapsed-cards');
            container.classList.add('has-collapsed-cards');

            // Build the dynamic data-labels using table header text
            const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.innerText.trim().replace(/:/g, ''));

            allRows.forEach(row => {
                // Keep the row's display state synchronized with JSTL/Pagination searches
                const isHiddenByJSTL = row.style.display === 'none';
                if (isHiddenByJSTL) {
                    row.classList.add('pos-row-hidden');
                } else {
                    row.classList.remove('pos-row-hidden');
                }

                // If the row is an empty placeholder, treat it gracefully
                if (row.cells.length === 1 && row.cells[0].colSpan > 1) {
                    row.classList.add('empty-placeholder-row');
                    return;
                }

                // Safe binding of gập mở Accordion Card Click listeners
                if (!row.dataset.accordionBound) {
                    row.dataset.accordionBound = "true";
                    row.addEventListener('click', function(e) {
                        // Bypass click event if targeting interactive inputs, links, buttons
                        if (e.target.closest('a, button, input, select, textarea, .btn')) {
                            return;
                        }

                        // Close other expanded cards to focus exclusively on this card (Accordion behavior)
                        allRows.forEach(r => {
                            if (r !== this && r.classList.contains('expanded')) {
                                r.classList.remove('expanded');
                                const otherChevron = r.querySelector('.row-chevron i');
                                if (otherChevron) otherChevron.className = 'bi bi-chevron-down';
                            }
                        });

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

                // Distribute column elements cleanly between Header, Details and Pinned Actions
                Array.from(row.cells).forEach((cell, idx) => {
                    const label = headers[idx] || '';
                    if (label && !cell.dataset.labelApplied) {
                        cell.setAttribute('data-label', label);
                        cell.dataset.labelApplied = "true";
                    }

                    // Specific check for chevron cell to avoid adding details styling
                    if (cell.classList.contains('row-chevron')) {
                        return;
                    }

                    // Identify if cell is strictly the edit/delete action row
                    const isActionCol = idx === row.cells.length - 1 ||
                        cell.classList.contains('actions-col') ||
                        cell.querySelector('.btn-action-edit, .btn-action-delete, .btn-action-info, .btn-action-warning') ||
                        (idx > 5 && cell.querySelector('a, button, .d-flex'));

                    const isCoreIdentityCol = idx < 4; // STT, ID, Image, Name
                    const isHeavyContent = label.includes('Đối soát') || label.includes('Biến động') || label.includes('Dữ liệu') || label.includes('Mô tả');

                    cell.classList.remove('card-header-col', 'card-action-col', 'card-detail-col', 'card-detail-col-full');

                    if (isCoreIdentityCol) {
                        cell.classList.add('card-header-col');
                        if (idx === 0) cell.classList.add('row-stt');
                    } else if (isActionCol) {
                        cell.classList.add('card-action-col');
                    } else {
                        if (isHeavyContent) {
                            cell.classList.add('card-detail-col-full');
                        } else {
                            cell.classList.add('card-detail-col');
                        }
                    }
                });

                // Inject the responsive interactive chevron trigger securely if missing
                if (!row.querySelector('.row-chevron')) {
                    const chevronTd = document.createElement('td');
                    chevronTd.className = 'row-chevron';
                    chevronTd.innerHTML = '<i class="bi bi-chevron-down"></i>';
                    row.appendChild(chevronTd);
                }
            });
        } else {
            // Restore regular table state when browser scales to desktop width
            table.classList.remove('table-collapsed-cards');
            container.classList.remove('has-collapsed-cards');

            allRows.forEach(row => {
                row.classList.remove('expanded');
                row.classList.remove('pos-row-hidden');
                const chevron = row.querySelector('.row-chevron');
                if (chevron) chevron.remove();

                Array.from(row.cells).forEach(cell => {
                    cell.classList.remove('card-header-col', 'card-action-col', 'card-detail-col', 'card-detail-col-full', 'row-stt');
                });
            });
        }
    });
}

// 4. Initial execution on page load
document.addEventListener("DOMContentLoaded", () => {
    optimizeAdminTables();
    window.addEventListener("resize", optimizeAdminTables);

    // MUTATION OBSERVER: Automatically re-evaluates tables when rows are dynamically
    // added, filtered, or paginated by client-side/server-side search scripts!
    const tableBodies = document.querySelectorAll('.admin-table tbody, .table-audit tbody');
    tableBodies.forEach(tbody => {
        const observer = new MutationObserver(() => {
            optimizeAdminTables();
        });
        observer.observe(tbody, { childList: true, subtree: true, attributes: true, attributeFilter: ['style'] });
    });
});
