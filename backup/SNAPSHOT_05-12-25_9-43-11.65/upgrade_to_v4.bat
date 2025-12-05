@echo off
setlocal

:: ===========================================
:: PLATON'S SHIFTER - UPGRADE TO V4
:: Installe automatiquement le niveau supérieur
:: ===========================================

set "PROJECT_DIR=%~dp0"
set "V4_FILE=%PROJECT_DIR%fix_game_v4.py"

echo ===========================================
echo UPGRADE VERS LE NIVEAU SUPÉRIEUR
echo ===========================================
echo.

:: === CRÉATION DE fix_game_v4.py ===
echo [ETAPE 1] Création du correcteur v4...
echo.

powershell -Command "@"
#!/usr/bin/env python3
"""
Platon's Shifter - Correcteur Automatique v4.0
NIVEAU SUPÉRIEUR : Détection fuites mémoire + Analyse d'équilibre
"""

import urllib.request
import hashlib
import os
import re
import sys
import shutil
import subprocess
from pathlib import Path
from typing import Dict, Optional, Tuple, List, Set

# ============================================
# CONFIGURATION DES CORRECTIONS
# ============================================
CORRECTIONS_CONFIG = [
    {
        "id": "taille_bases",
        "nom": "Reduire taille des bases (2.5?1.5)",
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
        "replace": "// ? CORRIGE : Respawn apres 1s\n                    enemies.splice(index, 1);\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
        "marqueur": "CORRECT_RESPAWN"
    }
]

# ============================================
# CLASSE DE CORRECTION
# ============================================
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

# ============================================
# NIVEAU SUPÉRIEUR 1 : DÉTECTION FUITES MÉMOIRE
# ============================================
def detect_memory_leaks(code: str) -> Dict[str, List[str]]:
    """
    Détecte les fuites mémoire dans le code JavaScript
    Retourne : { 'listeners': [...], 'intervals': [...] }
    """
    leaks = {
        'listeners': [],
        'intervals': []
    }
    
    # === DÉTECTION DES EVENT LISTENERS ===
    # Pattern : addEventListener sans removeEventListener correspondant
    listener_pattern = r'\.addEventListener\s*\(\s*[\'"](\w+)[\'"]\s*,'
    
    added_listeners = set()
    removed_listeners = set()
    
    # Trouver tous les addEventListener
    for match in re.finditer(listener_pattern, code):
        event_type = match.group(1)
        added_listeners.add(event_type)
    
    # Trouver tous les removeEventListener
    remove_pattern = r'\.removeEventListener\s*\(\s*[\'"](\w+)[\'"]\s*,'
    for match in re.finditer(remove_pattern, code):
        event_type = match.group(1)
        removed_listeners.add(event_type)
    
    # Listeners orphelins
    orphaned = added_listeners - removed_listeners
    for event in orphaned:
        leaks['listeners'].append(f"Event '{event}' ajouté mais jamais supprimé")
    
    # === DÉTECTION DES SETINTERVAL ===
    # Pattern : setInterval sans clearInterval
    interval_pattern = r'(\w+)\s*=\s*setInterval\s*\('
    clear_pattern = r'clearInterval\s*\(\s*(\w+)\s*\)'
    
    interval_vars = set()
    cleared_vars = set()
    
    # Trouver les variables qui stockent setInterval
    for match in re.finditer(interval_pattern, code):
        var_name = match.group(1)
        interval_vars.add(var_name)
    
    # Trouver les clearInterval
    for match in re.finditer(clear_pattern, code):
        var_name = match.group(1)
        cleared_vars.add(var_name)
    
    # Intervals non nettoyés
    uncleaned = interval_vars - cleared_vars
    for var in uncleaned:
        leaks['intervals'].append(f"Interval dans '{var}' non nettoyé")
    
    return leaks

