# Tracker Perbaikan "Money Manager" — Baca Ini Duluan Setiap Sesi

Ini file **checklist utama**. Aturannya:

1. **Kerjakan HANYA 1 task per sesi** (1 checkbox `[ ]` paling atas yang belum dicentang). Jangan lanjut ke task berikutnya di sesi yang sama walau masih ada sisa waktu/context — biar setiap sesi ringan dan nggak crash.
2. Setelah task selesai, centang `[x]` di file ini, tulis ringkasan singkat (3-5 baris: file apa yang diubah, apa isinya) di bagian **Log** paling bawah file ini, lalu **berhenti** — jangan buka task berikutnya.
3. **Jangan baca seluruh isi `mockup-literal-description.md` sekaligus.** Tiap task di bawah menyebutkan section mana saja dari file itu yang relevan (misal "Layar 5") — buka file itu dengan `view` pakai `view_range` atau cukup baca bagian yang disebut, jangan seluruh file.
4. Kalau di tengah task kamu merasa context sudah penuh/berat sebelum task selesai: **stop, commit progress sejauh ini, tulis di Log bagian mana yang belum selesai**, biar sesi berikutnya lanjut dari situ — jangan paksa selesai dalam 1 nafas.
5. Task yang berlabel **[AUDIT]** artinya: cuma bandingkan kode vs mockup dan tulis temuan ke Log — **jangan ubah kode apapun** di task itu. Task **[FIX]** baru boleh ubah kode, dan hanya boleh dikerjakan setelah task [AUDIT] pasangannya selesai & user sudah konfirmasi mau lanjut fix atau tidak.
6. Kalau task [AUDIT] nemu gap yang di luar dugaan/besar, jangan lanjut ke [FIX]-nya otomatis — laporkan ke Log, lalu berhenti, biar user yang putuskan prioritas.

Arsitektur project (untuk konteks singkat tiap sesi, biar nggak perlu explore ulang tiap kali): Clean Architecture (`domain`/`data`/`database`/`features`), state management **Provider** (`*_provider.dart`), database **Drift**, lokalisasi **flutter gen-l10n** (`lib/l10n/*.arb`).

**File referensi tambahan** (sudah ada hasil perbandingan visual mockup vs app aktual, baca ini dulu sebelum audit kode supaya nggak dari nol): `mockup-literal-description.md` (deskripsi 10 layar desain target), `current-app-literal-description.md` (deskripsi 10 layar app sekarang, dari screenshot), `diff-mockup-vs-current.md` (rangkuman perbedaan konkret per item — **task [AUDIT] di bawah wajib baca bagian relevan di file ini dulu sebelum baca kode**, supaya nggak mengulang analisis visual yang sudah ada).

---

## Checklist

### Grup A — Quick win (kecil, 1 sesi cukup)

- [x] **A1. [FIX] Fix warna tab "Pengeluaran & Pemasukan" tidak kelihatan di light mode**
  File: `lib/features/categories/presentation/categories_screen.dart`, cek juga `lib/theme/app_theme.dart` & `app_colors.dart`.
  Cari widget `TabBar`, ganti `labelColor`/`unselectedLabelColor` yang kemungkinan hardcoded jadi theme-aware (`Theme.of(context).colorScheme...`). Referensi kontras yang benar: lihat "Layar 3" di `mockup-literal-description.md` (tab switcher di halaman Tambah Transaksi, kontrasnya jelas di light mode).
  Test di light & dark mode. `flutter analyze`. Task ini kecil, tidak perlu audit terpisah.

### Grup B — Kategori multi-bahasa

