import json
import pickle
import torch
import whisperx
import gc
from pyannote.audio import Model, Inference, Pipeline
import pandas as pd
import numpy as np
import importlib.util
import os
from pathlib import Path
from scipy.spatial.distance import cosine
import requests

# Bloquer les proxys
os.environ['NO_PROXY'] = 'localhost,127.0.0.1'
os.environ['no_proxy'] = 'localhost,127.0.0.1'

#Supprimer les warnings inutiles
import warnings
warnings.filterwarnings("ignore")

JSON_PATH = ""
PATH = Path("./Reunions/ID/")  #Dossier où seront stockés les fichiers json de transcription
PATH.mkdir(parents=True, exist_ok=True)  # crée le dossier s'il n'existe pas
# Authentification Hugging Face (nécessaire pour accéder à certains modèles)
YOUR_AUTH_TOKEN = "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"  # ou via variable d’environnement HF_TOKEN
# batch_size = 16 # arranger en fonction de la puissance de calcul possédé
batch_size = 4 
compute_type = "int8" # arranger en fonction de la puissance de calcul possédé
EMBED_SIM_THRESHOLD = 0.55  # seuil de similarité (0 à 1) # cosine similarity threshold (0..1) pour considérer un match

# Ecrire la transcription segmentée par intervenant dans un fichier json
def transcription_to_json(segs, ID_reunion):
   
    print("[INFO] Préparation à l'envoi des segments vers la BDD...")

    transcription_reu_path = PATH / f"{ID_reunion}" / "JSON" / f"transcription_reu_{ID_reunion}.json"
    transcription_reu_path.parent.mkdir(parents=True, exist_ok=True)  # crée le dossier s'il n'existe pas
    global JSON_PATH
    JSON_PATH = transcription_reu_path

    speaker_seg = {}


    if not segs:
        print("[WARN] Pas de segments")
    else:
        print(f"[INFO] {len(segs)} segments") #renvoie le nbre de segments présents dans result
        
        #async def send_json():   
        for s in segs:
            speaker_seg = {
                    "speaker": s.get("speaker", "SPEAKER_XX"), #Soit numéro SPEAKER SOIT INCONNU
                    "start": s.get("start", 0.0), # récupère le timestamp de début du segment sinon met 0.0 par défaut
                    "end": s.get("end", 0.0),  # récupère le timestamp de fin du segment sinon met 0.0 par défaut
                    "text": s.get("text","").strip()#ajoute le texte (en supprimant les blancs avant et après le texte avec .strip()) du segment à la liste du speaker selon son identifiant (speaker_00, speaker_01, ...)   
            } 
            print(f"[INFO] Envoi segment : {speaker_seg}")

            transcription_service_url = os.getenv("TRANSCRIPTION_SERVICE_URL", "http://transcription-service:8082")
            url = f"{transcription_service_url}/api/transcription/{ID_reunion}/segment_to_bdd"
            try:
                response = requests.post(url, json=speaker_seg, headers={'Content-Type': 'application/json'})
                print(f"[DEBUG] Status code: {response.status_code}")
                print(f"[DEBUG] Response: {response.text}")
                response.raise_for_status()
                print(f"[INFO] Segments envoyés avec succès pour la réunion {ID_reunion}")
            except requests.RequestException as e:
                print(f"[ERROR] Échec de l'envoi des segments : {e}")
                if hasattr(e, 'response') and e.response is not None:
                    print(f"[ERROR] Détails de l'erreur : {e.response.text}")



    """Partie commentée : ancienne version de transcription_to_json qui écrivait tout dans un fichier JSON local"""   
"""Met à jour le fichier JSON avec les nouveaux segments.
        Fusionne les segments des speakers déjà présents.
    
        Args:
            JSON_PATH (str): chemin du fichier transcription.json
            new_segments_by_speaker (dict): {speaker_id: [segments]}
        """
    
        # Charger le contenu du fichier json si existant 
