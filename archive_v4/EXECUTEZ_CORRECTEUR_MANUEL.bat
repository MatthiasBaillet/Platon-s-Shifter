@echo off
setlocal

:: CORRECTEUR MANUEL ULTRA-PRECIS - FENETRE OUVERTE
cd /d "%~dp0"

echo =========================================================
echo CORRECTEUR MANUEL ULTRA-PRECIS
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR : Python non trouve. Installez Python 3.8+
    pause
    exit /b 1
)

python CORRECTEUR_MANUEL_LIGNES.py

echo.
echo =========================================================
echo Termine. Appuyez sur une touche pour fermer.
echo =========================================================
echo.

pause >nul

endlocal