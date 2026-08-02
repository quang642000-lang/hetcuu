package config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Calendar;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import service.impl.ThongKeServiceImpl;

/**
 * =========================================================================
 * TEA POS SYSTEM - APPLICATION LIFECYCLE LISTENERS
 * Cleaned of redundant logs and updated to automatically schedule nightly
 * data warehousing aggregation jobs.
 * =========================================================================
 */
@WebListener
public class ContextListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Khởi động ứng dụng TEA POS. Đang kiểm tra kết nối CSDL...");
        try (Connection conn = DBConnect.getConnection()) {
            System.out.println("[TEA POS INFO] Kết nối CSDL thành công! Connection Pool đã hoạt động.");

            // Tối ưu hóa Sequences hệ thống
            String[] sequenceCommands = {
                    "ALTER SEQUENCE seq_NhanVien NO CACHE;",
                    "ALTER SEQUENCE seq_KhachHang NO CACHE;",
                    "ALTER SEQUENCE seq_DonHang NO CACHE;",
                    "ALTER SEQUENCE seq_SanPham NO CACHE;",
                    "ALTER SEQUENCE seq_DanhMuc NO CACHE;",
                    "ALTER SEQUENCE seq_Voucher NO CACHE;",
                    "ALTER SEQUENCE seq_Topping NO CACHE;"
            };
            try (Statement stmt = conn.createStatement()) {
                for (String cmd : sequenceCommands) {
                    stmt.addBatch(cmd);
                }
                stmt.executeBatch();
                System.out.println("[TEA POS INFO] Đã tối ưu cấu hình NO CACHE cho toàn bộ 7 hệ thống Sequences.");
            } catch (Exception ex) {
                System.out.println("[TEA POS WARNING] Bỏ qua cấu hình NO CACHE Sequences: " + ex.getMessage());
            }

            // KÍCH HOẠT TÍNH NĂNG CHẠY NGẦM: Tự động chạy báo cáo gộp THONG_KE_NGAY lúc 23:59 hàng ngày
            startNightlyAggregationJob();

        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Khởi chạy kết nối Connection Pool thất bại: " + e.getMessage());
        }
    }

    private void startNightlyAggregationJob() {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        Calendar calendar = Calendar.getInstance();
        Calendar now = Calendar.getInstance();

        calendar.set(Calendar.HOUR_OF_DAY, 23);
        calendar.set(Calendar.MINUTE, 59);
        calendar.set(Calendar.SECOND, 0);

        long initialDelay = calendar.getTimeInMillis() - now.getTimeInMillis();
        if (initialDelay < 0) {
            calendar.add(Calendar.DAY_OF_MONTH, 1);
            initialDelay = calendar.getTimeInMillis() - now.getTimeInMillis();
        }

        scheduler.scheduleAtFixedRate(() -> {
            System.out.println("[TEA POS CRON] Đang thực hiện chốt sổ gộp dữ liệu doanh thu cuối ngày...");
            boolean success = ThongKeServiceImpl.getInstance().runNightlyAggregationJob();
            if (success) {
                System.out.println("[TEA POS CRON] Chốt sổ dữ liệu doanh thu ngày hôm nay thành công!");
            } else {
                System.err.println("[TEA POS CRON] Chốt sổ thất bại hoặc dữ liệu ngày hôm nay đã tồn tại.");
            }
        }, initialDelay, TimeUnit.DAYS.toMillis(1), TimeUnit.MILLISECONDS);

        System.out.println("[TEA POS INFO] Đã lên lịch chốt sổ báo cáo doanh thu hàng ngày thành công (23:59 hàng đêm).");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Đang đóng ứng dụng. Tiến hành giải phóng tài nguyên...");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
        }
        try {
            DBConnect.shutdown();
            System.out.println("[TEA POS INFO] Đã giải phóng toàn bộ tài nguyên Connection Pool an toàn.");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Giải phóng kết nối Connection Pool gặp sự cố: " + e.getMessage());
        }
    }
}
