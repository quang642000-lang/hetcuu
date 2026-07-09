package service.impl;

import config.DBConnect;
import model.entity.SanPham;
import model.entity.SanPhamKichCo;
import repository.ISanPhamKichCoRepository;
import repository.ISanPhamRepository;
import repository.impl.SanPhamKichCoRepoImpl;
import repository.impl.SanPhamRepoImpl;
import service.ISanPhamService;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SanPhamServiceImpl implements ISanPhamService {
    private static SanPhamServiceImpl instance;
    private final ISanPhamRepository sanPhamRepository;
    private final ISanPhamKichCoRepository sanPhamKichCoRepository;

    private SanPhamServiceImpl() {
        this.sanPhamRepository = SanPhamRepoImpl.getInstance();
        this.sanPhamKichCoRepository = SanPhamKichCoRepoImpl.getInstance();
    }

    public static synchronized SanPhamServiceImpl getInstance() {
        if (instance == null) {
            instance = new SanPhamServiceImpl();
        }
        return instance;
    }

    @Override
    public List<SanPham> getAllSanPham() {
        return sanPhamRepository.getAll();
    }

    @Override
    public SanPham getSanPhamById(String id) {
        return sanPhamRepository.getById(id);
    }

    @Override
    public List<SanPham> getSanPhamByDanhMuc(int maDm) {
        return sanPhamRepository.getByDanhMuc(maDm);
    }

    @Override
    public List<SanPham> getBestsellers() {
        return sanPhamRepository.getBestsellers();
    }

    @Override
    public List<SanPham> getNewArrivals() {
        return sanPhamRepository.getNewArrivals();
    }

    @Override
    public List<SanPham> searchSanPham(String keyword) {
        return sanPhamRepository.searchByName(keyword);
    }

    @Override
    public boolean createSanPham(SanPham sanPham, List<SanPhamKichCo> sizes) {
        if (sizes == null || sizes.isEmpty()) {
            return false; // Bắt buộc phải có ít nhất một size
        }

        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction phối hợp 2 bảng

            // 1. Lưu sản phẩm mẹ (Tự sinh mã SP dạng SPxxxx trong procedure)
            boolean addedSp = sanPhamRepository.add(sanPham);
            if (!addedSp || sanPham.getMaSp() == null) {
                conn.rollback();
                return false;
            }

            // 2. Lưu danh sách kích cỡ đi kèm
            for (SanPhamKichCo size : sizes) {
                size.setMaSp(sanPham.getMaSp()); // Đồng bộ mã SP vừa sinh
                boolean addedSize = sanPhamKichCoRepository.add(size);
                if (!addedSize) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    @Override
    public boolean updateSanPham(SanPham sanPham, List<SanPhamKichCo> sizes) {
        if (sizes == null || sizes.isEmpty()) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật thông tin sản phẩm mẹ
            boolean updatedSp = sanPhamRepository.update(sanPham);
            if (!updatedSp) {
                conn.rollback();
                return false;
            }

            // 2. Xóa sạch cấu hình kích cỡ cũ
            sanPhamKichCoRepository.deleteAllBySanPham(sanPham.getMaSp());

            // 3. Nạp lại danh sách kích cỡ mới
            for (SanPhamKichCo size : sizes) {
                size.setMaSp(sanPham.getMaSp());
                boolean addedSize = sanPhamKichCoRepository.add(size);
                if (!addedSize) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    @Override
    public boolean deleteSanPham(String id) {
        return sanPhamRepository.delete(id); // Soft Delete
    }

    @Override
    public List<SanPhamKichCo> getSizesBySanPham(String maSp) {
        return sanPhamKichCoRepository.getBySanPham(maSp);
    }
}