package com.meeting.microservices.MeetingDB;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;
import java.util.Locale;

@ApplicationScoped
public class MeetingRepository implements PanacheRepositoryBase<Meeting, Long> {

    public List<Meeting> findByTitleContainingIgnoreCase(String title) {
        if (title == null || title.isBlank()) {
            return listAll();
        }
        String pattern = "%" + title.toLowerCase(Locale.ROOT) + "%";
        return list("LOWER(meetingtitle) LIKE ?1", pattern);
    }
}