# ============================================
# NIVEAU SUPÉRIEUR 2 : ANALYSE D'ÉQUILIBRE DE JEU
# ============================================
def analyze_game_balance(code: str) -> Dict[str, List[str]]:
    """
    Analyse l'équilibre des 5 formes du jeu
    Retourne : { 'warnings': [...], 'info': [...] }
    """
    balance = {
        'warnings': [],
        'info': [],
        'stats': {}
    }
    
    # Extraire les stats de chaque forme
    forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
    
    for form in forms:
        # Rechercher le coût énergie et les dégâts dans les fonctions de pouvoir
        power_func = f"{form.lower()}_power"
        
        # Pattern pour trouver energy -= X
        energy_pattern = rf'function\s+{power_func}[\s\S]*?energy\s*-\=\s*(\d+)'
        damage_pattern = rf'function\s+{power_func}[\s\S]*?damage\s*=\s*(\d+)'
        
        energy_cost = 0
        damage = 0
        
        energy_match = re.search(energy_pattern, code)
        if energy_match:
            energy_cost = int(energy_match.group(1))
        
        damage_match = re.search(damage_pattern, code)
        if damage_match:
            damage = int(damage_match.group(1))
        
        balance['stats'][form] = {
            'energy_cost': energy_cost,
            'damage': damage
        }
    
    # === ANALYSE DES RATIOS ===
    for form, stats in balance['stats'].items():
        energy = stats['energy_cost']
        dmg = stats['damage']
        
        if energy > 0:
            ratio = dmg / energy
            
            # Alerte si ratio trop élevé (forme trop puissante)
            if ratio > 3.0:
                balance['warnings'].append(f"{form} : Ratio Dégâts/Énergie TROP ÉLEVÉ ({ratio:.2f})")
            
            # Info si ratio faible (forme faible)
            elif ratio < 0.5:
                balance['info'].append(f"{form} : Ratio Dégâts/Énergie faible ({ratio:.2f})")
        
        # Vérifier si le coût énergie est raisonnable
        if energy > 10:
            balance['warnings'].append(f"{form} : Coût énergie très élevé ({energy})")
    
    # === VÉRIFICATION PROGRESSION ===
    # Vérifier que les formes se débloquent dans un ordre logique
    if 'Tetrahedron' in balance['stats'] and balance['stats']['Tetrahedron']['energy_cost'] == 0:
        balance['warnings'].append("Tetrahedron devrait avoir un coût énergie > 0")
    
    return balance

# ============================================
# RESTE DU CODE (identique à v3)
# ============================================
def apply_with_rollback(code: str, correction: Correction) -> Tuple[str, bool, Optional[str]]:
    backup_code = code
    new_code, modified = correction.apply(code)
    if not modified:
        return code, False, None
    is_valid, error = validate_syntax(new_code)
    if is_valid:
        new_code += f"\n// {correction.marqueur}\n"
        return new_code, True, None
    else:
        print(f"      ? ÉCHEC VALIDATION - Rollback automatique")
        print(f"         Erreur : {error[:80]}...")
        return backup_code, False, error

def load_content(source: str) -> str:
    if source.startswith(('http://', 'https://')):
        return download_from_url(source)
    else:
        return load_from_file(source)

def download_from_url(url: str) -> str:
    try:
        print(f"   Tentative de telechargement depuis {url}...")
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as response:
            content_type = response.headers.get('Content-Type', '')
            if 'text/html' in content_type.lower():
                print(f" ? ERREUR : L'URL a renvoye une page HTML.")
                sys.exit(1)
            content = response.read()
            decoded = content.decode('utf-8', errors='strict')
            if decoded.strip().startswith('<!DOCTYPE html>') or '<html' in decoded[:100]:
                print(" ? ERREUR : Le contenu semble etre une page HTML.")
                sys.exit(1)
            return decoded
    except urllib.error.HTTPError as e:
        print(f" ? ERREUR HTTP {e.code}: {e.reason}")
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f" ? ERREUR DE CONNEXION: {e.reason}")
        sys.exit(1)
    except Exception as e:
        print(f" ? ERREUR INATTENDUE: {e}")
        sys.exit(1)

def load_from_file(filepath: str) -> str:
    try:
        print(f"   Chargement depuis fichier local : {filepath}")
        path = Path(filepath)
        if not path.exists():
            print(f" ? ERREUR : Le fichier n'existe pas : {filepath}")
            sys.exit(1)
        if path.stat().st_size > 500000:
            print(f" ? ERREUR : Fichier trop volumineux (> 500 Ko)")
            sys.exit(1)
        # Gestion intelligente de l'encodage
        try:
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            print("   [Encodage detecte : UTF-8]")
            return content
        except UnicodeDecodeError:
            try:
                with open(path, 'r', encoding='windows-1252') as f:
                    content = f.read()
                print("   [Encodage detecte : ANSI/Windows-1252]")
                return content
            except Exception as e2:
                print(f" ? ERREUR : Impossible de lire le fichier")
                print(f"    Erreur finale : {e2}")
                sys.exit(1)
    except Exception as e:
        print(f" ? ERREUR lors de la lecture du fichier : {e}")
        sys.exit(1)

