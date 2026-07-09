package repository;

import model.entity.KhuyenMai;
import java.util.List;

public interface IKhuyenMaiRepository extends IBaseRepository<KhuyenMai, String> {
    KhuyenMai getByCode(String code);
    List<KhuyenMai> getVouchersKhaDung(int tongDonHang, String maKh);
    boolean giamSoLuongVoucher(String maKm);
}