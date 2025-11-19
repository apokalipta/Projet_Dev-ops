package com.meeting.microservices.meeting.rest;

import com.meeting.microservices.meeting.dto.ParticipantRequest;
import com.meeting.microservices.meeting.dto.ParticipantResponse;
import com.meeting.microservices.meeting.service.MeetingService;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.net.URI;
import java.util.List;

@Path("/api/participant")
@Consumes(MediaType.APPLICATION_JSON)
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

    @POST
    @Transactional
    public Response createOrUpdateParticipant(@Valid ParticipantRequest request) {
        ParticipantResponse participant = meetingService.saveParticipant(request);
        boolean isUpdate = request != null && request.id() != null;
        if (isUpdate) {
            return Response.ok(participant).build();
        }
        URI location = URI.create("/api/participant/" + participant.id());
        return Response.created(location).entity(participant).build();
    }
}
