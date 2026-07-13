package service.impl;

import model.entity.DanhMuc;
import repository.IDanhMucRepository;
import repository.impl.DanhMucRepoImpl;
import service.IDanhMucService;
import java.util.List;

public class DanhMucServiceImpl implements IDanhMucService {
    private static DanhMucServiceImpl instance;
    private final IDanhMucRepository danhMucRepository;

    private DanhMucServiceImpl() {
        this.danhMucRepository = DanhMucRepoImpl.getInstance();
    }

    public static synchronized DanhMucServiceImpl getInstance() {
        if (instance == null) {
            instance = new DanhMucServiceImpl();
        }
        return instance;
    }

    @Override
    public List<DanhMuc> getAllDanhMuc() {
        return danhMucRepository.getAll();
    }

    @Override
    public List<DanhMuc> getActiveDanhMuc() {
        return danhMucRepository.getByTrangThai(true);
    }

    @Override
    public DanhMuc getDanhMucById(String id) {
        return danhMucRepository.getById(id);
    }

    @Override
    public boolean createDanhMuc(DanhMuc danhMuc) {
        if (isTenDanhMucDuplicate(danhMuc.getTenDm(), null)) {
            return false;
        }
        return danhMucRepository.add(danhMuc);
    }

    @Override
    public boolean updateDanhMuc(DanhMuc danhMuc) {
        if (isTenDanhMucDuplicate(danhMuc.getTenDm(), danhMuc.getMaDm())) {
            return false;
        }
        return danhMucRepository.update(danhMuc);
    }

    @Override
    public boolean deleteDanhMuc(String id) {
        return danhMucRepository.delete(id);
    }

    @Override
    public boolean isTenDanhMucDuplicate(String tenDm, String excludeId) {
        return danhMucRepository.checkTenDanhMucTrung(tenDm, excludeId);
    }
}
