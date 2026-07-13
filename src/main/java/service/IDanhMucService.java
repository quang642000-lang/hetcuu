package service;

import model.entity.DanhMuc;
import java.util.List;

public interface IDanhMucService {
    List<DanhMuc> getAllDanhMuc();
    List<DanhMuc> getActiveDanhMuc();
    DanhMuc getDanhMucById(String id);
    boolean createDanhMuc(DanhMuc danhMuc);
    boolean updateDanhMuc(DanhMuc danhMuc);
    boolean deleteDanhMuc(String id);
    boolean isTenDanhMucDuplicate(String tenDm, String excludeId);
}
