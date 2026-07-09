package model.enums;

public enum OrderStatusEnum {
    CHO_XAC_NHAN(0, "Chờ xác nhận"), DA_XAC_NHAN(1, "Đã xác nhận"), DANG_PHA_CHE(2, "Đang pha chế"),
    CHO_LAY_HANG(3, "Chờ lấy hàng"), HOAN_THANH(4, "Hoàn thành"), DA_HUY(5, "Đã hủy");

    private final int value;
    private final String description;

    OrderStatusEnum(int value, String description) { this.value = value; this.description = description; }
    public int getValue() { return value; }
    public String getDescription() { return description; }

    public static OrderStatusEnum fromValue(int value) {
        for (OrderStatusEnum status : values()) { if (status.value == value) return status; }
        throw new IllegalArgumentException("Trạng thái đơn hàng không hợp lệ: " + value);
    }
}