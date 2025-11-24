package com.meeting.microservices.meeting.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ParticipantRequest(
                Long id,
                String firstname,
                String lastname,
                @JsonAlias("fullName") String fullName,
                String email
) {

        public String resolvedFirstname() {
                if (firstname != null && !firstname.isBlank()) {
                        return firstname;
                }
                if (fullName != null && !fullName.isBlank()) {
                        String[] tokens = fullName.trim().split("\\s+", 2);
                        return tokens.length > 0 ? tokens[0] : null;
                }
                return null;
        }

        public String resolvedLastname() {
                if (lastname != null && !lastname.isBlank()) {
                        return lastname;
                }
                if (fullName != null && !fullName.isBlank()) {
                        String[] tokens = fullName.trim().split("\\s+", 2);
                        return tokens.length > 1 ? tokens[1] : tokens[0];
                }
                return null;
        }
}
