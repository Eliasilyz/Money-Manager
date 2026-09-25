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
  /// **'Akun'**
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

  /// No description provided for @recurringAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah Transaksi Berulang'**
  String get recurringAdd;

  /// No description provided for @editRecurring.
  ///
  /// In id, this message translates to:
  /// **'Edit Transaksi Berulang'**
  String get editRecurring;

  /// No description provided for @frequency.
  ///
  /// In id, this message translates to:
  /// **'Frekuensi'**
  String get frequency;

  /// No description provided for @startDate.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get endDate;

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
  String notificationActiveCount(Object count);

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

  /// No description provided for @googleDriveTitle.
  ///
  /// In id, this message translates to:
  /// **'Google Drive'**
  String get googleDriveTitle;

  /// No description provided for @googleDriveConnected.
  ///
  /// In id, this message translates to:
  /// **'Terhubung sebagai {email}'**
  String googleDriveConnected(Object email);

  /// No description provided for @driveBackupsTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Cadangan di Google Drive'**
  String get driveBackupsTitle;

  /// No description provided for @loadingDriveBackups.
  ///
  /// In id, this message translates to:
  /// **'Memuat daftar cadangan...'**
  String get loadingDriveBackups;

  /// No description provided for @noDriveBackups.
  ///
  /// In id, this message translates to:
  /// **'Belum ada file backup di Google Drive'**
  String get noDriveBackups;

  /// No description provided for @deleteDriveBackupTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Cadangan Drive?'**
  String get deleteDriveBackupTitle;

  /// No description provided for @deleteDriveBackupConfirm.
  ///
  /// In id, this message translates to:
  /// **'File cadangan \"{name}\" akan dihapus dari Google Drive.'**
  String deleteDriveBackupConfirm(Object name);

  /// No description provided for @backupSuccess.
  ///
  /// In id, this message translates to:
  /// **'Backup ke Google Drive berhasil!'**
  String get backupSuccess;

  /// No description provided for @backupProgress.
  ///
  /// In id, this message translates to:
  /// **'Mengunggah backup ke Google Drive...'**
  String get backupProgress;

  /// No description provided for @restoreProgress.
  ///
  /// In id, this message translates to:
  /// **'Memulihkan data dari Google Drive...'**
  String get restoreProgress;

  /// No description provided for @enterBackupPassword.
  ///
  /// In id, this message translates to:
  /// **'Masukkan Kata Sandi Enkripsi'**
  String get enterBackupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi (kosongkan jika tidak terenkripsi)'**
  String get backupPasswordHint;

  /// No description provided for @googleCloudSetupInfo.
  ///
  /// In id, this message translates to:
  /// **'Panduan Cloud Console'**
  String get googleCloudSetupInfo;

  /// No description provided for @googleCloudSetupDesc.
  ///
  /// In id, this message translates to:
  /// **'Pastikan Google Drive API dan OAuth 2.0 Client ID (Package: id.eliasilyz.moneymanager) sudah dikonfigurasi pada https://console.cloud.google.com/'**
  String get googleCloudSetupDesc;

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

  /// No description provided for @deleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin menghapus?'**
  String get deleteConfirm;

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

  /// No description provided for @totalNetBalance.
  ///
  /// In id, this message translates to:
  /// **'Total Saldo Bersih'**
  String get totalNetBalance;

  /// No description provided for @lastUpdatedAgo.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui {minutes} mnt lalu'**
  String lastUpdatedAgo(Object minutes);

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
  ///
  /// In id, this message translates to:
  /// **'Yang Baru'**
  String get changelog;

  /// No description provided for @donation.
  ///
  /// In id, this message translates to:
  /// **'Dukung Pengembang'**
  String get donation;

  /// No description provided for @developerCredits.
  ///
  /// In id, this message translates to:
  /// **'Dikembangkan oleh {name}'**
  String developerCredits(Object name);

  /// No description provided for @noChangelog.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan perubahan.'**
  String get noChangelog;

  /// No description provided for @copiedToClipboard.
  ///
  /// In id, this message translates to:
  /// **'Disalin ke clipboard'**
  String get copiedToClipboard;

  /// No description provided for @editTransaction.
  ///
  /// In id, this message translates to:
  /// **'Ubah transaksi'**
  String get editTransaction;

  /// No description provided for @editTransactionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Perbarui data transaksi'**
  String get editTransactionSubtitle;

  /// No description provided for @saveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get saveChanges;

  /// No description provided for @confirmDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi ini?'**
  String get confirmDelete;

  /// No description provided for @transactionUpdated.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil diperbarui'**
  String get transactionUpdated;

  /// No description provided for @transactionDeleted.
  ///
  /// In id, this message translates to:
  /// **'Transaksi berhasil dihapus'**
  String get transactionDeleted;

  /// No description provided for @transactionSaveError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan transaksi'**
  String get transactionSaveError;

  /// No description provided for @analytics.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get analytics;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @expensePerCategory.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per kategori'**
  String get expensePerCategory;

  /// No description provided for @netBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo bersih'**
  String get netBalance;

  /// No description provided for @filterTransactions.
  ///
  /// In id, this message translates to:
  /// **'Filter Transaksi'**
  String get filterTransactions;

  /// No description provided for @type.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get type;

  /// No description provided for @thisWeekShort.
  ///
  /// In id, this message translates to:
  /// **'Minggu ini'**
  String get thisWeekShort;

  /// No description provided for @thisMonthShort.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get thisMonthShort;

  /// No description provided for @applyFilter.
  ///
  /// In id, this message translates to:
  /// **'Terapkan filter'**
  String get applyFilter;

  /// No description provided for @transactionAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah transaksi'**
  String get transactionAmount;

  /// No description provided for @addNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Tambah catatan transaksi'**
  String get addNoteHint;

  /// No description provided for @editAfterSave.
  ///
  /// In id, this message translates to:
  /// **'Anda masih bisa mengedit setelah menyimpan'**
  String get editAfterSave;

  /// No description provided for @addNewAccount.
  ///
  /// In id, this message translates to:
  /// **'Tambah akun baru'**
  String get addNewAccount;

  /// No description provided for @selectAccountAndAmount.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun dan masukkan nominal yang valid'**
  String get selectAccountAndAmount;

  /// No description provided for @manageAccounts.
  ///
  /// In id, this message translates to:
  /// **'Kelola Akun'**
  String get manageAccounts;

  /// No description provided for @activeAccounts.
  ///
  /// In id, this message translates to:
  /// **'Akun Aktif'**
  String get activeAccounts;

  /// No description provided for @archivedAccounts.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan'**
  String get archivedAccounts;

  /// No description provided for @editAccount.
  ///
  /// In id, this message translates to:
  /// **'Edit Akun'**
  String get editAccount;

  /// No description provided for @editBudget.
  ///
  /// In id, this message translates to:
  /// **'Edit Anggaran'**
  String get editBudget;

  /// No description provided for @editGoal.
  ///
  /// In id, this message translates to:
  /// **'Edit Target'**
  String get editGoal;

  /// No description provided for @adjustBalance.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan Saldo'**
  String get adjustBalance;

  /// No description provided for @archiveAccount.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get archiveAccount;

  /// No description provided for @activateAccount.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Kembali'**
  String get activateAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Akun'**
  String get deleteAccountTitle;

  /// No description provided for @accountHasTransactions.
  ///
  /// In id, this message translates to:
  /// **'Akun ini memiliki {count} transaksi. Gunakan \"Arsipkan\" untuk menyembunyikan.'**
  String accountHasTransactions(Object count);

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In id, this message translates to:
  /// **'Akun \"{name}\" akan dihapus permanen.'**
  String deleteAccountConfirm(Object name);

  /// No description provided for @balanceTarget.
  ///
  /// In id, this message translates to:
  /// **'Saldo target'**
  String get balanceTarget;

  /// No description provided for @adjustmentNote.
  ///
  /// In id, this message translates to:
  /// **'Akan membuat transaksi penyesuaian.'**
  String get adjustmentNote;

  /// No description provided for @apply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get apply;

  /// No description provided for @balanceAdjusted.
  ///
  /// In id, this message translates to:
  /// **'Saldo disesuaikan'**
  String get balanceAdjusted;

  /// No description provided for @balanceAdjustmentDesc.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian saldo'**
  String get balanceAdjustmentDesc;

  /// No description provided for @addAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Akun'**
  String get addAccountTitle;

  /// No description provided for @accountNameLabel.
  ///
  /// In id, this message translates to:
  /// **'NAMA AKUN'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: BCA Utama'**
  String get accountNameHint;

  /// No description provided for @accountTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'TIPE AKUN'**
  String get accountTypeLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In id, this message translates to:
  /// **'MATA UANG'**
  String get currencyLabel;

  /// No description provided for @initialBalanceLabel.
  ///
  /// In id, this message translates to:
  /// **'SALDO AWAL'**
  String get initialBalanceLabel;

  /// No description provided for @noteLabel.
  ///
  /// In id, this message translates to:
  /// **'CATATAN'**
  String get noteLabel;

  /// No description provided for @saveAccount.
  ///
  /// In id, this message translates to:
  /// **'Simpan Akun'**
  String get saveAccount;

  /// No description provided for @accountNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama akun'**
  String get accountNameRequired;

  /// No description provided for @addTransferTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Transfer'**
  String get addTransferTitle;

  /// No description provided for @createNewAccount.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get createNewAccount;

  /// No description provided for @selectFromAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih Akun Asal'**
  String get selectFromAccount;

  /// No description provided for @selectToAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih Akun Tujuan'**
  String get selectToAccount;

  /// No description provided for @nominalLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMINAL'**
  String get nominalLabel;

  /// No description provided for @exchangeRateLabel.
  ///
  /// In id, this message translates to:
  /// **'KURS'**
  String get exchangeRateLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'KETERANGAN'**
  String get descriptionLabel;

  /// No description provided for @saveTransfer.
  ///
  /// In id, this message translates to:
  /// **'Simpan Transfer'**
  String get saveTransfer;

  /// No description provided for @fillAmountAndSelectAccounts.
  ///
  /// In id, this message translates to:
  /// **'Isi nominal dan pilih kedua akun'**
  String get fillAmountAndSelectAccounts;

  /// No description provided for @accountsMustBeDifferent.
  ///
  /// In id, this message translates to:
  /// **'Akun asal dan tujuan tidak boleh sama'**
  String get accountsMustBeDifferent;

  /// No description provided for @appSettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan aplikasi & data'**
  String get appSettingsSubtitle;

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @otherFeatures.
  ///
  /// In id, this message translates to:
  /// **'Fitur Lainnya'**
  String get otherFeatures;

  /// No description provided for @budgetsAndGoals.
  ///
  /// In id, this message translates to:
  /// **'Anggaran & Target'**
  String get budgetsAndGoals;

  /// No description provided for @defaultCurrencyName.
  ///
  /// In id, this message translates to:
  /// **'Rupiah Indonesia (IDR)'**
  String get defaultCurrencyName;

  /// No description provided for @baseCurrency.
  ///
  /// In id, this message translates to:
  /// **'Mata uang dasar'**
  String get baseCurrency;

  /// No description provided for @refreshRates.
  ///
  /// In id, this message translates to:
  /// **'Segarkan kurs'**
  String get refreshRates;

  /// No description provided for @dataAndSecurity.
  ///
  /// In id, this message translates to:
  /// **'Data & keamanan'**
  String get dataAndSecurity;

  /// No description provided for @securitySubtitle.
  ///
  /// In id, this message translates to:
  /// **'PIN, biometrik, dan akses akun'**
  String get securitySubtitle;

  /// No description provided for @helpAndInfo.
  ///
  /// In id, this message translates to:
  /// **'Bantuan & informasi'**
  String get helpAndInfo;

  /// No description provided for @themeUppercase.
  ///
  /// In id, this message translates to:
  /// **'TEMA'**
  String get themeUppercase;

  /// No description provided for @languageUppercase.
  ///
  /// In id, this message translates to:
  /// **'BAHASA'**
  String get languageUppercase;

  /// No description provided for @backupAvailablePlatform.
  ///
  /// In id, this message translates to:
  /// **'Backup tersedia di Android/iOS'**
  String get backupAvailablePlatform;

  /// No description provided for @backupRetention.
  ///
  /// In id, this message translates to:
  /// **'Retensi backup'**
  String get backupRetention;

  /// No description provided for @maxBackups.
  ///
  /// In id, this message translates to:
  /// **'Maks backup'**
  String get maxBackups;

  /// No description provided for @maxBackupsDesc.
  ///
  /// In id, this message translates to:
  /// **'Backup otomatis tertua dihapus lebih dulu'**
  String get maxBackupsDesc;

  /// No description provided for @noBackupYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada backup'**
  String get noBackupYet;

  /// No description provided for @noChangesSkipBackup.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada perubahan, skip backup.'**
  String get noChangesSkipBackup;

  /// No description provided for @backupSuccessNoUpload.
  ///
  /// In id, this message translates to:
  /// **'Backup berhasil (belum terupload — TODO Drive)'**
  String get backupSuccessNoUpload;

  /// No description provided for @restoreWillReplace.
  ///
  /// In id, this message translates to:
  /// **'Restore akan mengganti data saat ini. Sebuah snapshot cadangan akan dibuat untuk jaga-jaga.'**
  String get restoreWillReplace;

  /// No description provided for @restoreSuccessDrive.
  ///
  /// In id, this message translates to:
  /// **'Restore berhasil (TODO: implement Drive download)'**
  String get restoreSuccessDrive;

  /// No description provided for @interval.
  ///
  /// In id, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @backupSuccessful.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get backupSuccessful;

  /// No description provided for @categoryDefaultFoodDrink.
  ///
  /// In id, this message translates to:
  /// **'Makan & Minum'**
  String get categoryDefaultFoodDrink;

  /// No description provided for @categoryDefaultTransport.
  ///
  /// In id, this message translates to:
  /// **'Transportasi'**
  String get categoryDefaultTransport;

  /// No description provided for @categoryDefaultShopping.
  ///
  /// In id, this message translates to:
  /// **'Belanja'**
  String get categoryDefaultShopping;

  /// No description provided for @categoryDefaultHousing.
  ///
  /// In id, this message translates to:
  /// **'Rumah & Sewa'**
  String get categoryDefaultHousing;

  /// No description provided for @categoryDefaultUtilities.
  ///
  /// In id, this message translates to:
  /// **'Tagihan & Utilitas'**
  String get categoryDefaultUtilities;

  /// No description provided for @categoryDefaultHealth.
  ///
  /// In id, this message translates to:
  /// **'Kesehatan'**
  String get categoryDefaultHealth;

  /// No description provided for @categoryDefaultEducation.
  ///
  /// In id, this message translates to:
  /// **'Pendidikan'**
  String get categoryDefaultEducation;

  /// No description provided for @categoryDefaultEntertainment.
  ///
  /// In id, this message translates to:
  /// **'Hiburan'**
  String get categoryDefaultEntertainment;

  /// No description provided for @categoryDefaultVacation.
  ///
  /// In id, this message translates to:
  /// **'Liburan'**
  String get categoryDefaultVacation;

  /// No description provided for @categoryDefaultFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluarga & Anak'**
  String get categoryDefaultFamily;

  /// No description provided for @categoryDefaultPersonalCare.
  ///
  /// In id, this message translates to:
  /// **'Perawatan Diri'**
  String get categoryDefaultPersonalCare;

  /// No description provided for @categoryDefaultGifts.
  ///
  /// In id, this message translates to:
  /// **'Hadiah & Donasi'**
  String get categoryDefaultGifts;

  /// No description provided for @categoryDefaultDebtPayment.
  ///
  /// In id, this message translates to:
  /// **'Cicilan & Hutang'**
  String get categoryDefaultDebtPayment;

  /// No description provided for @categoryDefaultInsurance.
  ///
  /// In id, this message translates to:
  /// **'Asuransi'**
  String get categoryDefaultInsurance;

  /// No description provided for @categoryDefaultSubscriptions.
  ///
  /// In id, this message translates to:
  /// **'Langganan'**
  String get categoryDefaultSubscriptions;

  /// No description provided for @categoryDefaultOtherExpense.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get categoryDefaultOtherExpense;

  /// No description provided for @categoryDefaultSalary.
  ///
  /// In id, this message translates to:
  /// **'Gaji'**
  String get categoryDefaultSalary;

  /// No description provided for @categoryDefaultBonus.
  ///
  /// In id, this message translates to:
  /// **'Bonus'**
  String get categoryDefaultBonus;

  /// No description provided for @categoryDefaultBusiness.
  ///
  /// In id, this message translates to:
  /// **'Usaha'**
  String get categoryDefaultBusiness;

  /// No description provided for @categoryDefaultInvestment.
  ///
  /// In id, this message translates to:
  /// **'Investasi'**
  String get categoryDefaultInvestment;

  /// No description provided for @categoryDefaultGift.
  ///
  /// In id, this message translates to:
  /// **'Hadiah'**
  String get categoryDefaultGift;

  /// No description provided for @categoryDefaultSale.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get categoryDefaultSale;

  /// No description provided for @categoryDefaultRefund.
  ///
  /// In id, this message translates to:
  /// **'Pengembalian Dana'**
  String get categoryDefaultRefund;

  /// No description provided for @categoryDefaultOtherIncome.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get categoryDefaultOtherIncome;

  /// No description provided for @categoryDefaultBalanceAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian Saldo'**
  String get categoryDefaultBalanceAdjustment;

  /// No description provided for @categoryDefaultTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get categoryDefaultTransfer;

  /// No description provided for @allFinancialActivity.
  ///
  /// In id, this message translates to:
  /// **'Semua aktivitas keuangan'**
  String get allFinancialActivity;

  /// No description provided for @manageCategories.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategories;

  /// No description provided for @financialNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan Keuangan'**
  String get financialNotes;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In id, this message translates to:
  /// **'Cari transaksi atau catatan...'**
  String get searchTransactionsHint;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterTransactionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Filter Transaksi'**
  String get filterTransactionsTitle;

  /// No description provided for @totalIncome.
  ///
  /// In id, this message translates to:
  /// **'Total pemasukan'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In id, this message translates to:
  /// **'Total pengeluaran'**
  String get totalExpenses;

  /// No description provided for @transactionDetails.
  ///
  /// In id, this message translates to:
  /// **'Detail transaksi'**
  String get transactionDetails;

  /// No description provided for @todayBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo hari ini'**
  String get todayBalance;

  /// No description provided for @aboutVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi {version} (Build {build})'**
  String aboutVersion(Object build, Object version);

  /// No description provided for @aboutDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi manajemen keuangan pribadi yang membantu Anda melacak transaksi, anggaran, dompet, transaksi berulang, serta impian finansial Anda secara aman & privat.'**
  String get aboutDesc;

  /// No description provided for @developer.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get developer;

  /// No description provided for @license.
  ///
  /// In id, this message translates to:
  /// **'Lisensi'**
  String get license;

  /// No description provided for @supportDeveloper.
  ///
  /// In id, this message translates to:
  /// **'Dukung Pengembang (Donasi)'**
  String get supportDeveloper;

  /// No description provided for @upcoming30Days.
  ///
  /// In id, this message translates to:
  /// **'Akan datang (30 hari)'**
  String get upcoming30Days;

  /// No description provided for @itemsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} item'**
  String itemsCount(Object count);

  /// No description provided for @goalName.
  ///
  /// In id, this message translates to:
  /// **'NAMA TUJUAN'**
  String get goalName;

  /// No description provided for @targetDate.
  ///
  /// In id, this message translates to:
  /// **'Target Selesai'**
  String get targetDate;

  /// No description provided for @notSet.
  ///
  /// In id, this message translates to:
  /// **'Belum ditentukan'**
  String get notSet;

  /// No description provided for @prioritySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan di paling atas halaman Impian'**
  String get prioritySubtitle;

  /// No description provided for @saveGoal.
  ///
  /// In id, this message translates to:
  /// **'Simpan Tujuan'**
  String get saveGoal;

  /// No description provided for @recentTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi terbaru'**
  String get recentTransactions;

  /// No description provided for @incomeThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan bulan ini'**
  String get incomeThisMonth;

  /// No description provided for @expenseThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran bulan ini'**
  String get expenseThisMonth;

  /// No description provided for @sixMonths.
  ///
  /// In id, this message translates to:
  /// **'6 bulan'**
  String get sixMonths;

  /// No description provided for @yesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterday;

  /// No description provided for @goals.
  ///
  /// In id, this message translates to:
  /// **'Target'**
  String get goals;

  /// No description provided for @budgetAmount.
  ///
  /// In id, this message translates to:
  /// **'JUMLAH ANGGARAN'**
  String get budgetAmount;

  /// No description provided for @period.
  ///
  /// In id, this message translates to:
  /// **'Periode'**
  String get period;

  /// No description provided for @saveBudget.
  ///
  /// In id, this message translates to:
  /// **'Simpan Anggaran'**
  String get saveBudget;

  /// No description provided for @negative.
  ///
  /// In id, this message translates to:
  /// **'Negatif'**
  String get negative;

  /// No description provided for @accountHistoryOf.
  ///
  /// In id, this message translates to:
  /// **'Riwayat {name}'**
  String accountHistoryOf(Object name);

  /// No description provided for @activeCount.
  ///
  /// In id, this message translates to:
  /// **'{count} aktif'**
  String activeCount(Object count);

  /// No description provided for @quickAccess.
  ///
  /// In id, this message translates to:
  /// **'Akses cepat'**
  String get quickAccess;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola kategori transaksi'**
  String get manageCategoriesSubtitle;

  /// No description provided for @addNotesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah catatan transaksi'**
  String get addNotesSubtitle;

  /// No description provided for @last6Months.
  ///
  /// In id, this message translates to:
  /// **'6 bulan terakhir'**
  String get last6Months;

  /// No description provided for @categoryDistribution.
  ///
  /// In id, this message translates to:
  /// **'Distribusi per kategori'**
  String get categoryDistribution;

  /// No description provided for @positiveTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren positif'**
  String get positiveTrend;

  /// No description provided for @trendPosTip.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran bulan ini turun {pct}% dibanding {month}. Pertahankan!'**
  String trendPosTip(Object month, Object pct);

  /// No description provided for @trendKeepMonitoring.
  ///
  /// In id, this message translates to:
  /// **'Pantau terus pengeluaran untuk mencapai target keuanganmu.'**
  String get trendKeepMonitoring;

  /// No description provided for @hintTransactionNote.
  ///
  /// In id, this message translates to:
  /// **'Makan malam bersama tim...'**
  String get hintTransactionNote;

  /// No description provided for @selectDestinationAccount.
  ///
  /// In id, this message translates to:
  /// **'Pilih Akun Tujuan'**
  String get selectDestinationAccount;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus transaksi ini?'**
  String get confirmDeleteTransaction;

  /// No description provided for @enterTransactionAmount.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah transaksi'**
  String get enterTransactionAmount;

  /// No description provided for @selectAccountFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun terlebih dahulu'**
  String get selectAccountFirst;

  /// No description provided for @selectDestinationAccountFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih akun tujuan untuk transfer'**
  String get selectDestinationAccountFirst;

  /// No description provided for @deleteTransaction.
  ///
  /// In id, this message translates to:
  /// **'Hapus Transaksi'**
  String get deleteTransaction;

  /// No description provided for @trendVsLastMonth.
  ///
  /// In id, this message translates to:
  /// **'{percent}% dibanding {lastMonth}'**
  String trendVsLastMonth(Object lastMonth, Object percent);

  /// No description provided for @noRecurringTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi berulang'**
  String get noRecurringTransactions;

  /// No description provided for @tapAddRecurring.
  ///
  /// In id, this message translates to:
  /// **'Tap \"+ Tambah\" untuk menambahkan'**
  String get tapAddRecurring;

  /// No description provided for @renewInDays.
  ///
  /// In id, this message translates to:
  /// **'Perpanjang dalam {count} hari'**
  String renewInDays(Object count);

  /// No description provided for @budgetRemainingThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Sisa anggaran bulan ini'**
  String get budgetRemainingThisMonth;

  /// No description provided for @budgetAttentionWarning.
  ///
  /// In id, this message translates to:
  /// **'Anggaran {name} sudah mencapai {pct}% dari batas bulanan.'**
  String budgetAttentionWarning(Object name, Object pct);

  /// No description provided for @pocketLabel.
  ///
  /// In id, this message translates to:
  /// **'Kantong {name} • {balance}'**
  String pocketLabel(Object balance, Object name);

  /// No description provided for @deposit.
  ///
  /// In id, this message translates to:
  /// **'Setor'**
  String get deposit;

  /// No description provided for @pocketName.
  ///
  /// In id, this message translates to:
  /// **'Kantong {name}'**
  String pocketName(Object name);

  /// No description provided for @monthlyFinancialPlan.
  ///
  /// In id, this message translates to:
  /// **'Rencana keuangan bulanan'**
  String get monthlyFinancialPlan;

  /// No description provided for @realizeYourDreams.
  ///
  /// In id, this message translates to:
  /// **'Wujudkan impianmu'**
  String get realizeYourDreams;

  /// No description provided for @manageDebtsAndReceivables.
  ///
  /// In id, this message translates to:
  /// **'Kelola utang piutang'**
  String get manageDebtsAndReceivables;

  /// No description provided for @progressPercentOfTarget.
  ///
  /// In id, this message translates to:
  /// **'{pct}% dari target'**
  String progressPercentOfTarget(Object pct);

  /// No description provided for @noSavingsGoals.
  ///
  /// In id, this message translates to:
  /// **'Belum ada target tabungan'**
  String get noSavingsGoals;

  /// No description provided for @tapAddGoal.
  ///
  /// In id, this message translates to:
  /// **'Tap \"+ Tambah\" untuk membuat target'**
  String get tapAddGoal;

  /// No description provided for @noActiveDebts.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hutang aktif'**
  String get noActiveDebts;

  /// No description provided for @debtList.
  ///
  /// In id, this message translates to:
  /// **'Daftar hutang'**
  String get debtList;

  /// No description provided for @dueDateWithDate.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo: {date}'**
  String dueDateWithDate(Object date);

  /// No description provided for @addDebtTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Utang/Piutang'**
  String get addDebtTitle;

  /// No description provided for @nameLabel.
  ///
  /// In id, this message translates to:
  /// **'NAMA'**
  String get nameLabel;

  /// No description provided for @personNameHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Budi'**
  String get personNameHint;

  /// No description provided for @dueDateTitle.
  ///
  /// In id, this message translates to:
  /// **'Jatuh Tempo'**
  String get dueDateTitle;

  /// No description provided for @saveDebt.
  ///
  /// In id, this message translates to:
  /// **'Simpan Utang/Piutang'**
  String get saveDebt;

  /// No description provided for @fillNameAndAmount.
  ///
  /// In id, this message translates to:
  /// **'Isi nama dan nominal'**
  String get fillNameAndAmount;

  /// No description provided for @attentionNeeded.
  ///
  /// In id, this message translates to:
  /// **'Perlu perhatian'**
  String get attentionNeeded;

  /// No description provided for @financialInsight.
  ///
  /// In id, this message translates to:
  /// **'Insight keuangan'**
  String get financialInsight;

  /// No description provided for @trendExpenseIncreaseTip.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran bulan ini naik {pct}% dibanding {month}. Perhatikan anggaranmu!'**
  String trendExpenseIncreaseTip(Object month, Object pct);

  /// No description provided for @trendIncomeIncreaseTip.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan bulan ini naik {pct}% dibanding {month}. Kerja bagus!'**
  String trendIncomeIncreaseTip(Object month, Object pct);

  /// No description provided for @trendIncomeDecreaseTip.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan bulan ini turun {pct}% dibanding {month}.'**
  String trendIncomeDecreaseTip(Object month, Object pct);

  /// No description provided for @trendCashFlowIncreaseTip.
  ///
  /// In id, this message translates to:
  /// **'Arus kas bulan ini meningkat {pct}% dibanding {month}.'**
  String trendCashFlowIncreaseTip(Object month, Object pct);

  /// No description provided for @trendCashFlowDecreaseTip.
  ///
  /// In id, this message translates to:
  /// **'Arus kas bulan ini menurun {pct}% dibanding {month}.'**
  String trendCashFlowDecreaseTip(Object month, Object pct);

  /// No description provided for @notificationDailyBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa catat pengeluaran hari ini'**
  String get notificationDailyBody;

  /// No description provided for @notificationTestTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Tes - Money Manager'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In id, this message translates to:
  /// **'Jika kamu melihat ini, notifikasi aplikasi berfungsi dengan baik! 🎉'**
  String get notificationTestBody;

  /// No description provided for @enterCategoryName.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama kategori'**
  String get enterCategoryName;

  /// No description provided for @fillGoalNameAndTarget.
  ///
  /// In id, this message translates to:
  /// **'Isi nama dan target nominal'**
  String get fillGoalNameAndTarget;

  /// No description provided for @fillBudgetAmountCategory.
  ///
  /// In id, this message translates to:
  /// **'Isi nominal dan pilih kategori'**
  String get fillBudgetAmountCategory;

  /// No description provided for @fillRecurringAmountAccount.
  ///
  /// In id, this message translates to:
  /// **'Isi jumlah dan pilih akun'**
  String get fillRecurringAmountAccount;

  /// No description provided for @saveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String saveFailed(String error);

  /// No description provided for @signInSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil masuk sebagai {email}'**
  String signInSuccess(String email);

  /// No description provided for @signInFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal login Google: {error}'**
  String signInFailed(String error);

  /// No description provided for @signInCancelled.
  ///
  /// In id, this message translates to:
  /// **'Masuk Google dibatalkan atau memerlukan konfirmasi akun.'**
  String get signInCancelled;

  /// No description provided for @signInAuthMisconfigured.
  ///
  /// In id, this message translates to:
  /// **'Gagal autentikasi Google (SHA-1 / OAuth Client ID belum terdaftar di Google Cloud Console).'**
  String get signInAuthMisconfigured;

  /// No description provided for @signOutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil keluar dari akun Google'**
  String get signOutSuccess;

  /// No description provided for @signInForBackupRequired.
  ///
  /// In id, this message translates to:
  /// **'Silakan masuk dengan Google Drive untuk mencadangkan data.'**
  String get signInForBackupRequired;

  /// No description provided for @restoreSuccessCount.
  ///
  /// In id, this message translates to:
  /// **'Berhasil memulihkan {count} data dari Google Drive.'**
  String restoreSuccessCount(int count);

  /// No description provided for @driveFileDeleted.
  ///
  /// In id, this message translates to:
  /// **'File backup berhasil dihapus dari Google Drive.'**
  String get driveFileDeleted;

  /// No description provided for @infoCloud.
  ///
  /// In id, this message translates to:
  /// **'Info Cloud'**
  String get infoCloud;

  /// No description provided for @openCloudConsole.
  ///
  /// In id, this message translates to:
  /// **'Buka Console Cloud Google'**
  String get openCloudConsole;

  /// No description provided for @driveStorage.
  ///
  /// In id, this message translates to:
  /// **'Storage: {size}'**
  String driveStorage(String size);

  /// No description provided for @backupSignInRequired.
  ///
  /// In id, this message translates to:
  /// **'Silakan masuk ke Google Drive terlebih dahulu.'**
  String get backupSignInRequired;

  /// No description provided for @backupDriveFileUnreadable.
  ///
  /// In id, this message translates to:
  /// **'File backup dari Drive tidak dapat dibaca.'**
  String get backupDriveFileUnreadable;

  /// No description provided for @backupInvalidFile.
  ///
  /// In id, this message translates to:
  /// **'File bukan backup yang valid.'**
  String get backupInvalidFile;

  /// No description provided for @backupNeedsPassword.
  ///
  /// In id, this message translates to:
  /// **'Backup terenkripsi memerlukan kata sandi.'**
  String get backupNeedsPassword;

  /// No description provided for @backupEncryptedInvalid.
  ///
  /// In id, this message translates to:
  /// **'Backup terenkripsi tidak valid.'**
  String get backupEncryptedInvalid;

  /// No description provided for @backupWrongPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi salah atau file rusak.'**
  String get backupWrongPassword;

  /// No description provided for @backupEncryptedCorrupt.
  ///
  /// In id, this message translates to:
  /// **'File backup terenkripsi rusak.'**
  String get backupEncryptedCorrupt;

  /// No description provided for @backupUnknownFormat.
  ///
  /// In id, this message translates to:
  /// **'Format backup tidak dikenali.'**
  String get backupUnknownFormat;

  /// No description provided for @backupSchemaInvalid.
  ///
  /// In id, this message translates to:
  /// **'Versi skema backup tidak valid.'**
  String get backupSchemaInvalid;

  /// No description provided for @backupFromNewerVersion.
  ///
  /// In id, this message translates to:
  /// **'Backup dibuat oleh versi yang lebih baru (skema {version}). Update aplikasi terlebih dahulu.'**
  String backupFromNewerVersion(int version);

  /// No description provided for @backupDataCorrupt.
  ///
  /// In id, this message translates to:
  /// **'Data backup kosong atau rusak.'**
  String get backupDataCorrupt;

  /// No description provided for @backupCollectionCorrupt.
  ///
  /// In id, this message translates to:
  /// **'Koleksi \"{name}\" pada backup rusak.'**
  String backupCollectionCorrupt(String name);

  /// No description provided for @backupSnapshotMissing.
  ///
  /// In id, this message translates to:
  /// **'Snapshot cadangan tidak ditemukan.'**
  String get backupSnapshotMissing;

  /// No description provided for @driveUploadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunggah backup ke Google Drive ({code})'**
  String driveUploadFailed(int code);

  /// No description provided for @driveListFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil daftar backup dari Google Drive ({code})'**
  String driveListFailed(int code);

  /// No description provided for @driveDownloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunduh backup dari Google Drive ({code})'**
  String driveDownloadFailed(int code);

  /// No description provided for @driveDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus file backup dari Google Drive ({code})'**
  String driveDeleteFailed(int code);

  /// No description provided for @biometricReason.
  ///
  /// In id, this message translates to:
  /// **'Buka Money Manager dengan biometrik'**
  String get biometricReason;
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
