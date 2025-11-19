FROM python:3.11

# Installer git
# ------------------------------
# Installer outils nécessaires
# ------------------------------

RUN apt-get update && \
    apt-get install -y \
        git \
        build-essential \
        cmake \
        python3-dev \
        ffmpeg \
        && rm -rf /var/lib/apt/lists/*
#Ce sont tous les paquets nécessaires pour faire tourner notre image docker sur l'architecture linux python:3.10.4
#rm -rf /var/lib/apt/lists/* supprimer le cache apt pour réduire la taille de l'image

# Direcitory de travail
WORKDIR /Transcription_AI

# Copier le dossier whisperX depuis le host vers le container
#COPY whisperx/ ./whisperX
#On copie le dossier whisperX dans le container pour pouvoir l'installer via le requirements.txt

# Installer + upgrader pip et installer torchcodec avant les autres dépendances pour éviter des conflits de versions
RUN python3 -m pip install --upgrade pip && pip install torchcodec && pip install pydub

# Copier les fichiers de dépendances
COPY requirements.txt ./
RUN python3 -m pip install -r requirements.txt

COPY . . 
#. (host) → . (container, qui est /AI_transcription_API à cause du WORKDIR)

# Définir la variable d'environnement PYTHONPATH pour inclure le répertoire de l'application
#ENV PYTHONPATH=/Transcription_AI

#Exposition du port et commande de lancement de l'API
EXPOSE 8000
CMD ["uvicorn", "AI_API:app", "--host", "0.0.0.0", "--port", "8000"]