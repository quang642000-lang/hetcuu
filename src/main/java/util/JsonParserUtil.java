package util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class JsonParserUtil {
    // Tạo cấu hình Gson chuẩn ghi nhận định dạng ngày giờ chuẩn doanh nghiệp ISO
    private static final Gson gson = new GsonBuilder()
            .setDateFormat("yyyy-MM-dd HH:mm:ss.SSS")
            .serializeNulls() // Giữ lại cả các trường mang giá trị Null trong chuỗi JSON
            .create();

    private JsonParserUtil() {}

    /**
     * Chuyển đổi một đối tượng Java bất kỳ thành chuỗi JSON
     * @param object Đối tượng cần parse
     * @return Chuỗi JSON định dạng đầy đủ thuộc tính
     */
    public static String toJson(Object object) {
        if (object == null) {
            return null;
        }
        try {
            return gson.toJson(object);
        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\":\"Không thể parse đối tượng sang JSON\"}";
        }
    }

    /**
     * Chuyển đổi ngược lại từ chuỗi JSON sang đối tượng Java
     * @param json Chuỗi JSON đầu vào
     * @param clazz Kiểu Class của đối tượng mong muốn
     * @return Đối tượng Class Java tương ứng đã nạp đủ dữ liệu
     */
    public static <T> T fromJson(String json, Class<T> clazz) {
        if (json == null || json.trim().isEmpty()) {
            return null;
        }
        try {
            return gson.fromJson(json, clazz);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}