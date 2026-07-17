package controller;

import util.PaymentStore;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "CheckPaymentController", urlPatterns = {"/api/check-payment", "/checkout/check-payment"})
public class CheckPaymentController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            code = request.getParameter("id");
        }

        if (code == null || code.trim().isEmpty()) {
            out.print("{\"status\":\"ERROR\", \"message\":\"Missing transaction code/id\"}");
            return;
        }

        String cleanCode = code.trim().toUpperCase();
        String unDashedCode = cleanCode.replace("-", "");

        // Check in PaymentStore cache
        if (PaymentStore.transactions.containsKey(cleanCode) || PaymentStore.transactions.containsKey(unDashedCode)) {
            PaymentStore.transactions.remove(cleanCode);
            PaymentStore.transactions.remove(unDashedCode);
            System.out.println("✅ [TEA POS API] Chốt đơn thanh toán thành công cho: " + cleanCode);
            out.print("{\"status\":\"SUCCESS\", \"message\":\"Payment matched successfully\"}");
        } else {
            out.print("{\"status\":\"PENDING\", \"message\":\"Waiting for transfer...\"}");
        }
    }
}