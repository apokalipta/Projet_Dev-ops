# Configuration Docker pour Transcription-service

Ce document explique comment utiliser Docker Compose pour orchestrer les services de transcription.

## Services inclus

1. **mysql-transcription** : Base de données MySQL pour le service de transcription
2. **transcription-service** : Service Quarkus qui écoute sur le port 8082
3. **ai-service** : Service Python FastAPI pour la transcription/diarisation (port 8000)

## Prérequis

- Docker et Docker Compose installés
- Le service IA doit être accessible (chemin configuré via variable d'environnement)

## Configuration initiale

### Option 1 : Script automatique (recommandé)

```bash
./setup-docker.sh
```

Le script vous guidera pour configurer le chemin vers votre dossier IA.

### Option 2 : Configuration manuelle

1. Copiez le fichier d'exemple :
```bash
cp env.example .env
```

2. Éditez le fichier `.env` et ajustez le chemin `AI_SERVICE_PATH` :
```bash
# Si le dossier IA est dans ce projet
AI_SERVICE_PATH=./ai-service

# Si le dossier IA est à côté de ce projet
AI_SERVICE_PATH=../Transcription_AI/IA

# Ou tout autre chemin relatif
AI_SERVICE_PATH=../../mon-chemin/vers/IA
```

**Note** : Le chemin doit être relatif au répertoire où se trouve le `docker-compose.yml`.

## Configuration

### Base de données MySQL

- **Host**: `mysql-transcription` (dans Docker) ou `localhost` (depuis l'extérieur)
- **Port**: 3306
- **Database**: `transcriptiondb`
- **Username**: `root`
- **Password**: `root`

### Transcription-service

- **Port**: 8082
- **URL**: http://localhost:8082
- **Swagger UI**: http://localhost:8082/openapi

### AI Service

- **Port**: 8000
- **URL**: http://localhost:8000

## Utilisation

### Démarrer tous les services

```bash
docker-compose up -d
```

### Voir les logs

```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f transcription-service
docker-compose logs -f ai-service
docker-compose logs -f mysql-transcription
```

### Arrêter les services

```bash
docker-compose down
```

### Arrêter et supprimer les volumes (⚠️ supprime les données)

```bash
docker-compose down -v
```

### Reconstruire les images

```bash
docker-compose build --no-cache
```

## Portabilité

Le projet est maintenant entièrement portable ! Le chemin vers le service IA est configuré via la variable d'environnement `AI_SERVICE_PATH` dans le fichier `.env`. 

- ✅ Aucun chemin absolu dans le code
- ✅ Configuration via fichier `.env` (non versionné)
- ✅ Fonctionne sur n'importe quel PC après configuration

**Important** : N'oubliez pas d'ajouter `.env` à votre `.gitignore` si vous versionnez le projet, car il contient des chemins spécifiques à votre machine.

## Vérification

Une fois les services démarrés, vous pouvez vérifier qu'ils fonctionnent :

1. **Transcription-service** : http://localhost:8082/openapi
2. **AI Service** : http://localhost:8000/docs (documentation FastAPI)
3. **MySQL** : Connectez-vous avec un client MySQL sur `localhost:3306`

## Communication entre services

- Le `transcription-service` communique avec `ai-service` via `http://ai-service:8000`
- L'`ai-service` communique avec `transcription-service` via `http://transcription-service:8082`
- Le `transcription-service` se connecte à MySQL via `mysql-transcription:3306`

Ces noms de services sont résolus automatiquement par Docker Compose dans le réseau `transcription-network`.

