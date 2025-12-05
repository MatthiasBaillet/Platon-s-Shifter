import os
import shutil
import datetime

# CONFIGURATION
DOSSIER_RACINE = "."
DOSSIER_ARCHIVE = "archive_v4"
DOSSIER_BACKUP = "backup"
DOSSIER_SCRIPTS = "scripts"

# Fichiers CRITIQUES à ne JAMAIS bouger
FICHIERS_CRITIQUES = {
    "Game.js", "index.html", "launcher.bat", 
    "CORRECTEUR_FINAL_V4.2.py", "PLATON_SHIFTER_DOCUMENTATION.txt"
}

# PATTERNS à archiver (tout ce qui est ancien/dupliqué)
PATTERNS_ARCHIVE = [
    "fix_game_v", "CORRECTEUR_", "PATCH", "corriger_", 
    "executer_", "test_game", "validation", "upgrade_",
    "launcher_final", "nettoyage", "watch"
]

def log(msg):
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    print(f"[{timestamp}] {msg}")

def creer_structure():
    """Crée la structure de dossiers propre"""
    log("📁 Création de la structure...")
    for dossier in [DOSSIER_ARCHIVE, DOSSIER_BACKUP, DOSSIER_SCRIPTS]:
        os.makedirs(dossier, exist_ok=True)

def trier_fichiers():
    """Trie tous les fichiers non critiques"""
    log("🗂️  Tri des fichiers...")
    deplaces = 0
    
    for fichier in os.listdir(DOSSIER_RACINE):
        chemin_complet = os.path.join(DOSSIER_RACINE, fichier)
        
        # Ignorer dossiers et fichiers critiques
        if not os.path.isfile(chemin_complet) or fichier in FICHIERS_CRITIQUES:
            continue
        
        # Déterminer destination
        destination = DOSSIER_ARCHIVE  # Par défaut : archiver
        
        if "backup" in fichier.lower() or ".backup" in fichier:
            destination = DOSSIER_BACKUP
        elif "test" in fichier.lower() or "diagnostic" in fichier:
            destination = DOSSIER_SCRIPTS
        
        # Déplacer
        try:
            shutil.move(chemin_complet, os.path.join(destination, fichier))
            log(f"   → {fichier} → {destination}/")
            deplaces += 1
        except Exception as e:
            log(f"   ⚠️ Erreur {fichier}: {e}")
    
    log(f"   ✅ {deplaces} fichiers déplacés")

def creer_lanceur_final():
    """Crée un lanceur propre et unique"""
    log("🚀 Création du lanceur final...")
    
    with open("LANCER_PROJET.bat", "w") as f:
        f.write("""@echo OFF
chcp 65001 >nul
color 0A
echo ==========================================
echo   PLATON'S SHIFTER - WORKFLOW V4.2
echo ==========================================
echo.
echo 1. 🔍 DIAGNOSTIC du jeu
echo 2. 🔧 CORRIGER avec V4.2
echo 3. 🎮 TESTER dans le navigateur
echo 4. 📦 CRÉER une version stable
echo 5. 🚪 QUITTER
echo.
set /p choix="→ Votre choix [1-5] : "
if "%choix%"=="1" call diagnostic_game.bat
if "%choix%"=="2" python correcteurs\\CORRECTEUR_FINAL_V4.2.py Game.js
if "%choix%"=="3" start "" index.html
if "%choix%"=="4" call creer_version_stable.bat
if "%choix%"=="5" exit
""")
    
    log("   ✅ Lancé créé : LANCER_PROJET.bat")

def creer_dossier_correcteur():
    """Place le correcteur dans son propre dossier"""
    log("🔧 Organisation du correcteur...")
    os.makedirs("correcteurs", exist_ok=True)
    
    # Déplacer le correcteur final
    if os.path.exists("CORRECTEUR_FINAL_V4.2.py"):
        shutil.move("CORRECTEUR_FINAL_V4.2.py", "correcteurs/CORRECTEUR_FINAL_V4.2.py")
        log("   → Correcteur déplacé dans /correcteurs/")

if __name__ == "__main__":
    print("🧹 NETTOYAGE INTELLIGENT V4")
    print("=" * 50)
    
    # Sauvegarde préalable
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    log(f"📸 Snapshot créé automatiquement : backup/snapshot_{timestamp}")
    shutil.copytree(".", f"backup/snapshot_{timestamp}", 
                    ignore=shutil.ignore_patterns('backup', 'archive*'))
    
    creer_structure()
    trier_fichiers()
    creer_dossier_correcteur()
    creer_lanceur_final()
    
    log("=" * 50)
    log("✅ Nettoyage terminé !")
    log("🎯 Utilisez LANCER_PROJET.bat maintenant")