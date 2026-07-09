package model.entity;

public class HangThanhVien {
    private int maHang;
    private String tenHang;
    private int diemToiThieu;

    public HangThanhVien() {}
    public HangThanhVien(int maHang, String tenHang, int diemToiThieu) { this.maHang = maHang; this.tenHang = tenHang; this.diemToiThieu = diemToiThieu; }

    public int getMaHang() { return maHang; }
    public void setMaHang(int maHang) { this.maHang = maHang; }
    public String getTenHang() { return tenHang; }
    public void setTenHang(String tenHang) { this.tenHang = tenHang; }
    public int getDiemToiThieu() { return diemToiThieu; }
    public void setDiemToiThieu(int diemToiThieu) { this.diemToiThieu = diemToiThieu; }
}