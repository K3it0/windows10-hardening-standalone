#Requires -RunAsAdministrator
<#
.SYNOPSIS
    BSI SYS.2.2.3 / SiSyPHuS Win10 – Registry-Härtungsmaßnahmen
.DESCRIPTION
    Setzt Registry-Einstellungen gemäß BSI IT-Grundschutz SYS.2.2.3 (Windows 10 Clients)
    und SiSyPHuS Win10. Jede Einstellung enthält Referenz, Beschreibung, Pfad/Wert
    und den Rollback-Standardwert als Kommentar.

    ACHTUNG: Jede Einstellung vor Anwendung auf die eigene Umgebung prüfen!
    Bestimmte Maßnahmen können den Betrieb von Anwendungen beeinträchtigen.
.NOTES
    Log: C:\Temp\bsi-hardening-log.txt
    Neustart empfohlen nach Anwendung.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Admin-Prüfung ---
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Dieses Skript muss als Administrator ausgeführt werden. Abbruch."
    exit 1
}

# --- Log-Setup ---
$logDir  = 'C:\Temp'
$logFile = "$logDir\bsi-hardening-log.txt"
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

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = 'DWord',
        [string]$Ref,
        [string]$Description
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "ERSTELLT  $Path"
    }

    try {
        $old = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        Write-Log "[$Ref] ALT: $Name = $old  | $Description"
    }
    catch {
        Write-Log "[$Ref] NEU: $Name (vorher nicht vorhanden)  | $Description"
    }

    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    Write-Log "[$Ref] GESETZT: $Name = $Value"
}

# =============================================================================
Write-Log "=========================================================="
Write-Log "START  bsi-registry.ps1  ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
Write-Log "=========================================================="


# =============================================================================
# 1. AUTORUN / AUTOPLAY DEAKTIVIEREN
# BSI: SYS.2.2.3.A4 – Verwendung geeigneter Sicherheitsprodukte; SiSyPHuS Kap. 5
# Beschreibung: Autorun auf allen Laufwerkstypen (0xFF = alle) deaktivieren.
#               Verhindert automatische Ausführung von Schadcode von USB/CD.
# Rollback: NoDriveTypeAutoRun = 0x91 (Windows-Standard: nur Netzlaufwerke+unbekannt)
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
    -Name  'NoDriveTypeAutoRun' `
    -Value 0xFF `
    -Type  'DWord' `
    -Ref   'SYS.2.2.3.A4' `
    -Description 'Autorun auf allen Laufwerkstypen deaktivieren'

# Autoplay für alle Benutzer deaktivieren (Gruppenrichtlinien-Äquivalent)
# Rollback: DisableAutoplay = 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
    -Name  'DisableAutoplay' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A4' `
    -Description 'Autoplay systemweit deaktivieren'


# =============================================================================
# 2. WINDOWS-FIREWALL ERZWINGEN (alle Profile)
# BSI: SYS.2.2.3.A8 – Absicherung des Windows-Netzwerks; SiSyPHuS Kap. 8
# Beschreibung: Windows-Firewall für Domänen-, privates und öffentliches Profil
#               aktivieren und erzwingen. Eingehende Verbindungen blockieren,
#               ausgehende erlauben (Standard).
# Rollback: EnableFirewall = 0 (deaktiviert)
# =============================================================================
$fwBase = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'

# Domänenprofil
Set-RegValue -Path "$fwBase\DomainProfile" `
    -Name  'EnableFirewall' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall Domänenprofil aktivieren'

Set-RegValue -Path "$fwBase\DomainProfile" `
    -Name  'DefaultInboundAction' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall Domäne: eingehend blockieren (1=Block)'

# Privates Profil
Set-RegValue -Path "$fwBase\PrivateProfile" `
    -Name  'EnableFirewall' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall privates Profil aktivieren'

Set-RegValue -Path "$fwBase\PrivateProfile" `
    -Name  'DefaultInboundAction' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall Privat: eingehend blockieren'

