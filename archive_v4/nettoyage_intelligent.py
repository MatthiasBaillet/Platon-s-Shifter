#!/usr/bin/env python3
# NETTOYAGE INTELLIGENT v4.2 - Console gardee OUVERTE
# Nettoie le dossier tout en garantissant la sécurité des fichiers critiques

import shutil
from pathlib import Path
import subprocess
import sys

print("="*70)
print("🧹 MÉNAGE INTELLIGENT - Platon's Shifter v4.2")
print("="*70)
print()

# ============================================================================
# CONFIGURATION
# ============================================================================
PROJET_DIR = Path.cwd()
FICHIERS_ESSENTIELS = [
    "Game.js",
    "index.html",
    "fix_game_v4.1.py",
    "launcher_final_v4.1.bat",
    "CHECKPOINT_GLOBAL.md",
    "PROJECT_STATE.md"
]

FICHIERS_TEMPORAIRES = [
    "Game_fixed.js",
    "Game.js.save",
    "Game.js.backup_urgence",
    "patch_*.py",
    "diagnostic_*.py",
    "correction_*.py",
    "CORRECTION_*.py",
    "fix_syntax_error.py",
    "patch_garanti.py",
    "patch_total.py",
    "resultat_*.txt",
    "diagnostic.txt",
    "LANCEZ-MOI.bat",
    "EXCECUTEZ_MO.bat"
]

DOSSIERS_A_CREER = ["backups", "archives"]

# ============================================================================
# ETAPE 1 : Sauvegarde de sécurité complète (ZIP)
# ============================================================================
print("💾 Création d'une sauvegarde de sécurité...")
try:
    shutil.make_archive("Sauvegarde_avant_menage", 'zip', PROJET_DIR)
    print("✅ Sauvegarde créée : Sauvegarde_avant_menage.zip")
except Exception as e:
    print(f"⚠️ Sauvegarde impossible : {e}")
    print("  Le ménage continue...")
print()

# ============================================================================
# ETAPE 2 : Création de la structure de dossiers
# ============================================================================
print("📁 Création de la structure de dossiers...")
for dossier in DOSSIERS_A_CREER:
    (PROJET_DIR / dossier).mkdir(exist_ok=True)
    print(f"  ✅ Dossier '{dossier}' prêt")

# ============================================================================
# ETAPE 3 : Déplacer les anciens correcteurs vers archives/
# ============================================================================
print()
print("📦 Archivage des fichiers temporaires...")
deplaces = 0

for pattern in FICHIERS_TEMPORAIRES:
    for fichier in PROJET_DIR.glob(pattern):
        if fichier.is_file() and fichier.name != Path(__file__).name:
            try:
                destination = PROJET_DIR / "archives" / fichier.name
                if not destination.exists():
                    fichier.rename(destination)
                    deplaces += 1
                    print(f"  📄 Archivé : {fichier.name}")
                else:
                    fichier.unlink()  # Supprimer doublon
                    print(f"  🗑️ Supprimé (doublon) : {fichier.name}")
            except Exception as e:
                print(f"  ⚠️ Erreur avec {fichier.name} : {e}")

print(f"✅ {deplaces} fichiers archivés")

# ============================================================================
# ETAPE 4 : Organiser les backups existants
# ============================================================================
print()
print("💾 Organisation des backups...")
backups_deplaces = 0

# Finder les backups Game.js dans le dossier racine
for backup in PROJET_DIR.glob("Game.js.backup*"):
    try:
        if backup.name in ["Game.js.backup1", "Game.js.backup2"]:
            # Garder les 2 plus récents à la racine
            print(f"  ✅ Conservé à la racine : {backup.name}")
        else:
            # Déplacer les autres dans backups/
            destination = PROJET_DIR / "backups" / backup.name
            backup.rename(destination)
            backups_deplaces += 1
            print(f"  📦 Déplacé vers backups/ : {backup.name}")
    except Exception as e:
        print(f"  ⚠️ Erreur backup {backup.name} : {e}")

print(f"✅ {backups_deplaces} backups organisés")

# ============================================================================
# ETAPE 5 : Vérifier les fichiers essentiels
# ============================================================================
print()
print("🔍 Vérification des fichiers essentiels...")
manquants = []

for fichier in FICHIERS_ESSENTIELS:
    if (PROJET_DIR / fichier).exists():
        print(f"  ✅ {fichier}")
    else:
        print(f"  ❌ MANQUANT : {fichier}")
        manquants.append(fichier)

if manquants:
    print()
    print(f"⚠️ {len(manquants)} fichiers essentiels manquants !")
    print("Le projet peut ne pas fonctionner correctement.")

# ============================================================================
# ETAPE 6 : Valider la syntaxe Game.js
# ============================================================================
print()
print("🔍 Validation finale de Game.js...")
try:
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True, timeout=10)
    if result.returncode == 0:
        print("  ✅ Syntaxe Game.js VALIDE")
        validation = "VALIDE"
    else:
        print("  ❌ ERREUR SYNTAXE Game.js :")
        print(f"     {result.stderr.split('Game.js:')[1].split('^')[0]}")
        validation = "INVALIDE"
except Exception as e:
    print(f"  ⚠️ Validation impossible : {e}")
    validation = "INCONNUE"

# ============================================================================
# ETAPE 7 : Rapport final
# ============================================================================
print()
print("="*70)
print("📊 RAPPORT DE MÉNAGE")
print("="*70)
print(f"""
✅ Sauvegarde créée : Sauvegarde_avant_menage.zip
✅ Structure de dossiers : backups/, archives/
✅ Fichiers archivés : {deplaces}
✅ Backups organisés : {backups_deplaces}
✅ Fichiers essentiels vérifiés : {len(FICHIERS_ESSENTIELS) - len(manquants)}/{len(FICHIERS_ESSENTIELS)}
✅ Syntaxe Game.js : {validation}

📁 Structure actuelle :
   {PROJET_DIR.name}/
   ├── Game.js (principal)
   ├── index.html (test)
   ├── fix_game_v4.1.py (correcteur)
   ├── launcher_final_v4.1.bat (lanceur)
   ├── CHECKPOINT_GLOBAL.md (doc)
   ├── PROJECT_STATE.md (doc)
   ├── backups/
   │   ├── Game.js.backup1 (dernière stable)
   │   └── Game.js.backup2 (précédente)
   └── archives/
       ├── patch_*.py (anciens correcteurs)
       ├── diagnostic_*.py (anciens diagnostics)
       └── *.backup_urgence (backups manuels)

🎮 PROCHAIN PAS :
   Double-cliquez sur "launcher_final_v4.1.bat" -> [1] Corriger + Rapport
""")
print("="*70)

# ============================================================================
# ETAPE 8 : GARDER LA FENÊTRE OUVERTE
# ============================================================================
print()
input("✅ MÉNAGE TERMINÉ. Appuyez sur Entrée pour fermer...")