"""if os.path.exists(transcription_reu_path):
            with open(transcription_reu_path, "r", encoding="utf-8") as f:
                try:
                    data = json.load(f)
                except json.JSONDecodeError:
                    print("[WARN] JSON corrompu ou vide, initialisation d’un nouveau fichier.")
                    data = {}
        else:
            data = {}

        by_speaker = {}

        for s in segs:
            sp = s.get("speaker", "SPEAKER_XX") #Soit numéro SPEAKER SOIT INCONNU
            by_speaker.setdefault(sp, []).append({
                "Start": s.get("start", 0.0), # récupère le timestamp de début du segment sinon met 0.0 par défaut
                "End": s.get("end", 0.0),  # récupère le timestamp de fin du segment sinon met 0.0 par défaut
                "text": s.get("text","").strip()}) #ajoute le texte (en supprimant les blancs avant et après le texte avec .strip()) du segment à la liste du speaker selon son identifiant (speaker_00, speaker_01, ...)   
   
        #Vérification présence speakers dans le fichier JSON existant
        for spk, segments in by_speaker.items():
            if spk in data:
                # append sans doublon
                existing = data[spk]
                # éviter les segments déjà présents (ex : même timestamp)
                existing_starts = {seg["start"] for seg in existing if "start" in seg} #filtrage des timestamps des segments déjà présents
                new_segs = [seg for seg in segments if seg.get("start") not in existing_starts] #ne garder que les segments dont le timestamp de début n'est pas déjà dans existing_starts et donc qui n'est pas un segment doublon
                data[spk].extend(new_segs) #ajoute les nouveaux segments  à la liste des segments existants pour ce speaker
            else:
                # nouveau speaker → ajout direct
                data[spk] = segments
            
            # Affichage console
            print(f"[INFO] {spk} a {len(segments)} segments")
            for seg in segments:
                print(f"  - [{seg['Start']:.2f}s --> {seg['End']:.2f}s] {'Speaker: ' + spk} {seg['text']}")

        # écrase le fichier à chaque run pour garder un JSON propre
        with open(transcription_reu_path, "w", encoding="utf-8") as f: #Ecrit à la suire dans le fichier transcription.json
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        #for seg in data[spk]: #spk correspond aux speakers dans data. Ici, on parcourt chaque segment de chaque speaker
        #     speaker_seg.append(seg)
        #     print("Segments du speaker envoyés vers la bdd")
        #     print(f"  - [{speaker_seg['Start']:.2f}s --> {speaker_seg['End']:.2f}s] {'Speaker: ' + spk} {speaker_seg['text']}")
            ####Envoi segment par segment vers la bdd#######

        print(f"[INFO] Fichier JSON mis à jour ({transcription_reu_path}) avec {len(by_speaker)} speakers.")"""
    
#Télécharger et sauvegarder le modèle WhisperX en local (à exécuter une seule fois)   
#def save_whisperx_model_to_localhost():
#    model = whisperx.load_model("large-v2", device, compute_type=compute_type)

# Charger le Modèle WhisperX en local
def start_model(whisperx_model, Pyannote_model, device, diarization_pipeline, audio_file, ID_reunion, filename):
    transcribe_audio_file(Pyannote_model, whisperx_model, device, diarization_pipeline, audio_file, ID_reunion, filename)

def load_speaker_memory(ID_reunion):
    """Retourne dict {canonical_speaker_id: np.ndarray}"""
    spk_memory = PATH / f"{ID_reunion}" / "SPEAKERS" / f"speaker_memory.pkl"
    spk_memory.parent.mkdir(parents=True, exist_ok=True)  # crée le dossier s'il n'existe pas
    if (spk_memory).exists():
        with open(spk_memory, "rb") as f:
            return pickle.load(f)
    return {}

def save_speaker_memory(memory: dict, ID_reunion):
    spk_memory = PATH / f"{ID_reunion}" / "SPEAKERS" / f"speaker_memory.pkl"
    spk_memory.parent.mkdir(parents=True, exist_ok=True)  # crée le dossier s'il n'existe pas
    with open(spk_memory, "wb") as f:
        pickle.dump(memory, f)

