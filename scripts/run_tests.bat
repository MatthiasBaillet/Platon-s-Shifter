@echo off
cd /d "%~dp0"
echo Lancement des tests unitaires...
node test_game.js
echo.
pause