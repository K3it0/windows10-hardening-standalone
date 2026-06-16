# BSI SYS.2.2.3 – Mapping: Anforderung → Umsetzung → Status

Vollständige Übersicht aller Anforderungen aus **BSI IT-Grundschutz SYS.2.2.3
(Windows 10 Clients)** mit Umsetzungsstatus für dieses Standalone-Härungspaket.

**Legende:**
- **Umsetzung:** Automatisiert | Manuell | Nicht anwendbar (Standalone) | Teilweise automatisiert
- **Skript:** Dateiname oder `-`
- **Status:** Umgesetzt | Offen | Entfällt

---

## Basis-Anforderungen (SYS.2.2.3.A*)

| BSI-Anforderung | Titel | Umsetzung | Skript | Status | Bemerkung |
|-----------------|-------|-----------|--------|--------|-----------|
| SYS.2.2.3.A1 | Planung des Einsatzes von Windows 10 Clients | Manuell | - | Offen | Betriebskonzept erstellen; siehe `bsi-nicht-automatisiert.md` |
| SYS.2.2.3.A2 | Geeignete Auswahl einer Windows 10 Version und Beschaffung | Manuell | - | Offen | Enterprise LTSC empfohlen für hohen Schutzbedarf |
| SYS.2.2.3.A3 | Geeignete Verwaltung von Windows-Benutzerkonten | Teilweise automatisiert | `registry/apply-hardening.ps1`, `bsi/bsi-registry.ps1` | Teilweise | Anmeldebildschirm gehärtet; Benutzerkonten-Verwaltung manuell |
| SYS.2.2.3.A4 | Telemetrie und Datenschutzeinstellungen von Windows 10 | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Teilweise | Registry-Werte gesetzt; weitere Einstellungen manuell |
| SYS.2.2.3.A5 | Schutz vor Schadsoftware | Manuell | - | Offen | Microsoft Defender aktivieren/konfigurieren; siehe `bsi-nicht-automatisiert.md` |
| SYS.2.2.3.A6 | Integration von Online-Diensten | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Teilweise | SmartScreen per Registry; weitere Cloud-Dienste manuell einschränken |
| SYS.2.2.3.A7 | Lokale Sicherheitsrichtlinien | Teilweise automatisiert | `secpol/export-secpol.cmd`, `secpol/import-secpol.cmd` | Offen | Export/Import-Werkzeuge vorhanden; Richtlinien-Konzept manuell erstellen |
| SYS.2.2.3.A8 | Absicherung des Windows-Netzwerks | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Teilweise | Firewall, LLMNR, SMBv1, NetBIOS per Registry; Firewall-Regelwerk manuell prüfen |

---

## Standard-Anforderungen (SYS.2.2.3.A*)

| BSI-Anforderung | Titel | Umsetzung | Skript | Status | Bemerkung |
|-----------------|-------|-----------|--------|--------|-----------|
| SYS.2.2.3.A9 | Sichere zentrale Authentifizierung von Windows-Nutzern | Nicht anwendbar (Standalone) | - | Entfällt (kein AD) | Erfordert Active Directory / Kerberos |
| SYS.2.2.3.A10 | Konfiguration zum Schutz von Anwendungen in Windows 10 | Manuell | - | Offen | Exploit Guard, AppLocker/WDAC manuell konfigurieren; siehe `bsi-nicht-automatisiert.md` |
| SYS.2.2.3.A11 | Berechtigungsmanagement | Manuell | - | Offen | Separates Admin-Konto anlegen; Built-in Admin umbenennen; Minimalrechte prüfen |
| SYS.2.2.3.A12 | Datei- und Freigabeberechtigungen | Manuell | - | Offen | NTFS-Berechtigungen und Freigaben manuell prüfen/einschränken |
| SYS.2.2.3.A13 | Einsatz von Sicherheitsprodukte für Windows-Clients | Manuell | - | Offen | EDR/AV-Lösung evaluieren und deployen |
| SYS.2.2.3.A14 | Anwendungssteuerung mit AppLocker | Manuell | - | Offen | AppLocker oder WDAC manuell konfigurieren; erfordert Anwendungsinventar |
| SYS.2.2.3.A15 | Einsatz von verschlüsselten Datenträgern | Manuell | - | Offen | BitLocker aktivieren; Recovery-Key extern sichern; siehe `bsi-nicht-automatisiert.md` |
| SYS.2.2.3.A16 | Anbindung von Windows 10 an den Microsoft Store | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Offen | Store-Einschränkung per GPO/Registry möglich; Entscheidung nach Betriebskonzept |
| SYS.2.2.3.A17 | Konfiguration des Telemetrie-Dienstes | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `AllowTelemetry = 0` gesetzt; Dienst-Deaktivierung noch manuell prüfen |
| SYS.2.2.3.A18 | Einschränkung von Cortana | Manuell | - | Offen | Cortana in Einstellungen deaktivieren; ggf. per Registry/GPO |
| SYS.2.2.3.A19 | Einschränkung der Synchronisationsmechanismen von Windows 10 | Manuell | - | Offen | OneDrive, Einstellungssync, Microsoft-Konto manuell einschränken |
| SYS.2.2.3.A20 | Restriktive Vergabe von Zugriffsrechten auf Netzwerkfreigaben | Manuell | - | Offen | Freigaben und Netzwerkberechtigungen manuell auf Minimalprinzip prüfen |

---

## Erhöhte Anforderungen (SYS.2.2.3.A*)

