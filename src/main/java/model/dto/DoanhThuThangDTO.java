package model.dto;

public class DoanhThuThangDTO {
    private int nam;
    private int thang;
    private int soLuongDon;
    private long tongDoanhThu;

    // 1. Constructor không tham số
    public DoanhThuThangDTO() {}

    // 2. Constructor đầy đủ tham số
    public DoanhThuThangDTO(int nam, int thang, int soLuongDon, long tongDoanhThu) {
        this.nam = nam;
        this.thang = thang;
        this.soLuongDon = soLuongDon;
        this.tongDoanhThu = tongDoanhThu;
    }

    // 3. Quyết toán Getters & Setters
    public int getNam() {
        return nam;
    }

    public void setNam(int nam) {
        this.nam = nam;
    }

    public int getThang() {
        return thang;
    }

    public void setThang(int thang) {
        this.thang = thang;
    }

    public int getSoLuongDon() {
        return soLuongDon;
    }

    public void setSoLuongDon(int soLuongDon) {
        this.soLuongDon = soLuongDon;
    }

    public long getTongDoanhThu() {
        return tongDoanhThu;
    }

    public void setTongDoanhThu(long tongDoanhThu) {
        this.tongDoanhThu = tongDoanhThu;
    }
}