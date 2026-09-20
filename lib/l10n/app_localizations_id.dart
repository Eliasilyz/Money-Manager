// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get goodMorning => 'Selamat pagi';

  @override
  String get goodAfternoon => 'Selamat siang';

  @override
  String get goodEvening => 'Selamat sore';

  @override
  String get goodNight => 'Selamat malam';

  @override
  String get totalBalance => 'Total Saldo';

  @override
  String get incomeMonth => 'Pemasukan';

  @override
  String get expensesMonth => 'Pengeluaran';

  @override
  String get today => 'Hari ini';

  @override
  String get thisMonth => 'Bulan ini';

  @override
  String get total => 'Total';

  @override
  String get dashboard => 'Beranda';

  @override
  String get transactions => 'Transaksi';

  @override
  String get accounts => 'Akun';

  @override
  String get settings => 'Lainnya';

  @override
  String get noTransactions => 'Belum ada transaksi';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get transactionTitle => 'Transaksi';

  @override
  String get transactionSubtitle => 'Semua aktivitas keuangan';

  @override
  String get noTransactionsFound => 'Tidak ada transaksi ditemukan';

  @override
  String get categories => 'Kategori';

  @override
  String get accountsTitle => 'Akun & Dompet';

  @override
  String accountsSubtitle(Object count) {
    return '$count akun aktif';
  }

  @override
  String get addAccount => '+ Akun';

  @override
  String get noAccounts => 'Belum ada akun';

  @override
  String get firstTransaction => 'Tap + untuk transaksi pertama';

  @override
  String get budgets => 'Anggaran';

  @override
  String get goalsAndDebts => 'Target & Hutang';

  @override
  String get recurring => 'Transaksi Berulang';

  @override
  String get statistics => 'Statistik';

  @override
  String get calendar => 'Kalender Keuangan';

  @override
  String get notes => 'Catatan';

  @override
  String get searchTransactions => 'Cari transaksi atau catatan...';

  @override
  String get allFilter => 'Semua';

  @override
  String get categoryFilter => 'Kategori';

  @override
  String get accountFilter => 'Akun';

  @override
  String get periodFilter => 'Periode';

  @override
  String get todayTitle => 'Hari ini';

  @override
  String get yesterdayTitle => 'Kemarin';

  @override
  String get addTransaction => 'Tambah transaksi';

  @override
  String get addTransactionSubtitle => 'Catat dengan cepat';

  @override
  String get close => 'Tutup';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get income => 'Pemasukan';

  @override
  String get transfer => 'Transfer';

  @override
  String get amount => 'Jumlah';

  @override
  String get category => 'Kategori';

  @override
  String get fromAccount => 'Dari akun';

  @override
  String get toAccount => 'Ke akun';

  @override
  String get date => 'Tanggal';

  @override
  String get note => 'Catatan';

  @override
  String get saveTransaction => 'Simpan transaksi';

  @override
  String get selectCategory => 'Pilih kategori';

  @override
  String get selectAccount => 'Pilih akun';

  @override
  String get transferInfo => 'Alur transfer antar akun';

  @override
  String get from => 'Dari';

  @override
  String get to => 'Ke';

  @override
  String get currentBalance => 'Saldo saat ini';

  @override
  String get requiredField => 'Wajib diisi';

  @override
  String get amountMustBePositive => 'Jumlah harus lebih dari 0';

  @override
  String get accountsMustDiffer => 'Akun asal dan tujuan harus berbeda';

  @override
  String get budgetsTitle => 'Anggaran';

  @override
  String budgetsSubtitle(Object monthYear) {
    return '$monthYear';
  }

  @override
  String get addBudget => '+ Buat';

  @override
  String get totalBudgetRemaining => 'Total anggaran tersisa';

  @override
  String spent(Object spent, Object total) {
    return '$spent dari $total';
  }

  @override
  String get perCategory => 'Per kategori';

  @override
  String budgetCount(Object count) {
    return '$count anggaran';
  }

  @override
  String get attention => 'Perlu perhatian';

  @override
  String get overLimit => 'Melebihi';

  @override
  String get noBudgets => 'Belum ada anggaran';

  @override
  String get targetAndDebtsTitle => 'Target & Hutang';

  @override
  String get financialPlan => 'Rencana finansial';

  @override
  String get addTarget => '+ Tambah';

  @override
  String get savingsTarget => 'Target tabungan';

  @override
  String get debts => 'Hutang';

  @override
  String get priority => 'PRIORITAS';

  @override
  String ofTarget(Object current, Object target) {
    return '$current dari $target';
  }

  @override
  String progress(Object percent) {
    return '$percent% tercapai';
  }

  @override
  String targetDeadline(Object date) {
    return 'TARGET $date';
  }

  @override
  String get debtSummary => 'Ringkasan hutang';

  @override
  String get totalDebtRemaining => 'Total sisa hutang';

  @override
  String installment(Object paid, Object total) {
    return '$paid dari $total';
  }

  @override
  String dueDate(Object date) {
    return 'Jatuh tempo $date';
  }

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Nonaktif';

  @override
  String get recurringTitle => 'Transaksi Berulang';

  @override
  String get recurringSubtitle => 'Otomatis dan terjadwal';

  @override
  String get nextMonthProjection => 'Proyeksi bulan depan';

  @override
  String expenseCount(Object count) {
    return '$count pengeluaran';
  }

  @override
  String incomeCount(Object count) {
    return '$count pemasukan';
  }

  @override
  String get comingSoon => 'Akan datang';

  @override
  String daysLeft(Object count) {
    return '$count hari lagi';
  }

  @override
  String everyDate(Object day) {
    return 'Setiap tanggal $day';
  }

  @override
  String get subscriptions => 'Langganan';

  @override
  String get statisticsTitle => 'Statistik';

  @override
  String get statisticsSubtitle => 'Insight keuanganmu';

  @override
  String get cashFlow => 'Arus kas';

  @override
  String get totalLabel => 'Total';

  @override
  String changeVsLastMonth(Object lastMonth, Object percent) {
    return '$percent% dibanding $lastMonth';
  }

  @override
  String get decrease => '↓';

  @override
  String get increase => '↑';

  @override
  String get dailyAverage => 'Rata-rata harian';

  @override
  String get highestDay => 'Hari tertinggi';

  @override
  String get categoryBreakdown => 'Breakdown kategori';

  @override
  String get viewDetail => 'Lihat detail';

  @override
  String get noData => 'Belum ada data';

  @override
  String get calendarTitle => 'Kalender Keuangan';

  @override
  String calendarSubtitle(Object monthYear) {
    return '$monthYear';
  }

  @override
  String get todayButton => 'Hari ini';

  @override
  String transactionCount(Object count) {
    return '$count transaksi';
  }

  @override
  String get entries => 'Masuk';

  @override
  String get exits => 'Keluar';

  @override
  String get othersTitle => 'Lainnya';

  @override
  String get othersSubtitle => 'Pengaturan & fitur';

  @override
  String get profileName => 'Money Manager';

  @override
  String get profileSubtitle => 'Personal Finance Tracker';

  @override
  String get financialManagement => 'Kelola keuangan';

  @override
  String categoriesCount(Object count) {
    return '$count kategori';
  }

  @override
  String notesSaved(Object count) {
    return '$count catatan tersimpan';
  }

  @override
  String activeRecurring(Object count) {
    return '$count transaksi aktif';
  }

  @override
  String budgetsGoalsCount(Object budgets, Object goals) {
    return '$budgets anggaran • $goals target';
  }

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get preferences => 'Preferensi';

  @override
  String get currency => 'Mata uang';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get notificationsActive => 'Pengingat aktif';

  @override
  String get notificationsInactive => 'Pengingat nonaktif';

  @override
  String get view => 'Tampilan';

  @override
  String get lightTheme => 'Tema terang';

  @override
  String get securityPriv => 'Keamanan & privasi';

  @override
  String get pinActive => 'PIN dan biometrik aktif';

  @override
  String get pinInactive => 'PIN dan biometrik tidak aktif';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get followSystem => 'Ikuti sistem';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';

  @override
  String get signInOut => 'Masuk dengan Google';

  @override
  String get signOut => 'Keluar';

  @override
  String get notSignedIn => 'Belum masuk';

  @override
  String get backupNow => 'Backup sekarang';

  @override
  String lastBackup(Object date) {
    return 'Backup terakhir: $date';
  }

  @override
  String get manageBackups => 'Kelola Cadangan';

  @override
  String get deleteBackup => 'Hapus Cadangan';

  @override
  String get exportLocal => 'Ekspor ke file';

  @override
  String get importLocal => 'Impor dari file';

  @override
  String get autoBackup => 'Backup otomatis';

  @override
  String get wifiOnly => 'Hanya Wi-Fi';

  @override
  String get encryptBackup => 'Enkripsi dengan kata sandi';

  @override
  String get passwordRequired => 'Kata sandi wajib diisi';

  @override
  String get lostPasswordWarning =>
      'Kata sandi hilang = backup tidak bisa dipulihkan';

  @override
  String get restore => 'Pulihkan';

  @override
  String get restoreConfirm => 'Pulihkan data dari backup ini?';

  @override
  String get restoreWarning => 'Data saat ini akan diganti.';

  @override
  String get version => 'Versi';

  @override
  String get build => 'Build';

  @override
  String get openSourceLicenses => 'Lisensi Open Source';

  @override
  String get copyInfo => 'Tekan lama untuk menyalin';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfService => 'Syarat & Ketentuan';

  @override
  String get contact => 'Hubungi Kami';

  @override
  String get rateApp => 'Nilai Aplikasi';

  @override
  String get shareApp => 'Bagikan';

  @override
  String get madeWith => 'Dibuat dengan';

  @override
  String allRightsReserved(Object year) {
    return 'Hak cipta dilindungi. $year';
  }

  @override
  String get debugInfo => 'Info Debug';

  @override
  String get enterPin => 'Masukkan PIN';

  @override
  String get changePin => 'Ubah PIN';

  @override
  String get enableBiometrics => 'Aktifkan biometrik';

  @override
  String get biometricsActive => 'Biometrik aktif';

  @override
  String get biometricsInactive => 'Biometrik tidak aktif';

  @override
  String get pinMismatch => 'PIN tidak cocok';

  @override
  String pinLength(Object length) {
    return 'PIN harus $length angka';
  }

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Buat';

  @override
  String get update => 'Perbarui';

  @override
  String get add => 'Tambah';

  @override
  String get name => 'Nama';

  @override
  String get balance => 'Saldo';

  @override
  String get description => 'Deskripsi';

  @override
  String get optional => 'Opsional';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Coba lagi';

  @override
  String get noConnection => 'Tidak ada koneksi';

  @override
  String get somethingWentWrong => 'Terjadi kesalahan';

  @override
  String get transactionType => 'Jenis transaksi';

  @override
  String get search => 'Cari';

  @override
  String get resetFilters => 'Reset filter';

  @override
  String get filterCalendar => 'Kalender';

  @override
  String monthYear(Object month, Object year) {
    return '$month $year';
  }
}