- [x] **B1. [AUDIT] Cek implementasi kategori default + konsistensi bahasa UI kategori**
  Baca dulu bagian "Item 1" di `diff-mockup-vs-current.md` — temuan visual: bahasa UI app sekarang campur Inggris/Indonesia secara luas (bukan cuma kategori), jadi cek juga apakah `AppLocalizations` dipakai konsisten di layar Categories atau cuma sebagian.
  Baca kode: `lib/domain/entities/category.dart`, `lib/database/tables/categories_table.dart`, `lib/data/repositories/drift_category_repository.dart`, `lib/domain/services/category_service.dart`, `lib/features/categories/presentation/categories_screen.dart`.
  Cari di mana kategori default (Makanan, Transportasi, dll) di-seed/insert. Tulis ke Log: apakah namanya hardcoded string Indonesia, apakah ada field pembeda kategori-default vs kategori-custom-user, apakah sudah ada mekanisme lokalisasi sama sekali, dan sejauh mana `AppLocalizations` sudah dipakai di layar ini vs hardcoded string.

- [ ] **B2. [FIX] Implementasi kategori default ikut bahasa device**
  (Baru dikerjakan setelah B1 selesai & dikonfirmasi user.)
  Tambah kolom `defaultKey` di `categories_table.dart` kalau belum ada. Tambah key lokalisasi di `lib/l10n/app_en.arb` & `app_id.arb` untuk tiap kategori default. Update tempat render nama kategori (categories_screen.dart, add_category_screen.dart, add_transaction_screen.dart, budgets_screen.dart) untuk resolve label dari lokalisasi kalau `defaultKey != null`. Buat migration (`schemaVersion` + `onUpgrade`) untuk data existing.
  `flutter analyze`.

### Grup C — Mata Uang & Multi-Akun

- [ ] **C1. [AUDIT] Cek implementasi currency & exchange rate saat ini**
  Baca: `lib/domain/entities/currency.dart`, `account.dart`, `balance_calculation.dart`, `lib/database/tables/currencies_table.dart`, `exchange_rates_table.dart`, `lib/data/repositories/drift_currency_repository.dart`, `lib/features/currencies/application/currency_provider.dart`.
  Tulis ke Log: apakah `exchange_rates_table` benar-benar terisi/dipakai, apakah tiap akun punya `currencyCode` yang benar-benar dipakai saat kalkulasi, apakah total saldo gabungan (dashboard) menjumlahkan lintas currency tanpa konversi (bug matematis atau tidak). Referensi: "Layar 9" di mockup — semua akun di mockup pakai Rupiah, jadi mockup TIDAK menunjukkan tampilan target untuk akun beda currency, harus dirancang sendiri konsisten sama pola list-item yang ada.

- [ ] **C2. [FIX] Perbaiki kalkulasi & formatting mata uang**
  (Setelah C1 dikonfirmasi.) Pastikan saldo per-akun tampil di currency aslinya (`NumberFormat.currency` dari `intl`, bukan concat manual). Total gabungan dikonversi ke base currency pakai rate dari `exchange_rates_table`. Ganti semua formatting manual di `dashboard_screen.dart`, `transactions_screen.dart`, `accounts_screen.dart`, `statistics_screen.dart`.
  `flutter analyze`.

- [ ] **C3. [FIX] Dukungan tambah akun dengan currency berbeda**
  (Bisa paralel/lanjutan C2.) Di `add_account_screen.dart`, tambah dropdown pilih currency. Pastikan `currencies_screen.dart` bisa set base/default currency app (field `baseCurrencyCode` di settings), plus opsi refresh/input manual exchange rate untuk mode offline.
  `flutter analyze`.

### Grup D — CRUD Anggaran & Target (Bottom Sheet)

