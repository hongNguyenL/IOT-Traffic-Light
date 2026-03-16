<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<%
    String status = request.getParameter("status");
    long currentTime = System.currentTimeMillis();
    
    if ("true".equals(status)) {
        if (Esp32ServerListener.isAdjustingTime && (currentTime - Esp32ServerListener.adjustTimeStart < 60000)) {
            out.print("LOCKED");
        } else {
            Esp32ServerListener.isAdjustingTime = true;
            Esp32ServerListener.adjustTimeStart = currentTime;
            out.print("OK");
        }
    } else {
        Esp32ServerListener.isAdjustingTime = false;
        out.print("OK");
    }
%>
