<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener" %>
<%
    // 1. Lấy dữ liệu từ ESP32 gửi lên
    String msg = request.getParameter("msg");
    long currentTime = System.currentTimeMillis();

    if (msg != null && !msg.isEmpty()) {
        // --- TRƯỜNG HỢP ESP32 GỬI TIN NHẮN ---
        // Cập nhật trạng thái và thời gian cập nhật cuối cùng (Nhịp tim)
        Esp32ServerListener.currentStatus = msg.trim();
        Esp32ServerListener.lastUpdate = currentTime;
        
        // Cập nhật cảm biến (nếu có)
        if (request.getParameter("ir1") != null) Esp32ServerListener.ir1Status = request.getParameter("ir1");
        if (request.getParameter("ir2") != null) Esp32ServerListener.ir2Status = request.getParameter("ir2");

        // Phản hồi cho ESP32 đồng bộ đèn thật (G,Y,R)
        out.print(Esp32ServerListener.timeGreen + "," + 
                  Esp32ServerListener.timeYellow + "," + 
                  Esp32ServerListener.timeRed);
    } 
    else {
        // --- TRƯỜNG HỢP DASHBOARD (WEB) GỌI ---
        String status = Esp32ServerListener.currentStatus;
        long lastUpdate = Esp32ServerListener.lastUpdate;

        // KIỂM TRA TRẠNG THÁI KẾT NỐI
        if (lastUpdate == 0) {
            // Nếu server vừa bật và chưa thấy ESP32 đâu
            status = "WAITING FOR ESP32";
        } 
        else if (currentTime - lastUpdate > 30000) { 
            // Nếu quá 30 giây không thấy tin nhắn mới (Tăng từ 12s lên 30s để ổn định trên Web)
            status = "LOST CONNECTION";
        }
        
        // KIỂM TRA KHÓA CHỈNH SỬA
        boolean isLocked = Esp32ServerListener.isAdjustingTime && (currentTime - Esp32ServerListener.adjustTimeStart < 60000);
        String lockStatus = isLocked ? "|LOCKED" : "|FREE";
        
        // GỬI KÈM CONFIG ĐỂ WEB ĐỒNG BỘ THỜI GIAN
        String configData = "|" + Esp32ServerListener.timeGreen + "," + 
                            Esp32ServerListener.timeYellow + "," + 
                            Esp32ServerListener.timeRed;
        
        // Kết quả trả về Web: STATUS | LOCK | G,Y,R
        out.print(status.trim() + lockStatus + configData);
    }
%>