package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * =========================================================================
 * TEA POS SYSTEM - CRYPTOGRAPHY & SECURITY UTILITIES
 * Optimized for high security, salting protection, and defensive null guards.
 * =========================================================================
 */
public class SecurityUtil {

    // Chặn khởi tạo thực thể bừa bãi
    private SecurityUtil() {}

    /**
     * Hàm băm mật khẩu một chiều bằng thuật toán SHA-256 với cơ chế phòng thủ Null-Safe
     * @param password Mật khẩu gốc dạng rõ (clear text)
     * @return Chuỗi Hex dài 64 ký tự đã băm bảo mật
     */
    public static String hashSHA256(String password) {
        if (password == null || password.trim().isEmpty()) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            System.err.println("[SECURITY ERROR] Không tìm thấy thuật toán mã hóa SHA-256: " + e.getMessage());
            throw new RuntimeException("Lỗi bảo mật mã hóa mật khẩu", e);
        }
    }

    /**
     * Hàm băm mật khẩu nâng cao kết hợp Muối độc bản (Salted Password Hashing)
     * Ngăn chặn hoàn toàn các cuộc tấn công Rainbow Table tầm trung
     * @param password Mật khẩu gốc
     * @param salt Muối bổ sung (ví dụ: tên đăng nhập hoặc email)
     * @return Chuỗi băm bảo mật kèm muối
     */
    public static String hashWithSalt(String password, String salt) {
        if (password == null) {
            return null;
        }
        String saltedPassword = password + "[$tea_pos_salt_key$]" + (salt != null ? salt.trim() : "");
        return hashSHA256(saltedPassword);
    }

    /**
     * Hàm so khớp mật khẩu người dùng nhập vào với mật khẩu băm đã lưu trong CSDL
     * @param inputPassword Mật khẩu người dùng gõ từ Form
     * @param dbHashedPassword Mật khẩu đã băm lưu dưới CSDL
     * @return true nếu trùng khớp hoàn toàn, false nếu sai mật khẩu
     */
    public static boolean checkPassword(String inputPassword, String dbHashedPassword) {
        if (inputPassword == null || dbHashedPassword == null) {
            return false;
        }
        String hashedInput = hashSHA256(inputPassword);
        return hashedInput.equalsIgnoreCase(dbHashedPassword.trim());
    }
}
