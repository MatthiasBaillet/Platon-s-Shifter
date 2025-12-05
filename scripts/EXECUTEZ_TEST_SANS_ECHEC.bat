@echo off
setlocal

:: TEST NODE.JS - VERSION SANS ÉCHEC POSSIBLE
:: Cette fenêtre RESTE OUVERTE

cd /d "%~dp0"

echo =========================================================
echo ?? TEST NODE.JS - VERSION DÉFINITIVE
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
echo ?? Exécution du test...
echo.
node test_game.js

:: Pause finale
echo.
pause

endlocal