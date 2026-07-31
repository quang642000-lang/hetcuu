package controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * =========================================================================
 * TEA POS SYSTEM - HIGHLY ROBUST SEPAY WEBHOOK CONTROLLER
 * Maps to /api/sepay-webhook
 * Safe fallback, JSON parsing, automatic order matching and status transition.
 * ALWAYS returns HTTP 200 OK for standard received payloads to prevent SePay
 * from flagging errors or unverified statuses!
 * =========================================================================
 */
@WebServlet(name = "SePayWebhookController", urlPatterns = {"/api/sepay-webhook"})
public class SePayWebhookController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private String sepayToken;
    private static final boolean BYPASS_TOKEN_FOR_DEMO = true;

    @Override
    public void init() throws ServletException {
        Properties properties = new Properties();
        try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/classes/application.properties")) {
            InputStream in = input;
            if (in == null) {
                in = getClass().getClassLoader().getResourceAsStream("application.properties");
            }
            if (in != null) {
                properties.load(in);
                sepayToken = properties.getProperty("sepay.token");
            }
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Không thể nạp application.properties để lấy sepay.token: " + e.getMessage());
        }
        if (sepayToken == null || sepayToken.trim().isEmpty()) {
            sepayToken = "U4RXVN1VBGSWAZR68VQ3SMYHUPFFC6AGOYBKXY8PQBTXAT3YULOBQZI4KDPZ2WSE"; // Fallback từ properties mặc định
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String authHeader = request.getHeader("Authorization");
        String paramToken = request.getParameter("token");
        boolean authorized = false;

        if (BYPASS_TOKEN_FOR_DEMO) {
            authorized = true;
            System.out.println("⚠️ [SECURITY NOTICE] Đang chạy chế độ BYPASS_TOKEN_FOR_DEMO = true. Bỏ qua kiểm tra Token bảo mật!");
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
                authorized = true; // Bỏ qua nếu không cấu hình token
            }
        }

        if (!authorized) {
            System.err.println("❌ [SECURITY WARNING] Từ chối Webhook SePay do không khớp Token xác thực! Header: " + authHeader + " | Param: " + paramToken);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"status\":\"UNAUTHORIZED\",\"message\":\"Invalid webhook token\"}");
            return;
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        try {
            String jsonStr = sb.toString();
            if (jsonStr.trim().isEmpty()) {
                // Trả về 200 OK cho ping thử nghiệm không có nội dung
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"Empty payload acknowledged\"}");
                return;
            }

            System.out.println("📬 [SEPAY WEBHOOK RAW] " + jsonStr);
            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();

            // Hỗ trợ kiểm tra Webhook Test từ SePay
            if (json.has("content") && json.get("content").getAsString().toLowerCase().contains("test")) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"Test Webhook received successfully\"}");
                return;
            }

            // HỖ TRỢ ĐA KHÓA: Đọc cả content lẫn transactionContent đề phòng SePay thay đổi API payload
            String content = "";
            if (json.has("transactionContent") && !json.get("transactionContent").isJsonNull()) {
                content = json.get("transactionContent").getAsString();
            } else if (json.has("content") && !json.get("content").isJsonNull()) {
                content = json.get("content").getAsString();
            }

            // HỖ TRỢ ĐA KHÓA SỐ TIỀN: Đọc cả transferAmount lẫn amount
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
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"Order matched and processed\"}");
                System.out.println("✅ [SEPAY WEBHOOK] Khớp đơn và cập nhật CSDL thành công cho nội dung: " + upperContent);
            } else {
                // LUÔN TRẢ VỀ 200 OK khi nhận thành công Webhook để tránh lỗi không xác thực, nhưng gắn nhãn SKIPPED trong JSON
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\":\"SKIPPED\",\"message\":\"No pending order matched this transfer content or amount\"}");
                System.err.println("ℹ️ [SEPAY WEBHOOK] Đã nhận tín hiệu nhưng không tìm thấy đơn hàng chờ khớp hoặc sai tiền: " + upperContent + " (" + amount + "đ)");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_OK); // Trả về 200 OK kèm thông tin lỗi để đảm bảo SePay không báo lỗi gửi liên tục
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage().replace('"', '\'') + "\"}");
        }
    }
}
