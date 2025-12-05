@echo off
chcp 65001 >nul
color 0A

:: Création du timestamp
set TIMESTAMP=%DATE:/=-%_%TIME::=-%
set TIMESTAMP=%TIMESTAMP: =%
set "DEST=backup\SNAPSHOT_%TIMESTAMP%"

echo ?? Création du snapshot dans %DEST%...
mkdir "%DEST%" 2>nul

:: Copie intelligente avec ROBUSTCOPY (évite la boucle)
if exist "C:\Windows\System32\robocopy.exe" (
    robocopy "." "%DEST%" /E /XD backup /XD "%DEST%" /XD archive* /XD correcteurs /XD scripts /XD versions >nul 2>&1
    if %ERRORLEVEL% LEQ 1 (echo ? Snapshot réussi) else (echo ?? Avertissement - Code %ERRORLEVEL%)
) else (
    :: Fallback sans xcopy (évite la boucle)
    echo ?? Robocopy non trouvé, utilisation de la méthode alternative...
    for %%F in (*.bat *.py *.txt *.js *.html) do (
        if exist "%%F" copy /Y "%%F" "%DEST%\" >nul 2>&1
    )
    echo ? Snapshot partiel créé
)

echo.
pause