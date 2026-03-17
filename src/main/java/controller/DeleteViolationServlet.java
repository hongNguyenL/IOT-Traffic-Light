package controller;

import dao.ViolationDAO;
import service.SupabaseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "DeleteViolationServlet", urlPatterns = {"/deleteViolation"})
public class DeleteViolationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                ViolationDAO dao = new ViolationDAO();
                
                // Delete from DB and get back the image URL
                String imageUrl = dao.deleteViolation(id);
                
                // If a URL was returned, also delete the file from Supabase Storage
                if (imageUrl != null && !imageUrl.isEmpty()) {
                    // Extract just the filename from the full URL
                    // URL format: .../object/public/violation/violation_1234567890.jpg
                    String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
                    boolean storageDeleted = SupabaseService.deleteFile(fileName);
                    if (storageDeleted) {
                        System.out.println(">>> [DELETE] Removed from Supabase Storage: " + fileName);
                    } else {
                        System.err.println(">>> [DELETE] Failed to remove from Supabase Storage: " + fileName);
                    }
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        
        // Redirect back to the admin security section
        response.sendRedirect("admin#security");
    }
}
