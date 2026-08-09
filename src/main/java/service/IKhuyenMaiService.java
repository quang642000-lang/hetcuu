package service;

import model.entity.KhuyenMai;
import java.util.List;

public interface IKhuyenMaiService {

    List<KhuyenMai> getAllKhuyenMai();
    KhuyenMai getKhuyenMaiById(String id);
    KhuyenMai getKhuyenMaiByCode(String code);
    boolean createKhuyenMai(KhuyenMai khuyenMai);
    boolean updateKhuyenMai(KhuyenMai khuyenMai);
    boolean deleteKhuyenMai(String id);
    List<KhuyenMai> getVouchersKhaDungForKhachHang(int tongDonHang, String maKh);
    boolean validateVoucher(String code, int tongDonHang, String maKh);
    int calculateDiscount(String code, int tongDonHang);
}