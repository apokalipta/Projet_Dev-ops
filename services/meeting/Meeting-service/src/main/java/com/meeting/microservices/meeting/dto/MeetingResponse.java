package com.meeting.microservices.meeting.dto;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

import java.util.List;

public record MeetingResponse(
        @JsonSerialize(using = ToStringSerializer.class)
        Long id,
        String title,
        String description,
        String scheduledAt,
        Integer durationMinutes,
        String status,
        List<ParticipantResponse> participants
) {
}
