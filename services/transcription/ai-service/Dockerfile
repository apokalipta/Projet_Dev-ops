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

# Installer + upgrader pip et outils de build
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip cache purge

# Copier les fichiers de dépendances
COPY requirements.txt ./

# Installer torchcodec avant les autres dépendances pour éviter des conflits de versions
RUN python3 -m pip install --no-cache-dir torchcodec pydub && \
    pip cache purge

# Installer les dépendances avec nettoyage du cache après
RUN python3 -m pip install --no-cache-dir --timeout=300 -r requirements.txt && \
    pip cache purge && \
    find /usr/local/lib/python3.11 -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true && \
    find /usr/local/lib/python3.11 -type f -name "*.pyc" -delete && \
    find /usr/local/lib/python3.11 -type f -name "*.pyo" -delete

# Nettoyer les outils de build qui ne sont plus nécessaires après l'installation
RUN apt-get purge -y build-essential cmake && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . . 
#. (host) → . (container, qui est /AI_transcription_API à cause du WORKDIR)

# Définir la variable d'environnement PYTHONPATH pour inclure le répertoire de l'application
#ENV PYTHONPATH=/Transcription_AI

#Exposition du port et commande de lancement de l'API
EXPOSE 8000
CMD ["uvicorn", "AI_API:app", "--host", "0.0.0.0", "--port", "8000"]