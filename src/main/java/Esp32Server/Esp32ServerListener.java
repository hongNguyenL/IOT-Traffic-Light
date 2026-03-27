package Esp32Server;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.net.HttpURLConnection;
import java.net.URL;

@WebListener 
public class Esp32ServerListener implements ServletContextListener {

    // --- BIẾN TRẠNG THÁI HỆ THỐNG (Static để JSP truy cập được) ---
    public static volatile String currentStatus = "LOST CONNECTION";
    public static volatile long lastUpdate = 0; 

    public static volatile int timeGreen = 10;
    public static volatile int timeYellow = 3;
    public static volatile int timeRed = 13; 
    
    public static volatile boolean isAdjustingTime = false;
    public static volatile long adjustTimeStart = 0;

    // --- THÊM: Biến lưu trạng thái cảm biến IR từ ESP32 ---
    public static volatile String ir1Status = "0";
    public static volatile String ir2Status = "0";
    
    // --- THÊM: Yêu cầu đi bộ qua đường từ WEB ---
    public static volatile boolean webPedRequest1 = false;
    public static volatile boolean webPedRequest2 = false;
    
    private Thread keepAliveThread;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Traffic System Server: Initializing...");
        
        // Vì Render không cho phép mở cổng 9999, chúng ta sẽ bỏ phần ServerSocket.
        // Mọi dữ liệu sẽ được nhận thông qua status_api.jsp
        
        // Khởi động Keep-alive thread để ngăn Render "ngủ gật"
        startKeepAlive();
    }

    private void startKeepAlive() {
        keepAliveThread = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    // Cứ 10 phút ping server một lần
                    Thread.sleep(10 * 60 * 1000);
                    
                    String urlStr = System.getenv("RENDER_EXTERNAL_URL");
                    if (urlStr == null || urlStr.isEmpty()) {
                        // Nếu chưa cấu hình biến môi trường, dùng tạm localhost
                        urlStr = "http://localhost:8080/"; 
                    }
                    
                    URL url = new URL(urlStr);
                    HttpURLConnection con = (HttpURLConnection) url.openConnection();
                    con.setRequestMethod("GET");
                    con.setConnectTimeout(5000);
                    con.setReadTimeout(5000);
                    
                    int responseCode = con.getResponseCode();
                    System.out.println("Keep-Alive Ping: " + urlStr + " | Status: " + responseCode);
                    
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    System.err.println("Keep-Alive Error: " + e.getMessage());
                }
            }
        });
        keepAliveThread.setDaemon(true);
        keepAliveThread.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Traffic System Server: Stopping...");
        if (keepAliveThread != null) {
            keepAliveThread.interrupt();
        }
    }
}