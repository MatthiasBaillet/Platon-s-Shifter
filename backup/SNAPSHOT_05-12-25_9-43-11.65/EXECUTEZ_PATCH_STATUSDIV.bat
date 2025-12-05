@echo off
setlocal

:: PATCH STATUSDIV FORCÉ - FENÊTRE OUVERTE
cd /d "%~dp0"

echo =========================================================
echo ?? PATCH STATUSDIV FORCÉ - Placement au début
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé. Installez Python 3.8+
    pause
    exit /b 1
)

python PATCH_STATUSDIV_FORCÉ.py

echo.
pause

endlocal