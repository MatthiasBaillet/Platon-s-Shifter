@echo OFF
chcp 65001 >nul
color 0B
echo ?? GÉNÉRATION DE LA DOCUMENTATION
echo ============================================

:: Extraire les commentaires du code
findstr /B "//" Game.js > documentation_auto.txt
findstr /B "const CONFIG" Game.js >> documentation_auto.txt
findstr /B "function" Game.js >> documentation_auto.txt

:: Créer la documentation HTML
(
echo ^<!DOCTYPE html^>
echo ^<html^>^<head^>^<title^>Doc Platon's Shifter^</title^>
echo ^<style^>body{font-family:monospace;background:#1a1a1a;color:#fff;padding:20px}^</style^>
echo ^</head^>^<body^>
echo ^<h1^>?? Documentation Technique - Platon's Shifter V4.3^</h1^>
echo ^<pre^>
type documentation_auto.txt
echo ^</pre^>
echo ^</body^>^</html^>
) > documentation.html

echo ? Documentation générée :
echo    - documentation_auto.txt (brute)
echo    - documentation.html (formatée)
echo.
start documentation.html
pause