# Öffentliches Profil
Set-RegValue -Path "$fwBase\PublicProfile" `
    -Name  'EnableFirewall' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall öffentliches Profil aktivieren'

Set-RegValue -Path "$fwBase\PublicProfile" `
    -Name  'DefaultInboundAction' -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Firewall Öffentlich: eingehend blockieren'


# =============================================================================
# 3. SMBv1 DEAKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 8 / BSI-Empfehlung nach WannaCry
# Beschreibung: SMBv1 ist veraltet und enthält kritische Schwachstellen
#               (EternalBlue). Deaktivierung über Registry (Lanman-Parameter).
# Rollback: SMB1 = 1 (aktiviert) – Windows-Standard auf älteren Systemen
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' `
    -Name  'SMB1' `
    -Value 0 `
    -Ref   'SiSyPHuS/SMBv1' `
    -Description 'SMBv1-Protokoll serverseitig deaktivieren'

# SMBv1 clientseitig deaktivieren (MR-Client Treiber)
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10' `
    -Name  'Start' `
    -Value 4 `
    -Ref   'SiSyPHuS/SMBv1' `
    -Description 'SMBv1-Client-Treiber deaktivieren (Start=4 = Disabled)'


# =============================================================================
# 4. LLMNR (Link-Local Multicast Name Resolution) DEAKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 8 / SYS.2.2.3.A8
# Beschreibung: LLMNR kann für MITM-/Poisoning-Angriffe (Responder) missbraucht
#               werden. Deaktivieren, wenn kein Bedarf besteht.
# Rollback: EnableMulticast = 1 (aktiviert, Windows-Standard)
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' `
    -Name  'EnableMulticast' `
    -Value 0 `
    -Ref   'SiSyPHuS/LLMNR' `
    -Description 'LLMNR deaktivieren (verhindert Name-Poisoning-Angriffe)'


# =============================================================================
# 5. NETBIOS OVER TCP/IP DEAKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 8
# Beschreibung: NetBIOS over TCP/IP ermöglicht NBNS-Poisoning und SMB-Relay-
#               Angriffe. Deaktivieren auf allen Netzwerkadaptern.
#               Wert 2 = NetBIOS over TCP/IP deaktivieren.
# Rollback: NetbiosOptions = 0 (DHCP-gesteuert, Windows-Standard)
# Hinweis: Wirkt auf alle vorhandenen Netzwerkadapter.
# =============================================================================
$netbiosPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces'
if (Test-Path $netbiosPath) {
    Get-ChildItem -Path $netbiosPath | ForEach-Object {
        Set-RegValue -Path $_.PSPath `
            -Name  'NetbiosOptions' `
            -Value 2 `
            -Ref   'SiSyPHuS/NetBIOS' `
            -Description "NetBIOS over TCP/IP deaktivieren auf: $($_.PSChildName)"
    }
}
else {
    Write-Log "[SiSyPHuS/NetBIOS] WARNUNG: Pfad $netbiosPath nicht gefunden – NetBIOS nicht angepasst."
}


# =============================================================================
# 6. WDIGEST-AUTHENTIFIZIERUNG DEAKTIVIEREN (Credential Guard Vorbereitung)
# BSI: SiSyPHuS Win10 Kap. 6 / SYS.2.2.3.A14
# Beschreibung: WDigest speichert Klartext-Passwörter im LSASS-Speicher.
#               Deaktivieren reduziert das Risiko von Pass-the-Hash-Angriffen
#               und ist Voraussetzung für Windows Credential Guard.
# Rollback: UseLogonCredential = 1 (aktiviert auf älteren Systemen)
#           Auf Windows 10 ist der Standardwert 0 (deaktiviert) – Eintrag setzt explizit.
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' `
    -Name  'UseLogonCredential' `
    -Value 0 `
    -Ref   'SYS.2.2.3.A14' `
    -Description 'WDigest-Klartext-Cache im LSASS deaktivieren'


# =============================================================================
# 7. REMOTE-REGISTRIERUNG DEAKTIVIEREN
# BSI: SYS.2.2.3.A8; SiSyPHuS Win10 Kap. 8
# Beschreibung: Der Remote-Registry-Dienst erlaubt Fernzugriff auf die Registry.
#               Für Standalone-Systeme ohne Bedarf deaktivieren.
#               Start = 4 = Disabled (manueller Start bleibt über Dienste möglich).
# Rollback: Start = 3 (manuell, Windows-Standard)
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\RemoteRegistry' `
    -Name  'Start' `
    -Value 4 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'Remote-Registry-Dienst deaktivieren (Start=4)'


# =============================================================================
# 8. ANONYME SID-ENUMERATION VERBIETEN
# BSI: SYS.2.2.3.A3; SiSyPHuS Win10 Kap. 7
# Beschreibung: Verhindert, dass anonyme (nicht authentifizierte) Benutzer
#               Sicherheits-IDs (SIDs) und Kontonamen des Systems abfragen.
# Rollback: RestrictAnonymousSAM = 0 (keine Einschränkung)
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name  'RestrictAnonymousSAM' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'Anonyme SAM-Abfragen (SID-Enumeration) verbieten'

# Zusätzlich: Anonymen Zugriff auf freigegebene Ressourcen einschränken
# Rollback: RestrictAnonymous = 0
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name  'RestrictAnonymous' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'Anonymen Netzwerkzugriff auf SAM/Shares einschränken'


# =============================================================================
# 9. NTLM-AUTHENTIFIZIERUNG STÄRKEN (LM-Hashes verbieten)
# BSI: SYS.2.2.3.A3; SiSyPHuS Win10 Kap. 6
# Beschreibung: LmCompatibilityLevel = 5 erzwingt NTLMv2-only.
#               LM- und NTLM-Antworten werden verweigert; nur NTLMv2 akzeptiert.
# Rollback: LmCompatibilityLevel = 3 (Windows-Standard sende NTLMv2, akzeptiere alle)
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name  'LmCompatibilityLevel' `
    -Value 5 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'NTLMv2-only erzwingen; LM/NTLM-Authentifizierung ablehnen'

