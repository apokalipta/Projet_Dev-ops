package com.meeting.microservices.meeting.dto;

import java.time.Instant;

public record ApiError(Instant timestamp, int status, String error, String path) {
}
