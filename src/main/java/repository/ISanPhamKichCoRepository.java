package repository;

import model.entity.SanPhamKichCo;
import java.util.List;

public interface ISanPhamKichCoRepository {
    List<SanPhamKichCo> getAll();
    List<SanPhamKichCo> getBySanPham(String maSp);
    SanPhamKichCo getBySanPhamAndSize(String maSp, int maSize);
    boolean add(SanPhamKichCo entity);
    boolean update(SanPhamKichCo entity);
    boolean delete(String maSp, int maSize);
    boolean deleteAllBySanPham(String maSp);
}