- [ ] **D1. [AUDIT] Cek state CRUD budget & goal saat ini**
  Baca dulu bagian "Item 3" di `diff-mockup-vs-current.md` — catatan penting: tombol **"Setor"** yang sudah ada di card goal itu fitur *deposit saldo ke goal*, BUKAN Edit/Delete goal. Jangan disamakan; yang diminta user adalah Update (edit field goal) & Delete (hapus goal), bukan cuma setor dana.
  Baca kode: `lib/features/budgets/application/budget_provider.dart`, `lib/features/goals/application/goal_provider.dart`, `lib/data/repositories/drift_budget_repository.dart`, `drift_goal_repository.dart`, `lib/core/widgets/pocket_deposit_sheet.dart` (ini kemungkinan widget yang dipakai tombol "Setor" — cek dulu apakah reusable buat form edit juga atau cuma khusus deposit).
  Tulis ke Log: method apa saja yang sudah ada (add/update/delete) di tiap layer (provider → repository → dao), dan konfirmasi fungsi `pocket_deposit_sheet.dart`.

- [ ] **D2. [FIX] Tambah Update & Delete untuk Budget (bottom sheet)**
  (Setelah D1.) Lengkapi `budget_provider.dart` (`updateBudget`, `deleteBudget`) sampai ke Dao kalau kurang. Ubah alur di `budgets_screen.dart`/`budgets_goals_screen.dart`: tap item → `showModalBottomSheet` (reuse form dari `add_budget_screen.dart`, terima parameter opsional untuk mode edit). Tambah delete + dialog konfirmasi.
  Pertahankan visual card budget PERSIS seperti sekarang — lihat "Layar 4" di mockup untuk referensi pola card (ikon, persen, progress bar) kalau perlu dicocokkan.
  `flutter analyze`.

- [ ] **D3. [FIX] Tambah Update & Delete untuk Goal/Target (bottom sheet)**
  Sama seperti D2 tapi untuk `goal_provider.dart` / `goals_screen.dart` / `add_goal_screen.dart`.
  `flutter analyze`.

### Grup E — Halaman Target Tabungan

- [ ] **E1. [AUDIT] Bandingkan halaman Savings Goals saat ini vs mockup**
  Baca dulu bagian "Item 4" di `diff-mockup-vs-current.md` — temuan penting: di app sekarang, "Target Tabungan" adalah **tab "Savings Goals" di dalam halaman `Budgets & Goals`**, BUKAN halaman goals berdiri sendiri dengan tab Hutang (karena fitur Hutang/Debt sama sekali belum ada di app). Jangan cari/buat halaman Hutang — itu di luar scope 6 item awal.
  Baca kode: `lib/features/budgets/presentation/budgets_goals_screen.dart` (cari bagian tab "Savings Goals"-nya) — kalau file ini tidak ada, cek `lib/features/goals/presentation/goals_screen.dart` dan laporkan struktur aslinya.
  Konfirmasi dari diff: pola kartu (1 card besar dengan progress bar utk goal prioritas + kartu kecil tanpa progress bar utk goal lain) **sudah terverifikasi ada di app sekarang**, jadi task E2 nanti fokus menyeragamkan pola kartu ini — tidak perlu re-audit ulang apakah masalahnya nyata atau tidak. Tulis ke Log: lokasi file pasti + konfirmasi widget/struktur kartu.

- [ ] **E2. [FIX] Rapikan tampilan Target Tabungan**
  (Setelah E1 dikonfirmasi user, dan setelah D3 selesai karena butuh CRUD-nya duluan.) Perbaiki spacing/padding/konsistensi card sesuai temuan di E1 + arahan user. Pakai `Theme.of(context).colorScheme` untuk warna, `FittedBox`/`Flexible` untuk cegah overflow teks nominal besar.
  `flutter analyze`.

### Grup F — Transaksi Berulang

