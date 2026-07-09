<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>TEA POS - Bảng Thống Kê Doanh Thu Hệ Thống</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="/views/layout/header_admin.jsp" />
    <link href="${pageContext.request.contextPath}/assets/css/global.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/admin.css" rel="stylesheet">
    <!-- Nạp thư viện biểu đồ tĩnh/động Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="admin-wrapper">
    <!-- Sidebar bên trái -->
    <jsp:include page="/views/layout/sidebar_admin.jsp" />

    <!-- Khối nội dung chính bên phải -->
    <div class="admin-content">
        <!-- Banner đầu trang kèm bộ lọc thời gian -->
        <div class="p-4 bg-white border-bottom shadow-sm d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div>
                <h3 class="fw-bold text-dark mb-1" style="color: var(--primary-color) !important;">BẢNG ĐIỀU KHIỂN & SỐ LIỆU DOANH THU</h3>
                <p class="text-muted small mb-0">Theo dõi dòng tiền bán lẻ tại quầy POS, đơn đặt hàng online CRM và hiệu suất làm việc của nhân viên</p>
            </div>

            <!-- Bộ lọc thời gian thống kê -->
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

        <!-- 4 THẺ CHỈ SỐ KPI CHÍNH (DYNAMIC KPI CARDS) -->
        <div class="kpi-container px-4 mt-4">
            <!-- 1. Doanh thu kỳ lọc -->
            <div class="kpi-card bg-white shadow-sm border border-light">
                <div class="kpi-info">
                    <h3>DOANH THU KỲ LỌC</h3>
                    <p class="text-success"><fmt:formatNumber value="${kpis.doanhThuKyLoc}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ</p>
                </div>
                <div class="kpi-icon bg-success bg-opacity-10 text-success">
                    <i class="bi bi-currency-dollar"></i>
                </div>
            </div>
            <!-- 2. Đơn hàng kỳ lọc -->
            <div class="kpi-card bg-white shadow-sm border border-light">
                <div class="kpi-info">
                    <h3>ĐƠN HÀNG THÀNH CÔNG</h3>
                    <p class="text-info">${kpis.donHangKyLoc} đơn</p>
                </div>
                <div class="kpi-icon bg-info bg-opacity-10 text-info">
                    <i class="bi bi-receipt"></i>
                </div>
            </div>
            <!-- 3. Sản phẩm đang bán -->
            <div class="kpi-card bg-white shadow-sm border border-light">
                <div class="kpi-info">
                    <h3>SẢN PHẨM ĐANG BÁN</h3>
                    <p class="text-warning">${kpis.monDangBan} món</p>
                </div>
                <div class="kpi-icon bg-warning bg-opacity-10 text-warning">
                    <i class="bi bi-cup-hot-fill"></i>
                </div>
            </div>
            <!-- 4. Tổng thành viên CRM -->
            <div class="kpi-card bg-white shadow-sm border border-light">
                <div class="kpi-info">
                    <h3>THÀNH VIÊN CRM</h3>
                    <p class="text-primary">${kpis.tongKhachHang} khách</p>
                </div>
                <div class="kpi-icon bg-primary bg-opacity-10 text-primary">
                    <i class="bi bi-people-fill"></i>
                </div>
            </div>
        </div>

        <!-- KHU VỰC VẼ BIỂU ĐỒ TRỰC QUAN (CHART) -->
        <div class="container-fluid px-4 mt-4 mb-4">
            <div class="row g-4">
                <!-- Đồ thị doanh thu theo ngày -->
                <div class="col-12 col-xl-8">
                    <div class="card card-teapos p-4">
                        <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-graph-up-arrow text-success"></i> Tăng trưởng doanh số ngày (VNĐ)
                        </h5>
                        <canvas id="dailyRevenueChart" style="max-height: 350px;"></canvas>
                    </div>
                </div>
                <!-- Đồ thị cơ cấu danh mục -->
                <div class="col-12 col-xl-4">
                    <div class="card card-teapos p-4">
                        <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                            <i class="bi bi-pie-chart-fill text-info"></i> Tỷ trọng danh mục đồ uống
                        </h5>
                        <canvas id="categoryRevenueChart" style="max-height: 350px;"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- BẢNG THỐNG KÊ CHI TIẾT (TOP SẢN PHẨM & NHÂN VIÊN) -->
        <div class="container-fluid px-4 mb-5">
            <div class="row g-4">
                <!-- Top 10 sản phẩm bán chạy nhất -->
                <div class="col-12 col-lg-7">
                    <div class="card card-teapos p-4">
                        <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                            <i class="bi bi-trophy-fill text-warning"></i> Top 10 sản phẩm bán chạy nhất
                        </h5>
                        <div class="table-responsive">
                            <table class="table table-hover table-teapos mb-0">
                                <thead>
                                <tr>
                                    <th style="width: 60px;">STT</th>
                                    <th>Tên Sản Phẩm</th>
                                    <th>Nhóm Danh Mục</th>
                                    <th class="text-center" style="width: 120px;">Sản lượng bán</th>
                                    <th class="text-end" style="width: 150px;">Doanh thu mang lại</th>
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
                                                <td class="text-end fw-bold">
                                                    <fmt:formatNumber value="${item.doanhThuMangLai}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-4">Chưa phát sinh dữ liệu bán hàng trong kỳ lọc</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Xếp hạng doanh thu nhân viên -->
                <div class="col-12 col-lg-5">
                    <div class="card card-teapos p-4">
                        <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                            <i class="bi bi-star-fill text-primary"></i> Xếp hạng chốt đơn của Nhân viên
                        </h5>
                        <div class="table-responsive">
                            <table class="table table-hover table-teapos mb-0">
                                <thead>
                                <tr>
                                    <th>Họ và tên nhân viên</th>
                                    <th class="text-center" style="width: 120px;">Đơn thành công</th>
                                    <th class="text-end" style="width: 150px;">Doanh thu tạo ra</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty topNhanViens}">
                                        <c:forEach var="item" items="${topNhanViens}">
                                            <tr>
                                                <td>
                                                    <div class="fw-bold"><c:out value="${item.hoTen}"/></div>
                                                    <small class="text-muted">Mã: ${item.maNv}</small>
                                                </td>
                                                <td class="text-center fw-bold">${item.soDonHoanThanh} đơn</td>
                                                <td class="text-end text-success fw-bold">
                                                    <fmt:formatNumber value="${item.doanhThuTaoRa}" type="currency" currencySymbol="" maxFractionDigits="0"/> đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="3" class="text-center text-muted py-4">Không có nhân viên thực hiện giao dịch trong kỳ</td>
                                        </tr>
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

<!-- ĐOẠN SCRIPT KHỞI DỰNG CÁC ĐỒ THỊ CHUYÊN NGHIỆP TRỰC TIẾP TỪ JSTL -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 1. Khởi tạo Line Chart cho Doanh Thu Ngày
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
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) { return value.toLocaleString('vi-VN') + ' đ'; }
                        }
                    }
                }
            }
        });

        // 2. Khởi tạo Doughnut Chart cho Tỷ Trọng Danh Mục
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
                    backgroundColor: [
                        '#10b981', '#06b6d4', '#f59e0b', '#ef4444', '#6366f1', '#a855f7', '#ec4899'
                    ],
                    borderWidth: 2,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, padding: 15 } }
                }
            }
        });
    });
</script>

</body>
</html>