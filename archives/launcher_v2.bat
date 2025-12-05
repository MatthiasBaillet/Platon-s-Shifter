@echo off
setlocal
chcp 65001 >nul 2>&1  :: Passer en UTF-8 pour les accents

:: PLATON SHIFTER LAUNCHER - VERSION AMÉLIORÉE
:: ENREGISTRER EN UTF-8 SANS BOM

:: Activation des couleurs Windows 10+
if "%OS%"=="Windows_NT" (
    reg query HKCU\Console /v VirtualTerminalLevel >nul 2>&1
    if errorlevel 1 (
        reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
    )
)

:: Variables
set "SCRIPT_DIR=%~dp0"
set "CORRECTEUR=%SCRIPT_DIR%fix_game_v3.py"
set "GAME_JS=%SCRIPT_DIR%Game.js"
set "GAME_FIXED=%SCRIPT_DIR%Game_fixed.js"
set "GAME_BACKUP=%SCRIPT_DIR%Game.js.backup"

:: Couleurs ANSI
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

echo %BLUE%
echo ===========================================
echo PLATON'S SHIFTER LAUNCHER v2.0
echo ===========================================
echo %RESET%

:: === VÉRIFICATION PYTHON ===
echo %BLUE%[ÉTAPE 1]%RESET% Vérification Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%✗%RESET% Python non trouvé dans le PATH
    echo.
    echo Solutions :
    echo   1. Installer Python 3.x depuis python.org
    echo   2. Cocher "Add Python to PATH" lors de l'installation
    pause
    exit /b 1
)
echo %GREEN%✓%RESET% Python détecté

:: === VÉRIFICATION NODE.JS (optionnel mais recommandé) ===
echo.
echo %BLUE%[ÉTAPE 2]%RESET% Vérification Node.js (validation)...
node --version >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%⚠%RESET% Node.js non trouvé - validation désactivée
) else (
    echo %GREEN%✓%RESET% Node.js détecté
)

:: === VÉRIFICATION FICHIERS ===
echo.
echo %BLUE%[ÉTAPE 3]%RESET% Vérification des fichiers...
if not exist "%CORRECTEUR%" (
    echo %RED%✗%RESET% Correcteur non trouvé : %CORRECTEUR%
    pause
    exit /b 1
)
echo %GREEN%✓%RESET% Correcteur trouvé

if not exist "%GAME_JS%" (
    echo %RED%✗%RESET% Game.js MANQUANT
    echo.
    echo Vérifiez que Game.js est dans le même dossier que ce launcher
    pause
    exit /b 1
)
echo %GREEN%✓%RESET% Game.js trouvé

:MENU
echo.
echo %BLUE%===========================================%RESET%
echo MENU
echo %BLUE%===========================================%RESET%
echo.
echo %GREEN%1%RESET% - Corriger (%YELLOW%applique + valide%RESET%)
echo %BLUE%2%RESET% - Simulation (%YELLOW%teste sans modifier%RESET%)
echo %YELLOW%3%RESET% - Renommer Game_fixed.js → Game.js
echo %RED%4%RESET% - Restaurer depuis backup
echo %GREEN%5%RESET% - Nettoyer anciens backups
echo %RED%0%RESET% - Quitter
echo.
set /p choix="Choix (0-5) : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" goto :SIMULATION
if "%choix%"=="3" goto :RENOMMER_MANUEL
if "%choix%"=="4" goto :RESTAURER
if "%choix%"=="5" goto :NETTOYER
if "%choix%"=="0" goto :FIN
echo %RED%Choix invalide%RESET%
goto :MENU

:CORRIGER
echo.
echo %GREEN%════════════════════════════════════════%RESET%
echo LANCEMENT DE LA CORRECTION...
echo %GREEN%════════════════════════════════════════%RESET%
echo.

python "%CORRECTEUR%" "%GAME_JS%"

:: Vérification si le fichier corrigé a été créé
if not exist "%GAME_FIXED%" (
    echo.
    echo %RED%✗%RESET% La correction a échoué (Game_fixed.js non créé)
    pause
    goto :MENU
)

echo.
echo %GREEN%✓%RESET% Correction terminée !
echo.
set /p reponse="Renommer Game_fixed.js → Game.js maintenant ? (o/n) : "
if /i "%reponse%"=="o" goto :RENOMMER_AUTO
goto :MENU

:SIMULATION
echo.
echo %BLUE%════════════════════════════════════════%RESET%
echo LANCEMENT DE LA SIMULATION...
echo %BLUE%════════════════════════════════════════%RESET%
echo.

python "%CORRECTEUR%" "%GAME_JS%" --dry-run

echo.
pause
goto :MENU

:RENOMMER_AUTO
echo.
echo %YELLOW%Renommage en cours...%RESET%
if exist "%GAME_JS%" (
    move "%GAME_JS%" "%GAME_BACKUP%" >nul 2>&1
    echo %GREEN%✓%RESET% Backup créé : Game.js.backup
)
move "%GAME_FIXED%" "%GAME_JS%" >nul 2>&1
echo %GREEN%✓%RESET% Renommage terminé !
echo.
echo %GREEN%Le jeu est prêt à être testé !%RESET%
echo Double-cliquez sur index.html
pause
goto :MENU

:RENOMMER_MANUEL
echo.
if not exist "%GAME_FIXED%" (
    echo %RED%✗%RESET% Game_fixed.js n'existe pas
    pause
    goto :MENU
)

set /p confirm="Renommer Game_fixed.js → Game.js ? (o/n) : "
if /i "%confirm%"=="o" goto :RENOMMER_AUTO
goto :MENU

:RESTAURER
echo.
if not exist "%GAME_BACKUP%" (
    echo %RED%✗%RESET% Aucun backup trouvé
    pause
    goto :MENU
)

set /p confirm="Restaurer depuis Game.js.backup ? (o/n) : "
if /i "%confirm%"=="o" (
    copy "%GAME_BACKUP%" "%GAME_JS%" >nul 2>&1
    echo %GREEN%✓%RESET% Restauration effectuée
)
goto :MENU

:NETTOYER
echo.
echo %YELLOW%Recherche de vieux backups...%RESET%
for %%f in ("%SCRIPT_DIR%*.backup") do (
    echo Suppression : %%~nxf
    del "%%f" >nul 2>&1
)
echo %GREEN%✓%RESET% Nettoyage terminé
pause
goto :MENU

:FIN
echo.
echo %BLUE%Fin du script%RESET%
timeout /t 2 >nul
exit /b 0