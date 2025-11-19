package com.meeting.microservices.meeting.service;

import com.meeting.microservices.MeetingDB.Meeting;
import com.meeting.microservices.MeetingDB.MeetingRepository;
import com.meeting.microservices.MeetingDB.Participant;
import com.meeting.microservices.MeetingDB.ParticipantRepository;
import com.meeting.microservices.meeting.dto.MeetingRequest;
import com.meeting.microservices.meeting.dto.MeetingResponse;
import com.meeting.microservices.meeting.dto.ParticipantRequest;
import com.meeting.microservices.meeting.dto.ParticipantResponse;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

@ApplicationScoped
public class MeetingService {

    private static final String RESOURCE_MEETING = "Meeting";
    private static final String RESOURCE_PARTICIPANT = "Participant";
    private static final String DEFAULT_LANGUAGE = "fr";
    private static final String DEFAULT_STATUS = "Planifiée";
    private static final String STATUS_TERMINATED = "Terminée";
    private static final String STATUS_IN_PROGRESS = "En cours";
    private static final String STATUS_POSTPONED = "Reportée";
    private static final String STATUS_CANCELLED = "Annulée";
    private static final String FRONT_STATUS_SCHEDULED = "scheduled";
    private static final String FRONT_STATUS_IN_PROGRESS = "in_progress";
    private static final String FRONT_STATUS_COMPLETED = "completed";
    private static final String FRONT_STATUS_POSTPONED = "postponed";
    private static final String FRONT_STATUS_CANCELLED = "cancelled";

    private final MeetingRepository meetingRepository;
    private final ParticipantRepository participantRepository;

    @Inject
    public MeetingService(MeetingRepository meetingRepository, ParticipantRepository participantRepository) {
        this.meetingRepository = meetingRepository;
        this.participantRepository = participantRepository;
    }


