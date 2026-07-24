<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!-- PHẦN FOOTER CHÍNH CỦA WEBSITE - ĐÃ ĐỒNG BỘ MÀU CHỮ TRỰC QUAN CHỐNG TRÙNG MÀU NỀN -->
<style>
    .portal-footer {
        background-color: #0f172a !important; /* Premium Slate Dark */
        color: #f8fafc !important;
        border-top: 4px solid #10b981 !important; /* Emerald top border */
        padding-top: 3rem !important;
        padding-bottom: 1.5rem !important;
        margin-top: 3rem !important;
    }
    .portal-footer h5, .portal-footer h6 {
        color: #ffffff !important;
        font-weight: 700 !important;
        margin-bottom: 1rem !important;
    }
    .portal-footer .text-success-custom {
        color: #10b981 !important;
    }
    .portal-footer p, .portal-footer span, .portal-footer .text-muted-custom {
        color: #94a3b8 !important; /* Lighter slate gray for perfect readability on dark bg */
        font-size: 13.5px !important;
    }
    .portal-footer a.footer-link {
        color: #94a3b8 !important;
        text-decoration: none !important;
        transition: all 0.2s ease-in-out !important;
        font-size: 13.5px !important;
    }
    .portal-footer a.footer-link:hover {
        color: #10b981 !important; /* Elegant Emerald Glow */
        padding-left: 4px !important; /* Subtle slider effect */
    }
    .portal-footer .social-icon {
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px solid rgba(16, 185, 129, 0.3) !important;
        color: #10b981 !important;
        border-radius: 50%;
        transition: all 0.25s ease !important;
        text-decoration: none !important;
    }
    .portal-footer .social-icon:hover {
        background-color: #10b981 !important;
        color: #ffffff !important;
        border-color: #10b981 !important;
        transform: translateY(-2px) scale(1.05) !important;
    }
    .portal-footer hr {
        border-color: #334155 !important;
        opacity: 0.5 !important;
    }
    .portal-footer .footer-bottom-text {
        color: #64748b !important;
        font-size: 12px !important;
    }
</style>

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
<!-- IMPORT BOOTSTRAP JS BUNDLE SOLELY HERE FOR THE WEB PORTAL -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>