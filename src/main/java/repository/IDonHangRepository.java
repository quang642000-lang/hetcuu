package repository;

import model.entity.ChiTietDonHang;
import model.entity.DonHang;
import model.entity.ChiTietTopping;
import java.util.List;

public interface IDonHangRepository extends IBaseRepository<DonHang, String> {
    List<DonHang> getByKhachHang(String maKh);
    List<DonHang> getByTrangThai(int trangThaiDon);
    boolean updateTrangThaiDon(String maDh, int trangThaiDon);
    boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan);

    // Truy xuất chi tiết đơn hàng phục vụ in hóa đơn và đối soát
    List<ChiTietDonHang> getChiTietDonHang(String maDh);
    List<ChiTietTopping> getToppingsOfChiTiet(long maCtdh);
}
