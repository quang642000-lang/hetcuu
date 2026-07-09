package model.dto;

public class DashboardKpiDTO {
    private long doanhThuKyLoc;
    private int donHangKyLoc;
    private int monDangBan;
    private int tongKhachHang;

    // 1. Constructor không tham số
    public DashboardKpiDTO() {}

    // 2. Constructor đầy đủ tham số
    public DashboardKpiDTO(long doanhThuKyLoc, int donHangKyLoc, int monDangBan, int tongKhachHang) {
        this.doanhThuKyLoc = doanhThuKyLoc;
        this.donHangKyLoc = donHangKyLoc;
        this.monDangBan = monDangBan;
        this.tongKhachHang = tongKhachHang;
    }

    // 3. Quyết toán Getters & Setters
    public long getDoanhThuKyLoc() {
        return doanhThuKyLoc;
    }

    public void setDoanhThuKyLoc(long doanhThuKyLoc) {
        this.doanhThuKyLoc = doanhThuKyLoc;
    }

    public int getDonHangKyLoc() {
        return donHangKyLoc;
    }

    public void setDonHangKyLoc(int donHangKyLoc) {
        this.donHangKyLoc = donHangKyLoc;
    }

    public int getMonDangBan() {
        return monDangBan;
    }

    public void setMonDangBan(int monDangBan) {
        this.monDangBan = monDangBan;
    }

    public int getTongKhachHang() {
        return tongKhachHang;
    }

    public void setTongKhachHang(int tongKhachHang) {
        this.tongKhachHang = tongKhachHang;
    }
}
