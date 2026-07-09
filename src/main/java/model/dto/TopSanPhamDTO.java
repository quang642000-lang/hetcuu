package model.dto;

public class TopSanPhamDTO {
    private String maSp;
    private String tenSp;
    private String tenDm;
    private int tongSoLuongBan;
    private long doanhThuMangLai;

    // 1. Constructor không tham số
    public TopSanPhamDTO() {}

    // 2. Constructor đầy đủ tham số
    public TopSanPhamDTO(String maSp, String tenSp, String tenDm, int tongSoLuongBan, long doanhThuMangLai) {
        this.maSp = maSp;
        this.tenSp = tenSp;
        this.tenDm = tenDm;
        this.tongSoLuongBan = tongSoLuongBan;
        this.doanhThuMangLai = doanhThuMangLai;
    }

    // 3. Quyết toán Getters & Setters
    public String getMaSp() {
        return maSp;
    }

    public void setMaSp(String maSp) {
        this.maSp = maSp;
    }

    public String getTenSp() {
        return tenSp;
    }

    public void setTenSp(String tenSp) {
        this.tenSp = tenSp;
    }

    public String getTenDm() {
        return tenDm;
    }

    public void setTenDm(String tenDm) {
        this.tenDm = tenDm;
    }

    public int getTongSoLuongBan() {
        return tongSoLuongBan;
    }

    public void setTongSoLuongBan(int tongSoLuongBan) {
        this.tongSoLuongBan = tongSoLuongBan;
    }

    public long getDoanhThuMangLai() {
        return doanhThuMangLai;
    }

    public void setDoanhThuMangLai(long doanhThuMangLai) {
        this.doanhThuMangLai = doanhThuMangLai;
    }
}