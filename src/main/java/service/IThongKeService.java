package service;

import model.dto.*;
import java.sql.Date;
import java.util.List;

public interface IThongKeService {

    List<DoanhThuNgayDTO> getDoanhThuTheoNgay(Date tuNgay, Date denNgay);
    List<DoanhThuThangDTO> getDoanhThuTheoThang();
    List<TopSanPhamDTO> getTop10SanPhamBanChay();
    List<TopNhanVienDTO> getTop10NhanVienDoanhThu();
    List<DoanhThuDanhMucDTO> getDoanhThuTheoDanhMuc();
    DashboardKpiDTO getDashboardKpis(Date tuNgay, Date denNgay);
    boolean runNightlyAggregationJob();
}