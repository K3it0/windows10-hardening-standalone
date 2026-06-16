@echo off
:: ============================================================
:: export-lgpo.cmd
:: Exportiert alle lokalen Gruppenrichtlinien mit LGPO.exe.
:: LGPO.exe muss im PATH oder im selben Verzeichnis liegen.
:: Download: Microsoft Security Compliance Toolkit
:: https://www.microsoft.com/en-us/download/details.aspx?id=55319
::
:: Muss als Administrator ausgeführt werden.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo FEHLER: Dieses Skript muss als Administrator ausgefuehrt werden.
    pause
    exit /b 1
)

:: LGPO.exe verfuegbar?
where LGPO.exe >nul 2>&1
if %errorLevel% neq 0 (
    :: Auch im Skript-Verzeichnis suchen
    if exist "%~dp0LGPO.exe" (
        set LGPO_CMD="%~dp0LGPO.exe"
    ) else (
        echo.
        echo FEHLER: LGPO.exe wurde nicht gefunden.
        echo.
        echo Bitte laden Sie das Microsoft Security Compliance Toolkit herunter:
        echo   https://www.microsoft.com/en-us/download/details.aspx?id=55319
        echo.
        echo Entpacken Sie LGPO.exe und legen Sie sie entweder:
        echo   a) in dieses Verzeichnis (%~dp0), oder
        echo   b) in ein Verzeichnis, das im PATH enthalten ist.
        echo.
        pause
        exit /b 1
    )
) else (
    set LGPO_CMD=LGPO.exe
)

:: Zielverzeichnis vorbereiten
if not exist "C:\Temp" mkdir "C:\Temp"

:: Timestamp
for /f "tokens=2 delims==" %%i in ('wmic os get LocalDateTime /value') do set ldt=%%i
set TIMESTAMP=%ldt:~0,8%_%ldt:~8,6%

set BACKUPDIR=C:\Temp\GPO-Backup-%TIMESTAMP%
mkdir "%BACKUPDIR%"

echo.
echo [%date% %time%] Exportiere lokale Gruppenrichtlinien nach: %BACKUPDIR%
echo.

%LGPO_CMD% /b "%BACKUPDIR%"

if %errorLevel% equ 0 (
    echo ERFOLG: Gruppenrichtlinien exportiert nach %BACKUPDIR%
) else (
    echo FEHLER: LGPO-Export fehlgeschlagen. Exitcode: %errorLevel%
    exit /b %errorLevel%
)

echo.
echo Zur Wiederherstellung: lgpo\import-lgpo.cmd
pause
