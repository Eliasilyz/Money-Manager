# Features

Every feature lives in `lib/features/<name>/` with `application/` (providers/services) and `presentation/` (screens) subfolders.

## Dashboard — `features/dashboard`

Home screen with balance summary and income/expense overview. Period selector via `dashboardPeriodProvider` (`thisMonth`, `threeMonths`, `thisYear`). Multi-currency amounts are converted to the base currency using the exchange-rate registry.

## Transactions — `features/transactions`

Income/expense logging with search, date-range filtering, and daily groupings. Routes: `/transactions`, `/add-transaction` (edit passes the `Transaction` through `state.extra`).

## Transfers — `features/transfers`

Inter-account transfers storing both `sourceAmount` and `destinationAmount`, so cross-currency transfers keep an explicit rate. Routes: `/transfers`, `/add-transfer`.

## Accounts — `features/accounts`

Cash, bank, and e-wallet accounts with per-account currency, typed icon, color, archive flag, and manual `sortOrder`. Balance = initial balance ± transactions. Routes: `/accounts`, `/add-account`, `/manage-accounts`.

## Budgets — `features/budgets`

Category-scoped spending limits with a period and live progress indicators. Form is a modal bottom sheet (`budget_form_sheet.dart`). Route: `/budgets`.

## Goals — `features/goals`

Savings targets with `targetAmount`, `currentAmount`, priority flag, and status; deposits move money into the goal balance. Route: `/goals`.

## Debts — `features/debts`

Money owed to or by you: person, type, original/remaining amount, due date, installment counters (`totalInstallments`, `paidInstallments`, `billingDay`), and a payment history (`debt_payments`). Routes: `/debts`, `/add-debt`.

## Recurring — `features/recurring`

Daily/weekly/monthly/yearly schedules with `interval`, `startDate`, `nextOccurrence`, and an `enabled` toggle. Route: `/recurring`. **Automatic execution is not yet implemented** — see [Known Issues](Known-Issues); users currently log the transactions manually.

## Currencies — `features/currencies`

Currency registry (code, symbol, decimalDigits) plus an exchange-rate table keyed by `(base, target, date)`. Route: `/currencies`. Conversion logic: `ExchangeRate.convertAmount` in `lib/domain/entities/exchange_rate.dart` (unknown pairs fall back to 1:1).

## Categories — `features/categories`

Income/expense categories with `systemKey` for system-managed seeds. Routes: `/categories`, `/add-category`.

## Statistics — `features/statistics`

Monthly income vs. expense breakdown by category, rendered with custom-painted donut/bar segments (no chart dependency). Route: `/statistics`.

## Calendar — `features/calendar`

Interactive calendar grid with per-day spending dots. Route: `/calendar`.

## Notes — `features/notes`

Lightweight financial memos kept alongside your records. Route: `/notes`.

## Security — `features/security`

PIN + biometric lock. Details on the [Security](Security) page. Routes: `/security` (settings) and the lock overlay.

## Settings & Backup — `features/settings`

Theme (light/dark/system + 5 color presets), language, base currency, notifications, app links, and backup. The Backup screen covers local export/import and Google Drive upload/list/restore — details on the [Backup and Restore](Backup-and-Restore) page. Routes: `/settings`, `/backup`, `/notification-settings`.

## Notifications — `features/settings/application/notification_service.dart`

Channels: daily reminder, recurring, debt, budget, backup. The daily reminder (default 19:00) and test notification are implemented; recurring/debt/budget/backup scheduling methods are currently **stubs** — see [Known Issues](Known-Issues).

