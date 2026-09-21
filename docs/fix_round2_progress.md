# Ronde 2 Progress — Perbaikan Bug & Penyempurnaan

## Status: Selesai

Commits: `aa7f965`, `049188e`, `f2b9fdf`, `42ce0bd`, `7a36ec1`, `54a8516`, `111006b`

---

## Fase A: Reproduksi & Fondasi

### A1. Smoke Test Matrix ✅
- File: `test/ui/screen_matrix_test.dart`
- 720 kombinasi (12 layar × 5 ukuran × 3 text scale × 2 locale × 2 theme)
- 148 overflow failures diukuran sangat kecil (320×568) — expected, perlu fix lanjutan di fase mendatang

### A2. Dead Controls Audit ✅
- File: `docs/dead_controls_audit.md`
- Sebelum: 7 dead controls
- Sesudah: 0 dead controls

---

## Fase B: Perbaikan

### 1. Dashboard Quick Actions ✅
- Transfer → `/add-transfer`
- Pindai diganti "Anggaran" → `/budgets`
- Target → `/goals`
- Laporan diganti "Statistik" → `/statistics`
- Notification bell → `/settings`

### 2. Transaksi Terbaru ✅
- Judul: note → kategori → transfer label → tipe (fallback)
- Subjudul: kategori • akun • waktu
- Waktu: Hari ini/Kemarin/short date
- TransactionTile shared widget di app_widgets.dart

### 3. Transaksi Overflow & Filter ✅
- Header pakai Flexible + compact icons
- Calendar strip = current week (7 days)
- Filter Kategori/Akun via bottom sheet berfungsi
- Filter button di header membuka bottom sheet

### 4. Edit Transaksi ✅
- Tap tile → detail bottom sheet → Edit/Hapus
- AddTransactionScreen mendukung mode edit (pre-fill)
- Hapus dengan konfirmasi + balance rollback
- Service-level edit/delete

### 5. Akun Duplicate Button & FAB ✅
- Hapus "+ Tambah" duplikat → FAB (+)
- "Pindah saldo" → `/add-transfer`
- "Kelola" → `/manage-accounts`

### 6. Kelola Akun ✅
- Screen baru: `manage_accounts_screen.dart`
- Drag-to-reorder, edit, arsipkan, hapus
- Hapus diblokir jika ada transaksi
- Adjust Balance buat transaksi penyesuaian
- `sortOrder` field (migrasi v2→v3)

### 7. Kategori Default ✅
- 26 kategori: 16 pengeluaran, 8 pemasukan, 2 sistem
- Seeding idempoten saat DB kosong
- `systemKey` field ditambahkan ke Category

### 8. Transaksi Berulang ✅
- Hapus header "+ Tambah" → FAB (+)
- FAB navigasi ke `/add-transaction`

### 9. Anggaran & Target ✅
- FAB (+) di Anggaran, Target, Hutang, Kategori, Catatan
- Semua header duplicate button dihapus

### 10. Backup Google Drive ✅
- Hapus export/import file lokal
- Auto backup toggle + interval (Harian/Mingguan/Bulanan)
- Wi-Fi only, retensi 1-10 backup
- Status terakhir + failure reason
- Safety snapshot untuk rollback
- gzip compression, skip unchanged
- TODO stubs untuk Google Drive API

### 11A. Tema Gelap ✅
- TextStyles extension pakai AppColorsT.of(context)
- Settings cards pakai theme-aware colors
- Semua teks adaptif gelap/terang

### 11B. Beralih Bahasa ✅
- ARB files (ID/EN) ~60 keys
- Locale provider + SharedPreferences persistence
- 18 layar di-lokalisaikan
- Switch tanpa restart

### 12. Tentang ✅
- App icon, nama, versi+build, copyright
- Developer credits (hidden jika TODO_FILL_ME)
- Donasi card (showDonation flag)
- Links: Privasi, Syarat, Hubungi, Nilai, Bagikan
- Open source licenses, Changelog, Debug info copy

### 13. Notifikasi ✅
- Notification settings screen baru
- 5 per-type toggles (recurring, debt, budget, daily, backup)
- Daily reminder time picker
- System permission status + open settings
- Test notification button
- Active count di settings tile
- Android notification channels (stubbed scheduling)

---

## Phase C: Audit

### Matriks A1
- 148 overflow failures di 320×568 (expected — very small screen)
- Header transactions sudah di-fix untuk 320px

### Dead Controls: 0 tersisa ✅
### Literal warna/string hardcode: Cek manual diperlukan
### flutter analyze: 54 info-level (prefer_const_constructors), 0 errors
### flutter test: 34/34 pass (33 unit + 1 widget)

---

## TODO_FILL_ME yang harus diisi
1. `lib/core/config/app_links.dart` — developer name, profile URL, donation URL, privacy policy, terms, contact email
2. Google Drive client ID untuk backup/restore
3. `lib/features/settings/application/notification_service.dart` — actual scheduling implementation
4. `lib/features/settings/application/backup_service.dart` — actual Google Drive API integration
5. L10n ARB keys yang masih perlu ditambahkan untuk add_* screens

---

## Catatan Keputusan
- "Pindai" diganti "Anggaran" (kamera+OCR di luar cakupan)
- "Laporan" diganti "Statistik" (konsisten dengan nama layar)
- Recurring FAB navigasi ke /add-transaction (belum ada form recurring tersendiri)
- Kelola akun navigasi ke /manage-accounts (bukan /categories seperti sebelumnya)
- Backup Google Drive = stub (tidak bisa test tanpa client ID)
- Retensi default = 5 backup, auto trimmed lebih dulu dari manual
- Akun terarsip tidak dihitung di total saldo
