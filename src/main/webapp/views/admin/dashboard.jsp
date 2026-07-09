<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Bảng Thống Kê Doanh Thu Hệ Thống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-light">
<div class="admin-wrapper">
    <!-- CỘT TRÁI: SIDEBAR DỌC -->
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <!-- CỘT PHẢI: TOÀN BỘ NỘI DUNG VÀ HEADER -->
    <div class="admin-content">
        <!-- Nhúng Header chuẩn trong phần nội dung chính, tuyệt đối không cho vào head -->
        <jsp:include page="/views/layout/header_admin.jsp" />

        <div class="p-4">
            <div class="bg-white border-bottom shadow-sm p-4 rounded-3 d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h3 class="fw-bold mb-1" style="color: var(--primary-color);">BẢNG ĐIỀU KHIỂN & DOANH THU</h3>
                    <p class="text-muted small mb-0">Theo dõi dòng tiền bán lẻ tại quầy POS, đơn đặt hàng online CRM và hiệu suất làm việc của nhân viên</p>
                </div>
                <form action="${pageContext.request.contextPath}/admin/dashboard" method="GET" class="d-flex flex-wrap gap-2 align-items-end">
                    <div>
                        <label class="form-label text-muted small fw-bold mb-1">Từ ngày</label>
                        <input type="date" name="tuNgay" class="form-control form-control-sm" value="${tuNgay}" required>
                    </div>
                    <div>
                        <label class="form-label text-muted small fw-bold mb-1">Đến ngày</label>
                        <input type="date" name="denNgay" class="form-control form-control-sm" value="${denNgay}" required>
                    </div>
                    <button type="submit" class="btn btn-primary-teapos px-3 btn-sm d-flex align-items-center gap-1">
                        <i class="bi bi-filter"></i> Lọc dữ liệu
                    </button>
                </form>
            </div>

            <!-- KPI Cards -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-sm-6 col-lg-3">
                    <div class="card card-teapos p-3 shadow-sm border border-light d-flex flex-row justify-content-between align-items-center bg-white" style="border-radius: 12px;">
                        <div class="kpi-info">
                            <h3 style="font-size: 13px; color: var(--text-muted); font-weight: 600; margin-bottom: 4px;">DOANH THU KỲ LỌC</h3>
                            <p class="text-success fw-bold fs-4 mb-0"><fmt:formatNumber value="${kpis.doanhThuKyLoc}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</p>
                        </div>
                        <div class="kpi-icon bg-success bg-opacity-10 text-success rounded p-2" style="font-size: 24px;"><i class="bi bi-currency-dollar"></i></div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-lg-3">
                    <div class="card card-teapos p-3 shadow-sm border border-light d-flex flex-row justify-content-between align-items-center bg-white" style="border-radius: 12px;">
                        <div class="kpi-info">
                            <h3 style="font-size: 13px; color: var(--text-muted); font-weight: 600; margin-bottom: 4px;">ĐƠN HÀNG THÀNH CÔNG</h3>
                            <p class="text-info fw-bold fs-4 mb-0">${kpis.donHangKyLoc} đơn</p>
                        </div>
                        <div class="kpi-icon bg-info bg-opacity-10 text-info rounded p-2" style="font-size: 24px;"><i class="bi bi-receipt"></i></div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-lg-3">
                    <div class="card card-teapos p-3 shadow-sm border border-light d-flex flex-row justify-content-between align-items-center bg-white" style="border-radius: 12px;">
                        <div class="kpi-info">
                            <h3 style="font-size: 13px; color: var(--text-muted); font-weight: 600; margin-bottom: 4px;">SẢN PHẨM ĐANG BÁN</h3>
                            <p class="text-warning fw-bold fs-4 mb-0">${kpis.monDangBan} món</p>
                        </div>
                        <div class="kpi-icon bg-warning bg-opacity-10 text-warning rounded p-2" style="font-size: 24px;"><i class="bi bi-cup-hot-fill"></i></div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-lg-3">
                    <div class="card card-teapos p-3 shadow-sm border border-light d-flex flex-row justify-content-between align-items-center bg-white" style="border-radius: 12px;">
                        <div class="kpi-info">
                            <h3 style="font-size: 13px; color: var(--text-muted); font-weight: 600; margin-bottom: 4px;">THÀNH VIÊN CRM</h3>
                            <p class="text-primary fw-bold fs-4 mb-0">${kpis.tongKhachHang} khách</p>
                        </div>
                        <div class="kpi-icon bg-primary bg-opacity-10 text-primary rounded p-2" style="font-size: 24px;"><i class="bi bi-people-fill"></i></div>
                    </div>
                </div>
            </div>

            <!-- Charts -->
            <div class="row g-4 mb-4">
                <div class="col-12 col-xl-8">
                    <div class="card card-teapos p-4 bg-white shadow-sm border border-light" style="border-radius: 12px;">
                        <h5 class="fw-bold mb-3 d-flex align-items-center gap-2"><i class="bi bi-graph-up-arrow text-success"></i> Tăng trưởng doanh số ngày (VNĐ)</h5>
                        <canvas id="dailyRevenueChart" style="max-height: 280px;"></canvas>
                    </div>
                </div>
                <div class="col-12 col-xl-4">
                    <div class="card card-teapos p-4 bg-white shadow-sm border border-light" style="border-radius: 12px;">
                        <h5 class="fw-bold mb-3 d-flex align-items-center gap-2"><i class="bi bi-pie-chart-fill text-info"></i> Tỷ trọng danh mục</h5>
                        <canvas id="categoryRevenueChart" style="max-height: 280px;"></canvas>
                    </div>
                </div>
            </div>

            <!-- Lists Top -->
            <div class="row g-4">
                <div class="col-12 col-lg-7">
                    <div class="card card-teapos p-4 bg-white shadow-sm" style="border-radius: 12px;">
                        <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2"><i class="bi bi-trophy-fill text-warning"></i> Top 10 sản phẩm bán chạy nhất</h5>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                <tr class="table-light">
                                    <th style="width: 60px;">STT</th>
                                    <th>Tên Sản Phẩm</th>
                                    <th>Danh Mục</th>
                                    <th class="text-center">Sản lượng</th>
                                    <th class="text-end">Doanh thu</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty topSanPhams}">
                                        <c:forEach var="item" items="${topSanPhams}" varStatus="loop">
                                            <tr>
                                                <td><strong>${loop.index + 1}</strong></td>
                                                <td><strong><c:out value="${item.tenSp}"/></strong></td>
                                                <td><span class="badge bg-light text-success border border-success px-2 py-1">${item.tenDm}</span></td>
                                                <td class="text-center fw-bold text-success">${item.tongSoLuongBan} ly</td>
                                                <td class="text-end fw-bold"><fmt:formatNumber value="${item.doanhThuMangLai}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="5" class="text-center text-muted py-4">Chưa phát sinh dữ liệu bán hàng!</td></tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-lg-5">
                    <div class="card card-teapos p-4 bg-white shadow-sm" style="border-radius: 12px;">
                        <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2"><i class="bi bi-star-fill text-primary"></i> Xếp hạng nhân viên xuất sắc</h5>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                <tr class="table-light">
                                    <th>Nhân viên</th>
                                    <th class="text-center">Đơn hàng</th>
                                    <th class="text-end">Doanh thu</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty topNhanViens}">
                                        <c:forEach var="item" items="${topNhanViens}">
                                            <tr>
                                                <td><div class="fw-bold"><c:out value="${item.hoTen}"/></div><small class="text-muted">Mã: ${item.maNv}</small></td>
                                                <td class="text-center fw-bold">${item.soDonHoanThanh} đơn</td>
                                                <td class="text-end text-success fw-bold"><fmt:formatNumber value="${item.doanhThuTaoRa}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="3" class="text-center text-muted py-4">Không có nhân viên thực hiện giao dịch!</td></tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const dailyCtx = document.getElementById('dailyRevenueChart').getContext('2d');
        const dailyLabels = [];
        const dailyData = [];
        <c:forEach var="item" items="${doanhThuNgay}">
        dailyLabels.push('${item.ngay}');
        dailyData.push(${item.tongDoanhThu});
        </c:forEach>
        new Chart(dailyCtx, {
            type: 'line',
            data: {
                labels: dailyLabels,
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: dailyData,
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.08)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.25,
                    pointBackgroundColor: '#10b981',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { callback: function(value) { return value.toLocaleString('vi-VN') + ' đ'; } } } }
            }
        });

        const catCtx = document.getElementById('categoryRevenueChart').getContext('2d');
        const catLabels = [];
        const catData = [];
        <c:forEach var="item" items="${doanhThuDanhMuc}">
        catLabels.push('<c:out value="${item.tenDm}"/>');
        catData.push(${item.tongDoanhThu});
        </c:forEach>
        new Chart(catCtx, {
            type: 'doughnut',
            data: {
                labels: catLabels,
                datasets: [{
                    data: catData,
                    backgroundColor: ['#10b981', '#06b6d4', '#f59e0b', '#ef4444', '#6366f1', '#a855f7', '#ec4899'],
                    borderWidth: 2,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { boxWidth: 12, padding: 15 } } }
            }
        });
    });
</script>
</body>
</html>