# LM-Hashes nicht im SAM speichern
# Rollback: NoLMHash = 0
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name  'NoLMHash' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'LAN Manager-Hash-Speicherung deaktivieren'


# =============================================================================
# 10. WINDOWS SCRIPT HOST EINSCHRÄNKEN
# BSI: SYS.2.2.3.A4; SiSyPHuS Win10 Kap. 5
# Beschreibung: WSH erlaubt Ausführung von VBScript/JScript außerhalb des Browsers.
#               Deaktivieren reduziert die Angriffsfläche für Script-Malware.
#               ACHTUNG: Kann Verwaltungsskripte und Anwendungen beeinträchtigen!
# Rollback: Enabled = 1 (aktiviert)
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings' `
    -Name  'Enabled' `
    -Value 0 `
    -Ref   'SYS.2.2.3.A4' `
    -Description 'Windows Script Host deaktivieren (VBScript/JScript außerhalb Browser)'


# =============================================================================
# 11. UAC AUF HÖCHSTE STUFE SETZEN
# BSI: SYS.2.2.3.A3; SiSyPHuS Win10 Kap. 7
# Beschreibung: ConsentPromptBehaviorAdmin = 2 = Zustimmung auf sicherem Desktop
#               PromptOnSecureDesktop = 1 = sicherer Desktop für UAC-Dialog
# Rollback: ConsentPromptBehaviorAdmin = 5, PromptOnSecureDesktop = 1
# =============================================================================
$uacPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

Set-RegValue -Path $uacPath `
    -Name  'ConsentPromptBehaviorAdmin' `
    -Value 2 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'UAC: Zustimmung für Admins auf sicherem Desktop anfordern'

Set-RegValue -Path $uacPath `
    -Name  'PromptOnSecureDesktop' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'UAC: Sicheren Desktop für Eingabeaufforderung verwenden'

