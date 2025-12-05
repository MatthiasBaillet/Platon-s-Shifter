@echo off
setlocal

cd /d "%~dp0"

echo.
echo ===========================================
echo DIAGNOSTIC SIMPLIFIÉ
echo ===========================================
echo.

echo Vérifie Game.js...
if exist "Game.js" (echo [OK] Game.js existe) else (echo [ERREUR] manquant)

echo Vérifie index.html...
if exist "index.html" (echo [OK] index.html existe) else (echo [ERREUR] manquant)

echo.
echo Appuyez sur Entrée...
pause >nul

echo.
echo FIN (vous devriez voir ce message)