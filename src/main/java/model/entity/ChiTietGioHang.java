package model.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ChiTietGioHang {
    private long maCtgh;
    private int maGh;
    private String maSp;
    private int maSize;
    private int soLuong;
    private String mucDa;
    private String mucDuong;
    private String ghiChuMon;
    private boolean isChonMua;
    private Timestamp thoiGianThem;
    private int giaBan;
    private String tenSize;

    // OOP Association: Holds direct reference to product mother properties (tenSp, hinhAnh, choPhepDoiDa, choPhepDoiDuong)
    private SanPham sanPham;

    private List<ChiTietToppingGioHang> toppingGioHangList = new ArrayList<>();

    public ChiTietGioHang() {}

    public ChiTietGioHang(long maCtgh, int maGh, String maSp, int maSize, int soLuong,
                          String mucDa, String mucDuong, String ghiChuMon,
                          boolean isChonMua, Timestamp thoiGianThem) {
        this.maCtgh = maCtgh;
        this.maGh = maGh;
        this.maSp = maSp;
        this.maSize = maSize;
        this.soLuong = soLuong;
        this.mucDa = mucDa;
        this.mucDuong = mucDuong;
        this.ghiChuMon = ghiChuMon;
        this.isChonMua = isChonMua;
        this.thoiGianThem = thoiGianThem;
    }

    public long getMaCtgh() { return maCtgh; }
    public void setMaCtgh(long maCtgh) { this.maCtgh = maCtgh; }
    public int getMaGh() { return maGh; }
    public void setMaGh(int maGh) { this.maGh = maGh; }
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }
    public int getMaSize() { return maSize; }
    public void setMaSize(int maSize) { this.maSize = maSize; }
    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }
    public String getMucDa() { return mucDa; }
    public void setMucDa(String mucDa) { this.mucDa = mucDa; }
    public String getMucDuong() { return mucDuong; }
    public void setMucDuong(String mucDuong) { this.mucDuong = mucDuong; }
    public String getGhiChuMon() { return ghiChuMon; }
    public void setGhiChuMon(String ghiChuMon) { this.ghiChuMon = ghiChuMon; }

    public boolean isChonMua() { return isChonMua; }
    public boolean getChonMua() { return isChonMua; } // Matches JSTL EL ${item.chonMua}
    public boolean getIsChonMua() { return isChonMua; } // Fallback
    public void setChonMua(boolean isChonMua) { this.isChonMua = isChonMua; }

    public Timestamp getThoiGianThem() { return thoiGianThem; }
    public void setThoiGianThem(Timestamp thoiGianThem) { this.thoiGianThem = thoiGianThem; }
    public int getGiaBan() { return giaBan; }
    public void setGiaBan(int giaBan) { this.giaBan = giaBan; }
    public String getTenSize() { return tenSize; }
    public void setTenSize(String tenSize) { this.tenSize = tenSize; }

    public SanPham getSanPham() { return sanPham; }
    public void setSanPham(SanPham sanPham) { this.sanPham = sanPham; }

    public List<ChiTietToppingGioHang> getToppingGioHangList() { return toppingGioHangList; }
    public void setToppingGioHangList(List<ChiTietToppingGioHang> toppingGioHangList) { this.toppingGioHangList = toppingGioHangList; }
}
