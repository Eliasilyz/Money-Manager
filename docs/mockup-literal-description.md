# Deskripsi Literal Mockup "Money Manager" (10 Layar)

**Cara pakai dokumen ini:** ini murni deskripsi apa yang TERLIHAT di gambar mockup, tanpa opini, tanpa teori penyebab masalah, tanpa saran perbaikan. Kalau ada bagian yang terpotong/tidak jelas di gambar, ditandai eksplisit "tidak terlihat" — bukan ditebak.

**Konteks penting:** mockup ini kemungkinan menggambarkan desain yang berbeda dari implementasi app saat ini di **banyak/semua halaman**, bukan cuma 1-2 fitur. Jangan asumsikan halaman mana yang sudah sesuai dan mana yang belum — **agent harus buka kode tiap layar yang berkaitan dan bandingkan sendiri baris per baris** dengan deskripsi di bawah, lalu laporkan gap yang ditemukan (fitur ada di mockup tapi tidak ada di kode, atau sebaliknya) sebelum mengubah apapun. Jangan berimprovisasi menambah/mengurangi fitur berdasarkan asumsi.

Urutan layar sesuai posisi di gambar: baris atas 5 layar (kiri ke kanan), baris bawah 5 layar (kiri ke kanan).

---

## Layar 1 (baris atas, ke-1) — "Beranda"

- Header: teks "Selamat pagi, Elon" (kiri), teks "Sabtu, 19 September" di bawahnya, badge "Sep 2026" (kanan, sejajar baris pertama).
- Card hijau: judul kecil "Total saldo", angka besar "Rp 18.750.000". Di bawahnya 2 kolom: kolom kiri ikon panah atas + "Pemasukan bulan ini" + "Rp 12,5 jt"; kolom kanan ikon panah bawah + "Pengeluaran bulan ini" + "Rp 7,8 jt".
- 3 kotak kecil sejajar horizontal di bawah card hijau: "Hari ini" / "Rp 248 rb"; "Bulan ini" / "Rp 7,8 jt"; "Total" / "Rp 52,4 jt".
- Section "Arus kas" dengan teks "6 bulan" di kanan judul. Di bawahnya bar chart vertikal, batang berwarna hijau dan oranye berselang-seling (urutan warna per batang tidak terbaca jelas jumlahnya, tapi ada campuran hijau & oranye).
- Section "Transaksi terbaru" dengan link "Lihat semua" di kanan judul. List 3 item:
  1. Ikon keranjang belanja (lingkaran biru muda) — "Supermarket Fresh" — subtitle "Belanja • Hari ini, 18:20" — nominal kanan "−Rp 276.500" (merah).
  2. Ikon mangkuk (lingkaran oranye muda) — "Bakso" — subtitle "Belanja • Hari ini, 18:00" — nominal "−Rp 10.000" (merah).
  3. Ikon (lingkaran hijau muda) — "Gaji bulanan" — subtitle "Pendapatan • 17 Sep" — nominal "+Rp 12.500.000" (hijau).
- Tombol bulat hijau (+) di pojok kanan bawah, di atas bottom nav.
- Bottom nav 4 item: Beranda (ikon rumah, background hijau rounded karena aktif) / Transaksi / Akun / Lainnya.

---

## Layar 2 (baris atas, ke-2) — "Transaksi"

