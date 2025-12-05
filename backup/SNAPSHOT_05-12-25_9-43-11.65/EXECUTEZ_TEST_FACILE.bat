@echo off
setlocal

:: EXECUTEUR DE TEST - FENÊTRE OUVERTE GARANTIE
:: Ce script trouve et exécute le test, peu importe où il est lancé

:: Obtenir le dossier de ce script
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo =========================================================
echo ?? TEST UNITAIRE - LANCEMENT AUTOMATIQUE
echo =========================================================
echo.

:: Vérifier Python
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Python non trouvé. Installez Python 3.8+
    pause
    exit /b 1
)

:: Vérifier si le script Python existe
if not exist "%SCRIPT_DIR%\executer_test_AUTOMATIQUE.py" (
    echo ? executer_test_AUTOMATIQUE.py introuvable !
    pause
    exit /b 1
)

:: Exécuter le script Python
python "%SCRIPT_DIR%\executer_test_AUTOMATIQUE.py"

:: Garde la fenêtre ouverte
echo.
echo =========================================================
echo ? Terminé. Appuyez sur une touche pour fermer.
echo =========================================================
pause >nul

endlocal