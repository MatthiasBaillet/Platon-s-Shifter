@echo off
cd /d "%~dp0"

echo Suppression des emojis problématiques...

powershell -Command "(Get-Content fix_game_v4.py) -replace '??', '>' -replace '??', 'RAPPORT' -replace '?', '[OK]' -replace '?', '[ERREUR]' | Set-Content fix_game_v4.py"

echo ? Emojis remplacés par des caractères ASCII
pause