# Diff: Mockup (target) vs App Sekarang (aktual, dari screenshot)

Sumber: `mockup-literal-description.md` (target) dibandingkan `current-app-literal-description.md` (aktual, screenshot 23 Sep 2026). Ini **pengganti/percepatan** task-task [AUDIT] di `TASKS.md` — agent tinggal verifikasi tiap poin ke kode yang relevan, tidak perlu menebak dari nol.

---

## Temuan Lintas-Layar (berlaku ke banyak halaman)

1. **Bahasa UI campur, bukan cuma soal kategori default.** App sekarang: judul halaman & label tombol mayoritas Inggris ("Dashboard", "Transactions", "Add Transaction", "Save Transaction", "Close", "Select category"), tapi ada teks Indonesia yang nyelip ("Good night, Elon" harusnya "Selamat malam", "Transaksi terbaru", "6 bulan", "Setor", "Kantong"). Ini **lebih luas dari Item 1 di prompt awal** (yang cuma soal nama kategori default) — kemungkinan app belum benar-benar pakai sistem lokalisasi (`AppLocalizations`) secara konsisten di semua string UI, cuma sebagian. **Perlu diputuskan:** apakah scope Item 1 diperluas jadi "audit semua hardcoded string UI, bukan cuma kategori", atau tetap fokus kategori dulu.
2. **Struktur halaman Transaksi vs Statistik vs Kalender berbeda dari mockup.** Di mockup, "Statistik" dan "Kalender Keuangan" adalah 2 halaman terpisah dengan header sendiri. Di app sekarang, keduanya adalah **state/tab di dalam 1 halaman "Transactions"** (toggle "Analytics" / "Financial Calendar" mengubah konten tapi header & search bar tetap sama). Ini bukan bug — kemungkinan memang desain arsitektur app sekarang begitu. **Tidak perlu diubah kecuali user memang mau restrukturisasi navigasi total.**
3. **Halaman "Budgets & Goals" (app sekarang) menggabungkan Budget + Savings Goals dalam 1 halaman ber-tab** — ini beda dari mockup yang punya "Anggaran" (standalone) dan "Target & Hutang" (Goals+Debt digabung) sebagai 2 konsep terpisah. **Fitur "Hutang/Debt" sama sekali tidak terlihat di app sekarang** (tidak ada di manapun pada 10 screenshot). Kemungkinan Debt belum diimplementasikan sama sekali — ini di luar 6 item yang diminta user, jangan dikerjakan kecuali diminta eksplisit.
4. **Warna tab aktif tidak konsisten:** di layar "Add Transaction", tab "Expense" yang aktif berwarna **merah**, sementara tab aktif di halaman lain (Budgets/Savings Goals) pakai hijau. Perlu diklarifikasi ke user: apakah warna merah untuk tab Expense ini disengaja (semantik: merah = pengeluaran) atau bug.
5. **Data dummy/testing masih ada** (nominal kecil Rp50,000, Rp1,666, dll) — wajar untuk app development, bukan bug.

---

## Per Item (dari 6 item awal user)

