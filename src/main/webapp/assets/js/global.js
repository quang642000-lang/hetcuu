/**
 * =========================================================================
 * TEA POS SYSTEM - COMPREHENSIVE GLOBAL JAVASCRIPT PARTNER (v8.5)
 * =========================================================================
 */

function toggleSidebar() {
    const sidebar = document.getElementById('adminSidebar');
    const overlay = document.getElementById('sidebarOverlay');
    if (sidebar && overlay) {
        sidebar.classList.toggle('show');
        overlay.classList.toggle('show');
        if (sidebar.classList.contains('show')) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
    }
}

// Global SweetAlert Toast helper
function showToast(type, message) {
    if (typeof Swal !== 'undefined') {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer)
                toast.addEventListener('mouseleave', Swal.resumeTimer)
            }
        });
        Toast.fire({
            icon: type,
            title: message
        });
    } else {
        alert(message);
    }
}

// Handle expansion toggles for mobile cards
document.addEventListener("DOMContentLoaded", function() {
    document.addEventListener("click", function(e) {
        const chevron = e.target.closest(".acm-chevron-btn");
        if (chevron) {
            const card = chevron.closest(".acm-mobile-card");
            if (card) {
                const isExpanded = card.classList.contains("expanded");
                if (isExpanded) {
                    card.classList.remove("expanded");
                    chevron.innerHTML = '<i class="bi bi-chevron-down"></i>';
                } else {
                    card.classList.add("expanded");
                    chevron.innerHTML = '<i class="bi bi-chevron-up"></i>';
                }
            }
            return;
        }

        // Toggle when clicking header too, if not a button
        const cardHeader = e.target.closest(".acm-card-header");
        if (cardHeader && !e.target.closest("button") && !e.target.closest("a") && !e.target.closest(".acm-chevron-btn")) {
            const card = cardHeader.closest(".acm-mobile-card");
            if (card) {
                const btn = card.querySelector(".acm-chevron-btn");
                const isExpanded = card.classList.contains("expanded");
                if (isExpanded) {
                    card.classList.remove("expanded");
                    if (btn) btn.innerHTML = '<i class="bi bi-chevron-down"></i>';
                } else {
                    card.classList.add("expanded");
                    if (btn) btn.innerHTML = '<i class="bi bi-chevron-up"></i>';
                }
            }
        }
    });
});
