# Contributing

## Workflow

1. Fork and create a feature branch: `git checkout -b feature/AmazingFeature`
2. Make your changes
3. Verify before pushing:

   ```bash
   flutter analyze
   flutter test test/unit
   dart run build_runner build --delete-conflicting-outputs   # if schema/arb changed
   flutter test
   ```

4. Commit with a conventional prefix (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`)
5. Push and open a Pull Request

## Code style

- `flutter_lints` via `analysis_options.yaml` — `flutter analyze` must report **0 issues**
- Follow the existing feature-first layout: new screens go in `features/<name>/presentation/`, providers in `features/<name>/application/`
- Business rules belong in `lib/domain/services/`, not in widgets
- UI strings: never hardcode — add keys to **both** `app_id.arb` and `app_en.arb`, then `flutter gen-l10n`
- Money amounts are `int` (base currency units); never use `double` for storage
- Theme colors come from `AppColors` / the active preset, not raw hex values in widgets

## Schema changes

Bump `AppConstants.databaseSchemaVersion`, add the `if (from < N)` migration block, regenerate, and add/extend a case in `test/unit/database_test.dart`.

## Testing expectations

- New business logic → a unit test in `test/unit/`
- New screen → it is automatically covered by `test/ui/screen_matrix_test.dart` only if you add it to the `_screens` map; add it there when the screen is stable

## License

By contributing you agree your changes are licensed under AGPL-3.0 (same as the project).
