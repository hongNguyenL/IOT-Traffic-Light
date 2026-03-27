package controller;

import dao.ViolationDAO;
import model.Violation;
import service.SupabaseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;

@WebServlet(name = "UploadServlet", urlPatterns = { "/upload" })
public class UploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("\n>>> [UploadServlet] Đã nhận 1 Request POST từ " + request.getRemoteAddr());
        byte[] imageBytes = null;

        try {
            // 1. Đọc dữ liệu Raw Binary trực tiếp từ Request Body
            // Lưu ý: Không dùng @MultipartConfig giúp tránh lỗi 400 khi ESP32 gửi stream
            // thuần
            try (InputStream inputStream = request.getInputStream()) {
                imageBytes = inputStream.readAllBytes();
            }

            if (imageBytes != null && imageBytes.length > 0) {
                System.out.println(">>> [ESP32] Nhan anh: " + imageBytes.length + " bytes");

                // Lấy camID từ URL (?camID=1) nếu bạn cần lưu thông tin hướng vi phạm
                String camID = request.getParameter("camID");
                if (camID == null)
                    camID = "Unknown";

                // 2. Upload lên Supabase Storage thông qua Service của bạn
                String imageUrl = SupabaseService.upload(imageBytes);

                if (imageUrl != null && !imageUrl.isEmpty()) {
                    // 3. Khởi tạo đối tượng Violation
                    Violation violation = new Violation();
                    violation.setImageUrl(imageUrl);
                    violation.setViolationTime(new Date());

                    // Bạn có thể dùng camID để set thông tin vị trí nếu cần
                    violation.setLicensePlate("CAM_" + camID);
                    violation.setVehicleType("Detecting...");

                    // 4. Lưu vào PostgreSQL qua DAO
                    ViolationDAO dao = new ViolationDAO();
                    boolean isSaved = dao.save(violation);

                    if (isSaved) {
                        System.out.println(">>> [SUCCESS] Da luu vao DB! URL: " + imageUrl);
                        response.setStatus(HttpServletResponse.SC_OK);
                        response.getWriter().write("200 OK: Captured and Saved!");
                    } else {
                        System.err.println(">>> [ERROR] DAO save() failed.");
                        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database save failed");
                    }
                } else {
                    System.err.println(">>> [ERROR] Supabase upload failed (null URL).");
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Cloud upload failed");
                }
            } else {
                System.err.println(">>> [ERROR] imageBytes bi trong (0 byte). Gửi mã lỗi 418 để test.");
                // Thay thế tạm lỗi 400 thành 418 (I'm a teapot) để chuẩn đoán lỗi
                response.sendError(418, "No image data received (Diagnostic 418)");
            }
        } catch (Exception e) {
            System.err.println(">>> [EXCEPTION] UploadServlet Error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server Error: " + e.getMessage());
        }
    }
}
