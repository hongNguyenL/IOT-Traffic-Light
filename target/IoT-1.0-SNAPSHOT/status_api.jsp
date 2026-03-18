<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<%
    String msg = request.getParameter("msg");
    long currentTime = System.currentTimeMillis();

    if (msg != null && !msg.isEmpty()) {
        // ESP32 gửi lên -> Lưu vào biến static
        Esp32ServerListener.currentStatus = msg;
        Esp32ServerListener.lastUpdate = currentTime;
        
        if (request.getParameter("ir1") != null) Esp32ServerListener.ir1Status = request.getParameter("ir1");
        if (request.getParameter("ir2") != null) Esp32ServerListener.ir2Status = request.getParameter("ir2");

        // Trả về cho ESP32 để đồng bộ đèn thật
        out.print(Esp32ServerListener.timeGreen + "," + Esp32ServerListener.timeYellow + "," + Esp32ServerListener.timeRed);
    } else {
        // Dashboard (Trình duyệt) gọi -> Trả về chuỗi có dấu | để Web dễ tách
        String status = Esp32ServerListener.currentStatus;
        if (currentTime - Esp32ServerListener.lastUpdate > 12000 && Esp32ServerListener.lastUpdate != 0) {
            status = "LOST CONNECTION";
        }
        boolean isLocked = Esp32ServerListener.isAdjustingTime && (currentTime - Esp32ServerListener.adjustTimeStart < 60000);
        String lockStatus = isLocked ? "|LOCKED" : "|FREE";
        String configData = "|" + Esp32ServerListener.timeGreen + "," + Esp32ServerListener.timeYellow + "," + Esp32ServerListener.timeRed;
        
        out.print(status.trim() + lockStatus + configData);
    }
%>