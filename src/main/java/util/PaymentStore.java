package util;

import model.entity.DonHang;
import java.util.concurrent.ConcurrentHashMap;

/**
 * =========================================================================
 * TEA POS SYSTEM - CENTRALIZED IN-MEMORY PAYMENT CACHE
 * Fully synchronized thread-safe storage for matched transactions and
 * temporary pending orders before official database commitment.
 * =========================================================================
 */
public class PaymentStore {
    // Lưu mã giao dịch Webhook gửi tới. VD: "TEA-20260716-000001" -> true
    public static final ConcurrentHashMap<String, Boolean> transactions = new ConcurrentHashMap<>();

    // Lưu đơn hàng tạm thời chờ thanh toán QR trước khi chính thức ghi nhận xuống Database
    public static final ConcurrentHashMap<String, DonHang> pendingOrders = new ConcurrentHashMap<>();
}
