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

@WebServlet(name = "SePayWebhookController", urlPatterns = {"/api/sepay-webhook"})
public class SePayWebhookController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
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
            double amount = json.has("transferAmount") ? json.get("transferAmount").getAsDouble() : 0.0;

            // Re-match content uppercase
            String upperContent = content.toUpperCase();

            // Execute Database matching and state transitions
            boolean success = donHangService.handleSePayWebhook(upperContent, amount);

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"Order matched and processed\"}");
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