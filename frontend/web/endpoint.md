# 📋 Catalogue des Endpoints Backend

Ce document centralise les endpoints REST à implémenter pour les deux sous-projets : **Meeting** et **Transcription**. Les exemples supposent un préfixe d’API commun `https://api.transcript-ia.com/api` et une authentification JWT.

> **Headers recommandés**
> ```http
> Authorization: Bearer <token>
> Content-Type: application/json
> ```

---

## 🗂️ Sous-projet N°1 — Meetings & Participants

| Méthode | Endpoint | Description | Réponse attendue |
|---------|----------|-------------|-------------------|
| **POST** | `/api/meeting` | Créer une nouvelle réunion | `201 Created` + objet Meeting |
| **GET** | `/api/meeting/all` | Lister toutes les réunions | `200 OK` + liste de Meeting |
| **GET** | `/api/meeting/{id_meeting}` | Détails d’une réunion | `200 OK` + Meeting |
| **GET** | `/api/meeting/{id_meeting}/participant/all` | Participants de la réunion | `200 OK` + liste de Participants |
| **POST** | `/api/meeting/{id_meeting}/participant` | Ajouter un participant | `201 Created` + Participant |
| **DELETE** | `/api/meeting/{id_meeting}/participant/{id_participant}` | Retirer un participant | `204 No Content` |
| **GET** | `/api/meeting/search/byTitle?title=...` | Recherche de réunions par titre | `200 OK` + liste de Meeting |

### Modèle Meeting (exemple)
```json
{
  "id": "uuid",
  "title": "Daily Standup",
  "description": "Point d'équipe",
  "scheduledAt": "2024-02-01T09:00:00Z",
  "durationMinutes": 30,
  "participantSlots": 5,
  "status": "scheduled",
  "participants": [
    {
      "id": "uuid",
      "fullName": "Jean Dupont",
      "email": "jean.dupont@example.com"
    }
  ],
  "metadata": {
    "autoStart": true,
    "sendReminders": false
  },
  "createdAt": "2024-01-31T16:12:00Z",
  "updatedAt": "2024-01-31T16:12:00Z"
}
```

### Points de vigilance
- Validation forte sur `title`, `scheduledAt`, `durationMinutes`.
- Gérer les doublons d’email lors de l’ajout de participant.
- Pagination & filtres recommandés pour `/meeting/all`.
- Audit : garder trace des ajouts/suppressions de participants.

---

## 🎙️ Sous-projet N°2 — Transcription, Locuteurs & Segments

| Méthode | Endpoint | Description | Réponse attendue |
|---------|----------|-------------|-------------------|
| **GET** | `/api/transcription/{id_reunion}/segment/all` | Segments de la transcription | `200 OK` + liste de Segments |
| **GET** | `/api/transcription/{id_reunion}/segment/{id_segment}` | Segment spécifique | `200 OK` + Segment |
| **PUT** | `/api/transcription/{id_reunion}/segment/{id_segment}` | Modifier le texte d’un segment | `202 Accepted` + Segment mis à jour |
| **GET** | `/api/transcription/{id_reunion}/segment/{id_segment}/locuteur/all` | Locuteurs d’un segment | `200 OK` + liste de Locuteurs |
| **PUT** | `/api/transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant}` | Redéfinir le locuteur attribué | `202 Accepted` + Segment mis à jour |
| **GET** | `/api/transcription/{id_reunion}/record_file` | Récupérer le fichier audio brut | `200 OK` + fichier/URL |
| **GET** | `/api/transcription/{id_reunion}/segment/{id_segment}/time_depart` | Heure de début du segment | `200 OK` + timestamp |
| **GET** | `/api/transcription/{id_reunion}/segment/{id_segment}/time_fin` | Heure de fin du segment | `200 OK` + timestamp |

### Modèle Segment (exemple)
```json
{
  "id": "uuid",
  "meetingId": "uuid",
  "speaker": {
    "id": "uuid",
    "label": "Participant 1"
  },
  "startTime": "2024-02-01T09:05:12.345Z",
  "endTime": "2024-02-01T09:05:45.120Z",
  "confidence": 0.94,
  "text": "Bonjour à tous, merci d'être présents."
}
```

### Recommandations
- `GET record_file` peut renvoyer une URL signée (S3, CDN) plutôt que le binaire direct.
- `PUT` segments/locuteurs : journaliser les modifications (audit trail).
- Contrôle d’accès : seuls les participants autorisés doivent pouvoir modifier la transcription.
- Indexer `startTime`/`endTime` pour la reconstruction audio.

---

## 🔐 Exigences Transverses
- Authentification JWT obligatoire pour tous les endpoints.
- Rate limiting côté API Gateway.
- Validation schéma (JSON Schema / JOI) sur les payloads.
- Gestion des erreurs avec codes cohérents (`4xx`, `5xx`) et payload uniforme `{ message, errors?, timestamp }`.

---

## 🗺️ Roadmap d’Implémentation
1. Définir les schémas DB (`meeting`, `participant`, `transcription`, `segment`, `speaker`).
2. Implémenter les endpoints Meeting (CRUD + recherche).
3. Implémenter les endpoints Transcription (lecture, édition, alignement audio).
4. Intégrer l’upload audio & stockage objet.
5. Ajouter tests d’intégration + documentation (OpenAPI / Swagger).


