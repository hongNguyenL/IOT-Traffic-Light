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
    
    // Returns the imageUrl of the deleted violation, or null if not found / failed
    public String deleteViolation(int id) {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        String imageUrl = null;
        try {
            em.getTransaction().begin();
            Violation v = em.find(Violation.class, id);
            if (v != null) {
                imageUrl = v.getImageUrl(); // Grab the URL before removing
                em.remove(v);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        return imageUrl;
    }

    // Deletes all violations and returns their image URLs for cloud cleanup
    public List<String> deleteAllViolations() {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        List<String> imageUrls = new ArrayList<>();
        try {
            em.getTransaction().begin();
            List<Violation> allViolations = em.createQuery("SELECT v FROM Violation v", Violation.class).getResultList();
            for (Violation v : allViolations) {
                if (v.getImageUrl() != null) {
                    imageUrls.add(v.getImageUrl());
                }
                em.remove(v);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
        return imageUrls;
    }

    
    // Proper way to close EMF when application shuts down (optional but recommended)
    public static void closeEntityManagerFactory() {
        // Get the EntityManagerFactory from JpaUtils to close it
        EntityManagerFactory emf = JpaUtils.getEntityManagerFactory();
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
    
    public boolean save(Violation violation) {
        EntityManager em = JpaUtils.getEntityManagerFactory().createEntityManager();
        try {
            em.getTransaction().begin(); // Bắt đầu giao dịch
            em.persist(violation);       // Đưa đối tượng vào trạng thái lưu trữ
            em.getTransaction().commit(); // Xác nhận lưu vào DB
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback(); // Hoàn tác nếu có lỗi xảy ra
            }
            e.printStackTrace();
            return false;
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }
}