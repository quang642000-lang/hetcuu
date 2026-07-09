package service.impl;

import config.DBConnect;
import model.dto.*;
import service.IThongKeService;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ThongKeServiceImpl implements IThongKeService {
    private static ThongKeServiceImpl instance;

    private ThongKeServiceImpl() {}

    public static synchronized ThongKeServiceImpl getInstance() {
        if (instance == null) {
            instance = new ThongKeServiceImpl();
        }
        return instance;
    }

    @Override
    public List<DoanhThuNgayDTO> getDoanhThuTheoNgay(Date tuNgay, Date denNgay) {
        List<DoanhThuNgayDTO> list = new ArrayList<>();
        String sql = "SELECT Ngay, SoLuongDon, TongDoanhThu FROM vw_DoanhThuNgay WHERE Ngay BETWEEN ? AND ? ORDER BY Ngay ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, tuNgay);
            ps.setDate(2, denNgay);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new DoanhThuNgayDTO(
                            rs.getDate("Ngay"),
                            rs.getInt("SoLuongDon"),
                            rs.getInt("TongDoanhThu")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<DoanhThuThangDTO> getDoanhThuTheoThang() {
        List<DoanhThuThangDTO> list = new ArrayList<>();
        String sql = "SELECT Nam, Thang, SoLuongDon, TongDoanhThu FROM vw_DoanhThuThang ORDER BY Nam DESC, Thang DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DoanhThuThangDTO(
                        rs.getInt("Nam"),
                        rs.getInt("Thang"),
                        rs.getInt("SoLuongDon"),
                        rs.getInt("TongDoanhThu")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<TopSanPhamDTO> getTop10SanPhamBanChay() {
        List<TopSanPhamDTO> list = new ArrayList<>();
        String sql = "SELECT TOP 10 ma_sp, ten_sp, ten_dm, TongSoLuongBan, DoanhThuMangLai FROM vw_TopSanPham ORDER BY TongSoLuongBan DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new TopSanPhamDTO(
                        rs.getString("ma_sp"),
                        rs.getString("ten_sp"),
                        rs.getString("ten_dm"),
                        rs.getInt("TongSoLuongBan"),
                        rs.getInt("DoanhThuMangLai")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<TopNhanVienDTO> getTop10NhanVienDoanhThu() {
        List<TopNhanVienDTO> list = new ArrayList<>();
        String sql = "SELECT TOP 10 ma_nv, ho_ten, SoDonHoanThanh, DoanhThuTaoRa FROM vw_TopNhanVien ORDER BY DoanhThuTaoRa DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new TopNhanVienDTO(
                        rs.getString("ma_nv"),
                        rs.getString("ho_ten"),
                        rs.getInt("SoDonHoanThanh"),
                        rs.getInt("DoanhThuTaoRa")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public List<DoanhThuDanhMucDTO> getDoanhThuTheoDanhMuc() {
        List<DoanhThuDanhMucDTO> list = new ArrayList<>();
        String sql = "SELECT ma_dm, ten_dm, TongSanPhamBan, TongDoanhThu FROM vw_DoanhThuTheoDanhMuc";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DoanhThuDanhMucDTO(
                        rs.getInt("ma_dm"),
                        rs.getString("ten_dm"),
                        rs.getInt("TongSanPhamBan"),
                        rs.getInt("TongDoanhThu")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    @Override
    public DashboardKpiDTO getDashboardKpis(Date tuNgay, Date denNgay) {
        long doanhThuKyLoc = 0;
        int donHangKyLoc = 0;
        int monDangBan = 0;
        int tongKhachHang = 0;

        String queryDoanhThu = "SELECT COALESCE(SUM(tong_phai_tra), 0), COUNT(ma_dh) FROM DON_HANG WHERE trang_thai_don = 4 AND thoi_gian_tao BETWEEN ? AND ?";
        String querySanPham = "SELECT COUNT(*) FROM SAN_PHAM WHERE trang_thai = 1";
        String queryKhachHang = "SELECT COUNT(*) FROM KHACH_HANG WHERE trang_thai = 1";

        try (Connection conn = DBConnect.getConnection()) {
            // 1. Tính Doanh thu và Số đơn thành công trong kỳ lọc
            try (PreparedStatement ps = conn.prepareStatement(queryDoanhThu)) {
                ps.setTimestamp(1, new Timestamp(tuNgay.getTime()));
                ps.setTimestamp(2, new Timestamp(denNgay.getTime() + (24 * 60 * 60 * 1000) - 1)); // Lấy đến cuối ngày
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        doanhThuKyLoc = rs.getLong(1);
                        donHangKyLoc = rs.getInt(2);
                    }
                }
            }

            // 2. Số lượng món đang mở bán
            try (PreparedStatement ps = conn.prepareStatement(querySanPham);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) monDangBan = rs.getInt(1);
            }

            // 3. Tổng số lượng thành viên đã kích hoạt hoạt động
            try (PreparedStatement ps = conn.prepareStatement(queryKhachHang);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) tongKhachHang = rs.getInt(1);
            }

        } catch (SQLException e) { e.printStackTrace(); }

        return new DashboardKpiDTO(doanhThuKyLoc, donHangKyLoc, monDangBan, tongKhachHang);
    }

    @Override
    public boolean runNightlyAggregationJob() {
        // Nghiệp vụ chốt sổ: gộp toàn bộ giao dịch trong ngày hôm nay vào bảng lưu trữ THONG_KE_NGAY
        String sql = "INSERT INTO THONG_KE_NGAY (ngay_thong_ke, tong_doanh_thu, so_luong_don, thoi_gian_tao) "
                + "SELECT CAST(GETDATE() AS DATE), COALESCE(SUM(tong_phai_tra), 0), COUNT(ma_dh), GETDATE() "
                + "FROM DON_HANG WHERE trang_thai_don = 4 AND CAST(thoi_gian_tao AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND NOT EXISTS (SELECT 1 FROM THONG_KE_NGAY WHERE ngay_thong_ke = CAST(GETDATE() AS DATE))";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}