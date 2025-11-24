package com.meeting.microservices.cli;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Scanner;
import java.util.StringJoiner;

/**
 * Petit client CLI pour interagir avec les endpoints REST du Meeting-service.
 */
@SuppressWarnings("java:S106")
public final class MeetingCliApp {

    private static final String BASE_URL = "http://localhost:8080/api/meeting";
    private static final String PARTICIPANT_URL = "http://localhost:8080/api/participant";
    private static final String HEADER_ACCEPT = "Accept";
    private static final String HEADER_CONTENT_TYPE = "Content-Type";
    private static final String MIME_JSON = "application/json";
    private static final String PROMPT_MEETING_ID = "ID de la réunion : ";
    private static final String PROMPT_PARTICIPANT_ID = "ID du participant : ";
    private static final String PROMPT_FIRSTNAME = "Prénom : ";
    private static final String PROMPT_LASTNAME = "Nom : ";
    private static final String PROMPT_EMAIL = "Email (optionnel) : ";
    private static final String STATUS_SCHEDULED = "scheduled";

    private static final HttpClient CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();

    private MeetingCliApp() {
        // Utility class
    }

    public static void main(String[] args) {
        try (Scanner scanner = new Scanner(System.in, StandardCharsets.UTF_8)) {
            boolean running = true;
            while (running) {
                printMenu();
                System.out.print("Votre choix : ");
                String choice = scanner.nextLine().trim();
                switch (choice) {
                    case "1" -> createMeeting(scanner);
                    case "2" -> listMeetings();
                    case "3" -> getMeetingById(scanner);
                    case "4" -> listParticipants(scanner);
                    case "5" -> addParticipant(scanner);
                    case "6" -> removeParticipant(scanner);
                    case "7" -> searchByTitle(scanner);
                    case "8" -> startMeeting(scanner);
                    case "9" -> endMeeting(scanner);
                    case "10" -> listRegisteredParticipants();
                    case "11" -> registerParticipantInDirectory(scanner);
                    case "0" -> running = false;
                    default -> System.out.println("Option inconnue, merci de réessayer.\n");
                }
            }
        }
    }

    private static void printMenu() {
        System.out.println("\n=== Menu Meeting Service ===");
        System.out.println("1. Créer une réunion");
        System.out.println("2. Lister toutes les réunions");
        System.out.println("3. Consulter une réunion par ID");
        System.out.println("4. Lister les participants d'une réunion");
        System.out.println("5. Ajouter un participant à une réunion");
        System.out.println("6. Retirer un participant d'une réunion");
        System.out.println("7. Rechercher des réunions par titre");
        System.out.println("8. Démarrer une réunion");
        System.out.println("9. Terminer une réunion");
        System.out.println("10. Lister les participants enregistrés");
        System.out.println("11. Enregistrer un participant sans réunion");
        System.out.println("0. Quitter");
    }

    private static void createMeeting(Scanner scanner) {
        System.out.println("\nCréation d'une réunion");
        System.out.print("Titre : ");
        String title = scanner.nextLine();
        System.out.print("Description : ");
        String description = scanner.nextLine();
        System.out.print("Date et heure (ex: 2025-11-07T10:00:00Z) : ");
        String scheduledAt = scanner.nextLine().trim();
        System.out.print("Durée prévue (minutes ou hh:mm) : ");
        Integer durationMinutes = parseDurationInput(scanner.nextLine());

        List<String> participantsJson = new ArrayList<>();
        while (true) {
            System.out.print("Ajouter un participant ? (o/n) : ");
            String answer = scanner.nextLine().trim().toLowerCase(Locale.ROOT);
            if (!"o".equals(answer)) {
                break;
            }
            String participantPayload = chooseParticipantPayload(scanner);
            if (participantPayload == null) {
                System.out.println("Participant non ajouté.");
            } else if (participantsJson.contains(participantPayload)) {
                System.out.println("Participant déjà présent dans la liste.");
            } else {
                participantsJson.add(participantPayload);
            }
        }

        String participantsArray = participantsJson.isEmpty()
                ? "[]"
                : "[" + String.join(",", participantsJson) + "]";

        List<String> fields = new ArrayList<>();
        fields.add("\"title\":\"" + escapeJson(title) + "\"");
        fields.add("\"description\":\"" + escapeJson(description) + "\"");
        fields.add("\"scheduledAt\":\"" + escapeJson(scheduledAt) + "\"");
        if (durationMinutes != null) {
            fields.add("\"durationMinutes\":" + durationMinutes);
        }
        fields.add(buildStatusField(STATUS_SCHEDULED));
        fields.add("\"participants\":" + participantsArray);

        String payload = "{" + String.join(",", fields) + "}";

        sendPost("", payload);
    }

