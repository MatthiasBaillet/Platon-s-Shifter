@echo off
setlocal

:: CORRECTEUR FINAL V4.2 - FENÊTRE OUVERTE
cd /d "%~dp0"

echo =========================================================
echo ?? CORRECTEUR FINAL V4.2 - Nettoyage intégral
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé
    pause
    exit /b 1
)

python CORRECTEUR_FINAL_V4.2.py

echo.
pause

endlocal