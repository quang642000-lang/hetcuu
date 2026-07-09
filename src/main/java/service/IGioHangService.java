package service;

import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import java.util.List;

public interface IGioHangService {

    /**
     * Lấy thông tin giỏ hàng tổng quát và toàn bộ danh sách các ly nước uống chi tiết bên trong của khách hàng.
     * @param maKh Mã khách hàng đăng nhập portal
     * @return Thực thể GioHang hoàn chỉnh chứa đầy đủ danh sách ChiTietGioHang con
     */
    GioHang getGioHangComplete(String maKh);

    /**
     * Thêm một ly nước uống được tùy chỉnh riêng biệt vào giỏ hàng của khách hàng.
     * Quy tắc xử lý trùng lặp trong giỏ hàng (Business Rule):
     * - Hệ thống quét kiểm tra xem trong giỏ hàng của khách đã tồn tại ly nước nào trùng khớp hoàn toàn từ:
     *   mã sản phẩm, kích cỡ ly, lượng đá, lượng đường, ghi chú cho đến danh sách toppings đi kèm hay chưa.
     * - Nếu trùng khớp 100%: Tiến hành cộng dồn số lượng đặt mua của ly đó lên (so_luong + soLuongThem) [17].
     * - Nếu khác biệt bất kỳ một tùy chọn nào: Tạo mới một dòng chi tiết giỏ hàng (`CHI_TIET_GIO_HANG`) riêng biệt.
     * @param maKh Mã khách hàng
     * @param maSp Mã sản phẩm đồ uống muốn thêm
     * @param maSize Mã kích cỡ ly (S, M, L)
     * @param soLuong Số lượng ly muốn thêm
     * @param mucDa Lượng đá (100%, 70%, 50%, 0%)
     * @param mucDuong Lượng đường (100%, 70%, 50%, 0%)
     * @param ghiChuMon Ghi chú pha chế riêng của ly nước
     * @param toppings Danh sách các toppings chọn ăn kèm đi kèm ly nước này
     * @return true nếu thêm thành công vào giỏ hàng
     */
    boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int soLuong,
                                String mucDa, String mucDuong, String ghiChuMon,
                                List<ChiTietToppingGioHang> toppings);

    /**
     * Cập nhật số lượng đặt mua của một dòng ly nước uống trong giỏ hàng.
     * @param maCtgh Mã chi tiết dòng giỏ hàng cần cập nhật
     * @param soLuongMoi Số lượng ly nước mới thiết lập
     * @return true nếu cập nhật thành công
     */
    boolean updateSoLuongChiTiet(long maCtgh, int soLuongMoi);

    /**
     * Xóa một dòng ly nước uống ra khỏi giỏ hàng.
     * Nghiệp vụ: CSDL sẽ tự động xóa sạch danh sách toppings liên kết đi kèm ly này trong bảng `CHI_TIET_TOPPING_GIO_HANG` [20].
     * @param maCtgh Mã chi tiết dòng giỏ hàng cần xóa
     * @return true nếu xóa thành công
     */
    boolean deleteChiTietGioHang(long maCtgh);

    /**
     * Xóa sạch toàn bộ giỏ hàng của khách hàng (Ví dụ: Thực hiện sau khi khách đã tạo đơn hàng thành công).
     * @param maKh Mã khách hàng
     * @return true nếu giỏ hàng được làm sạch thành công
     */
    boolean clearGioHang(String maKh);

    /**
     * Cập nhật trạng thái tick chọn mua của món trong giỏ hàng (Phục vụ tính năng Selective Checkout).
     * @param maCtgh Mã dòng chi tiết giỏ hàng
     * @param isChon true nếu khách hàng tick chọn mua để thanh toán, false nếu bỏ chọn mua
     * @return true nếu cập nhật thành công
     */
    boolean updateTrangThaiChonMua(long maCtgh, boolean isChon);
}