    private static void listMeetings() {
        sendGet("/all");
    }

    private static void getMeetingById(Scanner scanner) {
        Long id = readLong(scanner, PROMPT_MEETING_ID);
        if (id != null) {
            sendGet("/" + id);
        }
    }

    private static void listParticipants(Scanner scanner) {
        Long id = readLong(scanner, PROMPT_MEETING_ID);
        if (id != null) {
            sendGet("/" + id + "/participant/all");
        }
    }

    private static void addParticipant(Scanner scanner) {
        Long meetingId = readLong(scanner, PROMPT_MEETING_ID);
        if (meetingId == null) {
            return;
        }
        String payload = chooseParticipantPayload(scanner);
        if (payload == null) {
            System.out.println("Participant non ajouté.");
            return;
        }

        sendPost("/" + meetingId + "/participant", payload);
    }

    private static void removeParticipant(Scanner scanner) {
        Long meetingId = readLong(scanner, PROMPT_MEETING_ID);
        if (meetingId == null) {
            return;
        }
        Long participantId = readLong(scanner, PROMPT_PARTICIPANT_ID);
        if (participantId != null) {
            sendDelete("/" + meetingId + "/participant/" + participantId);
        }
    }

    private static void startMeeting(Scanner scanner) {
        Long meetingId = readLong(scanner, PROMPT_MEETING_ID);
        if (meetingId != null) {
            sendPut("/" + meetingId + "/start", "{}");
        }
    }

    private static void endMeeting(Scanner scanner) {
        Long meetingId = readLong(scanner, PROMPT_MEETING_ID);
        if (meetingId != null) {
            sendPut("/" + meetingId + "/end", "{}");
        }
    }

    private static void searchByTitle(Scanner scanner) {
        System.out.print("Mot clé du titre : ");
        String keyword = scanner.nextLine();
        String path = "/search/byTitle?title=" + urlEncode(keyword);
        sendGet(path);
    }

    private static void listRegisteredParticipants() {
        List<ParticipantSummary> participants = fetchKnownParticipants();
        if (participants.isEmpty()) {
            System.out.println("\nAucun participant enregistré pour le moment.");
            return;
        }
        printParticipantDirectory(participants);
    }

    private static void registerParticipantInDirectory(Scanner scanner) {
        System.out.print("ID du participant à mettre à jour (laisser vide pour créer) : ");
        String idInput = scanner.nextLine().trim();
        if (idInput.isEmpty()) {
            String payload = promptParticipantPayload(scanner, "Prénom et nom vides, participant ignoré.");
            if (payload == null) {
                System.out.println("Participant non enregistré.");
                return;
            }
            sendParticipantPost("", payload);
            return;
        }

        Long participantId;
        try {
            participantId = Long.parseLong(idInput);
        } catch (NumberFormatException e) {
            System.out.println("Identifiant invalide, opération annulée.");
            return;
        }

        System.out.print("Nouvel email (laisser vide pour annuler) : ");
        String email = scanner.nextLine().trim();
        if (email.isEmpty()) {
            System.out.println("Email vide, mise à jour annulée.");
            return;
        }

        String payload = "{\"id\":" + participantId + ",\"email\":\"" + escapeJson(email) + "\"}";
        sendParticipantPost("", payload);
    }

