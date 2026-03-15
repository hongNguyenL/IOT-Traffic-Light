package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "ControlLogs")
public class ControlLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LogID")
    private int logId;

    @Column(name = "DeviceID", nullable = false, length = 100)
    private String deviceId;

    @Column(name = "CommandSent", nullable = false, length = 255)
    private String commandSent;

    @Column(name = "ExecutionTime")
    @Temporal(TemporalType.TIMESTAMP)
    private Date executionTime;

    public ControlLog() {}

    // Getters and Setters
    public int getLogId() { return logId; }
    public void setLogId(int logId) { this.logId = logId; }

    public String getDeviceId() { return deviceId; }
    public void setDeviceId(String deviceId) { this.deviceId = deviceId; }

    public String getCommandSent() { return commandSent; }
    public void setCommandSent(String commandSent) { this.commandSent = commandSent; }

    public Date getExecutionTime() { return executionTime; }
    public void setExecutionTime(Date executionTime) { this.executionTime = executionTime; }
}
