package util;

import java.util.concurrent.ConcurrentHashMap;

public class PaymentStore {
    // ConcurrentHashMap to safely store paid order transactions across threads
    public static final ConcurrentHashMap<String, Boolean> transactions = new ConcurrentHashMap<>();
}
