package model.enums;

public enum DiscountTypeEnum {
    TRU_TIEN(1, "Trừ tiền mặt (VNĐ)"), TRU_PHAN_TRAM(2, "Trừ phần trăm (%)");

    private final int value;
    private final String description;

    DiscountTypeEnum(int value, String description) { this.value = value; this.description = description; }
    public int getValue() { return value; }
    public String getDescription() { return description; }

    public static DiscountTypeEnum fromValue(int value) {
        for (DiscountTypeEnum type : values()) { if (type.value == value) return type; }
        throw new IllegalArgumentException("Loại giảm giá không hợp lệ: " + value);
    }
}