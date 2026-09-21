import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Money Manager'**
  String get appTitle;

  /// No description provided for @goodMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get goodNight;

  /// No description provided for @totalBalance.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo'**
  String get totalBalance;

  /// No description provided for @incomeMonth.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get incomeMonth;

  /// No description provided for @expensesMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expensesMonth;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @thisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get thisMonth;

  /// No description provided for @total.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transactions;

  /// No description provided for @accounts.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get accounts;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get settings;

  /// No description provided for @noTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get noTransactions;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @transactionTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transactionTitle;

  /// No description provided for @transactionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Semua aktivitas keuangan'**
  String get transactionSubtitle;

  /// No description provided for @noTransactionsFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi ditemukan'**
  String get noTransactionsFound;

  /// No description provided for @categories.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get categories;

  /// No description provided for @accountsTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun & Dompet'**
  String get accountsTitle;

  /// No description provided for @accountsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{count} akun aktif'**
  String accountsSubtitle(Object count);

  /// No description provided for @addAccount.
  ///
  /// In id, this message translates to:
  /// **'+ Akun'**
  String get addAccount;

  /// No description provided for @noAccounts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun'**
  String get noAccounts;

  /// No description provided for @firstTransaction.
  ///
  /// In id, this message translates to:
  /// **'Tap + untuk transaksi pertama'**
  String get firstTransaction;

  /// No description provided for @budgets.
  ///
  /// In id, this message translates to:
  /// **'Anggaran'**
  String get budgets;

  /// No description provided for @goalsAndDebts.
  ///
  /// In id, this message translates to:
  /// **'Target & Hutang'**
  String get goalsAndDebts;

  /// No description provided for @recurring.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Berulang'**
  String get recurring;

  /// No description provided for @statistics.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// No description provided for @calendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender Keuangan'**
  String get calendar;

  /// No description provided for @notes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get notes;

  /// No description provided for @searchTransactions.
  ///
  /// In id, this message translates to:
  /// **'Cari transaksi atau catatan...'**
  String get searchTransactions;

  /// No description provided for @allFilter.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get allFilter;

  /// No description provided for @categoryFilter.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get categoryFilter;

  /// No description provided for @accountFilter.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get accountFilter;

  /// No description provided for @periodFilter.
  ///
  /// In id, this message translates to:
  /// **'Periode'**
  String get periodFilter;

  /// No description provided for @todayTitle.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get todayTitle;

  /// No description provided for @yesterdayTitle.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterdayTitle;

  /// No description provided for @addTransaction.
  ///
  /// In id, this message translates to:
  /// **'Tambah transaksi'**
  String get addTransaction;

  /// No description provided for @addTransactionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catat dengan cepat'**
  String get addTransactionSubtitle;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @expense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @amount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @fromAccount.
  ///
  /// In id, this message translates to:
  /// **'Dari akun'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In id, this message translates to:
  /// **'Ke akun'**
  String get toAccount;

  /// No description provided for @date.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get date;

  /// No description provided for @note.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get note;

  /// No description provided for @saveTransaction.
  ///
  /// In id, this message translates to:
  /// **'Simpan transaksi'**
  String get saveTransaction;

  /// No description provided for @selectCategory.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori'**
  String get selectCategory;

  /// No description provided for @selectAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun'**
  String get selectAccount;

  /// No description provided for @transferInfo.
  ///
  /// In id, this message translates to:
  /// **'Alur transfer antar akun'**
  String get transferInfo;

  /// No description provided for @from.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get from;

  /// No description provided for @to.
  ///
  /// In id, this message translates to:
  /// **'Ke'**
  String get to;

  /// No description provided for @currentBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo saat ini'**
  String get currentBalance;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get requiredField;

  /// No description provided for @amountMustBePositive.
  ///
  /// In id, this message translates to:
  /// **'Jumlah harus lebih dari 0'**
  String get amountMustBePositive;

  /// No description provided for @accountsMustDiffer.
  ///
  /// In id, this message translates to:
  /// **'Akun asal dan tujuan harus berbeda'**
  String get accountsMustDiffer;

  /// No description provided for @budgetsTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggaran'**
  String get budgetsTitle;

  /// No description provided for @budgetsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{monthYear}'**
  String budgetsSubtitle(Object monthYear);

  /// No description provided for @addBudget.
  ///
  /// In id, this message translates to:
  /// **'+ Buat'**
  String get addBudget;

  /// No description provided for @totalBudgetRemaining.
  ///
  /// In id, this message translates to:
  /// **'Total anggaran tersisa'**
  String get totalBudgetRemaining;

  /// No description provided for @spent.
  ///
  /// In id, this message translates to:
  /// **'{spent} dari {total}'**
  String spent(Object spent, Object total);

  /// No description provided for @perCategory.
  ///
  /// In id, this message translates to:
  /// **'Per kategori'**
  String get perCategory;

  /// No description provided for @budgetCount.
  ///
  /// In id, this message translates to:
  /// **'{count} anggaran'**
  String budgetCount(Object count);

  /// No description provided for @attention.
  ///
  /// In id, this message translates to:
  /// **'Perlu perhatian'**
  String get attention;

  /// No description provided for @overLimit.
  ///
  /// In id, this message translates to:
  /// **'Melebihi'**
  String get overLimit;

  /// No description provided for @noBudgets.
  ///
  /// In id, this message translates to:
  /// **'Belum ada budget'**
  String get noBudgets;

  /// No description provided for @goalsAndDebtsTitle.
  ///
  /// In id, this message translates to:
  /// **'Target & Hutang'**
  String get goalsAndDebtsTitle;

  /// No description provided for @financialPlan.
  ///
  /// In id, this message translates to:
  /// **'Rencana finansial'**
  String get financialPlan;

  /// No description provided for @addTarget.
  ///
  /// In id, this message translates to:
  /// **'+ Tambah'**
  String get addTarget;

  /// No description provided for @savingsTarget.
  ///
  /// In id, this message translates to:
  /// **'Target tabungan'**
  String get savingsTarget;

  /// No description provided for @debts.
  ///
  /// In id, this message translates to:
  /// **'Hutang'**
  String get debts;

  /// No description provided for @priority.
  ///
  /// In id, this message translates to:
  /// **'PRIORITAS'**
  String get priority;

  /// No description provided for @ofTarget.
  ///
  /// In id, this message translates to:
  /// **'{current} dari {target}'**
  String ofTarget(Object current, Object target);

  /// No description provided for @progress.
  ///
  /// In id, this message translates to:
  /// **'{percent}% tercapai'**
  String progress(Object percent);

  /// No description provided for @targetDeadline.
  ///
  /// In id, this message translates to:
  /// **'TARGET {date}'**
  String targetDeadline(Object date);

  /// No description provided for @debtSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan hutang'**
  String get debtSummary;

  /// No description provided for @totalDebtRemaining.
  ///
  /// In id, this message translates to:
  /// **'Total sisa hutang'**
  String get totalDebtRemaining;

  /// No description provided for @installment.
  ///
  /// In id, this message translates to:
  /// **'{paid} dari {total}'**
  String installment(Object paid, Object total);

  /// No description provided for @dueDate.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo {date}'**
  String dueDate(Object date);

  /// No description provided for @active.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get inactive;

  /// No description provided for @recurringTitle.
  ///
  /// In id, this message translates to:
  /// **'Transaksi Berulang'**
  String get recurringTitle;

  /// No description provided for @recurringSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Otomatis dan terjadwal'**
  String get recurringSubtitle;

  /// No description provided for @nextMonthProjection.
  ///
  /// In id, this message translates to:
  /// **'Proyeksi bulan depan'**
  String get nextMonthProjection;

  /// No description provided for @expenseCount.
  ///
  /// In id, this message translates to:
  /// **'{count} pengeluaran'**
  String expenseCount(Object count);

  /// No description provided for @incomeCount.
  ///
  /// In id, this message translates to:
  /// **'{count} pemasukan'**
  String incomeCount(Object count);

  /// No description provided for @comingSoon.
  ///
  /// In id, this message translates to:
  /// **'Akan datang'**
  String get comingSoon;

  /// No description provided for @daysLeft.
  ///
  /// In id, this message translates to:
  /// **'{count} hari lagi'**
  String daysLeft(Object count);

  /// No description provided for @everyDate.
  ///
  /// In id, this message translates to:
  /// **'Setiap tanggal {day}'**
  String everyDate(Object day);

  /// No description provided for @subscriptions.
  ///
  /// In id, this message translates to:
  /// **'Langganan'**
  String get subscriptions;

  /// No description provided for @statisticsTitle.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statisticsTitle;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Insight keuanganmu'**
  String get statisticsSubtitle;

  /// No description provided for @cashFlow.
  ///
  /// In id, this message translates to:
  /// **'Arus kas'**
  String get cashFlow;

  /// No description provided for @totalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @changeVsLastMonth.
  ///
  /// In id, this message translates to:
  /// **'Selisih vs bulan lalu'**
  String get changeVsLastMonth;

  /// No description provided for @decrease.
  ///
  /// In id, this message translates to:
  /// **'↓'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In id, this message translates to:
  /// **'↑'**
  String get increase;

  /// No description provided for @dailyAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata harian'**
  String get dailyAverage;

  /// No description provided for @highestDay.
  ///
  /// In id, this message translates to:
  /// **'Hari tertinggi'**
  String get highestDay;

  /// No description provided for @categoryBreakdown.
  ///
  /// In id, this message translates to:
  /// **'Breakdown kategori'**
  String get categoryBreakdown;

  /// No description provided for @viewDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail'**
  String get viewDetail;

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get noData;

  /// No description provided for @calendarTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender Keuangan'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{monthYear}'**
  String calendarSubtitle(Object monthYear);

  /// No description provided for @todayButton.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get todayButton;

  /// No description provided for @transactionCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String transactionCount(Object count);

  /// No description provided for @entries.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get entries;

  /// No description provided for @exits.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get exits;

  /// No description provided for @othersTitle.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get othersTitle;

  /// No description provided for @othersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan & fitur'**
  String get othersSubtitle;

  /// No description provided for @profileName.
  ///
  /// In id, this message translates to:
  /// **'Money Manager'**
  String get profileName;

  /// No description provided for @profileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Personal Finance Tracker'**
  String get profileSubtitle;

  /// No description provided for @financialManagement.
  ///
  /// In id, this message translates to:
  /// **'Kelola keuangan'**
  String get financialManagement;

  /// No description provided for @categoriesCount.
  ///
  /// In id, this message translates to:
  /// **'{count} kategori'**
  String categoriesCount(Object count);

  /// No description provided for @notesSaved.
  ///
  /// In id, this message translates to:
  /// **'{count} catatan tersimpan'**
  String notesSaved(Object count);

  /// No description provided for @activeRecurring.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi aktif'**
  String activeRecurring(Object count);

  /// No description provided for @budgetsGoalsCount.
  ///
  /// In id, this message translates to:
  /// **'{budgets} anggaran • {goals} target'**
  String budgetsGoalsCount(Object budgets, Object goals);

  /// No description provided for @backupRestore.
  ///
  /// In id, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @preferences.
  ///
  /// In id, this message translates to:
  /// **'Preferensi'**
  String get preferences;

  /// No description provided for @currency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang'**
  String get currency;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @notificationsActive.
  ///
  /// In id, this message translates to:
  /// **'Pengingat aktif'**
  String get notificationsActive;

  /// No description provided for @notificationsInactive.
  ///
  /// In id, this message translates to:
  /// **'Pengingat nonaktif'**
  String get notificationsInactive;

  /// No description provided for @notificationSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Notifikasi'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsExplanation.
  ///
  /// In id, this message translates to:
  /// **'Pengingat membantu kamu tidak melewatkan tagihan dan mengontrol anggaran'**
  String get notificationSettingsExplanation;

  /// No description provided for @notificationPermissionAllowed.
  ///
  /// In id, this message translates to:
  /// **'Diizinkan'**
  String get notificationPermissionAllowed;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationOpenSystemSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan sistem'**
  String get notificationOpenSystemSettings;

  /// No description provided for @notificationTypeRecurring.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & transaksi berulang'**
  String get notificationTypeRecurring;

  /// No description provided for @notificationTypeRecurringDesc.
  ///
  /// In id, this message translates to:
  /// **'Pengingat H-0, H-1, H-3 sebelum jatuh tempo'**
  String get notificationTypeRecurringDesc;

  /// No description provided for @notificationTypeDebt.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo hutang/cicilan'**
  String get notificationTypeDebt;

  /// No description provided for @notificationTypeDebtDesc.
  ///
  /// In id, this message translates to:
  /// **'Pengingat H-0, H-1, H-3 sebelum jatuh tempo'**
  String get notificationTypeDebtDesc;

  /// No description provided for @notificationTypeBudget.
  ///
  /// In id, this message translates to:
  /// **'Peringatan anggaran'**
  String get notificationTypeBudget;

  /// No description provided for @notificationTypeBudgetDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi saat anggaran mencapai 80% dan 100%'**
  String get notificationTypeBudgetDesc;

  /// No description provided for @notificationTypeDailyReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat catat transaksi harian'**
  String get notificationTypeDailyReminder;

  /// No description provided for @notificationTypeDailyReminderDesc.
  ///
  /// In id, this message translates to:
  /// **'Pengingat harian, dilewati jika sudah ada transaksi'**
  String get notificationTypeDailyReminderDesc;

  /// No description provided for @notificationTypeBackupStatus.
  ///
  /// In id, this message translates to:
  /// **'Status backup'**
  String get notificationTypeBackupStatus;

  /// No description provided for @notificationTypeBackupStatusDesc.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi jika backup gagal beberapa kali berturut-turut'**
  String get notificationTypeBackupStatusDesc;

  /// No description provided for @notificationTestButton.
  ///
  /// In id, this message translates to:
  /// **'Kirim notifikasi tes'**
  String get notificationTestButton;

  /// No description provided for @notificationTestSent.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi tes terkirim'**
  String get notificationTestSent;

  /// No description provided for @notificationActiveCount.
  ///
  /// In id, this message translates to:
  /// **'{count} pengingat aktif'**
  String notificationActiveCount(int count);

  /// No description provided for @view.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get view;

  /// No description provided for @lightTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema terang'**
  String get lightTheme;

  /// No description provided for @securityPriv.
  ///
  /// In id, this message translates to:
  /// **'Keamanan & privasi'**
  String get securityPriv;

  /// No description provided for @pinActive.
  ///
  /// In id, this message translates to:
  /// **'PIN dan biometrik aktif'**
  String get pinActive;

  /// No description provided for @pinInactive.
  ///
  /// In id, this message translates to:
  /// **'PIN dan biometrik tidak aktif'**
  String get pinInactive;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutApp;

  /// No description provided for @followSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get followSystem;

  /// No description provided for @light.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @signInOut.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan Google'**
  String get signInOut;

  /// No description provided for @signOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get signOut;

  /// No description provided for @notSignedIn.
  ///
  /// In id, this message translates to:
  /// **'Belum masuk'**
  String get notSignedIn;

  /// No description provided for @backupNow.
  ///
  /// In id, this message translates to:
  /// **'Backup sekarang'**
  String get backupNow;

  /// No description provided for @lastBackup.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir: {date}'**
  String lastBackup(Object date);

  /// No description provided for @manageBackups.
  ///
  /// In id, this message translates to:
  /// **'Kelola Cadangan'**
  String get manageBackups;

  /// No description provided for @deleteBackup.
  ///
  /// In id, this message translates to:
  /// **'Hapus Cadangan'**
  String get deleteBackup;

  /// No description provided for @exportLocal.
  ///
  /// In id, this message translates to:
  /// **'Ekspor ke file'**
  String get exportLocal;

  /// No description provided for @importLocal.
  ///
  /// In id, this message translates to:
  /// **'Impor dari file'**
  String get importLocal;

  /// No description provided for @autoBackup.
  ///
  /// In id, this message translates to:
  /// **'Backup otomatis'**
  String get autoBackup;

  /// No description provided for @wifiOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya Wi-Fi'**
  String get wifiOnly;

  /// No description provided for @encryptBackup.
  ///
  /// In id, this message translates to:
  /// **'Enkripsi dengan kata sandi'**
  String get encryptBackup;

  /// No description provided for @passwordRequired.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi wajib diisi'**
  String get passwordRequired;

  /// No description provided for @lostPasswordWarning.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi hilang = backup tidak bisa dipulihkan'**
  String get lostPasswordWarning;

  /// No description provided for @restore.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get restore;

  /// No description provided for @restoreConfirm.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan data dari backup ini?'**
  String get restoreConfirm;

  /// No description provided for @restoreWarning.
  ///
  /// In id, this message translates to:
  /// **'Data saat ini akan diganti.'**
  String get restoreWarning;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get version;

  /// No description provided for @build.
  ///
  /// In id, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @openSourceLicenses.
  ///
  /// In id, this message translates to:
  /// **'Lisensi Open Source'**
  String get openSourceLicenses;

  /// No description provided for @copyInfo.
  ///
  /// In id, this message translates to:
  /// **'Tekan lama untuk menyalin'**
  String get copyInfo;

  /// No description provided for @privacyPolicy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In id, this message translates to:
  /// **'Syarat & Ketentuan'**
  String get termsOfService;

  /// No description provided for @contact.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Kami'**
  String get contact;

  /// No description provided for @rateApp.
  ///
  /// In id, this message translates to:
  /// **'Nilai Aplikasi'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get shareApp;

  /// No description provided for @madeWith.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dengan'**
  String get madeWith;

  /// No description provided for @allRightsReserved.
  ///
  /// In id, this message translates to:
  /// **'Hak cipta dilindungi. {year}'**
  String allRightsReserved(Object year);

  /// No description provided for @debugInfo.
  ///
  /// In id, this message translates to:
  /// **'Info Debug'**
  String get debugInfo;

  /// No description provided for @enterPin.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN'**
  String get enterPin;

  /// No description provided for @changePin.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get changePin;

  /// No description provided for @enableBiometrics.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan biometrik'**
  String get enableBiometrics;

  /// No description provided for @biometricsActive.
  ///
  /// In id, this message translates to:
  /// **'Biometrik aktif'**
  String get biometricsActive;

  /// No description provided for @biometricsInactive.
  ///
  /// In id, this message translates to:
  /// **'Biometrik tidak aktif'**
  String get biometricsInactive;

  /// No description provided for @pinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak cocok'**
  String get pinMismatch;

  /// No description provided for @pinLength.
  ///
  /// In id, this message translates to:
  /// **'PIN harus {length} angka'**
  String pinLength(Object length);

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get create;

  /// No description provided for @update.
  ///
  /// In id, this message translates to:
  /// **'Perbarui'**
  String get update;

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @name.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get name;

  /// No description provided for @balance.
  ///
  /// In id, this message translates to:
  /// **'Saldo'**
  String get balance;

  /// No description provided for @description.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get description;

  /// No description provided for @optional.
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get optional;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @noConnection.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi'**
  String get noConnection;

  /// No description provided for @somethingWentWrong.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get somethingWentWrong;

  /// No description provided for @transactionType.
  ///
  /// In id, this message translates to:
  /// **'Jenis transaksi'**
  String get transactionType;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @resetFilters.
  ///
  /// In id, this message translates to:
  /// **'Reset filter'**
  String get resetFilters;

  /// No description provided for @filterCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get filterCalendar;

  /// No description provided for @monthYear.
  ///
  /// In id, this message translates to:
  /// **'Bulan & Tahun'**
  String get monthYear;

  /// No description provided for @financialSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Keuangan'**
  String get financialSummary;

  /// No description provided for @thisWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu Ini'**
  String get thisWeek;

  /// No description provided for @debtTypeBorrowed.
  ///
  /// In id, this message translates to:
  /// **'Hutang'**
  String get debtTypeBorrowed;

  /// No description provided for @debtTypeLent.
  ///
  /// In id, this message translates to:
  /// **'Piutang'**
  String get debtTypeLent;

  /// No description provided for @frequencyDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get frequencyDaily;

  /// No description provided for @frequencyWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get frequencyMonthly;

  /// No description provided for @frequencyYearly.
  ///
  /// In id, this message translates to:
  /// **'Tahunan'**
  String get frequencyYearly;

  /// No description provided for @nextDate.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya'**
  String get nextDate;

  /// No description provided for @manage.
  ///
  /// In id, this message translates to:
  /// **'Kelola'**
  String get manage;

  /// No description provided for @accountTypeCredit.
  ///
  /// In id, this message translates to:
  /// **'Kartu Kredit'**
  String get accountTypeCredit;

  /// No description provided for @accountTypeCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get accountTypeCash;

  /// No description provided for @other.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get other;

  /// No description provided for @accountList.
  ///
  /// In id, this message translates to:
  /// **'Daftar Akun'**
  String get accountList;

  /// No description provided for @netWorth.
  ///
  /// In id, this message translates to:
  /// **'Kekayaan Bersih'**
  String get netWorth;

  /// No description provided for @totalBudget.
  ///
  /// In id, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @firstNote.
  ///
  /// In id, this message translates to:
  /// **'Buat catatan pertama'**
  String get firstNote;

  /// No description provided for @addAccountButton.
  ///
  /// In id, this message translates to:
  /// **'+ Tambah akun'**
  String get addAccountButton;

  /// No description provided for @transferBalance.
  ///
  /// In id, this message translates to:
  /// **'Pindah saldo'**
  String get transferBalance;

  /// No description provided for @notesCount.
  ///
  /// In id, this message translates to:
  /// **'{count} catatan tersimpan'**
  String notesCount(Object count);

  /// No description provided for @accountTypeWallet.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get accountTypeWallet;

  /// No description provided for @accountTypeSavings.
  ///
  /// In id, this message translates to:
  /// **'Tabungan'**
  String get accountTypeSavings;

  /// No description provided for @accountTypeInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investasi'**
  String get accountTypeInvestment;

  /// No description provided for @changelog.
  String get changelog;

  /// No description provided for @donation.
  String get donation;

  /// No description provided for @developerCredits.
  String developerCredits(Object name);

  /// No description provided for @noChangelog.
  String get noChangelog;

  /// No description provided for @copiedToClipboard.
  String get copiedToClipboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