def embedding_diarization(segs, Pyannote_model, device, audio_file):

    # Extrait un embedding pour chaque segment de `segs`,
    # les ajoute embedding list et compare avec les embeddings précédents
    
    sr = 16000 # fréquence d'échantillonnage requise par pyannote-audio inference

   
    dev = torch.device(device) if isinstance(device, str) else device
    inference = Inference(Pyannote_model, device=dev)  # charger le waveform (numpy 1D float32)
    
    audio = whisperx.load_audio(audio_file)  # lit le fichier .mp3 / .wav et renvoie un tableau NumPy d’échantillons audio interprétables pour les calcus suivants
    audio_len = len(audio)


    embedding = {}  # speaker -> list of 1D numpy vectors
    target_dim = None
    skipped = 0    # extrait les embeddings pour chaque segment

    for s in segs:
        sp = s.get("speaker", "SPEAKER_00") #On récupére le locuteur
        try:
            start = float(s.get("start", 0.0))
            end = float(s.get("end", 0.0))
        except Exception:
            continue
        if end <= start:
            continue
        start_sample = int(max(0, round(start * sr)))
        end_sample = int(min(audio_len, round(end * sr)))
        if end_sample <= start_sample:
            continue
        chunk = audio[start_sample:end_sample]
        if chunk.size == 0:
            continue
        wave = torch.from_numpy(chunk).float().unsqueeze(0)  # shape (1, n_samples) = (channels, time)
        input_waveform = {"waveform": wave, "sample_rate": sr}
         # calcul de l'embedding
        try:
            emb = inference(input_waveform)
        except Exception as e:
            print(f"[WARN] Inference failed for segment {start:.2f}-{end:.2f}: {e}")
            skipped += 1
            continue

        emb_np= np.asarray(emb)
        
        # Normaliser la forme en vecteur 1D :
        if emb_np.ndim == 1:
            vec = emb_np
        elif emb_np.ndim == 2:
            # cas fréquent : (T, D) => moyenne sur l'axe temporel -> (D,)
            # ou (1, D) -> squeeze
            if emb_np.shape[0] == 1:
                vec = emb_np.reshape(-1)
            elif emb_np.shape[1] == 1:
                vec = emb_np.reshape(-1)
            else:
                vec = emb_np.mean(axis=0)
        else:
            # fallback : aplatir (attention aux incohérences de dimension)
            vec = emb_np.reshape(-1)

        # normalisation L2
        norm = np.linalg.norm(vec)
        if norm > 0:
            vec = vec / norm

        # définir la dimension cible à la première embedding valide
        if target_dim is None:
            target_dim = vec.size

        # si dimension différente -> skip (log)
        if vec.size != target_dim:
            print(f"[WARN] Ignoring embedding with shape {vec.shape} (expected {target_dim}) for segment {start:.2f}-{end:.2f}")
            skipped += 1
            continue

        embedding.setdefault(sp, []).append(vec)

    # Calcul des embeddings moyens par locuteur
    mean_embs = {}
    for sp, embs in embedding.items():
        if not embs:
            continue
        mat = np.stack(embs, axis=0)  # OK : toutes les lignes ont la même taille
        mean = mat.mean(axis=0)
        # normaliser de nouveau
        n = np.linalg.norm(mean)
        if n > 0:
            mean = mean / n
        mean_embs[sp] = mean

    if skipped:
        print(f"[INFO] embeddings skipped: {skipped}")
    return mean_embs

