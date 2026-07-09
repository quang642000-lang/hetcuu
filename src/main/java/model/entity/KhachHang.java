package model.entity;

import java.sql.Date;
import java.sql.Timestamp;

public class KhachHang {
    private String maKh;
    private int maHang;
    private String soDienThoai;
    private String tenKh;
    private String email;
    private String matKhau;
    private Date ngaySinh;
    private String gioiTinh;
    private String diaChiLienHe;
    private String hinhAnhUrl;
    private int diemTichLuy;
    private boolean trangThai;
    private Timestamp thoiGianTao;
    private Timestamp thoiGianCapNhat;

    // Constructor rỗng (Bắt buộc phải có để Service gọi new KhachHang())
    public KhachHang() {}

    // Constructor đầy đủ tham số
    public KhachHang(String maKh, int maHang, String soDienThoai, String tenKh, String email, String matKhau,
                     Date ngaySinh, String gioiTinh, String diaChiLienHe, String hinhAnhUrl,
                     int diemTichLuy, boolean trangThai, Timestamp thoiGianTao, Timestamp thoiGianCapNhat) {
        this.maKh = maKh;
        this.maHang = maHang;
        this.soDienThoai = soDienThoai;
        this.tenKh = tenKh;
        this.email = email;
        this.matKhau = matKhau;
        this.ngaySinh = ngaySinh;
        this.gioiTinh = gioiTinh;
        this.diaChiLienHe = diaChiLienHe;
        this.hinhAnhUrl = hinhAnhUrl;
        this.diemTichLuy = diemTichLuy;
        this.trangThai = trangThai;
        this.thoiGianTao = thoiGianTao;
        this.thoiGianCapNhat = thoiGianCapNhat;
    }

    // Các hàm Getter và Setter
    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }

    public int getMaHang() { return maHang; }
    public void setMaHang(int maHang) { this.maHang = maHang; }

    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }

    public String getTenKh() { return tenKh; }
    public void setTenKh(String tenKh) { this.tenKh = tenKh; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMatKhau() { return matKhau; }
    public void setMatKhau(String matKhau) { this.matKhau = matKhau; }

    public Date getNgaySinh() { return ngaySinh; }
    public void setNgaySinh(Date ngaySinh) { this.ngaySinh = ngaySinh; }

    public String getGioiTinh() { return gioiTinh; }
    public void setGioiTinh(String gioiTinh) { this.gioiTinh = gioiTinh; }

    public String getDiaChiLienHe() { return diaChiLienHe; }
    public void setDiaChiLienHe(String diaChiLienHe) { this.diaChiLienHe = diaChiLienHe; }

    public String getHinhAnhUrl() { return hinhAnhUrl; }
    public void setHinhAnhUrl(String hinhAnhUrl) { this.hinhAnhUrl = hinhAnhUrl; }

    public int getDiemTichLuy() { return diemTichLuy; }
    public void setDiemTichLuy(int diemTichLuy) { this.diemTichLuy = diemTichLuy; }

    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }

    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }

    public Timestamp getThoiGianCapNhat() { return thoiGianCapNhat; }
    public void setThoiGianCapNhat(Timestamp thoiGianCapNhat) { this.thoiGianCapNhat = thoiGianCapNhat; }
}