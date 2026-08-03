/**
 * =========================================================================
 * TEA POS SYSTEM - ACM ENGINE v7.0 (BULLETPROOF TABLE ACCORDION)
 * Designed by CodeDevSquad 2026. Resolved infinite observer recursion loops.
 * =========================================================================
 */

// Safe lazy-initialization of SweetAlert Toast
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

function showToast(icon, message) {
    const toast = getSweetToast();
    if (toast) {
        toast.fire({ icon: icon, title: message });
    } else {
        console.log(`[TEA POS TOAST - ${icon.toUpperCase()}]: ${message}`);
    }
}

function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
}

function formatPhone(phone) {
    if (!phone) return "";
    const cleaned = ('' + phone).replace(/\D/g, '');
    const match = cleaned.match(/^(\d{4})(\d{3})(\d{3})$/);
    if (match) return match[1] + ' ' + match[2] + ' ' + match[3];
    return phone;
}

// Global flag to prevent MutationObserver recursive cascades
let isTableOptimizing = false;

/**
 * Core Adaptive Column Morphing (ACM v7.0) Table Engine
 */
function optimizeAdminTables() {
    if (isTableOptimizing) return;

    const tables = document.querySelectorAll('.admin-table, .table-audit');
    if (tables.length === 0) return;

    isTableOptimizing = true;

    // Check viewport widths
    const isMobile = window.innerWidth <= 1200;

    tables.forEach(table => {
        const container = table.closest('.admin-table-container, .table-responsive');
        if (!container) return;

        // Measure naturally by temporarily removing classes
        table.classList.remove('table-collapsed-cards');
        container.classList.remove('has-collapsed-cards');

        const doesOverflow = table.scrollWidth > container.clientWidth;

        if (isMobile || doesOverflow) {
            table.classList.add('table-collapsed-cards');
            container.classList.add('has-collapsed-cards');

            // Build index of column headers (sanitized)
            const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.innerText.trim().replace(/:/g, ''));
            const allRows = table.querySelectorAll('tbody tr');

            // Tailor columns based on current page URL/ID
            const pageId = table.id || window.location.pathname;

            allRows.forEach(row => {
                // Ignore empty list placeholders
                if (row.cells.length === 1 && row.cells[0].colSpan > 1) {
                    row.classList.add('empty-placeholder-row');
                    return;
                }

                // Track style visibility to match JSTL/Pagination display status
                const isHidden = row.style.display === 'none';
                if (isHidden) {
                    row.classList.add('pos-row-hidden');
                } else {
                    row.classList.remove('pos-row-hidden');
                }

                // Bind touch Accordion Row event listener once
                if (!row.dataset.accordionBound) {
                    row.dataset.accordionBound = "true";
                    row.addEventListener('click', function(e) {
                        if (e.target.closest('a, button, input, select, textarea, .btn')) {
                            return; // Bypass interactive controls
                        }

                        // Accordion: close all other active cards
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
                            chevron.className = this.classList.contains('expanded') ? 'bi bi-chevron-up' : 'bi bi-chevron-down';
                        }
                    });
                }

                // Classify individual cell nodes based on Page Rules
                Array.from(row.cells).forEach((cell, idx) => {
                    const label = headers[idx] || '';
                    if (label && !cell.dataset.labelApplied) {
                        cell.setAttribute('data-label', label);
                        cell.dataset.labelApplied = "true";
                    }

                    if (cell.classList.contains('row-chevron')) return; // Avoid styling chevron cell

                    // Clear older classes
                    cell.className = cell.className.replace(/\b(card-header-col|card-detail-col|card-detail-col-full|card-action-col|row-stt|row-id|row-img|row-name|row-code-badge|row-status-main)\b/g, '').trim();

                    // Universal Actions matcher
                    const isActionCol = idx === row.cells.length - 1 ||
                        cell.querySelector('.btn-action-edit, .btn-action-delete, .btn-action-warning, .btn-action-info') ||
                        (idx > 4 && cell.querySelector('a, button'));

                    // PAGE SPECIFIC RULES
                    if (pageId.includes('voucher') || pageId.includes('KhuyenMai')) {
                        // Voucher structure:
                        // Core Header: STT (0), Mã Code (2), Tên CT (3), Trạng Thái (10 - mapped to top)
                        // Actions: 11
                        // Details: others
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 2) {
                            cell.classList.add('card-header-col', 'row-code-badge');
                        } else if (idx === 3) {
                            cell.classList.add('card-header-col', 'row-name');
                        } else if (idx === 10) {
                            cell.classList.add('card-header-col', 'row-status-main');
                        } else if (isActionCol) {
                            cell.classList.add('card-action-col');
                        } else {
                            const isHeavy = label.includes('Mô tả') || label.includes('Điều kiện');
                            cell.classList.add(isHeavy ? 'card-detail-col-full' : 'card-detail-col');
                        }
                    }
                    else if (pageId.includes('san_pham') || pageId.includes('sanpham')) {
                        // Product structure:
                        // Core Header: STT (0), Mã SP (1), Hình Ảnh (2), Tên Đồ Uống (3), Trạng Thái (8)
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 1) {
                            cell.classList.add('card-header-col', 'row-id');
                        } else if (idx === 2) {
                            cell.classList.add('card-header-col', 'row-img');
                        } else if (idx === 3) {
                            cell.classList.add('card-header-col', 'row-name');
                        } else if (idx === 8) {
                            cell.classList.add('card-header-col', 'row-status-main');
                        } else if (isActionCol) {
                            cell.classList.add('card-action-col');
                        } else {
                            cell.classList.add('card-detail-col');
                        }
                    }
                    else if (pageId.includes('khach_hang') || pageId.includes('khachhang')) {
                        // Customer CRM:
                        // Core Header: STT (0), Mã KH (1), Tên (2), Trạng Thái (7)
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 1) {
                            cell.classList.add('card-header-col', 'row-id');
                        } else if (idx === 2) {
                            cell.classList.add('card-header-col', 'row-name'); // Contains avatar + name inline
                        } else if (idx === 7) {
                            cell.classList.add('card-header-col', 'row-status-main');
                        } else if (isActionCol) {
                            cell.classList.add('card-action-col');
                        } else {
                            cell.classList.add('card-detail-col');
                        }
                    }
                    else if (pageId.includes('hoa_don') || pageId.includes('hoadon')) {
                        // Invoice structure:
                        // Core Header: STT (0), Mã HD (1), Khách (2), Thành Tiền (6), Trạng Thái Đơn (8)
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 1) {
                            cell.classList.add('card-header-col', 'row-id');
                        } else if (idx === 2) {
                            cell.classList.add('card-header-col', 'row-name');
                        } else if (idx === 6) {
                            cell.classList.add('card-header-col', 'row-stt'); // Show amount cleanly
                        } else if (idx === 8) {
                            cell.classList.add('card-header-col', 'row-status-main');
                        } else if (isActionCol) {
                            cell.classList.add('card-action-col');
                        } else {
                            cell.classList.add('card-detail-col');
                        }
                    }
                    else if (pageId.includes('nhat_ky') || pageId.includes('auditlog') || pageId.includes('nhatky')) {
                        // Audit Log:
                        // Core Header: Mã Log (0), Thời Gian (1), Nhân Viên (2), Hành Động (3)
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-id');
                        } else if (idx === 1) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 2) {
                            cell.classList.add('card-header-col', 'row-name');
                        } else if (idx === 3) {
                            cell.classList.add('card-header-col', 'row-status-main');
                        } else {
                            cell.classList.add('card-detail-col-full'); // Span full for JSON compare boxes
                        }
                    }
                    else {
                        // Default Fallback mapping
                        if (idx === 0) {
                            cell.classList.add('card-header-col', 'row-stt');
                        } else if (idx === 1) {
                            cell.classList.add('card-header-col', 'row-id');
                        } else if (idx < 4) {
                            cell.classList.add('card-header-col', 'row-name');
                        } else if (isActionCol) {
                            cell.classList.add('card-action-col');
                        } else {
                            cell.classList.add('card-detail-col');
                        }
                    }
                });

                // Inject the responsive touch floating chevron
                if (!row.querySelector('.row-chevron')) {
                    const chevronTd = document.createElement('td');
                    chevronTd.className = 'row-chevron';
                    chevronTd.innerHTML = '<i class="bi bi-chevron-down"></i>';
                    row.appendChild(chevronTd);
                }
            });
        } else {
            // Restore regular flat table state on desktop/un-collapsed width
            table.classList.remove('table-collapsed-cards');
            container.classList.remove('has-collapsed-cards');
            const allRows = table.querySelectorAll('tbody tr');
            allRows.forEach(row => {
                row.classList.remove('expanded');
                row.classList.remove('pos-row-hidden');
                const chevron = row.querySelector('.row-chevron');
                if (chevron) chevron.remove();
                Array.from(row.cells).forEach(cell => {
                    cell.className = cell.className.replace(/\b(card-header-col|card-detail-col|card-detail-col-full|card-action-col|row-stt|row-id|row-img|row-name|row-code-badge|row-status-main)\b/g, '').trim();
                });
            });
        }
    });

    // Clear and restore observer safety lock in next task event loop (macro-task)
    setTimeout(() => {
        isTableOptimizing = false;
    }, 50);
}

// 4. Initial execution on page load
document.addEventListener("DOMContentLoaded", () => {
    optimizeAdminTables();
    window.addEventListener("resize", optimizeAdminTables);

    // Safe Dynamic Mutations Monitoring (for search logs and pagination events)
    const tableBodies = document.querySelectorAll('.admin-table tbody, .table-audit tbody');
    tableBodies.forEach(tbody => {
        const observer = new MutationObserver((mutations) => {
            if (isTableOptimizing) return;
            optimizeAdminTables();
        });
        observer.observe(tbody, { childList: true, subtree: true, attributes: true, attributeFilter: ['style'] });
    });
});
