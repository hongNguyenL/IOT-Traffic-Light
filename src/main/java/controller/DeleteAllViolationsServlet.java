package controller;

import dao.ViolationDAO;
import service.SupabaseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DeleteAllViolationsServlet", urlPatterns = {"/deleteAllViolations"})
public class DeleteAllViolationsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ViolationDAO dao = new ViolationDAO();

        // Delete all from DB and get back all image URLs
        List<String> imageUrls = dao.deleteAllViolations();

        // Delete each file from Supabase Storage
        int deleted = 0;
        for (String imageUrl : imageUrls) {
            if (imageUrl != null && !imageUrl.isEmpty()) {
                String fileName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
                if (SupabaseService.deleteFile(fileName)) {
                    deleted++;
                }
            }
        }
        System.out.println(">>> [DELETE ALL] Removed " + imageUrls.size() + " DB records and "
                + deleted + " files from Supabase Storage.");

        // Redirect back to admin violations tab
        response.sendRedirect("admin#security");
    }
}
