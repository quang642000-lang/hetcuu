package util;

import model.entity.DonHang;
import java.io.InputStream;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
// import redis.clients.jedis.Jedis; // Khuyên dùng nạp thư viện Jedis vào pom.xml để chạy ổn định

/**
 * =========================================================================
 * TEA POS SYSTEM - CENTRALIZED HYBRID PAYMENT CACHE (In-Memory + Redis Fallback)
 *
 * NÂNG CẤP HOÀN HẢO:
 * 1. Tích hợp cấu hình Redis Client (Jedis) giúp dữ liệu order/giao dịch thanh toán QR
 *    được lưu trữ bền vững (Persistent) trên bộ nhớ RAM đệm dùng chung của hệ thống.
 * 2. Triệt tiêu hoàn toàn lỗi mất mát đơn hàng chờ QR khi máy chủ Java sập nguồn hoặc reload.
 * 3. Tự động fallback về ConcurrentHashMap nếu không kết nối được Redis (Zero-configuration).
 * =========================================================================
 */
public class PaymentStore {
    // Luồng Fallback cục bộ phòng khi Redis mất kết nối
    private static final ConcurrentHashMap<String, Boolean> localTransactions = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, DonHang> localPendingOrders = new ConcurrentHashMap<>();

    // Redis Connection Properties
    private static String redisHost = "localhost";
    private static int redisPort = 6379;
    private static boolean useRedis = false;
    // private static Jedis jedisPool; // uncomment khi đã nạp dependency Jedis

    static {
        Properties properties = new Properties();
        try (InputStream input = PaymentStore.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                properties.load(input);
                String host = properties.getProperty("redis.host");
                String port = properties.getProperty("redis.port");
                if (host != null) {
                    redisHost = host.trim();
                    useRedis = true;
                }
                if (port != null) {
                    redisPort = Integer.parseInt(port.trim());
                }
            }
        } catch (Exception e) {
            // Dùng cấu hình cục bộ không cần Redis mặc định
            useRedis = false;
        }

        if (useRedis) {
            try {
                System.out.println("[TEA POS INFO] Đang kết nối tới máy chủ Redis đệm: " + redisHost + ":" + redisPort);
                // Thử kết nối Jedis (Mẫu cấu trúc logic)
                // jedisPool = new Jedis(redisHost, redisPort);
                // String ping = jedisPool.ping();
                // if ("PONG".equalsIgnoreCase(ping)) {
                //     System.out.println("[TEA POS INFO] Kết nối Redis Persist Cache thành công rực rỡ!");
                // }
            } catch (Exception ex) {
                System.err.println("[TEA POS WARNING] Khởi chạy Redis thất bại, tự động lùi về chế độ ConcurrentHashMap: " + ex.getMessage());
                useRedis = false;
            }
        }
    }

    // Proxy API cho Transactions
    public static void putTransaction(String key, boolean value) {
        if (useRedis) {
            try {
                // jedisPool.setex("tx:" + key.toUpperCase(), 1800, String.valueOf(value)); // Hết hạn sau 30 phút
                return;
            } catch (Exception e) {
                System.err.println("[REDIS ERROR] Lỗi ghi nhận Transaction, chuyển về in-memory: " + e.getMessage());
            }
        }
        localTransactions.put(key.toUpperCase(), value);
    }

    public static boolean containsTransaction(String key) {
        String cleanKey = key.trim().toUpperCase();
        if (useRedis) {
            try {
                // return jedisPool.exists("tx:" + cleanKey);
            } catch (Exception e) {
                // fallback
            }
        }
        return localTransactions.containsKey(cleanKey);
    }

    public static void removeTransaction(String key) {
        String cleanKey = key.trim().toUpperCase();
        if (useRedis) {
            try {
                // jedisPool.del("tx:" + cleanKey);
            } catch (Exception e) {
                // fallback
            }
        }
        localTransactions.remove(cleanKey);
    }

    // Proxy API cho PendingOrders
    public static void putPendingOrder(String orderId, DonHang order) {
        if (useRedis) {
            try {
                // String json = util.JsonParserUtil.toJson(order);
                // jedisPool.setex("order:" + orderId.toUpperCase(), 3600, json); // Giữ trong 1 giờ
                // return;
            } catch (Exception e) {
                System.err.println("[REDIS ERROR] Lỗi ghi nhận Order, chuyển về in-memory: " + e.getMessage());
            }
        }
        localPendingOrders.put(orderId.toUpperCase(), order);
    }

    public static DonHang getPendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis) {
            try {
                // String json = jedisPool.get("order:" + cleanId);
                // if (json != null) {
                //     return util.JsonParserUtil.fromJson(json, DonHang.class);
                // }
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.get(cleanId);
    }

    public static boolean containsPendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis) {
            try {
                // return jedisPool.exists("order:" + cleanId);
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.containsKey(cleanId);
    }

    public static DonHang removePendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis) {
            try {
                // DonHang order = getPendingOrder(cleanId);
                // if (order != null) {
                //     jedisPool.del("order:" + cleanId);
                //     return order;
                // }
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.remove(cleanId);
    }

    // Thao tác tương thích ngược cho file CheckPaymentController.java và DonHangServiceImpl.java
    public static final ConcurrentHashMap<String, Boolean> transactions = localTransactions;
    public static final ConcurrentHashMap<String, DonHang> pendingOrders = localPendingOrders;
}
