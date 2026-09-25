# Backup and Restore

Implementation: `lib/features/settings/application/backup_service.dart` and `google_drive_service.dart`, UI on the `/backup` screen.

## Backup format

```json
{
  "format": "money_manager_backup",
  "schemaVersion": 1,
  "appVersion": "1.0.0",
  "exportedAt": "2026-01-01T00:00:00.000Z",
  "data": { "accounts": [...], "transactions": [...], ... }
}
```

- The JSON is **gzipped** (`createCompressedBackup`) → `.json.gz` payload.
- On restore, both gzipped and plain JSON are accepted.
- `schemaVersion` (`AppConstants.backupSchemaVersion`) is checked: **newer-than-app backups are rejected**, older ones are accepted and migrated.

## Encryption (optional)

If a password is set, the bundle is wrapped:

```json
{ "format": "encrypted_backup", "payload": "<base64 envelope>" }
```

The payload uses [AES-256-GCM + HMAC-SHA256](Security) via `CryptoUtils`. Wrong password or tampering fails the MAC check with a localized error.

## Safety snapshot

Before overwriting the database, `restoreBackup` flow:

1. `createSafetySnapshot()` — copies current data aside
2. Restore the new data
3. Success → `deleteSafetySnapshot()`
4. Failure → `rollbackFromSafetySnapshot()`

Malformed rows or unknown collections abort the restore and leave existing data intact (covered in `test/unit/backup_service_test.dart`).

## Google Drive

- **Auth**: `google_sign_in` with scopes `drive.appdata` + `drive.file` (`features/settings/application/auth_service.dart`).
- **Storage location**: the Drive **`appDataFolder`** — hidden in the Drive UI, visible only to your app, never shared.
- **Upload**: multipart POST to `googleapis.com/upload/drive/v3/files?uploadType=multipart`, with metadata properties `app=money_manager` and `isAutoBackup=true|false`.
- **Retention**: `trimOldAutoBackups` keeps the newest N auto-backups (configurable, default 5) and enforces a size budget.
- **List/restore/delete**: listing returns `DriveBackupFile` entries; restore downloads the bytes, gunzips, parses, then runs the same safety-snapshot flow as local restore.

## Change detection & status

- `shouldSkipBackup` / `getDatabaseDataHash` hash the canonical data JSON (MD5) so unchanged data can skip an upload.
- Last backup time, hash, and last failure reason are persisted in `SharedPreferences` and shown on the backup screen.

## Settings

| Setting | Key | Default |
|---|---|---|
| Auto backup | `auto_backup` | off |
| Interval | `backup_interval` | Daily |
| Max retained backups | `max_backups` | 5 |
| Wi-Fi only | `wifi_only` | on |
| Encrypt backups | `encrypt_backup` | off |

> The auto-backup *preferences* are stored, but no background scheduler currently calls `performBackupToDrive` — uploads are manual from the backup screen. See [Known Issues](Known-Issues).
