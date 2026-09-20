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
  String get settings => 'Settings';

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
  String get noBudgets => 'No budgets set';

  @override
  String get targetAndDebtsTitle => 'Target & Hutang';

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
  String changeVsLastMonth(Object lastMonth, Object percent) {
    return '$percent% vs $lastMonth';
  }

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
  String get noData => 'No data available';

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
  String get othersTitle => 'Settings';

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
  String monthYear(Object month, Object year) {
    return '$month $year';
  }
}
