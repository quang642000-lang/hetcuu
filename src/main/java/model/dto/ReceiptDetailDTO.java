package model.dto;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ReceiptDetailDTO {
    private String maDh;
    private Timestamp thoiGianTao;
    private String tenNhanVien;
    private String tenKhachHang;
    private String tenPhuongThucTT;
    private int tongTienHang;
    private int tienGiamGia;
    private int diemSuDung;
    private int tienTruDiem;
    private int tongPhaiTra;
    private String ghiChuDon;
    private List<ItemDetail> items = new ArrayList<>();

    // 1. Constructor không tham số cho ReceiptDetailDTO
    public ReceiptDetailDTO() {}

    // 2. Constructor đầy đủ tham số cho ReceiptDetailDTO
    public ReceiptDetailDTO(String maDh, Timestamp thoiGianTao, String tenNhanVien, String tenKhachHang,
                            String tenPhuongThucTT, int tongTienHang, int tienGiamGia, int diemSuDung,
                            int tienTruDiem, int tongPhaiTra, String ghiChuDon, List<ItemDetail> items) {
        this.maDh = maDh;
        this.thoiGianTao = thoiGianTao;
        this.tenNhanVien = tenNhanVien;
        this.tenKhachHang = tenKhachHang;
        this.tenPhuongThucTT = tenPhuongThucTT;
        this.tongTienHang = tongTienHang;
        this.tienGiamGia = tienGiamGia;
        this.diemSuDung = diemSuDung;
        this.tienTruDiem = tienTruDiem;
        this.tongPhaiTra = tongPhaiTra;
        this.ghiChuDon = ghiChuDon;
        this.items = items;
    }

    // 3. Đầy đủ Getter/Setter cho ReceiptDetailDTO
    public String getMaDh() { return maDh; }
    public void setMaDh(String maDh) { this.maDh = maDh; }

    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }

    public String getTenNhanVien() { return tenNhanVien; }
    public void setTenNhanVien(String tenNhanVien) { this.tenNhanVien = tenNhanVien; }

    public String getTenKhachHang() { return tenKhachHang; }
    public void setTenKhachHang(String tenKhachHang) { this.tenKhachHang = tenKhachHang; }

    public String getTenPhuongThucTT() { return tenPhuongThucTT; }
    public void setTenPhuongThucTT(String tenPhuongThucTT) { this.tenPhuongThucTT = tenPhuongThucTT; }

    public int getTongTienHang() { return tongTienHang; }
    public void setTongTienHang(int tongTienHang) { this.tongTienHang = tongTienHang; }

    public int getTienGiamGia() { return tienGiamGia; }
    public void setTienGiamGia(int tienGiamGia) { this.tienGiamGia = tienGiamGia; }

    public int getDiemSuDung() { return diemSuDung; }
    public void setDiemSuDung(int diemSuDung) { this.diemSuDung = diemSuDung; }

    public int getTienTruDiem() { return tienTruDiem; }
    public void setTienTruDiem(int tienTruDiem) { this.tienTruDiem = tienTruDiem; }

    public int getTongPhaiTra() { return tongPhaiTra; }
    public void setTongPhaiTra(int tongPhaiTra) { this.tongPhaiTra = tongPhaiTra; }

    public String getGhiChuDon() { return ghiChuDon; }
    public void setGhiChuDon(String ghiChuDon) { this.ghiChuDon = ghiChuDon; }

    public List<ItemDetail> getItems() { return items; }
    public void setItems(List<ItemDetail> items) { this.items = items; }


    // ================== NESTED CLASSES (JavaBeans) ==================

    public static class ItemDetail {
        private String tenMon;
        private String tenSize;
        private String mucDa;
        private String mucDuong;
        private int soLuong;
        private int giaChot;
        private List<ToppingDetail> toppings = new ArrayList<>();

        // Constructor không tham số
        public ItemDetail() {}

        // Constructor đầy đủ tham số
        public ItemDetail(String tenMon, String tenSize, String mucDa, String mucDuong,
                          int soLuong, int giaChot, List<ToppingDetail> toppings) {
            this.tenMon = tenMon;
            this.tenSize = tenSize;
            this.mucDa = mucDa;
            this.mucDuong = mucDuong;
            this.soLuong = soLuong;
            this.giaChot = giaChot;
            this.toppings = toppings;
        }

        // Getter & Setter
        public String getTenMon() { return tenMon; }
        public void setTenMon(String tenMon) { this.tenMon = tenMon; }

        public String getTenSize() { return tenSize; }
        public void setTenSize(String tenSize) { this.tenSize = tenSize; }

        public String getMucDa() { return mucDa; }
        public void setMucDa(String mucDa) { this.mucDa = mucDa; }

        public String getMucDuong() { return mucDuong; }
        public void setMucDuong(String mucDuong) { this.mucDuong = mucDuong; }

        public int getSoLuong() { return soLuong; }
        public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

        public int getGiaChot() { return giaChot; }
        public void setGiaChot(int giaChot) { this.giaChot = giaChot; }

        public List<ToppingDetail> getToppings() { return toppings; }
        public void setToppings(List<ToppingDetail> toppings) { this.toppings = toppings; }
    }

    public static class ToppingDetail {
        private String tenTopping;
        private int soLuong;
        private int giaChotTp;

        // Constructor không tham số
        public ToppingDetail() {}

        // Constructor đầy đủ tham số
        public ToppingDetail(String tenTopping, int soLuong, int giaChotTp) {
            this.tenTopping = tenTopping;
            this.soLuong = soLuong;
            this.giaChotTp = giaChotTp;
        }

        // Getter & Setter
        public String getTenTopping() { return tenTopping; }
        public void setTenTopping(String tenTopping) { this.tenTopping = tenTopping; }

        public int getSoLuong() { return soLuong; }
        public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

        public int getGiaChotTp() { return giaChotTp; }
        public void setGiaChotTp(int giaChotTp) { this.giaChotTp = giaChotTp; }
    }
}