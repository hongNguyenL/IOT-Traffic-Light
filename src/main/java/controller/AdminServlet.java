package controller;

import dao.ViolationDAO;
import model.Violation;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Gọi DAO lấy dữ liệu
        ViolationDAO dao = new ViolationDAO();
        List<Violation> list = dao.getAllViolations();
        
        // 2. Đặt dữ liệu vào request với tên "listV" (Khớp với c:forEach trong JSP)
        request.setAttribute("listV", list);
        
        // 3. Forward sang trang admin.jsp (hoặc file chứa security_section của bạn)
        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }
}