- Header: "Transaksi" (judul), "Semua aktivitas keuangan" (subtitle), ikon titik-tiga vertikal di kanan atas.
- Search bar dengan placeholder "Cari transaksi atau catatan...".
- Baris chip: "Semua" (fill hijau, terlihat aktif) / "Filter" / "Analitik" / "Kalender" (3 chip terakhir outline/abu).
- Strip kalender horizontal: judul "September 2026" (kiri) dan "Kalender" (kanan, kemungkinan link). Di bawahnya 7 kolom tanggal (S R K J S M S) dengan angka 15,16,17,18,19,20,21 — tanggal "19" di-highlight lingkaran hijau solid dengan teks putih, tanggal lain teks abu/hitam biasa.
- Section "Hari ini" dengan nominal total di kanan "−Rp 534.500". List 3 item di bawahnya:
  1. Ikon keranjang (lingkaran biru muda) — "Supermarket Fresh" — subtitle "Belanja • Hari ini, 18:20" — "−Rp 286.500".
  2. Ikon cangkir (lingkaran oranye muda) — "Kopi bersama tim" — subtitle "Makan • GoPay, 15:42" — "−Rp 68.000".
  3. Ikon pompa bensin (lingkaran merah muda) — "Isi bensin" — subtitle "Transportasi • BCA, 08:10" — "−Rp 180.000".
- Section "Kemarin" dengan nominal total "+Rp 1.750.000" di kanan. 1 item: ikon (lingkaran biru muda) — "Proyek desain" — subtitle "Pemasukan • Catatan: DP tahap 2" — "+Rp 1.750.000".
- Section "Akses cepat", 2 baris:
  1. Ikon kategori — "Kategori" (bold) — subtitle "Kelola kategori transaksi" — tombol "Buka" (kanan).
  2. Ikon catatan — "Catatan" (bold) — subtitle "Tambah catatan transaksi" — tombol "Buka" (kanan).
- Tombol bulat hijau (+) pojok kanan bawah.
- Bottom nav: Transaksi aktif (background hijau rounded pada ikon).

---

## Layar 3 (baris atas, ke-3) — "Tambah Transaksi"

- Header: "Tambah transaksi" (judul), "Catat dengan cepat" (subtitle), tombol "Tutup" kanan atas.
- Tab switcher 3 opsi sejajar: "Pengeluaran" (fill hijau solid, teks putih — terlihat aktif), "Pemasukan" (teks abu/hitam, tanpa fill), "Transfer" (teks abu/hitam, tanpa fill). Ketiga tab berada dalam 1 container dengan background yang sedikit lebih terang/beda dari background halaman.
- Card hijau: label kecil "Jumlah transaksi", angka besar putih "Rp 350.000".
- Field list (masing-masing: label kecil huruf kapital di atas, lalu value + ikon chevron ke bawah di kanan, dipisahkan garis horizontal tipis antar field):
  1. "KATEGORI" — ikon (lingkaran krem/oranye muda) + "Makan & Minum".
  2. "DARI AKUN" — ikon bendera/kartu + "BCA Utama • Rp 9.850.000".
  3. "TANGGAL" — "19 September 2026 • 18:45".
  4. "CATATAN" — text field berisi "Makan malam bersama keluarga".
- Tombol full-width hijau solid "Simpan transaksi" di bagian bawah konten (di atas bottom nav).
- Bottom nav: Transaksi aktif.

---

## Layar 4 (baris atas, ke-4) — "Anggaran"

- Header: "Anggaran" (judul), "September 2026" (subtitle), tombol "+ Buat" kanan atas.
- Card hijau: label "Total anggaran tersisa", angka besar putih "Rp 3.420.000", subtitle "Terpakai Rp 4,58 jt dari Rp 8 jt", progress bar horizontal di bawahnya (warna terisi terang di atas track hijau tua/gelap).
- Section "Per kategori" dengan "5 anggaran" di kanan judul. List 5 card:
  1. Ikon (lingkaran oranye muda, simbol makanan) — "Makan & Minum" (bold) — persentase "73%" kanan atas card — subtitle "Rp 1,82 jt dari Rp 2,5 jt" — progress bar hijau di baris bawah card.
  2. Ikon (lingkaran merah muda, simbol mobil) — "Transportasi" — "80%" — "Rp 960 rb dari Rp 1,2 jt" — progress bar **merah**.
  3. Ikon (lingkaran biru muda, simbol tas belanja) — "Belanja" — "49%" — "Rp 740 rb dari Rp 1,5 jt" — progress bar hijau.
  4. Ikon (lingkaran hijau muda, simbol rumah) — "Rumah" — "45%" — "Rp 680 rb dari Rp 1,5 jt" — progress bar hijau.
  5. Ikon (lingkaran pink muda, simbol hati) — "Hiburan" — "29%" — "Rp 380 rb dari Rp 1,3 jt" — progress bar hijau.
