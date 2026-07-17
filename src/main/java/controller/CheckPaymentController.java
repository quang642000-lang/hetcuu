package controller;

import util.PaymentStore;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CheckPaymentController", urlPatterns = {"/api/check-payment", "/checkout/check-payment"})
public class CheckPaymentController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String orderId = request.getParameter("id");

        if (orderId == null || orderId.trim().isEmpty()) {
            response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"Missing Order ID\"}");
            return;
        }

        Boolean isPaid = PaymentStore.transactions.get(orderId);
        if (isPaid != null && isPaid) {
            PaymentStore.transactions.remove(orderId); // Free memory immediately
            response.getWriter().write("{\"status\":\"SUCCESS\",\"message\":\"PAID\"}");
        } else {
            response.getWriter().write("{\"status\":\"PENDING\",\"message\":\"Waiting for payment confirmation\"}");
        }
    }
}
