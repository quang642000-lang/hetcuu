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

@WebServlet(name = "SePayWebhookController", urlPatterns = {"/api/sepay-webhook"})
public class SePayWebhookController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();
    private String sepayToken;

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
            sepayToken = "U4RXVN1VBGSWAZR68VQ3SMYHUPFFC6AGOYBKXY8PQBTXAT3YULOBQZI4KDPZ2WSE"; // Fallback từ CSDL
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        // CHỐT CHẶN BẢO MẬT: Xác thực Webhook từ SePay để tránh giả lập Request khớp đơn khống
        String authHeader = request.getHeader("Authorization");
        String paramToken = request.getParameter("token");
        boolean authorized = false;

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
            authorized = true; // Bỏ qua nếu không cấu hình token trong file properties
        }

        if (!authorized) {
            System.err.println("⚠️ [SECURITY WARNING] Từ chối Webhook SePay do không khớp Token xác thực! Header: " + authHeader + " | Param: " + paramToken);
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
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"status\":\"FAILED\",\"message\":\"Empty payload\"}");
                return;
            }

            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();
            String content = json.has("content") ? json.get("content").getAsString() : "";

            // HỖ TRỢ ĐA KHÓA: Đọc cả transferAmount lẫn amount để tương thích với tất cả cấu hình webhook SePay
            double amount = 0.0;
            if (json.has("transferAmount")) {
                amount = json.get("transferAmount").getAsDouble();
            } else if (json.has("amount")) {
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
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"status\":\"FAILED\",\"message\":\"No pending order matched this transfer\"}");
                System.err.println("❌ [SEPAY WEBHOOK] Không tìm thấy đơn hàng chờ thanh toán khớp với nội dung: " + upperContent + " hoặc sai lệch số tiền (" + amount + "đ)");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage() + "\"\"}");
        }
    }
}
