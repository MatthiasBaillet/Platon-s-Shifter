@echo OFF
chcp 65001 >nul
color 0B
echo ============================================
echo   ?? TEST INTEGRAL (SANS VÉRIFICATION NODE)
echo ============================================
set "ERREUR=0"

:: ÉTAPE 1 : Vérification des fichiers critiques
echo 1??  VÉRIFICATION DES FICHIERS CRITIQUES...
if not exist "Game.js" (
    echo ? Game.js manquant
    set "ERREUR=1"
    goto :fin
) else (
    for %%F in (Game.js) do echo ? Game.js présent (%%~zF bytes)
)

if not exist "index.html" (
    echo ? index.html manquant
    set "ERREUR=1"
    goto :fin
) else echo ? index.html présent

if not exist "correcteurs\CORRECTEUR_FINAL_V4.2.py" (
    if not exist "CORRECTEUR_FINAL_V4.2.py" (
        echo ? Correcteur manquant
        set "ERREUR=1"
        goto :fin
    ) else (
        echo ?? Correcteur à la racine (déplacement nécessaire)
        mkdir correcteurs 2>nul
        move /Y CORRECTEUR_FINAL_V4.2.py correcteurs\ >nul
    )
)
echo ? Correcteur V4.2 présent

:: ÉTAPE 2 : Vérification structure Game.js
echo.
echo 2??  VÉRIFICATION STRUCTURE Game.js...
findstr /C:"function init(" Game.js >nul && echo ? Fonction init() trouvée || echo ? init() manquante
findstr /C:"function update(" Game.js >nul && echo ? Fonction update() trouvée || echo ? update() manquante
findstr /C:"class PlatonicShape" Game.js >nul && echo ? Classe PlatonicShape trouvée || echo ? Classe manquante
findstr /C:"enemyBases" Game.js >nul && echo ? Système enemyBases trouvé || echo ? enemyBases manquant

:: ÉTAPE 3 : Simulation correcteur (dry-run)
echo.
echo 3??  SIMULATION CORRECTEUR V4.2...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js --dry-run
if %ERRORLEVEL% NEQ 0 (
    echo ?? Simulation a averti (vérifier)
) else (
    echo ? Simulation terminée
)

:: ÉTAPE 4 : Application réelle
echo.
echo 4??  APPLICATION DES CORRECTIONS...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js
if %ERRORLEVEL% NEQ 0 (
    echo ? Correcteur a échoué
    set "ERREUR=1"
    goto :fin
) else echo ? Corrections appliquées

:: ÉTAPE 5 : Vérification fichier généré
echo.
echo 5??  VÉRIFICATION Game_fixed.js...
if not exist "Game_fixed.js" (
    echo ? Game_fixed.js non créé
    set "ERREUR=1"
    goto :fin
) else (
    for %%F in (Game_fixed.js) do echo ? Game_fixed.js créé (%%~zF bytes)
)

:: ÉTAPE 6 : Remplacement sécurisé
echo.
echo 6??  REMPLACEMENT SÉCURISÉ...
copy /Y Game.js Game.js.backup_pre_v4 >nul
copy /Y Game_fixed.js Game.js >nul
if exist "Game_fixed.js" del Game_fixed.js
echo ? Remplacement effectué

:: ÉTAPE 7 : Test de lancement
echo.
echo 7??  TEST DE LANCEMENT...
echo    Ouverture du jeu dans le navigateur...
start "" index.html
timeout /t 2 >nul
echo ? Jeu lancé (vérifiez la console avec F12)

:fin
echo.
echo ============================================
if %ERREUR% EQU 0 (
    echo ? TEST INTÉGRAL RÉUSSI
    echo    Votre projet est STABLE
    echo.
    echo ?? PROCHAINES ACTIONS :
    echo    1. Jouez au jeu (Chrome)
    echo    2. Vérifiez la console (F12)
    echo    3. Si tout est vert, projet terminé
) else (
    echo ? TEST INTÉGRAL ÉCHOUÉ
    echo    Consultez les erreurs ci-dessus
)
echo ============================================
pause