package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TypedQuery;
import model.Violation;

import java.util.ArrayList;
import java.util.List;

public class ViolationDAO {
    
    public List<Violation> getAllViolations() {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        List<Violation> list = new ArrayList<>();
        
        try {
            // Using JPQL to fetch all Violation entities
            TypedQuery<Violation> query = em.createQuery("SELECT v FROM Violation v", Violation.class);
            list = query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        
        return list;
    }
    
    // Proper way to close EMF when application shuts down (optional but recommended)
    public static void closeEntityManagerFactory() {
        // Get the EntityManagerFactory from JpaUtils to close it
        EntityManagerFactory emf = JpaUtils.getEntityManagerFactory();
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}