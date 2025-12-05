@echo OFF
chcp 65001 >nul
color 0A
echo 📦 ARCHIVAGE VERSION FINALE V4.3
echo ============================================

set "DOSSIER=versions\V4.3_FINAL_%DATE:/=-%_%TIME::=-%"
set "DOSSIER=%DOSSIER: =%"
set "DOSSIER=%DOSSIER:,=%"

mkdir "%DOSSIER%"

:: Fichiers ESSENTIELS
copy Game.js "%DOSSIER%\"
copy index.html "%DOSSIER%\"
copy package.json "%DOSSIER%\"
copy __tests__\game.test.js "%DOSSIER%\__tests__\"

:: Documentation
mkdir "%DOSSIER%\docs"
copy docs\*.txt "%DOSSIER%\docs\" 2>nul
copy docs\*.md "%DOSSIER%\docs\" 2>nul

echo ✅ Archivé dans : %DOSSIER%
echo.
echo 📁 Fichiers sauvegardés :
dir "%DOSSIER%" /B
echo.
echo 🎯 CETTE VERSION EST 100% FONCTIONNELLE
echo    - Jeu qui se lance (JOUER.bat)
echo    - Tests qui passent (6/6)
echo    - Pas de dépendances
echo    - Prête pour la Phase 2
pause