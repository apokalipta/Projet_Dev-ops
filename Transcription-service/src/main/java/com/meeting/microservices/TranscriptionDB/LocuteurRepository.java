package com.meeting.microservices.TranscriptionDB;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@ApplicationScoped
public class LocuteurRepository {
    
    @PersistenceContext
    EntityManager em;

    public List<Locuteur> listByReunion(Long idReunion) {
        return em.createQuery("""
                SELECT s FROM Locuteur s
                WHERE s.transcription.idReunion = :id
                """, Locuteur.class)
                .setParameter("id", idReunion)
                .getResultList();
    }

    public Locuteur findById(Long idLocuteur) {
        return em.find(Locuteur.class, idLocuteur);
    }

    public Locuteur findByName(String NameLocuteur) {
        return em.find(Locuteur.class, NameLocuteur);
    } 

    public void save(Locuteur s) {
        em.persist(s);
    }

    public void update(Locuteur s) {
        em.merge(s);
    }
}
