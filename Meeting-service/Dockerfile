# Utiliser l'image de base Quarkus avec GraalVM pour une image native
FROM quay.io/quarkus/quarkus-distroless-image:3.2.9.Final-java17

# Copier le jar exécutable
COPY target/quarkus-app/lib/ /deployments/lib/
COPY target/quarkus-app/*.jar /deployments/
COPY target/quarkus-app/app/ /deployments/app/
COPY target/quarkus-app/quarkus/ /deployments/quarkus/

# Exposer le port du service
EXPOSE 8080

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "/deployments/quarkus-run.jar"]
