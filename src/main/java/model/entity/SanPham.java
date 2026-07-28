package model.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * =========================================================================
 * TEA POS SYSTEM - PRODUCT ENTITY MODEL
 * Added: thuTuHienThi property to support priority sorting on menus.
 * =========================================================================
 */
public class SanPham {
    private String maSp;
    private String maDm;
    private String tenSp;
    private String moTa;
    private String hinhAnh;
    private boolean choPhepDoiDa;
    private boolean choPhepDoiDuong;
    private boolean isNew;
    private boolean isBestseller;
    private boolean trangThai;
    private Timestamp thoiGianTao;
    private Timestamp thoiGianCapNhat;
    private boolean choPhepTopping = true;
    private int thuTuHienThi = 0; // TRƯỜNG MỚI NÂNG CẤP
    private List<SanPhamKichCo> sizesList = new ArrayList<>();

    // 1. Constructor không tham số (Bắt buộc)
    public SanPham() {}

    // 2. Constructor cũ để duy trì tương thích ngược
    public SanPham(String maSp, String maDm, String tenSp, String moTa, String hinhAnh,
                   boolean choPhepDoiDa, boolean choPhepDoiDuong, boolean isNew,
                   boolean isBestseller, boolean trangThai, Timestamp thoiGianTao, Timestamp thoiGianCapNhat) {
        this.maSp = maSp;
        this.maDm = maDm;
        this.tenSp = tenSp;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
        this.choPhepDoiDa = choPhepDoiDa;
        this.choPhepDoiDuong = choPhepDoiDuong;
        this.isNew = isNew;
        this.isBestseller = isBestseller;
        this.trangThai = trangThai;
        this.thoiGianTao = thoiGianTao;
        this.thoiGianCapNhat = thoiGianCapNhat;
    }

    // 3. Constructor đầy đủ tham số mới tinh để map CSDL chuẩn chỉ
    public SanPham(String maSp, String maDm, String tenSp, String moTa, String hinhAnh,
                   boolean choPhepDoiDa, boolean choPhepDoiDuong, boolean isNew,
                   boolean isBestseller, boolean trangThai, Timestamp thoiGianTao,
                   Timestamp thoiGianCapNhat, boolean choPhepTopping, int thuTuHienThi) {
        this.maSp = maSp;
        this.maDm = maDm;
        this.tenSp = tenSp;
        this.moTa = moTa;
        this.hinhAnh = hinhAnh;
        this.choPhepDoiDa = choPhepDoiDa;
        this.choPhepDoiDuong = choPhepDoiDuong;
        this.isNew = isNew;
        this.isBestseller = isBestseller;
        this.trangThai = trangThai;
        this.thoiGianTao = thoiGianTao;
        this.thoiGianCapNhat = thoiGianCapNhat;
        this.choPhepTopping = choPhepTopping;
        this.thuTuHienThi = thuTuHienThi;
    }

    // --- GETTERS AND SETTERS ---
    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public String getMaDm() { return maDm; }
    public void setMaDm(String maDm) { this.maDm = maDm; }

    public String getTenSp() { return tenSp; }
    public void setTenSp(String tenSp) { this.tenSp = tenSp; }

    public String getMoTa() { return moTa; }
    public void setMoTa(String moTa) { this.moTa = moTa; }

    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }

    public boolean isChoPhepDoiDa() { return choPhepDoiDa; }
    public void setChoPhepDoiDa(boolean choPhepDoiDa) { this.choPhepDoiDa = choPhepDoiDa; }

    public boolean isChoPhepDoiDuong() { return choPhepDoiDuong; }
    public void setChoPhepDoiDuong(boolean choPhepDoiDuong) { this.choPhepDoiDuong = choPhepDoiDuong; }

    public boolean getIsNew() { return isNew; }
    public void setIsNew(boolean isNew) { this.isNew = isNew; }

    public boolean getIsBestseller() { return isBestseller; }
    public void setIsBestseller(boolean isBestseller) { this.isBestseller = isBestseller; }

    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }

    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }

    public Timestamp getThoiGianCapNhat() { return thoiGianCapNhat; }
    public void setThoiGianCapNhat(Timestamp thoiGianCapNhat) { this.thoiGianCapNhat = thoiGianCapNhat; }

    public boolean isChoPhepTopping() { return choPhepTopping; }
    public void setChoPhepTopping(boolean choPhepTopping) { this.choPhepTopping = choPhepTopping; }

    public int getThuTuHienThi() { return thuTuHienThi; }
    public void setThuTuHienThi(int thuTuHienThi) { this.thuTuHienThi = thuTuHienThi; }

    public List<SanPhamKichCo> getSizesList() { return sizesList; }
    public void setSizesList(List<SanPhamKichCo> sizesList) { this.sizesList = sizesList; }
}
