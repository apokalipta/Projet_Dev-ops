package com.meeting.microservices.meeting.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public record MeetingRequest(
        String title,
        String description,
        @JsonProperty("meetingDate")
        @JsonAlias("scheduledAt")
        String meetingDate,
        @JsonProperty("previsualDuration")
        String previsualDuration,
        @JsonAlias("durationMinutes")
        Integer durationMinutes,
        @JsonAlias("status")
        String status,
        List<ParticipantRequest> participants
) {
}
