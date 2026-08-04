<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<footer class="portal-footer">
    <div class="container">
        <div class="row">
            <!-- Cột 1: Giới thiệu chung -->
            <div class="col-lg-4 col-md-6 mb-4 mb-lg-0 text-start">
                <h5 class="fw-bold text-success-custom"><i class="bi bi-cup-hot-fill me-2"></i>TEA POS CAFÉ</h5>
                <p class="small" style="line-height: 1.6;">
                    Hệ thống đặt nước trực tuyến Click & Collect và quản trị quầy bán lẻ chuyên nghiệp dành cho các thương hiệu trà sữa, cafe vừa và nhỏ. Hãy thưởng thức dải trà sữa hảo hạng thơm béo và tiện lợi nhất.
                </p>
                <div class="d-flex gap-2 mt-3">
                    <a href="#" class="social-icon"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="social-icon"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="social-icon"><i class="bi bi-youtube"></i></a>
                </div>
            </div>
            <!-- Cột 2: Danh mục nhanh -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0 text-start">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Liên kết nhanh</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/home" class="footer-link">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products" class="footer-link">Thực đơn trà sữa</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart" class="footer-link">Giỏ hàng</a></li>
                </ul>
            </div>
            <!-- Cột 3: Liên kết hệ thống hỗ trợ -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0 text-start">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Hỗ trợ khách hàng</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 mb-0">
                    <li><a href="${pageContext.request.contextPath}/profile" class="footer-link">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/orders" class="footer-link">Xem lịch sử đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/vouchers" class="footer-link text-success-custom">Kho voucher VIP 👑</a></li>
                </ul>
            </div>
            <!-- Cột 4: Thông tin liên hệ và thời gian hoạt động -->
            <div class="col-lg-4 col-md-6 text-start">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Thông tin liên hệ</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 mb-0">
                    <li class="d-flex align-items-start gap-2">
                        <i class="bi bi-geo-alt-fill text-success-custom mt-1"></i>
                        <span class="text-muted-custom">123 Đường Trà Sữa, Phường 10, Quận Gò Vấp, TP. Hồ Chí Minh</span>
                    </li>
                    <li class="d-flex align-items-center gap-2">
                        <i class="bi bi-telephone-fill text-success-custom"></i>
                        <span class="text-muted-custom">(+84) 123 456 789</span>
                    </li>
                    <li class="d-flex align-items-center gap-2">
                        <i class="bi bi-envelope-fill text-success-custom"></i>
                        <span class="text-muted-custom">hotro@teapos.vn</span>
                    </li>
                    <li class="d-flex align-items-center gap-2">
                        <i class="bi bi-clock-fill text-success-custom"></i>
                        <span class="text-muted-custom">Phục vụ: 07:00 - 22:30 hàng ngày</span>
                    </li>
                </ul>
            </div>
        </div>
        <hr class="my-4">
        <!-- Bản quyền dự án tốt nghiệp -->
        <div class="row align-items-center">
            <div class="col-md-6 text-center text-md-start footer-bottom-text">
                &copy; 2026 TEA POS SYSTEM. Dự án tốt nghiệp xây dựng bởi nhóm <b>CodeDevSquad</b>. All Rights Reserved.
            </div>
            <div class="col-md-6 text-center text-md-end footer-bottom-text mt-2 mt-md-0">
                Thiết kế Figma mượt mà, lập trình liên kết CSDL tối ưu bảo mật.
            </div>
        </div>
    </div>
</footer>

<!-- SYSTEM CENTRALIZED JS PARTNER -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.0/dist/sweetalert2.all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/global.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/portal.js"></script>
