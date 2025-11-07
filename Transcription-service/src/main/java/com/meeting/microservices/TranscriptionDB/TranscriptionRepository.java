package com.meeting.microservices.TranscriptionDB;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;

@ApplicationScoped
public class TranscriptionRepository {

    @Inject
    EntityManager em;

    public List<Transcription> listAll() {
        return em.createQuery("SELECT t FROM Transcription t", Transcription.class).getResultList();
    }

    public void persist(Transcription t) {
        em.persist(t);
    }

    public Transcription findById(Long id) {
        return em.find(Transcription.class, id);
    }
}
