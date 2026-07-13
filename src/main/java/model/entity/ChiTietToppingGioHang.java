package model.entity;

public class ChiTietToppingGioHang {
    private long maCtgh; // Khóa ngoại thuộc Composite Key
    private String maTp;    // Khóa ngoại thuộc Composite Key - chuyển đổi sang String
    private int soLuongTp;
    private int giaTp;
    private String tenTp; // CẢI TIẾN: Thêm thuộc tính lưu tên topping hiển thị tiếng Việt có dấu

    public ChiTietToppingGioHang() {}

    public ChiTietToppingGioHang(long maCtgh, String maTp, int soLuongTp) {
        this.maCtgh = maCtgh;
        this.maTp = maTp;
        this.soLuongTp = soLuongTp;
    }

    public long getMaCtgh() { return maCtgh; }
    public void setMaCtgh(long maCtgh) { this.maCtgh = maCtgh; }

    public String getMaTp() { return maTp; }
    public void setMaTp(String maTp) { this.maTp = maTp; }

    public int getSoLuongTp() { return soLuongTp; }
    public void setSoLuongTp(int soLuongTp) { this.soLuongTp = soLuongTp; }

    public int getGiaTp() { return giaTp; }
    public void setGiaTp(int giaTp) { this.giaTp = giaTp; }

    public String getTenTp() { return tenTp; }
    public void setTenTp(String tenTp) { this.tenTp = tenTp; }
}
