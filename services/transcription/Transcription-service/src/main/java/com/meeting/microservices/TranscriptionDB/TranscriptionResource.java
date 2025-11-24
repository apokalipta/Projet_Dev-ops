package com.meeting.microservices.TranscriptionDB;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import com.meeting.microservices.TranscriptionDB.SegmentDTO;

import com.meeting.microservices.TranscriptionDB.LocuteurRepository;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;
import java.nio.file.Files;
import org.apache.http.util.EntityUtils;



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

//MODIF PAR MAX A CONFIRMER
   // ==========================================================
    //  POST /api/start_transcription ✅
    // ==========================================================
    @POST
    @Path("/start_transcription/{id_reunion}") //Creation de la transcription lors du démarrage réunion
    @Transactional
    public Response createTranscription(Transcription transcription, @PathParam("id_reunion") Long idReunion) {
        transcription.setIdReunion(idReunion);
        transcriptionRepo.save(transcription);
        return Response.status(Response.Status.CREATED).entity(transcription).build(); // Renvoie la transcription créée avec son ID pour récupération côté Front et renvoie pour chaque demande de transcription
    }
            

    //ADD PAR MAX
    // ==========================================================
    //  POST /api/transcription/{id_transcription}/send_segment ✅
    // ==========================================================

    @POST
    @Path("/transcription/{id_reunion}/send_segment") //Envoi d'un segment audio pour transcription
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Transactional
    public Response Transcription(@PathParam("id_reunion") Long idReunion, @RestForm FileUpload file) {
                // Vérifier que le fichier est présent
                String filename = file.fileName();
                System.out.println("📁 Fichier reçu :"+filename);
                if (file == null || file.uploadedFile() == null) {
                    return Response.status(Response.Status.BAD_REQUEST)
                            .entity("Aucun fichier fourni").build();
                }
                
                // Récupérer le fichier audio depuis FileUpload
                byte[] audioBytes;
                try {
                    audioBytes = Files.readAllBytes(file.uploadedFile());
                } catch (IOException e) {
                    throw new RuntimeException("Erreur lors de la lecture du fichier audio", e);
                }

                //Envoyer le fichier à l'IA pour transcription
                String aiServiceUrl = System.getenv("AI_SERVICE_URL");
                if (aiServiceUrl == null || aiServiceUrl.isEmpty()) {
                    aiServiceUrl = "http://ai-service:8000";
                }
                String fastApiUrl = aiServiceUrl + "/transcribe/?ID_reunion=" + idReunion;
                System.out.println("Contenu requête vers IA : "+fastApiUrl);

                try (CloseableHttpClient client = HttpClients.createDefault()) {
                    
                    HttpPost post = new HttpPost(fastApiUrl);
                    MultipartEntityBuilder builder = MultipartEntityBuilder.create();
                    builder.addBinaryBody(
                        "file",
                        audioBytes,
                        ContentType.DEFAULT_BINARY,
                        filename  // nom fictif pour FastAPI
                    );

                    post.setEntity(builder.build());
                    
                    System.out.println("👉 Envoi requête vers l'IA…");

                    // ---- Exécuter la requête ----
                    try (CloseableHttpResponse response = client.execute(post)) {

                        int statusCode = response.getStatusLine().getStatusCode();
                        System.out.println("📡 Code retour FastAPI : " + statusCode);

                        String responseBody = "";
                        if (response.getEntity() != null) {
                            responseBody = EntityUtils.toString(response.getEntity());
                        }

                        System.out.println("📩 Réponse IA : " + responseBody);

                        if (statusCode != 200 && statusCode != 202) {
                            System.err.println("⚠️ Erreur lors de l’envoi au service IA");
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }   
                return Response.status(Response.Status.ACCEPTED).entity("Segment envoyé pour transcription").build();
    }

    //ADD PAR MAX
    // ==========================================================
    //  POST /api/transcription/{id_transcription}/segment_to_bdd ✅
    // ==========================================================
    @POST
    @Path("/transcription/{id_reunion}/segment_to_bdd") //Envoi d'un segment audio pour transcription
    @Transactional
    public Response segmentToBdd(
            @PathParam("id_reunion") Long ID_reunion, InputStream requestBody) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(requestBody); // parse le JSON depuis le content

            // Si c'est un seul segment
            if (root.isObject()) {
                Segment segment = parseSegment(root, ID_reunion);
                segmentRepo.save(segment);
            }
            // Si c'est un tableau de segments
            else if (root.isArray()) {
                for (JsonNode node : root) {
                    Segment segment = parseSegment(node, ID_reunion);
                    segmentRepo.save(segment);
                }
            } else {
                return Response.status(Response.Status.BAD_REQUEST)
                               .entity("JSON invalide pour un segment").build();
            }

            return Response.status(Response.Status.ACCEPTED)
                           .entity("Segment(s) sauvegardé(s) en base").build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.BAD_REQUEST)
                           .entity("Erreur lors du parsing du segment: " + e.getMessage())
                           .build();
        }
    }

    // Méthode utilitaire pour créer un Segment depuis un JsonNode
    private Segment parseSegment(JsonNode node, Long idReunion) {
        Segment segment = new Segment();

        String speakerID = node.has("speaker") ? node.get("speaker").asText() : "SPEAKER_XX";
        double timeDepart = node.has("start") ? node.get("start").asDouble() : 0.0;
        double timeEnd = node.has("end") ? node.get("end").asDouble() : 0.0;
        String texte = node.has("text") ? node.get("text").asText().strip() : "";

        // Récupérer ou créer le locuteur
        String locuteurName = speakerID.replace("SPEAKER_", "");
        
        Locuteur locuteur = locuteurRepo.findByName(locuteurName);
        if (locuteur == null) {
            // Créer un nouveau locuteur s'il n'existe pas
            locuteur = new Locuteur();
            locuteur.setName(locuteurName);
            locuteurRepo.save(locuteur);
        }
        
        segment.setTranscription(transcriptionRepo.findByReunionId(idReunion));     
        segment.setLocuteur(locuteur);
        segment.setTimeDepart(timeDepart);
        segment.setTimeEnd(timeEnd);
        segment.setTexte(texte);

        segmentRepo.save(segment);

        return segment;
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/all ✅
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/all")
    public Response listSegmentsByReunion(@PathParam("id_reunion") Long idReunion) {
        List<Segment> segments = segmentRepo.listByReunion(idReunion);
        System.out.println("Nb segments = " + segments.size());
        List<SegmentDTO> dtoList = segments.stream()
                                       .map(SegmentDTO::new)
                                       .collect(Collectors.toList());
        return Response.ok(dtoList).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment} ✅
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

        // Construire le DTO
        SegmentDTO dto = new SegmentDTO(segment);

        return Response.ok(dto).build();
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
        // Retourner un DTO pour éviter de renvoyer l'audio binaire
        SegmentDTO dto = new SegmentDTO(segment);

        return Response.ok(dto).build();
    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/locuteur/all ✅
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
        return Response.ok(segment.getLocuteurName()).build();
    }

    // ==========================================================
    //  PUT /api/transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant} ✅
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
            return Response.status(Response.Status.NOT_FOUND).entity("Segment introuvable").build();
        }

        Locuteur locuteur = locuteurRepo.findById(idParticipant);
        if (locuteur == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Locuteur non trouvé").build();
        }

        segment.setLocuteur(locuteur);
        segmentRepo.update(segment);
        // Retourner un DTO pour éviter de renvoyer l'audio binaire
        SegmentDTO dto = new SegmentDTO(segment);

        return Response.ok(dto).build();    }

    // ==========================================================
    //  GET /api/transcription/{id_reunion}/obtain_record_file ✅
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/obtain_record_file")
    public Response getRecordFile(@PathParam("id_reunion") Long idReunion) {
        Transcription t = transcriptionRepo.findByReunionId(idReunion);
        if (t == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(t.getRecordFileName()).build();
    }

    //ADD PAR MAX
     // ==========================================================
    //  POST /api/transcription/{id_reunion}/save_record_file ✅
    // ==========================================================
    @POST
    @Path("/transcription/{id_reunion}/save_record_file")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Transactional
    public Response saveRecordFile(
            @PathParam("id_reunion") Long idReunion, @RestForm FileUpload file) {
                
                // Vérifier que le fichier est présent
                if (file == null || file.uploadedFile() == null) {
                    return Response.status(Response.Status.BAD_REQUEST)
                            .entity("Aucun fichier fourni").build();
                }
                
                // Récupérer le fichier audio depuis FileUpload
                byte[] audioBytes;
                try {
                    audioBytes = Files.readAllBytes(file.uploadedFile());
                } catch (IOException e) {
                    throw new RuntimeException("Erreur lors de la lecture du fichier audio", e);
                }

                //On filtre les transcriptions selon l'id_reunion
                Transcription t = transcriptionRepo.findByReunionId(idReunion);
                if (t == null) {
                    return Response.status(Response.Status.NOT_FOUND).build();
                }

                // Sauvegarder le nom du fichier dans la base de données
                String fileName = "recording_reunion_" + idReunion + ".mp3"; // Exemple de nom de fichier
                t.setRecordFileName(fileName);
                t.setRecordFileData(audioBytes);
                transcriptionRepo.update(t);

                // Ici, vous pouvez également sauvegarder le fichier audio sur le serveur si nécessaire

                // Créer une réponse JSON simple avec ObjectMapper
                ObjectMapper mapper = new ObjectMapper();
                com.fasterxml.jackson.databind.node.ObjectNode jsonResponse = mapper.createObjectNode();
                jsonResponse.put("message", "Fichier enregistré avec succès");
                jsonResponse.put("fileName", fileName);
                jsonResponse.put("meetingId", idReunion);
                
                return Response.status(Response.Status.ACCEPTED).entity(jsonResponse).build();
    }
 
    // ==========================================================
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/time_depart ✅
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
    //  GET /api/transcription/{id_reunion}/segment/{id_segment}/time_fin ✅
    // ==========================================================
    @GET
    @Path("/transcription/{id_reunion}/segment/{id_segment}/time_fin")
    public Response getSegmentEndTime(
            @PathParam("id_reunion") Long idReunion,
            @PathParam("id_segment") Long idSegment) {

        Segment s = segmentRepo.findById(idSegment);
        if (s == null) return Response.status(Response.Status.NOT_FOUND).build();

        Double endTime = s.getTimeEnd();
        return Response.ok(endTime).build();
    }
}
