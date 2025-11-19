# Documentation des API - Microservices

## Meeting Service

Base URL: `http://localhost:8081`

---

### 1. Créer une réunion

**Endpoint:** `POST /api/meeting`

**Description:** Crée une nouvelle réunion avec les informations fournies.

**Payload JSON:**
```json
{
  "title": "Sprint Planning",
  "description": "Préparation du sprint pour la semaine prochaine",
  "scheduledAt": "2025-11-20T10:00:00",
  "durationMinutes": 45,
  "status": "scheduled",
  "participants": [
    {
      "fullName": "Alice Durand",
      "email": "alice.durand@example.com"
    },
    {
      "firstname": "Bob",
      "lastname": "Martin",
      "email": "bob.martin@example.com"
    }
  ]
}
```

**Note:** 
- `scheduledAt` peut aussi être fourni sous le nom `meetingDate`
- `durationMinutes` peut aussi être fourni sous le nom `previsualDuration` (en string)
- Pour les participants, vous pouvez utiliser soit `fullName` (qui sera automatiquement séparé en prénom/nom), soit `firstname` et `lastname` séparément

**Réponse (201 Created):**
```json
{
  "id": "1",
  "title": "Sprint Planning",
  "description": "Préparation du sprint pour la semaine prochaine",
  "scheduledAt": "2025-11-20T10:00:00",
  "durationMinutes": 45,
  "status": "scheduled",
  "participants": [
    {
      "id": "1",
      "fullName": "Alice Durand",
      "email": "alice.durand@example.com"
    },
    {
      "id": "2",
      "fullName": "Bob Martin",
      "email": "bob.martin@example.com"
    }
  ]
}
```

---

### 2. Lister toutes les réunions

**Endpoint:** `GET /api/meeting/all`

**Description:** Récupère la liste de toutes les réunions.

**Réponse (200 OK):**
```json
[
  {
    "id": "1",
    "title": "Sprint Planning",
    "description": "Préparation du sprint pour la semaine prochaine",
    "scheduledAt": "2025-11-20T10:00:00",
    "durationMinutes": 45,
    "status": "scheduled",
    "participants": [
      {
        "id": "1",
        "fullName": "Alice Durand",
        "email": "alice.durand@example.com"
      }
    ]
  }
]
```

---

### 3. Obtenir une réunion par ID

**Endpoint:** `GET /api/meeting/{meetingId}`

**Description:** Récupère les détails d'une réunion spécifique.

**Paramètres:**
- `meetingId` (path): ID de la réunion

**Réponse (200 OK):**
```json
{
  "id": "1",
  "title": "Sprint Planning",
  "description": "Préparation du sprint pour la semaine prochaine",
  "scheduledAt": "2025-11-20T10:00:00",
  "durationMinutes": 45,
  "status": "scheduled",
  "participants": [
    {
      "id": "1",
      "fullName": "Alice Durand",
      "email": "alice.durand@example.com"
    }
  ]
}
```

---

### 4. Rechercher des réunions par titre

**Endpoint:** `GET /api/meeting/search/byTitle?title={title}`

**Description:** Recherche des réunions dont le titre contient le terme recherché (insensible à la casse).

**Paramètres:**
- `title` (query): Terme de recherche

**Exemple:** `GET /api/meeting/search/byTitle?title=planning`

**Réponse (200 OK):**
```json
[
  {
    "id": "1",
    "title": "Sprint Planning",
    "description": "Préparation du sprint pour la semaine prochaine",
    "scheduledAt": "2025-11-20T10:00:00",
    "durationMinutes": 45,
    "status": "scheduled",
    "participants": []
  }
]
```

---

### 5. Démarrer une réunion

**Endpoint:** `PUT /api/meeting/{meetingId}/start`

**Description:** Démarre une réunion (transition de statut: `scheduled` → `in_progress`).

**Paramètres:**
- `meetingId` (path): ID de la réunion

**Réponse (200 OK):**
```json
{
  "id": "1",
  "title": "Sprint Planning",
  "description": "Préparation du sprint pour la semaine prochaine",
  "scheduledAt": "2025-11-20T10:00:00",
  "durationMinutes": 45,
  "status": "in_progress",
  "participants": []
}
```

---

### 6. Clore une réunion

**Endpoint:** `PUT /api/meeting/{meetingId}/end`

**Description:** Clôture une réunion (transition de statut: `in_progress` → `completed`).

**Paramètres:**
- `meetingId` (path): ID de la réunion

**Réponse (200 OK):**
```json
{
  "id": "1",
  "title": "Sprint Planning",
  "description": "Préparation du sprint pour la semaine prochaine",
  "scheduledAt": "2025-11-20T10:00:00",
  "durationMinutes": 45,
  "status": "completed",
  "participants": []
}
```

**Note:** Une fois qu'une réunion est `completed`, il n'est plus possible d'ajouter ou de retirer des participants.

---

### 7. Lister les participants d'une réunion

**Endpoint:** `GET /api/meeting/{meetingId}/participant/all`

**Description:** Récupère la liste de tous les participants d'une réunion spécifique.

**Paramètres:**
- `meetingId` (path): ID de la réunion

**Réponse (200 OK):**
```json
[
  {
    "id": "1",
    "fullName": "Alice Durand",
    "email": "alice.durand@example.com"
  },
  {
    "id": "2",
    "fullName": "Bob Martin",
    "email": "bob.martin@example.com"
  }
]
```

---

### 8. Ajouter un participant à une réunion

**Endpoint:** `POST /api/meeting/{meetingId}/participant`

**Description:** Ajoute un participant à une réunion existante. Refusé si la réunion est déjà `completed`.

