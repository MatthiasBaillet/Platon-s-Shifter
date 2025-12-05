@echo off
setlocal

cd /d "%~dp0"

echo ===========================================
echo MODE WATCH - SURVEILLANCE TEMPS RÉEL
echo ===========================================
echo.
echo Le correcteur va surveiller Game.js...
echo Appuyez sur Ctrl+C pour arrêter
echo ===========================================
echo.

python watch_game.py

echo.
echo Surveillance terminée
pause