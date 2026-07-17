package util;

import java.util.concurrent.ConcurrentHashMap;

public class PaymentStore {
    // Lưu mã giao dịch Webhook gửi tới. VD: "TEA-20260716-000001" -> true
    public static final ConcurrentHashMap<String, Boolean> transactions = new ConcurrentHashMap<>();
}