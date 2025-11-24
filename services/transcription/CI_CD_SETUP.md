# Configuration CI/CD pour les services de transcription

Ce projet utilise GitHub Actions pour construire automatiquement les images Docker et les publier sur GitHub Container Registry (ghcr.io).

## Configuration initiale

### 1. Créer un fichier `.env`

Copiez le fichier `env.example` en `.env` :

```bash
cp env.example .env
```

### 2. Configurer vos images Docker

Éditez le fichier `.env` et remplacez `your-username` par votre nom d'utilisateur GitHub :

```env
TRANSCRIPTION_SERVICE_IMAGE=ghcr.io/votre-username/transcription-service:latest
AI_SERVICE_IMAGE=ghcr.io/votre-username/ai-service:latest
```

### 3. Authentification à GitHub Container Registry

Pour pouvoir télécharger les images depuis ghcr.io, vous devez vous authentifier :

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u votre-username --password-stdin
```

Ou si vous utilisez un Personal Access Token :

```bash
docker login ghcr.io -u votre-username -p votre-token
```

**Note :** Pour créer un Personal Access Token :
1. Allez sur GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Créez un nouveau token avec la permission `read:packages`
3. Utilisez ce token pour vous authentifier

### 4. Lancer les services

Une fois configuré, lancez simplement :

```bash
cd Projet_Dev-ops
docker compose up -d
```

Les images seront téléchargées automatiquement depuis GitHub Container Registry.

## Workflow GitHub Actions

Le workflow `build-and-push-transcription.yml` se trouve à la racine du repo dans `.github/workflows/`. Il se déclenche automatiquement :
- **Push sur main/master** : Construit et pousse les images avec le tag `latest`
- **Pull Request** : Construit les images mais ne les pousse pas (pour les tests)
- **Workflow Dispatch** : Permet de construire manuellement avec un tag personnalisé

### Déclencher manuellement le workflow

1. Allez sur l'onglet "Actions" de votre dépôt GitHub
2. Sélectionnez "Build and Push Transcription Services"
3. Cliquez sur "Run workflow"
4. Optionnellement, spécifiez un tag personnalisé (par défaut : `latest`)

### Tags des images

Les images sont taguées automatiquement :
- `latest` : Pour les pushes sur main/master
- `{branch}-{sha}` : Pour les autres branches
- `pr-{number}-{sha}` : Pour les pull requests (pas poussées)
- Tag personnalisé : Lors d'un workflow dispatch manuel

## Avantages

- ✅ Plus besoin de construire localement (gain de temps)
- ✅ Images toujours à jour avec le code sur GitHub
- ✅ Cache Docker optimisé pour des builds plus rapides
- ✅ Multi-architecture (linux/amd64, linux/arm64)

## Résolution de problèmes

### Erreur : "unauthorized: authentication required"

Vérifiez que vous êtes bien authentifié :

```bash
docker login ghcr.io
```

### Erreur : "pull access denied"

Vérifiez que :
1. Les images existent bien dans votre GitHub Container Registry
2. Le workflow a bien été exécuté au moins une fois
3. Vous utilisez le bon nom d'utilisateur dans le `.env`

### Reconstruire les images

Pour forcer la reconstruction des images, déclenchez manuellement le workflow depuis l'interface GitHub Actions.


