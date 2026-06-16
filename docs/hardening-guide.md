# Hardening Guide – Windows 10 Standalone

Dokumentation aller durch `registry/apply-hardening.ps1` umgesetzten Härtungsmaßnahmen.

---

## Überblick

Die Härtungsmaßnahmen adressieren den Anmeldebildschirm und den Sperrbildschirm von Windows 10.
Sie setzen Registry-Werte unter:

```
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
```

Alle Änderungen werden vor dem Setzen protokolliert (`C:\Temp\hardening-log.txt`).
Für einen vollständigen Rollback steht `registry/rollback.ps1` zur Verfügung.

---

## Maßnahmen

### 1. Schnellen Benutzerwechsel deaktivieren

| Eigenschaft       | Wert |
|-------------------|------|
| **Registry-Pfad** | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` |
| **Wertname**      | `HideFastUserSwitching` |
| **Wert (gehärtet)** | `1` (DWORD) |
| **Wert (Standard)** | `0` |

**Begründung:**  
Der schnelle Benutzerwechsel erlaubt es, mehrere Benutzersitzungen gleichzeitig offen zu halten,
ohne sich abzumelden. Auf einem unbeaufsichtigten Gerät könnten so parallel geöffnete Sitzungen
von unbefugten Personen genutzt werden. Durch das Deaktivieren wird sichergestellt, dass eine
aktive Sitzung vollständig gesperrt oder abgemeldet sein muss, bevor ein anderer Nutzer arbeiten kann.

**BSI-Bezug:** SYS.2.2.3.A3 – Ordnungsgemäße Verwaltung von Windows-Benutzerkonten

---

### 2. Letzten Benutzernamen nicht auf dem Anmeldebildschirm anzeigen

| Eigenschaft       | Wert |
|-------------------|------|
| **Registry-Pfad** | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` |
| **Wertname**      | `DontDisplayLastUserName` |
| **Wert (gehärtet)** | `1` (DWORD) |
| **Wert (Standard)** | `0` |

**Begründung:**  
Windows zeigt standardmäßig den Benutzernamen des zuletzt angemeldeten Kontos auf dem
Anmeldebildschirm an. Dies erleichtert gezieltes Erraten oder Brute-Forcing des Passworts,
da ein Angreifer bereits den Benutzernamen kennt. Das Ausblenden des Namens erzwingt,
dass Benutzername und Passwort beide unbekannt sein müssen.

**BSI-Bezug:** SYS.2.2.3.A3; Microsoft-Empfehlung (CIS Benchmark Level 1)

---

### 3. Benutzerinformationen auf dem Sperrbildschirm ausblenden

| Eigenschaft       | Wert |
|-------------------|------|
| **Registry-Pfad** | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` |
| **Wertname**      | `DontDisplayLockedUserId` |
| **Wert (gehärtet)** | `3` (DWORD) |
| **Wert (Standard)** | `1` |

**Werte-Tabelle:**

| Wert | Bedeutung |
|------|-----------|
| `1`  | Anzeigename anzeigen (Standard) |
| `2`  | Anzeigename und E-Mail anzeigen |
| `3`  | Keinerlei Benutzerinformationen anzeigen |

**Begründung:**  
Wenn ein Windows-Gerät gesperrt ist, zeigt der Sperrbildschirm standardmäßig den Anzeigenamen
(und ggf. das Kontobild) des angemeldeten Benutzers. Dies gibt unberechtigten Personen in
Sichtweite des Bildschirms Informationen über interne Benutzerkonten. Mit Wert `3` werden
keinerlei Benutzerinformationen auf dem Sperrbildschirm angezeigt.

**BSI-Bezug:** SYS.2.2.3.A3; Datenschutz-Anforderungen (DSGVO Art. 32)

---

## Backup-Strategie

Vor der Anwendung der Härtungsmaßnahmen sollten vollständige Backups erstellt werden:

### secedit (Lokale Sicherheitsrichtlinien)

```cmd
secpol\export-secpol.cmd
```

Speichert die lokale Sicherheitsrichtlinie nach `C:\Temp\secpol_backup_<Timestamp>.cfg`.
Wiederherstellung mit `secpol\import-secpol.cmd`.

### LGPO (Lokale Gruppenrichtlinien)

```cmd
lgpo\export-lgpo.cmd
```

Speichert alle lokalen Gruppenrichtlinien nach `C:\Temp\GPO-Backup-<Timestamp>\`.
Erfordert `LGPO.exe` aus dem Microsoft Security Compliance Toolkit.
Wiederherstellung mit `lgpo\import-lgpo.cmd`.

---

## Vorgehen bei Problemen

1. **Rollback der Registry-Werte:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File registry\rollback.ps1
   ```

2. **Wiederherstellung der Sicherheitsrichtlinien:**
   ```cmd
   secpol\import-secpol.cmd
   ```

3. **Wiederherstellung der Gruppenrichtlinien:**
   ```cmd
   lgpo\import-lgpo.cmd
   ```

4. **System neu starten** – alle Maßnahmen erfordern einen Neustart zur vollständigen Wirksamkeit.

---

## Weiterführende BSI-Maßnahmen

Über die in `apply-hardening.ps1` enthaltenen Maßnahmen hinaus empfiehlt das BSI
weitere Härtungsschritte, die in `bsi/bsi-registry.ps1` implementiert sind.
Diese Maßnahmen (Autorun, Firewall, SMBv1, LLMNR, WDigest usw.) müssen vor der
Anwendung auf die eigene Umgebung geprüft werden – siehe `README.md`.

Nicht automatisierbare BSI-Anforderungen sind in `bsi/bsi-nicht-automatisiert.md`
dokumentiert.

---

## Referenzen

- BSI IT-Grundschutz-Kompendium SYS.2.2.3 – Clients unter Windows 10
- BSI SiSyPHuS Win10 – Systemaufbau, Protokollierung, Härtung und Sicherheitsfunktionen
- CIS Microsoft Windows 10 Benchmark (Level 1)
- Microsoft Security Baselines (Windows 10)
