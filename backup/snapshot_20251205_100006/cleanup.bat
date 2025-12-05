@echo off
setlocal

:: ===========================================
:: PLATON'S SHIFTER - NETTOYAGE INTELLIGENT
:: Supprime uniquement les fichiers superflus
:: ===========================================

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

echo ===========================================
echo NETTOYAGE INTELLIGENT DU PROJET
echo ===========================================
echo.

:: === CRÉER UN DOSSIER ARCHIVES POUR LES FICHIERS OBSOLÈTES ===
if not exist "archives" mkdir archives

:: === LISTE DES FICHIERS À CONSERVER (les indispensables) ===
:: Game.js, fix_game_v4.py, launcher_final.bat, PROJECT_STATE.md, CHECKPOINT.md
:: index.html, Game.js.backup*, *.bat, *.md (utiles)

:: === DÉPLACER LES FICHIERS OBSOLÈTES VERS archives ===
echo [INFO] Archivage des anciens scripts...

:: Anciens installateurs (superflus après installation)
if exist "install_v4.py" move "install_v4.py" "archives\" >nul 2>&1
if exist "create_fixer.py" move "create_fixer.py" "archives\" >nul 2>&1
if exist "installer_finale.py" move "installer_finale.py" "archives\" >nul 2>&1
if exist "setup_project.bat" move "setup_project.bat" "archives\" >nul 2>&1

:: Anciens patchs (plus nécessaires)
if exist "patch_v4.bat" move "patch_v4.bat" "archives\" >nul 2>&1
if exist "correction_regex.bat" move "correction_regex.bat" "archives\" >nul 2>&1

:: Anciens launchers (remplacés par launcher_final.bat)
if exist "launcher_v2.bat" move "launcher_v2.bat" "archives\" >nul 2>&1
if exist "launcher_v2_fixed.bat" move "launcher_v2_fixed.bat" "archives\" >nul 2>&1
if exist "launcher_v2_simple.bat" move "launcher_v2_simple.bat" "archives\" >nul 2>&1
if exist "launcher_debug.bat" move "launcher_debug.bat" "archives\" >nul 2>&1
if exist "launcher_debug_stay.bat" move "launcher_debug_stay.bat" "archives\" >nul 2>&1

:: Anciens correcteurs (remplacés par v4)
if exist "fix_game_v2.py" move "fix_game_v2.py" "archives\" >nul 2>&1
if exist "fix_game_v3.py" move "fix_game_v3.py" "archives\" >nul 2>&1

:: Fichiers temporaires
if exist "install_v4.log" move "install_v4.log" "archives\" >nul 2>&1
if exist "upgrade_v4.log" move "upgrade_v4.log" "archives\" >nul 2>&1
if exist "temp_validation.js" del "temp_validation.js" >nul 2>&1

:: === NETTOYER LES FICHIERS DE DÉBOGAGE ===
echo [INFO] Suppression des fichiers temporaires...
del /q *.tmp >nul 2>&1
del /q *.log >nul 2>&1 2>nul

:: === RAPPORT FINAL ===
echo.
echo ===========================================
echo RAPPORT DE NETTOYAGE
echo ===========================================
echo.

:: Compter les fichiers déplacés
set "ARCHIVES_COUNT=0"
for %%f in (archives\*.*) do set /a ARCHIVES_COUNT+=1

if %ARCHIVES_COUNT%==0 (
    echo ? Aucun fichier superflu trouvé. Le projet est déjà propre !
) else (
    echo ?? %ARCHIVES_COUNT% fichiers archivés dans le dossier "archives/"
    echo.
    echo ?? Fichiers conservés (essentiels) :
    echo   - Game.js
    echo   - fix_game_v4.py
    echo   - launcher_final.bat
    echo   - PROJECT_STATE.md
    echo   - CHECKPOINT.md
    echo   - index.html
    echo   - Game.js.backup* (versions sauvegardées)
    echo.
    echo ??? Fichiers archivés (obsolètes) :
    dir /b archives\ 2>nul
)

echo.
echo ===========================================
echo ? NETTOYAGE TERMINÉ !
echo ===========================================
echo.
echo Votre répertoire est maintenant propre et organisé.
echo Pour tester : double-cliquez sur launcher_final.bat
echo.
pause
exit /b 0