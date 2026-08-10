package util;

import model.entity.DonHang;
import java.util.concurrent.ConcurrentHashMap;

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
