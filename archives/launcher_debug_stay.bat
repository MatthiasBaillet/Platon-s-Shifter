@echo off
setlocal

:: VERSION DEBUG QUI RESTE OUVERTE
set "SCRIPT_DIR=%~dp0"

echo ===========================================
echo DEBUG - AFFICHAGE DU CONTENU DU DOSSIER
echo ===========================================
echo Dossier : %SCRIPT_DIR%
echo.

:: === VÉRIFICATION DOSSIER ===
if not exist "%SCRIPT_DIR%" (
    echo ERREUR CRITIQUE : Le dossier n'existe pas !
    echo Chemin teste : %SCRIPT_DIR%
    echo.
    echo Appuyez sur une touche pour quitter...
    pause >nul
    exit /b 1
)
echo [OK] Dossier existe

:: === LISTAGE FICHIERS ===
echo.
echo Fichiers dans le dossier :
dir "%SCRIPT_DIR%" /b
echo.

echo ===========================================
echo VERIFICATION SPECIFIQUE
echo ===========================================
echo.

:: Vérifier avec guillemets
if exist "%SCRIPT_DIR%\fix_game_v3.py" (
    echo [OK] fix_game_v3.py existe (avec guillemets)
) else (
    echo [ERREUR] fix_game_v3.py MANQUANT (avec guillemets)
)

if exist "%SCRIPT_DIR%\Game.js" (
    echo [OK] Game.js existe (avec guillemets)
) else (
    echo [ERREUR] Game.js MANQUANT (avec guillemets)
)

echo.
echo Chemins complets verifies :
echo   - Correcteur : %SCRIPT_DIR%\fix_game_v3.py
echo   - Jeu        : %SCRIPT_DIR%\Game.js
echo.

:: === STATUT FINAL ===
echo ===========================================
echo FIN DU DEBUG
echo ===========================================
echo Appuyez sur ENTREE pour fermer...
pause >nul
exit /b 0