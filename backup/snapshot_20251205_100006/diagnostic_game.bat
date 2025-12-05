@echo OFF
setlocal EnableDelayedExpansion
chcp 65001 >nul
color 0A
echo ============================================
echo   ?? DIAGNOSTIC AVANCÉ - PLATON'S SHIFTER
echo ============================================
echo.

:: Dossier de travail
set "DOSSIER=%~dp0"

:: Fichier cible
set "FICHIER_CIBLE=Game.js"

:: Couleurs
set "VERT=[32m"
set "ROUGE=[31m"
set "JAUNE=[33m"
set "RESET=[0m"

echo ?? Dossier examiné : %DOSSIER%
echo.

:: Vérification 1 : Existence du fichier
echo 1??  VÉRIFICATION EXISTENCE...
if not exist "%FICHIER_CIBLE%" (
    echo %ROUGE%? CRITIQUE%RESET% : %FICHIER_CIBLE% n'existe PAS !
    echo.
    echo Suggestions :
    echo   - Vérifier l'orthographe (Game.js, pas Gamejs)
    echo   - Exécuter RECUPERER_GAMEJS_IMMEDIAT.bat
    pause
    exit /b 1
) else (
    echo %VERT%?%RESET% %FICHIER_CIBLE% trouvé
)

:: Vérification 2 : Taille
echo.
echo 2??  VÉRIFICATION TAILLE...
for %%F in (%FICHIER_CIBLE%) do (
    set "TAILLE=%%~zF"
    echo    Taille : !TAILLE! bytes
)
if !TAILLE! LSS 10000 (
    echo %JAUNE%??%RESET% Fichier très petit (possiblement corrompu)
)
if !TAILLE! GTR 50000 (
    echo %JAUNE%??%RESET% Fichier très grand (possiblement non patché)
)

:: Vérification 3 : Encodage (vérification BOM)
echo.
echo 3??  VÉRIFICATION ENCODAGE...
powershell -Command "Get-Content -Encoding Byte -TotalCount 3 '%FICHIER_CIBLE%' | Select-Object -First 3" > temp_bom.txt 2>nul
findstr "239 187 191" temp_bom.txt >nul
if %ERRORLEVEL% EQU 0 (
    echo %ROUGE%?%RESET% BOM UTF-8 détectée (risque de bugs)
    echo    Solution : Sauvegarder en ANSI ou UTF-8 SANS BOM
) else (
    echo %VERT%?%RESET% Pas de BOM (compatible)
)

:: Vérification 4 : Syntaxe JavaScript (Node.js)
echo.
echo 4??  VÉRIFICATION SYNTAXE...
where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    node -c %FICHIER_CIBLE% 2>temp_erreur.txt
    if !ERRORLEVEL! EQU 0 (
        echo %VERT%?%RESET% Syntaxe JavaScript VALIDE
    ) else (
        echo %ROUGE%?%RESET% SYNTAXE INVALIDE
        echo.
        echo Erreurs détectées :
        type temp_erreur.txt
        set "SYNTAXE_ERREUR=1"
    )
) else (
    echo %JAUNE%??%RESET% Node.js non installé (vérification impossible)
)

:: Vérification 5 : Intégrité des fonctions critiques
echo.
echo 5??  VÉRIFICATION INTÉGRITÉ...

set "FONCTIONS=init update enemyBases PlatonicShape drawScore drawEnergy"

for %%F in (%FONCTIONS%) do (
    findstr /C:"%%F" %FICHIER_CIBLE% >nul
    if !ERRORLEVEL! EQU 0 (
        echo %VERT%?%RESET% %%F trouvé
    ) else (
        echo %ROUGE%?%RESET% %%F MANQUANT
        set "INTÉGRITÉ_ERREUR=1"
    )
)

:: Vérification 6 : Vérifications spécifiques au jeu
echo.
echo 6??  VÉRIFICATION JEU-SPECIFIQUE...

:: Canvas ID
findstr /C:"getElementById.*gameCanvas" %FICHIER_CIBLE% >nul
if !ERRORLEVEL! EQU 0 ( echo %VERT%?%RESET% canvas 'gameCanvas' référencé ) else ( echo %JAUNE%??%RESET% ID canvas non trouvé)

:: Formes
for %%S in (Tetrahedron Cube Octahedron Dodecahedron Icosahedron) do (
    findstr /C:"%%S" %FICHIER_CIBLE% >nul
    if !ERRORLEVEL! EQU 0 ( echo %VERT%?%RESET% Forme %%S trouvée ) else ( echo %ROUGE%?%RESET% Forme %%S MANQUANTE )
)

:: Vérification 7 : Vérification HTML
echo.
echo 7??  VÉRIFICATION INDEX.HTML...
if not exist "index.html" (
    echo %ROUGE%?%RESET% index.html manquant
) else (
    echo %VERT%?%RESET% index.html trouvé
    findstr /C:"gameCanvas" index.html >nul && echo %VERT%?%RESET% Canvas ID correct dans HTML || echo %ROUGE%?%RESET% Canvas ID absent dans HTML
)

:: RÉSUMÉ FINAL
echo.
echo ============================================
echo ?? RÉSUMÉ DU DIAGNOSTIC
echo ============================================
if defined SYNTAXE_ERREUR (
    echo %ROUGE%? SYNTAXE : ERREUR(S) DÉTECTÉE(S)%RESET%
    echo    Action : Voir erreurs ci-dessus, puis exécuter RECUPERER_GAMEJS_IMMEDIAT.bat
) else if defined INTÉGRITÉ_ERREUR (
    echo %JAUNE%?? INTÉGRITÉ : FONCTION(S) MANQUANTE(S)%RESET%
    echo    Action : Vérifier le fichier source ou appliquer un patch complet
) else (
    echo %VERT%? ÉTAT : STABLE%RESET%
    echo    Game.js est fonctionnel et prêt à être patché
)

:: Nettoyage
if exist temp_*.txt del temp_*.txt

echo.
pause