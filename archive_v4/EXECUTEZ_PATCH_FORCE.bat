@echo off
setlocal

:: PATCH STATUSDIV FORCE - FENETRE OUVERTE GARANTIE
:: Utilise uniquement des caracteres ASCII

cd /d "%~dp0"

echo =========================================================
echo 🔧 PATCH STATUSDIV FORCE - Version sans caracteres speciaux
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python non trouve. Installez Python 3.8+
    pause
    exit /b 1
)

python PATCH_STATUSDIV_FORCE.py

echo.
echo =========================================================
echo ✅ Termine. Appuyez sur une touche pour fermer.
echo =========================================================
echo.

pause >nul

endlocal