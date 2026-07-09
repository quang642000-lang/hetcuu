package model.dto;

import java.sql.Date;

public class DoanhThuNgayDTO {
    private Date ngay;
    private int soLuongDon;
    private long tongDoanhThu;

    // 1. Constructor không tham số
    public DoanhThuNgayDTO() {}

    // 2. Constructor đầy đủ tham số
    public DoanhThuNgayDTO(Date ngay, int soLuongDon, long tongDoanhThu) {
        this.ngay = ngay;
        this.soLuongDon = soLuongDon;
        this.tongDoanhThu = tongDoanhThu;
    }

    // 3. Quyết toán Getters & Setters
    public Date getNgay() {
        return ngay;
    }

    public void setNgay(Date ngay) {
        this.ngay = ngay;
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