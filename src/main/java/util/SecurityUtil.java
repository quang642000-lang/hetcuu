package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SecurityUtil {

    // Constructor private để chặn việc khởi tạo thực thể
    private SecurityUtil() {}

    /**
     * Hàm băm mật khẩu một chiều bằng thuật toán SHA-256
     * @param password Mật khẩu gốc dạng clear text
     * @return Chuỗi Hex dài 64 ký tự đã mã hóa thành công
     */
    public static String hashSHA256(String password) {
        if (password == null) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = digest.digest(password.getBytes());

            // Chuyển mảng byte đã băm sang dạng chuỗi Hexadecimal thập lục phân
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashedBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi nghiêm trọng: Không tìm thấy thuật toán mã hóa SHA-256!");
        }
    }

    /**
     * Hàm so khớp mật khẩu người dùng nhập vào với mật khẩu băm đã lưu trong CSDL
     * @param inputPassword Mật khẩu người dùng nhập vào Form
     * @param dbHashedPassword Mật khẩu đã băm trong cơ sở dữ liệu
     * @return True nếu trùng khớp hoàn toàn, False nếu sai mật khẩu
     */
    public static boolean checkPassword(String inputPassword, String dbHashedPassword) {
        if (inputPassword == null || dbHashedPassword == null) {
            return false;
        }
        String hashedInput = hashSHA256(inputPassword);
        return hashedInput.equalsIgnoreCase(dbHashedPassword);
    }
}