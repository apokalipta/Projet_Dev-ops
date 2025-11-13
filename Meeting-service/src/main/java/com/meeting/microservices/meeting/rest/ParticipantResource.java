package com.meeting.microservices.meeting.rest;

import com.meeting.microservices.meeting.dto.ParticipantResponse;
import com.meeting.microservices.meeting.service.MeetingService;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.util.List;

@Path("/api/participant")
@Produces(MediaType.APPLICATION_JSON)
public class ParticipantResource {

    private final MeetingService meetingService;

    @Inject
    public ParticipantResource(MeetingService meetingService) {
        this.meetingService = meetingService;
    }

    @GET
    @Path("/all")
    @Transactional(Transactional.TxType.SUPPORTS)
    public List<ParticipantResponse> getAllParticipants() {
        return meetingService.getAllParticipants();
    }
}
