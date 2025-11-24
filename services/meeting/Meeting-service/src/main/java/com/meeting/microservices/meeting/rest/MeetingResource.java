package com.meeting.microservices.meeting.rest;

import com.meeting.microservices.meeting.dto.MeetingRequest;
import com.meeting.microservices.meeting.dto.MeetingResponse;
import com.meeting.microservices.meeting.dto.ParticipantRequest;
import com.meeting.microservices.meeting.dto.ParticipantResponse;
import com.meeting.microservices.meeting.service.MeetingService;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.net.URI;
import java.util.List;

@Path("/api/meeting")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class MeetingResource {

    private final MeetingService meetingService;

    @Inject
    public MeetingResource(MeetingService meetingService) {
        this.meetingService = meetingService;
    }

    @POST
    @Transactional
    public Response createMeeting(@Valid MeetingRequest request) {
        MeetingResponse created = meetingService.createMeeting(request);
        URI location = URI.create("/api/meeting/" + created.id());
        return Response.created(location).entity(created).build();
    }

    @GET
    @Path("/all")
    public List<MeetingResponse> getAllMeetings() {
        return meetingService.getAllMeetings();
    }

    @GET
    @Path("/search/byTitle")
    public List<MeetingResponse> searchByTitle(@QueryParam("title") String title) {
        return meetingService.searchByTitle(title);
    }

    @GET
    @Path("/{meetingId}")
    public MeetingResponse getMeetingById(@PathParam("meetingId") Long meetingId) {
        return meetingService.getMeetingById(meetingId);
    }

    @DELETE
    @Path("/{meetingId}")
    @Transactional
    public Response deleteMeeting(@PathParam("meetingId") Long meetingId) {
        meetingService.deleteMeeting(meetingId);
        return Response.noContent().build();
    }

    @GET
    @Path("/{meetingId}/participant/all")
    public List<ParticipantResponse> getParticipants(@PathParam("meetingId") Long meetingId) {
        return meetingService.getParticipantsByMeeting(meetingId);
    }

    @POST
    @Path("/{meetingId}/participant")
    @Transactional
    public Response addParticipant(@PathParam("meetingId") Long meetingId,
                                   @Valid ParticipantRequest request) {
        ParticipantResponse participant = meetingService.addParticipant(meetingId, request);
        URI location = URI.create("/api/meeting/" + meetingId + "/participant/" + participant.id());
        return Response.created(location).entity(participant).build();
    }

    @DELETE
    @Path("/{meetingId}/participant/{participantId}")
    @Transactional
    public Response removeParticipant(@PathParam("meetingId") Long meetingId,
                                      @PathParam("participantId") Long participantId) {
        meetingService.removeParticipant(meetingId, participantId);
        return Response.noContent().build();
    }

    @PUT
    @Path("/{meetingId}/start")
    @Transactional
    public MeetingResponse startMeeting(@PathParam("meetingId") Long meetingId) {
        return meetingService.startMeeting(meetingId);
    }

    @PUT
    @Path("/{meetingId}/end")
    @Transactional
    public MeetingResponse endMeeting(@PathParam("meetingId") Long meetingId) {
        return meetingService.endMeeting(meetingId);
    }
}