def validate_syntax(code: str) -> Tuple[bool, Optional[str]]:
    try:
        temp_file = Path("temp_validation.js")
        temp_file.write_text(code, encoding='utf-8')
        result = subprocess.run(
            ["node", "-c", str(temp_file)],
            capture_output=True,
            text=True,
            timeout=5
        )
        temp_file.unlink(missing_ok=True)
        if result.returncode == 0:
            return True, None
        return False, result.stderr
    except FileNotFoundError:
        print(" ??  Node.js non trouve - validation desactivee")
        return True, None
    except Exception as e:
        return False, str(e)

def save_with_backup(filepath: str, content: str):
    path = Path(filepath)
    if path.exists():
        backup_path = path.with_suffix(path.suffix + '.backup')
        shutil.copy2(path, backup_path)
        print(f" ?? Backup cree : {backup_path.name}")
    path.write_text(content, encoding='utf-8')
    print(f" ? Fichier sauvegarde : {filepath}")

# ============================================
# MAIN (AMÉLIORÉ AVEC NIVEAU SUPÉRIEUR)
# ============================================
def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Correcteur Platon'"'"'s Shifter v4.0')
    parser.add_argument('file', help='Fichier Game.js a corriger')
    parser.add_argument('--dry-run', action='store_true', help='Simulation sans modification')
    parser.add_argument('--no-backup', action='store_true', help='Pas de backup')
    parser.add_argument('--advanced-report', action='store_true', help='Rapport niveau superieur')
    
    args = parser.parse_args()
    
    # Chargement
    with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
    
    print("=" * 70)
    print("?? PLATON'"'"'S SHIFTER v4.0 - NIVEAU SUPÉRIEUR")
    print("=" * 70)
    
    # Application corrections
    applied = []
    skipped = []
    errors = []
    
    for i, corr in enumerate(corrections, 1):
        if corr.marqueur in content:
            skipped.append(corr.nom)
            continue
        if corr.test(content):
            new_content, modified = corr.apply(content)
            if modified:
                content = new_content
                content += f"\n// {corr.marqueur}\n"
                applied.append(corr.nom)
    
    # === RAPPORT AVANCÉ (NIVEAU SUPÉRIEUR) ===
    if args.advanced_report or not args.dry_run:
        print("\n" + "=" * 70)
        print("?? RAPPORT NIVEAU SUPÉRIEUR")
        print("=" * 70)
        
        # 1. Détection fuites mémoire
        print("\n?? ANALYSE FUITES MÉMOIRE :")
        leaks = detect_memory_leaks(content)
        if leaks['listeners']:
            for leak in leaks['listeners']:
                print(f"   ??  {leak}")
        if leaks['intervals']:
            for leak in leaks['intervals']:
                print(f"   ??  {leak}")
        if not leaks['listeners'] and not leaks['intervals']:
            print("   ? Aucune fuite mémoire detectee")
        
        # 2. Analyse d'équilibre
        print("\n?? ANALYSE EQUILIBRE DE JEU :")
        balance = analyze_game_balance(content)
        if balance['warnings']:
            for warn in balance['warnings']:
                print(f"   ??  {warn}")
        if balance['info']:
            for info in balance['info']:
                print(f"   ??  {info}")
        if not balance['warnings'] and not balance['info']:
            print("   ? Equilibre du jeu OK")
        
        # Stats détaillées
        print("\n?? STATS DES FORMES :")
        for form, stats in balance['stats'].items():
            print(f"   {form:12} : Energie={stats['energy_cost']:2} | Dégâts={stats['damage']:3}")
    
    # Sauvegarde
    if not args.dry_run:
        if not args.no_backup:
            backup_file = args.file + '.backup'
            shutil.copy2(args.file, backup_file)
        output_file = args.file.replace('.js', '_fixed.js')
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\n? Fichier corrigé : {output_file}")

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath "%V4_FILE%" -Encoding utf8

if exist "%V4_FILE%" (
    echo ? fix_game_v4.py cree avec succes !
) else (
    echo ? ERREUR creation fix_game_v4.py
    pause
    exit /b 1
)

:: === METTRE À JOUR LE LAUNCHER POUR UTILISER V4 ===
echo.
echo [ETAPE 2] Mise a jour du launcher...
echo.

:: Sauvegarder l'ancien launcher
if exist "%PROJECT_DIR%launcher_final.bat" (
    copy "%PROJECT_DIR%launcher_final.bat" "%PROJECT_DIR%launcher_final_v3.backup" >nul 2>&1
)

:: Creer le nouveau launcher v4
powershell -Command "@"
@echo off
setlocal

:: PLATON'S SHIFTER - LAUNCHER v4.0
:: NIVEAU SUPÉRIEUR ACTIVÉ

set "SCRIPT_DIR=%~dp0"
set "CORRECTEUR=%SCRIPT_DIR%fix_game_v4.py"
set "GAME=%SCRIPT_DIR%Game.js"
set "GAME_FIXED=%SCRIPT_DIR%Game_fixed.js"

:: ============================================================
echo ===========================================
echo PLATON'S SHIFTER v4.0 - NIVEAU SUPÉRIEUR
echo ===========================================
echo.
echo ??  Ce launcher inclut :
echo    - Détection des fuites mémoire
echo    - Analyse d'équilibre de jeu
echo    - Rapports avancés
echo.

:: === VÉRIFICATIONS ===
cd /d "%SCRIPT_DIR%"

python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python non trouve
    pause
    exit /b 1
)
if not exist "fix_game_v4.py" (
    echo [ERREUR] fix_game_v4.py manquant
    pause
    exit /b 1
)
if not exist "Game.js" (
    echo [ERREUR] Game.js manquant
    pause
    exit /b 1
)

