package model.entity;

public class SanPhamKichCo {
    private String maSp;       // Khóa ngoại thuộc Composite Key
    private int maSize;        // Khóa ngoại thuộc Composite Key
    private int giaBan;
    private String dinhLuong;
    private boolean trangThai;
    private String tenSize;    // THÊM ĐỂ ĐỌC DỮ LIỆU SIZE ĐỘNG TỪ BẢNG KICH_CO

    public SanPhamKichCo() {}

    public SanPhamKichCo(String maSp, int maSize, int giaBan, String dinhLuong, boolean trangThai) {
        this.maSp = maSp;
        this.maSize = maSize;
        this.giaBan = giaBan;
        this.dinhLuong = dinhLuong;
        this.trangThai = trangThai;
    }

    // Overloaded constructor để tiện bóc tách dữ liệu có tên Size
    public SanPhamKichCo(String maSp, int maSize, int giaBan, String dinhLuong, boolean trangThai, String tenSize) {
        this.maSp = maSp;
        this.maSize = maSize;
        this.giaBan = giaBan;
        this.dinhLuong = dinhLuong;
        this.trangThai = trangThai;
        this.tenSize = tenSize;
    }

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public int getMaSize() { return maSize; }
    public void setMaSize(int maSize) { this.maSize = maSize; }

    public int getGiaBan() { return giaBan; }
    public void setGiaBan(int giaBan) { this.giaBan = giaBan; }

    public String getDinhLuong() { return dinhLuong; }
    public void setDinhLuong(String dinhLuong) { this.dinhLuong = dinhLuong; }

    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }

    public String getTenSize() { return tenSize; }
    public void setTenSize(String tenSize) { this.tenSize = tenSize; }
}
