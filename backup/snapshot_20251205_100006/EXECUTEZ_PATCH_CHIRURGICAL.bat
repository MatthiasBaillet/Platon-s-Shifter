@echo off
setlocal

:: PATCH CHIRURGICAL FINAL - FENÊTRE OUVERTE GARANTIE
cd /d "%~dp0"

echo =========================================================
echo 🔪 PATCH CHIRURGICAL FINAL - StatusDiv + EventListeners
echo =========================================================
echo.

where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Python non trouvé. Installez Python 3.8+
    pause
    exit /b 1
)

python PATCHER_CHIRURGICAL.py

echo.
echo =========================================================
echo ✅ Terminé. Appuyez sur une touche pour fermer.
echo =========================================================
pause >nul

endlocal