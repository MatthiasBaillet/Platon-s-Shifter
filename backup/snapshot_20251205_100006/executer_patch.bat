@echo off
setlocal

:: PLATON'S SHIFTER - Lanceur de correction
:: Cette fenêtre NE SE FERME PAS automatiquement

cd /d "%~dp0"

echo =========================================================
echo 🚀 LANCEMENT CORRECTION ULTIME V4.2
echo =========================================================
echo.

:: Vérifie si Python est installé
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python non trouvé. Installez Python 3.8+
    echo.
    pause
    exit /b 1
)

:: Exécute le script Python
python correction_ultime.py

:: Pause pour garder la fenêtre ouverte
echo.
echo =========================================================
echo ✅ Script terminé. La fenêtre reste ouverte.
echo =========================================================
pause

endlocal