import asyncio
from fastapi import FastAPI, Form, UploadFile, BackgroundTasks
from pathlib import Path
import shutil
from concurrent.futures import ThreadPoolExecutor
from fastapi import BackgroundTasks
import os
import json
import whisperx
from pyannote.audio import Model, Pipeline
import torch
from Transcription_AI import JSON_PATH
from Transcription_AI import start_model 
from pydub import AudioSegment
import httpx
import requests
from io import BytesIO

# Bloquer les proxys
os.environ['NO_PROXY'] = 'localhost,127.0.0.1'
os.environ['no_proxy'] = 'localhost,127.0.0.1'

executor = ThreadPoolExecutor(max_workers=4)  # Limite le nombre de threads pour le traitement en parallèle


app = FastAPI() #On définit le nom de l'API pour pouvoir la démarrer avec uvicorn
AUDIO_DIR = Path("./Reunions/ID/") #Dossier où seront stockés les fichiers audio uploadés
AUDIO_DIR.mkdir(parents=True, exist_ok=True) # crée le dossier s'il n'existe pas

#Définition CPU ou GPU
if torch.backends.mps.is_available():
    print("GPU MPS détecté — WhisperX ne le supporte pas encore, utilisation CPU à la place.")
    device = "cpu"
elif torch.cuda.is_available(): #Utilisation GPU Nvidia
    device = "cuda"
else: #Si pas de GPU utilisation CPU
    device = "cpu"

#Chargement du modèle WhisperX
compute_type = "int8" # arranger en fonction de la puissance de calcul possédé
whisperx_model = whisperx.load_model("small", device, compute_type=compute_type)

#Diarization via Pyannote-audio
# Authentification Hugging Face (nécessaire pour accéder à certains modèles)
YOUR_AUTH_TOKEN = "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"  # ou via variable d’environnement HF_TOKEN
Pyannote_model = Model.from_pretrained("pyannote/embedding", 
                              use_auth_token=YOUR_AUTH_TOKEN)
diarization_pipeline = Pipeline.from_pretrained(
    "pyannote/speaker-diarization-3.1", #Utiliser si GPU ou si on veut un modèle encore plus précis mais faut aller sur le lien : https://huggingface.co/pyannote/speaker-diarization-community-1￼ pour accepter les conditions et faire en sorte que notre token ait accès à ce modèle
    use_auth_token=YOUR_AUTH_TOKEN) #Générer son token sur : https://huggingface.co/

# file d'attente globale
queue = asyncio.Queue()


@app.post("/transcribe/") #async permet d'utiliser await dans la fonction et de ne pas bloquer l'API et d'effectuer plusieurs fois la tâche en parallèle pour gérer plusieurs requêtes
async def upload_audio(file: UploadFile, ID_reunion: str, background_tasks: BackgroundTasks): #, ID_reunion: int):
    """Réceptionne un chunk audio (ex: 1min30)"""
    print(f"📨 Réception du fichier {file.filename} pour la réunion {ID_reunion}...")
    save_ID_reunion = ID_reunion
    save_filename = file.filename
    one_audio_save_path = AUDIO_DIR / f"{ID_reunion}" / "AUDIO" / "UPLOAD" / f"{file.filename.split('.')[0]}_reu_{ID_reunion}.mp3"  # crée un chemin unique pour chaque fichier uploadé en fonction de l'ID de la réunion et du nom du fichier
    # Crée tous les dossiers parents si nécessaire
    one_audio_save_path.parent.mkdir(parents=True, exist_ok=True)

    async def save_file():
        with one_audio_save_path.open("wb") as f: #On ouvre le fichier en mode écriture binaire pour flatter le fichier audio
            while chunk := await file.read(1024*1024): # lit le fichier par chunks de 1MB
                f.write(chunk)    
        print(f"💾 Fichier {file.filename} sauvegardé à {one_audio_save_path}")
        merged_audio_path = AUDIO_DIR / f"{ID_reunion}" / "AUDIO" / "MERGED" 
        merged_audio_path.mkdir(parents=True, exist_ok=True) 
        merged_audio = merged_audio_path / f"merged_reu_{ID_reunion}.mp3"

        # Gérer la fusion progressive
        if not merged_audio.exists():
        # Premier fichier → on ne fusionne pas
            shutil.copy(one_audio_save_path, merged_audio)
        else:
            # Fusion du dernier fichier fusionné avec le nouveau
            merged_audio = await merge_audio_files(
                [merged_audio, one_audio_save_path],
                merged_audio, save_ID_reunion
            )
            
        
        await queue.put((str(one_audio_save_path), save_ID_reunion , save_filename)) #envoie le chemin du fichier et l'ID de la réunion à la file d'attente
    
    async def merge_audio_files(file_paths, output_path, id_reunion): # Fusionne plusieurs fichiers audio en un seul
        print(f"🔀 Fusion des fichiers audio en {output_path}...")
        merged = AudioSegment.empty()

        for path in sorted(file_paths):  # tri si nécessaire
            merged += AudioSegment.from_mp3(path)

        merged.export(output_path, format="mp3")
        print("[INFO] Envoi du fichier audio merged")
        
        #########Envoi du fichier audio final ##############
        with open(output_path, "rb") as f:
            #audio_bytes = f.read()
            files = {'file': ('merged.mp3', f, 'audio/mpeg')}
            transcription_service_url = os.getenv("TRANSCRIPTION_SERVICE_URL", "http://transcription-service:8082")
            url = f"{transcription_service_url}/api/transcription/{id_reunion}/save_record_file"
            
            try:
                response = requests.post(url, files=files)
                response.raise_for_status()
                print(f"[INFO] Segments envoyés avec succès pour la réunion {ID_reunion}")
            except requests.RequestException as e:
                print(f"[ERROR] Échec de l'envoi des segments : {e}")
                print(f"[ERROR] Réponse du serveur : {response.text if 'response' in locals() else 'Pas de réponse'}")

        
        return output_path

    background_tasks.add_task(save_file) # Sauvegarde le fichier en arrière-plan pour ne pas bloquer la réponse à l'utilisateur
    return {"status": "queued", "file": file.filename}



async def worker():
    """ Traite un fichier à la fois issu de la file d'attente """
    loop = asyncio.get_running_loop()    
    while True:
        print("⏳ En attente de fichiers à traiter...")
        one_audio_save_path, ID_reunion, filename = await queue.get() # attend un fichier dans la file d'attente qui est récupéré par upload_audio lors du queue.put      
        print(f"🎧 Traitement de {one_audio_save_path} pour reunion {ID_reunion}...")
        try:
             # start_model s'exécute dans un thread séparé pour empêcher le blocage de l'event loop et donc de la connexion client-serveur
            await loop.run_in_executor(executor, start_model, whisperx_model, Pyannote_model, device , diarization_pipeline, one_audio_save_path, ID_reunion, filename) #path est connu par executor comme argument à la fonction
            #start_model(path)  # ta fonction adaptée en async
        except Exception as e:
            print(f"❌ Erreur de transcription {one_audio_save_path}: {e}")
        finally:
            print(f"✅ Transcription terminée pour {one_audio_save_path}")
            queue.task_done()
        

    

@app.on_event("startup")
async def startup_event():
    """Lancé automatiquement quand l'API démarre"""
    print("🚀 Démarrage du service de transcription...")
    asyncio.create_task(worker())

@app.on_event("shutdown")
async def shutdown_event():
    """Lancé automatiquement quand l'API s'arrête"""
    print("🛑 Arrêt du service de transcription...")
    await queue.join()  # Attendre que la file d'attente soit vide avant de fermer