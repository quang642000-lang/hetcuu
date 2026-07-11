package model.entity;

import java.util.ArrayList;
import java.util.List;

public class ChiTietDonHang {
    private long maCtdh;
    private String maDh;
    private String maSp;
    private int maSize;
    private int soLuong;
    private int giaChot;
    private String mucDa;
    private String mucDuong;
    private String ghiChuMon;
    private String tenSize; // THÊM ĐỂ ĐỒNG BỘ ĐỘNG TÊN SIZE XL/GIANT

    // QUAN HỆ 1-N: Một ly nước chi tiết có thể chọn đi kèm nhiều món Topping bổ sung
    private List<ChiTietTopping> toppingsList = new ArrayList<>();

    // Constructor mặc định không tham số
    public ChiTietDonHang() {}

    // Constructor đầy đủ tham số để map dữ liệu từ ResultSet của SQL Server
    public ChiTietDonHang(long maCtdh, String maDh, String maSp, int maSize, int soLuong,
                          int giaChot, String mucDa, String mucDuong, String ghiChuMon) {
        this.maCtdh = maCtdh;
        this.maDh = maDh;
        this.maSp = maSp;
        this.maSize = maSize;
        this.soLuong = soLuong;
        this.giaChot = giaChot;
        this.mucDa = mucDa;
        this.mucDuong = mucDuong;
        this.ghiChuMon = ghiChuMon;
    }

    // Getter và Setter cho các thuộc tính liên kết dữ liệu
    public long getMaCtdh() { return maCtdh; }
    public void setMaCtdh(long maCtdh) { this.maCtdh = maCtdh; }

    public String getMaDh() { return maDh; }
    public void setMaDh(String maDh) { this.maDh = maDh; }

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public int getMaSize() { return maSize; }
    public void setMaSize(int maSize) { this.maSize = maSize; }

    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

    public int getGiaChot() { return giaChot; }
    public void setGiaChot(int giaChot) { this.giaChot = giaChot; }

    public String getMucDa() { return mucDa; }
    public void setMucDa(String mucDa) { this.mucDa = mucDa; }

    public String getMucDuong() { return mucDuong; }
    public void setMucDuong(String mucDuong) { this.mucDuong = mucDuong; }

    public String getGhiChuMon() { return ghiChuMon; }
    public void setGhiChuMon(String ghiChuMon) { this.ghiChuMon = ghiChuMon; }

    public String getTenSize() { return tenSize; }
    public void setTenSize(String tenSize) { this.tenSize = tenSize; }

    // Hàm lấy danh sách Topping đi kèm của ly nước (Giải quyết triệt để lỗi getToppingsList)
    public List<ChiTietTopping> getToppingsList() { return toppingsList; }
    public void setToppingsList(List<ChiTietTopping> toppingsList) { this.toppingsList = toppingsList; }
}