    private static String chooseParticipantPayload(Scanner scanner) {
        List<ParticipantSummary> participants = fetchKnownParticipants();
        if (participants.isEmpty()) {
            System.out.println("Aucun participant enregistré. Création d'un nouveau participant.");
            return promptParticipantPayload(scanner, "Prénom et nom vides, participant ignoré.");
        }

        while (true) {
            printParticipantDirectory(participants);
            System.out.print("Sélectionnez un ID existant, 'n' pour créer un nouveau participant, ou Entrée pour annuler : ");
            String input = scanner.nextLine().trim();
            if (input.isEmpty()) {
                return null;
            }
            if ("n".equalsIgnoreCase(input)) {
                return promptParticipantPayload(scanner, "Prénom et nom vides, participant ignoré.");
            }
            try {
                Long participantId = Long.parseLong(input);
                for (ParticipantSummary participant : participants) {
                    if (participant.id() != null && participant.id().equals(participantId)) {
                        return "{\"id\":" + participantId + "}";
                    }
                }
                System.out.println("ID inconnu : " + input);
            } catch (NumberFormatException e) {
                System.out.println("Merci de saisir un identifiant numérique, 'n' ou laisser vide pour annuler.");
            }
        }
    }

    private static List<ParticipantSummary> fetchKnownParticipants() {
        Map<Long, ParticipantAccumulator> unique = new LinkedHashMap<>();

        String meetingsPayload = requestJson(BASE_URL + "/all", "la récupération des réunions");
        if (meetingsPayload != null) {
            mergeParticipantsFromMeetings(meetingsPayload, unique);
        }

        String directoryPayload = requestJson(PARTICIPANT_URL + "/all", "la récupération des participants");
        if (directoryPayload != null) {
            mergeParticipantsDirectory(directoryPayload, unique);
        }

        if (unique.isEmpty()) {
            return List.of();
        }

        return unique.values().stream()
                .map(ParticipantAccumulator::toSummary)
                .sorted(Comparator
                        .comparing(ParticipantSummary::fullName, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(ParticipantSummary::email, Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER))
                        .thenComparing(ParticipantSummary::id))
                .toList();
    }

