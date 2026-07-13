package repository;

import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import java.util.List;

public interface IGioHangRepository {
    // Thao tác giỏ hàng tổng quát của Khách hàng
    GioHang getByKhachHang(String maKh);
    boolean createGioHang(String maKh);

    // Thao tác Chi tiết sản phẩm trong giỏ hàng
    List<ChiTietGioHang> getChiTietGioHang(int maGh);
    ChiTietGioHang getChiTietBySpAndSize(int maGh, String maSp, int maSize);
    boolean addOrUpdateChiTiet(ChiTietGioHang chiTiet);
    boolean deleteChiTiet(long maCtgh);
    boolean clearGioHang(int maGh);
    boolean updateTrangThaiChonMua(long maCtgh, boolean isChonMua);

    // Thao tác danh sách Topping đi kèm của ly nước trong giỏ hàng
    List<ChiTietToppingGioHang> getToppingByChiTiet(long maCtgh);
    boolean addToppingToGioHang(long maCtgh, String maTp, int soLuongTp);
    boolean removeToppingsFromChiTiet(long maCtgh);
}
