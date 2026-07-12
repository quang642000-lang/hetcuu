package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet(name = "ImageServlet", urlPatterns = {"/assets/images/*"})
public class ImageServlet extends HttpServlet {
    private static final String UPLOAD_DIR_WIN = "C:/teapos_uploads/images/";
    private static final String UPLOAD_DIR_MAC = "/var/teapos_uploads/images/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo(); // Lấy tên tệp tin ví dụ: /1711234567_abc.png
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Tự động phân tách ổ đĩa lưu trữ cố định dựa trên hệ điều hành của máy tính chạy local
        String baseDir = System.getProperty("os.name").toLowerCase().contains("win") ? UPLOAD_DIR_WIN : UPLOAD_DIR_MAC;
        File file = new File(baseDir, pathInfo);

        // FALLBACK: Nếu tệp tin không tồn tại ở thư mục cố định bên ngoài, tìm kiếm trong thư mục Real Path tạm thời của Webapp
        if (!file.exists()) {
            String realPath = getServletContext().getRealPath("/assets/images" + pathInfo);
            if (realPath != null) {
                file = new File(realPath);
            }
        }

        if (!file.exists() || file.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Đọc MimeType tự động để trình duyệt render tệp tin ảnh sắc nét
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLength((int) file.length());

        // Thực hiện ghi luồng byte ảnh từ đĩa cứng trả về luồng HTTP Response
        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
