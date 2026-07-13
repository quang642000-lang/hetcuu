package service;

import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import java.util.List;

public interface ISanPhamService {
    List<SanPham> getAllSanPham();
    SanPham getSanPhamById(String id);
    List<SanPham> getSanPhamByDanhMuc(String maDm);
    List<SanPham> getBestsellers();
    List<SanPham> getNewArrivals();
    List<SanPham> searchSanPham(String keyword);
    boolean createSanPham(SanPham sanPham, List<SanPhamKichCo> sizes);
    boolean updateSanPham(SanPham sanPham, List<SanPhamKichCo> sizes);
    boolean deleteSanPham(String id);
    List<SanPhamKichCo> getSizesBySanPham(String maSp);
}
