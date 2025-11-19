package com.meeting.microservices.TranscriptionDB;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@ApplicationScoped
public class SegmentRepository {

    @PersistenceContext
    EntityManager em;

    public List<Segment> listByReunion(Long idReunion) {
        return em.createQuery("""
                SELECT s FROM Segment s
                WHERE s.transcription.idReunion = :id
                """, Segment.class)
                .setParameter("id", idReunion)
                .getResultList();
    }

    public Segment findById(Long idSegment) {
        return em.find(Segment.class, idSegment);
    }

    public void save(Segment s) {
        em.persist(s);
    }

    public void update(Segment s) {
        em.merge(s);
    }
}
