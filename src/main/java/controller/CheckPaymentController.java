package controller;

import util.PaymentStore;
import service.IDonHangService;
import service.impl.DonHangServiceImpl;
import model.entity.DonHang;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * =========================================================================
 * TEA POS SYSTEM - HIGH-PERFORMANCE PAYMENT VERIFICATION CONTROLLER (VietQR)
 * Leverages ConcurrentHashMap cache lookup first for ultra-fast response,
 * and seamlessly falls back to direct database query as a fail-safe
 * against cache expiration, JVM restarts, or multi-node race conditions.
 * =========================================================================
 */
@WebServlet(name = "CheckPaymentController", urlPatterns = {"/api/check-payment", "/checkout/check-payment"})
public class CheckPaymentController extends HttpServlet {
    private final IDonHangService donHangService = DonHangServiceImpl.getInstance();

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

        // 1. Kiểm tra bộ nhớ đệm PaymentStore (Ưu tiên phản hồi nhanh realtime)
        if (PaymentStore.transactions.containsKey(cleanCode) || PaymentStore.transactions.containsKey(unDashedCode)) {
            PaymentStore.transactions.remove(cleanCode);
            PaymentStore.transactions.remove(unDashedCode);
            System.out.println("✅ [TEA POS API] Chốt đơn thanh toán thành công cho (Cache): " + cleanCode);
            out.print("{\"status\":\"SUCCESS\", \"message\":\"Payment matched successfully\"}");
            return;
        }

        // 2. FALLBACK: Kiểm tra trạng thái thực tế dưới Database phòng ngừa cache bị dọn sạch
        DonHang dh = donHangService.getDonHangById(cleanCode);
        if (dh != null && dh.getTrangThaiThanhToan() == 1) {
            System.out.println("✅ [TEA POS API] Chốt đơn thanh toán thành công cho (Database fallback): " + cleanCode);
            out.print("{\"status\":\"SUCCESS\", \"message\":\"Payment matched successfully\"}");
            return;
        }

        out.print("{\"status\":\"PENDING\", \"message\":\"Waiting for transfer...\"}");
    }
}
