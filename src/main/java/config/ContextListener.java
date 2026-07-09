package config;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class ContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Khởi động ứng dụng. Đang khởi tạo Connection Pool...");
        try {
            DBConnect.getConnection().close();
            System.out.println("[TEA POS INFO] Connection Pool HikariCP đã sẵn sàng!");
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