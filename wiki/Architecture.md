# Architecture

Money Manager follows a **Feature-First Clean Architecture**: each domain module isolates its data, business logic, and presentation concerns.

## Data flow

```
Presentation (screens, sheets)
        │  watches
        ▼
Riverpod providers (features/<feature>/application)
        │  calls
        ▼
Repositories (domain contracts → data implementations)
        │  queries
        ▼
Drift DAOs (lib/database/daos)
        │  reads/writes
        ▼
Local SQLite (money_manager.db)
```

There is no network layer in the data path. The only HTTP calls in the app are Google Drive backup uploads/downloads in `features/settings/application/google_drive_service.dart`.

## Layer responsibilities

| Layer | Location | Contents |
|---|---|---|
| Presentation | `lib/features/*/**/presentation` | Screens, bottom sheets, forms |
| Application | `lib/features/*/**/application` | Riverpod providers, feature services |
| Domain | `lib/domain` | Pure Dart entities, repository interfaces, business services (`TransactionService`, `AccountService`, `CategoryService`) |
| Data | `lib/data/repositories` | `Drift*Repository` implementations that map Drift rows → domain entities |
| Database | `lib/database` | `AppDatabase`, table definitions, DAOs, migrations |
| Core | `lib/core` | Crypto (`CryptoUtils`), constants (`AppConstants`), config (`AppLinks`), shared widgets |
| Theme | `lib/theme` | Color palettes (`AppColors`, 5 presets), `AppTheme` light/dark builders |
| L10n | `lib/l10n` | ARB templates + generated localizations |

## Wiring (lib/main.dart)

`main()` builds one `AppDatabase`, constructs all nine repositories, then passes them into `ProviderScope` via `overrideWithValue`. Providers themselves are declared with a throwing default (see `lib/app.dart: databaseProvider`), so forgetting the override fails fast with a clear `StateError` instead of silently opening a second database.

After opening the DB, `main()` seeds defaults on first launch:

- **5 currencies**: IDR, USD, EUR, GBP, JPY
- **26 categories**: 16 expense, 8 income, 2 system (`balance_adjustment`, `transfer`), each with a `systemKey` for future locale-aware renaming

## Routing (lib/routing/router.dart)

GoRouter with a `StatefulShellRoute.indexedStack` bottom navigation shell:

| Branch | Path | Screen |
|---|---|---|
| 1 | `/` | Dashboard |
| 2 | `/transactions` | Transactions |
| 3 | `/accounts` | Accounts |
| 4 | `/settings` | Settings |

Standalone routes: `/add-transaction`, `/add-account`, `/manage-accounts`, `/transfers`, `/add-transfer`, `/budgets`, `/goals`, `/debts`, `/add-debt`, `/categories`, `/add-category`, `/notes`, `/backup`, `/security`, `/recurring`, `/currencies`, `/notification-settings`, `/statistics`, `/calendar`.

Edit flows pass the existing entity through `state.extra` (e.g. `GoRoute('/add-transaction')` casts `state.extra as Transaction?`).

## App lock overlay

`MoneyManagerApp.build` watches `appLockedProvider` and renders `LockScreen` in a `Stack` **on top of** the router output. The whole navigation state stays mounted behind the lock, so unlocking returns you exactly where you were.

## State management conventions

- **`FutureProvider`** — one-shot async reads (e.g. `dashboardProvider`).
- **`StreamProvider` / `StreamProvider.family`** — reactive DB queries via Drift `watch*` methods, so screens update automatically on writes.
- **`StateProvider`** — UI state (selected period, locale, theme, lock state).
- **`Provider`** — services and repositories.
- Feature providers live in `features/<name>/application/<name>_provider.dart` (13 of them: accounts, budgets, categories, currencies, dashboard, debts, goals, notes, recurring, security, settings, transactions, transfers).
