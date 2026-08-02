package controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

@WebServlet(name = "SePayWebhookController", urlPatterns = {"/api/sepay-webhook"})
public class SePayWebhookController extends BaseController {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private String sepayToken;
    private boolean bypassTokenForDemo = false;

    @Override
    public void init() throws ServletException {
        Properties properties = new Properties();
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                properties.load(input);

                String rawToken = properties.getProperty("sepay.token");
                String rawBypass = properties.getProperty("sepay.bypass");

                if (rawToken != null) {
                    sepayToken = resolvePlaceholder(rawToken);
                }
                if (rawBypass != null) {
                    String cleanBypass = resolvePlaceholder(rawBypass);
                    bypassTokenForDemo = Boolean.parseBoolean(cleanBypass.trim());
                }
            }
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Không thể nạp application.properties để lấy cấu hình SePay: " + e.getMessage());
        }

        if (sepayToken == null || sepayToken.trim().isEmpty() || sepayToken.contains("${")) {
            sepayToken = "U4RXVN1VBGSWAZR68VQ3SMYHUPFFC6AGOYBKXY8PQBTXAT3YULOBQZI4KDPZ2WSE";
        }

        System.out.println("[TEA POS SEPAY INIT] SePay Webhook Token initialized (Bypass: " + bypassTokenForDemo + ")");
    }

    private static String resolvePlaceholder(String value) {
        if (value == null) return null;
        value = value.trim();
        if (value.startsWith("${") && value.endsWith("}")) {
            String inner = value.substring(2, value.length() - 1);
            int colonIdx = inner.indexOf(':');
            String envVar = colonIdx == -1 ? inner : inner.substring(0, colonIdx);
            String defaultValue = colonIdx == -1 ? "" : inner.substring(colonIdx + 1);

            String envValue = System.getenv(envVar);
            if (envValue != null && !envValue.trim().isEmpty()) {
                return envValue.trim();
            }
            return defaultValue.trim();
        }
        return value;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        String paramToken = request.getParameter("token");
        boolean authorized = false;

        if (bypassTokenForDemo) {
            authorized = true;
            System.out.println("⚠️ [SECURITY NOTICE] Đang chạy chế độ BYPASS_TOKEN_FOR_DEMO = true. Chỉ dùng cho thử nghiệm!");
        } else {
            if (sepayToken != null && !sepayToken.trim().isEmpty()) {
                if (paramToken != null && paramToken.trim().equals(sepayToken.trim())) {
                    authorized = true;
                } else if (authHeader != null) {
                    String cleanHeader = authHeader.replace("Apikey", "").replace("Bearer", "").trim();
                    if (cleanHeader.equals(sepayToken.trim())) {
                        authorized = true;
                    }
                }
            } else {
                authorized = true;
            }
        }

        if (!authorized) {
            System.err.println("❌ [SECURITY WARNING] Từ chối Webhook SePay do không khớp Token xác thực! Header: " + authHeader + " | Param: " + paramToken);
            sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Invalid webhook token");
            return;
        }

        String jsonStr = getRequestBody(request);
        if (jsonStr == null || jsonStr.trim().isEmpty()) {
            sendJson(response, new WebhookResponse("SUCCESS", "Empty payload acknowledged"));
            return;
        }

        try {
            System.out.println("📬 [SEPAY WEBHOOK RAW] " + jsonStr);
            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();
            if (json.has("content") && json.get("content").getAsString().toLowerCase().contains("test")) {
                sendJson(response, new WebhookResponse("SUCCESS", "Test Webhook received successfully"));
                return;
            }

            String content = "";
            if (json.has("transactionContent") && !json.get("transactionContent").isJsonNull()) {
                content = json.get("transactionContent").getAsString();
            } else if (json.has("content") && !json.get("content").isJsonNull()) {
                content = json.get("content").getAsString();
            }

            double amount = 0.0;
            if (json.has("transferAmount") && !json.get("transferAmount").isJsonNull()) {
                amount = json.get("transferAmount").getAsDouble();
            } else if (json.has("amount") && !json.get("amount").isJsonNull()) {
                amount = json.get("amount").getAsDouble();
            }

            System.out.println("📬 [SEPAY WEBHOOK] Nhận tín hiệu thanh toán: Nội dung='" + content + "', Số tiền=" + amount);
            String upperContent = content.toUpperCase();
            boolean success = donHangService.handleSePayWebhook(upperContent, amount);
            if (success) {
                System.out.println("✅ [SEPAY WEBHOOK] Khớp đơn và cập nhật CSDL thành công cho nội dung: " + upperContent);
                sendJson(response, new WebhookResponse("SUCCESS", "Order matched and processed"));
            } else {
                System.err.println("ℹ️ [SEPAY WEBHOOK] Đã nhận tín hiệu nhưng không tìm thấy đơn hàng chờ khớp hoặc sai tiền: " + upperContent);
                sendJson(response, new WebhookResponse("SKIPPED", "No pending order matched"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendJson(response, new WebhookResponse("ERROR", e.getMessage()));
        }
    }

    private static class WebhookResponse {
        private String status;
        private String message;

        public WebhookResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}
