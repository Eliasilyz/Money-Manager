# Database Schema

SQLite through [Drift](https://drift.simonbinder.eu/). File: `money_manager.db`. Current `schemaVersion`: **4** (`AppConstants.databaseSchemaVersion`).

## Tables (12)

| Table | PK | Columns |
|---|---|---|
| `accounts` | `id` | name, currencyCode (default `IDR`), accountType, initialBalance, icon, color, note, isArchived, sortOrder, systemKey, createdAt, updatedAt |
| `categories` | `id` | name, type (`income`/`expense`/`system`), systemKey, createdAt, updatedAt |
| `transactions` | `id` | type, accountId, categoryId?, amount, currencyCode, description?, date, note?, transferId?, createdAt, updatedAt |
| `transfers` | `id` | fromAccountId, toAccountId, sourceAmount, destinationAmount, currencyCode, date, createdAt, updatedAt |
| `recurring_transactions` | `id` | type, accountId, amount, currencyCode, frequency, interval, startDate, nextOccurrence, enabled, createdAt, updatedAt |
| `budgets` | `id` | categoryId, amount, currencyCode, period, startDate, createdAt, updatedAt |
| `goals` | `id` | name, targetAmount, currentAmount, currencyCode, startDate, isPriority, status, createdAt, updatedAt |
| `debts` | `id` | personName, type, originalAmount, remainingAmount, currencyCode, dueDate, status, createdAt, updatedAt |
| `debt_payments` | `id` | debtId, accountId, amount, date, createdAt |
| `currencies` | `code` | name, symbol, decimalDigits |
| `exchange_rates` | (baseCurrency, targetCurrency, date) | rate |
| `notes` | `id` | title, body, createdAt, updatedAt |

Notes:

- **Money is stored as `IntColumn`** — amounts are integers in the currency's base unit (IDR has `decimalDigits = 0`).
- `transactions` declares indexes on `account_id`, `category_id`, `date`, and `type`.
- Foreign keys are declared as `customConstraints` on the transactions table (account, category, currency, transfer).
- `exchange_rates` has a composite primary key, so one rate per pair per day.

## DAOs (9)

`AccountsDao`, `BudgetsDao`, `CategoriesDao`, `CurrenciesDao`, `DebtsDao`, `GoalsDao`, `NotesDao`, `RecurringDao`, `TransactionsDao` — in `lib/database/daos/`. DAOs expose both one-shot `Future` getters and `Stream` watchers; repositories wrap the watchers for the providers.

## Migrations

Handled in `AppDatabase.migration` (`lib/database/database.dart`):

| Upgrade | Changes |
|---|---|
| → 2 | Create `notes`; add `systemKey` to accounts & categories; add `isPriority` to goals; add `totalInstallments`, `paidInstallments`, `billingDay` to debts |
| → 3 | Add `sortOrder` to accounts |
| → 4 | Drop and recreate `recurring_transactions` (breaking schema change for that table) |

`onCreate` runs `m.createAll()`. A migration test (`test/unit/database_test.dart`) asserts data survives an upgrade.

## Changing the schema

1. Edit the table class in `lib/database/tables/`.
2. Bump `AppConstants.databaseSchemaVersion`.
3. Add an `if (from < N)` block in the `onUpgrade` handler.
4. Run `dart run build_runner build --delete-conflicting-outputs`.
5. Run `flutter test test/unit/database_test.dart`.
