package controller;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;
import util.PaymentStore;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet(name = "SePayWebhookController", urlPatterns = {"/api/sepay-webhook"})
public class SePayWebhookController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        // Read incoming JSON body from SePay Webhook
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        try {
            String jsonStr = sb.toString();
            if (jsonStr.trim().isEmpty()) {
                response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Empty payload\"}");
                return;
            }

            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();

            // Extract content (transfer description) and amount from SePay JSON schema
            String content = json.has("content") ? json.get("content").getAsString() : "";
            double amount = json.has("transferAmount") ? json.get("transferAmount").getAsDouble() : 0.0;

            // Handle webhook matching inside Service layer
            boolean success = donHangService.handleSePayWebhook(content, amount);

            if (success) {
                // Parse order ID using regex (e.g. TEAxxxx) and put in PaymentStore
                Pattern pattern = Pattern.compile("TEA(\\d+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(content);
                if (matcher.find()) {
                    String orderId = "TEA" + matcher.group(1);
                    PaymentStore.transactions.put(orderId, true);
                }
                response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"Payment processed and matched successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"status\":\"FAILED\",\"message\":\"No pending order matched this transfer\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage() + "\"\"}");
        }
    }
}
