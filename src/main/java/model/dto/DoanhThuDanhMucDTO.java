package model.dto;

public class DoanhThuDanhMucDTO {
    private int maDm;
    private String tenDm;
    private int tongSanPhamBan;
    private long tongDoanhThu;

    // 1. Constructor không tham số
    public DoanhThuDanhMucDTO() {}

    // 2. Constructor đầy đủ tham số
    public DoanhThuDanhMucDTO(int maDm, String tenDm, int tongSanPhamBan, long tongDoanhThu) {
        this.maDm = maDm;
        this.tenDm = tenDm;
        this.tongSanPhamBan = tongSanPhamBan;
        this.tongDoanhThu = tongDoanhThu;
    }

    // 3. Quyết toán Getters & Setters
    public int getMaDm() {
        return maDm;
    }

    public void setMaDm(int maDm) {
        this.maDm = maDm;
    }

    public String getTenDm() {
        return tenDm;
    }

    public void setTenDm(String tenDm) {
        this.tenDm = tenDm;
    }

    public int getTongSanPhamBan() {
        return tongSanPhamBan;
    }

    public void setTongSanPhamBan(int tongSanPhamBan) {
        this.tongSanPhamBan = tongSanPhamBan;
    }

    public long getTongDoanhThu() {
        return tongDoanhThu;
    }

    public void setTongDoanhThu(long tongDoanhThu) {
        this.tongDoanhThu = tongDoanhThu;
    }
}