package util;

public class EmailUtil {
    public static boolean sendOtpEmail(String recipientEmail, String otpCode) {
        return EmailSenderUtil.sendOTPEmail(recipientEmail, otpCode);
    }
}