    private static String requestJson(String url, String failureContext) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .header(HEADER_ACCEPT, MIME_JSON)
                .build();
        try {
            HttpResponse<String> response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                logFailedRequest(failureContext, response);
                return null;
            }
            return response.body();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Lecture interrompue pendant " + failureContext + ".");
        } catch (IOException e) {
            System.err.println("Erreur lors de " + failureContext + " : " + formatException(e));
        }
        return null;
    }

    private static void mergeParticipantsFromMeetings(String payload, Map<Long, ParticipantAccumulator> unique) {
        if (payload == null || payload.isBlank()) {
            return;
        }
        int searchIndex = 0;
        while (searchIndex < payload.length()) {
            int objectStart = payload.indexOf('{', searchIndex);
            if (objectStart < 0) {
                return;
            }
            int objectEnd = findMatchingBrace(payload, objectStart);
            if (objectEnd < 0) {
                return;
            }
            processMeetingParticipants(payload.substring(objectStart + 1, objectEnd), unique);
            searchIndex = objectEnd + 1;
        }
    }

    private static void processMeetingParticipants(String meetingContent, Map<Long, ParticipantAccumulator> accumulator) {
        Long meetingId = extractLongField(meetingContent, "id");
        int participantsKey = meetingContent.indexOf("\"participants\"");
        if (participantsKey < 0) {
            return;
        }
        int arrayStart = meetingContent.indexOf('[', participantsKey);
        if (arrayStart < 0) {
            return;
        }
        int arrayEnd = findMatchingBracket(meetingContent, arrayStart);
        if (arrayEnd < 0) {
            return;
        }
        String arrayContent = meetingContent.substring(arrayStart + 1, arrayEnd);
        parseParticipantsArray(arrayContent, accumulator, meetingId);
    }

    private static void mergeParticipantsDirectory(String payload, Map<Long, ParticipantAccumulator> accumulator) {
        if (payload == null || payload.isBlank()) {
            return;
        }
        String trimmed = payload.trim();
        if (!trimmed.startsWith("[")) {
            return;
        }
        int arrayStart = trimmed.indexOf('[');
        int arrayEnd = findMatchingBracket(trimmed, arrayStart);
        if (arrayStart >= 0 && arrayEnd > arrayStart) {
            String arrayContent = trimmed.substring(arrayStart + 1, arrayEnd);
            parseParticipantsArray(arrayContent, accumulator, null);
        }
    }

    private static void parseParticipantsArray(String content, Map<Long, ParticipantAccumulator> accumulator, Long meetingId) {
        int index = 0;
        while (index < content.length()) {
            int objectStart = content.indexOf('{', index);
            if (objectStart < 0) {
                index = content.length();
            } else {
                int objectEnd = findMatchingBrace(content, objectStart);
                if (objectEnd < 0) {
                    index = content.length();
                } else {
                    ParticipantDetails details = parseParticipantObject(content.substring(objectStart + 1, objectEnd));
                    if (details != null && details.id() != null) {
                        ParticipantAccumulator acc = accumulator.computeIfAbsent(details.id(), ParticipantAccumulator::new);
                        acc.merge(details, meetingId);
                    }
                    index = objectEnd + 1;
                }
            }
        }
    }

    private static ParticipantDetails parseParticipantObject(String objectContent) {
        Long id = extractLongField(objectContent, "id");
        if (id == null) {
            return null;
        }
        String fullName = extractStringField(objectContent, "fullName");
        String email = extractStringField(objectContent, "email");
        return new ParticipantDetails(id, fullName, email);
    }

    private static Long extractLongField(String json, String fieldName) {
        int fieldIndex = json.indexOf("\"" + fieldName + "\"");
        if (fieldIndex < 0) {
            return null;
        }
        int colonIndex = json.indexOf(':', fieldIndex);
        if (colonIndex < 0) {
            return null;
        }
        int start = colonIndex + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) {
            start++;
        }
        boolean quoted = start < json.length() && json.charAt(start) == '"';
        if (quoted) {
            start++;
        }
        int end = start;
        while (end < json.length() && Character.isDigit(json.charAt(end))) {
            end++;
        }
        if (end == start) {
            return null;
        }
        if (quoted && (end >= json.length() || json.charAt(end) != '"')) {
            return null;
        }
        try {
            return Long.parseLong(json.substring(start, end));
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private static String extractStringField(String json, String fieldName) {
        int fieldIndex = json.indexOf("\"" + fieldName + "\"");
        if (fieldIndex < 0) {
            return null;
        }
        int colonIndex = json.indexOf(':', fieldIndex);
        if (colonIndex < 0) {
            return null;
        }
        int start = colonIndex + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) {
            start++;
        }
        if (start >= json.length()) {
            return null;
        }
        if (json.startsWith("null", start)) {
            return null;
        }
        if (json.charAt(start) != '"') {
            return null;
        }
        int end = skipJsonString(json, start);
        if (end < 0) {
            return null;
        }
        String raw = json.substring(start + 1, end);
        return decodeJsonString(raw);
    }

    private static int skipJsonString(String source, int startQuoteIndex) {
        boolean escaping = false;
        for (int i = startQuoteIndex + 1; i < source.length(); i++) {
            char current = source.charAt(i);
            if (escaping) {
                escaping = false;
            } else if (current == '\\') {
                escaping = true;
            } else if (current == '"') {
                return i;
            }
        }
        return -1;
    }

    private static int findMatchingBracket(String source, int startIndex) {
        int depth = 0;
        int index = startIndex;
        while (index < source.length()) {
            char current = source.charAt(index);
            if (current == '[') {
                depth++;
            } else if (current == ']') {
                depth--;
                if (depth == 0) {
                    return index;
                }
            } else if (current == '"') {
                int stringEnd = skipJsonString(source, index);
                if (stringEnd < 0) {
                    return -1;
                }
                index = stringEnd;
            }
            index++;
        }
        return -1;
    }

    private static int findMatchingBrace(String source, int startIndex) {
        int depth = 0;
        int index = startIndex;
        while (index < source.length()) {
            char current = source.charAt(index);
            if (current == '{') {
                depth++;
            } else if (current == '}') {
                depth--;
                if (depth == 0) {
                    return index;
                }
            } else if (current == '"') {
                int stringEnd = skipJsonString(source, index);
                if (stringEnd < 0) {
                    return -1;
                }
                index = stringEnd;
            }
            index++;
        }
        return -1;
    }

    private static String decodeJsonString(String raw) {
        StringBuilder builder = new StringBuilder(raw.length());
        boolean escaping = false;
        for (int i = 0; i < raw.length(); i++) {
            char current = raw.charAt(i);
            if (escaping) {
                builder.append(switch (current) {
                    case '\\' -> '\\';
                    case '"' -> '"';
                    case '/' -> '/';
                    case 'b' -> '\b';
                    case 'f' -> '\f';
                    case 'n' -> '\n';
                    case 'r' -> '\r';
                    case 't' -> '\t';
                    default -> current;
                });
                escaping = false;
            } else if (current == '\\') {
                escaping = true;
            } else {
                builder.append(current);
            }
        }
        if (escaping) {
            builder.append('\\');
        }
        return builder.toString();
    }

    private static void logFailedRequest(String context, HttpResponse<String> response) {
        System.err.println("Impossible de mener à bien " + context + " (code HTTP : " + response.statusCode() + ").");
        String body = response.body();
        if (body != null && !body.isBlank()) {
            System.err.println("Réponse : " + body);
        }
    }

    private static void printParticipantDirectory(List<ParticipantSummary> participants) {
        System.out.println("\nParticipants enregistrés :");
        for (ParticipantSummary participant : participants) {
            String displayName = participant.fullName() != null && !participant.fullName().isBlank()
                    ? participant.fullName()
                    : "(nom indisponible)";
            String emailInfo = participant.email() != null && !participant.email().isBlank()
                    ? " | " + participant.email()
                    : "";
            String meetingInfo = "";
            if (!participant.meetingIds().isEmpty()) {
                StringJoiner joiner = new StringJoiner(", ");
                for (Long meetingId : participant.meetingIds()) {
                    joiner.add(String.valueOf(meetingId));
                }
                meetingInfo = " | réunions: " + joiner;
            }
            System.out.println("- ID participant " + participant.id() + " : " + displayName + emailInfo + meetingInfo);
        }
        System.out.println();
    }

    private static Integer parseDurationInput(String input) {
        if (input == null) {
            return null;
        }
        String trimmed = input.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        if (trimmed.contains(":")) {
            String[] parts = trimmed.split(":", 2);
            try {
                int hours = Integer.parseInt(parts[0].trim());
                int minutes = Integer.parseInt(parts[1].trim());
                return Math.max((hours * 60) + minutes, 0);
            } catch (NumberFormatException e) {
                System.out.println("Format hh:mm invalide, durée ignorée.");
                return null;
            }
        }
        try {
            int value = Integer.parseInt(trimmed);
            return Math.max(value, 0);
        } catch (NumberFormatException e) {
            System.out.println("Durée invalide, durée ignorée.");
            return null;
        }
    }

    private static void sendGet(String path) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + path))
                .GET()
                .header(HEADER_ACCEPT, MIME_JSON)
                .build();
        sendRequest(request);
    }

    private static void sendPost(String path, String jsonPayload) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + path))
                .header(HEADER_CONTENT_TYPE, MIME_JSON)
                .header(HEADER_ACCEPT, MIME_JSON)
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();
        sendRequest(request);
    }

    private static void sendParticipantPost(String path, String jsonPayload) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(PARTICIPANT_URL + path))
                .header(HEADER_CONTENT_TYPE, MIME_JSON)
                .header(HEADER_ACCEPT, MIME_JSON)
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();
        sendRequest(request);
    }

    private static void sendPut(String path, String jsonPayload) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + path))
                .header(HEADER_CONTENT_TYPE, MIME_JSON)
                .header(HEADER_ACCEPT, MIME_JSON)
                .PUT(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();
        sendRequest(request);
    }

    private static void sendDelete(String path) {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + path))
                .DELETE()
                .header(HEADER_ACCEPT, MIME_JSON)
                .build();
        sendRequest(request);
    }

    private static void sendRequest(HttpRequest request) {
        try {
            HttpResponse<String> response = CLIENT.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            System.out.println("\nCode HTTP : " + response.statusCode());
            System.out.println("Réponse : " + response.body());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Appel HTTP interrompu, opération annulée.");
        } catch (IOException e) {
            System.err.println("Erreur lors de l'appel HTTP : " + formatException(e));
        }
    }

    private static String formatException(Throwable throwable) {
        StringBuilder builder = new StringBuilder();
        if (throwable.getMessage() != null && !throwable.getMessage().isBlank()) {
            builder.append(throwable.getMessage());
        } else {
            builder.append(throwable.getClass().getSimpleName());
        }
        Throwable cause = throwable.getCause();
        if (cause != null && cause != throwable) {
            builder.append(" - cause: ");
            if (cause.getMessage() != null && !cause.getMessage().isBlank()) {
                builder.append(cause.getMessage());
            } else {
                builder.append(cause.getClass().getSimpleName());
            }
        }
        return builder.toString();
    }

    private static Long readLong(Scanner scanner, String prompt) {
        System.out.print(prompt);
        String value = scanner.nextLine().trim();
        if (value.isEmpty()) {
            System.out.println("Valeur vide, opération annulée.");
            return null;
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            System.out.println("Nombre invalide : " + value);
            return null;
        }
    }

    private static String promptParticipantPayload(Scanner scanner, String emptyWarning) {
        System.out.print(PROMPT_FIRSTNAME);
        String firstname = scanner.nextLine().trim();
        System.out.print(PROMPT_LASTNAME);
        String lastname = scanner.nextLine().trim();
        String fullName = combineFullName(firstname, lastname);
        if (fullName.isEmpty()) {
            System.out.println(emptyWarning);
            return null;
        }
        System.out.print(PROMPT_EMAIL);
        String email = scanner.nextLine().trim();

        StringBuilder payloadBuilder = new StringBuilder("{\"fullName\":\"")
                .append(escapeJson(fullName))
                .append("\"");
        if (!email.isEmpty()) {
            payloadBuilder.append(",\"email\":\"")
                    .append(escapeJson(email))
                    .append("\"");
        }
        payloadBuilder.append("}");
        return payloadBuilder.toString();
    }

    private static String buildStatusField(String statusValue) {
        return "\"status\":\"" + escapeJson(statusValue) + "\"";
    }

    private static String combineFullName(String firstname, String lastname) {
        StringBuilder builder = new StringBuilder();
        if (!firstname.isBlank()) {
            builder.append(firstname.trim());
        }
        if (!lastname.isBlank()) {
            if (!builder.isEmpty()) {
                builder.append(' ');
            }
            builder.append(lastname.trim());
        }
        return builder.toString().trim();
    }

    private static String escapeJson(String input) {
        return input.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String urlEncode(String value) {
        return java.net.URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private record ParticipantSummary(Long id, String fullName, String email, List<Long> meetingIds) {
    }

    private record ParticipantDetails(Long id, String fullName, String email) {
    }

    private static final class ParticipantAccumulator {
        private final Long id;
        private String fullName;
        private String email;
        private final List<Long> meetingIds = new ArrayList<>();

        private ParticipantAccumulator(Long id) {
            this.id = id;
        }

        private void merge(ParticipantDetails details, Long meetingId) {
            if (details.fullName() != null && (fullName == null || fullName.isBlank())) {
                fullName = details.fullName();
            }
            if (details.email() != null && (email == null || email.isBlank())) {
                email = details.email();
            }
            if (meetingId != null && !meetingIds.contains(meetingId)) {
                meetingIds.add(meetingId);
            }
        }

        private ParticipantSummary toSummary() {
            List<Long> sortedMeetings = meetingIds.isEmpty()
                    ? List.of()
                    : meetingIds.stream().sorted().toList();
            return new ParticipantSummary(id, fullName, email, sortedMeetings);
        }
    }
}
