<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!-- PHẦN FOOTER CHÍNH CỦA WEBSITE -->
<footer class="bg-dark text-white pt-5 pb-4 mt-5 border-top border-success" style="border-top-width: 4px !important;">
    <div class="container">
        <div class="row">
            <!-- Cột 1: Giới thiệu chung -->
            <div class="col-lg-4 col-md-6 mb-4 mb-lg-0">
                <h5 class="fw-bold text-success mb-3">TEA POS CAFÉ</h5>
                <p class="small text-muted" style="line-height: 1.6;">Hệ thống đặt nước trực tuyến Click & Collect và quản trị quầy bán lẻ chuyên nghiệp dành cho các thương hiệu trà sữa, cafe vừa và nhỏ. Hãy thưởng thức dải trà sữa hảo hạng thơm béo và tiện lợi nhất.</p>
                <div class="d-flex gap-2.5 mt-3">
                    <a href="#" class="btn btn-outline-success btn-sm rounded-circle" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="btn btn-outline-success btn-sm rounded-circle" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="btn btn-outline-success btn-sm rounded-circle" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;"><i class="bi bi-youtube"></i></a>
                </div>
            </div>
            <!-- Cột 2: Danh mục nhanh -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Liên kết nhanh</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li><a href="${pageContext.request.contextPath}/home" class="text-muted text-decoration-none hover-text-white">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products" class="text-muted text-decoration-none hover-text-white">Thực đơn trà sữa</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart" class="text-muted text-decoration-none hover-text-white">Giỏ hàng</a></li>
                </ul>
            </div>
            <!-- Cột 3: Liên kết hệ thống thông tin hỗ trợ khách hàng -->
            <div class="col-lg-2 col-md-6 col-6 mb-4 mb-lg-0">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Hỗ trợ khách hàng</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li><a href="${pageContext.request.contextPath}/profile" class="text-muted text-decoration-none hover-text-white">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/orders" class="text-muted text-decoration-none hover-text-white">Xem lịch sử đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/profile/vouchers" class="text-muted text-decoration-none hover-text-white font-success">Kho voucher VIP</a></li>
                </ul>
            </div>
            <!-- Cột 4: Thông tin liên hệ và thời gian hoạt động -->
            <div class="col-lg-4 col-md-6">
                <h6 class="fw-bold text-white mb-3" style="letter-spacing: 0.5px;">Thông tin liên hệ</h6>
                <ul class="list-unstyled d-flex flex-column gap-2 small">
                    <li class="d-flex align-items-start gap-2 text-muted">
                        <i class="bi bi-geo-alt-fill text-success"></i>
                        <span>123 Đường Trà Sữa, Phường 10, Quận Gò Vấp, TP. Hồ Chí Minh</span>
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
                        <span>Thời gian phục vụ: 07:00 - 22:30 hàng ngày</span>
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

<!-- IMPORT BOOTSTRAP JS BUNDLE SOLELY HERE FOR THE WEB PORTAL -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>