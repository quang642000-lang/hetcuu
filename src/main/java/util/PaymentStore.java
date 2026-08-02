package util;

import model.entity.DonHang;
import java.io.InputStream;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.Jedis;

public class PaymentStore {
    private static final ConcurrentHashMap<String, Boolean> localTransactions = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, DonHang> localPendingOrders = new ConcurrentHashMap<>();

    private static String redisHost = "127.0.0.1"; // Thay vì "localhost" tránh lỗi phân giải DNS (DNS Name resolution failure)
    private static int redisPort = 6379;
    private static boolean useRedis = false;
    private static JedisPool jedisPool;

    static {
        Properties properties = new Properties();
        try (InputStream input = PaymentStore.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                properties.load(input);
                String host = properties.getProperty("redis.host");
                String port = properties.getProperty("redis.port");
                if (host != null && !host.trim().isEmpty()) {
                    redisHost = host.trim();
                    useRedis = true;
                }
                if (port != null && !port.trim().isEmpty()) {
                    redisPort = Integer.parseInt(port.trim());
                }
            }
        } catch (Exception e) {
            useRedis = false;
        }

        if (useRedis) {
            try {
                System.out.println("[TEA POS INFO] Đang kết nối tới máy chủ Redis đệm: " + redisHost + ":" + redisPort);
                JedisPoolConfig poolConfig = new JedisPoolConfig();
                poolConfig.setMaxTotal(10);
                poolConfig.setMaxIdle(5);
                poolConfig.setMinIdle(1);
                poolConfig.setTestOnBorrow(true);
                jedisPool = new JedisPool(poolConfig, redisHost, redisPort, 2000); // Connection timeout 2s

                try (Jedis jedis = jedisPool.getResource()) {
                    String ping = jedis.ping();
                    if ("PONG".equalsIgnoreCase(ping)) {
                        System.out.println("[TEA POS INFO] Kết nối Redis Cache thành công rực rỡ!");
                    }
                }
            } catch (Exception ex) {
                System.err.println("[TEA POS WARNING] Khởi chạy Redis thất bại, tự động lùi về chế độ ConcurrentHashMap: " + ex.getMessage());
                useRedis = false;
                if (jedisPool != null) {
                    try { jedisPool.close(); } catch(Exception e) {}
                    jedisPool = null;
                }
            }
        }
    }

    public static void putTransaction(String key, boolean value) {
        String cleanKey = key.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                jedis.setex("tx:" + cleanKey, 1800, String.valueOf(value)); // TTL 30 phút
                return;
            } catch (Exception e) {
                System.err.println("[REDIS ERROR] Lỗi ghi nhận Transaction, lùi về in-memory: " + e.getMessage());
            }
        }
        localTransactions.put(cleanKey, value);
    }

    public static boolean containsTransaction(String key) {
        String cleanKey = key.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                return jedis.exists("tx:" + cleanKey);
            } catch (Exception e) {
                // fallback
            }
        }
        return localTransactions.containsKey(cleanKey);
    }

    public static void removeTransaction(String key) {
        String cleanKey = key.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                jedis.del("tx:" + cleanKey);
                return;
            } catch (Exception e) {
                // fallback
            }
        }
        localTransactions.remove(cleanKey);
    }

    public static void putPendingOrder(String orderId, DonHang order) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                String json = util.JsonParserUtil.toJson(order);
                jedis.setex("order:" + cleanId, 3600, json); // TTL 1 giờ
                return;
            } catch (Exception e) {
                System.err.println("[REDIS ERROR] Lỗi ghi nhận Order, lùi về in-memory: " + e.getMessage());
            }
        }
        localPendingOrders.put(cleanId, order);
    }

    public static DonHang getPendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                String json = jedis.get("order:" + cleanId);
                if (json != null) {
                    return util.JsonParserUtil.fromJson(json, DonHang.class);
                }
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.get(cleanId);
    }

    public static boolean containsPendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                return jedis.exists("order:" + cleanId);
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.containsKey(cleanId);
    }

    public static DonHang removePendingOrder(String orderId) {
        String cleanId = orderId.trim().toUpperCase();
        if (useRedis && jedisPool != null) {
            try (Jedis jedis = jedisPool.getResource()) {
                DonHang order = getPendingOrder(cleanId);
                if (order != null) {
                    jedis.del("order:" + cleanId);
                    return order;
                }
            } catch (Exception e) {
                // fallback
            }
        }
        return localPendingOrders.remove(cleanId);
    }

    public static final ConcurrentHashMap<String, Boolean> transactions = localTransactions;
    public static final ConcurrentHashMap<String, DonHang> pendingOrders = localPendingOrders;
}
