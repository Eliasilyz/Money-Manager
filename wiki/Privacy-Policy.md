# Privacy Policy

**Effective date:** September 25, 2026
**App:** Money Manager (`id.eliasilyz.moneymanager`)
**Developer:** Irvan Farael Hanafi — [farellh12@gmail.com](mailto:farellh12@gmail.com)

## Summary

Money Manager is an **offline-first** app. It has no user accounts, no analytics, no ads, and no server of its own. Your financial data stays on your device. The only optional cloud feature — backup — uploads directly to **your own Google Drive**, and only when you turn it on.

## Data the app stores

### On your device (local database)

All records live in a local SQLite file (`money_manager.db`) that never leaves the device unless you export or back it up:

- Accounts, categories, currencies, exchange rates
- Income/expense transactions and transfers
- Budgets, savings goals, debts and debt payments
- Recurring schedules and notes

App preferences (theme, language, PIN hash + salt, notification settings, backup settings) are stored in the app's local preferences.

### On your device (security data)

If you enable the app lock, a **salted SHA-256 hash** of your PIN is stored locally. The PIN itself is never stored, and the lock only protects the app interface — it does not encrypt the database at rest.

## Data the app does NOT collect

- No names, emails, or profile information (the app has no registration)
- No financial data is transmitted to the developer
- No analytics, crash reporting, or advertising identifiers
- No location, contacts, or device identifiers
- No third-party tracking SDKs

## Optional: Google Drive backup

If you choose to sign in with Google and use Drive backup:

- The app requests the OAuth scopes `drive.appdata` and `drive.file`.
- Backup files are written to your Drive **`appDataFolder`**, a hidden folder visible only to you and to the app — it is not shared with anyone and is not part of your normal Drive browsing.
- The app can list, download, and delete **only the backup files it created**.
- Backup files may be encrypted with a password you choose (AES-256-GCM + HMAC-SHA256). The developer cannot decrypt them and never receives them.
- You can disconnect at any time by signing out on the Backup screen or revoking access at [https://myaccount.google.com/permissions](https://myaccount.google.com/permissions).

Google's own terms and privacy policy apply to Google Sign-In and Google Drive. The developer does not receive your Google account information.

## Permissions

| Permission | Why |
|---|---|
| Notifications | Optional reminders you enable (daily summary, budgets, debts, recurring items) |
| Exact alarm | Scheduling those reminders at the chosen time |
| Run at boot (RECEIVE_BOOT_COMPLETED) | Re-schedule reminders after the device restarts |
| Biometric (fingerprint/face) | Optional app unlock, if you enable it |

## Data deletion

- Delete data inside the app (individual records or clear-all via reinstallation).
- Uninstalling the app removes the local database from the device.
- To remove cloud backups: delete the backup files in the app's `appDataFolder` (via the Backup screen) and revoke the app's Google access.
- The developer holds no copy of your data and cannot delete it for you.

## Children

The app is not directed at children under 13 and collects no data from anyone, including children.

## Changes to this policy

Updates will be published on this wiki page with a new effective date. Continued use after a change means acceptance of the revised policy.

## Contact

Questions: [farellh12@gmail.com](mailto:farellh12@gmail.com)
