package controller;

import util.PaymentStore;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;
import model.entity.DonHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CheckPaymentController", urlPatterns = {"/api/check-payment", "/checkout/check-payment"})
public class CheckPaymentController extends BaseController {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            code = request.getParameter("id");
        }
        if (code == null || code.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing transaction code/id");
            return;
        }
        String cleanCode = code.trim().toUpperCase();
        String unDashedCode = cleanCode.replace("-", "");

        // 1. Check Cache first
        if (PaymentStore.containsTransaction(cleanCode) || PaymentStore.containsTransaction(unDashedCode)) {
            PaymentStore.removeTransaction(cleanCode);
            PaymentStore.removeTransaction(unDashedCode);
            System.out.println("✅ [TEA POS API] Chốt đơn thanh toán thành công cho (Cache): " + cleanCode);
            sendJson(response, new PaymentResponse("SUCCESS", "Payment matched successfully"));
            return;
        }

        // 2. Database Fallback
        DonHang dh = donHangService.getDonHangById(cleanCode);
        if (dh != null && dh.getTrangThaiThanhToan() == 1) {
            System.out.println("✅ [TEA POS API] Chốt đơn thanh toán thành công cho (Database fallback): " + cleanCode);
            sendJson(response, new PaymentResponse("SUCCESS", "Payment matched successfully"));
            return;
        }

        sendJson(response, new PaymentResponse("PENDING", "Waiting for transfer..."));
    }

    private static class PaymentResponse {
        private String status;
        private String message;
        public PaymentResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}
