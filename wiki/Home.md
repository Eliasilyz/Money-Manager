# Money Manager

A secure, **offline-first** personal finance app built with Flutter. Multi-account tracking, budgets, debts, recurring transactions, statistics, and encrypted Google Drive backup : with no mandatory internet, no third-party account, and no server in the middle.

| | |
|---|---|
| **Framework** | Flutter `>=3.2.0 <4.0.0` / Dart |
| **Database** | SQLite via [Drift](https://drift.simonbinder.eu/) (local only) |
| **State** | Riverpod `^2.5.1` |
| **Routing** | GoRouter `^14.0.0` |
| **License** | AGPL-3.0 |
| **App ID** | `id.eliasilyz.moneymanager` (v1.0.0+1) |

## Why it exists

Most finance apps require an internet connection, a registered account, or store your records on someone else's server. Money Manager takes the opposite stance:

- **100% offline-first** : all cash flows, balances, and records live in a local SQLite file on your device.
- **Strong encryption** : optional AES-256-GCM + HMAC-SHA256 (encrypt-then-MAC) protection for backups and exports.
- **Own your data** : cloud backup uploads directly to *your* Google Drive `appDataFolder`. No middleman database, no subscription.

## Wiki contents

| Page | What it covers |
|---|---|
| [Getting Started](Getting-Started) | Prerequisites, setup, code generation, running, building |
| [Architecture](Architecture) | Layered design, folder structure, data flow, routing, providers |
| [Database Schema](Database-Schema) | All 12 tables, DAOs, migrations |
| [Features](Features) | Every feature module and where it lives |
| [Security](Security) | PIN, biometrics, lockout, cryptography |
| [Backup and Restore](Backup-and-Restore) | Local + Google Drive backup format, encryption, safety snapshots |
| [Localization](Localization) | English / Bahasa Indonesia, ARB workflow |
| [Testing](Testing) | Unit tests, widget tests, the 720-case screen matrix |
| [Contributing](Contributing) | Workflow, code style, PR checklist |
| [Known Issues](Known-Issues) | Audit findings and current limitations |
| [Privacy Policy](Privacy-Policy) | What data is (and is not) collected |
| [Terms of Service](Terms-of-Service) | Usage terms and disclaimers |
| [Developer Credits](Developer-Credits) | Author, donations, open-source licenses |

## Quick start

```bash
git clone https://github.com/Eliasilyz/Money-Manager.git
cd "Money Manager"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Full details on the [Getting Started](Getting-Started) page.

