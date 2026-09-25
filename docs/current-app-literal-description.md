# Deskripsi Literal App SAAT INI (dari screenshot asli, 23 Sep 2026)

Murni deskriptif, tanpa opini. Urutan: baris atas 5 layar (kiri-kanan), baris bawah 5 layar (kiri-kanan).

**Catatan umum sebelum detail per layar:** UI chrome (judul halaman, label field, tombol) app sekarang mayoritas **Bahasa Inggris** ("Dashboard", "Transactions", "Add Transaction", "Budgets & Goals", dst), sementara sebagian teks lain Bahasa Indonesia campur ("Good night, Elon", "Transaksi terbaru", "6 bulan", "Setor", "Needs Attention" tapi ada "Kantong Kantong Transportasi"). Ini beda dari mockup yang full Bahasa Indonesia semua.

---

## 1. Dashboard
- Header: "Good night, Elon" / "Wednesday, 23 September" (kiri), dropdown "September 2026" dengan ikon kalender (kanan).
- Card hijau "Total Balance" (ada ikon mata di kanan judul) → "Rp 18,000,000". Di bawahnya 2 kolom kecil: titik hijau "Income" "Rp 50,000"; titik merah "Expenses" "Rp 50,000".
- 3 kotak stat: "Today" / "Rp 50,000"; "This Month" / "Rp 50,000"; "Total Balance" / "Rp 18,000,0..." (terpotong).
- Card "Cash Flow" "6 bulan" (label bulan campur Indonesia) — bar chart, sumbu bulan "Apr May Jun Jul Aug Sep", cuma terlihat 2 batang berisi data (Aug oranye, Sep hijau) — bulan lain kosong/tidak ada batang.
- "Transaksi terbaru" (Indonesia) / "See All" (Inggris) — 1 item terlihat: ikon panah bawah — "Ngoding" — "Salary • Bank Jago • Today..." — nominal terpotong "+Rp 5...".
- FAB (+) hijau kanan bawah, sedikit overlap dengan card transaksi terakhir.
- Bottom nav: "Dashboard" (aktif) / "Transactions" / "Accounts" / "Other Menu".

## 2. Transactions (list utama)
- Header: "Transactions" / "All financial activity".
- Search bar "Search transactions or note..." dengan ikon filter di kanan search bar.
- 2 tombol sejajar (bukan chip kecil seperti mockup): "Analytics" (ikon lingkaran) dan "Financial Calendar" (ikon kalender) — keduanya outline, tidak ada yang fill/aktif di state default ini.
- **Tidak ada strip kalender tanggal horizontal** di layar ini (beda dari mockup Layar 2 yang punya strip tanggal 15-21).
- Section "Today" dengan "+Rp 0" di kanan (kosong). 2 item di bawahnya:
  1. Ikon panah bawah (lingkaran hijau muda) — "Ngoding" — "Salary • Today • 20:31" — "+Rp 50,000" (hijau).
  2. Ikon panah atas (lingkaran merah muda) — "Bensin" — "Transport • Today • 20:29" — "−Rp 50,000" (merah).
- Section "Tuesday" dengan "+Rp 125,000" di kanan. 2 item:
  1. Ikon panah atas (lingkaran merah muda) — "Makan" — "Transport • 11 Aug 26 • 20:30" — "−Rp 25,000" (**kategori "Transport" untuk item "Makan" — kemungkinan salah kategori/data dummy, dicatat sebagai temuan, bukan asumsi bug UI**).
  2. Ikon panah bawah (lingkaran hijau muda) — "Ngoding" — "Salary • 11 Aug 26 • 20:29" — "+Rp 150,000".
- FAB (+) kanan bawah.
- Bottom nav: "Transactions" aktif.

## 3. Add Transaction
- Header: "Add Transaction" / "Record quickly", tombol "Close" kanan atas.
- Tab switcher 3 opsi: **"Expense" (fill MERAH, aktif)**, "Income" (outline/tidak aktif), "Transfer" (outline/tidak aktif). — **Warna tab aktif di sini MERAH, bukan hijau seperti di mockup.**
- Label "Transaction amount" (center), input "Rp 0" besar.
- Field list bergaya sama seperti mockup (label kapital kecil di atas, value + chevron kanan):
  1. "CATEGORY" — ikon — "Select category" (placeholder, belum dipilih).
  2. "FROM ACCOUNT" — ikon — "Select account" (placeholder).
  3. "DATE" — ikon kalender — "23 September 2026 • 20:32".
  4. "NOTE" — ikon — "Add transaction note" (placeholder).
