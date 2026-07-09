package service;

import model.entity.DonHang;
import model.entity.ChiTietDonHang;
import java.sql.Timestamp;
import java.util.List;

public interface IDonHangService {

    List<DonHang> getAllDonHang();

    DonHang getDonHangById(String id);

    List<DonHang> getDonHangByKhachHang(String maKh);

    List<DonHang> getDonHangByTrangThai(int trangThaiDon);

    /**
     * Nghiệp vụ chốt hóa đơn bán hàng tại quầy POS dành cho thu ngân [6]:
     * Quy trình xử lý bao gồm:
     * 1. Sinh mã hóa đơn an toàn chống trùng lặp bằng SEQUENCE của SQL Server (`seq_DonHang`) [2].
     * 2. Thực hiện khóa dòng cơ sở dữ liệu (`ROWLOCK / UPDLOCK`) khi kiểm tra và áp dụng mã khuyến mãi cuối cùng để tránh lỗi tranh chấp tài nguyên (Race Condition) [1].
     * 3. Chốt cứng đơn giá bán của sản phẩm (`gia_chot`) và toppings (`gia_chot_tp`) tại thời điểm tạo đơn để bảo toàn lịch sử báo cáo doanh thu tài chính (Price Snapshot) [1].
     * 4. Tính toán dồn tiền hóa đơn: Tổng tiền = (Giá chốt món + Giá chốt Topping) * Số lượng - Tiền giảm Voucher - Tiền trừ điểm tích lũy.
     * 5. Lưu toàn bộ thông tin đơn hàng, chi tiết đơn hàng, chi tiết toppings đi kèm vào CSDL trong một Transaction duy nhất [21, 22].
     * 6. Cộng điểm CRM thưởng cho khách hàng theo quy tắc: 10.000 VNĐ tiền trả thực tế = 1 điểm tích lũy [23].
     * 7. Lưu nhật ký hoạt động của nhân viên thu ngân dưới dạng JSON chi tiết để phục vụ công tác kiểm toán sau này [15, 24].
     * @param donHang Thực thể thông tin hóa đơn tổng quát
     * @param items Danh sách chi tiết ly nước và toppings đi kèm được đặt mua
     * @param maNv Mã nhân viên thu ngân thực hiện chốt đơn tại quầy
     * @return true nếu đơn hàng được thanh toán, in hóa đơn và lưu trữ thành công
     */
    boolean checkoutPOS(DonHang donHang, List<ChiTietDonHang> items, String maNv);

    /**
     * Nghiệp vụ khách hàng tự đặt hàng Online (Click & Collect) trên Website Portal [1, 2].
     * Quy tắc nghiệp vụ đặc thù:
     * - Khách hàng bắt buộc phải chỉ định thời gian đến cửa hàng lấy nước (Hẹn giờ lấy).
     * - Hệ thống kiểm tra điều kiện thời gian hẹn lấy phải cách thời điểm đặt đơn tối thiểu 15 phút và nằm trong khung giờ mở cửa của quán (Validation thời gian hợp lý).
     * - Trạng thái ban đầu của hóa đơn được thiết lập là 'Chờ xác nhận' (trang_thai_don = 0) [1].
     * @param donHang Thực thể hóa đơn chứa thông tin đặt online
     * @param items Danh sách chi tiết giỏ hàng đặt mua
     * @return true nếu đặt hàng online thành công
     */
    boolean placeOrderOnline(DonHang donHang, List<ChiTietDonHang> items);

    /**
     * Cập nhật trạng thái xử lý đơn hàng.
     * Nghiệp vụ: Khi chuyển đơn hàng sang trạng thái 'Hoàn thành' (trang_thai_don = 4):
     * - Hệ thống cập nhật thời gian hoàn thành thực tế (`thoi_gian_hoan_thanh = GETDATE()`) [23].
     * - Tự động cộng điểm tích lũy cho tài khoản khách hàng tương ứng trong CSDL [23].
     * - Nâng hạng thành viên tự động cho khách hàng nếu tổng điểm tích lũy đạt mốc quy định mới.
     * @param maDh Mã hóa đơn cần cập nhật
     * @param trangThaiDon Trạng thái đơn hàng mới (Confirmed, Processing, Ready, Completed, Cancelled)
     * @param maNv Mã nhân viên thao tác cập nhật trạng thái đơn
     * @param lyDoHuy Lý do hủy đơn hàng (Bắt buộc phải truyền vào nếu trạng thái cập nhật là Hủy đơn) [1]
     * @return true nếu cập nhật thành công và ghi nhận lịch sử kiểm toán đầy đủ
     */
    boolean updateTrangThaiDon(String maDh, int trangThaiDon, String maNv, String lyDoHuy);

    /**
     * Cập nhật trạng thái thanh toán của hóa đơn (Ví dụ: Chưa thanh toán -> Đã thanh toán).
     */
    boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan);

    /**
     * Tự động nhận diện và xử lý thanh toán chuyển khoản ngân hàng thông qua SePay Webhook (IPN) [1, 2].
     * Quy trình xử lý thông minh (Automatic Payment Matching):
     * 1. Nhận thông tin thông báo Webhook chuyển khoản chứa nội dung chuyển khoản và số tiền thực nhận.
     * 2. Áp dụng biểu thức chính quy (Regex) để bóc tách tìm mã đơn hàng: Định dạng regex quét tìm chuỗi ký tự 'TEA' đi kèm với số hóa đơn (Ví dụ nội dung chuyển khoản: 'Chuyen tien don TEA10024') [1].
     * 3. Tìm kiếm đơn hàng có mã trùng khớp trong CSDL.
     * 4. Kiểm tra đối soát số tiền thực nhận có khớp 100% với giá trị phải trả cuối cùng của đơn hàng hay không.
     * 5. Nếu khớp hoàn toàn: Hệ thống tự động chuyển trạng thái đơn sang 'Đã xác nhận' và 'Đang pha chế' mà không cần bất kỳ nhân viên nào phải bấm xác nhận tay tại quầy POS [1, 2].
     * @param content Nội dung tin nhắn chuyển khoản ngân hàng do SePay gửi về backend
     * @param amount Số tiền ngân hàng ghi nhận thực tế
     * @return true nếu nhận diện thanh toán và khớp đơn tự động thành công
     */
    boolean handleSePayWebhook(String content, double amount);

    /**
     * Kiểm tra tính hợp lệ của thời gian hẹn đến lấy nước đặt online.
     * @param thoiGianHenLay Thời gian hẹn lấy
     * @return true nếu thời gian hoàn toàn hợp lý (Thời gian hẹn >= Thời gian hiện tại + 15 phút)
     */
    boolean validateThoiGianHenLay(Timestamp thoiGianHenLay);
}

