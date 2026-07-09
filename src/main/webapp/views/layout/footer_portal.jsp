<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>

<!-- PHẦN FOOTER CHÍNH CỦA WEBSITE -->
<footer class="bg-dark text-white pt-5 pb-4 mt-5 border-top border-success" style="border-top-width: 4px !important;">
    <div class="container">
        <div class="row">
            <!-- Cột 1: Giới thiệu chung -->
            <div class="col-lg-4 col-md-6 mb-4 mb-lg-0">
                <h5 class="fw-bold mb-3 d-flex align-items-center gap-2" style="color: #10b981 !important;">
                    <i class="bi bi-cup-hot-fill fs-4 text-success"></i> TEA POS SYSTEM
                </h5>
                <p class="text-muted small mb-3" style="line-height: 1.7;">
                    Hệ thống đặt nước uống trực tuyến và quản lý CRM thành viên hiện đại. Mang đến trải nghiệm mua trà sữa tiện lợi nhanh chóng thông qua giải pháp Click & Collect lấy ngay tại quầy không cần xếp hàng chờ đợi [9]!
                </p>
                <div class="d-flex gap-3 fs-5">
                    <a href="#" class="text-secondary hover-text-success"><i class="bi bi-facebook text-primary"></i></a>
                    <a href="#" class="text-secondary hover-text-success"><i class="bi bi-youtube text-danger"></i></a>
                    <a href="#" class="text-secondary hover-text-success"><i class="bi bi-tiktok text-light"></i></a>
                    <a href="#" class="text-secondary hover-text-success"><i class="bi bi-globe2 text-info"></i></a>
                </div>
            </div>

            <!-- Cột 2: Các liên kết thực đơn phổ biến -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0 ps-lg-5">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Thực đơn nhanh</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li><a href="${pageContext.request.contextPath}/products" class="text-muted text-decoration-none hover-text-white">Trà sữa trân châu</a></li>
                    <li><a href="${pageContext.request.contextPath}/products" class="text-muted text-decoration-none hover-text-white">Trà trái cây nhiệt đới</a></li>
                    <li><a href="${pageContext.request.contextPath}/products" class="text-muted text-decoration-none hover-text-white">Toppings phong phú</a></li>
                    <li><a href="${pageContext.request.contextPath}/products" class="text-muted text-decoration-none hover-text-white">Sản phẩm bán chạy</a></li>
                </ul>
            </div>

            <!-- Cột 3: Liên kết hệ thống thông tin hỗ trợ khách hàng -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Hỗ trợ khách hàng</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li><a href="${pageContext.request.contextPath}/profile" class="text-muted text-decoration-none hover-text-white">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/orders" class="text-muted text-decoration-none hover-text-white">Xem lịch sử đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/vouchers" class="text-muted text-decoration-none hover-text-white font-success">Kho voucher VIP</a></li>
                    <li><a href="#" class="text-muted text-decoration-none hover-text-white">Điều khoản sử dụng</a></li>
                </ul>
            </div>

            <!-- Cột 4: Thông tin liên hệ và thời gian hoạt động -->
            <div class="col-lg-4 col-md-6">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Thông tin liên hệ</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li class="d-flex align-items-start gap-2 text-muted">
                        <i class="bi bi-geo-alt-fill text-success"></i>
                        <span>123 Đường Trà Sữa, Phường 10, Quận Gò Vấp, TP. Hồ Chí Minh [13]</span>
                    </li>
                    <li class="d-flex align-items-center gap-2 text-muted">
                        <i class="bi bi-telephone-fill text-success"></i>
                        <span>(+84) 123 456 789</span>
                    </li>
                    <li class="d-flex align-items-center gap-2 text-muted">
                        <i class="bi bi-envelope-fill text-success"></i>
                        <span>hotro@teapos.vn</span>
                    </li>
                    <li class="d-flex align-items-center gap-2 text-muted">
                        <i class="bi bi-clock-fill text-success"></i>
                        <span>Thời gian phục vụ: 07:00 - 22:30 hàng ngày [13]</span>
                    </li>
                </ul>
            </div>
        </div>

        <hr class="border-secondary my-4">

        <!-- Bản quyền dự án tốt nghiệp -->
        <div class="row align-items-center">
            <div class="col-md-6 text-center text-md-start small text-muted">
                &copy; 2026 TEA POS SYSTEM. Dự án tốt nghiệp xây dựng bởi nhóm <b>CodeDevSquad</b>. All Rights Reserved.
            </div>
            <div class="col-md-6 text-center text-md-end small text-muted mt-2 mt-md-0">
                Thiết kế Figma mượt mà, lập trình liên kết CSDL tối ưu bảo mật.
            </div>
        </div>
    </div>
</footer>

<!-- KHU VỰC NẠP TOÀN BỘ CÁC SCRIPT HOẠT ĐỘNG JAVASCRIPT CỐT LÕI -->
<!-- 1. Thư viện Bootstrap 5.3 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" type="text/javascript"></script>

<!-- 2. Thư viện Tiện ích và Toast dùng chung -->
<script src="${pageContext.request.contextPath}/assets/js/global.js" type="text/javascript"></script>

<!-- 3. Thư viện xử lý nghiệp vụ của Website Portal -->
<script src="${pageContext.request.contextPath}/assets/js/portal.js" type="text/javascript"></script>

</body>
</html>