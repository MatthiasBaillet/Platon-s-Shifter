@echo off
setlocal

:: VÉRIFICATION COMPLÈTE - FENÊTRE OUVERTE
cd /d "%~dp0"

echo =========================================================
echo ?? VÉRIFICATION COMPLÈTE DU PROJET
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé
    pause
    exit /b 1
)

python verifier_html_complet.py

echo.
echo =========================================================
echo ? Terminé. Appuyez sur une touche pour fermer.
echo =========================================================
echo.

pause >nul

endlocal