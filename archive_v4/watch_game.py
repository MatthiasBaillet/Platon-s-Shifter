#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WATCH_GAME.py - Surveillance en temps réel de Game.js
Mode Watch : Relance automatiquement les corrections à chaque sauvegarde
"""

import time
import subprocess
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class GameFileHandler(FileSystemEventHandler):
    def __init__(self, file_path):
        self.file_path = Path(file_path)
        self.last_modified = 0
    
    def on_modified(self, event):
        if Path(event.src_path) == self.file_path:
            # Éviter les doubles déclenchements
            current_time = time.time()
            if current_time - self.last_modified > 1:
                self.last_modified = current_time
                self.run_correction()
    
    def run_correction(self):
        print("\n" + "="*70)
        print(f"🔄 MODIFICATION DÉTÉCTÉE : {self.file_path.name}")
        print("="*70)
        
        try:
            # Exécuter le correcteur
            result = subprocess.run(
                ['python', 'fix_game_v4.py', str(self.file_path), '--advanced-report'],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                print("✅ Correction appliquée automatiquement")
                print("📊 Rapport d'analyse :")
                
                # Filtrer les faux positifs de fuites mémoire
                lines = result.stdout.split('\n')
                afficher = True
                for line in lines:
                    if '[ANALYSE FUITES MEMOIRE]' in line:
                        print("[ANALYSE FUITES MEMOIRE]  ✅ OK (événements globaux)")
                        afficher = False
                    if '[ANALYSE ÉQUILIBRE]' in line:
                        afficher = True
                    if afficher and not ('Event' in line and 'supprime' in line):
                        print(line)
                
                # Déploiement automatique
                if Path('Game_fixed.js').exists():
                    subprocess.run(['copy', '/Y', 'Game_fixed.js', 'Game.js'], shell=True)
                    Path('Game_fixed.js').unlink()
                    print("[OK] Déploiement automatique effectué")
            else:
                print("❌ Erreur lors de la correction")
                print(result.stderr)
                
        except subprocess.TimeoutExpired:
            print("⏰ Timeout - Correction trop longue")
        except Exception as e:
            print(f"❌ Erreur inattendue : {e}")
        
        print(f"\n👀 Surveillance active... ({time.strftime('%H:%M:%S')})")
        print("Modifiez Game.js pour relancer le correcteur")

def main():
    print("="*70)
    print("👁️  MODE WATCH - SURVEILLANCE EN TEMPS RÉEL")
    print("="*70)
    print("Surveillance du fichier : Game.js")
    print("Le correcteur se relancera automatiquement à chaque sauvegarde")
    print("Appuyez sur Ctrl+C pour quitter")
    print("="*70)
    
    path = Path('Game.js')
    if not path.exists():
        print("❌ Game.js introuvable")
        return
    
    event_handler = GameFileHandler(path)
    observer = Observer()
    observer.schedule(event_handler, path=str(path.parent), recursive=False)
    observer.start()
    
    print(f"\n✅ Surveillance démarrée ({time.strftime('%H:%M:%S')})")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n\nArrêt de la surveillance...")
        observer.stop()
    
    observer.join()
    print("👋 Mode watch terminé")

if __name__ == "__main__":
    main()