# UAC für Standard-Benutzer: Zugriff verweigern (nicht still erhöhen)
# Rollback: ConsentPromptBehaviorUser = 3
Set-RegValue -Path $uacPath `
    -Name  'ConsentPromptBehaviorUser' `
    -Value 0 `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'UAC: Standardbenutzer-Erhöhungsversuche automatisch ablehnen'


# =============================================================================
# 12. WINDOWS DEFENDER SMARTSCREEN ERZWINGEN
# BSI: SYS.2.2.3.A6; SiSyPHuS Win10 Kap. 5
# Beschreibung: SmartScreen für Explorer und Edge erzwingen.
#               Warnt vor unbekannten/gefährlichen Programmen und Webseiten.
# Rollback: EnableSmartScreen = 1 (Warn), ShellSmartScreenLevel = Warn
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name  'EnableSmartScreen' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A6' `
    -Description 'SmartScreen für Windows Explorer aktivieren'

Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
    -Name  'ShellSmartScreenLevel' `
    -Value 'Block' `
    -Type  'String' `
    -Ref   'SYS.2.2.3.A6' `
    -Description 'SmartScreen-Stufe: Block (nicht nur Warn)'


# =============================================================================
# 13. TELEMETRIE AUF MINIMUM REDUZIEREN
# BSI: SYS.2.2.3.A13; SiSyPHuS Win10 Kap. 9
# Beschreibung: AllowTelemetry = 0 = Sicherheitsdaten only (Security-Edition)
#               Auf Home/Pro ist Mindestwert = 1 (Basic/Required).
#               Wert 0 wird auf Enterprise/Education angewendet.
# Rollback: AllowTelemetry = 3 (Full, Windows-Standard)
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
    -Name  'AllowTelemetry' `
    -Value 0 `
    -Ref   'SYS.2.2.3.A13' `
    -Description 'Telemetrie auf Minimum (0=Security) reduzieren'



# =============================================================================
# 14. DATEIENDUNGEN IM EXPLORER IMMER ANZEIGEN – ALLE BENUTZER
# BSI: SYS.2.2.3.A4; SiSyPHuS Win10 Kap. 5
# Beschreibung: Windows blendet standardmäßig Dateiendungen bekannter Dateitypen
#               aus. Angreifer nutzen dies, um Schadsoftware als harmlose Datei
#               zu tarnen (z. B. "rechnung.pdf.exe" erscheint als "rechnung.pdf").
#               Gilt für:
#               a) Alle bestehenden Benutzerprofile (geladene + ungeladene Hives)
#               b) Neue Benutzerkonten (Default-User-Hive)
# Rollback: HideFileExt = 1 (Dateiendungen ausblenden, Windows-Standard)
# =============================================================================
$explorerAdvKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$explorerAdvPS  = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# --- a) Aktuellen Benutzer (HKCU, immer geladen) ---
Set-RegValue -Path "HKCU:\$explorerAdvPS" `
    -Name  'HideFileExt' `
    -Value 0 `
    -Ref   'SYS.2.2.3.A4' `
    -Description 'Dateiendungen anzeigen – aktueller Benutzer (HKCU)'

# --- b) Alle bestehenden Benutzerprofile ---
$profileListPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$profiles = Get-ChildItem -Path $profileListPath |
    Where-Object { $_.PSChildName -match '^S-1-5-21-' } # Nur echte Benutzer-SIDs

foreach ($profile in $profiles) {
    $sid         = $profile.PSChildName
    $profilePath = (Get-ItemProperty -Path $profile.PSPath).ProfileImagePath
    $ntUserDat   = "$profilePath\NTUSER.DAT"
    $hiveMounted = $false

    # Prüfen ob der Hive bereits in HKU geladen ist (Benutzer aktiv angemeldet)
    if (Test-Path "Registry::HKU\$sid") {
        Write-Log "[SYS.2.2.3.A4] Hive geladen: $sid ($profilePath)"
    }
    elseif (Test-Path $ntUserDat) {
        # Hive temporär laden
        $null = & reg load "HKU\$sid" $ntUserDat 2>&1
        if ($LASTEXITCODE -eq 0) {
            $hiveMounted = $true
            Write-Log "[SYS.2.2.3.A4] Hive gemountet: $sid ($profilePath)"
        }
        else {
            Write-Log "[SYS.2.2.3.A4] WARNUNG: Hive konnte nicht geladen werden: $ntUserDat"
            continue
        }
    }
    else {
        Write-Log "[SYS.2.2.3.A4] ÜBERSPRUNGEN: NTUSER.DAT nicht gefunden für $sid"
        continue
    }

    try {
        $regPath = "Registry::HKU\$sid\$explorerAdvKey"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        $old = (Get-ItemProperty -Path $regPath -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
        Set-ItemProperty -Path $regPath -Name 'HideFileExt' -Value 0 -Type DWord -Force
        Write-Log "[SYS.2.2.3.A4] GESETZT HideFileExt = 0 (war: $old) für SID $sid"
    }
    finally {
        # Hive wieder entladen wenn wir ihn geladen haben
        if ($hiveMounted) {
            [GC]::Collect()
            $null = & reg unload "HKU\$sid" 2>&1
        }
    }
}

# --- c) Default-User-Profil (gilt für alle neuen Benutzerkonten) ---
$defaultHivePath = 'C:\Users\Default\NTUSER.DAT'
if (Test-Path $defaultHivePath) {
    $null = & reg load 'HKU\DefaultUserTemp' $defaultHivePath 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            $defPath = "Registry::HKU\DefaultUserTemp\$explorerAdvKey"
            if (-not (Test-Path $defPath)) {
                New-Item -Path $defPath -Force | Out-Null
            }
            $old = (Get-ItemProperty -Path $defPath -Name 'HideFileExt' -ErrorAction SilentlyContinue).HideFileExt
            Set-ItemProperty -Path $defPath -Name 'HideFileExt' -Value 0 -Type DWord -Force
            Write-Log "[SYS.2.2.3.A4] GESETZT HideFileExt = 0 (war: $old) im Default-User-Profil"
        }
        finally {
            [GC]::Collect()
            $null = & reg unload 'HKU\DefaultUserTemp' 2>&1
        }
    }
    else {
        Write-Log "[SYS.2.2.3.A4] WARNUNG: Default-User-Hive konnte nicht geladen werden."
    }
}
else {
    Write-Log "[SYS.2.2.3.A4] WARNUNG: Default-User-Profil nicht gefunden: $defaultHivePath"
}


# =============================================================================
# 15. RDP-HÄRTUNG (NLA + TLS + VERSCHLÜSSELUNG)
# BSI: SYS.2.2.3.A8; SiSyPHuS Win10 Kap. 8
# Beschreibung: RDP bleibt aktiviert, wird aber auf sichere Authentifizierung
#               und Verschlüsselung gezwungen:
#               - UserAuthentication = 1: Network Level Authentication (NLA)
#                 erzwingt Vorauthentifizierung VOR dem Desktop-Zugriff.
#               - SecurityLayer = 2: TLS statt des schwächeren RDP-Eigenprotokolls.
#               - MinEncryptionLevel = 3: Nur High-Encryption (128-Bit) erlaubt.
# Rollback: UserAuthentication=0, SecurityLayer=0, MinEncryptionLevel=1
# =============================================================================
$rdpPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

Set-RegValue -Path $rdpPath `
    -Name  'UserAuthentication' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'RDP: Network Level Authentication (NLA) erzwingen'