- Tombol full-width hijau "Save Transaction".
- Teks kecil abu-abu di bawah tombol: "You can still edit after saving".

## 4. Budgets & Goals — tab "Budgets"
- Header: tombol back (←) — "Budgets & Goals" — tombol "+ Create" kanan atas.
- Tab switcher 2 opsi di bawah header: "Budgets" (aktif/underline) / "Savings Goals" (tidak aktif).
- Card hijau: "Total Budget Remaining" → "Rp 1,950,000", subtitle "Rp 50K of Rp 2M", progress bar (terisi sangat sedikit, warna oranye kecil di ujung kiri track putih).
- Section "Per Category" dengan "1 budgets" di kanan. 1 card: ikon (lingkaran hijau, simbol grid/kategori) — "Transport" — "3%" (kanan atas) — "Rp 50K of Rp 2M" — progress bar hijau (sangat sedikit terisi).
- Di bawah card, 1 baris terpisah (bukan bagian card): ikon dompet — "Kantong Kantong Transportasi • Rp 0" — link "Setor" (kanan). — **"Kantong" terulang 2x dalam teks ini ("Kantong Kantong Transportasi") — kemungkinan bug teks/string duplikat, dicatat sebagai temuan.**
- Box oranye pucat dengan ikon segitiga peringatan: "Needs Attention" (isi detail tidak terlihat/tidak ada di bawahnya pada screenshot ini).
- **Tidak ada bottom nav terlihat di layar ini** (kemungkinan halaman ini full-screen tanpa bottom nav, diakses via push navigation dari "Other Menu").

## 5. Budgets & Goals — tab "Savings Goals"
- Header sama: back (←) — "Budgets & Goals" — **"+ Add"** (label tombol beda dari tab Budgets yang "+ Create").
- Tab switcher: "Budgets" / "Savings Goals" (aktif).
- 1 card: ikon bintang (lingkaran ungu muda) kiri atas — badge "PRIORITY" (Inggris, beda dari mockup "PRIORITAS") kanan atas — "Liburan" (nama goal, terpotong dibanding mockup "Liburan ke Jepang") — angka "Rp 1,666" — progress bar (kosong, tidak ada isian terlihat) — subtitle "0% of Rp 50M" — tombol "Setor" (Indonesia, outline hijau) di bawahnya.
- 2 card kecil sejajar:
  1. Ikon celengan (lingkaran ungu muda) — "Dana Darurat" — "Rp 1.67K" — "0% achieved" — tanpa progress bar.
  2. Ikon celengan (lingkaran ungu muda) — "Party" — "Rp 1.67K" — "0% achieved" — tanpa progress bar.
- Tidak ada bottom nav terlihat di layar ini.

## 6. Recurring Transactions
- Header hijau: tombol back (←) — "Recurring Tran..." (terpotong, kemungkinan "Recurring Transactions").
- Konten: ikon panah bolak-balik (lingkaran abu muda, besar, di tengah layar) — teks "No data yet" di bawahnya.
- **Tidak ada tombol tambah/FAB/(+) dalam bentuk apapun yang terlihat di layar ini.**
- Tidak ada bottom nav terlihat (full-screen push navigation).

## 7. Transactions — mode "Analytics"
- Header: "Transactions" / "All financial activity". Search bar sama.
- 2 tombol: **"Analytics" (fill hijau, aktif sekarang)** / "Financial Calendar" (outline).
- 2 card sejajar: "Expense" (background pink pucat) "Rp 75,000"; "Income" (background hijau pucat) "Rp 200,000".
- "Expense per category" — donut chart (hijau + biru) — legend: "Transport 67%" (hijau), "Other 33%" (biru).
- List di bawah donut: "Transport" — "Rp 50,000" — progress bar hijau "67%"; "Other" — "Rp 25,000" — progress bar (persentase terpotong di bawah batas gambar).
- FAB (+) kanan bawah.
- Bottom nav: "Transactions" aktif.
- **Ini bukan halaman terpisah "Statistik" seperti di mockup — ini adalah state/tab di dalam halaman "Transactions" yang sama** (header & search bar tetap sama persis dengan layar 2).

