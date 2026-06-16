#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Setzt Registry-Härtungseinstellungen auf Windows-Standardwerte zurück.
.DESCRIPTION
    Stellt die durch apply-hardening.ps1 gesetzten Registry-Werte auf ihre
    originalen Windows-Standardwerte zurück.
.NOTES
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

function Restore-DefaultValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$DefaultValue,
        [string]$Type = 'DWord',
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        Write-Log "ÜBERSPRUNGEN  $Path existiert nicht – kein Rollback nötig für $Name"
        return
    }

    try {
        $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        Write-Log "AKTUELL   $Path\$Name = $currentValue"
    }
    catch {
        Write-Log "NICHT VORHANDEN  $Path\$Name – kein Rollback nötig"
        return
    }

    Set-ItemProperty -Path $Path -Name $Name -Value $DefaultValue -Type $Type -Force
    Write-Log "ZURÜCKGESETZT  $Path\$Name = $DefaultValue  ($Description)"
}

# =============================================================================
Write-Log "=========================================================="
Write-Log "START  rollback.ps1  ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
Write-Log "=========================================================="

$policyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

# Schnellen Benutzerwechsel: Windows-Standard = 0 (aktiviert)
Restore-DefaultValue -Path $policyPath `
    -Name         'HideFastUserSwitching' `
    -DefaultValue 0 `
    -Description  'Schnellen Benutzerwechsel – Standardwert (aktiviert)'

# Letzten Benutzernamen anzeigen: Windows-Standard = 0 (anzeigen)
Restore-DefaultValue -Path $policyPath `
    -Name         'DontDisplayLastUserName' `
    -DefaultValue 0 `
    -Description  'Letzten Benutzernamen anzeigen – Standardwert (anzeigen)'

# Benutzerinfo auf Sperrbildschirm: Windows-Standard = 1 (Anzeigename anzeigen)
Restore-DefaultValue -Path $policyPath `
    -Name         'DontDisplayLockedUserId' `
    -DefaultValue 1 `
    -Description  'Sperrbildschirm-Benutzerinfo – Standardwert (Anzeigename sichtbar)'

# =============================================================================
Write-Log "FERTIG rollback.ps1"
Write-Log "=========================================================="
Write-Host ""
Write-Host "Alle Werte wurden auf Windows-Standardwerte zurückgesetzt. Protokoll: $logFile" -ForegroundColor Green
Write-Host "Bitte starten Sie das System neu." -ForegroundColor Yellow
