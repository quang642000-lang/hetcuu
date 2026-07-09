package config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DBConnect {
    private static HikariDataSource dataSource;

    static {
        try {
            HikariConfig config = new HikariConfig();

            // Khai báo driver kết nối Microsoft SQL Server
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Đường dẫn URL kết nối cơ sở dữ liệu QuanLyQuanCafe [1]
            config.setJdbcUrl("jdbc:sqlserver://localhost:1433;databaseName=QuanLyQuanCafe;encrypt=true;trustServerCertificate=true;");
            config.setUsername("sa");
            config.setPassword("123456");

            // Cấu hình tối ưu hóa cho Connection Pool doanh nghiệp
            config.setMaximumPoolSize(20);             // Tối đa 20 kết nối chạy đồng thời
            config.setMinimumIdle(5);                  // Duy trì tối thiểu 5 kết nối nhàn rỗi trong bộ nhớ
            config.setIdleTimeout(300000);             // Kết nối nhàn rỗi quá 5 phút sẽ tự giải phóng (300.000 ms)
            config.setConnectionTimeout(20000);        // Giới hạn thời gian chờ kết nối tối đa 20 giây (20.000 ms)
            config.setMaxLifetime(1800000);            // Vòng đời tối đa của 1 kết nối là 30 phút (1.800.000 ms)

            // Cấu hình thuộc tính kiểm tra trạng thái hoạt động của kết nối
            config.setConnectionTestQuery("SELECT 1");

            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi nghiêm trọng: Không thể khởi tạo Connection Pool HikariCP kết nối SQL Server!");
        }
    }

    // Constructor private để chặn việc khởi tạo thực thể bừa bãi bên ngoài
    private DBConnect() {}

    // Hàm lấy Connection từ Pool để thực thi các câu lệnh SQL
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource chưa được khởi tạo thành công.");
        }
        return dataSource.getConnection();
    }

    // Hàm đóng toàn bộ Pool khi dừng ứng dụng (Tomcat Server tắt)
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }
}