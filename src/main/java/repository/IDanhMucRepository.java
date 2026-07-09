package repository;

import model.entity.DanhMuc;
import java.util.List;

public interface IDanhMucRepository extends IBaseRepository<DanhMuc, Integer> {
    List<DanhMuc> getByTrangThai(boolean status);
    boolean checkTenDanhMucTrung(String tenDm, Integer excludeId);
}