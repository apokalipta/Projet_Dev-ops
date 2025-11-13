package com.meeting.microservices.MeetingDB;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ParticipantRepository implements PanacheRepositoryBase<Participant, Long> {
}
