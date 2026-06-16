@echo off
:: ============================================================
:: import-lgpo.cmd
:: Stellt lokale Gruppenrichtlinien aus dem neuesten
:: GPO-Backup-Ordner in C:\Temp\ wieder her.
:: LGPO.exe muss im PATH oder im selben Verzeichnis liegen.
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
    if exist "%~dp0LGPO.exe" (
        set LGPO_CMD="%~dp0LGPO.exe"
    ) else (
        echo.
        echo FEHLER: LGPO.exe wurde nicht gefunden.
        echo Bitte laden Sie das Microsoft Security Compliance Toolkit herunter:
        echo   https://www.microsoft.com/en-us/download/details.aspx?id=55319
        pause
        exit /b 1
    )
) else (
    set LGPO_CMD=LGPO.exe
)

:: Neuesten GPO-Backup-Ordner suchen
set BACKUPPARENT=C:\Temp
set BACKUPDIR=

for /f "delims=" %%d in ('dir /b /o-n /ad "%BACKUPPARENT%\GPO-Backup-*" 2^>nul') do (
    if not defined BACKUPDIR set BACKUPDIR=%BACKUPPARENT%\%%d
)

if not defined BACKUPDIR (
    echo FEHLER: Kein GPO-Backup-Ordner gefunden in %BACKUPPARENT%\GPO-Backup-*
    echo Bitte zuerst export-lgpo.cmd ausfuehren.
    pause
    exit /b 1
)

echo.
echo [%date% %time%] Wiederherstelle Gruppenrichtlinien aus: %BACKUPDIR%
echo.
echo ACHTUNG: Die aktuellen Gruppenrichtlinien werden ueberschrieben!
echo Druecken Sie STRG+C zum Abbrechen oder
pause

%LGPO_CMD% /g "%BACKUPDIR%"

if %errorLevel% equ 0 (
    echo ERFOLG: Gruppenrichtlinien aus %BACKUPDIR% wiederhergestellt.
    echo Bitte starten Sie das System neu, damit alle Aenderungen wirksam werden.
) else (
    echo FEHLER: LGPO-Import fehlgeschlagen. Exitcode: %errorLevel%
    exit /b %errorLevel%
)

pause
