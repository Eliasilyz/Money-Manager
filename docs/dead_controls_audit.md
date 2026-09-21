# Dead Controls Audit

Audit of dead controls (buttons/taps that do nothing) in the Money Manager Flutter app.

| File | Line | Control | Status | Fix Plan |
|------|------|---------|--------|----------|
| `lib/features/accounts/presentation/accounts_screen.dart` | 72 | Filter `IconButton` in accounts header | Dead — needs fix | Add filter bottom sheet |
| `lib/features/accounts/presentation/accounts_screen.dart` | 90 | "Atur" `TextButton` in Daftar akun header | Dead — needs fix | Navigate to manage accounts screen |
| `lib/features/accounts/presentation/accounts_screen.dart` | 202 | "Pindah saldo" action | Dead — needs fix | Open add-transfer screen |
| `lib/features/dashboard/presentation/dashboard_screen.dart` | 83 | Notification bell `IconButton` | Dead — needs fix | Show snackbar or navigate to notifications settings |
| `lib/features/dashboard/presentation/dashboard_screen.dart` | 171 | Quick action buttons (Transfer/Pindai/Target/Laporan) | Dead — needs fix | Navigate: Transfer→add-transfer, Anggaran→/budgets, Target→/goals, Statistik→/statistics |
| `lib/features/recurring/presentation/recurring_screen.dart` | 32 | `IconButton` (unspecified) | Dead — needs fix | Check context and wire up action |
| `lib/features/transactions/presentation/transactions_screen.dart` | 118 | Filter `IconButton` in transactions header | Dead — needs fix | Open filter bottom sheet |
