package model.entity;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class GioHang {
    private int maGh;
    private String maKh;
    private Timestamp thoiGianTao;
    private Timestamp thoiGianCapNhat;

    // QUAN HỆ 1-N: Giỏ hàng chứa nhiều chi tiết sản phẩm
    private List<ChiTietGioHang> chiTietGioHangList = new ArrayList<>();

    public GioHang() {}
    public GioHang(int maGh, String maKh, Timestamp thoiGianTao, Timestamp thoiGianCapNhat) {
        this.maGh = maGh;
        this.maKh = maKh;
        this.thoiGianTao = thoiGianTao;
        this.thoiGianCapNhat = thoiGianCapNhat;
    }

    public int getMaGh() { return maGh; }
    public void setMaGh(int maGh) { this.maGh = maGh; }

    public String getMaKh() { return maKh; }
    public void setMaKh(String maKh) { this.maKh = maKh; }

    public Timestamp getThoiGianTao() { return thoiGianTao; }
    public void setThoiGianTao(Timestamp thoiGianTao) { this.thoiGianTao = thoiGianTao; }

    public Timestamp getThoiGianCapNhat() { return thoiGianCapNhat; }
    public void setThoiGianCapNhat(Timestamp thoiGianCapNhat) { this.thoiGianCapNhat = thoiGianCapNhat; }

    // Getter và Setter cho danh sách chi tiết giỏ hàng
    public List<ChiTietGioHang> getChiTietGioHangList() {
        return chiTietGioHangList;
    }

    public void setChiTietGioHangList(List<ChiTietGioHang> chiTietGioHangList) {
        this.chiTietGioHangList = chiTietGioHangList;
    }
}