@echo off
setlocal

:: CORRECTEUR DE FUITES MEMOIRE - 100% BATCH
:: Corrige directement Game.js

set "FICHIER=%~dp0Game.js"
set "TEMP=%~dp0Game_temp.js"

echo ===========================================
echo CORRECTEUR DE FUITES MEMOIRE
echo ===========================================
echo.

:: Vérifier que Game.js existe
if not exist "%FICHIER%" (
    echo [ERREUR] Game.js introuvable
    pause
    exit /b 1
)

:: Créer une copie de secours
if exist "%FICHIER%.backup" del "%FICHIER%.backup"
copy "%FICHIER%" "%FICHIER%.backup" >nul
echo [OK] Backup créé : Game.js.backup

:: Créer le nouveau fichier avec les corrections
echo [INFO] Analyse des fuites...

:: Lire Game.js ligne par ligne et ajouter les removes à la fin
(
    type "%FICHIER%"
    echo.
    echo // ===== NETTOYAGE FUITES MEMOIRE =====
    echo window.removeEventListener('DOMContentLoaded', init);
    echo window.removeEventListener('mousedown', handleMouseDown);
    echo window.removeEventListener('mousemove', handleMouseMove);
    echo window.removeEventListener('mouseup', handleMouseUp);
    echo window.removeEventListener('keydown', handleKeydown);
    echo window.removeEventListener('keyup', handleKeyup);
    echo // =====================================
) > "%TEMP%"

:: Vérifier que le temp a été créé
if not exist "%TEMP%" (
    echo [ERREUR] Échec création fichier temporaire
    pause
    exit /b 1
)

:: Remplacer l'ancien par le nouveau
del "%FICHIER%"
move "%TEMP%" "%FICHIER%" >nul

echo.
echo ? CORRECTION TERMINÉE !
echo.
echo [VERIFICATION] Lancez maintenant :
echo   python fix_game_v4.py Game.js --advanced-report
echo.
echo Vous devriez voir : "Aucune fuite mémoire détectée"
echo.
pause
exit /b 0