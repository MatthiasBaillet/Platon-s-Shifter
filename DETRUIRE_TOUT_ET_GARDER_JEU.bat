@echo OFF
chcp 65001 >nul
color 0C
echo ?? NETTOYAGE RADICAL DU PROJET
echo ============================================
echo Cette action va supprimer TOUS les scripts
echo et garder uniquement Game.js + index.html + JOUER.bat
echo.
set /p rep="Êtes-vous sûr (O/N) ? "
if /i "%rep%"=="O" (
    mkdir backup_final 2>nul
    move Game.js backup_final\ >nul
    move index.html backup_final\ >nul
    move JOUER.bat backup_final\ >nul
    del /Q *.*
    move backup_final\*.* .\
    rmdir backup_final
    echo ? PROJET NETTOYÉ
    echo ?? Double-cliquez sur JOUER.bat pour jouer
) else (
    echo Annulé.
)
pause