package service;

import model.entity.KhuyenMai;
import java.util.List;

public interface IKhuyenMaiService {

    List<KhuyenMai> getAllKhuyenMai();

    KhuyenMai getKhuyenMaiById(String id);

    KhuyenMai getKhuyenMaiByCode(String code);

    boolean createKhuyenMai(KhuyenMai khuyenMai);

    boolean updateKhuyenMai(KhuyenMai khuyenMai);

    /**
     * Xóa chương trình khuyến mãi (Áp dụng xóa mềm chuyển trạng thái về ngừng hoạt động).
     */
    boolean deleteKhuyenMai(String id);

    /**
     * Lấy danh sách các mã khuyến mãi (Voucher) khả dụng mà một khách hàng cụ thể có thể sử dụng cho đơn hàng hiện tại.
     * Nghiệp vụ lọc bao gồm:
     * - Voucher đang hoạt động và nằm trong khoảng thời gian hiệu lực (ngay_bat_dau <= Hiện tại <= ngay_ket_thuc).
     * - Tổng tiền đơn hàng đạt điều kiện giá trị đơn tối thiểu (don_toi_thieu <= tongDonHang).
     * - Voucher còn số lượng phát hành (so_luong > 0).
     * - Khách hàng đạt thứ hạng thành viên cho phép áp dụng (Ví dụ: Voucher VIP chỉ dành cho hạng Vàng, Kim Cương).
     * @param tongDonHang Tổng số tiền hàng trước khi giảm giá
     * @param maKh Mã khách hàng mua hàng (để kiểm tra hạng thẻ), truyền null nếu là khách lẻ vãng lai
     * @return Danh sách Voucher hợp lệ có thể áp dụng
     */
    List<KhuyenMai> getVouchersKhaDungForKhachHang(int tongDonHang, String maKh);

    /**
     * Kiểm tra tính hợp lệ tuyệt đối của một mã Voucher trước khi tiến hành thanh toán chốt đơn.
     * Chống các hành vi gian lận hoặc can thiệp dữ liệu từ phía Client.
     * @param code Mã Code giảm giá (ví dụ: 'TEAFREE')
     * @param tongDonHang Tổng số tiền hàng
     * @param maKh Mã khách hàng tương ứng
     * @return true nếu mã hoàn toàn hợp lệ và đủ điều kiện áp dụng
     */
    boolean validateVoucher(String code, int tongDonHang, String maKh);

    /**
     * Tính toán số tiền được giảm giá thực tế khi áp dụng mã Voucher.
     * Nghiệp vụ tính toán bám sát quy tắc:
     * - Nếu loai_giam = 1 (TRU_TIEN): Số tiền giảm = gia_tri_giam.
     * - Nếu loai_giam = 2 (TRU_PHAN_TRAM): Số tiền giảm = (tongDonHang * gia_tri_giam) / 100.
     * - Số tiền giảm cuối cùng bắt buộc không được vượt quá số tiền giảm tối đa cho phép (giam_toi_da) và không được vượt quá tổng tiền của chính đơn hàng đó [1, 7].
     * @param code Mã Voucher
     * @param tongDonHang Tổng số tiền hàng
     * @return Số tiền giảm giá thực tế (đơn vị: VNĐ)
     */
    int calculateDiscount(String code, int tongDonHang);
}