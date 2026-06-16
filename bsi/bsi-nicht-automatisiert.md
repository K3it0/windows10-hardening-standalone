# BSI SYS.2.2.3 – Nicht automatisierbare Maßnahmen

Dieses Dokument listet alle Anforderungen aus **BSI IT-Grundschutz SYS.2.2.3 (Windows 10 Clients)**
und **SiSyPHuS Win10**, die sich nicht oder nicht vollständig per Skript umsetzen lassen.
Sie erfordern organisatorische Maßnahmen, manuelle Konfiguration oder den Einsatz dedizierter Werkzeuge.

---

## SYS.2.2.3.A1 – Planung des Einsatzes von Windows 10 Clients

**BSI-Referenz:** SYS.2.2.3.A1 (Basis)  
**Beschreibung:** Vor dem Einsatz müssen die Nutzungsszenarien, Sicherheitsanforderungen und
der Schutzbedarf der verarbeiteten Daten konzeptionell festgelegt werden.  
**Manuelle Maßnahme:**
- Betriebskonzept für Windows 10 erstellen (Einsatzzweck, Schutzbedarf)
- Festlegen, welche Anwendungen zugelassen sind
- Sicherheitskonzept dokumentieren

---

## SYS.2.2.3.A2 – Geeignete Auswahl einer Windows 10 Version und Beschaffung

**BSI-Referenz:** SYS.2.2.3.A2 (Basis)  
**Beschreibung:** Für den Einsatz in sensitiven Umgebungen wird Windows 10 Enterprise
(LTSC) empfohlen, da es weniger Telemetrie und mehr Kontrolle bietet.  
**Manuelle Maßnahme:**
- Auswahl der geeigneten Edition (Enterprise LTSC für hohen Schutzbedarf)
- Lizenzierung klären
- Bezug über offizielle Kanäle sicherstellen (Integritätsprüfung)

---

## SYS.2.2.3.A5 – Schutz vor Schadsoftware

**BSI-Referenz:** SYS.2.2.3.A5 (Basis)  
**Beschreibung:** Einsatz einer Virenschutz-Lösung, die regelmäßig aktualisiert wird.  
**Manuelle Maßnahme:**
- Microsoft Defender Antivirus aktivieren und aktuell halten (oder alternative Lösung)
- Regelmäßige Signatururpdates sicherstellen (Automatische Updates aktivieren)
- Definition von Ausnahmen dokumentieren und begründen
- Regelmäßige Scans planen (geplante Aufgabe)
- Bei erhöhtem Schutzbedarf: EDR-Lösung (z. B. Microsoft Defender for Endpoint) einsetzen

---

## SYS.2.2.3.A7 – Lokale Sicherheitsrichtlinien

**BSI-Referenz:** SYS.2.2.3.A7 (Basis)  
**Beschreibung:** Lokale Sicherheitsrichtlinien (Passwortrichtlinien, Kontosperrung, Audit)
müssen konfiguriert werden. Teile sind via secedit/LGPO automatisierbar, die Konzepterstellung
und Freigabe ist jedoch ein manueller Prozess.  
**Manuelle Maßnahme:**
- Passwortrichtlinie festlegen (Mindestlänge ≥ 12 Zeichen, Komplexität, Historie)
- Kontosperrrichtlinie definieren (z. B. 5 Fehlversuche → 30 Min. Sperrung)
- Auditrichtlinie dokumentieren und konfigurieren (Anmeldeereignisse, Rechteverwaltung)
- Lokale secpol.msc nach Konzept einstellen oder secedit-Import nutzen

---

## SYS.2.2.3.A9 – Sichere zentrale Authentifizierung (entfällt – kein AD)

**BSI-Referenz:** SYS.2.2.3.A9 (Standard)  
**Beschreibung:** Authentifizierung über Active Directory / Kerberos.  
**Status:** Entfällt – Standalone-System ohne Active Directory.  
Stattdessen: Starke lokale Passwortrichtlinien und ggf. Windows Hello for Business
(lokal) oder FIDO2-Authentikator einsetzen.

---

## SYS.2.2.3.A10 – Konfiguration zum Schutz von Anwendungen in Windows 10

