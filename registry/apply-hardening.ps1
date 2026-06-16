#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Wendet Registry-Härtungseinstellungen für Windows 10 Standalone an.
.DESCRIPTION
    Setzt sicherheitsrelevante Registry-Werte unter HKLM:\SOFTWARE\Microsoft\Windows\
    CurrentVersion\Policies\System. Protokolliert alle Änderungen nach C:\Temp\hardening-log.txt.
.NOTES
    Referenz: BSI IT-Grundschutz SYS.2.2.3
    Neustart nach Anwendung empfohlen.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Admin-Prüfung ---
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Dieses Skript muss als Administrator ausgeführt werden. Abbruch."
    exit 1
}

# --- Log-Verzeichnis und -Datei vorbereiten ---
$logDir  = 'C:\Temp'
$logFile = "$logDir\hardening-log.txt"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "$timestamp  $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Host $entry
}

# --- Hilfsfunktion: alten Wert loggen und neuen Wert setzen ---
function Set-HardenedValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord',
        [string]$Description
    )

    # Registry-Pfad anlegen falls nicht vorhanden
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "ERSTELLT  Schlüssel: $Path"
    }

    # Alten Wert auslesen und loggen
    try {
        $oldValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        Write-Log "ALT       $Path\$Name = $oldValue  ($Description)"
    }
    catch {
        Write-Log "NEU       $Path\$Name existierte nicht  ($Description)"
        $oldValue = $null
    }

    # Neuen Wert setzen
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    Write-Log "GESETZT   $Path\$Name = $Value  ($Description)"
}

# =============================================================================
# Härtungsmaßnahmen
# =============================================================================
Write-Log "=========================================================="
Write-Log "START  apply-hardening.ps1  ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
Write-Log "=========================================================="

$policyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

# --- 1. Schnellen Benutzerwechsel deaktivieren ---
# Verhindert, dass weitere Benutzersitzungen parallel geöffnet werden können,
# ohne die aktive Sitzung zu sperren. Reduziert Angriffsfläche bei
# unbeaufsichtigtem Gerät.
# BSI SYS.2.2.3.A3 – Ordnungsgemäße Verwaltung von Windows-Benutzerkonten
# Rollback: HideFastUserSwitching = 0
Set-HardenedValue -Path $policyPath `
    -Name  'HideFastUserSwitching' `
    -Value 1 `
    -Description 'Schnellen Benutzerwechsel deaktivieren'

# --- 2. Letzten Benutzernamen auf Anmeldebildschirm nicht anzeigen ---
# Verhindert, dass ein Angreifer am Anmeldebildschirm den Kontonamen des
# zuletzt angemeldeten Nutzers sieht und gezielt angreifen kann.
# BSI SYS.2.2.3.A3 – Ordnungsgemäße Verwaltung von Windows-Benutzerkonten
# Rollback: DontDisplayLastUserName = 0
Set-HardenedValue -Path $policyPath `
    -Name  'DontDisplayLastUserName' `
    -Value 1 `
    -Description 'Letzten Benutzernamen auf Anmeldebildschirm ausblenden'

# --- 3. Name und Bild auf Sperrbildschirm ausblenden ---
# Wert 3: Name und Bild des angemeldeten Benutzers auf dem Sperrbildschirm
# nicht anzeigen. Verhindert Social-Engineering-Angriffe und schützt
# Datenschutz bei unbeaufsichtigtem Gerät.
# BSI SYS.2.2.3.A3
# Rollback: DontDisplayLockedUserId = 1
Set-HardenedValue -Path $policyPath `
    -Name  'DontDisplayLockedUserId' `
    -Value 3 `
    -Description 'Name und Bild auf Sperrbildschirm ausblenden (Wert 3 = Name+Bild)'

# =============================================================================
Write-Log "FERTIG apply-hardening.ps1"
Write-Log "=========================================================="
Write-Host ""
Write-Host "Alle Einstellungen wurden angewendet. Protokoll: $logFile" -ForegroundColor Green
Write-Host "Bitte starten Sie das System neu, damit alle Änderungen wirksam werden." -ForegroundColor Yellow
