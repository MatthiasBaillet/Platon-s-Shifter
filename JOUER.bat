@echo OFF
chcp 65001 >nul
color 0A
echo ============================================
echo   ?? PLATON'S SHIFTER V4.2 - PRÊT À JOUER
echo ============================================
echo.
echo ? Vérification des fichiers...
if not exist "Game.js" echo ? Game.js manquant && pause && exit /b 1
if not exist "index.html" echo ? index.html manquant && pause && exit /b 1
echo ? Tous les fichiers présents
echo.
echo ?? Lancement du jeu dans Chrome...
start "" index.html
echo.
echo ??  Si le jeu ne s'ouvre pas, glissez index.html sur Chrome
echo.
pause