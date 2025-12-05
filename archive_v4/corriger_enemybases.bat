@echo off
setlocal

cd /d "%~dp0"

echo ===========================================
echo CORRECTEUR ENEMYBASES SPECIFIQUE
echo ===========================================
echo.

:: Vérifier la ligne problématique
findstr /C:"let enemyBase = null;" Game.js >nul 2>&1
if errorlevel 1 (
    echo [INFO] Correction déjà appliquée ou non nécessaire
    pause
    exit /b 0
)

:: Créer une copie de secours
copy Game.js Game.js.backup_enemybases >nul

:: Corriger la ligne
powershell -Command "(Get-Content Game.js) -replace 'let enemyBase = null;', 'let enemyBases = [];' | Set-Content Game.js"

echo [OK] Variable enemyBases restaurée
echo.
echo ??  VEUILLEZ VERIFIER QUE Game.js FONCTIONNE
echo.
pause