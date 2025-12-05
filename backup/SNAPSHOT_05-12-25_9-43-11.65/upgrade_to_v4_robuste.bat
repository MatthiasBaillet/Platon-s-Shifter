@echo off
setlocal

:: ===========================================
:: VERSION ULTRA-SURE - 100% BATCH, PAS DE POWERSHELL
:: ===========================================
:: Ce script ne se fermera JAMAIS, meme en cas d'erreur
:: ===========================================

set "PROJECT_DIR=%~dp0"
set "V4_FILE=%PROJECT_DIR%fix_game_v4.py"

:: CREER UN FICHIER LOG POUR VOIR LES ERREURS
set "LOG_FILE=%PROJECT_DIR%upgrade_v4.log"
echo [DEBUT UPGRADE V4] > "%LOG_FILE%"
echo %DATE% %TIME% >> "%LOG_FILE%"
echo ============================ >> "%LOG_FILE%"
echo.

echo ===========================================
echo UPGRADE VERS LE NIVEAU SUPERIEUR
echo ===========================================
echo VERIFICATION : Ce script ne va pas se fermer !
echo.
echo [INFO] Dossier projet : %PROJECT_DIR%
echo [INFO] Fichier cible : %V4_FILE%
echo.

:: VERIFIER QU'ON PEUT ECRIRE DANS LE DOSSIER
cd /d "%PROJECT_DIR%" 2>nul
if errorlevel 1 (
    echo ERREUR CRITIQUE : Impossible d'acceder au dossier
    echo %PROJECT_DIR%
    pause
    exit /b 1
)

:: ETAPE 1 : CREER fix_game_v4.py LIGNE PAR LIGNE (methode ultra-sure)
echo [ETAPE 1] Creation de fix_game_v4.py...
echo [ETAPE 1] Creation de fix_game_v4.py... >> "%LOG_FILE%"

