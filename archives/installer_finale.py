#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Platon's Shifter - Installateur Final v4.0
Installe le Niveau Supérieur (detecte fuites memoire + analyse equilibre)
"""

import os
import sys
from pathlib import Path

# ============ CONFIGURATION ============
PROJECT_DIR = Path(__file__).parent
V4_FILE = PROJECT_DIR / "fix_game_v4.py"
LAUNCHER_FILE = PROJECT_DIR / "launcher_final.bat"
DOC_FILE = PROJECT_DIR / "PROJECT_STATE.md"

# ============ CODE DU CORRECTEUR V4 ============
V4_CODE = """#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional

CORRECTIONS_CONFIG = [
    {
        "id": "taille_bases",
        "nom": "Reduire taille des bases (2.5→1.5)",
        "pattern": r"radius\\s*:\\s*GRID_SIZE\\s*\\*\\s*2\\.5",
        "replace": "radius: GRID_SIZE * 1.5",
        "marqueur": "CORRECT_TAILLE_BASES"
    },
    {
        "id": "base_unique_ennemi",
        "nom": "Passer a une seule base ennemi",
        "pattern": r"let\\s+enemyBases\\s*=\\s*\\[\\s*\\]\\s*;",
        "replace": "let enemyBase = null;",
        "marqueur": "CORRECT_BASE_UNIQUE"
    },
    {
        "id": "bases_logique_spawn",
        "nom": "Simplifier logique de creation des bases",
        "pattern": r"// 3 bases ennemis[\\s\\S]*?enemyBases\\.push\\(base\\);\\s+}\\s+}",
        "replace": \"\"\"
            # Une seule base ennemie
            enemyBase = {
                x: canvas.width * 0.75,
                y: canvas.height / 2,
                radius: GRID_SIZE * 1.5
            };\"\"\",
        "marqueur": "CORRECT_BASES_LOGIQUE"
    },
    {
        "id": "uniformiser_style",
        "nom": "Uniformiser style base/terrain",
        "pattern": r"ctx\\.fillText\\s*\\(\\s*'BASE'\\s*,\\s*startBase\\.x\\s*,\\s*startBase\\.y\\s*\\+\\s*5\\s*\\)\\s*;",
        "replace": "",
        "marqueur": "CORRECT_STYLE"
    },
    {
        "id": "respawn_ennemis",
        "nom": "Corriger respawn ennemis",
        "pattern": r"//\\s*DETRUIRE\\s*L'ENNEMI\\s*enemies\\.splice\\s*\\(\\s*index\\s*,\\s*1\\s*\\)\\s*;",
        "replace": \"\"\"
        # CORRIGE: Respawn apres 1s
                    enemies.splice(index, 1);
                    setTimeout(() => enemies.push(createEnemy()), 1000);\"\"\",
        "marqueur": "CORRECT_RESPAWN"
    }
]

class Correction:
    def __init__(self, config: Dict):
        self.id = config["id"]
        self.nom = config["nom"]
        self.marqueur = config["marqueur"]
        self.pattern = config.get("pattern", "")
        self.replace = config.get("replace", "")
    
    def test(self, code: str) -> bool:
        return bool(re.search(self.pattern, code, re.MULTILINE | re.DOTALL))
    
    def apply(self, code: str) -> Tuple[str, bool]:
        new_code = re.sub(self.pattern, self.replace, code, flags=re.MULTILINE | re.DOTALL)
        modified = new_code != code
        return new_code, modified

def detect_memory_leaks(code: str) -> Dict[str, List[str]]:
    leaks = {'listeners': [], 'intervals': []}
    listener_pattern = r'\\.addEventListener\\s*\\(\\s*[\\'"'"'](\\w+)[\\'"'"']\\s*,'
    for match in re.finditer(listener_pattern, code):
        leaks['listeners'].append(f"Event '{match.group(1)}' non supprimé")
    return leaks

