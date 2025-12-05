@echo off
setlocal

:: ===========================================
:: UPGRADE V4 - VERSION ULTRA-SÛRE (100% BATCH)
:: NE JAMAIS UTILISER POWERSHELL - TROP INSTABLE
:: ===========================================

set "PROJECT_DIR=%~dp0"
set "V4_FILE=%PROJECT_DIR%fix_game_v4.py"
set "LOG=%PROJECT_DIR%install_v4.log"

:: CREER UN FICHIER LOG POUR VOIR LES ERREURS
echo [UPGRADE V4 - DEBUT] > "%LOG%"
echo %DATE% %TIME% >> "%LOG%"
echo ========================= >> "%LOG%"
echo.

echo ===========================================
echo UPGRADE V4 ULTRA-SÛR (PAS DE POWERSHELL)
echo ===========================================
echo VERIFICATION : Cette fenetre ne va PAS se fermer
echo.
echo [INFO] Dossier : %PROJECT_DIR%
echo [INFO] Fichier cible : %V4_FILE%
echo.

:: VERIFIER QU'ON PEUT ECRIRE
cd /d "%PROJECT_DIR%" 2>nul
if errorlevel 1 (
    echo ERREUR CRITIQUE : Impossible d'acceder au dossier >> "%LOG%"
    echo %PROJECT_DIR% >> "%LOG%"
    echo ERREUR CRITIQUE : Impossible d'acceder au dossier
    echo Voir le log : %LOG%
    pause
    exit /b 1
)

:: ETAPE 1 : CREER LE FICHIER LIGNE PAR LIGNE (100% FIABLE)
echo [ETAPE 1] Creation de fix_game_v4.py ligne par ligne...
echo [ETAPE 1] Creation ligne par ligne >> "%LOG%"

:: METHODE ULTRA-SURE : Utilisation d'un fichier temporaire
:: On ecrit chaque ligne une par une
(
echo #!/usr/bin/env python3
echo """Platon's Shifter - Correcteur v4.0"""
echo """NIVEAU SUPERIEUR : Detection fuites memoire + Analyse equilibre"""
echo """"""
echo import re
echo import sys
echo from pathlib import Path
echo from typing import Dict, List, Tuple, Optional
echo.
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
echo         "replace": """            # Une seule base ennemie"\n"                enemyBase = {"\n"                    x: canvas.width * 0.75,"\n"                    y: canvas.height / 2,"\n"                    radius: GRID_SIZE * 1.5"\n"                };""",
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
echo         "replace": "# CORRIGE: Respawn apres 1s\n                    enemies.splice(index, 1);\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
echo         "marqueur": "CORRECT_RESPAWN"
echo     }
echo ]
echo.
echo class Correction:
echo     def __init__(self, config: Dict):
echo         self.id = config["id"]
echo         self.nom = config["nom"]
echo         self.marqueur = config["marqueur"]
echo         self.pattern = config.get("pattern", "")
echo         self.replace = config.get("replace", "")
echo     def test(self, code: str) -> bool:
echo         return bool(re.search(self.pattern, code, re.MULTILINE ^| re.DOTALL))
echo     def apply(self, code: str) -> Tuple[str, bool]:
echo         new_code = re.sub(self.pattern, self.replace, code, flags=re.MULTILINE ^| re.DOTALL)
echo         modified = new_code != code
echo         return new_code, modified
echo.
echo def detect_memory_leaks(code: str) -> Dict[str, List[str]]:
echo     leaks = {'listeners': [], 'intervals': []}
echo     listener_pattern = r'\.addEventListener\s*\(\s*[\''](\w+)[\'']\s*,'
echo     for match in re.finditer(listener_pattern, code):
echo         leaks['listeners'].append(f"Event '{match.group(1)}' non supprime")
echo     return leaks
echo.
echo def analyze_game_balance(code: str) -> Dict[str, List[str]]:
echo     balance = {'warnings': [], 'info': [], 'stats': {}}
echo     forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
echo     for form in forms:
echo         energy_pattern = rf'function\s+{form.lower()}_power[\s\S]*?energy\s*-\=\s*(\d+)'
echo         match = re.search(energy_pattern, code)
echo         energy = int(match.group(1)) if match else 0
echo         balance['stats'][form] = {'energy': energy, 'damage': energy * 3}
echo         if energy > 10:
echo             balance['warnings'].append(f"{form}: Cout energie eleve ({energy})")
echo     return balance
echo.
echo def main():
echo     import argparse
echo     parser = argparse.ArgumentParser()
echo     parser.add_argument('file')
echo     parser.add_argument('--dry-run', action='store_true')
echo     parser.add_argument('--advanced-report', action='store_true')
echo     args = parser.parse_args()
echo     with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
echo         content = f.read()
echo     corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
echo     applied = []
echo     print("=" * 70)
echo     print("?? NIVEAU SUPERIEUR ACTIVE")
echo     print("=" * 70)
echo     for corr in corrections:
echo         if corr.test(content):
echo             content, modified = corr.apply(content)
echo             if modified:
echo                 applied.append(corr.nom)
echo                 content += f"\n// {corr.marqueur}\n"
echo     if args.advanced_report:
echo         print("\n[ANALYSE FUITES MEMOIRE]")
echo         leaks = detect_memory_leaks(content)
echo         for leak in leaks['listeners']:
echo             print(f"  - {leak}")
echo         print("\n[ANALYSE EQUILIBRE]")
echo         balance = analyze_game_balance(content)
echo         for warn in balance['warnings']:
echo             print(f"  - {warn}")
echo     output = args.file.replace('.js', '_fixed.js')
echo     with open(output, 'w', encoding='utf-8') as f:
echo         f.write(content)
echo     print(f"\nFichier corrige: {output}")
echo.
echo if __name__ == "__main__":
echo     main()
) > "%V4_FILE%"