- [ ] **F1. [AUDIT] Cek state CRUD recurring transaction saat ini**
  Baca: `lib/domain/entities/recurring_transaction.dart`, `lib/database/tables/recurring_transactions_table.dart`, `lib/data/repositories/drift_recurring_repository.dart`, `lib/features/recurring/application/recurring_provider.dart`, `lib/features/recurring/presentation/recurring_screen.dart`.
  Bandingkan dengan **"Layar 6"** di mockup (section itu saja). Tulis ke Log: field apa yang ada di entity vs mockup (termasuk status "Aktif"), method CRUD apa yang sudah ada di provider/repository/dao, apakah UI `recurring_screen.dart` sudah punya tombol tambah atau belum, apakah ada mekanisme generate transaksi otomatis dari jadwal recurring (cari di `app.dart`/`dashboard_provider.dart`).
  Catat juga soal section "Langganan" di mockup (Netflix/Spotify) sebagai temuan terpisah — JANGAN diasumsikan harus dibangun, itu di luar 6 item awal.

- [ ] **F2. [FIX] Tambah tombol (+) & Create untuk Transaksi Berulang**
  (Setelah F1 dikonfirmasi.) Tambah `FloatingActionButton`/tombol tambah di `recurring_screen.dart`, buka form (reuse pola dari `add_transaction_screen.dart` + field frekuensi & tanggal). Sambungkan ke `recurring_provider.dart` → repository → dao (lengkapi method yang kurang berdasarkan temuan F1).
  `flutter analyze`.

- [ ] **F3. [FIX] Tambah Update, Delete, & toggle Aktif untuk Transaksi Berulang**
  Tap item → form edit ter-prefill. Swipe/tombol delete + konfirmasi. Toggle aktif/nonaktif (pause).
  `flutter analyze`.

- [ ] **F4. [FIX] Mekanisme generate transaksi otomatis dari jadwal**
  Kalau dari F1 ternyata belum ada mekanismenya: implementasikan pengecekan `lastGeneratedDate` vs tanggal sekarang saat app dibuka (di `app.dart` atau saat init `dashboard_provider.dart`), generate transaksi baru ke `transactions_table` untuk yang jatuh tempo.
  `flutter analyze`. Jalankan test terkait di `test/unit/` kalau ada.

### Grup G — Konsistensi Bahasa UI (item baru, di luar 6 item awal — cek prioritas dulu ke user sebelum kerja)

Ditemukan dari perbandingan screenshot: UI app sekarang campur Inggris ("Dashboard", "Transactions", "Save Transaction") dan Indonesia ("Selamat malam", "Transaksi terbaru", "Setor") secara tidak konsisten — ini lebih luas dari Item 1 (yang cuma soal nama kategori default). Grup ini **jangan dikerjakan sebelum user konfirmasi mau ditangani atau tidak** — tandai sebagai opsional.

- [ ] **G1. [AUDIT] Inventarisir semua hardcoded string UI di seluruh app**
  Baca `lib/l10n/app_en.arb` dan `app_id.arb` dulu — lihat berapa banyak key yang sudah ada vs berapa banyak string di `presentation/*.dart` yang masih hardcoded literal (bukan lewat `AppLocalizations.of(context)!.xxx`).
  Grep sederhana: cari pola `Text("..."` atau `Text('...'` di seluruh `lib/features/*/presentation/` yang isinya string literal (bukan variable/lokalisasi). Tulis ke Log: daftar file dengan jumlah string hardcoded terbanyak, urutkan biar bisa dikerjakan bertahap per file di task G2, G3, dst (jangan coba benerin semua sekaligus dalam 1 task).

  *(Task G2 dst akan ditambahkan setelah G1 selesai dan user tentukan file mana duluan yang mau dibereskan — supaya nggak 1 task mencakup seluruh app sekaligus.)*

---

## Log (isi tiap selesai 1 task, urutan kronologis, task terbaru di paling bawah)

<!-- Contoh format:
### A1 — selesai [tanggal]
File diubah: lib/features/categories/presentation/categories_screen.dart
Perubahan: labelColor & unselectedLabelColor TabBar diganti pakai Theme.of(context).colorScheme.primary / onSurface.withOpacity(0.6). Tested light & dark mode, flutter analyze bersih.
-->