**Paramètres:**
- `meetingId` (path): ID de la réunion

**Payload JSON:**
```json
{
  "fullName": "Claire Dupont",
  "email": "claire.dupont@example.com"
}
```

**Ou avec firstname/lastname:**
```json
{
  "firstname": "Claire",
  "lastname": "Dupont",
  "email": "claire.dupont@example.com"
}
```

**Réponse (201 Created):**
```json
{
  "id": "3",
  "fullName": "Claire Dupont",
  "email": "claire.dupont@example.com"
}
```

**Erreur (409 Conflict):** Si la réunion est déjà terminée (`completed`)

---

### 9. Retirer un participant d'une réunion

**Endpoint:** `DELETE /api/meeting/{meetingId}/participant/{participantId}`

**Description:** Retire un participant d'une réunion. Refusé si la réunion est déjà `completed`.

**Paramètres:**
- `meetingId` (path): ID de la réunion
- `participantId` (path): ID du participant à retirer

**Réponse (204 No Content):** Aucun contenu

**Erreur (409 Conflict):** Si la réunion est déjà terminée (`completed`)

---

### 10. Lister tous les participants (annuaire)

**Endpoint:** `GET /api/participant/all`

**Description:** Récupère la liste de tous les participants enregistrés dans l'annuaire, qu'ils soient associés à une réunion ou non.

**Réponse (200 OK):**
```json
[
  {
    "id": "1",
    "fullName": "Alice Durand",
    "email": "alice.durand@example.com"
  },
  {
    "id": "2",
    "fullName": "Bob Martin",
    "email": "bob.martin@example.com"
  },
  {
    "id": "3",
    "fullName": "Claire Dupont",
    "email": "claire.dupont@example.com"
  }
]
```

---

### 11. Créer ou mettre à jour un participant (annuaire)

**Endpoint:** `POST /api/participant`

**Description:** Crée un nouveau participant dans l'annuaire ou met à jour un participant existant si un `id` est fourni.

**Payload JSON (création):**
```json
{
  "firstname": "David",
  "lastname": "Bernard",
  "email": "david.bernard@example.com"
}
```

**Ou avec fullName:**
```json
{
  "fullName": "David Bernard",
  "email": "david.bernard@example.com"
}
```

**Payload JSON (mise à jour):**
```json
{
  "id": 1,
  "firstname": "Alice",
  "lastname": "Durand",
  "email": "alice.durand.new@example.com"
}
```

**Réponse (201 Created pour création, 200 OK pour mise à jour):**
```json
{
  "id": "4",
  "fullName": "David Bernard",
  "email": "david.bernard@example.com"
}
```

---

## Statuts de réunion

Les statuts possibles pour une réunion sont :
- `scheduled` : Réunion planifiée
- `in_progress` : Réunion en cours
- `completed` : Réunion terminée

---

## Codes de statut HTTP

- `200 OK` : Requête réussie
- `201 Created` : Ressource créée avec succès
- `204 No Content` : Requête réussie, pas de contenu à retourner
- `400 Bad Request` : Requête invalide (validation échouée)
- `404 Not Found` : Ressource non trouvée
- `409 Conflict` : Conflit (ex: tentative d'ajout/retrait de participant sur une réunion terminée)
- `500 Internal Server Error` : Erreur serveur

---

## Exemples d'utilisation avec curl

### Créer une réunion
```bash
curl -X POST http://localhost:8081/api/meeting \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Sprint Planning",
    "description": "Préparation du sprint",
    "scheduledAt": "2025-11-20T10:00:00",
    "durationMinutes": 45,
    "status": "scheduled",
    "participants": [
      {
        "fullName": "Alice Durand",
        "email": "alice@example.com"
      }
    ]
  }'
```

### Lister toutes les réunions
```bash
curl http://localhost:8081/api/meeting/all
```

### Obtenir une réunion par ID
```bash
curl http://localhost:8081/api/meeting/1
```

### Rechercher par titre
```bash
curl "http://localhost:8081/api/meeting/search/byTitle?title=planning"
```

### Démarrer une réunion
```bash
curl -X PUT http://localhost:8081/api/meeting/1/start
```

### Clore une réunion
```bash
curl -X PUT http://localhost:8081/api/meeting/1/end
```

### Ajouter un participant à une réunion
```bash
curl -X POST http://localhost:8081/api/meeting/1/participant \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "Bob",
    "lastname": "Martin",
    "email": "bob@example.com"
  }'
```

### Retirer un participant d'une réunion
```bash
curl -X DELETE http://localhost:8081/api/meeting/1/participant/2
```

### Lister tous les participants
```bash
curl http://localhost:8081/api/participant/all
```

### Créer un participant dans l'annuaire
```bash
curl -X POST http://localhost:8081/api/participant \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "Claire",
    "lastname": "Dupont",
    "email": "claire@example.com"
  }'
```

---

## Notes importantes

1. **Format de date:** Les dates doivent être au format ISO 8601 : `YYYY-MM-DDTHH:mm:ss` (ex: `2025-11-20T10:00:00`)

2. **Participants:** 
   - Vous pouvez utiliser `fullName` (qui sera automatiquement séparé) ou `firstname`/`lastname` séparément
   - L'email est optionnel mais recommandé

3. **Statuts:** 
   - Les réunions terminées (`completed`) ne peuvent plus être modifiées (ajout/retrait de participants)
   - Les transitions de statut sont : `scheduled` → `in_progress` → `completed`

4. **Validation:** 
   - Le titre d'une réunion est obligatoire
   - Les champs sont validés côté serveur

5. **Base URL:** Par défaut, le service écoute sur le port `8081`. En production, ajustez selon votre configuration.

