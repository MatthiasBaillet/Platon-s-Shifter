@echo off
setlocal

:: PLATON'S SHIFTER v4.1 - WORKFLOW FINAL
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo =========================================================
echo ?? PLATON'S SHIFTER v4.1 - CORRECTEUR INDUSTRIEL
echo =========================================================
echo.

:MENU
echo [1] Corriger + Rapport Complet (8,2s)
echo [2] Simuler (test sans appliquer)
echo [3] Ouvrir Jeu
echo [0] Quitter
echo.
set /p choix="Choix : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" python fix_game_v4.1.py Game.js --advanced-report --dry-run && pause
if "%choix%"=="3" start "" "index.html" && exit /b 0
if "%choix%"=="0" exit /b 0
goto :MENU

:CORRIGER
python fix_game_v4.1.py Game.js --advanced-report
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ? Corrections appliquées avec succès !
    echo ?? Lancement du jeu...
    timeout /t 2 /nobreak >nul
    start "" "index.html"
) else (
    echo.
    echo ? Erreur lors de la correction
)
pause
goto :MENU