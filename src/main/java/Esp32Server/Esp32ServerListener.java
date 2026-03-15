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
    
    private Thread serverThread;
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
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Traffic System Server: Stopping...");
        try {
            if (serverSocket != null) serverSocket.close();
            if (serverThread != null) serverThread.interrupt();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}