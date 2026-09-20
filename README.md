# Money Manager

Aplikasi manajemen keuangan pribadi multi-mata uang dengan keamanan PIN + biometrik, dibangun dengan Flutter dan design system dari Design.png.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x, Dart |
| State | Riverpod 2.x (StateNotifier + AsyncValue) |
| Routing | go_router (StatefulShellRoute untuk bottom nav) |
| Database | drift (SQLite) — 2 schema migrations |
| Crypto | encrypt (AES-256-GCM + HMAC) + flutter_secure_storage |
| UI | Google Fonts (Outfit, Inter, JetBrains Mono) |

## Features

### Core
- **Dashboard** — saldo bersih, income/expense bulan ini, quick stats, transaksi terakhir
- **Transaksi** — search + filter kalender + grouped by hari
- **Tambah Transaksi** — tab Pengeluaran/Pemasukan, amount card, category chips, date picker
- **Akun & Dompet** — multi-mata uang, saldo bersih, typed icons (Tunai, Bank, E-Wallet)
- **Kategori** — expense/income, custom icon & color
- **Transfer** — transfer antar akun, auto-conversion
- **Budget** — per kategori, progress bar visual
- **Target & Hutang** — tab target tabungan + hutang, priority badge, deadline
- **Transaksi Berulang** — frequency harian/mingguan/bulanan/tahunan
- **Catatan** — CRUD catatan bebas
- **Mata Uang** — daftar default, CRUD custom
- **Statistik** — period tabs, income/expense summary, category breakdown
- **Kalender** — month grid dengan indicator dots, daily transaction summary

### Security & Settings
- **PIN Lock** — SHA-256 hashed PIN, lockout 5 percobaan, startup gate
- **Biometrik** — fingerprint/face unlock via local_auth
- **Backup & Restore** — AES-256-GCM encrypted backup, file picker export/import
- **Daily Reminder** — notifikasi harian jam 19:00

## Getting Started

```bash
flutter pub get
flutter run
```

### Test
```bash
flutter test          # 34 tests — unit + widget
flutter analyze       # No issues
```

## Project Structure

```
lib/
├── core/widgets/          # Reusable components
├── domain/entities/       # Pure Dart entities
├── data/repositories/     # drift DAO implementations
├── features/              # 14 feature modules
├── l10n/                  # Indonesian localization
├── theme/                 # Colors + typography
└── routing/               # go_router configuration
```

## Known Limitations

- Google Drive backup: stub — perlu client ID untuk OAuth
- Tidak ada sinkronisasi cloud
- PIN/biometric tidak dapat diverifikasi tanpa device/emulator
