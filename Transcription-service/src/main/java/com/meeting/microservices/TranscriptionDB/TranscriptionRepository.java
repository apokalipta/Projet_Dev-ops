package com.meeting.microservices.TranscriptionDB;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@ApplicationScoped
public class TranscriptionRepository {

    @PersistenceContext
    EntityManager em;

    public void save(Transcription transcription) {
        em.persist(transcription);
    }

    public Transcription findByReunionId(Long idReunion) {
        String query = "FROM Transcription t WHERE t.idReunion = :id";
        List<Transcription> results = em.createQuery(query, Transcription.class)
                .setParameter("id", idReunion)
                .getResultList();
        return results.isEmpty() ? null : results.get(0);
    }
}
