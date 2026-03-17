package model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "Violations")
public class Violation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ViolationID")
    private int violationId;

    @Column(name = "ImageURL", nullable = false, columnDefinition = "TEXT")
    private String imageUrl;

    @Column(name = "ViolationTime")
    @Temporal(TemporalType.TIMESTAMP)
    private Date violationTime;

    @Column(name = "LicensePlate", length = 20)
    private String licensePlate;

    @Column(name = "VehicleType", length = 50)
    private String vehicleType;

    @Column(name = "SeverityLevel", nullable = false, length = 50)
    private String severityLevel;

    @Column(name = "Confident")
    private Double confident;

    public Violation() {}

    // Getters and Setters
    public int getViolationId() { return violationId; }
    public void setViolationId(int violationId) { this.violationId = violationId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Date getViolationTime() { return violationTime; }
    public void setViolationTime(Date violationTime) { this.violationTime = violationTime; }

    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getSeverityLevel() { return severityLevel; }
    public void setSeverityLevel(String severityLevel) { this.severityLevel = severityLevel; }

    public Double getConfident() { return confident; }
    public void setConfident(Double confident) { this.confident = confident; }
}