### Item 1 — Kategori multi-bahasa
- Halaman "Other" → "Categories" menunjukkan "26 categories" — belum bisa dipastikan dari screenshot berapa yang default vs custom, dan apakah namanya sudah pakai lokalisasi. **Task B1 di TASKS.md tetap perlu dijalankan** (baca kode), tapi sekarang agent tahu bahwa masalah bahasa kemungkinan lebih luas dari sekadar kategori (lihat Temuan Lintas-Layar #1) — sebaiknya B1 diperluas cakupannya untuk cek juga apakah ada infrastruktur `AppLocalizations` yang dipakai sebagian tapi tidak lengkap.

### Item 2 — Mata uang & multi-akun
- Halaman "Other" → "Currency" menunjukkan "Base currency: IDR" — jadi konsep base currency **sudah ada** di UI settings, tinggal dicek apakah logic di baliknya (Item C1/C2 di TASKS.md) benar-benar berfungsi atau cuma label statis.
- Halaman "Accounts & Wallets" di app sekarang isinya cuma akun tipe "Kantong" (savings pocket) — **tidak terlihat ada akun tipe lain (bank/e-wallet/kartu kredit) dalam 4 item yang tampak**, beda dari mockup yang penuh variasi tipe akun. Sebelum implementasi multi-currency (C3), agent perlu cek ke kode: apakah tipe akun selain "Kantong/Savings" sudah ada di `account.dart`/`accounts_table.dart` tapi belum ada datanya, atau memang belum diimplementasikan modelnya sama sekali.

### Item 3 — CRUD Anggaran & Target
- Tombol "Setor" **sudah ada** di card goal (baik goal utama maupun tidak — btw tombol "Setor" hanya terlihat di goal utama/prioritas, tidak di 2 card kecil "Dana Darurat"/"Party"). Ini kemungkinan fitur "tambah saldo ke goal", bukan Edit/Delete goal itu sendiri — **jangan disamakan dengan CRUD Update/Delete yang diminta user**, ini kemungkinan fitur berbeda (deposit) yang sudah ada terpisah.
- Tidak terlihat ada tombol edit/delete/swipe di card Budget atau Goal manapun pada screenshot — **konsisten dengan laporan awal user bahwa CRUD belum lengkap.**
- Tombol header beda antara tab Budgets ("+ Create") dan tab Savings Goals ("+ Add") — inkonsistensi label tombol tambah, bisa disamakan sekalian saat mengerjakan Grup D.

### Item 4 — Halaman Target Tabungan
- Di app sekarang, ini adalah **tab "Savings Goals" di dalam halaman "Budgets & Goals"**, bukan halaman `goals_screen.dart` berdiri sendiri dengan tab "Hutang" (karena Hutang tidak ada). **Task E1 di TASKS.md perlu disesuaikan**: cek `lib/features/budgets/presentation/budgets_goals_screen.dart` (bukan cuma `goals_screen.dart`) untuk cari implementasi tab "Savings Goals" ini.
- Pola kartu goal di app sekarang **sudah mirip temuan di mockup**: 1 card besar dengan progress bar (goal prioritas) + kartu kecil tanpa progress bar untuk goal lain — jadi confirmed, ini bukan asumsi lagi, inkonsistensi ukuran/info card ini **memang ada di app sekarang**, bukan cuma di mockup.
- Badge "PRIORITY" (Inggris) di app vs "PRIORITAS" (Indonesia) di mockup — konsisten dengan temuan bahasa campur di atas.

### Item 5 — Tab warna light mode
- Screenshot yang diberikan tidak mencakup halaman "Categories" secara spesifik (cuma ada entry "Categories — 26 categories" di halaman "Other", belum masuk ke dalamnya). **Task A1 di TASKS.md tetap perlu dikerjakan seperti rencana** — belum ada info baru dari screenshot ini soal halaman Categories.
- Catatan tambahan: tab switcher di "Add Transaction" (Expense/Income/Transfer) terlihat kontras BAIK di kedua state (aktif merah/putih, tidak aktif abu gelap di atas putih) — screenshot ini sepertinya diambil dalam **mode terang**, dan tab tsb kontrasnya OK. Jadi masalah tab tak-kelihatan yang dilaporkan user kemungkinan spesifik ke halaman Categories saja, bukan pola tab switcher di seluruh app.

### Item 6 — Transaksi Berulang
- **Konfirmasi visual: layar "Recurring Transactions" cuma menampilkan ikon + teks "No data yet", benar-benar tidak ada tombol tambah dalam bentuk apapun** — sama persis dengan laporan awal user. Task F1 (audit kode) tetap perlu jalan untuk cek apakah provider/repository sudah siap di layer bawah meski UI-nya kosong, tapi temuan UI-nya sudah pasti: perlu ditambah dari nol di sisi presentation.
- Halaman "Other" menunjukkan "Recurring — 0 active transactions" — counter ini kemungkinan sudah nyambung ke data asli (bukan hardcoded), karena andai ada data ini juga yang perlu update. Perlu dicek saat F2/F3 dikerjakan apakah counter ini otomatis update.

---

## Rekomendasi Urutan Kerja (update dari TASKS.md)

Dengan info baru ini, task [AUDIT] di `TASKS.md` bisa dipercepat karena sebagian sudah terjawab visual di atas — tapi tetap jalankan audit kode (bukan dilewati total) karena diff ini cuma dari tampilan, bukan dari baca kode. Yang berubah:
- **B1**: perluas scope ke "audit semua hardcoded string UI", bukan cuma kategori.
- **E1**: ganti target file jadi `budgets_goals_screen.dart` tab Savings Goals, bukan `goals_screen.dart` terpisah.
- Semua task lain di `TASKS.md` tetap berlaku seperti rencana.

**Sebelum lanjut ke task manapun, user perlu putuskan dulu 1 hal:** apakah mau tambah **Item 7 (baru)** ke tracker — "audit & rapikan konsistensi bahasa UI di seluruh app (bukan cuma kategori)" — karena temuan #1 di atas menunjukkan ini masalah yang lebih besar dari yang tercantum di 6 item awal.