package service;

import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import java.util.List;

public interface IGioHangService {
    GioHang getGioHangComplete(String maKh);

    boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int soLuong,
                                String mucDa, String mucDuong, String ghiChuMon,
                                List<ChiTietToppingGioHang> toppings);

    boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int soLuong,
                                String mucDa, String mucDuong, String ghiChuMon,
                                List<ChiTietToppingGioHang> toppings, boolean isBuyNow);

    boolean updateSoLuongChiTiet(long maCtgh, int soLuongMoi);

    boolean deleteChiTietGioHang(long maCtgh);

    boolean clearGioHang(String maKh);

    boolean updateTrangThaiChonMua(long maCtgh, boolean isChon);
}
