@echo off
setlocal

:: PATCH RUNTIME BUGS - FENÊTRE OUVERTE GARANTIE
cd /d "%~dp0"

echo =========================================================
echo ?? PATCH BUGS RUNTIME - Game.js
echo =========================================================
echo.

:: Vérifier Python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé. Installez Python 3.8+
    pause
    exit /b 1
)

:: Exécuter le patch
python patch_runtime_bugs.py

:: Pause finale
echo.
pause

endlocal