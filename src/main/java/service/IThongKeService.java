package service;

import model.dto.*;
import java.sql.Date;
import java.util.List;

public interface IThongKeService {

    /**
     * Thống kê báo cáo doanh thu chi tiết theo từng ngày trong khoảng thời gian lọc chỉ định.
     * Dữ liệu được truy xuất trực tiếp từ View tối ưu `vw_DoanhThuNgay` trong SQL Server [25].
     * @param tuNgay Ngày bắt đầu bộ lọc
     * @param denNgay Ngày kết thúc bộ lọc
     * @return Danh sách DTO thống kê doanh thu ngày
     */
    List<DoanhThuNgayDTO> getDoanhThuTheoNgay(Date tuNgay, Date denNgay);

    /**
     * Thống kê báo cáo doanh thu theo từng tháng trong năm để vẽ biểu đồ tăng trưởng cột.
     * Dữ liệu được lấy từ View tối ưu `vw_DoanhThuThang` [26].
     * @return Danh sách DTO doanh thu tháng
     */
    List<DoanhThuThangDTO> getDoanhThuTheoThang();

    /**
     * Lấy danh sách Top 10 sản phẩm đồ uống bán chạy nhất hệ thống kèm tổng doanh thu mang lại.
     * Dữ liệu được lấy từ View tối ưu `vw_TopSanPham` [26, 27].
     * @return Danh sách DTO Top sản phẩm
     */
    List<TopSanPhamDTO> getTop10SanPhamBanChay();

    /**
     * Lấy danh sách nhân viên có doanh số chốt đơn tốt nhất cửa hàng.
     * Dữ liệu được lấy từ View tối ưu `vw_TopNhanVien` [27, 28].
     * @return Danh sách DTO xếp hạng nhân viên xuất sắc
     */
    List<TopNhanVienDTO> getTop10NhanVienDoanhThu();

    /**
     * Thống kê tỷ trọng doanh thu chia theo từng danh mục đồ uống (Ví dụ: Trà sữa chiếm 60%, Cafe 20%...) để vẽ biểu đồ tròn.
     * Dữ liệu được lấy từ View tối ưu `vw_DoanhThuTheoDanhMuc` [28].
     * @return Danh sách DTO doanh thu danh mục
     */
    List<DoanhThuDanhMucDTO> getDoanhThuTheoDanhMuc();

    /**
     * Lấy dữ liệu 4 chỉ số KPI tổng hợp nhanh để hiển thị lên 4 Card của Dashboard Admin [29]:
     * - Chỉ số 1: Doanh thu kỳ lọc (Tổng doanh thu của các đơn hoàn thành trong thời gian lọc).
     * - Chỉ số 2: Đơn hàng kỳ lọc (Tổng số hóa đơn thành công trong thời gian lọc).
     * - Chỉ số 3: Món đang bán (Tổng số sản phẩm đang mở bán hoạt động trong hệ thống).
     * - Chỉ số 4: Tổng khách hàng (Tổng số lượng khách hàng đã gia nhập hệ thống thành viên).
     * @param tuNgay Ngày bắt đầu lọc
     * @param denNgay Ngày kết thúc lọc
     * @return Đối tượng DTO chứa 4 thông số KPI cốt lõi
     */
    DashboardKpiDTO getDashboardKpis(Date tuNgay, Date denNgay);

    /**
     * Cơ chế chốt sổ số liệu hàng đêm (Cron Job Aggregation - Data Warehousing) [1, 2]:
     * - Khi đồng hồ điểm 23:59:59 hàng đêm, hệ thống kích hoạt tự động phương thức này để tổng hợp toàn bộ
     *   hàng vạn giao dịch bán lẻ phát sinh trong ngày thành duy nhất một dòng tổng quan nạp vào bảng `THONG_KE_NGAY`.
     * - Phương thức này giúp triệt tiêu hoàn toàn gánh nặng truy vấn thô của CSDL khi Admin xem biểu đồ,
     *   giúp màn hình Dashboard tải dữ liệu siêu tốc chỉ trong 0.1 giây mà không gây lag máy chủ.
     * @return true nếu chốt sổ đồng bộ dữ liệu thống kê thành công
     */
    boolean runNightlyAggregationJob();
}