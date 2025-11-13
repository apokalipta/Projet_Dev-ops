package com.meeting.microservices.TranscriptionDB;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.util.List;

@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TranscriptionResource {

    @Inject
    TranscriptionRepository transcriptionRepo;

    @Inject
    SegmentRepository segmentRepo;

    @Inject
    LocuteurRepository locuteurRepo;

    // ==========================================================
    //  POST /api/transcribe
    // ==========================================================
    @POST
    @Path("/transcribe")
    @Transactional
    public Response createTranscription(Transcription transcription) {
        transcriptionRepo.save(transcription);
        return Response.status(Response.Status.CREATED).entity(transcription).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/all
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/all")
    public Response listSegmentsByReunion(@PathParam("id_reunion") Long idReunion) {
        List<Segment> segments = segmentRepo.listByReunion(idReunion);
        return Response.ok(segments).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/{id_segment}")
    public Response getSegment(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment) {

        Segment segment = segmentRepo.findById(idSegment);
        if (segment == null || !segment.getTranscription().getIdReunion().equals(idReunion)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(segment).build();
    }

    // ==========================================================
    //  PUT /api/transcription/{id_reunion}/segment/{id_segment}
    // ==========================================================
    @PUT
    @Path("/transcription/{id_reunion}/segment/{id_segment}")
    @Transactional
    public Response updateSegmentText(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment,
            Segment updatedSegment) {

        Segment segment = segmentRepo.findById(idSegment);
        if (segment == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        segment.setTexte(updatedSegment.getTexte());
        segmentRepo.update(segment);
        return Response.status(Response.Status.ACCEPTED).entity(segment).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/locuteur/all
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/{id_segment}/locuteur/all")
    public Response listLocuteursBySegment(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment) {

        Segment segment = segmentRepo.findById(idSegment);
        if (segment == null || !segment.getTranscription().getIdReunion().equals(idReunion)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(segment.getLocuteur()).build();
    }

    // ==========================================================
    //  PUT /api/transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant}
    // ==========================================================
    @PUT
    @Path("/transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant}")
    @Transactional
    public Response updateSegmentLocuteur(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment,
            @PathParam("id_participant") Long idParticipant) {

        Segment segment = segmentRepo.findById(idSegment);
        if (segment == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        Locuteur locuteur = locuteurRepo.findById(idParticipant);
        if (locuteur == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Locuteur non trouvé").build();
        }

        segment.setLocuteur(locuteur);
        segmentRepo.update(segment);
        return Response.status(Response.Status.ACCEPTED).entity(segment).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/record_file
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/record_file")
    public Response getRecordFile(@PathParam("id_reunion") Long idReunion) {
        Transcription t = transcriptionRepo.findByReunionId(idReunion);
        if (t == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(t.getRecordFileName()).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/time_depart
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/{id_segment}/time_depart")
    public Response getSegmentStartTime(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment) {

        Segment s = segmentRepo.findById(idSegment);
        if (s == null) return Response.status(Response.Status.NOT_FOUND).build();

        return Response.ok(s.getTimeDepart()).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/time_fin
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/{id_segment}/time_fin")
    public Response getSegmentEndTime(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment) {

        Segment s = segmentRepo.findById(idSegment);
        if (s == null) return Response.status(Response.Status.NOT_FOUND).build();

        Double endTime = (s.getTimeDepart() != null && s.getDuree() != null)
                ? s.getTimeDepart() + s.getDuree()
                : null;

        return Response.ok(endTime).build();
    }
}
