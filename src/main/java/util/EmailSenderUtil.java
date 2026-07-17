package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailSenderUtil {
    // SMTP Gmail configuration parameters
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "teapos.devsquad@gmail.com"; // Replace with actual Gmail address
    private static final String SENDER_PASSWORD = "your-app-password"; // Replace with 16-character App Password

    public static boolean sendOTPEmail(String recipientEmail, String otpCode) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "TEA POS DevSquad"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("[TEA POS] MÃ XÁC THỰC OTP KÍCH HOẠT / KHÔI PHỤC");

            // Custom professional HTML layout
            String htmlContent = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 25px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);\">"
                    + "  <div style=\"text-align: center; margin-bottom: 25px;\">"
                    + "    <h2 style=\"color: #10b981; margin: 0; font-size: 24px; font-weight: bold; letter-spacing: 0.5px;\">TEA POS CAFÉ</h2>"
                    + "    <p style=\"color: #64748b; font-size: 13px; margin: 6px 0 0 0; text-transform: uppercase; font-weight: 600;\">Hệ Thống Đặt Nước Online & CRM Loyalty</p>"
                    + "  </div>"
                    + "  <div style=\"border-bottom: 2px dashed #e2e8f0; margin-bottom: 25px;\"></div>"
                    + "  <div style=\"padding: 5px; color: #334155; line-height: 1.7; font-size: 15px;\">"
                    + "    <p>Xin chào quý khách,</p>"
                    + "    <p>Hệ thống nhận được yêu cầu đăng ký hội viên hoặc thay đổi bảo mật cho tài khoản của bạn trên Website Portal.</p>"
                    + "    <p>Dưới đây là mã xác thực OTP dùng để kích hoạt (Mã có hiệu lực trong vòng <strong>5 phút</strong>):</p>"
                    + "    <div style=\"text-align: center; margin: 30px 0;\">"
                    + "      <span style=\"font-size: 36px; font-weight: bold; color: #059669; letter-spacing: 6px; background-color: #ecfdf5; padding: 12px 40px; border-radius: 12px; border: 1px solid #a7f3d0; display: inline-block; font-family: 'Courier New', Courier, monospace;\">" + otpCode + "</span>"
                    + "    </div>"
                    + "    <p style=\"color: #ef4444; font-size: 12px; font-style: italic; margin-top: 15px;\">* Lưu ý bảo mật: Tuyệt đối KHÔNG cung cấp mã này cho bất kỳ ai (kể cả nhân viên cửa hàng) để tránh thất thoát điểm tích lũy hoặc tài khoản!</p>"
                    + "  </div>"
                    + "  <div style=\"border-bottom: 2px dashed #e2e8f0; margin-top: 30px; margin-bottom: 20px;\"></div>"
                    + "  <div style=\"text-align: center; font-size: 11px; color: #94a3b8; line-height: 1.4;\">"
                    + "    Bản quyền thiết kế bởi &copy; CodeDevSquad 2026. All rights reserved.<br>"
                    + "    Mọi thắc mắc vui lòng liên hệ hotline hỗ trợ: (+84) 123 456 789."
                    + "  </div>"
                    + "</div>";

            message.setContent(htmlContent, "text/html;charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
