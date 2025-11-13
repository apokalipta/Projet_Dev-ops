package com.meeting.microservices.meeting.rest;

import com.meeting.microservices.meeting.dto.ApiError;
import jakarta.validation.ConstraintViolationException;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriInfo;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

import java.time.Instant;

@Provider
public class RestExceptionMapper implements ExceptionMapper<Throwable> {

    @Context
    UriInfo uriInfo;

    @Override
    public Response toResponse(Throwable exception) {
        if (exception instanceof WebApplicationException webEx) {
            return buildResponse(webEx.getResponse().getStatus(), webEx.getMessage());
        }
        if (exception instanceof ConstraintViolationException validationEx) {
            String message = validationEx.getConstraintViolations().stream()
                    .map(violation -> violation.getPropertyPath() + " " + violation.getMessage())
                    .sorted()
                    .distinct()
                    .reduce((a, b) -> a + "; " + b)
                    .orElse(validationEx.getMessage());
            return buildResponse(Response.Status.BAD_REQUEST.getStatusCode(), message);
        }
        return buildResponse(Response.Status.INTERNAL_SERVER_ERROR.getStatusCode(), "Unexpected server error");
    }

    private Response buildResponse(int status, String message) {
        ApiError body = new ApiError(Instant.now(), status, message, uriInfo != null ? uriInfo.getPath() : "");
        return Response.status(status).entity(body).build();
    }
}
