// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get incomeMonth => 'Income';

  @override
  String get expensesMonth => 'Expenses';

  @override
  String get today => 'Today';

  @override
  String get thisMonth => 'This Month';

  @override
  String get total => 'Total';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get accounts => 'Accounts';

  @override
  String get settings => 'Other Menu';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get seeAll => 'See All';

  @override
  String get transactionTitle => 'Transactions';

  @override
  String get transactionSubtitle => 'All financial activity';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get categories => 'Categories';

  @override
  String get accountsTitle => 'Accounts & Wallets';

  @override
  String accountsSubtitle(Object count) {
    return '$count active accounts';
  }

  @override
  String get addAccount => '+ Add Account';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get firstTransaction => 'Tap + to create your first';

  @override
  String get budgets => 'Budgets';

  @override
  String get goalsAndDebts => 'Goals & Debts';

  @override
  String get recurring => 'Recurring';

  @override
  String get statistics => 'Statistics';

  @override
  String get calendar => 'Financial Calendar';

  @override
  String get notes => 'Notes';

  @override
  String get searchTransactions => 'Search transactions or notes...';

  @override
  String get allFilter => 'All';

  @override
  String get categoryFilter => 'Category';

  @override
  String get accountFilter => 'Account';

  @override
  String get periodFilter => 'Period';

  @override
  String get todayTitle => 'Today';

  @override
  String get yesterdayTitle => 'Yesterday';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addTransactionSubtitle => 'Record quickly';

  @override
  String get close => 'Close';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String get selectCategory => 'Select category';

  @override
  String get selectAccount => 'Select account';

  @override
  String get transferInfo => 'Transfer between accounts';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get requiredField => 'Required';

  @override
  String get amountMustBePositive => 'Amount must be greater than 0';

  @override
  String get accountsMustDiffer =>
      'Source and destination accounts must differ';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String budgetsSubtitle(Object monthYear) {
    return '$monthYear';
  }

  @override
  String get addBudget => '+ Create';

  @override
  String get totalBudgetRemaining => 'Total Budget Remaining';

  @override
  String spent(Object spent, Object total) {
    return '$spent of $total';
  }

  @override
  String get perCategory => 'Per Category';

  @override
  String budgetCount(Object count) {
    return '$count budgets';
  }

  @override
  String get attention => 'Needs Attention';

  @override
  String get overLimit => 'Over Limit';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get goalsAndDebtsTitle => 'Goals & Debts';

  @override
  String get financialPlan => 'Financial Plan';

  @override
  String get addTarget => '+ Add';

  @override
  String get savingsTarget => 'Savings Goals';

  @override
  String get debts => 'Debts';

  @override
  String get priority => 'PRIORITY';

  @override
  String ofTarget(Object current, Object target) {
    return '$current of $target';
  }

  @override
  String progress(Object percent) {
    return '$percent% achieved';
  }

  @override
  String targetDeadline(Object date) {
    return 'DEADLINE $date';
  }

  @override
  String get debtSummary => 'Debt Summary';

  @override
  String get totalDebtRemaining => 'Total Debt Remaining';

  @override
  String installment(Object paid, Object total) {
    return '$paid of $total';
  }

  @override
  String dueDate(Object date) {
    return 'Due $date';
  }

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get recurringTitle => 'Recurring Transactions';

  @override
  String get recurringSubtitle => 'Automatic and scheduled';

  @override
  String get nextMonthProjection => 'Next Month Projection';

  @override
  String expenseCount(Object count) {
    return '$count expenses';
  }

  @override
  String incomeCount(Object count) {
    return '$count incomes';
  }

  @override
  String get comingSoon => 'Coming Up';

  @override
  String daysLeft(Object count) {
    return '$count days left';
  }

  @override
  String everyDate(Object day) {
    return 'Every $day';
  }

  @override
  String get recurringAdd => 'New Recurring Transaction';

  @override
  String get editRecurring => 'Edit Recurring Transaction';

  @override
  String get frequency => 'Frequency';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsSubtitle => 'Your financial insights';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get totalLabel => 'Total';

  @override
  String get changeVsLastMonth => 'Change vs last month';

  @override
  String get decrease => '↓';

  @override
  String get increase => '↑';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get highestDay => 'Highest Day';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get viewDetail => 'View Detail';

  @override
  String get noData => 'No data yet';

  @override
  String get calendarTitle => 'Financial Calendar';

  @override
  String calendarSubtitle(Object monthYear) {
    return '$monthYear';
  }

  @override
  String get todayButton => 'Today';

  @override
  String transactionCount(Object count) {
    return '$count transactions';
  }

  @override
  String get entries => 'In';

  @override
  String get exits => 'Out';

  @override
  String get othersTitle => 'Other';

  @override
  String get othersSubtitle => 'Settings & features';

  @override
  String get profileName => 'Money Manager';

  @override
  String get profileSubtitle => 'Personal Finance Tracker';

  @override
  String get financialManagement => 'Financial Management';

  @override
  String categoriesCount(Object count) {
    return '$count categories';
  }

  @override
  String notesSaved(Object count) {
    return '$count notes saved';
  }

  @override
  String activeRecurring(Object count) {
    return '$count active transactions';
  }

  @override
  String budgetsGoalsCount(Object budgets, Object goals) {
    return '$budgets budgets • $goals goals';
  }

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get preferences => 'Preferences';

  @override
  String get currency => 'Currency';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsActive => 'Reminders active';

  @override
  String get notificationsInactive => 'Reminders inactive';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsExplanation =>
      'Reminders help you never miss bills and control your budget';

  @override
  String get notificationPermissionAllowed => 'Allowed';

  @override
  String get notificationPermissionDenied => 'Denied';

  @override
  String get notificationOpenSystemSettings => 'Open system settings';

  @override
  String get notificationTypeRecurring => 'Bills & recurring transactions';

  @override
  String get notificationTypeRecurringDesc =>
      'Reminder H-0, H-1, H-3 before due date';

  @override
  String get notificationTypeDebt => 'Debt/installment due date';

  @override
  String get notificationTypeDebtDesc =>
      'Reminder H-0, H-1, H-3 before due date';

  @override
  String get notificationTypeBudget => 'Budget alerts';

  @override
  String get notificationTypeBudgetDesc =>
      'Notification when budget reaches 80% and 100%';

  @override
  String get notificationTypeDailyReminder => 'Daily transaction reminder';

  @override
  String get notificationTypeDailyReminderDesc =>
      'Daily reminder, skipped if transactions already recorded';

  @override
  String get notificationTypeBackupStatus => 'Backup status';

  @override
  String get notificationTypeBackupStatusDesc =>
      'Notification if backup fails multiple times consecutively';

  @override
  String get notificationTestButton => 'Send test notification';

  @override
  String get notificationTestSent => 'Test notification sent';

  @override
  String notificationActiveCount(Object count) {
    return '$count reminders active';
  }

  @override
  String get view => 'Appearance';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get securityPriv => 'Security & privacy';

  @override
  String get pinActive => 'PIN and biometrics active';

  @override
  String get pinInactive => 'PIN and biometrics inactive';

  @override
  String get aboutApp => 'About App';

  @override
  String get followSystem => 'Follow System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get english => 'English';

  @override
  String get signInOut => 'Sign in with Google';

  @override
  String get signOut => 'Sign Out';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get backupNow => 'Backup Now';

  @override
  String lastBackup(Object date) {
    return 'Last backup: $date';
  }

  @override
  String get manageBackups => 'Manage Backups';

  @override
  String get deleteBackup => 'Delete Backup';

  @override
  String get exportLocal => 'Export to File';

  @override
  String get importLocal => 'Import from File';

  @override
  String get autoBackup => 'Auto-backup';

  @override
  String get wifiOnly => 'Wi-Fi only';

  @override
  String get encryptBackup => 'Encrypt with password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get lostPasswordWarning => 'Lost password = backup cannot be restored';

  @override
  String get restore => 'Restore';

  @override
  String get restoreConfirm => 'Restore data from this backup?';

  @override
  String get restoreWarning => 'Current data will be replaced.';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get copyInfo => 'Long press to copy';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get contact => 'Contact Us';

  @override
  String get rateApp => 'Rate This App';

  @override
  String get shareApp => 'Share App';

  @override
  String get madeWith => 'Made with';

  @override
  String allRightsReserved(Object year) {
    return 'All rights reserved. $year';
  }

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get enableBiometrics => 'Enable Biometrics';

  @override
  String get biometricsActive => 'Biometrics active';

  @override
  String get biometricsInactive => 'Biometrics inactive';

  @override
  String get pinMismatch => 'PIN does not match';

  @override
  String pinLength(Object length) {
    return 'PIN must be $length digits';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Are you sure you want to delete?';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get name => 'Name';

  @override
  String get balance => 'Balance';

  @override
  String get description => 'Description';

  @override
  String get optional => 'Optional';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get search => 'Search';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get filterCalendar => 'Calendar';

  @override
  String get monthYear => 'Month & Year';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get thisWeek => 'This Week';

  @override
  String get debtTypeBorrowed => 'Debt';

  @override
  String get debtTypeLent => 'Receivable';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get nextDate => 'Next';

  @override
  String get manage => 'Manage';

  @override
  String get accountTypeCredit => 'Credit Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get other => 'Other';

  @override
  String get accountList => 'Account List';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get totalNetBalance => 'Total Net Balance';

  @override
  String lastUpdatedAgo(Object minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get firstNote => 'Create first note';

  @override
  String get addAccountButton => '+ Add account';

  @override
  String get transferBalance => 'Transfer';

  @override
  String notesCount(Object count) {
    return '$count notes saved';
  }

  @override
  String get accountTypeWallet => 'Wallet';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeInvestment => 'Investment';

  @override
  String get changelog => 'What\'s New';

  @override
  String get donation => 'Support the Developer';

  @override
  String developerCredits(Object name) {
    return 'Developed by $name';
  }

  @override
  String get noChangelog => 'No changelog available yet.';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get editTransactionSubtitle => 'Update transaction data';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get confirmDelete => 'Delete this transaction?';

  @override
  String get transactionUpdated => 'Transaction updated successfully';

  @override
  String get transactionDeleted => 'Transaction deleted successfully';

  @override
  String get transactionSaveError => 'Failed to save transaction';

  @override
  String get analytics => 'Analytics';

  @override
  String get reset => 'Reset';

  @override
  String get expensePerCategory => 'Expense per category';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get filterTransactions => 'Filter Transactions';

  @override
  String get type => 'Type';

  @override
  String get thisWeekShort => 'This week';

  @override
  String get thisMonthShort => 'This month';

  @override
  String get applyFilter => 'Apply filter';

  @override
  String get transactionAmount => 'Transaction amount';

  @override
  String get addNoteHint => 'Add transaction note';

  @override
  String get editAfterSave => 'You can still edit after saving';

  @override
  String get addNewAccount => 'Add new account';

  @override
  String get selectAccountAndAmount =>
      'Select an account and enter a valid amount';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String get activeAccounts => 'Active Accounts';

  @override
  String get archivedAccounts => 'Archived';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get adjustBalance => 'Adjust Balance';

  @override
  String get archiveAccount => 'Archive';

  @override
  String get activateAccount => 'Reactivate';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String accountHasTransactions(Object count) {
    return 'This account has $count transactions. Use \"Archive\" to hide it.';
  }

  @override
  String deleteAccountConfirm(Object name) {
    return 'Account \"$name\" will be permanently deleted.';
  }

  @override
  String get balanceTarget => 'Target balance';

  @override
  String get adjustmentNote => 'This will create an adjustment transaction.';

  @override
  String get apply => 'Apply';

  @override
  String get balanceAdjusted => 'Balance adjusted';

  @override
  String get balanceAdjustmentDesc => 'Balance adjustment';

  @override
  String get addAccountTitle => 'Add Account';

  @override
  String get accountNameLabel => 'ACCOUNT NAME';

  @override
  String get accountNameHint => 'e.g. BCA Main';

  @override
  String get accountTypeLabel => 'ACCOUNT TYPE';

  @override
  String get currencyLabel => 'CURRENCY';

  @override
  String get initialBalanceLabel => 'INITIAL BALANCE';

  @override
  String get noteLabel => 'NOTE';

  @override
  String get saveAccount => 'Save Account';

  @override
  String get accountNameRequired => 'Enter account name';

  @override
  String get addTransferTitle => 'Add Transfer';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get selectFromAccount => 'Select source account';

  @override
  String get selectToAccount => 'Select destination account';

  @override
  String get nominalLabel => 'AMOUNT';

  @override
  String get exchangeRateLabel => 'EXCHANGE RATE';

  @override
  String get descriptionLabel => 'DESCRIPTION';

  @override
  String get saveTransfer => 'Save Transfer';

  @override
  String get fillAmountAndSelectAccounts =>
      'Enter amount and select both accounts';

  @override
  String get accountsMustBeDifferent =>
      'Source and destination accounts must be different';

  @override
  String get appSettingsSubtitle => 'App settings & data';

  @override
  String get theme => 'Theme';

  @override
  String get otherFeatures => 'Other Features';

  @override
  String get budgetsAndGoals => 'Budgets & Goals';

  @override
  String get defaultCurrencyName => 'Indonesian Rupiah (IDR)';

  @override
  String get baseCurrency => 'Base currency';

  @override
  String get refreshRates => 'Refresh rates';

  @override
  String get dataAndSecurity => 'Data & security';

  @override
  String get securitySubtitle => 'PIN, biometrics, and account access';

  @override
  String get helpAndInfo => 'Help & information';

  @override
  String get themeUppercase => 'THEME';

  @override
  String get languageUppercase => 'LANGUAGE';

  @override
  String get backupAvailablePlatform => 'Backup available on Android/iOS';

  @override
  String get backupRetention => 'Backup retention';

  @override
  String get maxBackups => 'Max backups';

  @override
  String get maxBackupsDesc => 'Oldest automatic backups are deleted first';

  @override
  String get noBackupYet => 'No backups yet';

  @override
  String get noChangesSkipBackup => 'No changes, skipping backup.';

  @override
  String get backupSuccessNoUpload =>
      'Backup successful (not uploaded — TODO Drive)';

  @override
  String get restoreWillReplace =>
      'Restore will replace current data. A safety snapshot will be created.';

  @override
  String get restoreSuccessDrive =>
      'Restore successful (TODO: implement Drive download)';

  @override
  String get interval => 'Interval';

  @override
  String get backupSuccessful => 'Successful';

  @override
  String get categoryDefaultFoodDrink => 'Food & Drink';

  @override
  String get categoryDefaultTransport => 'Transport';

  @override
  String get categoryDefaultShopping => 'Shopping';

  @override
  String get categoryDefaultHousing => 'Housing & Rent';

  @override
  String get categoryDefaultUtilities => 'Bills & Utilities';

  @override
  String get categoryDefaultHealth => 'Health';

  @override
  String get categoryDefaultEducation => 'Education';

  @override
  String get categoryDefaultEntertainment => 'Entertainment';

  @override
  String get categoryDefaultVacation => 'Vacation';

  @override
  String get categoryDefaultFamily => 'Family & Kids';

  @override
  String get categoryDefaultPersonalCare => 'Personal Care';

  @override
  String get categoryDefaultGifts => 'Gifts & Donations';

  @override
  String get categoryDefaultDebtPayment => 'Installments & Debt';

  @override
  String get categoryDefaultInsurance => 'Insurance';

  @override
  String get categoryDefaultSubscriptions => 'Subscriptions';

  @override
  String get categoryDefaultOtherExpense => 'Other';

  @override
  String get categoryDefaultSalary => 'Salary';

  @override
  String get categoryDefaultBonus => 'Bonus';

  @override
  String get categoryDefaultBusiness => 'Business';

  @override
  String get categoryDefaultInvestment => 'Investment';

  @override
  String get categoryDefaultGift => 'Gift';

  @override
  String get categoryDefaultSale => 'Sales';

  @override
  String get categoryDefaultRefund => 'Refunds';

  @override
  String get categoryDefaultOtherIncome => 'Other';

  @override
  String get categoryDefaultBalanceAdjustment => 'Balance Adjustment';

  @override
  String get categoryDefaultTransfer => 'Transfer';
}