    @Transactional
    public MeetingResponse createMeeting(MeetingRequest request) {
        if (request == null) {
            throw new WebApplicationException("Meeting payload is required", Response.Status.BAD_REQUEST);
        }

        Meeting meeting = new Meeting();
        meeting.setTitle(requireNonBlank(request.title(), "title"));
        meeting.setDescription(request.description());
        meeting.setMeetingDate(request.meetingDate());
        meeting.setMeetingPrevisualDuration(resolvePlannedDuration(request));
        meeting.setMeetingRealDuration(null);
        meeting.setMeetingLanguage(DEFAULT_LANGUAGE);
        meeting.setMeetingStatus(DEFAULT_STATUS);
        meeting.setMeetingParticipants("0");

        meetingRepository.persist(meeting);
        meetingRepository.flush();

        if (request.participants() != null) {
            for (ParticipantRequest participantRequest : request.participants()) {
                Participant participant = resolveParticipant(participantRequest);
                attachParticipant(meeting, participant);
            }
        }

        meetingRepository.flush();
        return toResponse(meeting);
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<MeetingResponse> getAllMeetings() {
        return meetingRepository.listAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public MeetingResponse getMeetingById(Long meetingId) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));
        return toResponse(meeting);
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<ParticipantResponse> getParticipantsByMeeting(Long meetingId) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));
        return meeting.getParticipants().stream()
                .sorted(Comparator.comparing(Participant::getLastname, Comparator.nullsLast(String::compareToIgnoreCase))
                        .thenComparing(Participant::getFirstname, Comparator.nullsLast(String::compareToIgnoreCase)))
                .map(this::toParticipantResponse)
                .toList();
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<ParticipantResponse> getAllParticipants() {
    return participantRepository.listAll().stream()
        .sorted(Comparator.comparing(Participant::getLastname, Comparator.nullsLast(String::compareToIgnoreCase))
            .thenComparing(Participant::getFirstname, Comparator.nullsLast(String::compareToIgnoreCase)))
        .map(this::toParticipantResponse)
        .toList();
    }

    @Transactional
    public ParticipantResponse addParticipant(Long meetingId, ParticipantRequest request) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));

        String currentStatus = meeting.getMeetingStatus();
        if (currentStatus != null && STATUS_TERMINATED.equalsIgnoreCase(currentStatus)) {
            throw new WebApplicationException("Cannot modify participants once the meeting is completed", Response.Status.CONFLICT);
        }

        Participant participant = resolveParticipant(request);
        attachParticipant(meeting, participant);

        meetingRepository.flush();
        return toParticipantResponse(participant);
    }

    @Transactional
    public ParticipantResponse saveParticipant(ParticipantRequest request) {
        Participant participant = resolveParticipant(request);
        return toParticipantResponse(participant);
    }

    @Transactional
    public void removeParticipant(Long meetingId, Long participantId) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));
        Participant participant = Optional.ofNullable(participantRepository.findById(participantId))
                .orElseThrow(() -> notFound(RESOURCE_PARTICIPANT, participantId));

        String currentStatus = meeting.getMeetingStatus();
        if (currentStatus != null && STATUS_TERMINATED.equalsIgnoreCase(currentStatus)) {
            throw new WebApplicationException("Cannot modify participants once the meeting is completed", Response.Status.CONFLICT);
        }

        if (!meeting.getParticipants().contains(participant)) {
            throw new WebApplicationException("Participant not assigned to this meeting", Response.Status.NOT_FOUND);
        }

        meeting.removeParticipant(participant);
        meetingRepository.flush();
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<MeetingResponse> searchByTitle(String title) {
        return meetingRepository.findByTitleContainingIgnoreCase(title)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public MeetingResponse startMeeting(Long meetingId) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));

        String currentStatus = meeting.getMeetingStatus();
        if (currentStatus != null && STATUS_TERMINATED.equalsIgnoreCase(currentStatus)) {
            throw new WebApplicationException("Meeting already completed", Response.Status.CONFLICT);
        }
        if (currentStatus != null && STATUS_CANCELLED.equalsIgnoreCase(currentStatus)) {
            throw new WebApplicationException("Meeting is cancelled", Response.Status.CONFLICT);
        }

        meeting.setMeetingStatus(STATUS_IN_PROGRESS);
        meeting.setMeetingRealDuration(null);
        meetingRepository.flush();

        return toResponse(meeting);
    }

    @Transactional
    public MeetingResponse endMeeting(Long meetingId) {
        Meeting meeting = Optional.ofNullable(meetingRepository.findById(meetingId))
                .orElseThrow(() -> notFound(RESOURCE_MEETING, meetingId));

        String currentStatus = meeting.getMeetingStatus();
        if (currentStatus != null) {
            if (STATUS_CANCELLED.equalsIgnoreCase(currentStatus)) {
                throw new WebApplicationException("Meeting is cancelled", Response.Status.CONFLICT);
            }
            if (STATUS_TERMINATED.equalsIgnoreCase(currentStatus)) {
                return toResponse(meeting);
            }
            if (!STATUS_IN_PROGRESS.equalsIgnoreCase(currentStatus)) {
                throw new WebApplicationException("Meeting has not started", Response.Status.CONFLICT);
            }
        }

        meeting.setMeetingStatus(STATUS_TERMINATED);
        meetingRepository.flush();

        return toResponse(meeting);
    }

    private Participant resolveParticipant(ParticipantRequest request) {
        if (request == null) {
            throw new WebApplicationException("Participant payload is required", Response.Status.BAD_REQUEST);
        }

        if (request.id() != null) {
            Participant participant = Optional.ofNullable(participantRepository.findById(request.id()))
                    .orElseThrow(() -> notFound(RESOURCE_PARTICIPANT, request.id()));
            if (request.email() != null && !request.email().isBlank()) {
                participant.setEmail(request.email());
                participantRepository.flush();
            }
            return participant;
        }

        String firstname = requireNonBlank(request.resolvedFirstname(), "firstname");
        String lastname = requireNonBlank(request.resolvedLastname(), "lastname");

        Participant participant = new Participant();
        participant.setFirstname(firstname);
        participant.setLastname(lastname);
        participant.setEmail(request.email());
        participantRepository.persist(participant);
        participantRepository.flush();
        return participant;
    }

    private void attachParticipant(Meeting meeting, Participant participant) {
        if (participant.getId() != null) {
            boolean alreadyAssigned = meeting.getParticipants().stream()
                    .filter(Objects::nonNull)
                    .anyMatch(existing -> Objects.equals(existing.getId(), participant.getId()));
            if (alreadyAssigned) {
                return;
            }
        }
        meeting.addParticipant(participant);
    }

    private MeetingResponse toResponse(Meeting meeting) {
        List<ParticipantResponse> participantResponses = meeting.getParticipants().stream()
                .sorted(Comparator.comparing(Participant::getLastname, Comparator.nullsLast(String::compareToIgnoreCase))
                        .thenComparing(Participant::getFirstname, Comparator.nullsLast(String::compareToIgnoreCase)))
                .map(this::toParticipantResponse)
                .toList();

        return new MeetingResponse(
                meeting.getId(),
                meeting.getTitle(),
                meeting.getDescription(),
                meeting.getMeetingDate(),
                computeDurationMinutes(meeting.getMeetingPrevisualDuration()),
                mapStatusForResponse(meeting.getMeetingStatus()),
                new ArrayList<>(participantResponses)
        );
    }

    private ParticipantResponse toParticipantResponse(Participant participant) {
        return new ParticipantResponse(
                participant.getId(),
                buildFullName(participant),
                participant.getEmail()
        );
    }

    private WebApplicationException notFound(String resource, Long id) {
        return new WebApplicationException(resource + " not found: " + id, Response.Status.NOT_FOUND);
    }

    private String requireNonBlank(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new WebApplicationException("Field '" + field + "' is required", Response.Status.BAD_REQUEST);
        }
        return value;
    }

    private String resolvePlannedDuration(MeetingRequest request) {
        if (request.previsualDuration() != null && !request.previsualDuration().isBlank()) {
            return request.previsualDuration();
        }
        Integer minutes = request.durationMinutes();
        if (minutes != null && minutes >= 0) {
            return minutes.toString();
        }
        return null;
    }

    private Integer computeDurationMinutes(String rawDuration) {
        if (rawDuration == null || rawDuration.isBlank()) {
            return null;
        }
        String trimmed = rawDuration.trim();
        if (trimmed.contains(":")) {
            String[] parts = trimmed.split(":", 2);
            try {
                int hours = Integer.parseInt(parts[0].trim());
                int minutes = Integer.parseInt(parts[1].trim());
                return Math.max((hours * 60) + minutes, 0);
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        try {
            return Math.max(Integer.parseInt(trimmed), 0);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String mapStatusForResponse(String status) {
        if (status == null || status.isBlank()) {
            return FRONT_STATUS_SCHEDULED;
        }
        return switch (status.trim().toLowerCase(Locale.ROOT)) {
            case "planifiée", "planifiee" -> FRONT_STATUS_SCHEDULED;
            case "en cours", "en_cours" -> FRONT_STATUS_IN_PROGRESS;
            case "terminée", "terminee" -> FRONT_STATUS_COMPLETED;
            case "reportée", "reportee" -> FRONT_STATUS_POSTPONED;
            case "annulée", "annulee" -> FRONT_STATUS_CANCELLED;
            default -> status.trim().toLowerCase(Locale.ROOT).replace(' ', '_');
        };
    }

    private String buildFullName(Participant participant) {
        String firstname = participant.getFirstname();
        String lastname = participant.getLastname();
        if ((firstname == null || firstname.isBlank()) && (lastname == null || lastname.isBlank())) {
            return null;
        }
        if (firstname == null || firstname.isBlank()) {
            return lastname;
        }
        if (lastname == null || lastname.isBlank()) {
            return firstname;
        }
        return firstname + " " + lastname;
    }
}
