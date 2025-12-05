@echo OFF
chcp 65001 >nul
color 0A
echo ?? ARCHIVAGE VERSION STABLE V4.3
echo ============================================

set "DOSSIER=versions\V4.3_STABLE_%DATE:/=-%_%TIME::=-%"
set "DOSSIER=%DOSSIER: =%"
set "DOSSIER=%DOSSIER:,=%"

mkdir "%DOSSIER%"
copy Game.js "%DOSSIER%\Game_v4.3.js"
copy index.html "%DOSSIER%\index.html"
copy docs\*.txt "%DOSSIER%\" 2>nul
copy docs\*.md "%DOSSIER%\" 2>nul

echo ? Archivé dans : %DOSSIER%
echo ?? Fichiers sauvegardés :
dir "%DOSSIER%"
echo.
echo ?? CETTE VERSION EST FONCTIONNELLE ET DOCUMENTÉE
echo    Copiez ce dossier sur un support externe.
pause