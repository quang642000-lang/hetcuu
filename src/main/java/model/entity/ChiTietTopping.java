package model.entity;

public class ChiTietTopping {
    private long maCtdh;
    private String maTp; // Changed from int to String
    private int soLuong;
    private int giaChotTp;
    private String tenTopping;

    public ChiTietTopping() {}

    public ChiTietTopping(long maCtdh, String maTp, int soLuong, int giaChotTp) {
        this.maCtdh = maCtdh;
        this.maTp = maTp;
        this.soLuong = soLuong;
        this.giaChotTp = giaChotTp;
    }

    public ChiTietTopping(long maCtdh, String maTp, int soLuong, int giaChotTp, String tenTopping) {
        this.maCtdh = maCtdh;
        this.maTp = maTp;
        this.soLuong = soLuong;
        this.giaChotTp = giaChotTp;
        this.tenTopping = tenTopping;
    }

    public long getMaCtdh() { return maCtdh; }
    public void setMaCtdh(long maCtdh) { this.maCtdh = maCtdh; }

    public String getMaTp() { return maTp; }
    public void setMaTp(String maTp) { this.maTp = maTp; }

    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }

    public int getGiaChotTp() { return giaChotTp; }
    public void setGiaChotTp(int giaChotTp) { this.giaChotTp = giaChotTp; }

    public String getTenTopping() { return tenTopping; }
    public void setTenTopping(String tenTopping) { this.tenTopping = tenTopping; }
}
