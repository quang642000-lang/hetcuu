package model.entity;

public class KichCo {
    private int maSize;
    private String tenSize;
    private int thuTuHienThi;

    public KichCo() {}
    public KichCo(int maSize, String tenSize, int thuTuHienThi) { this.maSize = maSize; this.tenSize = tenSize; this.thuTuHienThi = thuTuHienThi; }

    public int getMaSize() { return maSize; }
    public void setMaSize(int maSize) { this.maSize = maSize; }
    public String getTenSize() { return tenSize; }
    public void setTenSize(String tenSize) { this.tenSize = tenSize; }
    public int getThuTuHienThi() { return thuTuHienThi; }
    public void setThuTuHienThi(int thuTuHienThi) { this.thuTuHienThi = thuTuHienThi; }
}