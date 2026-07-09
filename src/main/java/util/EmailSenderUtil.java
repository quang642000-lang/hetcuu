package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailSenderUtil {

    // Cấu hình SMTP Server của Google Gmail
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "quang642000@gmail.com"; // Thay đổi bằng Email của dự án
    private static final String SENDER_PASSWORD = "jchji ifwc qga ynpw"; // Sử dụng App Password của Gmail

    private EmailSenderUtil() {}

    /**
     * Hàm gửi mã xác thực OTP 6 số đến Email của người dùng nhận
     * @param recipientEmail Email của khách hàng hoặc nhân viên nhận OTP
     * @param otpCode Mã OTP gồm 6 chữ số ngẫu nhiên
     * @return True nếu gửi thành công, False nếu xảy ra lỗi
     */
    public static boolean sendOTPEmail(String recipientEmail, String otpCode) {
        if (recipientEmail == null || otpCode == null) {
            return false;
        }

        // Cấu hình Properties kết nối bảo mật SMTP
        Properties properties = new Properties();
        properties.put("mail.smtp.host", SMTP_HOST);
        properties.put("mail.smtp.port", SMTP_PORT);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true"); // Kích hoạt kết nối bảo mật TLS

        // Khởi tạo Session làm việc có kèm thông tin đăng nhập SMTP
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            // Khởi tạo thực thể Message viết thư điện tử
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "TEA POS - HỆ THỐNG TRÀ SỮA"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));

            // Thiết lập tiêu đề thư
            message.setSubject("[TEA POS] MÃ XÁC THỰC OTP TÀI KHOẢN CỦA BẠN");

            // Thiết lập nội dung thư định dạng HTML chuyên nghiệp, tinh tế
            String htmlContent = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;'>"
                    + "<h2 style='color: #4CAF50; text-align: center;'>TEA POS SYSTEM</h2>"
                    + "<p>Xin chào quý khách,</p>"
                    + "<p>Bạn vừa thực hiện yêu cầu xác thực tại hệ thống đặt nước trực tuyến của <b>TEA POS</b>.</p>"
                    + "<p>Dưới đây là mã xác thực OTP của bạn:</p>"
                    + "<div style='background-color: #f1f1f1; padding: 15px; text-align: center; font-size: 28px; font-weight: bold; letter-spacing: 5px; color: #333; border-radius: 4px; margin: 20px 0;'>"
                    + otpCode
                    + "</div>"
                    + "<p style='color: #FF5722;'><b>Lưu ý:</b> Mã xác thực này có hiệu lực sử dụng trong vòng <b>2 phút</b> và chỉ sử dụng được 1 lần duy nhất [10]. Tuyệt đối không chia sẻ mã này cho bất kỳ ai khác.</p>"
                    + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>"
                    + "<p style='font-size: 12px; color: #888; text-align: center;'>Thư điện tử được gửi tự động từ hệ thống TEA POS. Vui lòng không trả lời thư này.</p>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            // Tiến hành gửi Email
            Transport.send(message);
            return true;
        } catch (Exception e) {
            System.err.println("[TEA POS ERROR] Gửi email OTP thất bại: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
