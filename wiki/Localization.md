# Localization

Two languages ship out of the box: **English (`en`)** and **Bahasa Indonesia (`id`)**. Indonesian is the template locale.

## Files

| File | Role |
|---|---|
| `lib/l10n/app_id.arb` | Template ARB (source of truth for keys) |
| `lib/l10n/app_en.arb` | English translations |
| `lib/l10n/app_localizations.dart` + `_en.dart` + `_id.dart` | Generated — do not edit by hand |
| `l10n.yaml` | gen-l10n config (`template-arb-file: app_id.arb`) |

Both locales currently carry **502 message keys** with matching placeholder orders (enforced by `test/unit/l10n_placeholder_order_test.dart`).

## Usage in code

```dart
import 'package:money_manager/l10n/app_localizations.dart';

Text(AppLocalizations.of(context).someKey)
```

For services running outside a widget context, `lib/l10n/l10n_loader.dart` exposes `loadAppL10n()` which resolves the current locale from settings.

## Adding or changing strings

1. Add the key to **both** `app_id.arb` and `app_en.arb` (id is the template — missing keys there break generation).
2. Use `{placeholder}` syntax for interpolation and declare each placeholder in the `@key` metadata block.
3. Regenerate:

   ```bash
   flutter gen-l10n
   ```

4. Run `flutter test test/unit/l10n_placeholder_order_test.dart` to confirm placeholder orders match across locales.

## Adding a new language

1. Create `lib/l10n/app_<code>.arb` translated from `app_id.arb`.
2. Add `Locale('<code>')` to `supportedLocales` in `lib/app.dart`.
3. Add the language option to the locale picker in `features/settings`.
4. Run `flutter gen-l10n` and the full test suite.

## Current limitation

Default seed categories created on first launch use **hardcoded Indonesian names** (`Makan & Minum`, `Transportasi`, …). They are not localized at runtime — a locale-aware seeding rework is on the roadmap.