| BSI-Anforderung | Titel | Umsetzung | Skript | Status | Bemerkung |
|-----------------|-------|-----------|--------|--------|-----------|
| SYS.2.2.3.A21 | Einsatz des Encrypting File System EFS | Manuell | - | Offen | EFS bei Bedarf konfigurieren; BitLocker bevorzugt für Volldatenträgerverschlüsselung |
| SYS.2.2.3.A22 | Windows Defender Credential Guard | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Teilweise | WDigest deaktiviert (Vorbereitung); Credential Guard selbst erfordert UEFI/Secure Boot-Konfiguration |
| SYS.2.2.3.A23 | Festplatten- und Dateiverschlüsselung | Manuell | - | Offen | BitLocker inkl. Pre-Boot-PIN für hohen Schutzbedarf; siehe `bsi-nicht-automatisiert.md` |
| SYS.2.2.3.A24 | Verwendung der Windows-Remoteunterstützung | Nicht anwendbar (Standalone) | - | Entfällt (kein AD) | Quick Assist/RDS i. d. R. ohne AD-Infrastruktur nicht zentral verwaltbar; lokal deaktivieren |
| SYS.2.2.3.A25 | Erweiterter Schutz der Anmeldeinformationen in Windows 10 | Teilweise automatisiert | `bsi/bsi-registry.ps1` | Teilweise | WDigest, NTLM-Level, LM-Hash per Registry; Protected Users Security Group erfordert AD |
| SYS.2.2.3.A26 | Verwendung des Systemintegritätsschutzes | Manuell | - | Offen | Secure Boot im BIOS/UEFI aktivieren; UEFI-Einstellungen manuell prüfen |
| SYS.2.2.3.A27 | Verwendung von Windows Defender Application Control | Manuell | - | Offen | WDAC-Richtlinie erstellen, signieren und deployen; hoher Aufwand, erfordert Anwendungsinventar |

---

## Übergreifende Anforderungen (ergänzend)

| Referenz | Titel | Umsetzung | Skript | Status | Bemerkung |
|----------|-------|-----------|--------|--------|-----------|
| SiSyPHuS / SMBv1 | SMBv1 deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Server- und Client-seitig via Registry |
| SiSyPHuS / LLMNR | LLMNR deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Registry: `EnableMulticast = 0` |
| SiSyPHuS / NetBIOS | NetBIOS over TCP/IP deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `NetbiosOptions = 2` auf allen Adaptern |
| SiSyPHuS / WDigest | WDigest-Authentifizierung deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `UseLogonCredential = 0` |
| SiSyPHuS / RemReg | Remote-Registry-Dienst deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `Start = 4` (Disabled) |
| SiSyPHuS / SID | Anonyme SID-Enumeration verbieten | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `RestrictAnonymousSAM = 1`, `RestrictAnonymous = 1` |
| SiSyPHuS / NTLM | NTLMv2-only erzwingen, LM-Hashes deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `LmCompatibilityLevel = 5`, `NoLMHash = 1` |
| SiSyPHuS / UAC | UAC auf höchste Stufe setzen | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Sicherer Desktop, Admin-Zustimmung |
| SiSyPHuS / Explorer | Dateiendungen im Explorer anzeigen | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `HideFileExt = 0` (HKCU); Hinweis: per-user, gilt für ausführenden Benutzer |
| SYS.2.2.3 / RDP | RDP-Härtung (NLA + TLS, RDP bleibt aktiv) | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | NLA, SecurityLayer=2 (TLS), MinEncryptionLevel=3 |
| SYS.2.2.3.A14 / LSA | LSA Protection (RunAsPPL) | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Schützt lsass.exe vor Credential-Dumps; Neustart erforderlich |
| SYS.2.2.3.A3 / Cache | Cached Logons einschränken | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | `CachedLogonsCount = 1` (REG_SZ) |
| SiSyPHuS / PS-Log | PowerShell Script Block Logging | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Event-ID 4104; Erkennung von PS-Malware |
| SiSyPHuS / Teredo | Teredo (IPv6-Tunnel) deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | Verhindert Firewall-Umgehung via IPv6-Tunnel |
| SiSyPHuS / WPAD | WPAD deaktivieren | Automatisiert | `bsi/bsi-registry.ps1` | Umgesetzt | MITM-Schutz; AutoDetect=0 (HKCU + HKLM-Policy) |
| CON.3 | Datensicherungskonzept | Manuell | - | Offen | Backup-Strategie 3-2-1; Wiederherstellungstest; siehe `bsi-nicht-automatisiert.md` |
| ORP.3 | Nutzerschulung | Manuell | - | Offen | Phishing, Passwörter, Meldewege; regelmäßige Schulungen |
| INF.8 | Physische Sicherheit | Manuell | - | Offen | Zutrittsschutz, Secure Boot, BIOS-Passwort; siehe `bsi-nicht-automatisiert.md` |
| OPS.1.1.3 | Patch-Management | Manuell | - | Offen | Windows Update automatisch; Anwendungen separat aktuell halten |

---

## Zusammenfassung

| Kategorie | Anzahl | Davon umgesetzt | Davon offen | Davon entfällt (kein AD) |
|-----------|--------|-----------------|-------------|--------------------------|
| Basis-Anforderungen (A1–A8) | 8 | 1 | 5 | 0 |
| Standard-Anforderungen (A9–A20) | 12 | 1 | 10 | 1 |
| Erhöhte Anforderungen (A21–A27) | 7 | 0 | 5 | 2 |
| SiSyPHuS / übergreifend | 18 | 15 | 3 | 0 |
| **Gesamt** | **45** | **17** | **25** | **3** |

> **Hinweis:** "Teilweise automatisiert" zählt als "Offen", da manuelle Schritte fehlen.
> Ziel ist es, den Status aller offenen Punkte sukzessive auf "Umgesetzt" zu bringen.

---

*Grundlage: BSI IT-Grundschutz-Kompendium Edition 2023, SYS.2.2.3; SiSyPHuS Win10 v1.3*
