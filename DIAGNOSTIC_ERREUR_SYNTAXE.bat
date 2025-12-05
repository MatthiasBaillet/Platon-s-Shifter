@echo OFF
chcp 65001 >nul
color 0C
echo ?? DIAGNOSTIC D'ERREUR SYNTAXE EXACTE
echo =====================================
echo.

echo ?? Fichier à analyser : Game.js (21 365 bytes)
echo.

:: Vérification brute avec Node.js
echo ?? RÉSULTAT BRUT DE NODE.JS :
echo ----------------------------------------
node -c Game.js 2>&1
echo ----------------------------------------
echo.

:: Vérification ligne par ligne si erreur
echo ?? LOCALISATION DE L'ERREUR :
setlocal enabledelayedexpansion
set "LIGNE=0"
for /f "delims=" %%L in (Game.js) do (
    set /a "LIGNE+=1"
    echo %%L | findstr /C:"//" >nul || (
        echo !LIGNE!: %%L >> temp_lignes.txt
    )
)
echo    (Les lignes sans commentaires ont été loguées)
echo.

:: Test d'encodage détaillé
echo ?? VÉRIFICATION ENCODAGE :
powershell -Command "[System.IO.File]::ReadAllBytes('Game.js') | Select-Object -First 10" 2>nul
echo.

echo ?? Si vous voyez "Unexpected token" ou "SyntaxError", le fichier est corrompu.
pause