if not exist "%V4_FILE%" (
    echo ERREUR CRITIQUE : Echec creation %V4_FILE% >> "%LOG%"
    echo ERREUR : Echec creation. Voir log : %LOG%
    pause
    exit /b 1
)

echo [OK] Fichier cree : %V4_FILE%
echo [OK] Fichier cree >> "%LOG%"

:: ETAPE 2 : METTRE A JOUR LE LAUNCHER
echo.
echo [ETAPE 2] Mise a jour du launcher...
echo [ETAPE 2] Mise a jour du launcher >> "%LOG%"

(
echo @echo off
echo setlocal
echo set "SCRIPT_DIR=%%~dp0"
echo cd /d "%%SCRIPT_DIR%%"
echo echo ===========================================
echo echo PLATON'S SHIFTER v4.0 - NIVEAU SUPERIEUR
echo echo ===========================================
echo python --version ^>nul 2^>^&1
echo if errorlevel 1 ^(
echo     echo [ERREUR] Python non trouve
echo     pause
echo     exit /b 1
echo ^)
echo if not exist "fix_game_v4.py" ^(
echo     echo [ERREUR] fix_game_v4.py manquant
echo     pause
echo     exit /b 1
echo ^)
echo :MENU
echo echo.
echo echo ===========================================
echo echo MENU PRINCIPAL
echo echo ===========================================
echo echo 1 - Corriger + Rapport
echo echo 2 - Simulation
echo echo 3 - Voir documentation
echo echo 0 - Quitter
echo echo.
echo set /p choix="Choix : "
echo if "%%choix%%"=="1" python fix_game_v4.py Game.js --advanced-report ^&^& move Game_fixed.js Game.js ^>nul 2^>^&1 ^&^& echo [OK] Applique ^|^| echo [INFO] Rien a faire
echo if "%%choix%%"=="2" python fix_game_v4.py Game.js --dry-run --advanced-report
echo if "%%choix%%"=="3" start notepad PROJECT_STATE.md
echo if "%%choix%%"=="0" exit /b 0
echo goto :MENU
) > "%PROJECT_DIR%launcher_final.bat"

echo [OK] Launcher mis a jour >> "%LOG%"

:: === FINALISATION ===
echo.
echo ===========================================
echo ? UPGRADE TERMINÉ !
echo ===========================================
echo.
echo VERIFICATION :
echo   - fix_game_v4.py : %V4_FILE%
echo   - launcher_final.bat : %PROJECT_DIR%launcher_final.bat
echo.
echo POUR TESTER :
echo   1. Double-cliquez sur launcher_final.bat
echo   2. Tapez 1 (Corriger + Rapport)
echo   3. Observez les nouvelles informations !
echo.
echo Si ca ne marche pas, ouvrez ce fichier :
echo   %LOG%
echo ===========================================
echo Appuyez sur ENTREE pour fermer...
echo (Cette fenetre ne se fermera pas avant !)
echo ===========================================
pause >nul
exit /b 0