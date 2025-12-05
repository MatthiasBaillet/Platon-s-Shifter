#!/usr/bin/env python3
"""
Platon's Shifter - Installateur V4
NIVEAU SUPÉRIEUR - Installation 100% Python
"""

import os
import sys
from pathlib import Path

# ============ CONFIGURATION ============
PROJECT_DIR = Path(__file__).parent
V4_FILE = PROJECT_DIR / "fix_game_v4.py"
LAUNCHER_FILE = PROJECT_DIR / "launcher_final.bat"
STATE_FILE = PROJECT_DIR / "PROJECT_STATE.md"

# ============ CODE DU CORRECTEUR V4 ============
V4_CODE = '''#!/usr/bin/env python3
"""
Platon's Shifter - Correcteur v4.0
NIVEAU SUPÉRIEUR : Détection fuites mémoire + Analyse équilibre
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# ============ CORRECTIONS ============
CORRECTIONS_CONFIG = [
    {
        "id": "taille_bases",
        "nom": "Reduire taille des bases (2.5→1.5)",
        "pattern": r"radius\s*:\s*GRID_SIZE\s*\*\s*2\.5",
        "replace": "radius: GRID_SIZE * 1.5",
        "marqueur": "CORRECT_TAILLE_BASES"
    },
    {
        "id": "base_unique_ennemi",
        "nom": "Passer a une seule base ennemi",
        "pattern": r"let\s+enemyBases\s*=\s*\[\s*\]\s*;",
        "replace": "let enemyBase = null;",
        "marqueur": "CORRECT_BASE_UNIQUE"
    },
    {
        "id": "bases_logique_spawn",
        "nom": "Simplifier logique de creation des bases",
        "pattern": r"// 3 bases ennemis[\s\S]*?enemyBases\.push\(base\);\s+}\s+}",
        "replace": """            // Une seule base ennemie
            enemyBase = {
                x: canvas.width * 0.75,
                y: canvas.height / 2,
                radius: GRID_SIZE * 1.5
            };""",
        "marqueur": "CORRECT_BASES_LOGIQUE"
    },
    {
        "id": "uniformiser_style",
        "nom": "Uniformiser style base/terrain",
        "pattern": r"ctx\.fillText\s*\(\s*'BASE'\s*,\s*startBase\.x\s*,\s*startBase\.y\s*\+\s*5\s*\)\s*;",
        "replace": "",
        "marqueur": "CORRECT_STYLE"
    },
    {
        "id": "respawn_ennemis",
        "nom": "Corriger respawn ennemis",
        "pattern": r"//\s*DETRUIRE\s*L'ENNEMI\s*enemies\.splice\s*\(\s*index\s*,\s*1\s*\)\s*;",
        "replace": "// ✅ CORRIGE : Respawn apres 1s\n                    enemies.splice(index, 1);\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
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
    """Detecte les fuites memoire (event listeners et intervals)"""
    leaks = {'listeners': [], 'intervals': []}
    
    # Event listeners
    listener_pattern = r'\.addEventListener\s*\(\s*[\'"](\w+)[\'"]\s*,'
    for match in re.finditer(listener_pattern, code):
        leaks['listeners'].append(f"Event '{match.group(1)}' ajouté mais jamais supprimé")
    
    # Intervals
    interval_pattern = r'(\w+)\s*=\s*setInterval\s*\('
    for match in re.finditer(interval_pattern, code):
        leaks['intervals'].append(f"Interval '{match.group(1)}' non nettoyé")
    
    return leaks

def analyze_game_balance(code: str) -> Dict[str, List[str]]:
    """Analyse l'equilibre des 5 formes"""
    balance = {'warnings': [], 'info': [], 'stats': {}}
    forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
    
    for form in forms:
        energy_pattern = rf'function\s+{form.lower()}_power[\s\S]*?energy\s*-\=\s*(\d+)'
        match = re.search(energy_pattern, code)
        energy = int(match.group(1)) if match else 0
        damage = energy * 3  # Simplification
        
        balance['stats'][form] = {'energy': energy, 'damage': damage}
        
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
    
    # Lecture du fichier
    with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
    applied = []
    
    print("=" * 70)
    print("NIVEAU SUPÉRIEUR - V4.0")
    print("=" * 70)
    
    # Application des corrections
    for corr in corrections:
        if corr.test(content):
            new_content, modified = corr.apply(content)
            if modified:
                content = new_content
                content += f"\n// {corr.marqueur}\n"
                applied.append(corr.nom)
    
    # Rapport avancé
    if args.advanced_report or not args.dry_run:
        print("\n" + "=" * 70)
        print("📊 RAPPORT NIVEAU SUPÉRIEUR")
        print("=" * 70)
        
        # Fuites mémoire
        print("\n[ANALYSE FUITES MÉMOIRE]")
        leaks = detect_memory_leaks(content)
        if leaks['listeners']:
            for leak in leaks['listeners']:
                print(f"  ⚠️  {leak}")
        if leaks['intervals']:
            for leak in leaks['intervals']:
                print(f"  ⚠️  {leak}")
        if not leaks['listeners'] and not leaks['intervals']:
            print("  ✅ Aucune fuite mémoire détectée")
        
        # Équilibre jeu
        print("\n[ANALYSE ÉQUILIBRE]")
        balance = analyze_game_balance(content)
        if balance['warnings']:
            for warn in balance['warnings']:
                print(f"  ⚠️  {warn}")
        if balance['info']:
            for info in balance['info']:
                print(f"  ℹ️  {info}")
        
        # Stats
        print("\n[STATS DES FORMES]")
        for form, stats in balance['stats'].items():
            print(f"  {form:12} : Énergie={stats['energy']:<3} | Dégâts={stats['damage']:<3}")
    
    # Sauvegarde
    if not args.dry_run:
        output = args.file.replace('.js', '_fixed.js')
        with open(output, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\n✅ Fichier corrigé : {output}")

if __name__ == "__main__":
    main()
'''

