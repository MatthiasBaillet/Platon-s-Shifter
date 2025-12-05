@echo off
setlocal

:: VERSION SIMPLIFIEE SANS BUGS DE SYNTAXE
set "SCRIPT_DIR=%~dp0"

:: ENLEVER l'apostrophe du chemin pour eviter les conflits
set "SCRIPT_DIR=%SCRIPT_DIR:'=%"

echo ===========================================
echo PLATON'S SHIFTER LAUNCHER v2.4
echo ===========================================
echo.

:: VERIFICATIONS SIMPLES (sans chemins complexes)
cd /d "%SCRIPT_DIR%"

echo [ETAPE 1] Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR Python
    pause
    exit /b 1
)
echo [OK] Python

echo.
echo [ETAPE 2] Correcteur...
if NOT EXIST "fix_game_v3.py" goto :ERR_CORRECTEUR
echo [OK] Correcteur

echo.
echo [ETAPE 3] Game.js...
if NOT EXIST "Game.js" goto :ERR_GAMEJS
echo [OK] Game.js

goto :MENU

:ERR_CORRECTEUR
echo [ERREUR] fix_game_v3.py manquant
echo Fichiers .py dans le dossier :
dir *.py
pause
exit /b 1

:ERR_GAMEJS
echo [ERREUR] Game.js manquant
echo Fichiers .js dans le dossier :
dir *.js
pause
exit /b 1

:MENU
echo.
echo ===========================================
echo MENU
echo ===========================================
echo.
echo 1 - Corriger
echo 2 - Simulation
echo 0 - Quitter
echo.
set /p choix="Choix : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" goto :SIMULATION
if "%choix%"=="0" goto :FIN
goto :MENU

:CORRIGER
echo.
python fix_game_v3.py Game.js
echo.
pause
goto :MENU

:SIMULATION
echo.
python fix_game_v3.py Game.js --dry-run
echo.
pause
goto :MENU

:FIN
echo Au revoir
timeout /t 3 >nul
exit /b 0