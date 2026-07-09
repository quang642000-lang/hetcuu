package model.enums;

public enum PaymentStatusEnum {
    CHUA_THANH_TOAN(0, "Chưa thanh toán"), DA_THANH_TOAN(1, "Đã thanh toán"), DA_HOAN_TIEN(2, "Đã hoàn tiền");

    private final int value;
    private final String description;

    PaymentStatusEnum(int value, String description) { this.value = value; this.description = description; }
    public int getValue() { return value; }
    public String getDescription() { return description; }

    public static PaymentStatusEnum fromValue(int value) {
        for (PaymentStatusEnum status : values()) { if (status.value == value) return status; }
        throw new IllegalArgumentException("Trạng thái thanh toán không hợp lệ: " + value);
    }
}