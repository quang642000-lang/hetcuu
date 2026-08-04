<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- PROFILE MODAL -->
<div class="modal fade" id="posProfileModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-success text-white py-3">
                <h5 class="modal-title fw-bold m-0"><i class="bi bi-person-circle me-1"></i> THÔNG TIN CÁ NHÂN</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start bg-light">
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Họ và tên nhân viên</label>
                    <input type="text" id="profile_hoTen" class="form-control" value="<c:out value='${sessionScope.user.hoTen}'/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Số điện thoại liên hệ</label>
                    <input type="text" id="profile_sdt" class="form-control" value="${sessionScope.user.soDienThoai}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Địa chỉ Email</label>
                    <input type="email" id="profile_email" class="form-control" value="${sessionScope.user.email}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Tên đăng nhập hệ thống</label>
                    <input type="text" class="form-control bg-light text-muted" value="<c:out value='${sessionScope.user.tenDangNhap}'/>" readonly>
                </div>
            </div>
            <div class="modal-footer bg-light border-top p-2.5">
                <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-success btn-sm px-3" onclick="submitPosProfile()"><i class="bi bi-save me-1"></i> Lưu thay đổi</button>
            </div>
        </div>
    </div>
</div>

<!-- PASSWORD MODAL -->
<div class="modal fade" id="posPasswordModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-warning text-dark py-3">
                <h5 class="modal-title fw-bold m-0"><i class="bi bi-key-fill me-1"></i> ĐỔI MẬT KHẨU BẢO MẬT</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-start bg-light">
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Mật khẩu cũ hiện tại <span class="text-danger">*</span></label>
                    <input type="password" id="password_old" class="form-control" placeholder="Nhập mật khẩu cũ..." required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Mật khẩu mới bảo mật <span class="text-danger">*</span></label>
                    <input type="password" id="password_new" class="form-control" placeholder="Tối thiểu từ 8 ký tự..." required>
                </div>
                <div class="mb-3">
                    <label class="form-label text-muted small fw-bold">Xác nhận mật khẩu mới <span class="text-danger">*</span></label>
                    <input type="password" id="password_confirm" class="form-control" placeholder="Nhập lại mật khẩu mới..." required>
                </div>
            </div>
            <div class="modal-footer bg-light border-top p-2.5">
                <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-warning btn-sm px-3 fw-bold" onclick="submitPosPassword()"><i class="bi bi-save me-1"></i> Lưu mật khẩu mới</button>
            </div>
        </div>
    </div>
</div>

<!-- PRINT RECEIPT MODAL -->
<div class="modal fade" id="receiptDetailModal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 340px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 8px;">
            <div class="modal-body p-3 bg-white text-dark text-start receipt-container" id="billPrintArea" style="font-family: 'Courier New', Courier, monospace; font-size: 12px; line-height: 1.4;">
                <div class="text-center mb-2">
                    <strong style="font-size: 15px; letter-spacing: 1px; text-align: center; display: block;">TEA POS CAFÉ</strong>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Địa chỉ: 123 Đường Trà Sữa, Phường 10, Gò Vấp</span>
                    <span style="font-size: 9px; color: #555; text-align: center; display: block;">Hotline: (+84) 123 456 789</span>
                    <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                    <strong style="font-size: 11px; text-align: center; display: block;">HÓA ĐƠN CHI TIẾT</strong>
                    <span style="font-size: 10px; text-align: center; display: block;" id="billThoiGian"></span>
                </div>
                <div class="mb-2" style="font-size: 10px; line-height: 1.4;">
                    <div>Mã đơn: <strong id="billMaDh"></strong></div>
                    <div>Thu ngân: <span id="billTenNv"></span></div>
                    <div>Khách hàng: <span id="billTenKh"></span></div>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div id="billItemsContainer" style="font-size: 10.5px;"></div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="d-flex justify-content-between mb-1" style="font-size: 10px;">
                    <span>Tổng tiền nước gốc:</span>
                    <strong id="billRawPrice"></strong>
                </div>
                <div class="d-flex justify-content-between text-danger mb-1" id="billDiscountRow" style="display: none; font-size: 10px;">
                    <span>Khấu trừ Voucher:</span>
                    <strong id="billDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between text-primary mb-1" id="billPointsRow" style="display: none; font-size: 10px;">
                    <span>Tiêu điểm CRM:</span>
                    <strong id="billPointsDiscount"></strong>
                </div>
                <div class="d-flex justify-content-between mb-1" style="font-size: 10px;">
                    <span>Thuế VAT (8%):</span>
                    <strong id="billVatPrice"></strong>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 4px 0;"></div>
                <div class="d-flex justify-content-between fw-bold text-success" style="font-size: 12px; margin-bottom: 4px;">
                    <span>CẦN THANH TOÁN:</span>
                    <span id="billFinalPayable"></span>
                </div>
                <div class="d-flex justify-content-between text-muted mb-1" id="billCashGivenRow" style="font-size: 10px; display: none;">
                    <span>Tiền mặt khách đưa:</span>
                    <span id="billCashGiven" class="fw-bold text-dark"></span>
                </div>
                <div class="d-flex justify-content-between text-muted mb-1" id="billCashRefundRow" style="font-size: 10px; display: none;">
                    <span>Tiền thối lại:</span>
                    <span id="billCashRefund" class="fw-bold text-success"></span>
                </div>
                <div style="border-bottom: 1px dashed #333; margin: 6px 0;"></div>
                <div class="text-center mt-3" style="font-size: 9px; color: #444; text-align: center;">
                    Cảm ơn quý khách hàng và hẹn gặp lại!<br><i>Powered by CodeDevSquad</i>
                </div>
            </div>
            <div class="modal-footer p-2 bg-light d-flex justify-content-between">
                <button type="button" class="btn btn-sm btn-secondary fw-bold" data-bs-dismiss="modal">Đóng</button>
                <button type="button" class="btn btn-sm btn-success fw-bold" onclick="printReceipt()"><i class="bi bi-printer"></i> In Hóa Đơn</button>
            </div>
        </div>
    </div>
