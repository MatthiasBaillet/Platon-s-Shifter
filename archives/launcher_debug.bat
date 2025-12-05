@echo off
setlocal

:: VERSION DEBUG MAXIMALE
set "SCRIPT_DIR=%~dp0"

echo ===========================================
echo DEBUG - AFFICHAGE DU CONTENU DU DOSSIER
echo ===========================================
echo Dossier : %SCRIPT_DIR%
echo.

:: Lister TOUS les fichiers .js et .py
echo Fichiers JS et Python dans le dossier :
dir "%SCRIPT_DIR%\*.js" /b
dir "%SCRIPT_DIR%\*.py" /b
echo.

:: Vérifier chaque fichier individuellement
echo Verification individuelle :
if exist "%SCRIPT_DIR%fix_game_v3.py" (
    echo [OK] fix_game_v3.py existe
) else (
    echo [ERREUR] fix_game_v3.py MANQUANT
)

if exist "%SCRIPT_DIR%Game.js" (
    echo [OK] Game.js existe
) else (
    echo [ERREUR] Game.js MANQUANT
)

if exist "%SCRIPT_DIR%game.js" (
    echo [INFO] game.js (minuscule) existe - RENOMMER EN Game.js
)

:: Vérifier la casse exacte
echo.
echo Contenu detaille (nom exacte) :
for %%f in ("%SCRIPT_DIR%\Game.js") do echo Game.js : %%~nxf
for %%f in ("%SCRIPT_DIR%\game.js") do echo game.js : %%~nxf

echo.
pause

:: Si vous voyez Game.js ici, le batch ci-dessous fonctionnera