@echo off
setlocal

:: PLATON'S SHIFTER - DIAGNOSTIC AUTOMATIQUE
:: Détecte les erreurs JavaScript et les IDs manquants

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo ===========================================
echo DIAGNOSTIC AUTOMATIQUE DU JEU
echo ===========================================
echo.

:: === ÉTAPE 1 : Vérifier les fichiers essentiels ===
echo [ÉTAPE 1] Vérification des fichiers essentiels...
echo.

if exist "index.html" (
    echo [OK] index.html trouvé
) else (
    echo [ERREUR] index.html MANQUANT
    goto :FIN
)

if exist "Game.js" (
    echo [OK] Game.js trouvé
    echo [INFO] Taille : %~z1 bytes
) else (
    echo [ERREUR] Game.js MANQUANT
    goto :FIN
)

:: === ÉTAPE 2 : Vérifier la syntaxe JavaScript ===
echo.
echo [ÉTAPE 2] Validation syntaxe Game.js avec Node.js...
echo.

if exist "Game.js" (
    node -c "Game.js" 2>temp_error.log
    if errorlevel 1 (
        echo [ERREUR] Syntaxe Game.js invalide :
        type temp_error.log
        echo.
        goto :ANALYSE_DETAILLEE
    ) else (
        echo [OK] Syntaxe JavaScript valide
    )
) else (
    echo [ERREUR] Impossible de valider Game.js
)

:: === ÉTAPE 3 : Vérifier les IDs dans index.html ===
echo.
echo [ÉTAPE 3] Vérification des IDs dans index.html...
echo.

:: Rechercher le canvas
findstr /C:"id=\"gameCanvas\"" "index.html" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Canvas 'gameCanvas' non trouvé dans index.html
    echo Vérifiez : <canvas id="gameCanvas"></canvas>
) else (
    echo [OK] Canvas 'gameCanvas' trouvé
)

:: Rechercher le div pour le HUD
findstr /C:"id=\"hud" "index.html" >nul 2>&1
if errorlevel 1 (
    echo [AVERTISSEMENT] HUD manquant dans index.html
    echo Vérifiez : <div id="hud">...</div>
) else (
    echo [OK] éléments HUD trouvés
)

:: === ÉTAPE 4 : Ouvrir la console pour voir les erreurs ===
:ANALYSE_DETAILLEE
echo.
echo ===========================================
echo [ÉTAPE 4] Lancement du jeu en mode debug...
echo ===========================================
echo.
echo Le jeu va s'ouvrir dans votre navigateur.
echo OUVREZ LA CONSOLE (F12) POUR VOIR LES ERREURS !
echo.
echo Appuyez sur une touche pour ouvrir le jeu...
pause >nul

start "" "index.html"

echo.
echo Attendez 5 secondes puis revenez ici...
timeout /t 5 >nul

:: Rechercher les erreurs courantes
echo.
echo [ÉTAPE 5] Recherche d'erreurs courantes...

:: Vérifier si la fonction init existe
findstr /C:"function init(" "Game.js" >nul 2>&1
if errorlevel 1 (
    echo [AVERTISSEMENT] Fonction init() non trouvée dans Game.js
) else (
    echo [OK] Fonction init() présente
)

:: Vérifier si gameLoop existe
findstr /C:"function gameLoop(" "Game.js" >nul 2>&1
if errorlevel 1 (
    echo [AVERTISSEMENT] Fonction gameLoop() non trouvée
) else (
    echo [OK] Boucle de jeu présente
)

:: Vérifier les variables essentielles
findstr /C:"canvas =" "Game.js" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Variable 'canvas' non déclarée
) else (
    echo [OK] Variable 'canvas' trouvée
)

findstr /C:"ctx =" "Game.js" >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Variable 'ctx' (contexte) non déclarée
) else (
    echo [OK] Variable 'ctx' trouvée
)

:: === FIN DU DIAGNOSTIC ===
:FIN
echo.
echo ===========================================
echo DIAGNOSTIC TERMINÉ
echo ===========================================
echo.

if exist "temp_error.log" del "temp_error.log"

echo ?? RÉSUMÉ DES ACTIONS :
echo   - Vérifiez la console du navigateur (F12)
echo   - Corrigez les erreurs signalées ci-dessus
echo   - Relancez ce diagnostic après correction
echo.
echo ?? POUR VOIR LES ERREURS EN TEMPS RÉEL :
echo   Ouvrez index.html ? F12 ? Onglet "Console"
echo.
pause
exit /b 0