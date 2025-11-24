# Guide de revision : Meeting-service

Ce document synthetise le fonctionnement du microservice "Meeting-service"

## 1. Role global

Le "Meeting-service" gere la planification des reunions :
- creation avec titre, description, date, duree, langue et participants optionnels ;
- consultation d'une reunion ou de la liste complete ;
- gestion des participants rattaches a une reunion ;
- recherche de reunions par titre ;
- progression du statut de la reunion : `scheduled` -> `in_progress` -> `completed` ;
- Equipe REST exposee via Quarkus 3, persistance par Hibernate Panache sur une base MySQL.

## 2. Architecture technique

- **Framework** : Quarkus 3 (RESTEasy Reactive pour l'API, Hibernate Panache pour la persistence)
- **Langage** : Java 17
- **Build** : Gradle (module `Meeting-service`)
- **Base de donnees** : MySQL (`meeting`, `participant`, `meeting_participant`)
- **Configuration** : variables d'environnement JDBC (`MEETING_DB_URL`, `MEETING_DB_USERNAME`, `MEETING_DB_PASSWORD`)
- **Dev Mode** : `../gradlew :Meeting-service:quarkusDev`

### Packages principaux et fichiers clefs

- `com.meeting.microservices.meeting.rest`
  - `MeetingResource` : classe JAX-RS pour toutes les routes `/api/meeting` (creation, lecture, participants, start/end).
  - `ParticipantResource` : expose `/api/participant/all` pour l'annuaire global.

- `com.meeting.microservices.meeting.service`
  - `MeetingService` : logique metier centrale (validations, transitions de statut, conversions, interactions avec les repositories).

- `com.meeting.microservices.meeting.dto`
  - `MeetingRequest`, `MeetingResponse` : structures d'entree/sortie pour les reunions.
  - `ParticipantRequest`, `ParticipantResponse` : structures d'entree/sortie pour les participants.
  - `StatusUpdateRequest` : payload minimal pour les statuts exceptionnels (`postponed`, `cancelled`) si besoin.
  - `ApiError` : format d'erreur standard renvoye par l'API en cas d'exception.

- `com.meeting.microservices.MeetingDB`
  - `Meeting` : entite JPA mappee sur la table `meeting` (colonnes, relations participants).
  - `Participant` : entite JPA mappee sur la table `participant`.
  - `MeetingRepository`, `ParticipantRepository` : repositories Panache pour interroger les entites (requetes personnalisees, recherches par titre, etc.).
  - `Database` : utilitaire JDBC (non utilise par Panache mais conserve pour compatibilite) permettant d'obtenir une connexion brute via les variables d'environnement.

- `com.meeting.microservices.cli`
  - `MeetingCliApp` : application console permettant de piloter l'API (menus 1..10, start/end, etc.).

## 3. Modeles et tables

### Table `meeting`

Colonnes importantes :
- `meetingid` (PK),
- `title`, `description`,
- `date` (stocke la date planifiee),
- `previsual_duration` (duree prevue),
- `real_duration`,
- `status` (stocke la valeur "Planifiee", "En cours", etc.),
- `language`,
- `nb_participants` (compteur textualise).

### Table `participant`

- `participantid` (PK),
- `lastname`, `firstname`, `email`.

### Table `meeting_participant`

Table de jointure (PK composite) entre `meeting` et `participant`.

## 4. Flux metier principaux

### 4.1 Creation d'une reunion

1. Endpoint `POST /api/meeting`.
2. `MeetingRequest` accepte `title`, `description`, `scheduledAt`, `durationMinutes` (ou `previsualDuration`), `participants[]` (optionnel).
3. `MeetingService#createMeeting` :
   - valide le titre,
   - remplit les champs (langue par defaut `fr`, statut `Planifiee`),
   - persiste la reunion via `MeetingRepository`.
4. Pour chaque participant optionnel :
   - `resolveParticipant` recherche un participant existant (via `id`) ou en cree un nouveau,
   - `attachParticipant` l'ajoute a la reunion.
5. Reponse `MeetingResponse` : id, titre, description, date planifiee, duree en minutes (convertie si besoin), statut (`scheduled` cote API), liste de participants.

### 4.2 Lecture et recherche

- `GET /api/meeting/all` : liste toutes les reunions (projection en `MeetingResponse`).
- `GET /api/meeting/{id}` : details d'une reunion.
- `GET /api/meeting/{id}/participant/all` : liste les participants rattaches.
- `GET /api/participant/all` : liste de tous les participants enregistres (y compris non assignes).
- `POST /api/participant` : ajoute ou met a jour un participant dans l'annuaire sans passer par une reunion.
- `GET /api/meeting/search/byTitle?title=...` : filtre par mot cle dans le titre.

### 4.3 Gestion des participants (restrictions)

- `POST /api/meeting/{id}/participant` : ajoute un participant uniquement si la reunion n'est pas terminee (`STATUS_TERMINATED`).
- `DELETE /api/meeting/{id}/participant/{participantId}` : supprime un participant tant que la reunion n'est pas terminee.
- Quand la reunion est `Terminée`, toute modification provoque une erreur HTTP 409 (CONFLICT).

### 4.4 Cycle de vie de la reunion

- `PUT /api/meeting/{id}/start` :
  - verifie que la reunion existe et n'est ni terminee ni annulee.
  - status passe a `En cours` (expose en `in_progress`).
- `PUT /api/meeting/{id}/end` :
  - verifie que la reunion a commence (`En cours`),
  - status passe a `Terminée` (`completed`).

## 5. DTO exposes

- `MeetingRequest`
  - `title`
  - `description`
  - `scheduledAt` (alias `meetingDate`)
  - `durationMinutes` ou `previsualDuration`
  - `status` (facultatif, non necessaire pour la creation)
  - `participants[]` (tableau de `ParticipantRequest`)
- `ParticipantRequest`
  - `id` (facultatif)
  - `firstname`, `lastname` (ou `fullName` selon l'appelant)
  - `email`
- `StatusUpdateRequest`
  - `status` : utilise pour les statuts exceptionnels (report ou annulation) si vous conservez cet endpoint
- `MeetingResponse`
  - `id`, `title`, `description`, `scheduledAt`, `durationMinutes`
  - `status` (valeurs exposees cote API : `scheduled`, `in_progress`, `completed`, `postponed`, `cancelled`)
  - `participants[]` (`id`, `fullName`, `email`)

## 6. Composants REST principaux

### 6.1 MeetingResource

Expose tous les endpoints `/api/meeting` :
- `POST /api/meeting`
- `GET /api/meeting/all`
- `GET /api/meeting/{id}`
- `GET /api/meeting/{id}/participant/all`
- `POST /api/meeting/{id}/participant`
- `DELETE /api/meeting/{id}/participant/{participantId}`
- `PUT /api/meeting/{id}/start`
- `PUT /api/meeting/{id}/end`
- eventuellement `PUT /api/meeting/{id}/status` si active

### 6.2 ParticipantResource

- `GET /api/participant/all` : annuaire global des participants connus (y compris sans reunion).
- `POST /api/participant` : creation ou mise a jour d'un participant independamment d'une reunion.

## 7. Client CLI (`MeetingCliApp`)

- Permet de tester manuellement les endpoints sans Postman.
- Menu texte (Scanner + HttpClient) :
  1. creer une reunion, saisir participants existants/nouveaux ;
  2. lister toutes les reunions ;
  3. consulter une reunion par ID ;
  4. lister les participants assignes a une reunion ;
  5. ajouter un participant ;
  6. retirer un participant ;
  7. recherche par titre ;
  8. demarrer une reunion ;
  9. terminer une reunion ;
  10. lister les participants enregistres ;
  11. enregistrer ou mettre a jour un participant dans l'annuaire.
- Les appels HTTP renvoient les codes et le JSON renvoye par l'API.
- Les operations 5 et 6 echouent si la reunion est terminee (code 409).

## 8. Statuts et transitions

| Cote base | Cote API | Description |
|-----------|----------|-------------|
| `Planifiee` | `scheduled` | Reunion planifiee, avant demarrage |
| `En cours` | `in_progress` | Reunion demarree |
| `Terminee` | `completed` | Reunion close, participants verrouilles |
| `Reportee` | `postponed` | Statut exceptionnel (optionnel) |
| `Annulee` | `cancelled` | Statut exceptionnel (optionnel) |

Transitions autorisees :
- Creation -> `Planifiee` (`scheduled`).
- Start -> `En cours` (`in_progress`).
- End -> `Terminee` (`completed`).
- Depuis `Planifiee` ou `En cours` on peut eventuellement basculer vers `Reportee` ou `Annulee` si l'endpoint correspondant est conserve.
- Une fois `Terminee` ou `Annulee`, aucune modification de participants n'est acceptée.

## 9. Scripts utiles

### Demarrage du service
```
cd Meeting-service
../gradlew quarkusDev
```

### Build et tests
```
cd Meeting-service
../gradlew build
../gradlew test
```

### Exemple de requetes PowerShell
```
# Creation
$body = '{"title":"Sprint","description":"Planification","scheduledAt":"2025-11-08T10:00:00","durationMinutes":45}'
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/meeting" -ContentType "application/json" -Body $body

# Demarrage
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/api/meeting/1/start"

# Cloture
Invoke-RestMethod -Method Put -Uri "http://localhost:8080/api/meeting/1/end"

# Ajout de participant (echoue en 409 si la reunion est terminee)
$participant = '{"firstname":"Bob","lastname":"Martin"}'
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/meeting/1/participant" -ContentType "application/json" -Body $participant
```

## 10. Points a souligner a l'oral

1. **Verification des statuts** : transition automatique et verrous sur les participants apres cloture.
2. **Gestion participants** : re-utilisation d'un participant via son `id`, sinon creation d'un nouveau.
3. **DTO vs entites** : les entites sont cote `MeetingDB` (non exposees), on renvoie des DTO pour decoupler la persistence de l'API.
4. **CLI** : outil pedagogique pour demo rapide, s'appuie sur `HttpClient` et les endpoints REST.
5. **Configuration** : tout passe par des variables d'environnement, pas de credentials en dur.
6. **Tests / Qualite** : build Gradle + Quarkus Dev, possibilite d'etendre avec OpenAPI, tests d'integration, etc.

En memorisant ces 10 points et les principales routes, vous devriez pouvoir repondre aux questions sur la conception, le fonctionnement et la mise en pratique du Meeting-service.
