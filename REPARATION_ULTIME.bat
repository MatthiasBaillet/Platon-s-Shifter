@echo OFF
chcp 65001 >nul
color 0E
echo ============================================
echo   ?? RÉPARATION FORCEE - RECHERCHE BACKUP
echo ============================================
echo.

:: ÉTAPE 0 : Diagnostic de recherche forcée
echo ?? RECHERCHE FORCÉE DE TOUS LES FICHIERS Game* :

set "BACKUP_TROUVE="
set "BACKUP_NOM="

for %%F in ("Game*") do (
    echo    - "%%~nxF" (taille: %%~zF bytes)
    if "%%~zF"=="29973" (
        echo       ? C'EST LE BACKUP (29 973 bytes)
        set "BACKUP_TROUVE=1"
        set "BACKUP_NOM=%%~nxF"
    )
)

echo.

:: ÉTAPE 1 : Copie forcée du fichier de 29 KB
if defined BACKUP_TROUVE (
    echo 1??  COPIE DU BACKUP COMPLET...
    echo    Nom réel du backup : "%BACKUP_NOM%"
    copy /Y "%BACKUP_NOM%" Game.js >nul
    if !ERRORLEVEL! EQU 0 (
        for %%F in (Game.js) do echo ? Restauré (%%~zF bytes)
    ) else (
        echo ? Erreur de copie
        pause
        exit /b 1
    )
) else (
    echo ? AUCUN FICHIER DE 29 973 BYTES TROUVÉ
    echo    Vérifiez visuellement votre dossier
    pause
    exit /b 1
)

:: ÉTAPE 2 : Préparation correcteur
echo.
echo 2??  PRÉPARATION CORRECTEUR...
mkdir correcteurs 2>nul
if exist "CORRECTEUR_FINAL_V4.2.py" (
    move /Y CORRECTEUR_FINAL_V4.2.py correcteurs\ >nul
    echo ? Correcteur déplacé dans correcteurs/
) else if exist "correcteurs\CORRECTEUR_FINAL_V4.2.py" (
    echo ? Correcteur déjà en place
) else (
    echo ? Correcteur V4.2 manquant - Téléchargez-le
    pause
    exit /b 1
)

:: ÉTAPE 3 : Application correcteur
echo.
echo 3??  APPLICATION CORRECTEUR V4.2...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js --force
if !ERRORLEVEL! EQU 0 (
    echo ? Correcteur appliqué
    for %%F in (Game_fixed.js) do echo    Nouvelle taille : %%~zF bytes
) else (
    echo ? Échec correcteur
    pause
    exit /b 1
)

:: ÉTAPE 4 : Remplacement final
echo.
echo 4??  REMPLACEMENT FINAL...
copy /Y Game.js Game.js.original >nul
copy /Y Game_fixed.js Game.js >nul
if exist "Game_fixed.js" del Game_fixed.js
echo ? Remplacement effectué

:: ÉTAPE 5 : Lanceur
echo.
echo 5??  CRÉATION LANCEUR SIMPLIFIÉ...
> LANCER_PLATON.bat (
    echo @echo OFF
    echo chcp 65001 ^>nul
    echo color 0A
    echo echo =================================
    echo echo   PLATON'S SHIFTER - PLAY NOW
    echo echo =================================
    echo echo 1. Lancer le jeu
    echo echo 2. Rien
    echo echo 3. Quitter
    echo set /p c="Choix : "
    echo if "%%c%%"=="1" start "" index.html
    echo if "%%c%%"=="3" exit
)
echo ? Lanceur créé

:: ÉTAPE 6 : Test
echo.
echo 6??  TEST DU JEU...
start "" index.html
timeout /t 2 >nul
echo ? Jeu lancé

echo.
echo ============================================
echo ? RÉPARATION ULTIME TERMINÉE
echo ============================================
echo ?? DOUBLE-CLIQUER SUR : LANCER_PLATON.bat
echo    Puis tapez 1 pour jouer
echo ============================================
pause