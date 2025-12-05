@echo off
setlocal

cd /d "%~dp0"

echo ===========================================
echo PATCH ASCII FINAL - Suppression totale Unicode
echo ===========================================
echo.

:: Créer une copie de secours
copy fix_game_v4.py fix_game_v4.backup.py >nul
echo [OK] Backup créé

:: Utiliser PowerShell pour remplacer TOUTES les séquences Unicode
powershell -Command @"
# Lire le fichier
$content = Get-Content 'fix_game_v4.py' -Raw

# Remplacer les emojis et caractères spéciaux
$content = $content -replace '??', '>' -replace '??', 'RAPPORT' -replace '?', '[OK]'
$content = $content -replace '?', '[ERREUR]' -replace '??', '[WARN]' -replace '??', '[SKIP]'
$content = $content -replace '???', '[WATCH]' -replace '??', '[CHANGE]'

# Sauvegarder
Set-Content 'fix_game_v4.py' $content -Encoding ascii -NoNewline
"@

echo.
echo ? Tous les caractères Unicode remplacés par ASCII
echo.
echo Relancez le Mode Watch pour tester :
echo   1. Fermez watch.bat actuel
echo   2. Relancez watch.bat
echo   3. Modifiez Game.js pour voir si ça fonctionne
echo.
pause