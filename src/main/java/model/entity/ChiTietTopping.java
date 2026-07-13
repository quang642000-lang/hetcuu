package model.entity;

public class ChiTietTopping {
    private long maCtdh;
    private int maTp;
    private int soLuong;
    private int giaChotTp;
    private String tenTopping; // Bổ sung tên topping để hiển thị có dấu chuẩn chỉ

    // Constructor mặc định không tham số
    public ChiTietTopping() {}

    // Constructor đầy đủ tham số để map dữ liệu từ ResultSet của SQL Server
    public ChiTietTopping(long maCtdh, int maTp, int soLuong, int giaChotTp) {
        this.maCtdh = maCtdh;
        this.maTp = maTp;
        this.soLuong = soLuong;
        this.giaChotTp = giaChotTp;
    }

    // Constructor mở rộng kèm tên topping
    public ChiTietTopping(long maCtdh, int maTp, int soLuong, int giaChotTp, String tenTopping) {
        this.maCtdh = maCtdh;
        this.maTp = maTp;
        this.soLuong = soLuong;
        this.giaChotTp = giaChotTp;
        this.tenTopping = tenTopping;
    }

    // Getter và Setter cho các thuộc tính liên kết dữ liệu
    public long getMaCtdh() {
        return maCtdh;
    }

    public void setMaCtdh(long maCtdh) {
        this.maCtdh = maCtdh;
    }

    public int getMaTp() {
        return maTp;
    }

    public void setMaTp(int maTp) {
        this.maTp = maTp;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public int getGiaChotTp() {
        return giaChotTp;
    }

    public void setGiaChotTp(int giaChotTp) {
        this.giaChotTp = giaChotTp;
    }

    public String getTenTopping() {
        return tenTopping;
    }

    public void setTenTopping(String tenTopping) {
        this.tenTopping = tenTopping;
    }
}
