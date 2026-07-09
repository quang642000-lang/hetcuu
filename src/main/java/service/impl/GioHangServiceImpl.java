package service.impl;

import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import repository.IGioHangRepository;
import repository.impl.GioHangRepoImpl;
import service.IGioHangService;

import java.util.List;

public class GioHangServiceImpl implements IGioHangService {
    private static GioHangServiceImpl instance;
    private final IGioHangRepository gioHangRepository;

    private GioHangServiceImpl() {
        this.gioHangRepository = GioHangRepoImpl.getInstance();
    }

    public static synchronized GioHangServiceImpl getInstance() {
        if (instance == null) {
            instance = new GioHangServiceImpl();
        }
        return instance;
    }

    @Override
    public GioHang getGioHangComplete(String maKh) {
        GioHang gh = gioHangRepository.getByKhachHang(maKh);
        if (gh == null) {
            gioHangRepository.createGioHang(maKh);
            gh = gioHangRepository.getByKhachHang(maKh);
        }

        if (gh != null) {
            List<ChiTietGioHang> items = gioHangRepository.getChiTietGioHang(gh.getMaGh());
            for (ChiTietGioHang item : items) {
                // Nạp chi tiết Topping đi kèm của từng ly trong giỏ
                item.setToppingGioHangList(gioHangRepository.getToppingByChiTiet(item.getMaCtgh()));
            }
            gh.setChiTietGioHangList(items);
        }
        return gh;
    }

    @Override
    public boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int soLuong,
                                       String mucDa, String mucDuong, String ghiChuMon,
                                       List<ChiTietToppingGioHang> toppings) {
        GioHang gh = getGioHangComplete(maKh);
        if (gh == null) return false;

        // Quét kiểm tra trùng lặp sản phẩm cấu hình giống nhau 100%
        ChiTietGioHang targetItem = null;
        List<ChiTietGioHang> currentItems = gh.getChiTietGioHangList();

        for (ChiTietGioHang item : currentItems) {
            if (item.getMaSp().equals(maSp) && item.getMaSize() == maSize
                    && equalsString(item.getMucDa(), mucDa)
                    && equalsString(item.getMucDuong(), mucDuong)
                    && equalsString(item.getGhiChuMon(), ghiChuMon)) {

                // Kiểm tra xem toppings đi kèm có trùng khớp hoàn toàn không
                if (isSameToppings(item.getToppingGioHangList(), toppings)) {
                    targetItem = item;
                    break;
                }
            }
        }

        if (targetItem != null) {
            // Trùng khớp hoàn toàn -> Cộng dồn số lượng
            targetItem.setSoLuong(targetItem.getSoLuong() + soLuong);
            return gioHangRepository.addOrUpdateChiTiet(targetItem);
        } else {
            // Không trùng -> Thêm dòng chi tiết giỏ hàng mới
            ChiTietGioHang newItem = new ChiTietGioHang();
            newItem.setMaGh(gh.getMaGh());
            newItem.setMaSp(maSp);
            newItem.setMaSize(maSize);
            newItem.setSoLuong(soLuong);
            newItem.setMucDa(mucDa);
            newItem.setMucDuong(mucDuong);
            newItem.setGhiChuMon(ghiChuMon);
            newItem.setChonMua(true);

            boolean isAdded = gioHangRepository.addOrUpdateChiTiet(newItem);
            if (isAdded && toppings != null && !toppings.isEmpty()) {
                // Thêm danh sách topping đi kèm liên kết với dòng chi tiết vừa sinh
                for (ChiTietToppingGioHang tp : toppings) {
                    gioHangRepository.addToppingToGioHang(newItem.getMaCtgh(), tp.getMaTp(), tp.getSoLuongTp());
                }
            }
            return isAdded;
        }
    }

    private boolean equalsString(String s1, String s2) {
        if (s1 == null && s2 == null) return true;
        if (s1 == null || s2 == null) return false;
        return s1.trim().equalsIgnoreCase(s2.trim());
    }

    private boolean isSameToppings(List<ChiTietToppingGioHang> list1, List<ChiTietToppingGioHang> list2) {
        int size1 = (list1 == null) ? 0 : list1.size();
        int size2 = (list2 == null) ? 0 : list2.size();
        if (size1 != size2) return false;
        if (size1 == 0) return true;

        for (ChiTietToppingGioHang tp1 : list1) {
            boolean found = false;
            for (ChiTietToppingGioHang tp2 : list2) {
                if (tp1.getMaTp() == tp2.getMaTp() && tp1.getSoLuongTp() == tp2.getSoLuongTp()) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }
        return true;
    }

    @Override
    public boolean updateSoLuongChiTiet(long maCtgh, int soLuongMoi) {
        if (soLuongMoi <= 0) {
            return deleteChiTietGioHang(maCtgh);
        }

        // Đọc thông tin chi tiết cũ để tiến hành cập nhật
        ChiTietGioHang chiTiet = new ChiTietGioHang();
        chiTiet.setMaCtgh(maCtgh);
        chiTiet.setSoLuong(soLuongMoi);
        chiTiet.setChonMua(true);
        return gioHangRepository.addOrUpdateChiTiet(chiTiet);
    }

    @Override
    public boolean deleteChiTietGioHang(long maCtgh) {
        // CSDL được cấu hình ON DELETE CASCADE tại bảng CHI_TIET_TOPPING_GIO_HANG
        return gioHangRepository.deleteChiTiet(maCtgh);
    }

    @Override
    public boolean clearGioHang(String maKh) {
        GioHang gh = gioHangRepository.getByKhachHang(maKh);
        if (gh != null) {
            return gioHangRepository.clearGioHang(gh.getMaGh());
        }
        return false;
    }

    @Override
    public boolean updateTrangThaiChonMua(long maCtgh, boolean isChon) {
        return gioHangRepository.updateTrangThaiChonMua(maCtgh, isChon);
    }
}