Set-RegValue -Path $rdpPath `
    -Name  'SecurityLayer' `
    -Value 2 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'RDP: TLS als Sicherheitsebene erzwingen (2=SSL/TLS)'

Set-RegValue -Path $rdpPath `
    -Name  'MinEncryptionLevel' `
    -Value 3 `
    -Ref   'SYS.2.2.3.A8' `
    -Description 'RDP: Mindestverschlüsselung auf High (128-Bit) setzen'


# =============================================================================
# 16. LSA PROTECTION (RUNASPPL)
# BSI: SYS.2.2.3.A14; SiSyPHuS Win10 Kap. 6
# Beschreibung: Aktiviert den Protected Process Light-Modus für lsass.exe.
#               Verhindert, dass nicht-signierte Treiber und Tools (z. B. Mimikatz)
#               Credentials direkt aus dem LSASS-Prozessspeicher auslesen können.
# Voraussetzung: Neustart erforderlich. Auf Systemen ohne Secure Boot vor
#               Aktivierung prüfen, ob Treiber-Kompatibilität gewährleistet ist.
# Rollback: RunAsPPL = 0 (kein LSA-Schutz)
# =============================================================================
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name  'RunAsPPL' `
    -Value 1 `
    -Ref   'SYS.2.2.3.A14' `
    -Description 'LSA Protection: lsass.exe als Protected Process Light starten'


# =============================================================================
# 17. CACHED LOGONS EINSCHRÄNKEN
# BSI: SYS.2.2.3.A3; SiSyPHuS Win10 Kap. 7
# Beschreibung: Windows cached standardmäßig 10 Anmeldeinformationen lokal,
#               damit Benutzer sich auch ohne Domäne anmelden können.
#               Auf 1 reduzieren minimiert den Angriffsvector bei physischem Zugriff.
# Hinweis: Wert ist REG_SZ (String), nicht DWORD!
# Rollback: CachedLogonsCount = "10" (Windows-Standard)
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' `
    -Name  'CachedLogonsCount' `
    -Value '1' `
    -Type  'String' `
    -Ref   'SYS.2.2.3.A3' `
    -Description 'Gecachte Anmeldeinformationen auf maximal 1 begrenzen'


