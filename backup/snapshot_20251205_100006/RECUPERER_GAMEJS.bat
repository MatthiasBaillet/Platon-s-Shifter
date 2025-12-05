@echo off
setlocal

:: RECUPERATION Game.js v4.2 - SIMPLE ET SANS ERREUR
cd /d "%~dp0"

echo =========================================================
echo ?? RECUPERATION Game.js v4.2 (Ecriture directe)
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR : Python non trouve. Installez Python 3.8+
    pause
    exit /b 1
)

python RECUPERER_GAMEJS_FINAL.py

echo.
echo =========================================================
echo Termine. Appuyez sur une touche pour fermer.
echo =========================================================
echo.

pause >nul

endlocal