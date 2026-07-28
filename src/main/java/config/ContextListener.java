package config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;

/**
 * =========================================================================
 * TEA POS SYSTEM - APPLICATION LIFECYCLE LISTENERS
 * Optimized to handle clean startup, shutdown, and database-level sequences.
 * =========================================================================
 */
@WebListener
public class ContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Khởi động ứng dụng TEA POS. Đang kiểm tra kết nối CSDL...");

        try (Connection conn = DBConnect.getConnection()) {
            System.out.println("[TEA POS INFO] Thử kết nối CSDL thành công! Connection Pool đã hoạt động.");

            // TỐI ƯU HÓA HỆ THỐNG: Cấu hình NO CACHE cho các Sequences dưới dạng Batch Execution
            // Triệt tiêu hoàn toàn hiện tượng nhảy vọt ID rác khi hệ thống/database khởi động lại đột ngột
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
                System.out.println("[TEA POS INFO] Đã tối ưu cấu hình NO CACHE cho toàn bộ 7 hệ thống Sequences thành công!");
            } catch (Exception ex) {
                System.out.println("[TEA POS WARNING] Bỏ qua cấu hình NO CACHE Sequences (có thể do chưa chạy script khởi tạo bảng CSDL): " + ex.getMessage());
            }

        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Ổn định và khởi chạy kết nối Connection Pool thất bại: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Đang đóng ứng dụng. Tiến hành giải phóng tài nguyên...");
        try {
            DBConnect.shutdown();
            System.out.println("[TEA POS INFO] Đã thu hồi toàn bộ tài nguyên hệ thống an toàn.");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Giải phóng kết nối Connection Pool gặp sự cố: " + e.getMessage());
        }
    }
}
