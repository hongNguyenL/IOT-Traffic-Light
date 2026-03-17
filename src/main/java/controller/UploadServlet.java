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
@MultipartConfig
public class UploadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        byte[] imageBytes = null;
        String contentType = request.getContentType();

        try {
            if (contentType != null && contentType.startsWith("multipart/form-data")) {
                // Handle as Multipart
                jakarta.servlet.http.Part filePart = request.getPart("imageFile"); // Assuming field name is imageFile
                if (filePart == null) {
                    filePart = request.getParts().iterator().next(); // Take first part if name is unknown
                }

                if (filePart != null) {
                    try (InputStream is = filePart.getInputStream()) {
                        imageBytes = is.readAllBytes();
                    }
                }
            } else {
                // Handle as Raw Binary POST
                try (InputStream inputStream = request.getInputStream()) {
                    imageBytes = inputStream.readAllBytes();
                }
            }

            if (imageBytes != null && imageBytes.length > 0) {
                System.out.println(">>> Nhan anh tu ESP32: " + imageBytes.length + " bytes");
                // 2. Upload len Supabase Storage
                String imageUrl = SupabaseService.upload(imageBytes);

                if (imageUrl != null && !imageUrl.isEmpty()) {
                    // 3. Khởi tạo và gán giá trị cho Entity Violation
                    Violation violation = new Violation();

                    // Gán các trường bắt buộc (nullable = false)
                    violation.setImageUrl(imageUrl);
                    violation.setViolationTime(new Date()); // Lấy thời gian hiện tại
                    violation.setSeverityLevel("Normal"); // Giá trị mặc định vì Database yêu cầu NOT NULL

                    // Các trường không bắt buộc (Có thể để trống hoặc set mặc định)
                    violation.setLicensePlate("Unknown");
                    violation.setVehicleType("Detecting...");

                    // 4. Lưu vào PostgreSQL thông qua DAO
                    ViolationDAO dao = new ViolationDAO();
                    boolean isSaved = dao.save(violation);

                    if (isSaved) {
                        System.out.println(">>> [SUCCESS] Da luu vao Database! ImageURL: " + imageUrl);
                        response.setStatus(HttpServletResponse.SC_OK);
                        response.getWriter().write("Success: Captured and Saved!");
                    } else {
                        System.err.println(
                                ">>> [ERROR] DAO save() returned false - check DB connection and entity state.");
                        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database save failed");
                    }
                } else {
                    System.err.println(">>> [ERROR] Supabase upload returned null - image was NOT uploaded to cloud.");
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Cloud upload failed");
                }
            } else {
                System.err.println(">>> [ERROR] imageBytes is null or empty - ESP32 may have sent no data.");
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No image data received");
            }
        } catch (Exception e) {
            System.err.println(">>> [EXCEPTION] Server Error in UploadServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server Error: " + e.getMessage());
        }
    }
}
