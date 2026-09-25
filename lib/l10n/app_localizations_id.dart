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
  String get noBudgets => 'Belum ada budget';

  @override
  String get goalsAndDebtsTitle => 'Target & Hutang';

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
  String get recurringAdd => 'Tambah Transaksi Berulang';

  @override
  String get editRecurring => 'Edit Transaksi Berulang';

  @override
  String get frequency => 'Frekuensi';

  @override
  String get startDate => 'Mulai';

  @override
  String get endDate => 'Selesai';

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
  String get changeVsLastMonth => 'Selisih vs bulan lalu';

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
  String get notificationSettings => 'Pengaturan Notifikasi';

  @override
  String get notificationSettingsExplanation =>
      'Pengingat membantu kamu tidak melewatkan tagihan dan mengontrol anggaran';

  @override
  String get notificationPermissionAllowed => 'Diizinkan';

  @override
  String get notificationPermissionDenied => 'Ditolak';

  @override
  String get notificationOpenSystemSettings => 'Buka pengaturan sistem';

  @override
  String get notificationTypeRecurring => 'Tagihan & transaksi berulang';

  @override
  String get notificationTypeRecurringDesc =>
      'Pengingat H-0, H-1, H-3 sebelum jatuh tempo';

  @override
  String get notificationTypeDebt => 'Jatuh tempo hutang/cicilan';

  @override
  String get notificationTypeDebtDesc =>
      'Pengingat H-0, H-1, H-3 sebelum jatuh tempo';

  @override
  String get notificationTypeBudget => 'Peringatan anggaran';

  @override
  String get notificationTypeBudgetDesc =>
      'Notifikasi saat anggaran mencapai 80% dan 100%';

  @override
  String get notificationTypeDailyReminder =>
      'Pengingat catat transaksi harian';

  @override
  String get notificationTypeDailyReminderDesc =>
      'Pengingat harian, dilewati jika sudah ada transaksi';

  @override
  String get notificationTypeBackupStatus => 'Status backup';

  @override
  String get notificationTypeBackupStatusDesc =>
      'Notifikasi jika backup gagal beberapa kali berturut-turut';

  @override
  String get notificationTestButton => 'Kirim notifikasi tes';

  @override
  String get notificationTestSent => 'Notifikasi tes terkirim';

  @override
  String notificationActiveCount(Object count) {
    return '$count pengingat aktif';
  }

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
  String get deleteConfirm => 'Yakin ingin menghapus?';

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
  String get monthYear => 'Bulan & Tahun';

  @override
  String get financialSummary => 'Ringkasan Keuangan';

  @override
  String get thisWeek => 'Minggu Ini';

  @override
  String get debtTypeBorrowed => 'Hutang';

  @override
  String get debtTypeLent => 'Piutang';

  @override
  String get frequencyDaily => 'Harian';

  @override
  String get frequencyWeekly => 'Mingguan';

  @override
  String get frequencyMonthly => 'Bulanan';

  @override
  String get frequencyYearly => 'Tahunan';

  @override
  String get nextDate => 'Berikutnya';

  @override
  String get manage => 'Kelola';

  @override
  String get accountTypeCredit => 'Kartu Kredit';

  @override
  String get accountTypeCash => 'Tunai';

  @override
  String get other => 'Lainnya';

  @override
  String get accountList => 'Daftar Akun';

  @override
  String get netWorth => 'Kekayaan Bersih';

  @override
  String get totalNetBalance => 'Total Saldo Bersih';

  @override
  String lastUpdatedAgo(Object minutes) {
    return 'Diperbarui $minutes mnt lalu';
  }

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get firstNote => 'Buat catatan pertama';

  @override
  String get addAccountButton => '+ Tambah akun';

  @override
  String get transferBalance => 'Pindah saldo';

  @override
  String notesCount(Object count) {
    return '$count catatan tersimpan';
  }

  @override
  String get accountTypeWallet => 'Dompet';

  @override
  String get accountTypeSavings => 'Tabungan';

  @override
  String get accountTypeInvestment => 'Investasi';

  @override
  String get changelog => 'Yang Baru';

  @override
  String get donation => 'Dukung Pengembang';

  @override
  String developerCredits(Object name) {
    return 'Dikembangkan oleh $name';
  }

  @override
  String get noChangelog => 'Belum ada catatan perubahan.';

  @override
  String get copiedToClipboard => 'Disalin ke clipboard';

  @override
  String get editTransaction => 'Ubah transaksi';

  @override
  String get editTransactionSubtitle => 'Perbarui data transaksi';

  @override
  String get saveChanges => 'Simpan perubahan';

  @override
  String get confirmDelete => 'Hapus transaksi ini?';

  @override
  String get transactionUpdated => 'Transaksi berhasil diperbarui';

  @override
  String get transactionDeleted => 'Transaksi berhasil dihapus';

  @override
  String get transactionSaveError => 'Gagal menyimpan transaksi';

  @override
  String get analytics => 'Analitik';

  @override
  String get reset => 'Reset';

  @override
  String get expensePerCategory => 'Pengeluaran per kategori';

  @override
  String get netBalance => 'Saldo bersih';

  @override
  String get filterTransactions => 'Filter Transaksi';

  @override
  String get type => 'Tipe';

  @override
  String get thisWeekShort => 'Minggu ini';

  @override
  String get thisMonthShort => 'Bulan ini';

  @override
  String get applyFilter => 'Terapkan filter';

  @override
  String get transactionAmount => 'Jumlah transaksi';

  @override
  String get addNoteHint => 'Tambah catatan transaksi';

  @override
  String get editAfterSave => 'Anda masih bisa mengedit setelah menyimpan';

  @override
  String get addNewAccount => 'Tambah akun baru';

  @override
  String get selectAccountAndAmount =>
      'Pilih akun dan masukkan nominal yang valid';

  @override
  String get manageAccounts => 'Kelola Akun';

  @override
  String get activeAccounts => 'Akun Aktif';

  @override
  String get archivedAccounts => 'Diarsipkan';

  @override
  String get editAccount => 'Edit Akun';

  @override
  String get editBudget => 'Edit Anggaran';

  @override
  String get editGoal => 'Edit Target';

  @override
  String get adjustBalance => 'Sesuaikan Saldo';

  @override
  String get archiveAccount => 'Arsipkan';

  @override
  String get activateAccount => 'Aktifkan Kembali';

  @override
  String get deleteAccountTitle => 'Hapus Akun';

  @override
  String accountHasTransactions(Object count) {
    return 'Akun ini memiliki $count transaksi. Gunakan \"Arsipkan\" untuk menyembunyikan.';
  }

  @override
  String deleteAccountConfirm(Object name) {
    return 'Akun \"$name\" akan dihapus permanen.';
  }

  @override
  String get balanceTarget => 'Saldo target';

  @override
  String get adjustmentNote => 'Akan membuat transaksi penyesuaian.';

  @override
  String get apply => 'Terapkan';

  @override
  String get balanceAdjusted => 'Saldo disesuaikan';

  @override
  String get balanceAdjustmentDesc => 'Penyesuaian saldo';

  @override
  String get addAccountTitle => 'Tambah Akun';

  @override
  String get accountNameLabel => 'NAMA AKUN';

  @override
  String get accountNameHint => 'Contoh: BCA Utama';

  @override
  String get accountTypeLabel => 'TIPE AKUN';

  @override
  String get currencyLabel => 'MATA UANG';

  @override
  String get initialBalanceLabel => 'SALDO AWAL';

  @override
  String get noteLabel => 'CATATAN';

  @override
  String get saveAccount => 'Simpan Akun';

  @override
  String get accountNameRequired => 'Masukkan nama akun';

  @override
  String get addTransferTitle => 'Tambah Transfer';

  @override
  String get createNewAccount => 'Buat Akun Baru';

  @override
  String get selectFromAccount => 'Pilih Akun Asal';

  @override
  String get selectToAccount => 'Pilih Akun Tujuan';

  @override
  String get nominalLabel => 'NOMINAL';

  @override
  String get exchangeRateLabel => 'KURS';

  @override
  String get descriptionLabel => 'KETERANGAN';

  @override
  String get saveTransfer => 'Simpan Transfer';

  @override
  String get fillAmountAndSelectAccounts => 'Isi nominal dan pilih kedua akun';

  @override
  String get accountsMustBeDifferent => 'Akun asal dan tujuan tidak boleh sama';

  @override
  String get appSettingsSubtitle => 'Pengaturan aplikasi & data';

  @override
  String get theme => 'Tema';

  @override
  String get otherFeatures => 'Fitur Lainnya';

  @override
  String get budgetsAndGoals => 'Anggaran & Target';

  @override
  String get defaultCurrencyName => 'Rupiah Indonesia (IDR)';

  @override
  String get baseCurrency => 'Mata uang dasar';

  @override
  String get refreshRates => 'Segarkan kurs';

  @override
  String get dataAndSecurity => 'Data & keamanan';

  @override
  String get securitySubtitle => 'PIN, biometrik, dan akses akun';

  @override
  String get helpAndInfo => 'Bantuan & informasi';

  @override
  String get themeUppercase => 'TEMA';

  @override
  String get languageUppercase => 'BAHASA';

  @override
  String get backupAvailablePlatform => 'Backup tersedia di Android/iOS';

  @override
  String get backupRetention => 'Retensi backup';

  @override
  String get maxBackups => 'Maks backup';

  @override
  String get maxBackupsDesc => 'Backup otomatis tertua dihapus lebih dulu';

  @override
  String get noBackupYet => 'Belum ada backup';

  @override
  String get noChangesSkipBackup => 'Tidak ada perubahan, skip backup.';

  @override
  String get backupSuccessNoUpload =>
      'Backup berhasil (belum terupload — TODO Drive)';

  @override
  String get restoreWillReplace =>
      'Restore akan mengganti data saat ini. Sebuah snapshot cadangan akan dibuat untuk jaga-jaga.';

  @override
  String get restoreSuccessDrive =>
      'Restore berhasil (TODO: implement Drive download)';

  @override
  String get interval => 'Interval';

  @override
  String get backupSuccessful => 'Berhasil';

  @override
  String get categoryDefaultFoodDrink => 'Makan & Minum';

  @override
  String get categoryDefaultTransport => 'Transportasi';

  @override
  String get categoryDefaultShopping => 'Belanja';

  @override
  String get categoryDefaultHousing => 'Rumah & Sewa';

  @override
  String get categoryDefaultUtilities => 'Tagihan & Utilitas';

  @override
  String get categoryDefaultHealth => 'Kesehatan';

  @override
  String get categoryDefaultEducation => 'Pendidikan';

  @override
  String get categoryDefaultEntertainment => 'Hiburan';

  @override
  String get categoryDefaultVacation => 'Liburan';

  @override
  String get categoryDefaultFamily => 'Keluarga & Anak';

  @override
  String get categoryDefaultPersonalCare => 'Perawatan Diri';

  @override
  String get categoryDefaultGifts => 'Hadiah & Donasi';

  @override
  String get categoryDefaultDebtPayment => 'Cicilan & Hutang';

  @override
  String get categoryDefaultInsurance => 'Asuransi';

  @override
  String get categoryDefaultSubscriptions => 'Langganan';

  @override
  String get categoryDefaultOtherExpense => 'Lainnya';

  @override
  String get categoryDefaultSalary => 'Gaji';

  @override
  String get categoryDefaultBonus => 'Bonus';

  @override
  String get categoryDefaultBusiness => 'Usaha';

  @override
  String get categoryDefaultInvestment => 'Investasi';

  @override
  String get categoryDefaultGift => 'Hadiah';

  @override
  String get categoryDefaultSale => 'Penjualan';

  @override
  String get categoryDefaultRefund => 'Pengembalian Dana';

  @override
  String get categoryDefaultOtherIncome => 'Lainnya';

  @override
  String get categoryDefaultBalanceAdjustment => 'Penyesuaian Saldo';

  @override
  String get categoryDefaultTransfer => 'Transfer';

  @override
  String get allFinancialActivity => 'Semua aktivitas keuangan';

  @override
  String get manageCategories => 'Kelola Kategori';

  @override
  String get financialNotes => 'Catatan Keuangan';

  @override
  String get searchTransactionsHint => 'Cari transaksi atau catatan...';

  @override
  String get filter => 'Filter';

  @override
  String get filterTransactionsTitle => 'Filter Transaksi';

  @override
  String get totalIncome => 'Total pemasukan';

  @override
  String get totalExpenses => 'Total pengeluaran';

  @override
  String get transactionDetails => 'Detail transaksi';

  @override
  String get todayBalance => 'Saldo hari ini';

  @override
  String aboutVersion(Object build, Object version) {
    return 'Versi $version (Build $build)';
  }

  @override
  String get aboutDesc =>
      'Aplikasi manajemen keuangan pribadi yang membantu Anda melacak transaksi, anggaran, dompet, transaksi berulang, serta impian finansial Anda secara aman & privat.';

  @override
  String get developer => 'Pengembang';

  @override
  String get license => 'Lisensi';

  @override
  String get supportDeveloper => 'Dukung Pengembang (Donasi)';

  @override
  String get upcoming30Days => 'Akan datang (30 hari)';

  @override
  String itemsCount(Object count) {
    return '$count item';
  }

  @override
  String get goalName => 'NAMA TUJUAN';

  @override
  String get targetDate => 'Target Selesai';

  @override
  String get notSet => 'Belum ditentukan';

  @override
  String get prioritySubtitle => 'Tampilkan di paling atas halaman Impian';

  @override
  String get saveGoal => 'Simpan Tujuan';

  @override
  String get recentTransactions => 'Transaksi terbaru';

  @override
  String get incomeThisMonth => 'Pemasukan bulan ini';

  @override
  String get expenseThisMonth => 'Pengeluaran bulan ini';

  @override
  String get sixMonths => '6 bulan';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get goals => 'Target';

  @override
  String get budgetAmount => 'JUMLAH ANGGARAN';

  @override
  String get period => 'Periode';

  @override
  String get saveBudget => 'Simpan Anggaran';

  @override
  String get negative => 'Negatif';

  @override
  String accountHistoryOf(Object name) {
    return 'Riwayat $name';
  }

  @override
  String activeCount(Object count) {
    return '$count aktif';
  }

  @override
  String get quickAccess => 'Akses cepat';

  @override
  String get manageCategoriesSubtitle => 'Kelola kategori transaksi';

  @override
  String get addNotesSubtitle => 'Tambah catatan transaksi';

  @override
  String get last6Months => '6 bulan terakhir';

  @override
  String get categoryDistribution => 'Distribusi per kategori';

  @override
  String get positiveTrend => 'Tren positif';

  @override
  String trendPosTip(Object month, Object pct) {
    return 'Pengeluaran bulan ini turun $pct% dibanding $month. Pertahankan!';
  }

  @override
  String get trendKeepMonitoring =>
      'Pantau terus pengeluaran untuk mencapai target keuanganmu.';

  @override
  String get hintTransactionNote => 'Makan malam bersama tim...';

  @override
  String get selectDestinationAccount => 'Pilih Akun Tujuan';

  @override
  String get confirmDeleteTransaction =>
      'Apakah Anda yakin ingin menghapus transaksi ini?';

  @override
  String get enterTransactionAmount => 'Masukkan jumlah transaksi';

  @override
  String get selectAccountFirst => 'Pilih akun terlebih dahulu';

  @override
  String get selectDestinationAccountFirst =>
      'Pilih akun tujuan untuk transfer';

  @override
  String get deleteTransaction => 'Hapus Transaksi';

  @override
  String trendVsLastMonth(Object lastMonth, Object percent) {
    return '$percent% dibanding $lastMonth';
  }

  @override
  String get noRecurringTransactions => 'Belum ada transaksi berulang';

  @override
  String get tapAddRecurring => 'Tap \"+ Tambah\" untuk menambahkan';

  @override
  String renewInDays(Object count) {
    return 'Perpanjang dalam $count hari';
  }

  @override
  String get budgetRemainingThisMonth => 'Sisa anggaran bulan ini';

  @override
  String budgetAttentionWarning(Object name, Object pct) {
    return 'Anggaran $name sudah mencapai $pct% dari batas bulanan.';
  }

  @override
  String pocketLabel(Object balance, Object name) {
    return 'Kantong $name • $balance';
  }

  @override
  String get deposit => 'Setor';

  @override
  String pocketName(Object name) {
    return 'Kantong $name';
  }

  @override
  String get monthlyFinancialPlan => 'Rencana keuangan bulanan';

  @override
  String get realizeYourDreams => 'Wujudkan impianmu';

  @override
  String get manageDebtsAndReceivables => 'Kelola utang piutang';

  @override
  String progressPercentOfTarget(Object pct) {
    return '$pct% dari target';
  }

  @override
  String get noSavingsGoals => 'Belum ada target tabungan';

  @override
  String get tapAddGoal => 'Tap \"+ Tambah\" untuk membuat target';

  @override
  String get noActiveDebts => 'Tidak ada hutang aktif';

  @override
  String get debtList => 'Daftar hutang';

  @override
  String dueDateWithDate(Object date) {
    return 'Jatuh tempo: $date';
  }

  @override
  String get addDebtTitle => 'Tambah Utang/Piutang';

  @override
  String get nameLabel => 'NAMA';

  @override
  String get personNameHint => 'Contoh: Budi';

  @override
  String get dueDateTitle => 'Jatuh Tempo';

  @override
  String get saveDebt => 'Simpan Utang/Piutang';

  @override
  String get fillNameAndAmount => 'Isi nama dan nominal';

  @override
  String get attentionNeeded => 'Perlu perhatian';

  @override
  String get financialInsight => 'Insight keuangan';

  @override
  String trendExpenseIncreaseTip(Object month, Object pct) {
    return 'Pengeluaran bulan ini naik $pct% dibanding $month. Perhatikan anggaranmu!';
  }

  @override
  String trendIncomeIncreaseTip(Object month, Object pct) {
    return 'Pemasukan bulan ini naik $pct% dibanding $month. Kerja bagus!';
  }

  @override
  String trendIncomeDecreaseTip(Object month, Object pct) {
    return 'Pemasukan bulan ini turun $pct% dibanding $month.';
  }

  @override
  String trendCashFlowIncreaseTip(Object month, Object pct) {
    return 'Arus kas bulan ini meningkat $pct% dibanding $month.';
  }

  @override
  String trendCashFlowDecreaseTip(Object month, Object pct) {
    return 'Arus kas bulan ini menurun $pct% dibanding $month.';
  }
}
