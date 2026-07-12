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
    List<ChiTietDonHang> getChiTietDonHang(String maDh);
    List<ChiTietTopping> getToppingsOfChiTiet(long maCtdh);

    // ĐỒNG BỘ MÃ KHÓA CHÍNH: Phát sinh mã đơn hàng tự động chuẩn hóa
    String generateNextMaDh();
}
