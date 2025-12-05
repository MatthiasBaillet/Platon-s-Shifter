@echo OFF
echo 🔍 DIAGNOSTIC DE Game.js
echo.

:: Vérification 1 : Le fichier existe ?
if not exist "Game.js" (
    echo ❌ ERREUR CRITIQUE : Game.js n'existe pas !
    goto :fin
)

:: Vérification 2 : Taille et structure
for %%F in (Game.js) do set size=%%~zF
echo 📏 Taille : %size% bytes

:: Vérification 3 : Syntaxe JavaScript (si Node.js installé)
node -c Game.js 2>temp_syntaxe.txt
if %ERRORLEVEL% EQU 0 (
    echo ✅ Syntaxe JavaScript VALIDE
) else (
    echo ❌ Syntaxe JavaScript INVALIDE
    type temp_syntaxe.txt
)

:: Vérification 4 : Intégrité des fonctions critiques
findstr /C:"function init(" Game.js >nul && echo ✅ Fonction init() trouvée || echo ❌ init() MANQUANTE
findstr /C:"function update(" Game.js >nul && echo ✅ Fonction update() trouvée || echo ❌ update() MANQUANTE
findstr /C:"enemyBases" Game.js >nul && echo ✅ Variable enemyBases trouvée || echo ❌ enemyBases MANQUANTE
findstr /C:"class PlatonicShape" Game.js >nul && echo ✅ Classe PlatonicShape trouvée || echo ❌ PlatonicShape MANQUANTE

:fin
echo.
pause