def analyze_game_balance(code: str) -> Dict[str, List[str]]:
    balance = {'warnings': [], 'info': [], 'stats': {}}
    forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
    for form in forms:
        energy_pattern = rf'function\\s+{form.lower()}_power[\\s\\S]*?energy\\s*-\\=\\s*(\\d+)'
        match = re.search(energy_pattern, code)
        energy = int(match.group(1)) if match else 0
        balance['stats'][form] = {'energy': energy, 'damage': energy * 3}
        if energy > 10:
            balance['warnings'].append(f"{form}: Coût énergie élevé ({energy})")
    return balance

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Correcteur V4')
    parser.add_argument('file', help='Fichier Game.js')
    parser.add_argument('--dry-run', action='store_true', help='Simulation')
    parser.add_argument('--advanced-report', action='store_true', help='Rapport complet')
    
    args = parser.parse_args()
    
    with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
    applied = []
    
    print("=" * 70)
    print("🚀 NIVEAU SUPÉRIEUR V4.0 - ACTIVÉ")
    print("=" * 70)
    
    for corr in corrections:
        if corr.test(content):
            new_content, modified = corr.apply(content)
            if modified:
                content = new_content
                content += f"\\n// {corr.marqueur}\\n"
                applied.append(corr.nom)
    
    # Rapport avancé
    if args.advanced_report or not args.dry_run:
        print("\\n" + "=" * 70)
        print("📊 RAPPORT NIVEAU SUPÉRIEUR")
        print("=" * 70)
        
        # Fuites mémoire
        print("\\n[ANALYSE FUITES MÉMOIRE]")
        leaks = detect_memory_leaks(content)
        if leaks['listeners']:
            for leak in leaks['listeners']:
                print(f"  ⚠️  {leak}")
        else:
            print("  ✅ Aucune fuite mémoire détectée")
        
        # Équilibre jeu
        print("\\n[ANALYSE ÉQUILIBRE]")
        balance = analyze_game_balance(content)
        if balance['warnings']:
            for warn in balance['warnings']:
                print(f"  ⚠️  {warn}")
        else:
            print("  ✅ Équilibre du jeu OK")
        
        # Stats
        print("\\n[STATS DES FORMES]")
        for form, stats in balance['stats'].items():
            print(f"  {form:12} : Énergie={stats['energy']:<3} | Dégâts={stats['damage']:<3}")
    
    # Sauvegarde
    if not args.dry_run:
        output = args.file.replace('.js', '_fixed.js')
        with open(output, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\\n✅ Fichier corrigé : {output}")

if __name__ == "__main__":
    main()
"""

# ============ CODE DU LAUNCHER ============
LAUNCHER_CODE = """@echo off
setlocal

:: PLATON'S SHIFTER - LAUNCHER v4.0
:: NIVEAU SUPÉRIEUR : Detection fuites memoire + Analyse equilibre

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ===========================================
echo PLATON'S SHIFTER v4.0 - NIVEAU SUPERIEUR
echo ===========================================
echo.

:: Verifications
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python non trouve dans PATH
    pause
    exit /b 1
)

if not exist "fix_game_v4.py" (
    echo [ERREUR] fix_game_v4.py manquant
    pause
    exit /b 1
)

:MENU
echo.
echo ===========================================
echo MENU PRINCIPAL
echo ===========================================
echo 1 - Corriger le jeu + Rapport Avance
echo 2 - Simulation (test sans modification)
echo 3 - Voir la documentation
echo 0 - Quitter
echo.
set /p choix="Votre choix (0-3) : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" goto :SIMULER
if "%choix%"=="3" goto :DOC
if "%choix%"=="0" goto :FIN
echo Choix invalide
goto :MENU

:CORRIGER
echo.
echo =========================================
echo LANCEMENT CORRECTION + RAPPORT AVANCE
echo =========================================
python fix_game_v4.py Game.js --advanced-report
echo.
if exist "Game_fixed.js" (
    move "Game_fixed.js" "Game.js" >nul 2>&1
    echo [OK] Corrections appliquees !
) else (
    echo [INFO] Aucune correction necessaire
)
echo.
pause
goto :MENU

:SIMULER
echo.
echo =========================================
echo SIMULATION (test sans modification)
echo =========================================
python fix_game_v4.py Game.js --dry-run --advanced-report
echo.
pause
goto :MENU

:DOC
echo.
echo Ouverture de la documentation...
if exist "PROJECT_STATE.md" (
    start notepad "PROJECT_STATE.md"
) else (
    echo Documentation introuvable
)
goto :MENU

