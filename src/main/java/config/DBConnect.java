package config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * =========================================================================
 * TEA POS SYSTEM - HIGH-PERFORMANCE DATABASE CONNECTION POOL (HikariCP)
 * Optimized and fully synchronized with application.properties
 * Supported environment variables resolution to ensure strict production security.
 * =========================================================================
 */
public class DBConnect {
    private static HikariDataSource dataSource;

    static {
        try {
            System.out.println("[TEA POS INFO] Đang khởi tạo Connection Pool...");
            Properties properties = new Properties();
            // Nạp động cấu hình từ application.properties
            try (InputStream input = DBConnect.class.getClassLoader().getResourceAsStream("application.properties")) {
                if (input != null) {
                    properties.load(input);
                    System.out.println("[TEA POS INFO] Đã nạp thành công cấu hình application.properties!");
                } else {
                    System.err.println("[TEA POS WARNING] Không tìm thấy file application.properties! Sử dụng cấu hình mặc định...");
                }
            } catch (Exception ex) {
                System.err.println("[TEA POS WARNING] Gặp lỗi khi đọc file application.properties: " + ex.getMessage());
            }

            // Trích xuất các tham số cấu hình và xử lý các mốc biến môi trường Placeholder nâng cao
            String dbUrl = resolvePlaceholder(properties.getProperty("db.url"));
            String dbUser = resolvePlaceholder(properties.getProperty("db.user"));
            String dbPass = resolvePlaceholder(properties.getProperty("db.password"));

            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            config.setJdbcUrl(dbUrl);
            config.setUsername(dbUser);
            config.setPassword(dbPass);

            // --- TỐI ƯU HÓA HIỆU NĂNG DOANH NGHIỆP ---
            config.setMaximumPoolSize(20);             // Tối đa 20 kết nối chạy đồng thời
            config.setMinimumIdle(5);                  // Duy trì tối thiểu 5 kết nối nhàn rỗi (tránh mất thời gian tạo mới)
            config.setIdleTimeout(300000);             // 5 phút: Giải phóng kết nối nhàn rỗi vượt mức tối thiểu
            config.setConnectionTimeout(20000);        // 20 giây: Thời gian chờ tối đa để lấy 1 kết nối (Fail-fast)
            config.setMaxLifetime(1800000);            // 30 phút: Vòng đời tối đa của kết nối để tránh tràn RAM/Cache DB
            config.setConnectionTestQuery("SELECT 1");  // Kiểm tra trạng thái sống của kết nối

            // Tối ưu hóa hiệu năng SQL Server JDBC
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");

            dataSource = new HikariDataSource(config);
            System.out.println("[TEA POS INFO] Khởi tạo Connection Pool HikariCP thành công rực rỡ!");
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Khởi tạo Connection Pool HikariCP thất bại thảm hại: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Không thể khởi tạo cơ sở dữ liệu: " + e.getMessage(), e);
        }
    }

    // Chặn khởi tạo thực thể bừa bãi bằng private constructor
    private DBConnect() {}

    /**
     * Giải quyết các dải Placeholder dạng ${ENV_VAR:defaultValue} cho cấu hình kết nối CSDL
     */
    private static String resolvePlaceholder(String value) {
        if (value == null) return null;
        if (value.startsWith("${") && value.endsWith("}")) {
            String content = value.substring(2, value.length() - 1);
            int colonIdx = content.indexOf(":");
            String envName = content;
            String defaultValue = "";
            if (colonIdx != -1) {
                envName = content.substring(0, colonIdx);
                defaultValue = content.substring(colonIdx + 1);
            }
            String envValue = System.getenv(envName);
            if (envValue != null && !envValue.trim().isEmpty()) {
                return envValue.trim();
            }
            return defaultValue.trim();
        }
        return value;
    }

    /**
     * Lấy kết nối từ Connection Pool
     * @return java.sql.Connection
     * @throws SQLException khi không thể lấy kết nối
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            throw new SQLException("DataSource chưa được khởi tạo hoặc đã bị đóng.");
        }
        return dataSource.getConnection();
    }

    /**
     * Giải phóng và đóng toàn bộ Connection Pool an toàn khi undeploy ứng dụng
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            System.out.println("[TEA POS INFO] Đang thu hồi toàn bộ kết nối và đóng Connection Pool...");
            dataSource.close();
            System.out.println("[TEA POS INFO] Đã giải phóng Connection Pool an toàn.");
        }
    }
}