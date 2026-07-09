package repository;

import model.entity.PhuongThucThanhToan;
import java.util.List;

public interface IPhuongThucThanhToanRepository extends IBaseRepository<PhuongThucThanhToan, Integer> {
    List<PhuongThucThanhToan> getByTrangThai(boolean status);
}