# =============================================================================
# 18. POWERSHELL SCRIPT BLOCK LOGGING AKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 9; BSI OPS.1.1
# Beschreibung: Protokolliert jeden ausgeführten PowerShell-Codeblock im
#               Windows-Event-Log (Event-ID 4104, Provider: Microsoft-Windows-
#               PowerShell/Operational). Essenziell zur Erkennung und
#               forensischen Analyse von PS-basierter Malware und Living-off-the-Land-Angriffen.
# Rollback: EnableScriptBlockLogging = 0
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' `
    -Name  'EnableScriptBlockLogging' `
    -Value 1 `
    -Ref   'SiSyPHuS/PS-Logging' `
    -Description 'PowerShell Script Block Logging in Event-Log aktivieren (Event 4104)'


# =============================================================================
# 19. TEREDO DEAKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 8
# Beschreibung: Teredo ist ein IPv6-Tunneling-Protokoll über UDP/IPv4. Es kann
#               genutzt werden, um IPv4-Firewallregeln zu umgehen, da IPv6-Traffic
#               oft nicht gesondert gefiltert wird. Deaktivieren wenn IPv6-Konnektivität
#               nicht explizit über Teredo benötigt wird.
# Rollback: Teredo_State = "Default" oder Schlüssel löschen
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition' `
    -Name  'Teredo_State' `
    -Value 'Disabled' `
    -Type  'String' `
    -Ref   'SiSyPHuS/Teredo' `
    -Description 'Teredo IPv6-Tunnel deaktivieren (Firewall-Umgehung verhindern)'


# =============================================================================
# 20. WPAD (WEB PROXY AUTO DISCOVERY) DEAKTIVIEREN
# BSI: SiSyPHuS Win10 Kap. 8
# Beschreibung: WPAD ermöglicht automatische Proxy-Konfiguration über das Netzwerk.
#               In unsicheren Netzen kann WPAD für MITM-Angriffe (WPAD-Spoofing)
#               missbraucht werden. Deaktivieren wenn kein automatischer Proxy benötigt.
# Rollback: EnableAutoProxyResultCache = 1, AutoDetect = 1
# =============================================================================
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings' `
    -Name  'EnableAutoProxyResultCache' `
    -Value 0 `
    -Ref   'SiSyPHuS/WPAD' `
    -Description 'WPAD-Proxy-Cache deaktivieren (HKLM-Policy)'

Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' `
    -Name  'AutoDetect' `
    -Value 0 `
    -Ref   'SiSyPHuS/WPAD' `
    -Description 'Automatische Proxy-Erkennung (WPAD) für aktuellen Benutzer deaktivieren'


# =============================================================================
Write-Log "FERTIG bsi-registry.ps1"
Write-Log "=========================================================="
Write-Host ""
Write-Host "BSI-Einstellungen wurden angewendet. Protokoll: $logFile" -ForegroundColor Green
Write-Host "Bitte prüfen Sie das Log und starten Sie das System neu." -ForegroundColor Yellow
