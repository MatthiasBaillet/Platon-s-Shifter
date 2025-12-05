@echo off
setlocal

:: TEST NODE.JS FINAL - FENÊTRE OUVERTE GARANTIE

cd /d "%~dp0"

echo =========================================================
echo ?? TEST NODE.JS - VERSION FINALE CORRIGÉE
echo =========================================================
echo.

:: Vérifier test_game.js
if not exist "test_game.js" (
    echo ? test_game.js introuvable !
    pause
    exit /b 1
)

:: Vérifier Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Node.js non trouvé. Installez depuis https://nodejs.org/
    pause
    exit /b 1
)

:: Exécuter le test
echo ?? Exécution...
echo.
node test_game.js

:: Pause finale
echo.
pause

endlocal