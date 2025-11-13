# Meeting-service

Service Meetings du projet Projet_Dev-ops. Il gere la planification des reunions, le suivi des participants et expose leur detail complet via des API REST Quarkus.

## Fonctionnalites

- Creation de reunion avec titre, description, date, langue, duree previsionnelle et participants optionnels.
- Consultation detaillee d'une reunion et liste globale des reunions.
- Gestion des participants : ajout, suppression, liste triee.
- Recherche par titre.
- Cloture d'une reunion avec calcul automatique de la duree reelle (base sur `meetingDate`).
- Mise a jour du statut parmi les valeurs autorisees (`Planifiee`, `En cours`, `Terminee`, `Reportee`, `Annulee`).

## Architecture

- **Framework** : Quarkus 3 (RESTEasy Reactive, Hibernate Panache)
- **Langage** : Java 17
- **Build** : Gradle
- **Base de donnees** : MySQL (tables `meeting` et `participant`)
- **Configuration** : variables d'environnement JDBC
- **CLI** : utilitaire Java `MeetingCliApp` qui orchestre les endpoints

## Prerequis

- JDK 17+
- Gradle wrapper fourni (pas besoin d'installation globale)
- MySQL 8+ accessible
- Variables d'environnement configurees :
  - `MEETING_DB_USERNAME`
  - `MEETING_DB_PASSWORD`
  - `MEETING_DB_URL` (ex. `jdbc:mysql://localhost:3306/Meeting`)

## Configuration MySQL

```sql
CREATE DATABASE IF NOT EXISTS Meeting;
USE Meeting;

CREATE TABLE IF NOT EXISTS meeting (
    meetingid BIGINT PRIMARY KEY AUTO_INCREMENT,
    nb_participants VARCHAR(10),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date VARCHAR(50),
    previsual_duration VARCHAR(50),
    real_duration VARCHAR(50),
    status VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS participant (
    participantid BIGINT PRIMARY KEY AUTO_INCREMENT,
    lastname VARCHAR(255),
  firstname VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS meeting_participant (
    meeting_id BIGINT NOT NULL,
    participant_id BIGINT NOT NULL,
    PRIMARY KEY (meeting_id, participant_id),
    CONSTRAINT fk_meeting FOREIGN KEY (meeting_id) REFERENCES meeting(meetingid),
    CONSTRAINT fk_participant FOREIGN KEY (participant_id) REFERENCES participant(participantid)
);

ALTER TABLE meeting
  ADD COLUMN language VARCHAR(10) NOT NULL DEFAULT 'fr',
  MODIFY real_duration VARCHAR(16) NULL,
  MODIFY status VARCHAR(32) NOT NULL DEFAULT 'Planifiee';

ALTER TABLE meeting ALTER language DROP DEFAULT;
```

> Remarque : le dernier `ALTER TABLE ... DROP DEFAULT` est optionnel. Gardez le defaut `fr` tant que la langue n'est pas renseignee pour toutes les lignes existantes.

## Reinitialiser la base de donnees

Pour repartir sur des identifiants auto-incrementes a partir de 1, sauvegardez d'abord vos donnees si necessaire (`mysqldump meeting > backup.sql`), puis videz les tables en desactivant temporairement les contraintes :

```sql
USE meeting;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE meeting_participant;
TRUNCATE TABLE participant;
TRUNCATE TABLE meeting;
SET FOREIGN_KEY_CHECKS = 1;
```

Adaptez la liste des tables a votre schema. Les commandes `TRUNCATE` remettent l'auto-increment a zero pour chaque table.

## Nettoyage des fichiers de logs

Pour supprimer tous les fichiers `*.log` residant dans le projet (exemple sous PowerShell) :

```powershell
Get-ChildItem -Path C:\Users\Amira\git\Projet_Dev-ops -Filter *.log -Recurse | Remove-Item -Force
```

Attention : cette commande est destructive. Verifiez qu'aucun fichier journal necessaire au debug n'est conserve dans le repertoire avant de l'executer.

## Demarrer le service

```bash
cd Meeting-service
../gradlew quarkusDev
```
ou
```bash
.\gradlew :Meeting-service:quarkusDev  
```

Par defaut, l'API ecoute sur `http://localhost:8080`.

### Build production

```bash
cd Meeting-service
../gradlew build
```

Le jar executable se trouve sous `build/quarkus-app/`.

## API principale

| Verbe | Endpoint | Description |
|-------|----------|-------------|
| POST | `/api/meeting` | Creer une reunion |
| GET | `/api/meeting/all` | Lister les reunions |
| GET | `/api/meeting/{id}` | Detail d'une reunion |
| GET | `/api/meeting/{id}/participant/all` | Lister les participants |
| GET | `/api/participant/all` | Lister tous les participants enregistrés |
| POST | `/api/meeting/{id}/participant` | Ajouter un participant |
| DELETE | `/api/meeting/{id}/participant/{participantId}` | Retirer un participant |
| GET | `/api/meeting/search/byTitle` | Rechercher par titre (`title` en parametre) |
| POST | `/api/meeting/{id}/start` | Demarrer la reunion (passe le statut `En cours`) |
| PUT | `/api/meeting/{id}/status` | Mettre a jour le statut |

### DTOs principaux

- `MeetingRequest` : `title`, `description`, `scheduledAt` (alias `meetingDate`), `durationMinutes` ou `previsualDuration`, `status`, `participants[]`
- `StatusUpdateRequest` : `status`
- Reponse `MeetingResponse` : `id`, `title`, `description`, `scheduledAt`, `durationMinutes`, `status`, `participants[]` (`id`, `fullName`, `email`)

## Utilitaire CLI

Permet d'exercer les endpoints sans outil supplementaire.

```bash
cd Meeting-service
../gradlew run --args='cli'
```

Fonctionnalites : creation, consultation, recherche, gestion des participants, demarrage et mise a jour du statut.

### Options disponibles

- `1`: creation d'une reunion complete (participants existants ou nouveaux).
- `2`: liste de toutes les reunions via `/api/meeting/all`.
- `5` et `10`: reutilisation du repertoire des participants, incluant ceux sans reunion (`/api/participant/all`).
- `7`: recherche par titre avec mot-cle.
- `8` et `9`: controle du cycle de vie (demarrage, changement de statut).
- `0`: sortie de l'application.

Lance d'abord Quarkus (`../gradlew quarkusDev`), sinon les appels HttpClient echoueront.

## Jeux de donnees d'exemple

Pour tester rapidement, inserez des participants et une reunion de base :

```sql
USE Meeting;

INSERT INTO participant (lastname, firstname, email)
VALUES
  ('Durand', 'Alice', 'alice@example.com'),
  ('Martin', 'Bob', 'bob@example.com');

INSERT INTO meeting (nb_participants, title, description, date, previsual_duration, real_duration, status, language)
VALUES ('0', 'Demo', 'Reunion de demonstration', '2025-11-01T09:00:00', '60', NULL, 'Planifiee', 'fr');

INSERT INTO meeting_participant (meeting_id, participant_id)
VALUES (LAST_INSERT_ID(), 1);
```

Les participants restants non rattaches seront visibles via `/api/participant/all` et l'option 10 du CLI.

## Verifier les APIs

Lancer Quarkus en dev (`../gradlew quarkusDev`) puis utiliser `curl` ou `Invoke-RestMethod` (PowerShell) :

```powershell
# Creer une reunion (les alias `meetingDate` et `previsualDuration` restent acceptes)
$body = '{"title":"Sprint planning","description":"Preparation sprint","scheduledAt":"2025-11-08T10:00:00","durationMinutes":45,"status":"scheduled","participants":[{"fullName":"Alice Durand","email":"alice@example.com"}]}'
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/meeting" `
  -ContentType "application/json" -Body $body

# Lister toutes les reunions
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/meeting/all"

# Detail d'une reunion
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/meeting/1"

# Participants de la reunion
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/meeting/1/participant/all"

# Repertoire de tous les participants
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/participant/all"

# Ajouter un participant
$participant = '{"firstname":"Bob","lastname":"Martin"}'
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/meeting/1/participant" `
  -ContentType "application/json" -Body $participant

# Supprimer un participant (id 2)
Invoke-RestMethod -Method Delete -Uri "http://localhost:8080/api/meeting/1/participant/2"

# Recherche par titre
Invoke-RestMethod -Method Get -Uri "http://localhost:8080/api/meeting/search/byTitle?title=planning"

# Demarrer la reunion
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/meeting/1/start"

# Mettre a jour le statut
$status = '{"status":"En cours"}'
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/api/meeting/1/status" `
  -ContentType "application/json" -Body $status
```

Chaque appel renvoie un JSON representant l'etat courant de la reunion; ajuster les identifiants selon les donnees retournees par l'API.

## Tests

Executer la compilation et les tests :

```bash
cd Meeting-service
../gradlew test
```

Activez le rapport complet (`../gradlew check`) pour executer les verifications supplementaires configurees dans Gradle.

## Configuration et profils

- Le fichier `src/main/resources/application.properties` contient la configuration dev par defaut (JDBC, taille du pool, desactivation RabbitMQ devservices).
- Pour surcharger les identifiants en production, utilisez les variables d'environnement ou un fichier `application-prod.properties` et lancez `../gradlew quarkusDev -Dquarkus.profile=prod`.
- `quarkus.hibernate-orm.database.generation=update` met a jour le schema automatiquement en dev; passez-le a `validate` en production pour eviter toute modification involontaire.


## Conteneurisation (a faire)

- Ajouter un Dockerfile Quarkus (mode JVM).
- Integrer le service au `docker-compose.yml` global avec MySQL, RabbitMQ et les autres microservices.

## Troubleshooting

- Erreur JDBC : verifier les variables d'environnement et la disponibilite MySQL.
- Erreur RabbitMQ en dev : les devservices Quarkus sont desactives via `application.properties`.
- Statut ou langue invalide : le service controle la liste (`fr`, `en`, `es`, `de`, `it`, `pt`, `ar`).

## Prochaines etapes suggerees

1. Ajouter un Dockerfile et l'entree correspondante dans le compose global.
2. Exposer la documentation OpenAPI (activer `quarkus-smallrye-openapi`).
3. Industrialiser la configuration (profils Quarkus, secrets). 
