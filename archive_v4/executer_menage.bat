@echo off
setlocal

:: MÉNAGE INTELLIGENT - Platon's Shifter
:: Cette fenêtre RESTE OUVERTE

cd /d "%~dp0"

echo =========================================================
echo ?? MÉNAGE INTELLIGENT - Projet v4.2
echo =========================================================
echo.

:: Vérifie si Python est installé
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouve. Installez Python 3.8+
    echo.
    pause
    exit /b 1
)

:: Exécute le script de ménage
python nettoyage_intelligent.py

:: Pause pour garder la fenêtre OUVERTE
echo.
echo =========================================================
echo ? Termine. Appuyez sur une touche pour fermer.
echo =========================================================
pause >nul

endlocal