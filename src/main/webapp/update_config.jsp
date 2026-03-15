<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<%
    // Lấy dữ liệu và cắt bỏ khoảng trắng thừa ngay lập tức
    String gStr = request.getParameter("g");
    String yStr = request.getParameter("y");
    String rStr = request.getParameter("r");
    
    out.println("DEBUG: g=" + gStr + " y=" + yStr + " r=" + rStr + "<br>");
    
    // Nếu gStr bị null tức là trình duyệt gửi sai tên tham số (ví dụ gửi 'green' thay vì 'g')
    if (gStr == null || yStr == null || rStr == null) {
        out.print("LỖI: Server không nhận được tham số g, y, r. Hãy kiểm tra lại JavaScript!");
        return;
    }

    if (gStr.isEmpty() || yStr.isEmpty() || rStr.isEmpty()) {
        out.print("LỖI: Giá trị gửi sang bị trống!");
        return;
    }

    try {
        Esp32ServerListener.timeGreen = Integer.parseInt(gStr.trim());
        Esp32ServerListener.timeYellow = Integer.parseInt(yStr.trim());
        Esp32ServerListener.timeRed = Integer.parseInt(rStr.trim());
        out.print("OK");
    } catch (Exception e) {
        out.print("LỖI: Dữ liệu '" + gStr + "' không phải là số!");
    }
%>