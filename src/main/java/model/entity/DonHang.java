package model.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DonHang {
    private String maDh;
    private String maKh;
    private String maNv;
    private int maPt;
    private String maKm;
    private int loaiDonHang;
    private Timestamp thoiGianHenLay;
    private int tongTienHang;
    private int tienGiamGia;
    private int diemSuDung;
    private int tienTruDiem;
    private int tongPhaiTra;
    private String ghiChuDon;
    private String lyDoHuy;
    private int trangThaiThanhToan;
    private int trangThaiDon;
    private Timestamp thoiGianTao;
    private Timestamp thoiGianHoanThanh;

    // QUAN HỆ 1-N: Một đơn hàng có chứa danh sách nhiều chi tiết ly nước uống
    private List<ChiTietDonHang> chiTietDonHangList = new ArrayList<>();

    // Constructor mặc định không tham số
    public DonHang() {}

    // Constructor đầy đủ tham số để map dữ liệu từ ResultSet của SQL Server
    public DonHang(String maDh, String maKh, String maNv, int maPt, String maKm, int loaiDonHang,
                   Timestamp thoiGianHenLay, int tongTienHang, int tienGiamGia, int diemSuDung,
                   int tienTruDiem, int tongPhaiTra, String ghiChuDon, String lyDoHuy,
                   int trangThaiThanhToan, int trangThaiDon, Timestamp thoiGianTao, Timestamp thoiGianHoanThanh) {
        this.maDh = maDh;
        this.maKh = maKh;
        this.maNv = maNv;
        this.maPt = maPt;
        this.maKm = maKm;
        this.loaiDonHang = loaiDonHang;
        this.thoiGianHenLay = thoiGianHenLay;
        this.tongTienHang = tongTienHang;
        this.tienGiamGia = tienGiamGia;
        this.diemSuDung = diemSuDung;
        this.tienTruDiem = tienTruDiem;
        this.tongPhaiTra = tongPhaiTra;
        this.ghiChuDon = ghiChuDon;
        this.lyDoHuy = lyDoHuy;
        this.trangThaiThanhToan = trangThaiThanhToan;
        this.trangThaiDon = trangThaiDon;
        this.thoiGianTao = thoiGianTao;
        this.thoiGianHoanThanh = thoiGianHoanThanh;
    }

    // Getter và Setter cho các thuộc tính liên kết dữ liệu
    public String getMaDh() {
        return maDh;
    }

    public void setMaDh(String maDh) {
        this.maDh = maDh;
    }

    public String getMaKh() {
        return maKh;
    }

    public void setMaKh(String maKh) {
        this.maKh = maKh;
    }

    public String getMaNv() {
        return maNv;
    }

    public void setMaNv(String maNv) {
        this.maNv = maNv;
    }

    public int getMaPt() {
        return maPt;
    }

    public void setMaPt(int maPt) {
        this.maPt = maPt;
    }

    public String getMaKm() {
        return maKm;
    }

    public void setMaKm(String maKm) {
        this.maKm = maKm;
    }

    public int getLoaiDonHang() {
        return loaiDonHang;
    }

    public void setLoaiDonHang(int loaiDonHang) {
        this.loaiDonHang = loaiDonHang;
    }

    public Timestamp getThoiGianHenLay() {
        return thoiGianHenLay;
    }

    public void setThoiGianHenLay(Timestamp thoiGianHenLay) {
        this.thoiGianHenLay = thoiGianHenLay;
    }

    public int getTongTienHang() {
        return tongTienHang;
    }

    public void setTongTienHang(int tongTienHang) {
        this.tongTienHang = tongTienHang;
    }

    public int getTienGiamGia() {
        return tienGiamGia;
    }

    public void setTienGiamGia(int tienGiamGia) {
        this.tienGiamGia = tienGiamGia;
    }

    public int getDiemSuDung() {
        return diemSuDung;
    }

    public void setDiemSuDung(int diemSuDung) {
        this.diemSuDung = diemSuDung;
    }

    public int getTienTruDiem() {
        return tienTruDiem;
    }

    public void setTienTruDiem(int tienTruDiem) {
        this.tienTruDiem = tienTruDiem;
    }

    public int getTongPhaiTra() {
        return tongPhaiTra;
    }

    public void setTongPhaiTra(int tongPhaiTra) {
        this.tongPhaiTra = tongPhaiTra;
    }

    public String getGhiChuDon() {
        return ghiChuDon;
    }

    public void setGhiChuDon(String ghiChuDon) {
        this.ghiChuDon = ghiChuDon;
    }

    public String getLyDoHuy() {
        return lyDoHuy;
    }

    public void setLyDoHuy(String lyDoHuy) {
        this.lyDoHuy = lyDoHuy;
    }

    public int getTrangThaiThanhToan() {
        return trangThaiThanhToan;
    }

    public void setTrangThaiThanhToan(int trangThaiThanhToan) {
        this.trangThaiThanhToan = trangThaiThanhToan;
    }

    public int getTrangThaiDon() {
        return trangThaiDon;
    }

    public void setTrangThaiDon(int trangThaiDon) {
        this.trangThaiDon = trangThaiDon;
    }

    public Timestamp getThoiGianTao() {
        return thoiGianTao;
    }

    public void setThoiGianTao(Timestamp thoiGianTao) {
        this.thoiGianTao = thoiGianTao;
    }

    public Timestamp getThoiGianHoanThanh() {
        return thoiGianHoanThanh;
    }

    public void setThoiGianHoanThanh(Timestamp thoiGianHoanThanh) {
        this.thoiGianHoanThanh = thoiGianHoanThanh;
    }

    // Hàm lấy danh sách chi tiết đơn hàng (Giải quyết triệt để lỗi getChiTietDonHangList)
    public List<ChiTietDonHang> getChiTietDonHangList() {
        return chiTietDonHangList;
    }

    public void setChiTietDonHangList(List<ChiTietDonHang> chiTietDonHangList) {
        this.chiTietDonHangList = chiTietDonHangList;
    }
}