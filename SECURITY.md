# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.0.x | ✅ |
| < 1.0 | ❌ |

Security fixes are applied to the latest release on the `master` branch only.

## Reporting a Vulnerability

Please report security issues **privately** — do not open a public GitHub issue.

- **Email:** [farellh12@gmail.com](mailto:farellh12@gmail.com)
- Or use [GitHub Private Vulnerability Reporting](https://github.com/Eliasilyz/Money-Manager/security/advisories/new) if enabled.

Include, when possible:

- Affected version / platform (Android, Windows, …)
- Steps to reproduce
- Impact (e.g. data exposure, bypass of app lock, backup tampering)

You will get an acknowledgement within **72 hours**. If a fix is confirmed, a coordinated disclosure timeline will be agreed with you — typically a fix within **30 days** before any public disclosure.

## Security Measures

| Area | Mechanism |
|---|---|
| App lock | Salted SHA-256 PIN hash, 5-attempt lockout with 60 s cooldown, optional biometrics (`local_auth`) |
| Backup encryption | AES-256-GCM + HMAC-SHA256 encrypt-then-MAC, random salt/IV, constant-time MAC verification (`CryptoUtils`) |
| Backup restore | Format + schema validation, safety snapshot with rollback on failure |
| Data storage | 100% local SQLite — no app server, no telemetry, no third-party analytics |
| Cloud backup | Optional, direct upload to your own Google Drive `appDataFolder` (`drive.appdata` scope only) |

See the [Security wiki page](https://github.com/Eliasilyz/Money-Manager/wiki/Security) for details.

## Known Limitations

These are conscious or known trade-offs, not bugs — see [Known Issues](https://github.com/Eliasilyz/Money-Manager/wiki/Known-Issues) for the full list:

- **Database is not encrypted at rest.** The PIN gates the UI only; anyone with filesystem access (root/backup extraction) can read `money_manager.db`.
- **Backup password KDF is a single HMAC round** — fast for UX, weaker against offline brute-forcing of low-entropy passwords. Use a strong backup password.
- **Encrypted backups are unrecoverable without the password** — there is no recovery path.
- **App lock counter is session-only** — a process restart resets the failed-attempt count.
- **Release APKs are currently debug-signed** — a production keystore is required before store distribution.

## Scope

In scope:

- App lock / biometric bypass
- Backup encryption or restore integrity flaws (tampering, injection, path traversal)
- Unauthorized access to local data or Google Drive backups through the app
- Injection via imported backup files or transaction input

Out of scope:

- Physical/device-level attacks requiring root or a compromised OS
- Social engineering
- Denial of service against the user's own device
- Vulnerabilities in third-party dependencies with no impact on this app (report upstream)
