package model.entity;

import java.sql.Timestamp;

public class NhatKyHoatDong {
    private long maLog;
    private String maNv;
    private String hanhDong;
    private String bangTacDong;
    private String duLieuCu;  // JSON format
    private String duLieuMoi; // JSON format
    private String ipAddress;
    private Timestamp thoiGian;
    private String hoTenNhanVien; // Added dynamically for JOIN

    public NhatKyHoatDong() {}

    public NhatKyHoatDong(long maLog, String maNv, String hanhDong, String bangTacDong, String duLieuCu, String duLieuMoi, String ipAddress, Timestamp thoiGian) {
        this.maLog = maLog;
        this.maNv = maNv;
        this.hanhDong = hanhDong;
        this.bangTacDong = bangTacDong;
        this.duLieuCu = duLieuCu;
        this.duLieuMoi = duLieuMoi;
        this.ipAddress = ipAddress;
        this.thoiGian = thoiGian;
    }

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

    public String getHoTenNhanVien() { return hoTenNhanVien; }
    public void setHoTenNhanVien(String hoTenNhanVien) { this.hoTenNhanVien = hoTenNhanVien; }

    // Dynamic getter to extract primary key code inside brackets [key] for nhat_ky.jsp ${log.recordTacDong}
    public String getRecordTacDong() {
        if (this.bangTacDong != null && this.bangTacDong.contains("[") && this.bangTacDong.contains("]")) {
            int start = this.bangTacDong.indexOf("[") + 1;
            int end = this.bangTacDong.indexOf("]");
            if (start < end) {
                return this.bangTacDong.substring(start, end);
            }
        }
        return "";
    }
}
