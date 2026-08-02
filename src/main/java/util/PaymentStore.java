package util;

import model.entity.DonHang;
import java.util.concurrent.ConcurrentHashMap;

/**
 * =========================================================================
 * TEA POS SYSTEM - CENTRALIZED PURE IN-MEMORY PAYMENT CACHE
 *
 * TOÀN DIỆN & TINH GỌN (ĐÃ LOẠI BỎ HOÀN TOÀN REDIS / JEDIS):
 * 1. Lưu trữ tạm thời các đơn hàng chờ quét mã QR thanh toán (pendingOrders)
 *    và các giao dịch chuyển khoản VietQR thành công (transactions) bằng ConcurrentHashMap.
 * 2. Triệt tiêu hoàn toàn các lỗi kết nối, lỗi biên dịch liên quan đến Redis/Jedis.
 * 3. Đảm bảo log khởi động Tomcat cực kỳ sạch sẽ, không có cảnh báo lỗi kết nối mạng.
 * =========================================================================
 */
public class PaymentStore {
    // Bộ nhớ đệm cục bộ dạng Thread-safe ConcurrentHashMap
    private static final ConcurrentHashMap<String, Boolean> localTransactions = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, DonHang> localPendingOrders = new ConcurrentHashMap<>();

    static {
        System.out.println("[TEA POS INFO] Đang sử dụng bộ nhớ đệm ConcurrentHashMap cục bộ mượt mà và an toàn.");
    }

    // API cho Transactions
    public static void putTransaction(String key, boolean value) {
        localTransactions.put(key.toUpperCase(), value);
    }

    public static boolean containsTransaction(String key) {
        return localTransactions.containsKey(key.trim().toUpperCase());
    }

    public static void removeTransaction(String key) {
        localTransactions.remove(key.trim().toUpperCase());
    }

    // API cho PendingOrders
    public static void putPendingOrder(String orderId, DonHang order) {
        localPendingOrders.put(orderId.toUpperCase(), order);
    }

    public static DonHang getPendingOrder(String orderId) {
        return localPendingOrders.get(orderId.trim().toUpperCase());
    }

    public static boolean containsPendingOrder(String orderId) {
        return localPendingOrders.containsKey(orderId.trim().toUpperCase());
    }

    public static DonHang removePendingOrder(String orderId) {
        return localPendingOrders.remove(orderId.trim().toUpperCase());
    }

    // Ánh xạ tĩnh tương thích ngược cho CheckPaymentController và DonHangServiceImpl
    public static final ConcurrentHashMap<String, Boolean> transactions = localTransactions;
    public static final ConcurrentHashMap<String, DonHang> pendingOrders = localPendingOrders;
}
