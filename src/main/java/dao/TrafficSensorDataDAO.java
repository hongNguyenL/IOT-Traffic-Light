package dao;

import jakarta.persistence.EntityManager;
import model.TrafficSensorData;
import java.util.Date;

public class TrafficSensorDataDAO {
    public void saveData(Integer pedestrianRequests, Integer trafficCount) {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        try {
            em.getTransaction().begin();
            TrafficSensorData data = new TrafficSensorData();
            data.setLdrPedestrianRequests(pedestrianRequests);
            data.setTrafficFlowCount(trafficCount);
            data.setRecordedTime(new Date());
            em.persist(data);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
