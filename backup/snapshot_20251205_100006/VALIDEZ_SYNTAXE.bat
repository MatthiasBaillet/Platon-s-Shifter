@echo off
setlocal

:: VALIDATION SYNTAXE Game.js - FENÊTRE OUVERTE GARANTIE
cd /d "%~dp0"

echo =========================================================
echo ?? VALIDATION SYNTAXE - Game.js
echo =========================================================
echo.

:: Vérifier Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ? Node.js non trouvé. Installez depuis https://nodejs.org/
    echo    Puis redémarrez votre PC et réessayez.
    pause
    exit /b 1
)

:: Vérifier que les fichiers existent
if not exist "validation_syntaxe.js" (
    echo ? validation_syntaxe.js introuvable !
    pause
    exit /b 1
)

if not exist "Game.js" (
    echo ? Game.js introuvable !
    pause
    exit /b 1
)

:: Exécuter la validation
echo ?? Exécution de validation_syntaxe.js...
echo.
node validation_syntaxe.js

:: Vérifier le résultat
if %ERRORLEVEL% EQU 0 (
    echo.
    echo =========================================================
    echo ? SYNTAXE VALIDÉE ! Le code est correct.
    echo =========================================================
    echo.
    echo ?? VOUS POUVEZ LANCER LE JEU :
    echo    - Double-cliquez sur index.html
    echo    - OU exécutez launcher_final_v4.1.bat -^> [1] Corriger + Rapport
    echo =========================================================
) else (
    echo.
    echo =========================================================
    echo ? ERREUR DE SYNTAXE DÉTECTÉE
    echo =========================================================
    echo ?? Corrigez l'erreur avant de lancer le jeu
)

:: Pause pour garder la fenêtre ouverte
echo.
pause

endlocal