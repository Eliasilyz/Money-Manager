# Known Issues

Findings from a code audit (September 2026). `flutter analyze` reports **0 issues** and all unit/widget tests pass when run per-suite; the items below are behavioral gaps, rough edges, and risks.

## High priority

### 1. Full test run is flaky

`flutter test` (all suites at once) intermittently reports `did not complete` timeouts, mostly in `test/ui/screen_matrix_test.dart` and occasionally `test/unit/recurring_test.dart`. Each suite passes reliably when run alone (matrix: 720/720 in ~27 s; unit: 40/40). Likely a concurrency/timeout issue in the test runner on Windows. Until fixed, run suites separately (see [Testing](Testing)).

### 2. Auto-backup preferences are not wired to a scheduler

The backup screen stores `auto_backup`, `backup_interval`, `max_backups`, and `wifi_only`, and `BackupService.performBackupToDrive` exists — but no `Timer`/background task ever invokes it. Auto-backup only happens if the user taps upload manually. `AppConstants.autoBackupInterval` and `defaultMaxBackups` are also defined but referenced nowhere.

### 3. Four notification types are stubs

`features/settings/application/notification_service.dart`:

| Method | Status |
|---|---|
| `scheduleDaily` | Implemented |
| `sendTestNotification` | Implemented |
| `scheduleRecurring()` | **Stub** — TODO comment, does nothing |
| `scheduleDebtReminders()` | **Stub** — TODO |
| `checkBudgetThreshold()` | **Stub** — TODO |
| `checkBackupFailures()` | **Stub** — TODO |

The notification settings screen has matching TODOs for rescheduling on toggle. Users can enable these toggles but will never receive those notifications.

### 4. Recurring transactions do not auto-execute

`recurring_provider.dart` (51 lines) only manages CRUD. Nothing creates the actual transaction when `nextOccurrence` passes — matching the first item on the README roadmap. `flutter_local_notifications` reminders are also unimplemented (see above).

### 5. Google Drive credentials look misconfigured

`android/app/google-services.json` contains an OAuth **desktop/installed** client JSON (`{"installed": {...}}`), not a valid google-services format (no `project_info` / `client` array). The Google Services Gradle plugin is **not applied** either. `google_sign_in` may still work via the plugin-free path, but Drive features should be verified on a real device before release.

### 6. Release builds are debug-signed

`android/app/build.gradle.kts` signs the `release` build type with `signingConfigs.debug` (default Flutter template TODO). Must be replaced with a real keystore before store publication. Note: `minifyEnabled`/`shrinkResources` are on, with `proguard-rules.pro`.

## Medium priority

### 7. Placeholders shipped in user-visible links

`lib/core/config/app_links.dart`: `privacyPolicyUrl`, `termsOfServiceUrl`, `rateAppUrl` are `'https://TODO_FILL_ME'`. The `hasPrivacyPolicy`-style getters correctly hide these entries in the UI, but privacy policy / ToS links are effectively missing — required for Play Store submission.

### 8. Two l10n strings contain literal "TODO Drive"

`backupSuccessNoUpload` → *"Backup successful (not uploaded — TODO Drive)"* and `restoreSuccessDrive` → *"Restore successful (TODO: implement Drive download)"*. Drive upload/restore **is** implemented now, and neither key is referenced by any feature code — dead strings that should be deleted.

### 9. Empty `lib/features/backup/` scaffolding

The folder contains four empty directories (`application/`, `data/`, `domain/`, `presentation/`) with zero files. The real backup code lives in `features/settings/application/`. Either populate or delete the empty tree (git does not track empty dirs — it only exists locally after a fresh checkout of... actually it survives because of `.gitkeep`-less dirs only locally; harmless but confusing).

### 10. Dead code in `main.dart`

`_migrateSchema(AppDatabase db)` is an empty async function called at startup — migrations are handled entirely by Drift's `MigrationStrategy`. Remove it.

### 11. Lockout cooldown is spoofable

After 5 wrong PINs the lockout dialog delays 60 s (`Future.delayed`), then resets `_attempts`. Backing out of the app or hot-restart resets the counter immediately — the counter lives in widget state, not persisted. Adequate against casual shoulder-surfing, weak against a determined local attacker.

### 12. Backup change-detection uses MD5

`shouldSkipBackup`/`getDatabaseDataHash` use MD5 for *change detection only* (not security), so this is acceptable — but note SHA-256 is already imported and costs nothing.

## Low priority / informational

- **No CI**: no `.github/workflows` — `flutter analyze` + `flutter test` are not enforced on PRs.
- **No database-at-rest encryption**: SQLite is plain text; the PIN only gates UI access ([Security](Security)).
- **Fast KDF**: `CryptoUtils.deriveKey` is a single-round HMAC — fine for UX, weak against offline brute force of a low-entropy backup password.
- **`intl` date symbols**: `initializeDateFormatting('id_ID')` and `('en_US')` are both awaited-less in `main()`; works because `gen-l10n` bundles locale data, but the calls are redundant.
- **Screenshots section in README is an empty TODO.**
- **README platform badge** says "Android | Windows" while iOS/Linux/macOS/web folders exist (untested platforms).

## Roadmap (from README)

- [ ] Automated transaction generation when recurring schedules come due
- [ ] Automatic multi-currency net balance aggregation on Dashboard
- [ ] Locale-aware default categories on first launch
- [ ] Inline bottom-sheet CRUD for budgets and goals
