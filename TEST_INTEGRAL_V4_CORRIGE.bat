@echo OFF
chcp 65001 >nul
color 0B
echo ============================================
echo   ?? TEST INTEGRAL CORRIGÉ - DIAGNOSTIC CHEMIN
echo ============================================

:: DIAGNOSTIC : Où sommes-nous ?
echo ?? RÉPERTOIRE ACTUEL :
cd
echo.

echo ?? CONTENU DU DOSSIER :
dir /B Game* 2>nul
echo.

echo ?? VÉRIFICATION EXACTE DE Game.js...

:: Méthode 1 : IF EXIST
if exist "C:\Users\MATT\Desktop\Platon's Shifter\Game.js" (
    echo ? METHODE 1 : Chemin absolu trouvé
    set "CHEMIN=C:\Users\MATT\Desktop\Platon's Shifter\Game.js"
) else if exist "Game.js" (
    echo ? METHODE 2 : Nom relatif trouvé
    set "CHEMIN=Game.js"
) else (
    echo ? Game.js NON TROUVÉ avec aucune méthode
    echo    Vérifiez que vous êtes dans le bon dossier
    echo    Tapez 'cd' pour voir le répertoire actuel
    pause
    exit /b 1
)

:: Vérification taille
echo.
echo ?? TAILLE DU FICHIER :
for %%F in ("%CHEMIN%") do echo    %%~zF bytes

:: Vérification syntaxe
echo.
echo 2??  VÉRIFICATION SYNTAXE...
where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    node -c "%CHEMIN%" 2>temp_err.txt
    if !ERRORLEVEL! EQU 0 (
        echo ? Syntaxe JavaScript VALIDE
    ) else (
        echo ? SYNTAXE INVALIDE
        type temp_err.txt
    )
) else (
    echo ?? Node.js absent
)

:: Vérification correcteur
echo.
echo 3??  VÉRIFICATION CORRECTEUR...
if exist "correcteurs\CORRECTEUR_FINAL_V4.2.py" (
    echo ? Correcteur trouvé dans correcteurs/
) else if exist "CORRECTEUR_FINAL_V4.2.py" (
    echo ?? Correcteur trouvé à la racine (déplacer après)
) else (
    echo ? Correcteur manquant
)

echo.
echo ============================================
echo ? DIAGNOSTIC TERMINÉ
echo ============================================
pause