import java.sql.*;

public class TestDB {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:6543/postgres?sslmode=require";
        String user = "postgres.vwbelsnquxscdbyakyfz";
        String pass = "trafficlightiot123";
        System.out.println("Connecting to database...");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT \"LogID\", \"CommandSent\", \"ExecutionTime\" FROM \"ControlLogs\" WHERE \"CommandSent\" LIKE 'RECEIVED%' ORDER BY \"ExecutionTime\" DESC LIMIT 20");
            while (rs.next()) {
                 System.out.println(rs.getString("LogID") + " | " + rs.getString("CommandSent") + " | " + rs.getString("ExecutionTime"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