#Associe les nouveaux locuteurs à ceux connus via similarité cosinus.
#Crée un nouvel ID si aucun match n’est trouvé.
def match_and_merge_memory(new_mean_embs: dict, memory: dict):
    """
    new_mean_embs : {local_id -> np.ndarray}
    memory : {speaker_id -> np.ndarray}
    
    Retourne : (mapping local->speaker_id, mémoire mise à jour)
    """

    mapping = {}

    # Si pas de mémoire existante, initialiser avec les premiers embeddings
    if not memory:
        print("[INFO] Premier fichier - initialisation de la mémoire des speakers")
        for i, (local_sp, vec) in enumerate(new_mean_embs.items()):
            speaker_id = f"SPEAKER_{i:02d}"
            memory[speaker_id] = vec
            mapping[local_sp] = speaker_id
        return mapping, memory

    for local_sp, vec in new_mean_embs.items():
        vec = np.asarray(vec)
        
        # Chercher le locuteur connu le plus proche
        best_id, best_sim = None, -1.0
        for spk_id, mem_vec in memory.items():
            sim = 1 - cosine(vec, mem_vec)
            if sim > best_sim:
                best_sim = sim
                best_id = spk_id

        # Vérifier si la similarité dépasse le seuil
        if best_sim >= EMBED_SIM_THRESHOLD:
            print(f"[INFO] Match trouvé pour {local_sp} -> {best_id} (sim={best_sim:.3f})")
            mapping[local_sp] = best_id
            # on met à jour le vecteur moyen (simple moyenne)
            memory[best_id] = (memory[best_id] + vec) / 2.0
        else:
            # pas de match, créer un nouveau speaker
            print(f"[INFO] Nouveau locuteur détecté pour {local_sp} (best sim={best_sim:.3f})")
            new_id = f"SPEAKER_{len(memory):02d}"
            mapping[local_sp] = new_id
            memory[new_id] = vec

    return mapping, memory

def remap_segments_speakers(segs, mapping: dict):
    """
    Réaffecte les labels 'speaker' dans la liste de segments selon mapping local->canonical.
    """
    for s in segs:
        local = s.get("speaker")
        if local in mapping:
            s["speaker"] = mapping[local]
    return segs

def transcribe_audio_file(Pyannote_model, whisperx_model, device, diarization_pipeline, audio_file, ID_reunion, filename):
    audio = whisperx.load_audio(audio_file)
    result = whisperx_model.transcribe(audio, batch_size=batch_size)
    print(result["segments"]) # before alignment
    #Align whisper output
    model_a, metadata = whisperx.load_align_model(language_code=result["language"], device=device) #WhisperX détecte automatiquement la langue avant le traitement donc on la fournit au modèle d'alignement via result["language"]
    result = whisperx.align(result["segments"], model_a, metadata, audio, device, return_char_alignments=False)
    diarisation(audio_file, diarization_pipeline, Pyannote_model, device, result, ID_reunion, filename)

def diarisation(audio_file, diarization_pipeline, Pyannote_model, device, result, ID_reunion, filename):

    diarization = diarization_pipeline(audio_file)
    #print(diarization)
    # diarization = ton objet Pyannote
    #On récupère les valeurs de la diarization pour en faire un tableau compréhensible par whisperx pour la partie result
    diarize_df = pd.DataFrame([
        {"start": segment.start, "end": segment.end, "speaker": label.split()[-1]} # garde seulement SPEAKER_00}
        for segment, _ , label in diarization.itertracks(yield_label=True) # "_" permet de faire en sorte de récupérer la colonne track A --> AZ ect sans avoir à l'utiliser
    ])
    result = whisperx.assign_word_speakers(diarize_df, result) 

    #print(result["segments"]) # segments are now assigned speaker IDs
    # extraire embeddings moyens par local speaker (liste de segments fournie)
    mean_embs = embedding_diarization(result["segments"],Pyannote_model, device, audio_file)
    if mean_embs and len(mean_embs) > 0:

        # Associer les nouveaux embeddings aux locuteurs connus
        mapping, memory = match_and_merge_memory(mean_embs, load_speaker_memory(ID_reunion))

        # Sauvegarder la mémoire mise à jour
        save_speaker_memory(memory, ID_reunion)

        print(f"[INFO] Mémoire des locuteurs mise à jour avec {len(memory)} locuteurs connus.")
        # Réaffecter les labels de locuteurs dans les segments
        result["segments"] = remap_segments_speakers(result["segments"], mapping)

        transcription_to_json(result["segments"], ID_reunion)
    else:
        print("[WARN] Aucun embedding moyen extrait; mémoire non mise à jour.")

   


# Utilisation
def main(audio_file):
    #for audio_file in [audio_file_1, audio_file_2]:
    #    print(f"Processing file: {audio_file}")
    #start_model(Whisper_model, device, diarization_pipeline, audio_file)
    return

#A l'exécution du script python donne à ce module la valeur name == "main" ce qui lance main().
if __name__ == "__main__":
    main()

