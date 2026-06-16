@echo off
:: ============================================================
:: import-secpol.cmd
:: Stellt die lokale Sicherheitsrichtlinie aus dem letzten
:: secedit-Backup in C:\Temp\ wieder her.
:: Muss als Administrator ausgeführt werden.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo FEHLER: Dieses Skript muss als Administrator ausgefuehrt werden.
    pause
    exit /b 1
)

:: Neuestes Backup-File ermitteln
set BACKUPDIR=C:\Temp
set BACKUPFILE=

:: Letzte .cfg-Datei mit Namensschema secpol_backup_* suchen
for /f "delims=" %%f in ('dir /b /o-n "%BACKUPDIR%\secpol_backup_*.cfg" 2^>nul') do (
    if not defined BACKUPFILE set BACKUPFILE=%BACKUPDIR%\%%f
)

if not defined BACKUPFILE (
    echo FEHLER: Kein Backup-File gefunden in %BACKUPDIR%\secpol_backup_*.cfg
    echo Bitte zuerst export-secpol.cmd ausfuehren.
    pause
    exit /b 1
)

echo.
echo [%date% %time%] Wiederherstelle Sicherheitsrichtlinie aus: %BACKUPFILE%
echo.
echo ACHTUNG: Die aktuellen Sicherheitsrichtlinien werden ueberschrieben!
echo Druecken Sie STRG+C zum Abbrechen oder
pause

secedit /configure /db "%TEMP%\secedit_restore.sdb" /cfg "%BACKUPFILE%" /overwrite /quiet

if %errorLevel% equ 0 (
    echo ERFOLG: Sicherheitsrichtlinie aus %BACKUPFILE% wiederhergestellt.
    echo Bitte starten Sie das System neu.
) else (
    echo FEHLER: secedit-Import fehlgeschlagen. Exitcode: %errorLevel%
    exit /b %errorLevel%
)

pause
