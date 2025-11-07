package com.meeting.microservices.MeetingDB;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;

@ApplicationScoped
public class MeetingRepository {

    @Inject
    EntityManager em;

    public List<Meeting> listAll() {
        return em.createQuery("SELECT m FROM Meeting m", Meeting.class).getResultList();
    }

    public void persist(Meeting meeting) {
        em.persist(meeting);
    }

    public Meeting findById(Long id) {
        return em.find(Meeting.class, id);
    }

    public void deleteById(Long id) {
        Meeting m = findById(id);
        if (m != null) {
            em.remove(m);
        }
    }
}
