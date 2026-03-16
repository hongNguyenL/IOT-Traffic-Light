package controller;

import dao.ViolationDAO;
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
                dao.deleteViolation(id);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        
        // Redirect back to the admin security section
        response.sendRedirect("admin#security");
    }
}
