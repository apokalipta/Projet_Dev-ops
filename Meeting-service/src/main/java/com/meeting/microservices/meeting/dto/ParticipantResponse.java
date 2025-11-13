package com.meeting.microservices.meeting.dto;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public record ParticipantResponse(
        @JsonSerialize(using = ToStringSerializer.class)
        Long id,
        String fullName,
        String email
) {
}