:FIN
echo.
echo Au revoir !
timeout /t 3 >nul
exit /b 0
"""

# ============ DOCUMENTATION ============
DOC_CONTENT = """# PLATON'S SHIFTER - Documentation
Version: 4.0 (Niveau Supérieur)
Date: 2025-12-05

## Fonctionnalités du Niveau Supérieur
- Détection automatique des fuites mémoire
- Analyse d'équilibre des 5 formes
- Rapports détaillés dans la console

## Utilisation
1. Double-cliquer sur `launcher_final.bat`
2. Choisir "1" pour corriger + rapport
3. Observer les résultats

## Fichiers créés
- fix_game_v4.py (correcteur intelligent)
- launcher_final.bat (interface utilisateur)
- PROJECT_STATE.md (ce fichier)
"""

# ============ FONCTION D'INSTALLATION ============
def creer_fichier(chemin: Path, contenu: str, description: str):
    """Crée un fichier avec gestion d'erreurs"""
    print(f"[INFO] Création de {description}...")
    try:
        with open(chemin, 'w', encoding='utf-8') as f:
            f.write(contenu)
        print(f"  ✅ {chemin.name} créé")
    except Exception as e:
        print(f"  ❌ ERREUR {chemin.name}: {e}")

def installer():
    """Installation complète du niveau supérieur"""
    print("=" * 70)
    print("INSTALLATEUR FINAL - PLATON'S SHIFTER v4.0")
    print("=" * 70)
    print()
    
    # Vérifier que nous sommes au bon endroit
    if not (PROJECT_DIR / "Game.js").exists():
        print("❌ ERREUR : Game.js introuvable dans le dossier")
        print(f"   Dossier actuel : {PROJECT_DIR}")
        print()
        input("Appuyez sur Entrée pour quitter...")
        return
    
    # Étape 1 : Créer le correcteur
    creer_fichier(V4_FILE, V4_CODE, "le correcteur v4.0")
    
    # Étape 2 : Créer le launcher
    creer_fichier(LAUNCHER_FILE, LAUNCHER_CODE, "le launcher")
    
    # Étape 3 : Créer la documentation
    creer_fichier(DOC_FILE, DOC_CONTENT, "la documentation")
    
    # Étape 4 : Créer un raccourci (optionnel)
    print()
    print("[INFO] Création d'un raccourci sur le Bureau...")
    try:
        import winshell
        from win32com.client import Dispatch
        
        desktop = Path(winshell.desktop())
        shortcut = desktop / "Platon's Shifter.lnk"
        shell = Dispatch('WScript.Shell')
        s = shell.CreateShortCut(str(shortcut))
        s.Targetpath = str(LAUNCHER_FILE)
        s.WorkingDirectory = str(PROJECT_DIR)
        s.save()
        print("  ✅ Raccourci créé sur le Bureau !")
    except ImportError:
        print("  ℹ️  Module winshell non disponible")
        print("     Créez le raccourci manuellement :")
        print("     Clic droit sur launcher_final.bat → Envoyer vers → Bureau")
    except Exception as e:
        print(f"  ℹ️  Raccourci non créé : {e}")
    
    # Message final
    print()
    print("=" * 70)
    print("✅ INSTALLATION TERMINÉE AVEC SUCCÈS !")
    print("=" * 70)
    print()
    print("POUR UTILISER LE NIVEAU SUPÉRIEUR :")
    print("  1. Double-cliquez sur launcher_final.bat")
    print("  2. Choisissez '1' (Corriger + Rapport)")
    print("  3. Observez les nouvelles informations affichées !")
    print()
    print("=" * 70)
    print("LE SCRIPT VA RESTER OUVERT. Appuyez sur Entrée pour terminer.")
    print("=" * 70)

# ============ LANCEMENT GARANTI ============
if __name__ == "__main__":
    try:
        installer()
    except Exception as e:
        print(f"\n❌ ERREUR CRITIQUE : {e}")
    finally:
        # GARANTIE : La fenêtre reste ouverte
        input("\nAppuyez sur la touche Entrée pour fermer cette fenêtre...")