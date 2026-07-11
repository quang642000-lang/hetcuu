package model.entity;

public class Topping {
    private int maTp;
    private String tenTp;
    private String dinhLuong;
    private int giaBan;
    private int thuTuHienThi;
    private boolean trangThai;
    private String hinhAnh; // BỔ SUNG THUỘC TÍNH HÌNH ẢNH TOPPING THEO YÊU CẦU

    public Topping() {}

    public Topping(int maTp, String tenTp, String dinhLuong, int giaBan, int thuTuHienThi, boolean trangThai) {
        this.maTp = maTp;
        this.tenTp = tenTp;
        this.dinhLuong = dinhLuong;
        this.giaBan = giaBan;
        this.thuTuHienThi = thuTuHienThi;
        this.trangThai = trangThai;
    }

    public Topping(int maTp, String tenTp, String dinhLuong, int giaBan, int thuTuHienThi, boolean trangThai, String hinhAnh) {
        this.maTp = maTp;
        this.tenTp = tenTp;
        this.dinhLuong = dinhLuong;
        this.giaBan = giaBan;
        this.thuTuHienThi = thuTuHienThi;
        this.trangThai = trangThai;
        this.hinhAnh = hinhAnh;
    }

    public int getMaTp() { return maTp; }
    public void setMaTp(int maTp) { this.maTp = maTp; }

    public String getTenTp() { return tenTp; }
    public void setTenTp(String tenTp) { this.tenTp = tenTp; }

    public String getDinhLuong() { return dinhLuong; }
    public void setDinhLuong(String dinhLuong) { this.dinhLuong = dinhLuong; }

    public int getGiaBan() { return giaBan; }
    public void setGiaBan(int giaBan) { this.giaBan = giaBan; }

    public int getThuTuHienThi() { return thuTuHienThi; }
    public void setThuTuHienThi(int thuTuHienThi) { this.thuTuHienThi = thuTuHienThi; }

    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }

    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }
}