</div>

<!-- VIETQR MODAL -->
<div class="modal fade" id="posQrModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false" style="z-index: 1065;">
    <div class="modal-dialog modal-dialog-centered modal-sm" style="max-width: 320px;">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <div class="modal-header bg-dark text-white py-2.5">
                <h6 class="modal-title fw-bold m-0"><i class="bi bi-qr-code-scan me-2 text-success"></i> QUÉT MÃ CHUYỂN KHOẢN</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="cancelQRPayment()"></button>
            </div>
            <div class="modal-body text-center bg-white p-4">
                <h3 class="text-danger fw-bold mb-1" id="posQrAmount">0 đ</h3>
                <p class="text-muted small mb-3">Mã đơn: <span class="fw-bold text-dark font-monospace" id="posQrCodeDisplay"></span></p>
                <div class="bg-light p-3 rounded-4 d-inline-block mb-3 position-relative border" style="border-radius: 12px !important;">
                    <img id="posQrImage" src="" alt="VietQR Payment Code" class="img-fluid" style="max-width: 200px; height: 200px; object-fit: contain;">
                    <div id="posQrSuccessOverlay" class="position-absolute top-0 start-0 w-100 h-100 bg-white bg-opacity-90 d-flex flex-column justify-content-center align-items-center" style="display: none !important; z-index: 10; backdrop-filter: blur(2px); border-radius: 12px;">
                        <i class="bi bi-check-circle-fill text-success" style="font-size: 3.5rem;"></i>
                        <h6 class="text-success mt-2 fw-bold mb-0">Đã Khớp Số Dư!</h6>
                    </div>
                    <div id="posQrExpiredOverlay" class="position-absolute top-0 start-0 w-100 h-100 bg-white bg-opacity-90 d-flex flex-column justify-content-center align-items-center" style="display: none !important; z-index: 10; backdrop-filter: blur(2px); border-radius: 12px;">
                        <i class="bi bi-x-circle-fill text-danger" style="font-size: 3.5rem;"></i>
                        <h6 class="text-danger mt-2 fw-bold mb-0">Mã Đã Hết Hạn</h6>
                    </div>
                </div>
                <div class="text-danger fw-bold small mb-2 text-uppercase">
                    <i class="bi bi-clock-history"></i> Có hiệu lực trong <span id="posQrCountdownText" class="fs-5">120</span> giây
                </div>
                <div id="posQrLoadingStatus" class="text-success fw-bold small mb-0 d-flex align-items-center justify-content-center">
                    <div class="spinner-border spinner-border-sm text-success me-2" role="status"></div>
                    <span style="font-size: 11px;">Hệ thống đang chờ tiền vào...</span>
                </div>
            </div>
            <div class="modal-footer border-0 p-2 bg-light d-flex justify-content-between rounded-bottom-4">
                <button type="button" class="btn btn-sm btn-outline-danger fw-bold rounded-pill px-3" onclick="cancelQRPayment()">Hủy bỏ</button>
                <button type="button" class="btn btn-sm btn-success fw-bold rounded-pill px-3" onclick="forceSubmitCheckout()">Bỏ qua <i class="bi bi-arrow-right"></i></button>
            </div>
        </div>
    </div>
</div>