## 8. Transactions — mode "Financial Calendar"
- Header: "Transactions" / "All financial activity". Search bar sama.
- 2 tombol: "Analytics" (outline) / **"Financial Calendar" (fill hijau, aktif sekarang)**.
- Navigator bulan: "‹ September 2026 ›" dengan panah kiri-kanan.
- Grid kalender (kolom S S R K J S M — urutan hari beda dari mockup yang S R K J S M S), tanggal 1-30. Beberapa tanggal punya titik kecil hijau di bawah angka (2, 7, dan beberapa lainnya terlihat kabur). Tanggal "23" ditandai dengan **kotak outline hijau** (bukan lingkaran fill solid seperti di mockup).
- **Tidak ada card ringkasan hari terpilih atau list "Detail transaksi" yang terlihat di bawah kalender** pada screenshot ini (mungkin di bawah fold/scroll, tidak kelihatan).
- FAB (+) kanan bawah.
- Bottom nav: "Transactions" aktif.
- **Ini juga bukan halaman terpisah "Kalender Keuangan" — sama seperti Analytics, ini state di dalam halaman "Transactions" yang sama.**

## 9. Accounts & Wallets
- Header: "Accounts & Wallets" / "5 active accounts".
- Card hijau: "Total Net Balance" → "Rp 18,125,000", subtitle "Updated 2 min ago".
- 2 tombol sejajar: "+ Add Account" (outline) / "Transfer" (outline, dengan ikon panah bolak-balik).
- Section "Account List" dengan link "Manage" di kanan. List 4 item terlihat (subtitle header bilang "5 active accounts" tapi cuma 4 yang tampak — kemungkinan 1 lagi di bawah fold):
  1. Ikon dompet (lingkaran hijau muda) — "Kantong Transportasi" — "Savings • 0 transactions" — "Rp 0".
  2. Ikon dompet (lingkaran hijau muda) — "Kantong Liburan" — "Savings • 0 transactions" — "Rp 1,666".
  3. Ikon dompet (lingkaran hijau muda) — "Kantong Dana Darurat" — "Savings • 0 transactions" — "Rp 1,666".
  4. Ikon dompet (lingkaran hijau muda) — "Kantong Party" — "Savings • 0 transactions" — nominal terpotong oleh FAB.
- FAB (+) kanan bawah, menutupi sebagian nominal item ke-4.
- Bottom nav: "Accounts" aktif.
- **Semua akun yang terlihat bertipe "Kantong" (savings pocket/amplop), bukan akun bank/e-wallet riil** (beda dari mockup yang menampilkan "BCA Utama", "Jago Tabungan", "GoPay", "BCA Platinum", "Reksa Dana"). Kemungkinan akun utama (misal "Bank Jago" yang disebut di transaksi "Ngoding" pada layar Dashboard) ada tapi tidak masuk dalam 4 item yang terlihat di screenshot ini.

## 10. Other
- Header: "Other" / "App settings & data".
- Card profil: avatar hijau "ME" — "Mas Elon" — "maselon@email.com" — chevron kanan (bisa jadi tappable ke halaman profil).
- Section "Appearance": 1 baris — ikon — "Theme" — subtitle **"Light • English"** (menggabungkan info tema DAN bahasa dalam 1 baris) — chevron.
- Section "Other Features", 4 baris:
  1. Ikon — "Categories" — subtitle "26 categories" — chevron.
  2. Ikon — "Recurring" — subtitle "0 active transactions" — chevron.
  3. Ikon — "Budgets & Goals" — subtitle "1 budgets • 3 goals" — chevron.
  4. Ikon — "Currency" — subtitle "Base currency: IDR" — chevron.
- **Tidak ada section "Data & keamanan" (Backup, Security, Notifications) atau "Bantuan & informasi" (About) yang terlihat** pada screenshot ini — kemungkinan di bawah fold/scroll, atau memang belum ada.
- Bottom nav: "Other Menu" aktif.