package model.entity;

public class VaiTro {
    private int maVt;
    private String tenVt;
    private String moTa;

    public VaiTro() {}
    public VaiTro(int maVt, String tenVt, String moTa) { this.maVt = maVt; this.tenVt = tenVt; this.moTa = moTa; }

    public int getMaVt() { return maVt; }
    public void setMaVt(int maVt) { this.maVt = maVt; }
    public String getTenVt() { return tenVt; }
    public void setTenVt(String tenVt) { this.tenVt = tenVt; }
    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }
}