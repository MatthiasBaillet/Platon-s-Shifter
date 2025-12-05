@echo off
setlocal

:: VERIFICATION COMPLETE - VERSION ASCII SANS EMOJIS
:: Cette fenetre RESTE OUVERTE

cd /d "%~dp0"

echo =========================================================
echo VERIFICATION COMPLETE DU PROJET (Version ASCII)
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR : Python non trouve. Installez Python 3.8+
    pause
    exit /b 1
)

python verifier_html_complet.py

echo.
echo =========================================================
echo Termine. Appuyez sur une touche pour fermer ce script.
echo =========================================================
echo.

pause >nul

endlocal