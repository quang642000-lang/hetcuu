package model.entity;

import java.sql.Timestamp;

public class NhanVien {
    private String maNv;
    private int maVt;
    private String hoTen;
    private String soDienThoai;
    private String email;
    private String tenDangNhap;
    private String matKhau;
    private boolean trangThai;
    private Timestamp thoiGianTao;
    private Timestamp thoiGianCapNhat;

    public NhanVien() {}
    public NhanVien(String maNv, int maVt, String hoTen, String soDienThoai, String email, String tenDangNhap, String matKhau, boolean trangThai, Timestamp thoiGianTao, Timestamp thoiGianCapNhat) {
        this.maNv = maNv; this.maVt = maVt; this.hoTen = hoTen; this.soDienThoai = soDienThoai; this.email = email; this.tenDangNhap = tenDangNhap; this.matKhau = matKhau; this.trangThai = trangThai; this.thoiGianTao = thoiGianTao; this.thoiGianCapNhat = thoiGianCapNhat;
    }

    public String getMaNv() { return maNv; }
    public void setMaNv(String maNv) { this.maNv = maNv; }
    public int getMaVt() { return maVt; }
    public void setMaVt(int maVt) { this.maVt = maVt; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }
    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTenDangNhap() { return tenDangNhap; }
    public void setTenDangNhap(String tenDangNhap) { this.tenDangNhap = tenDangNhap; }
    public String getMatKhau() { return matKhau; }
    public void setMatKhau(String matKhau) { this.matKhau = matKhau; }
    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }
    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }
    public Timestamp getThoiGianCapNhat() { return thoiGianCapNhat; }
    public void setThoiGianCapNhat(Timestamp thoiGianCapNhat) { this.thoiGianCapNhat = thoiGianCapNhat; }
}