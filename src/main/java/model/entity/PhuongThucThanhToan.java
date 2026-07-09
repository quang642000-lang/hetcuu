package model.entity;

public class PhuongThucThanhToan {
    private int maPt;
    private String tenPt;
    private boolean trangThai;

    public PhuongThucThanhToan() {}
    public PhuongThucThanhToan(int maPt, String tenPt, boolean trangThai) { this.maPt = maPt; this.tenPt = tenPt; this.trangThai = trangThai; }

    public int getMaPt() { return maPt; }
    public void setMaPt(int maPt) { this.maPt = maPt; }
    public String getTenPt() { return tenPt; }
    public void setTenPt(String tenPt) { this.tenPt = tenPt; }
    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }
}