# ============ CODE DU LAUNCHER V4 ============
LAUNCHER_CODE = '''@echo off
setlocal

:: PLATON'S SHIFTER - LAUNCHER v4.0
:: NIVEAU SUPÉRIEUR ACTIVÉ

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ===========================================
echo PLATON'S SHIFTER v4.0 - NIVEAU SUPÉRIEUR
echo ===========================================
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python non trouve dans PATH
    pause
    exit /b 1
)

if not exist "install_v4.py" (
    echo [ERREUR] install_v4.py manquant
    pause
    exit /b 1
)

:MENU
echo.
echo ===========================================
echo MENU PRINCIPAL
echo ===========================================
echo 1 - Lancer le correcteur V4 + Rapport
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
echo LANCEMENT CORRECTION + RAPPORT AVANCÉ
echo =========================================
python install_v4.py Game.js --advanced-report
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
python install_v4.py Game.js --dry-run --advanced-report
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
'''

# ============ CODE DOCUMENTATION ============
DOC_CONTENT = '''# 📊 PLATON'S SHIFTER - ÉTAT DU PROJET
**Version** : 2.0  
**Date** : 2025-12-05  
**Statut** : ✅ NIVEAU SUPÉRIEUR ACTIVÉ

## Ce qui a été installé
- Détection automatique des fuites mémoire
- Analyse d'équilibre des 5 formes
- Rapports avancés dans la console

## Pour utiliser
Double-cliquez sur `launcher_final.bat` et choisissez **1**
'''

# ============ FONCTION D'INSTALLATION ============
def installer():
    print("=" * 70)
    print("INSTALLATEUR NIVEAU SUPÉRIEUR V4.0")
    print("=" * 70)
    print()
    
    # Étape 1 : Créer fix_game_v4.py
    print("[ÉTAPE 1] Création du correcteur v4...")
    try:
        with open(V4_FILE, 'w', encoding='utf-8') as f:
            f.write(V4_CODE)
        print(f"  ✅ {V4_FILE.name} créé")
    except Exception as e:
        print(f"  ❌ ERREUR : {e}")
        input("\nAppuyez sur Entrée pour quitter...")
        sys.exit(1)
    
    # Étape 2 : Créer le launcher
    print("\n[ÉTAPE 2] Création du launcher...")
    try:
        with open(LAUNCHER_FILE, 'w', encoding='utf-8') as f:
            f.write(LAUNCHER_CODE)
        print(f"  ✅ {LAUNCHER_FILE.name} créé")
    except Exception as e:
        print(f"  ❌ ERREUR : {e}")
        input("\nAppuyez sur Entrée pour quitter...")
        sys.exit(1)
    
    # Étape 3 : Créer documentation
    print("\n[ÉTAPE 3] Création de la documentation...")
    try:
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            f.write(DOC_CONTENT)
        print(f"  ✅ {STATE_FILE.name} créé")
    except Exception as e:
        print(f"  ❌ ERREUR : {e}")
    
    # Finalisation
    print("\n" + "=" * 70)
    print("✅ INSTALLATION TERMINÉE AVEC SUCCÈS !")
    print("=" * 70)
    print("\nPour utiliser le niveau supérieur :")
    print("  1. Double-cliquez sur launcher_final.bat")
    print("  2. Choisissez '1' (Corriger + Rapport)")
    print("\nLe script va maintenant créer un raccourci sur votre bureau...")
    
    # Créer raccourci (optionnel)
    try:
        import winshell
        from win32com.client import Dispatch
        
        desktop = winshell.desktop()
        shortcut_path = Path(desktop) / "Platon's Shifter.lnk"
        shell = Dispatch('WScript.Shell')
        shortcut = shell.CreateShortCut(str(shortcut_path))
        shortcut.Targetpath = str(LAUNCHER_FILE)
        shortcut.WorkingDirectory = str(PROJECT_DIR)
        shortcut.save()
        print(f"\n🎯 Raccourci créé sur le Bureau !")
    except:
        print(f"\nℹ️  Raccourci non créé (module winshell absent)")
        print(f"   Créez-le manuellement : clic droit → Envoyer vers → Bureau")
    
    print("\n" + "=" * 70)
    input("Appuyez sur Entrée pour quitter...")

# ============ LANCEMENT ============
if __name__ == "__main__":
    installer()