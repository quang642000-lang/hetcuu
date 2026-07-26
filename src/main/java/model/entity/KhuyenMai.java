package model.entity;

import java.sql.Timestamp;

public class KhuyenMai {
    private String maKm;
    private String tenKm;
    private String maCode;
    private String moTaDieuKien;
    private String hinhAnhUrl;
    private int loaiGiam; // 1: Tiền mặt, 2: %
    private int giaTriGiam;
    private int giamToiDa;
    private int donToiThieu;
    private boolean isPublic;
    private int soLuong; // Số lượng cài đặt ban đầu
    private Timestamp ngayBatDau;
    private Timestamp ngayKetThuc;
    private boolean trangThai;
    private int soLuotDungCaNhan = 0;
    private int hangApDung = 1; // 1: Đồng, 2: Bạc, 3: Vàng, 4: VIP
    private int loaiVoucher = 1; // 1: Hội viên CRM, 2: Giấy công khai

    // Các thuộc tính bọc lót tính toán động hiển thị UI
    private int soLuongDaDung = 0; // Đếm từ số lượng hóa đơn thực tế
    private int soLuotDaDungCaNhan = 0; // Đếm số lần dùng của riêng khách hàng đó

    public KhuyenMai() {}

    public KhuyenMai(String maKm, String tenKm, String maCode, String moTaDieuKien, String hinhAnhUrl, int loaiGiam, int giaTriGiam, int giamToiDa, int donToiThieu, boolean isPublic, int soLuong, Timestamp ngayBatDau, Timestamp ngayKetThuc, boolean trangThai) {
        this.maKm = maKm;
        this.tenKm = tenKm;
        this.maCode = maCode;
        this.moTaDieuKien = moTaDieuKien;
        this.hinhAnhUrl = hinhAnhUrl;
        this.loaiGiam = loaiGiam;
        this.giaTriGiam = giaTriGiam;
        this.giamToiDa = giamToiDa;
        this.donToiThieu = donToiThieu;
        this.isPublic = isPublic;
        this.soLuong = soLuong;
        this.ngayBatDau = ngayBatDau;
        this.ngayKetThuc = ngayKetThuc;
        this.trangThai = trangThai;
    }

    public KhuyenMai(String maKm, String tenKm, String maCode, String moTaDieuKien, String hinhAnhUrl, int loaiGiam, int giaTriGiam, int giamToiDa, int donToiThieu, boolean isPublic, int soLuong, Timestamp ngayBatDau, Timestamp ngayKetThuc, boolean trangThai, int soLuotDungCaNhan, int hangApDung, int loaiVoucher) {
        this.maKm = maKm;
        this.tenKm = tenKm;
        this.maCode = maCode;
        this.moTaDieuKien = moTaDieuKien;
        this.hinhAnhUrl = hinhAnhUrl;
        this.loaiGiam = loaiGiam;
        this.giaTriGiam = giaTriGiam;
        this.giamToiDa = giamToiDa;
        this.donToiThieu = donToiThieu;
        this.isPublic = isPublic;
        this.soLuong = soLuong;
        this.ngayBatDau = ngayBatDau;
        this.ngayKetThuc = ngayKetThuc;
        this.trangThai = trangThai;
        this.soLuotDungCaNhan = soLuotDungCaNhan;
        this.hangApDung = hangApDung;
        this.loaiVoucher = loaiVoucher;
    }

    public String getMaKm() { return maKm; }
    public void setMaKm(String maKm) { this.maKm = maKm; }
    public String getTenKm() { return tenKm; }
    public void setTenKm(String tenKm) { this.tenKm = tenKm; }
    public String getMaCode() { return maCode; }
    public void setMaCode(String maCode) { this.maCode = maCode; }
    public String getMoTaDieuKien() { return moTaDieuKien; }
    public void setMoTaDieuKien(String moTaDieuKien) { this.moTaDieuKien = moTaDieuKien; }
    public String getHinhAnhUrl() { return hinhAnhUrl; }
    public void setHinhAnhUrl(String hinhAnhUrl) { this.hinhAnhUrl = hinhAnhUrl; }
    public int getLoaiGiam() { return loaiGiam; }
    public void setLoaiGiam(int loaiGiam) { this.loaiGiam = loaiGiam; }
    public int getGiaTriGiam() { return giaTriGiam; }
    public void setGiaTriGiam(int giaTriGiam) { this.giaTriGiam = giaTriGiam; }
    public int getGiamToiDa() { return giamToiDa; }
    public void setGiamToiDa(int giamToiDa) { this.giamToiDa = giamToiDa; }
    public int getDonToiThieu() { return donToiThieu; }
    public void setDonToiThieu(int donToiThieu) { this.donToiThieu = donToiThieu; }
    public boolean isPublic() { return isPublic; }
    public void setPublic(boolean isPublic) { this.isPublic = isPublic; }
    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }
    public Timestamp getNgayBatDau() { return ngayBatDau; }
    public void setNgayBatDau(Timestamp ngayBatDau) { this.ngayBatDau = ngayBatDau; }
    public Timestamp getNgayKetThuc() { return ngayKetThuc; }
    public void setNgayKetThuc(Timestamp ngayKetThuc) { this.ngayKetThuc = ngayKetThuc; }
    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }
    public int getSoLuotDungCaNhan() { return soLuotDungCaNhan; }
    public void setSoLuotDungCaNhan(int soLuotDungCaNhan) { this.soLuotDungCaNhan = soLuotDungCaNhan; }
    public int getHangApDung() { return hangApDung; }
    public void setHangApDung(int hangApDung) { this.hangApDung = hangApDung; }
    public int getLoaiVoucher() { return loaiVoucher; }
    public void setLoaiVoucher(int loaiVoucher) { this.loaiVoucher = loaiVoucher; }
    public int getSoLuongDaDung() { return soLuongDaDung; }
    public void setSoLuongDaDung(int soLuongDaDung) { this.soLuongDaDung = soLuongDaDung; }
    public int getSoLuotDaDungCaNhan() { return soLuotDaDungCaNhan; }
    public void setSoLuotDaDungCaNhan(int soLuotDaDungCaNhan) { this.soLuotDaDungCaNhan = soLuotDaDungCaNhan; }
}
