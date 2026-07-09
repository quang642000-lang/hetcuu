package model.dto;

public class TopNhanVienDTO {
    private String maNv;
    private String hoTen;
    private int soDonHoanThanh;
    private long doanhThuTaoRa;

    // 1. Constructor không tham số
    public TopNhanVienDTO() {}

    // 2. Constructor đầy đủ tham số
    public TopNhanVienDTO(String maNv, String hoTen, int soDonHoanThanh, long doanhThuTaoRa) {
        this.maNv = maNv;
        this.hoTen = hoTen;
        this.soDonHoanThanh = soDonHoanThanh;
        this.doanhThuTaoRa = doanhThuTaoRa;
    }

    // 3. Quyết toán Getters & Setters
    public String getMaNv() {
        return maNv;
    }

    public void setMaNv(String maNv) {
        this.maNv = maNv;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public int getSoDonHoanThanh() {
        return soDonHoanThanh;
    }

    public void setSoDonHoanThanh(int soDonHoanThanh) {
        this.soDonHoanThanh = soDonHoanThanh;
    }

    public long getDoanhThuTaoRa() {
        return doanhThuTaoRa;
    }

    public void setDoanhThuTaoRa(long doanhThuTaoRa) {
        this.doanhThuTaoRa = doanhThuTaoRa;
    }
}