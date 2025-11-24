FROM gradle:8.11.1-jdk17 AS build
WORKDIR /workspace
COPY . .
RUN gradle :Meeting-service:build --no-daemon

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/Meeting-service/build/quarkus-app/ /app/
EXPOSE 8081
ENV QUARKUS_HTTP_PORT=8081
ENTRYPOINT ["java", "-jar", "quarkus-run.jar"]

