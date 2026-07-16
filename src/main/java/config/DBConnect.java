package config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

public class DBConnect {

    // Khai báo pool kết nối HikariCP
    private static HikariDataSource dataSource;

    static {
        try {
            System.out.println("[TEA POS INFO] Đang khởi tạo Connection Pool...");
            HikariConfig config = new HikariConfig();

            // Cấu hình Driver và thông tin kết nối cơ sở dữ liệu
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String dbUrl = "jdbc:sqlserver://localhost:1433;databaseName=QuanLyQuanCafehetcuu;encrypt=true;trustServerCertificate=true;";
            config.setJdbcUrl(dbUrl);
            config.setUsername("sa");
            config.setPassword("P6t4q29!");

            // --- TỐI ƯU HIỆU SUẤT TỪ BẢN DOANH NGHIỆP ---
            config.setMaximumPoolSize(20);             // Tối đa 20 kết nối chạy đồng thời
            config.setMinimumIdle(5);                  // Duy trì tối thiểu 5 kết nối nhàn rỗi (tránh mất tgian tạo lại)
            config.setIdleTimeout(300000);             // 5 phút: Đóng các kết nối nhàn rỗi vượt quá MinimumIdle
            config.setConnectionTimeout(20000);        // 20 giây: Thời gian chờ tối đa để lấy 1 kết nối (Fail-fast)
            config.setMaxLifetime(1800000);            // 30 phút: Vòng đời tối đa của 1 kết nối, tránh tràn RAM/Cache DB

            // Kiểm tra trạng thái hoạt động của kết nối (ping)
            config.setConnectionTestQuery("SELECT 1");

            // --- TỐI ƯU LOGGING & QUẢN LÝ ---
            config.setPoolName("TeaPos-HikariCP");     // Đặt tên pool để dễ theo dõi lỗi khi có hệ thống monitor

            // Khởi tạo DataSource thực sự
            dataSource = new HikariDataSource(config);
            System.out.println("[TEA POS INFO] Khởi tạo Connection Pool " + config.getPoolName() + " thành công!");

        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Lỗi khởi tạo Connection Pool: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi nghiêm trọng: Không thể khởi tạo CSDL", e);
        }
    }

    // --- BEST PRACTICE ---
    // Constructor private để chặn việc khởi tạo thực thể bừa bãi bằng "new DBConnect()" ở class khác
    private DBConnect() {}

    /**
     * Lấy kết nối từ Pool
     * @return java.sql.Connection
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource chưa được khởi tạo.");
        }
        return dataSource.getConnection();
    }

    /**
     * Đóng toàn bộ Pool khi tắt ứng dụng (Nên gọi hàm này ở ServletContextListener khi undeploy)
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            System.out.println("[TEA POS INFO] Đang đóng ứng dụng. Tiến hành thu hồi toàn bộ kết nối...");
            dataSource.close();
            System.out.println("[TEA POS INFO] Đã đóng Connection Pool an toàn.");
        }
    }
}