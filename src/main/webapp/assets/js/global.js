/**
 * =========================================================================
 * TEA POS SYSTEM - HIGH-PERFORMANCE RESPONSIVE & ADAPTIVE COMPANION (USTS v7.5)
 * =========================================================================
 */

document.addEventListener("DOMContentLoaded", function() {
    let activeObserver = null;
    let isTableOptimizing = false;

    // Core AMT Responsive Orchestrator
    function optimizeAdminTables() {
        if (isTableOptimizing) return;
        isTableOptimizing = true;

        const tables = document.querySelectorAll(".admin-table-container table, .audit-card table");
        const isMobile = window.innerWidth < 992;

        tables.forEach(table => {
            // Apply card styling structure if on mobile view
            if (isMobile) {
                table.classList.add("table-collapsed-cards");
            } else {
                table.classList.remove("table-collapsed-cards");
                // Reset expanded rows on resizing back to desktop
                table.querySelectorAll("tbody tr.expanded").forEach(r => r.classList.remove("expanded"));
                table.querySelectorAll(".acm-chevron-btn, .acm-card-header, .acm-card-details, .acm-card-actions").forEach(el => el.remove());
                table.querySelectorAll("td").forEach(td => td.style.display = "");
                isTableOptimizing = false;
                return;
            }

            const headers = Array.from(table.querySelectorAll("thead th")).map(th => th.innerText.trim());
            const rows = table.querySelectorAll("tbody tr");

            rows.forEach(row => {
                // Prevent duplicate elements from being injected
                if (row.querySelector(".acm-chevron-btn")) return;

                // Sync the pagination hidden state
                syncPaginationHiddenState(row);

                // Build a modern, semantic grid layout
                let headerContent = document.createElement("div");
                headerContent.className = "acm-card-header";

                let detailsContent = document.createElement("div");
                detailsContent.className = "acm-card-details";

                let actionsContent = document.createElement("div");
                actionsContent.className = "acm-card-actions";

                let chevronBtn = document.createElement("div");
                chevronBtn.className = "acm-chevron-btn";
                chevronBtn.innerHTML = '<i class="bi bi-chevron-down"></i>';

                // Categorize each table cell into Header, Detail, or Footer
                Array.from(row.cells).forEach((cell, idx) => {
                    const headerName = headers[idx] || "";

                    // Identify if this cell represents an Action button col
                    const isActionCol = cell.classList.contains("text-end") && (
                        cell.querySelector("a, button, .btn") || idx === row.cells.length - 1
                    );

                    // Map semantic structures based on columns
                    if (idx === 0) {
                        // STT
                        let clone = cell.cloneNode(true);
                        clone.className = "row-stt";
                        headerContent.appendChild(clone);
                        cell.style.display = "none";
                    } else if (headerName.toUpperCase().includes("MÃ") || headerName.toUpperCase().includes("CODE")) {
                        // IDs
                        let clone = cell.cloneNode(true);
                        clone.className = "row-id";
                        headerContent.appendChild(clone);
                        cell.style.display = "none";
                    } else if (cell.querySelector("img")) {
                        // Images
                        let clone = cell.querySelector("img").cloneNode(true);
                        clone.className = "row-img";
                        headerContent.appendChild(clone);
                        cell.style.display = "none";
                    } else if (headerName.toUpperCase().includes("TÊN") || headerName.toUpperCase().includes("NHÂN VIÊN") || headerName.toUpperCase().includes("KHÁCH HÀNG")) {
                        // Primary target names
                        let clone = cell.cloneNode(true);
                        clone.className = "row-name";
                        headerContent.appendChild(clone);
                        cell.style.display = "none";
                    } else if (isActionCol) {
                        // Render all actions to footer
                        Array.from(cell.children).forEach(btn => {
                            let clone = btn.cloneNode(true);
                            actionsContent.appendChild(clone);
                        });
                        cell.style.display = "none";
                    } else {
                        // All other columns go to details
                        let itemBox = document.createElement("div");
                        itemBox.className = "detail-item-box";

                        // Check if it's heavy content like Audit variables
                        if (headerName.toUpperCase().includes("ĐỐI SOÁT") || headerName.toUpperCase().includes("BIẾN ĐỘNG") || headerName.toUpperCase().includes("CHI TIẾT") || headerName.toUpperCase().includes("MÔ TẢ")) {
                            itemBox.classList.add("detail-col-full");
                        }

                        let labelSpan = document.createElement("span");
                        labelSpan.className = "detail-label";
                        labelSpan.innerText = headerName;

                        let valueSpan = document.createElement("span");
                        valueSpan.className = "detail-value";
                        valueSpan.innerHTML = cell.innerHTML;

                        itemBox.appendChild(labelSpan);
                        itemBox.appendChild(valueSpan);
                        detailsContent.appendChild(itemBox);
                        cell.style.display = "none";
                    }
                });

                // Assemble the card layout
                row.appendChild(chevronBtn);
                row.appendChild(headerContent);
                row.appendChild(detailsContent);
                row.appendChild(actionsContent);

                // Setup click toggle events
                row.addEventListener("click", function(e) {
                    if (e.target.closest("a") || e.target.closest("button") || e.target.closest(".acm-card-actions")) {
                        return; // Prevent click propagation from buttons
                    }

                    const isExpanded = row.classList.contains("expanded");

                    // Close any other expanded rows on the current table (Accordion)
                    table.querySelectorAll("tbody tr.expanded").forEach(r => {
                        if (r !== row) {
                            r.classList.remove("expanded");
                            const icon = r.querySelector(".acm-chevron-btn i");
                            if (icon) icon.className = "bi bi-chevron-down";
                        }
                    });

                    // Toggle self
                    if (isExpanded) {
                        row.classList.remove("expanded");
                        chevronBtn.innerHTML = '<i class="bi bi-chevron-down"></i>';
                    } else {
                        row.classList.add("expanded");
                        chevronBtn.innerHTML = '<i class="bi bi-chevron-up"></i>';
                    }
                });
            });
        });

        isTableOptimizing = false;
    }

    // Support pagination hidden syncing dynamically
    function syncPaginationHiddenState(row) {
        // If hidden inline or has display: none set, add pos-row-hidden class
        const currentStyle = row.style.display;
        if (currentStyle === "none" || row.classList.contains("d-none")) {
            row.classList.add("pos-row-hidden");
        } else {
            row.classList.remove("pos-row-hidden");
        }
    }

    // Set up high-performance MutationObserver at tbody level to guard against loops
    function initAcmObserver() {
        const tbodies = document.querySelectorAll(".admin-table-container tbody, .audit-card tbody");

        tbodies.forEach(tbody => {
            const observer = new MutationObserver(function(mutations) {
                let paginationChanged = false;

                mutations.forEach(mutation => {
                    // Check if children (rows) or style attributes changed
                    if (mutation.type === "childList" || mutation.type === "attributes") {
                        paginationChanged = true;
                    }
                });

                if (paginationChanged && !isTableOptimizing) {
                    // Temporarily disconnect to prevent infinite loops
                    observer.disconnect();

                    // Re-run syncing on all rows to ensure JSTL pagination is strictly respected
                    tbody.querySelectorAll("tr").forEach(row => {
                        syncPaginationHiddenState(row);
                    });

                    optimizeAdminTables();

                    // Re-connect safely
                    observer.observe(tbody, {
                        childList: true,
                        subtree: true,
                        attributes: true,
                        attributeFilter: ["style", "class"]
                    });
                }
            });

            observer.observe(tbody, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ["style", "class"]
            });
        });
    }

    // Execute setup
    optimizeAdminTables();
    initAcmObserver();

    // Trigger optimized redraw on resize
    window.addEventListener("resize", optimizeAdminTables);
});
