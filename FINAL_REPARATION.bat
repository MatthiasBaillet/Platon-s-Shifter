@echo OFF
chcp 65001 >nul
color 0E
echo ============================================
echo   ?? RÉPARATION FINALE - PLATON'S SHIFTER
echo ============================================
echo.

:: ÉTAPE 1 : Restauration du backup complet
echo 1??  RESTAURATION DU BACKUP COMPLET...
if exist "Game_fixed.js.backup" (
    echo ?? Backup trouvé (29 973 bytes)
    echo    Restauration en cours...
    copy /Y Game_fixed.js.backup Game.js >nul
    if !ERRORLEVEL! EQU 0 (
        for %%F in (Game.js) do echo ? Restauré (%%~zF bytes)
    )
) else (
    echo ? Backup non trouvé
    pause
    exit /b 1
)

:: ÉTAPE 2 : Vérification structure post-restauration
echo.
echo 2??  VÉRIFICATION STRUCTURE...
findstr /C:"class PlatonicShape" Game.js >nul && echo ? PlatonicShape OK || echo ? PlatonicShape manquant
findstr /C:"enemyBases" Game.js >nul && echo ? enemyBases OK || echo ? enemyBases manquant

:: ÉTAPE 3 : Création dossier correcteur
echo.
echo 3??  PRÉPARATION CORRECTEUR...
if not exist "correcteurs" mkdir correcteurs
if exist "CORRECTEUR_FINAL_V4.2.py" (
    move /Y CORRECTEUR_FINAL_V4.2.py correcteurs\ >nul
    echo ? Correcteur déplacé dans correcteurs/
)

:: ÉTAPE 4 : Application correcteur V4.2
echo.
echo 4??  APPLICATION CORRECTEUR V4.2...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js --force
if !ERRORLEVEL! EQU 0 (
    echo ? Correcteur appliqué
    for %%F in (Game_fixed.js) do echo    Nouvelle taille : %%~zF bytes
) else (
    echo ? Échec correcteur
    pause
    exit /b 1
)

:: ÉTAPE 5 : Remplacement final
echo.
echo 5??  REMPLACEMENT FINAL...
copy /Y Game.js Game.js.v4_original >nul
copy /Y Game_fixed.js Game.js >nul
del Game_fixed.js
echo ? Remplacement effectué

:: ÉTAPE 6 : Test de lancement
echo.
echo 6??  TEST DE LANCEMENT DU JEU...
start "" index.html
timeout /t 3 >nul
echo ? Jeu lancé dans Chrome

:: ÉTAPE 7 : Création du lanceur final
echo.
echo 7??  CRÉATION LANCEUR FINAL...
(
echo @echo OFF
echo chcp 65001 ^>nul
echo color 0A
echo echo ==========================================
echo echo   PLATON'S SHIFTER - V4.2 STABLE
echo echo ==========================================
echo echo.
echo echo 1. ?? DIAGNOSTIC
echo echo 2. ?? CORRIGER
echo echo 3. ?? JOUER
echo echo 4. ?? QUITTER
echo echo.
echo set /p choix="? Choix : "
echo if "%%choix%%"=="1" call diagnostic_game.bat
echo if "%%choix%%"=="2" python correcteurs\\CORRECTEUR_FINAL_V4.2.py Game.js
echo if "%%choix%%"=="3" start "" index.html
echo if "%%choix%%"=="4" exit
) > LANCER_PLATON.bat

echo ? Lanceur créé : LANCER_PLATON.bat

:: RÉSUMÉ FINAL
echo.
echo ============================================
echo ? RÉPARATION TERMINÉE
echo ============================================
echo ?? UTILISATION :
echo    Double-cliquez sur LANCER_PLATON.bat
echo    Choisissez 3 pour jouer au jeu
echo.
echo ?? Fichiers créés :
echo    - Game.js (version corrigée V4.2)
echo    - Game.js.v4_original (backup original)
echo    - LANCER_PLATON.bat (lanceur unique)
echo ============================================
pause