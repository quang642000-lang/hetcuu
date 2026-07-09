package model.enums;

public enum OrderTypeEnum {
    TAI_QUAN(1, "Tại quán"), MANG_DI(2, "Mang đi"), GIAO_HANG(3, "Giao hàng");

    private final int value;
    private final String description;

    OrderTypeEnum(int value, String description) { this.value = value; this.description = description; }
    public int getValue() { return value; }
    public String getDescription() { return description; }

    public static OrderTypeEnum fromValue(int value) {
        for (OrderTypeEnum type : values()) { if (type.value == value) return type; }
        throw new IllegalArgumentException("Loại đơn hàng không hợp lệ: " + value);
    }
}