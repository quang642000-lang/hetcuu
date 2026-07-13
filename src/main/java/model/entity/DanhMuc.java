package model.entity;

public class DanhMuc {
    private String maDm;
    private String tenDm;
    private String hinhAnh;
    private int thuTuHienThi;
    private boolean trangThai;

    public DanhMuc() {}

    public DanhMuc(String maDm, String tenDm, String hinhAnh, int thuTuHienThi, boolean trangThai) {
        this.maDm = maDm;
        this.tenDm = tenDm;
        this.hinhAnh = hinhAnh;
        this.thuTuHienThi = thuTuHienThi;
        this.trangThai = trangThai;
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

    public String getHinhAnh() {
        return hinhAnh;
    }

    public void setHinhAnh(String hinhAnh) {
        this.hinhAnh = hinhAnh;
    }

    public int getThuTuHienThi() {
        return thuTuHienThi;
    }

    public void setThuTuHienThi(int thuTuHienThi) {
        this.thuTuHienThi = thuTuHienThi;
    }

    public boolean isTrangThai() {
        return trangThai;
    }

    public void setTrangThai(boolean trangThai) {
        this.trangThai = trangThai;
    }
}
