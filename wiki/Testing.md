# Testing

## Suites

| File | Type | Count | Covers |
|---|---|---|---|
| `test/unit/database_test.dart` | unit | 7 | CRUD on accounts/currencies/categories/transactions/transfers, schema version, migration keeps data |
| `test/unit/backup_service_test.dart` | unit | 10 | Export→restore roundtrip, schema checks, corrupted/unknown/malformed rejection, encrypted-with-password |
| `test/unit/crypto_utils_test.dart` | unit | 5 | AES-GCM roundtrip, wrong password, random salt/IV, tamper detection, hash stability |
| `test/unit/transaction_service_test.dart` | unit | 3 | addExpense / addIncome persistence, category lookup |
| `test/unit/account_service_test.dart` | unit | 2 | UUID creation, balance handling, non-IDR currency |
| `test/unit/exchange_rate_test.dart` | unit | 4 | Direct/inverse pairs, unknown fallback, same-currency identity |
| `test/unit/recurring_test.dart` | unit | 3 | next-occurrence math, repository CRUD, form sheet create/edit/delete |
| `test/unit/theme_test.dart` | unit | 3 | Distinct light/dark tokens, WCAG contrast in both modes |
| `test/unit/l10n_placeholder_order_test.dart` | unit | 3 | Placeholder order parity across locales |
| `test/widget_test.dart` | widget | 1 | App boots with an in-memory DB |
| `test/ui/screen_matrix_test.dart` | widget | 720 | 12 screens × 5 sizes × 3 text scales × 2 locales × 2 themes |

## Running

```bash
# Everything
flutter test

# Fast inner loop
flutter test test/unit

# Screen matrix (needs a generous timeout — it renders 720 combinations)
flutter test test/ui/screen_matrix_test.dart --timeout 60s
```

> **Note:** `flutter test` currently runs flaky on some machines — suites pass in isolation but the full run can report `did not complete` timeouts. Run suites separately until this is resolved. See [Known Issues](Known-Issues).

## The screen matrix

`test/ui/screen_matrix_test.dart` pumps every major screen across:

- **Sizes**: 320×568, 360×640, 390×844, 430×932, 768×1024
- **Text scales**: 1.0, 1.3, 2.0
- **Locales**: `id`, `en`
- **Themes**: light, dark

and fails the test if a layout **overflow** FlutterError occurs. Repositories are replaced with empty in-memory fakes, `GoogleFonts` runtime fetching is disabled, and `initializeDateFormatting` runs in `setUpAll`.

## Conventions

- Tests use `AppDatabase.memory()` (`NativeDatabase.memory()`) — never the real file.
- No mock framework; repository fakes are hand-written classes implementing the `IAccountRepository`-style domain interfaces.
- Prefer adding cases to the existing unit groups over creating new files.
