package repository;

import model.entity.SanPham;
import java.util.List;

public interface ISanPhamRepository extends IBaseRepository<SanPham, String> {
    List<SanPham> getByDanhMuc(int maDm);
    List<SanPham> getBestsellers();
    List<SanPham> getNewArrivals();
    List<SanPham> searchByName(String keyword);
}
