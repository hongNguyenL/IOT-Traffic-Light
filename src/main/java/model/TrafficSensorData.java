package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "TrafficSensorData")
public class TrafficSensorData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DataID")
    private int dataId;

    @Column(name = "LdrPedestrianRequests")
    private Integer ldrPedestrianRequests;

    @Column(name = "TrafficFlowCount")
    private Integer trafficFlowCount;

    @Column(name = "RecordedTime")
    @Temporal(TemporalType.TIMESTAMP)
    private Date recordedTime;

    public TrafficSensorData() {}

    // Getters and Setters
    public int getDataId() { return dataId; }
    public void setDataId(int dataId) { this.dataId = dataId; }

    public Integer getLdrPedestrianRequests() { return ldrPedestrianRequests; }
    public void setLdrPedestrianRequests(Integer ldrPedestrianRequests) { this.ldrPedestrianRequests = ldrPedestrianRequests; }

    public Integer getTrafficFlowCount() { return trafficFlowCount; }
    public void setTrafficFlowCount(Integer trafficFlowCount) { this.trafficFlowCount = trafficFlowCount; }

    public Date getRecordedTime() { return recordedTime; }
    public void setRecordedTime(Date recordedTime) { this.recordedTime = recordedTime; }
}