**BSI-Referenz:** SYS.2.2.3.A10 (Standard)  
**Beschreibung:** Exploit-Schutz (Windows Defender Exploit Guard), AppLocker oder
Windows Defender Application Control (WDAC) konfigurieren.  
**Manuelle Maßnahme:**
- Exploit-Schutzeinstellungen über Windows Security > App- und Browsersteuerung konfigurieren
- AppLocker-Regeln erstellen (erfordert Analyse der genutzten Anwendungen)
- WDAC-Richtlinie erstellen und signieren (erfordert Code-Signing-Infrastruktur)
- Anwendungsbestand inventarisieren vor Einschränkung

---

## SYS.2.2.3.A11 – Berechtigungsmanagement

**BSI-Referenz:** SYS.2.2.3.A11 (Standard)  
**Beschreibung:** Lokale Konten und Berechtigungen nach Minimalprinzip vergeben.  
**Manuelle Maßnahme:**
- Separate Konten für Administration und tägliche Arbeit anlegen
- Built-in Administrator-Konto umbenennen und deaktivieren
- Gäste-Konto deaktivieren (prüfen ob bereits deaktiviert)
- Berechtigungen auf Dateisystem und Registry regelmäßig überprüfen
- Prinzip der geringsten Rechte dokumentieren

---

## SYS.2.2.3.A12 – Datei- und Freigabeberechtigungen

**BSI-Referenz:** SYS.2.2.3.A12 (Standard)  
**Beschreibung:** NTFS-Berechtigungen auf Dateisystem- und Freigabeebene korrekt setzen.  
**Manuelle Maßnahme:**
- Freigaben auf das Notwendige beschränken
- Öffentliche Ordner (z. B. `C:\Users\Public`) auf Inhalt prüfen und bereinigen
- Benutzerprofile vor Zugriff durch andere lokale Konten schützen
- Regelmäßige Berechtigungsüberprüfung (icacls oder GUI)

---

## SYS.2.2.3.A15 – Einsatz von verschlüsselten Datenträgern

**BSI-Referenz:** SYS.2.2.3.A15 (Standard)  
**Beschreibung:** Festplattenverschlüsselung mit BitLocker aktivieren.  
**Manuelle Maßnahme:**
- BitLocker auf Systemlaufwerk aktivieren (TPM 2.0 empfohlen)
- Recovery-Key sicher extern aufbewahren (nicht auf demselben Gerät!)
- BitLocker-PIN (Pre-Boot-Authentifizierung) aktivieren für hohen Schutzbedarf
- Wechseldatenträger mit BitLocker To Go verschlüsseln
- Für erhöhten Schutzbedarf: BitLocker-Konfiguration über GPO/LGPO vorgeben

---

## SYS.2.2.3.A16 – Anbindung von Windows 10 an den Microsoft Store

**BSI-Referenz:** SYS.2.2.3.A16 (Standard)  
**Beschreibung:** Store-Zugriff kontrollieren oder einschränken.  
**Manuelle Maßnahme:**
- Prüfen, ob Microsoft Store-Nutzung im Betriebskonzept vorgesehen ist
- Store für Standardbenutzer ggf. über Gruppenrichtlinie deaktivieren
- Business-Store (Microsoft Store for Business) alternativ nutzen

---

## SYS.2.2.3.A17 – Konfiguration des Telemetrie-Dienstes

**BSI-Referenz:** SYS.2.2.3.A17 (Standard)  
**Beschreibung:** Telemetrie-Level per Richtlinie auf das Minimum setzen.  
**Hinweis:** Der Registry-Wert wird in `bsi-registry.ps1` gesetzt. Ergänzend manuelle Maßnahmen:  
- Telemetrie-Dienste prüfen: `Connected User Experiences and Telemetry` auf `Disabled` setzen
- Mit Tools wie O&O ShutUp10++ oder Intune/GPO weitere Datenübertragungen unterdrücken
- Datenschutz-Einstellungen in Windows Security manuell überprüfen (Einstellungen > Datenschutz)

---

## SYS.2.2.3.A18 – Einschränkung von Cortana

**BSI-Referenz:** SYS.2.2.3.A18 (Standard)  
**Beschreibung:** Cortana deaktivieren oder einschränken.  
**Manuelle Maßnahme:**
- Cortana in den Windows-Einstellungen deaktivieren
- Sprachaktivierung deaktivieren
- Cortana-Datenweitergabe-Einstellungen prüfen

---

## SYS.2.2.3.A19 – Einschränkung der Synchronisationsmechanismen