- Di bawah list, ada teks "Perlu perhatian" yang terpotong oleh batas gambar — **isi lengkap section ini tidak terlihat**.
- Bottom nav: Lainnya aktif (bukan Anggaran — halaman ini kemungkinan diakses dari menu Lainnya, bukan tab bottom nav sendiri).

---

## Layar 5 (baris atas, ke-5) — "Target & Hutang"

- Header: "Target & Hutang" (judul), "Rencana finansial" (subtitle), tombol "+ Tambah" kanan atas.
- Tab switcher 2 opsi: "Target tabungan" (fill hijau, aktif) / "Hutang" (tidak aktif).
- 1 card: ikon bintang (lingkaran ungu muda, kiri atas) — badge "PRIORITAS" (kanan atas) — "Liburan ke Jepang" — angka besar "Rp 18.500.000" — progress bar ungu — baris bawah: "74% dari Rp 25 jt" (kiri) dan "Des 2026" (kanan).
- 2 card kecil sejajar (2 kolom):
  1. Ikon shield (lingkaran hijau muda) — "Dana darurat" (bold) — "Rp 22 jt" — "55% tercapai" (tanpa progress bar visual di card ini).
  2. Ikon laptop (lingkaran abu muda) — "Laptop baru" (bold) — "Rp 7,2 jt" — "80% tercapai" (tanpa progress bar visual).
- Section "Ringkasan hutang" dengan link "Lihat semua". 1 card: ikon (lingkaran merah muda) — "Cicilan motor" — subtitle "7 dari 24 bulan • Jatuh tempo 25 Sep" — nominal kanan "Rp 1,25 jt" — progress bar merah di bawah.
- Card pink pucat: label kecil "Total sisa hutang", angka merah besar "Rp 22.750.000".
- **Konten di bawah card ini terpotong batas gambar** — tidak terlihat apakah ada goal/card lain di bawahnya.
- Tidak ada tombol bulat (+) terpisah di layar ini (cuma tombol "+ Tambah" di header).
- Bottom nav: Lainnya aktif.

---

## Layar 6 (baris bawah, ke-1) — "Transaksi Berulang"

- Header: "Transaksi Berulang" (judul), "Otomatis dan terjadwal" (subtitle), tombol "+ Tambah" kanan atas.
- Card hijau: label "Proyeksi bulan depan", angka besar putih "−Rp 5.985.000", 2 kolom di bawahnya: "8 pengeluaran" (kiri) dan "2 pemasukan" (kanan).
- Section "Akan datang" dengan "30 hari" di kanan judul. List 4 item:
  1. Ikon rumah (lingkaran merah muda) — "Sewa apartemen" — subtitle kiri bawah "Setiap tanggal 1 • 12 hari lagi" — nominal kanan atas "−Rp 2.750.000" — badge "Aktif" kanan bawah.
  2. Ikon wifi (lingkaran biru muda) — "Internet rumah" — "Setiap tanggal 5 • 16 hari lagi" — "−Rp 425.000" — badge "Aktif".
  3. Ikon handphone (lingkaran merah muda) — "Paket seluler" — "Setiap tanggal 8 • 19 hari lagi" — "−Rp 160.000" — badge "Aktif".
  4. Ikon (lingkaran hijau muda) — "Gaji bulanan" — "Setiap tanggal 17 • bulan depan" — "+Rp 12.500.000" — badge "Aktif".
