# Stage 1: Build
FROM gradle:8.5-jdk17 AS build
WORKDIR /app

# Copy root build files
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

# Copy Transcription-service files
COPY Transcription-service/build.gradle ./Transcription-service/
COPY Transcription-service/src ./Transcription-service/src

# Build the application (skip tests for faster build)
RUN gradle :Transcription-service:build -x test --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:17-jre

# Create deployment directory
WORKDIR /deployments

# Copy the built application
COPY --from=build /app/Transcription-service/build/quarkus-app/lib/ ./lib/
COPY --from=build /app/Transcription-service/build/quarkus-app/*.jar ./
COPY --from=build /app/Transcription-service/build/quarkus-app/app/ ./app/
COPY --from=build /app/Transcription-service/build/quarkus-app/quarkus/ ./quarkus/

# Expose the port
EXPOSE 8082

# Start the application
ENTRYPOINT ["java", "-jar", "/deployments/quarkus-run.jar"]

