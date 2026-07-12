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
    boolean checkoutPOS(DonHang donHang, List<ChiTietDonHang> items, String maNv);
    boolean placeOrderOnline(DonHang donHang, List<ChiTietDonHang> items);
    boolean updateTrangThaiDon(String maDh, int trangThaiDon, String maNv, String lyDoHuy);
    boolean updateTrangThaiThanhToan(String maDh, int trangThaiThanhToan);
    boolean handleSePayWebhook(String content, double amount);
    boolean validateThoiGianHenLay(Timestamp thoiGianHenLay);

    // ĐỒNG BỘ MÃ KHÓA CHÍNH: Phát sinh mã hóa đơn đồng nhất cho POS & Online
    String generateNextMaDh();
}