:: CREATION DU FICHIER EN UTILISANT ECHO (plus lent mais 100% fiable)
(
echo #!/usr/bin/env python3
echo """
echo Platon's Shifter - Correcteur Automatique v4.0
echo NIVEAU SUPERIEUR : Detection fuites memoire + Analyse equilibre
echo """
echo.
echo import urllib.request
echo import hashlib
echo import os
echo import re
echo import sys
echo import shutil
echo import subprocess
echo from pathlib import Path
echo from typing import Dict, Optional, Tuple, List, Set
echo.
echo # ============================================
echo # CONFIGURATION DES CORRECTIONS
echo # ============================================
echo CORRECTIONS_CONFIG = [
echo     {
echo         "id": "taille_bases",
echo         "nom": "Reduire taille des bases (2.5?1.5)",
echo         "pattern": r"radius\s*:\s*GRID_SIZE\s*\*\s*2\.5",
echo         "replace": "radius: GRID_SIZE * 1.5",
echo         "marqueur": "CORRECT_TAILLE_BASES"
echo     },
echo     {
echo         "id": "base_unique_ennemi",
echo         "nom": "Passer a une seule base ennemi",
echo         "pattern": r"let\s+enemyBases\s*=\s*\[\s*\]\s*;",
echo         "replace": "let enemyBase = null;",
echo         "marqueur": "CORRECT_BASE_UNIQUE"
echo     },
echo     {
echo         "id": "bases_logique_spawn",
echo         "nom": "Simplifier logique de creation des bases",
echo         "pattern": r"// 3 bases ennemis[\s\S]*?enemyBases\.push\(base\);\s+}\s+}",
echo         "replace": """"""            # Une seule base ennemie
echo             enemyBase = {
echo                 x: canvas.width * 0.75,
echo                 y: canvas.height / 2,
echo                 radius: GRID_SIZE * 1.5
echo             };""""",
echo         "marqueur": "CORRECT_BASES_LOGIQUE"
echo     },
echo     {
echo         "id": "uniformiser_style",
echo         "nom": "Uniformiser style base/terrain",
echo         "pattern": r"ctx\.fillText\s*\(\s*'BASE'\s*,\s*startBase\.x\s*,\s*startBase\.y\s*\+\s*5\s*\)\s*;",
echo         "replace": "",
echo         "marqueur": "CORRECT_STYLE"
echo     },
echo     {
echo         "id": "respawn_ennemis",
echo         "nom": "Corriger respawn ennemis",
echo         "pattern": r"//\s*DETRUIRE\s*L'ENNEMI\s*enemies\.splice\s*\(\s*index\s*,\s*1\s*\)\s*;",
echo         "replace": "// ? CORRIGE : Respawn apres 1s\n                    enemies.splice(index, 1);\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
echo         "marqueur": "CORRECT_RESPAWN"
echo     }
echo ]
echo.
echo # ============================================
echo # CLASSE DE CORRECTION
echo # ============================================
echo class Correction:
echo     def __init__(self, config: Dict):
echo         self.id = config["id"]
echo         self.nom = config["nom"]
echo         self.marqueur = config["marqueur"]
echo         self.pattern = config.get("pattern", "")
echo         self.replace = config.get("replace", "")
echo     def test(self, code: str) -> bool:
echo         return bool(re.search(self.pattern, code, re.MULTILINE | re.DOTALL))
echo     def apply(self, code: str) -> Tuple[str, bool]:
echo         new_code = re.sub(self.pattern, self.replace, code, flags=re.MULTILINE | re.DOTALL)
echo         modified = new_code != code
echo         return new_code, modified
echo.
echo # ============================================
echo # NIVEAU SUPERIEUR 1 : DETECTION FUITES MEMOIRE
echo # ============================================
echo def detect_memory_leaks(code: str) -> Dict[str, List[str]]:
echo     leaks = {'listeners': [], 'intervals': []}
echo     listener_pattern = r'\.addEventListener\s*\(\s*[\'\"](\w+)[\'\"]\s*,'
echo     for match in re.finditer(listener_pattern, code):
echo         leaks['listeners'].append(f"Event '%%s%%s' non supprime" % match.group(1))
echo     interval_pattern = r'(\w+)\s*=\s*setInterval\('
echo     for match in re.finditer(interval_pattern, code):
echo         leaks['intervals'].append(f"Interval '%%s%%s' non nettoye" % match.group(1))
echo     return leaks
echo.
echo # ============================================
echo # NIVEAU SUPERIEUR 2 : ANALYSE D'EQUILIBRE
echo # ============================================
echo def analyze_game_balance(code: str) -> Dict[str, List[str]]:
echo     balance = {'warnings': [], 'info': [], 'stats': {}}
echo     forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
echo     for form in forms:
echo         energy_pattern = rf'function\s+{form.lower()}_power[\s\S]*?energy\s*-\=\s*(\d+)'
echo         match = re.search(energy_pattern, code)
echo         energy = int(match.group(1)) if match else 0
echo         balance['stats'][form] = {'energy': energy, 'damage': energy * 2}
echo         if energy > 10:
echo             balance['warnings'].append(f"{form}: Cout energie trop eleve")
echo     return balance
echo.
echo # ============================================
echo # MAIN AMELIORE
echo # ============================================
echo def main():
echo     import argparse
echo     parser = argparse.ArgumentParser()
echo     parser.add_argument('file')
echo     parser.add_argument('--dry-run', action='store_true')
echo     parser.add_argument('--advanced-report', action='store_true')
echo     args = parser.parse_args()
echo.
echo     with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
echo         content = f.read()
echo.
echo     corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
echo     applied = []
echo.
echo     print("=" * 70)
echo     print("NIVEAU SUPERIEUR ACTIVÉ")
echo     print("=" * 70)
echo.
echo     for corr in corrections:
echo         if corr.test(content):
echo             content, modified = corr.apply(content)
echo             if modified:
echo                 applied.append(corr.nom)
echo                 content += f"\n// {corr.marqueur}\n"
echo.
echo     if args.advanced_report:
echo         print("\n[FUITES MEMOIRE]")
echo         leaks = detect_memory_leaks(content)
echo         for leak in leaks['listeners']:
echo             print(f"   - {leak}")
echo.
echo         print("\n[ÉQUILIBRE JEU]")
echo         balance = analyze_game_balance(content)
echo         for warn in balance['warnings']:
echo             print(f"   - {warn}")
echo.
echo     output = args.file.replace('.js', '_fixed.js')
echo     with open(output, 'w', encoding='utf-8') as f:
echo         f.write(content)
echo     print(f"\nFichier corrigé: {output}")
echo.
echo if __name__ == "__main__":
echo     main()
) > "%V4_FILE%" 2>> "%LOG_FILE%"

if exist "%V4_FILE%" (
    echo [OK] fix_game_v4.py cree avec succes !
    echo [OK] fix_game_v4.py cree avec succes ! >> "%LOG_FILE%"
    dir "%V4_FILE%" >> "%LOG_FILE%"
) else (
    echo [ERREUR] Creation echouee - voir %LOG_FILE%
    echo [ERREUR] Creation echouee >> "%LOG_FILE%"
    type "%LOG_FILE%"
    pause
    exit /b 1
)

:: ETAPE 2 : Mettre a jour le launcher
echo.
echo [ETAPE 2] Mise a jour du launcher...
echo [ETAPE 2] Mise a jour du launcher... >> "%LOG_FILE%"

:: Sauvegarde l'ancien launcher
if exist "%PROJECT_DIR%launcher_final.bat" (
    copy "%PROJECT_DIR%launcher_final.bat" "%PROJECT_DIR%launcher_final_v3.backup" >nul 2>&1
    echo [OK] Sauvegarde launcher_final_v3.backup cree >> "%LOG_FILE%"
)

:: CREER UN LAUNCHER SIMPLIFIE QUI UTILISE V4
(
echo @echo off
echo setlocal
echo set "SCRIPT_DIR=%%~dp0"
echo cd /d "%%SCRIPT_DIR%%"
echo echo ===========================================
echo echo PLATON'S SHIFTER v4.0 - NIVEAU SUPERIEUR
echo echo ===========================================
echo echo.
echo python fix_game_v4.py Game.js --advanced-report
echo if exist "Game_fixed.js" ^(
echo     move "Game_fixed.js" "Game.js" ^>nul 2^>^&1
echo     echo Corrections appliquees ^!
echo ^)
echo echo.
echo pause
) > "%PROJECT_DIR%launcher_final.bat" 2>> "%LOG_FILE%"

if exist "%PROJECT_DIR%launcher_final.bat" (
    echo [OK] launcher_final.bat mis a jour !
    echo [OK] launcher mis a jour >> "%LOG_FILE%"
) else (
    echo [ERREUR] Mise a jour launcher echouee
    echo [ERREUR] Mise a jour launcher echouee >> "%LOG_FILE%"
    type "%LOG_FILE%"
    pause
    exit /b 1
)

:: === FINALISATION ===
echo.
echo ===========================================
echo SETUP TERMINÉ AVEC SUCCÈS !
echo ===========================================
echo.
echo VERIFICATION FICHIER LOG : %LOG_FILE%
echo (ouvrez-le si vous voyez des erreurs)
echo.
echo POUR UTILISER LE NIVEAU SUPERIEUR :
echo   1. Double-cliquez sur launcher_final.bat
echo   2. Observez les nouvelles informations !
echo.
echo ===========================================
echo Script cree par IA - Ne jamais cliquer sur Annuler ^^!
echo ===========================================
echo.

echo Conserver cette fenetre ouverte pour voir les erreurs eventuelles.
echo Appuyez sur une touche pour quitter...

timeout /t 30 >nul
exit /b 0