- Section "Langganan" dengan link "Kelola" di kanan. 2 card kecil sejajar:
  1. Logo huruf "N" (background hitam) — "Netflix" — "Rp 186 rb/bulan".
  2. Ikon musik — "Spotify" — "Rp 55 rb/bulan".
- Tidak ada tombol bulat (+) terpisah (cuma "+ Tambah" di header).
- Bottom nav: Lainnya aktif.

---

## Layar 7 (baris bawah, ke-2) — "Statistik"

- Header: "Statistik" (judul), "Insight keuanganmu" (subtitle), badge "Sep 2026" kanan atas.
- Tab switcher 3 opsi: "Pengeluaran" (fill hijau, aktif) / "Pemasukan" / "Arus kas".
- Label "Total pengeluaran", angka besar hitam "Rp 7.842.500", subtitle "↓ 8,4% dibanding Agustus" (teks hijau dengan ikon panah bawah).
- Bar chart harian di bawahnya — batang warna krem/beige, 1 batang berwarna oranye (kemungkinan menandai hari tertinggi).
- 2 kotak kecil sejajar: "Rata-rata harian" / "Rp 261 rb"; "Hari tertinggi" / "Rp 1,2 jt" (angka ini berwarna merah).
- Section "Breakdown kategori" dengan link "Lihat detail". Donut chart di kiri (warna oranye, ungu, hijau, abu) + legend list di kanan: "Makan & Minum 32%", "Transportasi 26%", "Belanja 24%", "Lainnya 18%".
- Box background biru muda: judul "Tren positif", teks "Pengeluaran makan turun 12% selama tiga minggu berturut-turut."
- Bottom nav: Lainnya aktif.

---

## Layar 8 (baris bawah, ke-3) — "Kalender Keuangan"

- Header: "Kalender Keuangan" (judul), "September 2026" (subtitle), tombol "Hari ini" kanan atas.
- Grid kalender penuh 1 bulan (kolom S R K J S M S), tanggal 1–29 terlihat. Beberapa tanggal (3,6,9,12,15,18,21,24,27) punya titik kecil merah di bawah angka. Tanggal "19" di-highlight lingkaran hijau solid dengan teks putih.
- Card hijau di bawah kalender: baris atas "Sabtu, 19 September" (kiri) dan "3 transaksi" (kanan); baris bawah "Masuk Rp 0" (kiri) dan "Keluar Rp 534.500" (kanan).
- Section "Detail transaksi". List 3 item:
  1. Ikon keranjang (lingkaran biru muda) — "Supermarket Fresh" — subtitle "18:20 • BCA Utama" — "−Rp 286.500".
  2. Ikon cangkir (lingkaran oranye muda) — "Kopi bersama tim" — subtitle "15:42 • GoPay" — "−Rp 68.000".
  3. Ikon pompa bensin (lingkaran merah muda) — "Isi bensin" — subtitle "08:10 • BCA Utama" — "−Rp 180.000".
- Tombol bulat hijau (+) pojok kanan bawah.
- Bottom nav: Transaksi aktif.

---

## Layar 9 (baris bawah, ke-4) — "Akun & Dompet"

- Header: "Akun & Dompet" (judul), "6 akun aktif • kelola saldo & detail" (subtitle), tombol "+ Akun" kanan atas.
- Card hijau: label "Total saldo bersih", angka besar putih "Rp 18.050.000", subtitle "Diperbarui 2 menit lalu".
- Section "Daftar akun" dengan link "Atur". List 5 item (subtitle "6 akun aktif" di header tapi yang tampil di list cuma 5 — kemungkinan item ke-6 di bawah batas layar/scroll, tidak terlihat):
  1. Ikon kartu (lingkaran biru muda) — "BCA Utama" — subtitle "Debit •••• 2841 • 2 transaksi hari ini" — "Rp 9.850.000".
  2. Ikon celengan (lingkaran hijau muda) — "Jago Tabungan" — subtitle "Tabungan •••• 9120 • bunga 4,5%" — "Rp 6.775.000".
  3. Ikon (lingkaran hijau muda) — "GoPay" — subtitle "Cash •••• 2841 • promo aktif" — "Rp 1.425.000".
  4. Ikon kartu (lingkaran ungu muda) — "BCA Platinum" — subtitle "Kredit •••• 1182 • tagihan 28 Sep" — "−Rp 1.200.000" (merah).
  5. Ikon grafik (lingkaran biru muda) — "Reksa Dana" — subtitle "Investment •••• 7712 • imbal hasil 7,2%" — "+Rp 1.100.000" (hijau).
