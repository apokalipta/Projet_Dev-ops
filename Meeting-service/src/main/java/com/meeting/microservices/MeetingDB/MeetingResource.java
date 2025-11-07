package com.meeting.microservices.MeetingDB;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/api/meeting")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class MeetingResource {

    @Inject
    MeetingRepository meetingRepo;

    @GET
    public List<Meeting> getAll() {
        return meetingRepo.listAll();
    }

    @POST
    @Transactional
    public Response create(Meeting meeting) {
        meetingRepo.persist(meeting);
        return Response.status(Response.Status.CREATED).entity(meeting).build();
    }

    @GET
    @Path("/{id}")
    public Meeting getById(@PathParam("id") Long id) {
        Meeting meeting = meetingRepo.findById(id);
        if (meeting == null) {
            throw new NotFoundException("Meeting not found");
        }
        return meeting;
    }

    @DELETE
    @Path("/{id}")
    @Transactional
    public Response delete(@PathParam("id") Long id) {
        meetingRepo.deleteById(id);
        return Response.noContent().build();
    }
}
