package model.dto;

public class DoanhThuDanhMucDTO {
    private String maDm;
    private String tenDm;
    private int tongSanPhamBan;
    private long tongDoanhThu;

    public DoanhThuDanhMucDTO() {}

    public DoanhThuDanhMucDTO(String maDm, String tenDm, int tongSanPhamBan, long tongDoanhThu) {
        this.maDm = maDm;
        this.tenDm = tenDm;
        this.tongSanPhamBan = tongSanPhamBan;
        this.tongDoanhThu = tongDoanhThu;
    }

    public String getMaDm() {
        return maDm;
    }

    public void setMaDm(String maDm) {
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
