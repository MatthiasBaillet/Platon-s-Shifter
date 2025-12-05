@echo off
setlocal

:: PLATON'S SHIFTER - Lanceur de correction finale
:: Cette fenêtre RESTE OUVERTE après exécution

cd /d "%~dp0"

echo =========================================================
echo ?? LANCEMENT CORRECTION FINALE V4.2
echo =========================================================
echo.

:: Vérification Python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouve. Installez Python 3.8+
    echo.
    pause
    exit /b 1
)

:: Exécution du script
python correction_finale.py

:: Pause finale (garde la fenetre ouverte)
echo.
echo =========================================================
echo ? Script termine. Appuyez sur une touche pour fermer.
echo =========================================================
pause >nul

endlocal