@echo OFF
chcp 65001 >nul
color 0E
echo ============================================
echo   ?? DIAGNOSTIC DE PRÉCISION - Game.js
echo ============================================
echo.

:: Test 1 : Vérification basique
echo 1??  VÉRIFICATION BASIQUE...
if exist "Game.js" (
    echo ? Fichier "Game.js" trouvé par IF EXIST
) else (
    echo ? Fichier "Game.js" NON trouvé par IF EXIST
    echo    Pourtant il est visible ? Analyse approfondie...
)

:: Test 2 : Lister TOUS les fichiers Game*
echo.
echo 2??  LISTE DES FICHIERS "Game*" :
for %%F in (Game*) do (
    echo    - "%%F" (taille : %%~zF bytes)
)

:: Test 3 : Vérification avec PowerShell (détecte les noms bizarres)
echo.
echo 3??  ANALYSE POWERHELL (nom réel) :
powershell -Command "Get-ChildItem 'Game*' | ForEach-Object { '[' + $_.Name + '] - Taille: ' + $_.Length + ' - Extension: [' + $_.Extension + ']' }"

:: Test 4 : Vérification des attributs
echo.
echo 4??  ATTRIBUTS DU FICHIER :
if exist "Game.js" (
    attrib Game.js
) else (
    for %%F in (Game*) do attrib "%%F"
)

:: Test 5 : Tentative de lecture
echo.
echo 5??  TEST DE LECTURE :
if exist "Game.js" (
    echo    Première ligne :
    powershell -Command "Get-Content Game.js -First 1"
    echo    Dernière ligne :
    powershell -Command "Get-Content Game.js -Tail 1"
) else (
    echo    ?? Impossible de lire (fichier non trouvé)
)

:: Test 6 : Vérification de l'encodage BOM
echo.
echo 6??  VÉRIFICATION BOM :
powershell -Command "$bytes = Get-Content Game.js -Encoding Byte -First 3; if ($bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) { 'BOM UTF-8 DÉTECTÉ' } else { 'Pas de BOM' }" 2>nul || echo ?? Test impossible

pause