:MENU
echo.
echo ===========================================
echo MENU PRINCIPAL
echo ===========================================
echo.
echo 1 - Corriger + Rapport Niveau Supérieur
echo 2 - Simulation (rapide)
echo 3 - Voir PROJECT_STATE.md
echo 0 - Quitter
echo.
set /p choix="Votre choix : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" goto :SIMULATION
if "%choix%"=="3" goto :VOIR_DOC
if "%choix%"=="0" goto :FIN
goto :MENU

:CORRIGER
echo.
echo =========================================
echo LANCEMENT CORRECTION + RAPPORT AVANCÉ
echo =========================================
python fix_game_v4.py Game.js --advanced-report
echo.
echo =========================================
echo Renommage automatique en cours...
echo =========================================
if exist "%GAME_FIXED%" (
    move "%GAME_FIXED%" "%GAME%" >nul 2>&1
    echo ? Corrections appliquées !
) else (
    echo ?? Aucune correction à appliquer
)
echo.
pause
goto :MENU

:SIMULATION
echo.
echo =========================================
echo SIMULATION (test sans modification)
echo =========================================
python fix_game_v4.py Game.js --dry-run --advanced-report
echo.
pause
goto :MENU

:VOIR_DOC
echo.
echo Ouverture de la documentation...
if exist "%SCRIPT_DIR%PROJECT_STATE.md" (
    start notepad "%SCRIPT_DIR%PROJECT_STATE.md"
) else (
    echo Documentation introuvable
)
goto :MENU

:FIN
echo.
echo À bientôt !
timeout /t 3 >nul
exit /b 0
"@ | Out-File -FilePath "%PROJECT_DIR%launcher_final.bat" -Encoding utf8

echo ? Launcher mis a jour vers v4.0 !

:: === FINALISATION ===
echo.
echo ===========================================
echo ? UPGRADE V4 TERMINÉ !
echo ===========================================
echo.
echo Ce qui a été installé :
echo   - fix_game_v4.py (detection fuites + equilibre)
echo   - launcher_final.bat (rapports avancés)
echo.
echo POUR UTILISER LE NIVEAU SUPÉRIEUR :
echo   1. Double-cliquez sur launcher_final.bat
echo   2. Choisissez "1" (Corriger + Rapport)
echo   3. Observez les nouvelles infos affichées !
echo.
echo ===========================================
echo Amusez-vous avec le niveau supérieur ! ??
echo ===========================================
echo.

pause
exit /b 0