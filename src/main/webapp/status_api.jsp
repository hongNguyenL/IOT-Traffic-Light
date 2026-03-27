<%@ page contentType="text/plain;charset=UTF-8" language="java" %>
<%@ page import="Esp32Server.Esp32ServerListener, websocket.TrafficWebSocket" %>
<%
    // 1. Lấy dữ liệu từ ESP32 gửi lên
    String msg = request.getParameter("msg");
    // Yêu cầu đi bộ từ Web (Nếu có)
    String reqPed = request.getParameter("reqPed");
    long currentTime = System.currentTimeMillis();

    if (reqPed != null && !reqPed.isEmpty()) {
        if (reqPed.equals("1")) Esp32ServerListener.webPedRequest1 = true;
        if (reqPed.equals("2")) Esp32ServerListener.webPedRequest2 = true;
        out.print("OK");
        return;
    }

    if (msg != null && !msg.isEmpty()) {
        // --- TRƯỜNG HỢP ESP32 GỬI TIN NHẮN ---
        // Cập nhật trạng thái và thời gian cập nhật cuối cùng (Nhịp tim)
        Esp32ServerListener.currentStatus = msg.trim();
        Esp32ServerListener.lastUpdate = currentTime;

        // 🔥 PUSH instantly to UI
        TrafficWebSocket.broadcast(msg.trim());
        
        // Cập nhật cảm biến (nếu có)
        if (request.getParameter("ir1") != null) Esp32ServerListener.ir1Status = request.getParameter("ir1");
        if (request.getParameter("ir2") != null) Esp32ServerListener.ir2Status = request.getParameter("ir2");

        // Phản hồi cho ESP32 đồng bộ đèn thật (G,Y,R,WebPed1,WebPed2)
        out.print(Esp32ServerListener.timeGreen + "," + 
                  Esp32ServerListener.timeYellow + "," + 
                  Esp32ServerListener.timeRed + "," +
                  (Esp32ServerListener.webPedRequest1 ? "1" : "0") + "," +
                  (Esp32ServerListener.webPedRequest2 ? "1" : "0"));
        
        // Reset sau khi gửi ESP32
        Esp32ServerListener.webPedRequest1 = false;
        Esp32ServerListener.webPedRequest2 = false;
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
        
        // TÍNH TOÁN ĐỘ TRỄ (AGE) CỦA DỮ LIỆU ĐỂ WEB TRỪ ĐI KHI XEM T:XX
        long age = (lastUpdate == 0) ? 0 : (currentTime - lastUpdate);
        String ageInfo = "|" + age;
        
        // Kết quả trả về Web: STATUS | LOCK | G,Y,R | AGE
        out.print(status.trim() + lockStatus + configData + ageInfo);
    }
%>