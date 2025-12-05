@echo off
setlocal

:: PLATON SHIFTER LAUNCHER - VERSION DEFINITIVE
:: GERE LES APOSTROPHES DANS LES CHEMINS

:: NE PAS SUPPRIMER L'APOSTROPHE ! On utilise le chemin tel quel
set "SCRIPT_DIR=%~dp0"

:: Assurez-vous que le chemin se termine par \
if not "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR%\"

set "CORRECTEUR=%SCRIPT_DIR%fix_game_v3.py"
set "GAME_JS=%SCRIPT_DIR%Game.js"
set "GAME_FIXED=%SCRIPT_DIR%Game_fixed.js"
set "GAME_BACKUP=%SCRIPT_DIR%Game.js.backup"

:: ============================================================
echo ===========================================
echo PLATON'S SHIFTER LAUNCHER v2.3
echo ===========================================
echo.

:: === VERIFICATION PYTHON ===
echo [ETAPE 1] Verification Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python non trouve dans le PATH
    pause
    exit /b 1
)
echo [OK] Python detecte

:: === VERIFICATION CORRECTEUR ===
echo.
echo [ETAPE 2] Verification du correcteur...
echo Chemin verifie : %CORRECTEUR%

if not exist "%CORRECTEUR%" (
    echo [ERREUR] Correcteur non trouve
    
    :: DEBUG : Afficher le contenu reel du dossier
    echo.
    echo DEBUG - Contenu du dossier :
    dir "%SCRIPT_DIR%"
    
    pause
    exit /b 1
)
echo [OK] Correcteur trouve

:: === VERIFICATION GAME.JS ===
echo.
echo [ETAPE 3] Verification Game.js...
echo Chemin verifie : %GAME_JS%

if not exist "%GAME_JS%" (
    echo [ERREUR] Game.js MANQUANT
    echo Dossier : %SCRIPT_DIR%
    echo.
    echo Conseils :
    echo   1. Placez Game.js DANS ce dossier
    echo   2. Verifiez le nom exacte : Game.js (G majuscule)
    echo   3. Le chemin contient-il des caracteres speciaux ?
    pause
    exit /b 1
)
echo [OK] Game.js trouve

:: === VERIFICATION NODE.JS (optionnel) ===
echo.
echo [ETAPE 4] Verification Node.js (optionnel)...
node --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Node.js non trouve - validation desactivee
) else (
    for /f "tokens=*" %%v in ('node --version') do echo [OK] Node.js %%v detecte
)

:GOTO_MENU

:MENU
echo.
echo ===========================================
echo MENU
echo ===========================================
echo.
echo 1 - Corriger (applique + valide)
echo 2 - Simulation (teste sans modifier)
echo 3 - Renommer Game_fixed.js en Game.js
echo 4 - Restaurer depuis backup
echo 5 - Nettoyer anciens backups
echo 0 - Quitter
echo.
set /p choix="Choix (0-5) : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" goto :SIMULATION
if "%choix%"=="3" goto :RENOMMER_MANUEL
if "%choix%"=="4" goto :RESTAURER
if "%choix%"=="5" goto :NETTOYER
if "%choix%"=="0" goto :FIN
echo Choix invalide
goto :MENU

:CORRIGER
echo.
echo =========================================
echo LANCEMENT DE LA CORRECTION...
echo =========================================
echo.

:: Se placer dans le dossier avant d'executer Python
cd /d "%SCRIPT_DIR%"
python fix_game_v3.py Game.js

if not exist "%GAME_FIXED%" (
    echo.
    echo [ERREUR] La correction a echoue (Game_fixed.js non cree)
    pause
    goto :MENU
)

echo.
echo [OK] Correction terminee !
echo.
set /p reponse="Renommer Game_fixed.js -> Game.js maintenant ? (o/n) : "
if /i "%reponse%"=="o" goto :RENOMMER_AUTO
goto :MENU

:SIMULATION
echo.
echo =========================================
echo LANCEMENT DE LA SIMULATION...
echo =========================================
echo.

cd /d "%SCRIPT_DIR%"
python fix_game_v3.py Game.js --dry-run

echo.
pause
goto :MENU

:RENOMMER_AUTO
echo.
echo Renommage en cours...
if exist "%GAME_JS%" (
    if exist "%GAME_BACKUP%" del "%GAME_BACKUP%" >nul 2>&1
    copy "%GAME_JS%" "%GAME_BACKUP%" >nul 2>&1
    echo [OK] Backup cree : Game.js.backup
)
move "%GAME_FIXED%" "%GAME_JS%" >nul 2>&1
echo [OK] Renommage termine !
echo.
echo Le jeu est pret a etre teste !
echo Double-cliquez sur index.html
pause
goto :MENU

:RENOMMER_MANUEL
echo.
if not exist "%GAME_FIXED%" (
    echo [ERREUR] Game_fixed.js n'existe pas
    pause
    goto :MENU
)

set /p confirm="Renommer Game_fixed.js -> Game.js ? (o/n) : "
if /i "%confirm%"=="o" goto :RENOMMER_AUTO
goto :MENU

:RESTAURER
echo.
if not exist "%GAME_BACKUP%" (
    echo [ERREUR] Aucun backup trouve
    pause
    goto :MENU
)

set /p confirm="Restaurer depuis Game.js.backup ? (o/n) : "
if /i "%confirm%"=="o" (
    copy "%GAME_BACKUP%" "%GAME_JS%" >nul 2>&1
    echo [OK] Restauration effectuee
)
pause
goto :MENU

:NETTOYER
echo.
echo Recherche de vieux backups...
for %%f in ("%SCRIPT_DIR%*.backup") do (
    echo Suppression : %%~nxf
    del "%%f" >nul 2>&1
)
echo [OK] Nettoyage termine
pause
goto :MENU

:FIN
echo.
echo Fin du script
timeout /t 2 >nul
exit /b 0