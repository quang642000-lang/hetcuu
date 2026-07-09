package config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Khởi động ứng dụng. Đang khởi tạo Connection Pool kết nối cơ sở dữ liệu...");
        try {
            // Gọi một kết nối thử để kích hoạt khối Static khởi tạo HikariCP
            DBConnect.getConnection().close();
            System.out.println("[TEA POS INFO] Connection Pool HikariCP kết nối SQL Server đã sẵn sàng hoạt động!");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Khởi tạo Connection Pool thất bại: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[TEA POS INFO] Đang đóng ứng dụng. Tiến hành thu hồi toàn bộ kết nối cơ sở dữ liệu...");
        try {
            DBConnect.shutdown();
            System.out.println("[TEA POS INFO] Đã đóng thành công toàn bộ kết nối và Connection Pool HikariCP an toàn!");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Đóng Connection Pool phát sinh lỗi: " + e.getMessage());
        }
    }
}