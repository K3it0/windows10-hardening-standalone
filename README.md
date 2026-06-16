# Windows 10 Standalone Hardening

Härtungs-Skripte für Windows 10 im Standalone-Betrieb (ohne Active Directory / Domäne).  
Die Maßnahmen orientieren sich am **BSI IT-Grundschutz SYS.2.2.3** sowie dem **SiSyPHuS Win10**-Leitfaden des BSI.

---

## Voraussetzungen

- Windows 10 (Version 1903 oder neuer)
- PowerShell 5.1 oder neuer
- **Administratorrechte** auf dem lokalen System
- **LGPO.exe** aus dem [Microsoft Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319) – muss im PATH oder im Verzeichnis `lgpo/` liegen, um `lgpo/export-lgpo.cmd` und `lgpo/import-lgpo.cmd` zu nutzen

---

## Reihenfolge der Anwendung

> **Immer zuerst Backups erstellen, bevor Änderungen vorgenommen werden!**

1. **Backup der Sicherheitsrichtlinien (secedit)**
   ```cmd
   secpol\export-secpol.cmd
   ```

2. **Backup der lokalen Gruppenrichtlinien (LGPO)**
   ```cmd
   lgpo\export-lgpo.cmd
   ```

3. **Eigene Registry-Härtung anwenden**
   ```powershell
   # Als Administrator ausführen:
   powershell -ExecutionPolicy Bypass -File registry\apply-hardening.ps1
   ```

4. **BSI-Empfehlungen anwenden** *(nur nach sorgfältiger Prüfung jeder Einstellung!)*
   ```powershell
   # Als Administrator ausführen:
   powershell -ExecutionPolicy Bypass -File bsi\bsi-registry.ps1
   ```

5. **System neu starten**
   ```powershell
   Restart-Computer
   ```

---

## Rückgängig machen

Einzelne Registry-Werte zurücksetzen:
```powershell
powershell -ExecutionPolicy Bypass -File registry\rollback.ps1
```

Sicherheitsrichtlinien wiederherstellen:
```cmd
secpol\import-secpol.cmd
```

Gruppenrichtlinien wiederherstellen:
```cmd
lgpo\import-lgpo.cmd
```

---

## Wichtige Hinweise

- **Neustart erforderlich:** Einige Einstellungen wirken erst nach einem Systemneustart.
- **`bsi-registry.ps1` nicht blind einsetzen:** Jede Einstellung ist im Skript kommentiert und muss vor der Anwendung auf die eigene Umgebung geprüft werden. Bestimmte Maßnahmen können den Betrieb von Anwendungen beeinträchtigen.
- **Logs:** Alle Skripte schreiben Änderungsprotokolle nach `C:\Temp\`. Dieser Ordner muss existieren oder wird automatisch erstellt.
- **Nicht automatisierbare Maßnahmen:** Siehe `bsi/bsi-nicht-automatisiert.md` für Maßnahmen, die manuelle organisatorische oder physische Umsetzung erfordern.
- **Kein Active Directory:** Diese Skripte sind explizit für Standalone-Systeme konzipiert. AD-spezifische Anforderungen sind in `docs/bsi-mapping.md` als "Entfällt (kein AD)" gekennzeichnet.

---

## Struktur

```
windows10-hardening-standalone/
├── registry/
│   ├── apply-hardening.ps1      # Eigene Registry-Härtungsmaßnahmen
│   └── rollback.ps1             # Rücksetzen auf Windows-Standardwerte
├── secpol/
│   ├── export-secpol.cmd        # Backup der lokalen Sicherheitsrichtlinie
│   └── import-secpol.cmd        # Wiederherstellung der Sicherheitsrichtlinie
├── lgpo/
│   ├── export-lgpo.cmd          # Backup aller lokalen Gruppenrichtlinien
│   └── import-lgpo.cmd          # Wiederherstellung der Gruppenrichtlinien
├── bsi/
│   ├── bsi-registry.ps1         # BSI SYS.2.2.3 / SiSyPHuS Registry-Maßnahmen
│   └── bsi-nicht-automatisiert.md  # Manuelle BSI-Maßnahmen
└── docs/
    ├── hardening-guide.md       # Dokumentation der eigenen Maßnahmen
    └── bsi-mapping.md           # BSI-Anforderungen → Umsetzungsstatus
```

---

## Referenzen

- [BSI IT-Grundschutz SYS.2.2.3 – Clients unter Windows 10](https://www.bsi.bund.de/DE/Themen/ITGrundschutz/ITGrundschutzKompendium/bausteine/SYS/SYS_2_2_3.html)
- [BSI SiSyPHuS Win10 – Studie zu Systemaufbau, Protokollierung, Härtung und Sicherheitsfunktionen](https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Informationen-und-Empfehlungen/Empfehlungen-nach-Angriffszielen/Clients/SiSyPHuS_Win10/SiSyPHuS_node.html)
- [Microsoft Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
