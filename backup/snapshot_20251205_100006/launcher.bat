@echo off
setlocal

:: PLATON SHIFTER LAUNCHER - VERSION ASCII (sans accents)
:: ENREGISTRER EN ANSI SANS ERREUR

echo ===========================================
echo PLATON SHIFTER LAUNCHER - Version Simple
echo ===========================================
echo.

:: VERIFICATION PYTHON
echo Verification Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Python non trouve
    pause
    exit /b 1
)
echo OK: Python detecte
echo.

:: VERIFICATION GAME.JS
echo Verification Game.js...
echo Chemin: %~dp0Game.js
if exist "%~dp0Game.js" (
    echo OK: Game.js trouve
    goto MENU
)

:: SI MANQUANT
echo ERREUR: Game.js MANQUANT
echo Dossier: %~dp0
echo.
echo Solutions:
echo 1. Placez Game.js DANS ce dossier
echo 2. Verifiez le nom: Game.js (G majuscule)
echo.
pause
exit /b 1

:: MENU
:MENU
echo.
echo ===========================================
echo MENU
echo ===========================================
echo 1. CORRIGER
echo 2. SIMULATION
echo 3. QUITTER
echo.
set /p choix="Choix (1-3): "

if "%choix%"=="1" goto CORRIGER
if "%choix%"=="2" goto SIMULATION
if "%choix%"=="3" goto FIN
echo Choix invalide
goto MENU

:CORRIGER
echo.
echo LANCEMENT DE LA CORRECTION...
python "%~dp0fix_game_v2.py" "%~dp0Game.js"
echo.
echo Termine. Renommez Game_fixed.js en Game.js
pause
goto FIN

:SIMULATION
echo.
echo LANCEMENT DE LA SIMULATION...
python "%~dp0fix_game_v2.py" "%~dp0Game.js" --dry-run
pause
goto MENU

:FIN
echo.
echo Fin du script
pause
exit /b 0