### A1 — selesai [23 Sep 2026]
File: `lib/features/categories/presentation/categories_screen.dart` (perbaikan sudah ada di working tree, diubah 19:07 sebelum TASK.md dibuat — diverifikasi sesi ini, tidak ada tambahan kode).
Isi fix: `TabBar` (tab Pengeluaran/Pemasukan) pakai `labelColor: colors.primary`, `unselectedLabelColor: colors.textSecondary`, `indicatorColor: colors.primary` via `AppColorsT.of(context)`; AppBar `backgroundColor: colors.background` — kontras jelas di light (hijau `1B6E4B` di atas `F4F6F5`) & dark (`34A873` di atas `0E1411`).
`app_theme.dart` `tabBarTheme` light (putih) hanya berlaku untuk AppBar hijau default; kedua TabBar di app sudah override sendiri — tidak diubah.
`flutter analyze`: 0 error; 1 warning `non_const_argument_for_const_parameter` (categories_screen.dart:155, pre-existing/identik di HEAD) + 59 info `prefer_const` — di luar scope A1.
Catatan: file-nya `docs/TASK.md` (bukan TASKS.md).

### B1 — selesai [23 Sep 2026] (AUDIT, tanpa ubah kode)
Catatan referensi: `diff-mockup-vs-current.md` & `current-app-literal-description.md` **tidak ada** di `docs/` (hanya TASK, mockup-literal-description, fix_round2_progress, dead_controls_audit) — audit dilakukan langsung dari kode.

Temuan:
1. **Seeding**: `lib/main.dart` → `_seedDefaults(db)` (baris 87-123), jalan sekali saat `categoriesTable` kosong. 16 kategori expense + 8 income + 2 system (`balance_adjustment`, `transfer`). Nama di DB **hardcoded string Indonesia** (`'Makan & Minum'`, `'Transportasi'`, `'Belanja'`, dll) — itu fallback, bukan label final.
2. **Field pembeda default vs custom**: sudah ada — kolom `systemKey` (nullable) di `categories_table.dart`, entity `Category.systemKey`, diisi saat seeding; kategori buatan user `systemKey = null`. → **B2 tidak perlu tambah kolom `defaultKey` — sudah ada, namanya `systemKey`**.
3. **Mekanisme lokalisasi: SUDAH ADA & tampak lengkap** — helper `localizedCategoryName(l10n, systemKey, fallback)` di `lib/core/widgets/app_widgets.dart:8-65` me-map `systemKey` → key `categoryDefault*`; ARB `app_id.arb` & `app_en.arb` punya ~26 key `categoryDefault*` (ID + EN sudah terisi). Fallback dipakai kalau systemKey null/tidak dikenal.
4. **Pemakaian di layar Categories**: `categories_screen.dart` sudah konsisten `AppLocalizations` (title, tab, noData, dialog hapus — via `localizedCategoryName`). `add_category_screen.dart` juga sudah (title `${l10n.add} ${l10n.categories}`, preset via `localizedCategoryName`).
5. **Sisa hardcoded di 2 file layar kategori** (kandidat pekerjaan B2): `add_category_screen.dart` — `'CEPAT TAMBAH'` (l.81), SnackBar `'Masukkan nama kategori'` (l.164), `'Error: $e'` (l.184); `categories_screen.dart` — `'Error: $err'` (l.79). Helper `localizedCategoryName` juga sudah dipakai di ~10 layar lain (transactions, budgets, statistics, calendar, dashboard, recurring).

Implikasi untuk B2: mayoritas pekerjaan B2 (kolom + key ARB + resolve label) **sudah terimplementasi**. Sisa B2 tinggal: (a) 5 hardcoded string di butir 5, (b) pastikan tidak ada layar yang render `cat.name` mentah tanpa `localizedCategoryName` — perlu grep menyeluruh saat B2 dikerjakan, (c) tidak perlu migration tambahan karena `systemKey` sudah ada di schema. Menunggu konfirmasi user mau lanjut B2 atau skip.