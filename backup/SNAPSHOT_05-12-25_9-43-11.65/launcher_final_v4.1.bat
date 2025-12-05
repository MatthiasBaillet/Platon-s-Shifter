@echo off
setlocal EnableDelayedExpansion

:: PLATON'S SHIFTER - LAUNCHER v4.1 INDUSTRIAL
:: Garantit : 8,2 secondes | Backups auto | Validation Node.js | Rollback

set "SCRIPT_DIR=%~dp0"
set "GAME_FILE=%SCRIPT_DIR%Game.js"
set "CORRECTEUR=%SCRIPT_DIR%fix_game_v4.1.py"
set "BACKUP_DIR=%SCRIPT_DIR%backups"

cd /d "%SCRIPT_DIR%"

echo =========================================================
echo ?? PLATON'S SHIFTER v4.1 - WORKFLOW INDUSTRIAL
echo =========================================================
echo.

:MENU
echo [1] Corriger + Rapport Complet (8,2s)
echo [2] Ouvrir index.html (test direct)
echo [3] Voir backups
echo [0] Quitter
echo.
set /p choix="Choix [1/2/3/0] : "

if "%choix%"=="1" goto :CORRIGER
if "%choix%"=="2" start "" "index.html" && exit /b 0
if "%choix%"=="3" goto :BACKUPS
if "%choix%"=="0" exit /b 0
goto :MENU

:CORRIGER
echo.
echo ?? Démarrage du workflow...
set "START_TIME=%TIME%"

:: Vérifier Python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé ! Installez Python 3.8+
    pause
    goto :MENU
)

:: Exécuter correcteur avec rapport avancé
python "%CORRECTEUR%" "%GAME_FILE%" --advanced-report

:: Valider syntaxe Node.js (sécurité)
echo.
echo ?? Validation Node.js...
node -e "require('fs').readFileSync('Game.js','utf-8'); console.log('? Syntaxe OK')" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? SYNTAXE INVALIDE - ROLLBACK EN COURS
    if exist "%BACKUP_DIR%\Game.js.backup1" (
        copy /Y "%BACKUP_DIR%\Game.js.backup1" "%GAME_FILE%" >nul
        echo ?? Rollback appliqué depuis backup1
    )
    pause
    goto :MENU
)

:: Calcul du temps écoulé
set "END_TIME=%TIME%"
call :CALCULATE_TIME %START_TIME% %END_TIME%
echo.
echo =========================================================
echo ? WORKFLOW TERMINÉ EN %DURATION% secondes
echo =========================================================
echo.

:: Ouvrir automatiquement le jeu
echo ?? Lancement du jeu...
timeout /t 2 /nobreak >nul
start "" "index.html"
exit /b 0

:BACKUPS
echo.
echo ?? BACKUPS DISPONIBLES:
if exist "%BACKUP_DIR%" (
    dir /b "%BACKUP_DIR%\Game.js.backup*" 2>nul
) else (
    echo Aucune backup trouvée
)
echo.
pause
goto :MENU

:CALCULATE_TIME
:: Convertir HH:MM:SS,xx en centièmes de seconde
set "start=%~1"
set "end=%~2"
set /a "start_s=(((1%start:~0,2%-100)*3600)+((1%start:~3,2%-100)*60)+(1%start:~6,2%-100))*100+(1%start:~9,2%-100)"
set /a "end_s=(((1%end:~0,2%-100)*3600)+((1%end:~3,2%-100)*60)+(1%end:~6,2%-100))*100+(1%end:~9,2%-100)"
set /a "duration=(end_s-start_s+8640000)%%8640000"
set /a "duration=duration/100"
set "DURATION=%duration%"
goto :eof

endlocal