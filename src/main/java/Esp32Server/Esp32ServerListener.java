package Esp32Server;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import dao.ControlLogDAO;

@WebListener 
public class Esp32ServerListener implements ServletContextListener {

    public static volatile String currentStatus = "WAITING FOR ESP32...";
    public static volatile long lastUpdate = 0; 

    public static volatile int timeGreen = 5;
    public static volatile int timeYellow = 2;
    public static volatile int timeRed = 7; 
    
    public static volatile boolean isAdjustingTime = false;
    public static volatile long adjustTimeStart = 0;
    
    private Thread serverThread;
    private Thread keepAliveThread;
    private ServerSocket serverSocket;
    private ControlLogDAO controlLogDAO = new ControlLogDAO();


    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Traffic System Server: Starting... opening port 9999!");
        
        serverThread = new Thread(() -> {
            try {
                serverSocket = new ServerSocket(9999);
                // Timeout để Socket không bị treo vĩnh viễn
                serverSocket.setSoTimeout(10000); 
                
                while (!Thread.currentThread().isInterrupted()) {
                    try (Socket clientSocket = serverSocket.accept()) {
                        // CHỐT HẠ: Ngay khi có kết nối (accept), reset nhịp tim ngay lập tức!
                        lastUpdate = System.currentTimeMillis();
                        
                        // Nếu đang ở trạng thái mất kết nối, chuyển sang trạng thái chờ nhận tin
                        if (currentStatus.equals("LOST CONNECTION")) {
                            currentStatus = "CONNECTED, WAITING DATA...";
                        }

                        BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                        PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);

                        // Đọc tin nhắn từ ESP32
                        String message = in.readLine();

                        if (message != null && !message.isEmpty()) {
                            // Cập nhật trạng thái và nhịp tim lần 2 khi có dữ liệu thực
                            currentStatus = message.trim().toUpperCase();
                            lastUpdate = System.currentTimeMillis(); 

                            // Gửi cấu hình thời gian mới nhất xuống ESP32
                            String configData = timeGreen + "," + timeYellow + "," + timeRed;
                            out.println(configData);
                            
                            // Log to Database
                            controlLogDAO.logCommand("ESP32_MAIN", "RECEIVED: " + currentStatus);
                            controlLogDAO.logCommand("ESP32_MAIN", "SENT_CONFIG: " + configData);
                            
                            System.out.println("ESP32: " + currentStatus + " | Sent Config: " + configData);
                        }
                    } catch (SocketTimeoutException e) {
                        // Sau 10s không thấy "gõ cửa", báo mất kết nối
                        currentStatus = "LOST CONNECTION";
                    } catch (Exception e) {
                        System.err.println("Socket Error: " + e.getMessage());
                    }
                }
            } catch (Exception e) {
                System.err.println("Server Error: " + e.getMessage());
            }
        });
        serverThread.setDaemon(true); 
        serverThread.start();

        // Keep-alive thread to prevent Render container from sleeping
        keepAliveThread = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    // Sleep for 10 minutes (600,000 ms)
                    Thread.sleep(10 * 60 * 1000);
                    
                    String urlStr = System.getenv("RENDER_EXTERNAL_URL");
                    if (urlStr == null || urlStr.isEmpty()) {
                        urlStr = "http://localhost:8080/"; 
                    }
                    
                    java.net.URL url = new java.net.URL(urlStr);
                    java.net.HttpURLConnection con = (java.net.HttpURLConnection) url.openConnection();
                    con.setRequestMethod("GET");
                    con.setConnectTimeout(5000);
                    con.setReadTimeout(5000);
                    int responseCode = con.getResponseCode();
                    System.out.println("Keep-Alive Ping to " + urlStr + " returned status: " + responseCode);
                    
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    System.err.println("Keep-Alive Ping Error: " + e.getMessage());
                }
            }
        });
        keepAliveThread.setDaemon(true);
        keepAliveThread.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Traffic System Server: Stopping...");
        try {
            if (serverSocket != null) serverSocket.close();
            if (serverThread != null) serverThread.interrupt();
            if (keepAliveThread != null) keepAliveThread.interrupt();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}