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

    // Thuộc tính bổ trợ lấy từ SAN_PHAM để render trực quan trên giao diện giỏ hàng
    private String tenSp;
    private String hinhAnh;

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

    // SỬA LỖI JAVABEANS: Khai báo đầy đủ 3 kiểu Getter để tương thích tuyệt đối với mọi cấu hình Tomcat/JSTL EL
    public boolean isChonMua() {
        return isChonMua;
    }

    public boolean getChonMua() {
        return isChonMua;
    } // Ánh xạ chuẩn cho EL ${item.chonMua}

    public boolean getIsChonMua() {
        return isChonMua;
    } // Ánh xạ dự phòng tương thích ngược cho EL ${item.isChonMua}

    public void setChonMua(boolean isChonMua) { this.isChonMua = isChonMua; }
    public Timestamp getThoiGianThem() { return thoiGianThem; }
    public void setThoiGianThem(Timestamp thoiGianThem) { this.thoiGianThem = thoiGianThem; }
    public int getGiaBan() { return giaBan; }
    public void setGiaBan(int giaBan) { this.giaBan = giaBan; }

    public String getTenSp() { return tenSp; }
    public void setTenSp(String tenSp) { this.tenSp = tenSp; }
    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }

    public List<ChiTietToppingGioHang> getToppingGioHangList() { return toppingGioHangList; }
    public void setToppingGioHangList(List<ChiTietToppingGioHang> toppingGioHangList) { this.toppingGioHangList = toppingGioHangList; }
}