- Section "Riwayat BCA Utama" dengan link "Lihat semua". List 2 item:
  1. Ikon keranjang (lingkaran merah muda) — "Supermarket Fresh" — subtitle "Hari ini • 18:20" — "−Rp 286.500".
  2. Ikon (lingkaran hijau muda) — "Gaji bulanan" — subtitle "17 Sep • 09:00" — "+Rp 12.500.000".
- Tombol bulat hijau (+) pojok kanan bawah.
- Bottom nav: Akun aktif.
- **Semua nominal di layar ini dalam format Rupiah** — tidak ada akun dengan mata uang lain (USD/SGD/dst) yang terlihat di gambar ini.

---

## Layar 10 (baris bawah, ke-5) — "Lainnya"

- Header: "Lainnya" (judul), "Pengaturan aplikasi & data" (subtitle).
- Card profil: avatar lingkaran hijau berisi inisial "ME" — "Mas Elon" (bold) — "masuelon@email.com" (abu-abu).
- Section "Tampilan": 1 baris — ikon — "Tema" (bold) — subtitle "Pilih tampilan aplikasi" — chevron kanan.
- Section "Fitur Lainnya", 4 baris:
  1. Ikon — "Kategori" (bold) — subtitle "Kelola kategori pengeluaran dan pemasukan" — chevron.
  2. Ikon — "Transaksi Berulang" (bold) — subtitle "0 Transaksi Aktif" — chevron.
  3. Ikon — "Anggaran & Target" (bold) — subtitle "0 Anggaran | 0 Target" — chevron.
  4. Ikon — "Mata Uang" (bold) — subtitle "Rupiah Indonesia" — chevron.
- Section "Data & keamanan", 3 baris:
  1. "Backup & Restore" — subtitle "Cadangkan & pulihkan data keuangan".
  2. "Keamanan & privasi" — subtitle "PIN, biometrik, dan akses akun".
  3. "Notifikasi" — subtitle "Pengingat, laporan, dan pemberitahuan".
- Section "Bantuan & informasi", 1 baris: "Tentang Aplikasi" — subtitle "Money Manager • Versi 2.4.0".
- Teks kecil paling bawah halaman: "Money Manager • Versi 2.4.0".
- Bottom nav: Lainnya aktif.

---

## Instruksi untuk Agent

1. Untuk **setiap** layar di atas, buka file `presentation` yang sesuai di project, dan bandingkan elemen per elemen dengan deskripsi di atas.
2. Untuk tiap layar, laporkan dalam bentuk tabel/list: elemen apa yang **sudah ada dan sesuai**, elemen apa yang **ada tapi beda** (styling/susunan/copy teks), dan elemen apa yang **ada di mockup tapi tidak ada di kode sama sekali**.
3. **Jangan langsung mengubah kode berdasarkan laporan ini.** Setelah laporan gap selesai untuk semua layar, tunggu konfirmasi/prioritas dari user (misalnya: mungkin user cuma mau fix sebagian layar dulu, bukan seluruhnya sekaligus) sebelum mulai eksekusi perubahan.
4. Kalau ada elemen di mockup yang ambigu fungsinya (misal section "Langganan" di layar Transaksi Berulang, atau badge "PRIORITAS" di goal) — cukup laporkan sebagai temuan, jangan diasumsikan sebagai fitur yang harus dibangun kecuali user konfirmasi.