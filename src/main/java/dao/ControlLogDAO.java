package dao;

import jakarta.persistence.EntityManager;
import model.ControlLog;
import java.util.Date;

public class ControlLogDAO {
    public void logCommand(String deviceId, String command) {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        try {
            em.getTransaction().begin();
            ControlLog log = new ControlLog();
            log.setDeviceId(deviceId);
            log.setCommandSent(command);
            log.setExecutionTime(new Date());
            em.persist(log);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
