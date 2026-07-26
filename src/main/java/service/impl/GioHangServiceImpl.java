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

    // NORMALIZE ICE (Ice default is 100% Đá, handle nulls and empty strings)
    private String normalizeIce(String da) {
        if (da == null) return "100% Đá";
        String d = da.trim().toLowerCase();
        if (d.isEmpty() || d.equals("100%") || d.contains("normal") || d.contains("mặc định") || d.contains("100% đá") || d.contains("100% da")) {
            return "100% Đá";
        }
        return da.trim();
    }

    // NORMALIZE SUGAR (Sugar default is 100% Đường, handle nulls and empty strings)
    private String normalizeSugar(String duong) {
        if (duong == null) return "100% Đường";
        String d = duong.trim().toLowerCase();
        if (d.isEmpty() || d.equals("100%") || d.contains("normal") || d.contains("mặc định") || d.contains("100% đường") || d.contains("100% duong")) {
            return "100% Đường";
        }
        return duong.trim();
    }

    // NORMALIZE NOTE (Handle nulls, default notes, "normal")
    private String normalizeNote(String note) {
        if (note == null) return "";
        String n = note.trim().toLowerCase();
        if (n.isEmpty() || n.equals("normal") || n.equals("mặc định") || n.equals("không có") || n.equals("none")) {
            return "";
        }
        return note.trim();
    }

    // MATCH TOPPINGS REAL-TIME (Robust Map-based exact comparison)
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
        GioHang gh = gioHangRepository.getByKhachHang(maKh);
        if (gh == null) {
            gioHangRepository.createGioHang(maKh);
            gh = gioHangRepository.getByKhachHang(maKh);
        }
        if (gh == null) return false;

        // Normalizing incoming parameters
        String normDa = normalizeIce(da);
        String normDuong = normalizeSugar(duong);
        String normNote = normalizeNote(note);

        // Fetching existing items in the cart
        List<ChiTietGioHang> existingDetails = gioHangRepository.getChiTietGioHang(gh.getMaGh());
        ChiTietGioHang targetItem = null;

        for (ChiTietGioHang item : existingDetails) {
            if (item.getMaSp().equals(maSp) && item.getMaSize() == maSize) {
                // Normalizing database values for precise matching
                String itemDa = normalizeIce(item.getMucDa());
                String itemDuong = normalizeSugar(item.getMucDuong());
                String itemNote = normalizeNote(item.getGhiChuMon());

                if (itemDa.equalsIgnoreCase(normDa) &&
                        itemDuong.equalsIgnoreCase(normDuong) &&
                        itemNote.equalsIgnoreCase(normNote)) {

                    // Compare toppings of existing item
                    List<ChiTietToppingGioHang> existingToppings = gioHangRepository.getToppingByChiTiet(item.getMaCtgh());
                    if (areToppingsEqual(existingToppings, toppings)) {
                        targetItem = item;
                        break;
                    }
                }
            }
        }

        if (targetItem != null) {
            // MATCH FOUND! GỘP MÓN: Increment existing item's quantity
            targetItem.setSoLuong(targetItem.getSoLuong() + qty);
            targetItem.setMucDa(normDa);
            targetItem.setMucDuong(normDuong);
            targetItem.setGhiChuMon(normNote);
            return gioHangRepository.addOrUpdateChiTiet(targetItem);
        } else {
            // NO MATCH FOUND! Insert new unique item line
            ChiTietGioHang newItem = new ChiTietGioHang();
            newItem.setMaGh(gh.getMaGh());
            newItem.setMaSp(maSp);
            newItem.setMaSize(maSize);
            newItem.setSoLuong(qty);
            newItem.setMucDa(normDa);
            newItem.setMucDuong(normDuong);
            newItem.setGhiChuMon(normNote);
            newItem.setChonMua(true);
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
        // Fetch original item to preserve other values on basic update
        // (addOrUpdateChiTiet is robust and updates what is provided)
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
