@echo OFF
chcp 65001 >nul
color 0B
echo ?? GÉNÉRATION DOCUMENTATION SIMPLE
echo ============================================

:: Créer dossier
mkdir docs 2>nul

:: Documentation brute (copie du code commenté)
echo /* PLATON'S SHIFTER - DOCUMENTATION EXTRAITE */ > docs\Game_comments.txt
echo =============================================== >> docs\Game_comments.txt
findstr /R /C:"^//" Game.js >> docs\Game_comments.txt

:: README simple
(
echo # Platon's Shifter V4.3
echo.
echo ## Fichiers
echo - `Game.js` : Code source complet
echo - `index.html` : Page de jeu
echo.
echo ## Lancer
echo Double-cliquer sur `index.html`
echo.
echo ## Documentation
echo Voir `docs\Game_comments.txt`
) > docs\README.md

echo ? Documentation créée dans docs\
echo ?? Fichiers :
dir docs\
echo.
pause