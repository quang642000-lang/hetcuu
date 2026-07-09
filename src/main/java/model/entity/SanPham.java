package model.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SanPham {
    private String maSp;
    private int maDm;
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

    private List<SanPhamKichCo> sizesList = new ArrayList<>();

    public SanPham() {}
    public SanPham(String maSp, int maDm, String tenSp, String moTa, String hinhAnh, boolean choPhepDoiDa, boolean choPhepDoiDuong, boolean isNew, boolean isBestseller, boolean trangThai, Timestamp thoiGianTao, Timestamp thoiGianCapNhat) {
        this.maSp = maSp; this.maDm = maDm; this.tenSp = tenSp; this.moTa = moTa; this.hinhAnh = hinhAnh; this.choPhepDoiDa = choPhepDoiDa; this.choPhepDoiDuong = choPhepDoiDuong; this.isNew = isNew; this.isBestseller = isBestseller; this.trangThai = trangThai; this.thoiGianTao = thoiGianTao; this.thoiGianCapNhat = thoiGianCapNhat;
    }

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }
    public int getMaDm() { return maDm; }
    public void setMaDm(int maDm) { this.maDm = maDm; }
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
    // Đổi isNew() thành getIsNew()
    public boolean getIsNew() { return isNew; }
    public void setIsNew(boolean isNew) { this.isNew = isNew; }

    // Đổi isBestseller() thành getIsBestseller()
    public boolean getIsBestseller() { return isBestseller; }
    public void setIsBestseller(boolean isBestseller) { this.isBestseller = isBestseller; }
    public boolean isTrangThai() { return trangThai; }
    public void setTrangThai(boolean trangThai) { this.trangThai = trangThai; }
    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }
    public Timestamp getThoiGianCapNhat() { return thoiGianCapNhat; }
    public void setThoiGianCapNhat(Timestamp thoiGianCapNhat) { this.thoiGianCapNhat = thoiGianCapNhat; }
    public List<SanPhamKichCo> getSizesList() {
        return sizesList;
    }

    public void setSizesList(List<SanPhamKichCo> sizesList) {
        this.sizesList = sizesList;
    }
}