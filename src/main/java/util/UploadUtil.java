package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.util.Properties;
import java.util.UUID;

/**
 * =========================================================================
 * TEA POS SYSTEM - CENTRALIZED FILE UPLOAD UTILITY
 * Consolidates duplicate upload logic from DanhMuc, SanPham, Topping Controllers.
 * Reads directory from application.properties dynamically with safe OS fallbacks.
 * =========================================================================
 */
public class UploadUtil {

    private static String uploadDir;

    static {
        Properties properties = new Properties();
        String defaultDirWin = "C:/teapos_uploads/images/";
        String defaultDirMac = "/var/teapos_uploads/images/";

        try (InputStream input = UploadUtil.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                properties.load(input);
                uploadDir = properties.getProperty("upload.dir");
            }
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Không thể đọc application.properties trong UploadUtil: " + e.getMessage());
        }

        if (uploadDir == null || uploadDir.trim().isEmpty()) {
            // Tự động phân tách ổ đĩa lưu trữ cố định dựa trên hệ điều hành
            uploadDir = System.getProperty("os.name").toLowerCase().contains("win") ? defaultDirWin : defaultDirMac;
        }

        // Khởi tạo thư mục nếu chưa tồn tại
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    private UploadUtil() {}

    /**
     * Thao tác upload tệp tin từ Form Multipart và lưu trữ an toàn dưới ổ đĩa cứng máy chủ
     * @param request Servlet Request chứa luồng Part
     * @param inputFieldName Tên trường input file (ví dụ: "hinhAnhFile")
     * @return Đường dẫn URL tương đối truy cập ảnh hoặc null nếu upload thất bại
     */
    public static String uploadFile(HttpServletRequest request, String inputFieldName) {
        try {
            Part filePart = request.getPart(inputFieldName);
            if (filePart == null || filePart.getSize() == 0) {
                return null;
            }

            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || fileName.trim().isEmpty()) {
                return null;
            }

            int dotIdx = fileName.lastIndexOf(".");
            if (dotIdx == -1) {
                return null;
            }

            String fileExt = fileName.substring(dotIdx);
            // Mã hóa tên tệp tin độc bản bằng UUID kết hợp Epoch Millis để chống ghi đè dữ liệu
            String newFileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + fileExt;

            File file = new File(uploadDir, newFileName);
            filePart.write(file.getAbsolutePath());

            // Trả về URL tương đối khớp với mapping của ImageServlet (/assets/images/*)
            return request.getContextPath() + "/assets/images/" + newFileName;
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Lỗi trong quá trình upload tệp tin: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
