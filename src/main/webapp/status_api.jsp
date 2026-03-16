<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<%
    long currentTime = System.currentTimeMillis();
    long lastUpdate = Esp32ServerListener.lastUpdate;
    String status = Esp32ServerListener.currentStatus;

    // 1. Kiểm tra nhịp tim: Nếu quá 12 giây không có tin nhắn mới
    if (currentTime - lastUpdate > 12000 && lastUpdate != 0) {
        status = "LOST CONNECTION";
    } 
    // 2. Nếu nhịp tim còn mới (dưới 12s) mà status vẫn là LOST CONNECTION 
    // thì nghĩa là nó vừa online lại, cần reset chữ hiển thị
    else if (status.equals("LOST CONNECTION")) {
        status = "CONNECTING...";
    }
    
    boolean isLocked = Esp32ServerListener.isAdjustingTime && (currentTime - Esp32ServerListener.adjustTimeStart < 60000);
    String lockStatus = isLocked ? "|LOCKED" : "|FREE";
    
    out.print(status.trim() + lockStatus);
%>