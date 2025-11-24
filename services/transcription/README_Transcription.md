# Transcription Service

Service de transcription et diarisation audio utilisant une architecture micro-services.

## 🚀 Démarrage rapide

### Prérequis
- Docker et Docker Compose installés

### Installation

1. **Configuration** (si nécessaire) :
   ```bash
   ./setup-docker.sh
   ```

2. **Démarrer les services** :
   ```bash
   docker-compose up -d
   ```

3. **Vérifier que tout fonctionne** :
   - Transcription-service : http://localhost:8082/openapi
   - AI Service : http://localhost:8000/docs

## 📚 Documentation

- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Documentation complète des API
- **[DOCKER_SETUP.md](DOCKER_SETUP.md)** - Guide d'utilisation Docker
- **[PORTABLE_SETUP.md](PORTABLE_SETUP.md)** - Créer une version portable
- **[README_DOCKER.md](README_DOCKER.md)** - Guide de démarrage rapide Docker

## 🏗️ Architecture

- **Transcription-service** : Service Quarkus (port 8082)
- **ai-service** : Service Python FastAPI pour transcription/diarisation (port 8000)
- **mysql-transcription** : Base de données MySQL

## 📦 Créer une version portable

```bash
./prepare-portable.sh
./create-portable-zip.sh
```

## 🔧 Commandes utiles

```bash
# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down

# Reconstruire les images
docker-compose build --no-cache
```

## 📝 Structure du projet

```
.
├── Transcription-service/    # Service Quarkus
├── ai-service/              # Service IA Python
├── docker-compose.yml       # Configuration Docker
├── .env                     # Configuration (chemins)
└── Documentation/           # Fichiers de documentation
```

