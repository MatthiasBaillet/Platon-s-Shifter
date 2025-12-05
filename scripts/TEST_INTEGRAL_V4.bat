@echo OFF
chcp 65001 >nul
color 0B
echo ============================================
echo   ?? TEST INTEGRAL DE LA CHAÎNE V4.2
echo ============================================
set "ERREUR=0"

:: ÉTAPE 1 : Vérification des fichiers critiques
echo.
echo 1??  VÉRIFICATION DES FICHIERS CRITIQUES...
if not exist "Game.js" (
    echo ? Game.js manquant
    set "ERREUR=1"
    goto :fin
) else echo ? Game.js présent

if not exist "index.html" (
    echo ? index.html manquant
    set "ERREUR=1"
    goto :fin
) else echo ? index.html présent

if not exist "correcteurs\CORRECTEUR_FINAL_V4.2.py" (
    echo ? Correcteur manquant
    set "ERREUR=1"
    goto :fin
) else echo ? Correcteur présent

:: ÉTAPE 2 : Diagnostic syntaxe
echo.
echo 2??  VÉRIFICATION SYNTAXE...
where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    node -c Game.js 2>temp_err.txt
    if !ERRORLEVEL! EQU 0 (
        echo ? Syntaxe JavaScript VALIDE
    ) else (
        echo ? SYNTAXE INVALIDE
        type temp_err.txt
        set "ERREUR=1"
    )
) else (
    echo ?? Node.js absent (vérification impossible)
)

:: ÉTAPE 3 : Simulation correcteur
echo.
echo 3??  SIMULATION CORRECTEUR V4.2...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js --dry-run
if !ERRORLEVEL! NEQ 0 (
    echo ?? Simulation a retourné des avertissements
    set "ERREUR=1"
)

:: ÉTAPE 4 : Application réelle
echo.
echo 4??  APPLICATION DES CORRECTIONS...
python correcteurs\CORRECTEUR_FINAL_V4.2.py Game.js
if !ERRORLEVEL! NEQ 0 (
    echo ? Correcteur a échoué
    set "ERREUR=1"
    goto :fin
) else echo ? Corrections appliquées

:: ÉTAPE 5 : Vérification post-correction
echo.
echo 5??  VÉRIFICATION POST-CORRECTION...
if not exist "Game_fixed.js" (
    echo ? Game_fixed.js non créé
    set "ERREUR=1"
    goto :fin
) else (
    node -c Game_fixed.js 2>temp_err2.txt
    if !ERRORLEVEL! EQU 0 (
        echo ? Game_fixed.js syntaxiquement valide
    ) else (
        echo ? Game_fixed.js corrompu
        type temp_err2.txt
        set "ERREUR=1"
    )
)

:: ÉTAPE 6 : Remplacement sécurisé
echo.
echo 6??  REMPLACEMENT SÉCURISÉ...
copy /Y Game.js Game.js.backup_manual >nul
copy /Y Game_fixed.js Game.js >nul
del Game_fixed.js
echo ? Remplacement effectué

:: ÉTAPE 7 : Test de lancement
echo.
echo 7??  TEST DE LANCEMENT...
echo    Ouverture du jeu dans le navigateur...
start "" index.html
timeout /t 3 >nul
echo ? Jeu lancé (vérifiez la console F12)

:: Nettoyage
if exist temp_err*.txt del temp_err*.txt

:fin
echo.
echo ============================================
if %ERREUR% EQU 0 (
    echo ? TEST INTÉGRAL RÉUSSI
    echo    Votre projet est STABLE et prêt
) else (
    echo ? TEST INTÉGRAL ÉCHOUÉ
    echo    Consultez les erreurs ci-dessus
)
echo ============================================
pause