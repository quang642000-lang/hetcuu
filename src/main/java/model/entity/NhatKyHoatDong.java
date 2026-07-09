package model.entity;

import java.sql.Timestamp;

public class NhatKyHoatDong {
    private long maLog;
    private String maNv;
    private String hanhDong;
    private String bangTacDong;
    private String duLieuCu;  // Định dạng JSON chuỗi trạng thái cũ [17]
    private String duLieuMoi; // Định dạng JSON chuỗi trạng thái mới [17]
    private String ipAddress;
    private Timestamp thoiGian;

    public NhatKyHoatDong() {}
    public NhatKyHoatDong(long maLog, String maNv, String hanhDong, String bangTacDong, String duLieuCu, String duLieuMoi, String ipAddress, Timestamp thoiGian) {
        this.maLog = maLog; this.maNv = maNv; this.hanhDong = hanhDong; this.bangTacDong = bangTacDong; this.duLieuCu = duLieuCu; this.duLieuMoi = duLieuMoi; this.ipAddress = ipAddress; this.thoiGian = thoiGian;
    }

    // Constructor 7 tham số dùng để thêm mới (bỏ qua maLog do DB tự tăng)
    public NhatKyHoatDong(String maNv, String hanhDong, String bangTacDong, String duLieuCu, String duLieuMoi, String ipAddress, Timestamp thoiGian) {
        this.maNv = maNv;
        this.hanhDong = hanhDong;
        this.bangTacDong = bangTacDong;
        this.duLieuCu = duLieuCu;
        this.duLieuMoi = duLieuMoi;
        this.ipAddress = ipAddress;
        this.thoiGian = thoiGian;
    }

    public long getMaLog() { return maLog; }
    public void setMaLog(long maLog) { this.maLog = maLog; }
    public String getMaNv() { return maNv; }
    public void setMaNv(String maNv) { this.maNv = maNv; }
    public String getHanhDong() { return hanhDong; }
    public void setHanhDong(String hanhDong) { this.hanhDong = hanhDong; }
    public String getBangTacDong() { return bangTacDong; }
    public void setBangTacDong(String bangTacDong) { this.bangTacDong = bangTacDong; }
    public String getDuLieuCu() { return duLieuCu; }
    public void setDuLieuCu(String duLieuCu) { this.duLieuCu = duLieuCu; }
    public String getDuLieuMoi() { return duLieuMoi; }
    public void setDuLieuMoi(String duLieuMoi) { this.duLieuMoi = duLieuMoi; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public Timestamp getThoiGian() { return thoiGian; }
    public void setThoiGian(Timestamp thoiGian) { this.thoiGian = thoiGian; }
}