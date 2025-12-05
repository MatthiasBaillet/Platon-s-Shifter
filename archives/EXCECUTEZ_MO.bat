@echo off
setlocal

:: CORRECTION ACCOLADE LIGNE 82
:: Cette fenêtre RESTE OUVERTE

cd /d "%~dp0"

echo =========================================================
echo ?? CORRECTION ACCOLADE LIGNE 82
echo =========================================================
echo.

:: Lance le script Python
python CORRECTION_ACCOLADE.py

:: Pause pour garder la fenêtre OUVERTE
echo.
echo =========================================================
echo ? Termine. La fenêtre reste OUVERTE pour voir les resultats.
echo =========================================================
pause

endlocal