package config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;

@WebListener
public class ContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Khởi động ứng dụng. Đang khởi tạo Connection Pool...");
        try {
            DBConnect.getConnection().close();
            System.out.println("[TEA POS INFO] Connection Pool HikariCP đã sẵn sàng!");

            // TỐI ƯU HÓA HỆ THỐNG: Cấu hình NO CACHE cho các Sequences của SQL Server
            // Loại bỏ hoàn toàn hiện tượng nhảy vọt ID (gaps) rác khi máy chủ/database khởi động lại đột ngột
            try (Connection conn = DBConnect.getConnection();
                 Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER SEQUENCE seq_NhanVien NO CACHE;");
                stmt.execute("ALTER SEQUENCE seq_KhachHang NO CACHE;");
                stmt.execute("ALTER SEQUENCE seq_DonHang NO CACHE;");
                stmt.execute("ALTER SEQUENCE seq_SanPham NO CACHE;");
                System.out.println("[TEA POS INFO] Đã tối ưu cấu hình NO CACHE cho toàn bộ sequences thành công!");
            } catch (Exception ex) {
                System.out.println("[TEA POS WARNING] Cấu hình NO CACHE sequence bỏ qua (có thể chưa chạy script khởi tạo DB): " + ex.getMessage());
            }

        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Khởi tạo Connection Pool thất bại: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Đang đóng ứng dụng. Tiến hành thu hồi toàn bộ kết nối...");
        try {
            DBConnect.shutdown();
            System.out.println("[TEA POS INFO] Đã đóng thành công toàn bộ kết nối!");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Đóng Connection Pool phát sinh lỗi: " + e.getMessage());
        }
    }
}
