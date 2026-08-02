package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * =========================================================================
 * TEA POS SYSTEM - CRYPTOGRAPHY & SECURITY UTILITIES
 * Optimized and cleaned of redundant/gray code.
 * =========================================================================
 */
public class SecurityUtil {

    private SecurityUtil() {}

    /**
     * Hàm băm mật khẩu một chiều bằng thuật toán SHA-256 (Phòng thủ Null-Safe)
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
     * Giúp chống các cuộc tấn công Rainbow Table tầm trung cực kỳ hiệu quả.
     */
    public static String hashWithSalt(String password, String salt) {
        if (password == null) {
            return null;
        }
        String saltedPassword = password + "[$tea_pos_salt_key$]" + (salt != null ? salt.trim() : "");
        return hashSHA256(saltedPassword);
    }

    /**
     * Hàm so khớp mật khẩu người dùng nhập với mật khẩu băm kèm muối đã lưu trong CSDL
     */
    public static boolean checkPassword(String inputPassword, String dbHashedPassword, String salt) {
        if (inputPassword == null || dbHashedPassword == null) {
            return false;
        }
        String hashedInput = hashWithSalt(inputPassword, salt);
        return hashedInput.equalsIgnoreCase(dbHashedPassword.trim());
    }
}
