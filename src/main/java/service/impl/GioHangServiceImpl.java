package service.impl;

import model.entity.GioHang;
import model.entity.ChiTietGioHang;
import model.entity.ChiTietToppingGioHang;
import repository.IGioHangRepository;
import repository.impl.GioHangRepoImpl;
import service.IGioHangService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        try (java.sql.Connection conn = config.DBConnect.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            stmt.addBatch("DELETE FROM CHI_TIET_TOPPING_GIO_HANG WHERE ma_tp IN (SELECT ma_tp FROM TOPPING WHERE trang_thai = 0)");
            stmt.addBatch("DELETE FROM CHI_TIET_GIO_HANG WHERE ma_sp IN (SELECT ma_sp FROM SAN_PHAM WHERE trang_thai = 0)");
            stmt.addBatch("DELETE FROM CHI_TIET_GIO_HANG WHERE ma_ctgh IN (SELECT ct.ma_ctgh FROM CHI_TIET_GIO_HANG ct JOIN SAN_PHAM_KICH_CO sk ON ct.ma_sp = sk.ma_sp AND ct.ma_size = sk.ma_size WHERE sk.trang_thai = 0)");
            stmt.executeBatch();
        } catch(Exception e) {
            e.printStackTrace();
        }
        GioHang gh = gioHangRepository.getByKhachHang(maKh);
        if (gh == null) {
            gioHangRepository.createGioHang(maKh);
            gh = gioHangRepository.getByKhachHang(maKh);
        }
        if (gh != null) {
            List<ChiTietGioHang> items = gioHangRepository.getChiTietGioHang(gh.getMaGh());
            for (ChiTietGioHang item : items) {
                item.setToppingGioHangList(gioHangRepository.getToppingByChiTiet(item.getMaCtgh()));
            }
            gh.setChiTietGioHangList(items);
        }
        return gh;
    }

    private String normalizeIce(String da) {
        if (da == null) return "100% Đá";
        String d = da.trim().toLowerCase();
        if (d.isEmpty() || d.contains("100") || d.contains("normal") || d.contains("mặc định") || d.contains("đá thường")) {
            return "100% Đá";
        }
        if (d.contains("70") || d.contains("ít đá") || d.contains("it da")) {
            return "70% Đá";
        }
        if (d.contains("50") || d.contains("vừa") || d.contains("vua")) {
            return "50% Đá";
        }
        if (d.contains("0") || d.contains("không") || d.contains("khong")) {
            return "0% Đá";
        }
        return da.trim();
    }

    private String normalizeSugar(String duong) {
        if (duong == null) return "100% Đường";
        String d = duong.trim().toLowerCase();
        if (d.isEmpty() || d.contains("100") || d.contains("normal") || d.contains("mặc định") || d.contains("ngọt thường")) {
            return "100% Đường";
        }
        if (d.contains("70") || d.contains("ít ngọt") || d.contains("it ngot")) {
            return "70% Đường";
        }
        if (d.contains("50") || d.contains("vừa") || d.contains("vua")) {
            return "50% Đường";
        }
        if (d.contains("0") || d.contains("không") || d.contains("khong")) {
            return "0% Đường";
        }
        return duong.trim();
    }

    private String normalizeNote(String note) {
        if (note == null) return "";
        String n = note.trim().toLowerCase();
        if (n.isEmpty() || n.equals("normal") || n.equals("mặc định") || n.equals("không có") || n.equals("none") || n.equals("quick add")) {
            return "";
        }
        return note.trim();
    }

    private boolean areToppingsEqual(List<ChiTietToppingGioHang> listA, List<ChiTietToppingGioHang> listB) {
        Map<String, Integer> mapA = new HashMap<>();
        if (listA != null) {
            for (ChiTietToppingGioHang t : listA) {
                if (t.getMaTp() != null && !t.getMaTp().trim().isEmpty() && t.getSoLuongTp() > 0) {
                    mapA.put(t.getMaTp().trim(), t.getSoLuongTp());
                }
            }
        }
        Map<String, Integer> mapB = new HashMap<>();
        if (listB != null) {
            for (ChiTietToppingGioHang t : listB) {
                if (t.getMaTp() != null && !t.getMaTp().trim().isEmpty() && t.getSoLuongTp() > 0) {
                    mapB.put(t.getMaTp().trim(), t.getSoLuongTp());
                }
            }
        }
        return mapA.equals(mapB);
    }

    @Override
    public boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int qty, String da, String duong, String note, List<ChiTietToppingGioHang> toppings) {
        return addSanPhamToGioHang(maKh, maSp, maSize, qty, da, duong, note, toppings, false);
    }

    @Override
    public boolean addSanPhamToGioHang(String maKh, String maSp, int maSize, int qty, String da, String duong, String note, List<ChiTietToppingGioHang> toppings, boolean isBuyNow) {
        GioHang gh = gioHangRepository.getByKhachHang(maKh);
        if (gh == null) {
            gioHangRepository.createGioHang(maKh);
            gh = gioHangRepository.getByKhachHang(maKh);
        }
        if (gh == null) return false;
        String normDa = normalizeIce(da);
        String normDuong = normalizeSugar(duong);
        String normNote = normalizeNote(note);

        ChiTietGioHang targetItem = null;
        if (!isBuyNow) { // BỎ QUA KIỂM TRA TRÙNG LẶP NẾU LÀ "MUA NGAY" ĐỂ KHÔNG BỊ GÔM CHUNG ĐƠN CŨ!
            List<ChiTietGioHang> existingDetails = gioHangRepository.getChiTietGioHang(gh.getMaGh());
            for (ChiTietGioHang item : existingDetails) {
                if (item.getMaSp().equals(maSp) && item.getMaSize() == maSize) {
                    String itemDa = normalizeIce(item.getMucDa());
                    String itemDuong = normalizeSugar(item.getMucDuong());
                    String itemNote = normalizeNote(item.getGhiChuMon());
                    if (itemDa.equalsIgnoreCase(normDa) &&
                            itemDuong.equalsIgnoreCase(normDuong) &&
                            itemNote.equalsIgnoreCase(normNote)) {
                        List<ChiTietToppingGioHang> existingToppings = gioHangRepository.getToppingByChiTiet(item.getMaCtgh());
                        if (areToppingsEqual(existingToppings, toppings)) {
                            targetItem = item;
                            break;
                        }
                    }
                }
            }
        }

        if (targetItem != null) {
            targetItem.setSoLuong(targetItem.getSoLuong() + qty);
            targetItem.setMucDa(normDa);
            targetItem.setMucDuong(normDuong);
            targetItem.setGhiChuMon(normNote);
            targetItem.setChonMua(true); // Luôn tích chọn sản phẩm vừa thêm
            return gioHangRepository.addOrUpdateChiTiet(targetItem);
        } else {
            ChiTietGioHang newItem = new ChiTietGioHang();
            newItem.setMaGh(gh.getMaGh());
            newItem.setMaSp(maSp);
            newItem.setMaSize(maSize);
            newItem.setSoLuong(qty);
            newItem.setMucDa(normDa);
            newItem.setMucDuong(normDuong);
            newItem.setGhiChuMon(normNote);
            newItem.setChonMua(true); // Luôn tích chọn mua đối với sản phẩm mới
            newItem.setToppingGioHangList(toppings);
            return gioHangRepository.addOrUpdateChiTiet(newItem);
        }
    }

    @Override
    public boolean updateSoLuongChiTiet(long maCtgh, int qty) {
        if (qty <= 0) {
            return gioHangRepository.deleteChiTiet(maCtgh);
        }
        ChiTietGioHang detail = new ChiTietGioHang();
        detail.setMaCtgh(maCtgh);
        detail.setSoLuong(qty);
        return gioHangRepository.addOrUpdateChiTiet(detail);
    }

    @Override
    public boolean deleteChiTietGioHang(long maCtgh) {
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
