@echo off
:: ============================================================
:: export-secpol.cmd
:: Exportiert die lokale Sicherheitsrichtlinie mit secedit.
:: Speichert das Backup mit Timestamp nach C:\Temp\.
:: Muss als Administrator ausgeführt werden.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo FEHLER: Dieses Skript muss als Administrator ausgefuehrt werden.
    pause
    exit /b 1
)

:: Zielverzeichnis sicherstellen
if not exist "C:\Temp" mkdir "C:\Temp"

:: Timestamp im Format YYYYMMDD_HHMMSS erzeugen
for /f "tokens=2 delims==" %%i in ('wmic os get LocalDateTime /value') do set ldt=%%i
set TIMESTAMP=%ldt:~0,8%_%ldt:~8,6%

set BACKUPFILE=C:\Temp\secpol_backup_%TIMESTAMP%.cfg

echo.
echo [%date% %time%] Exportiere Sicherheitsrichtlinie nach: %BACKUPFILE%
echo.

secedit /export /cfg "%BACKUPFILE%" /quiet

if %errorLevel% equ 0 (
    echo ERFOLG: Sicherheitsrichtlinie exportiert nach %BACKUPFILE%
) else (
    echo FEHLER: secedit-Export fehlgeschlagen. Exitcode: %errorLevel%
    exit /b %errorLevel%
)

echo.
echo Hinweis: Zur Wiederherstellung import-secpol.cmd verwenden.
pause
