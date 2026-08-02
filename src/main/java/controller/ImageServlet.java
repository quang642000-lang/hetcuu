package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Properties;

@WebServlet(name = "ImageServlet", urlPatterns = {"/assets/images/*"})
public class ImageServlet extends HttpServlet {
    private static String uploadDir;

    @Override
    public void init() throws ServletException {
        Properties properties = new Properties();
        String defaultDirWin = "C:/tea_pos_images";
        String defaultDirMac = "/var/teapos_uploads/images/";
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                properties.load(input);
                uploadDir = properties.getProperty("upload.dir");
            }
        } catch (Exception e) {
            System.err.println("[TEA POS WARNING] Không thể đọc application.properties trong ImageServlet, dùng mặc định: " + e.getMessage());
        }
        if (uploadDir == null || uploadDir.trim().isEmpty()) {
            uploadDir = System.getProperty("os.name").toLowerCase().contains("win") ? defaultDirWin : defaultDirMac;
        }
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        File file = new File(uploadDir, pathInfo);
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
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLength((int) file.length());
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