**BSI-Referenz:** SYS.2.2.3.A19 (Standard)  
**Beschreibung:** OneDrive, Einstellungssynchronisation und andere Cloud-Dienste einschränken.  
**Manuelle Maßnahme:**
- OneDrive-Synchronisation deaktivieren (Gruppenrichtlinie oder Deinstallation)
- Einstellungssynchronisation via Microsoft-Konto deaktivieren
- Lokales Konto statt Microsoft-Konto verwenden

---

## SYS.2.2.3.A20 – Datenschutzeinstellungen

**BSI-Referenz:** SYS.2.2.3.A20 (Hoch)  
**Beschreibung:** Umfangreiche Datenschutzkonfiguration (Kamera, Mikrofon, Standort usw.).  
**Manuelle Maßnahme:**
- Einstellungen > Datenschutz: alle nicht benötigten App-Berechtigungen widerrufen
- Diagnose und Feedback auf Minimum setzen
- Aktivitätsverlauf deaktivieren
- Standortdienste deaktivieren (wenn nicht benötigt)
- Kamera- und Mikrofonzugriff pro App einschränken

---

## Physische Sicherheit

**BSI-Referenz:** SYS.2.2.3.A1, OPS.1.1 (übergreifend)  
**Beschreibung:** Physischer Schutz des Geräts vor unbefugtem Zugriff.  
**Manuelle Maßnahme:**
- Gerät in gesichertem Raum aufstellen oder mit Kensington-Schloss sichern
- Keine Boot-Möglichkeit von externen Medien (BIOS/UEFI-Einstellungen, Secure Boot)
- BIOS/UEFI mit Passwort schützen
- Displaysperre nach kurzer Inaktivität (≤ 5 Minuten) erzwingen
- Bildschirmsichtschutz bei Nutzung in öffentlichen Bereichen

---

## Patch-Management

**BSI-Referenz:** SYS.2.2.3.A7 (Basis), OPS.1.1.3  
**Beschreibung:** Regelmäßiges und zeitnahes Einspielen von Sicherheitsupdates.  
**Manuelle Maßnahme:**
- Windows Update auf automatisch stellen (zumindest Sicherheitsupdates)
- Installationszeitfenster festlegen (Wartungsfenster)
- Update-Status regelmäßig prüfen
- Anwendungen (Browser, Office, PDF-Reader) separat aktuell halten
- Update-Prozess dokumentieren und Verantwortlichkeit klären

---

## Datensicherungskonzept

**BSI-Referenz:** CON.3 – Datensicherungskonzept  
**Beschreibung:** Regelmäßige Backups aller relevanten Daten.  
**Manuelle Maßnahme:**
- Backup-Strategie nach 3-2-1-Regel (3 Kopien, 2 Medientypen, 1 extern)
- Windows-Dateiversionsverlauf aktivieren oder Drittanbieter-Backup einsetzen
- Wiederherstellbarkeit regelmäßig testen
- Backup-Medien verschlüsseln
- Recovery-Datenträger (Windows-Wiederherstellungslaufwerk) erstellen

---

## Nutzerschulung und Sicherheitsbewusstsein

**BSI-Referenz:** ORP.3 – Sensibilisierung und Schulung  
**Beschreibung:** Nutzer müssen für Sicherheitsrisiken sensibilisiert werden.  
**Manuelle Maßnahme:**
- Schulung zu Phishing, Social Engineering, sichere Passwörter
- Richtlinien für Umgang mit E-Mail-Anhängen und Links vermitteln
- Meldewege für Sicherheitsvorfälle kommunizieren
- Regelmäßige Auffrischungsschulungen

---

## Virenschutz / Endpoint Detection & Response

**BSI-Referenz:** SYS.2.2.3.A5 (Basis)  
**Beschreibung:** Antivirenschutz und bei Bedarf EDR-Lösung.  
**Manuelle Maßnahme:**
- Microsoft Defender Antivirus im aktivierten Zustand belassen
- Cloud-Schutz und automatische Beispielübermittlung gemäß Datenschutzanforderungen konfigurieren
- Bei hohem Schutzbedarf: Microsoft Defender for Endpoint oder kommerzielle EDR-Lösung
- Regelmäßige Überprüfung der Schutzstatus-Meldungen

---

*Letzte Aktualisierung: 2024 | Grundlage: BSI IT-Grundschutz-Kompendium Edition 2023, SiSyPHuS Win10 v1.3*
