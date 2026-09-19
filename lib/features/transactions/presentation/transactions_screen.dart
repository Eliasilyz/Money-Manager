import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calendar State
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  // Monthly View State
  DateTime _monthlyMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Note Search State
  final TextEditingController _noteSearchController = TextEditingController();
  String _noteSearchQuery = '';

  // Stats State
  String _statsType = 'expense'; // 'expense' or 'income'
  String _statsPeriod = 'monthly'; // 'weekly', 'monthly', 'annually', 'custom'
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteSearchController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);

    final categories = categoriesAsync.valueOrNull ?? [];
    final accounts = accountsAsync.valueOrNull ?? [];
    final catMap = {for (final c in categories) c.id: c};
    final accMap = {for (final a in accounts) a.id: a};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaksi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: const [
            Tab(text: 'Harian'),
            Tab(text: 'Bulanan'),
            Tab(text: 'Total'),
            Tab(text: 'Kalender'),
            Tab(text: 'Catatan'),
            Tab(text: 'Statistik'),
          ],
        ),
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (allTransactions) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDailyView(allTransactions, catMap, accMap),
                _buildMonthlyView(allTransactions, catMap, accMap),
                _buildTotalView(allTransactions, catMap, accMap),
                _buildCalendarView(allTransactions, catMap, accMap),
                _buildNoteView(allTransactions, catMap, accMap),
                _buildStatsView(allTransactions, catMap),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: GoogleFonts.inter(color: AppColors.rose),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==========================================
  // 1. HARIAN (DAILY VIEW)
  // ==========================================
  Widget _buildDailyView(
    List<Transaction> transactions,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState('Belum ada transaksi');
    }

    // Group transactions by Date (YYYY-MM-DD)
    final grouped = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final txList = grouped[dateKey]!;
        final firstDate = txList.first.date;

        final dayIncome = txList
            .where((t) => t.type == 'income')
            .fold<int>(0, (sum, t) => sum + t.amount);
        final dayExpense = txList
            .where((t) => t.type == 'expense')
            .fold<int>(0, (sum, t) => sum + t.amount);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('d').format(firstDate),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE', 'id_ID').format(firstDate),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat('MMM yyyy', 'id_ID').format(firstDate),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textDim,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (dayIncome > 0) ...[
                          Text(
                            '+${_formatCurrency(dayIncome)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (dayExpense > 0)
                          Text(
                            '-${_formatCurrency(dayExpense)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.rose,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Transaction Items
              ...txList.map((tx) => _buildTransactionItem(tx, catMap, accMap)),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 2. BULANAN (MONTHLY VIEW)
  // ==========================================
  Widget _buildMonthlyView(
    List<Transaction> allTransactions,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    // Filter transactions for selected month
    final monthTx = allTransactions.where((t) {
      return t.date.year == _monthlyMonth.year &&
          t.date.month == _monthlyMonth.month;
    }).toList();

    final totalIncome = monthTx
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpense = monthTx
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    // Group by Day in this month
    final grouped = <String, List<Transaction>>{};
    for (final tx in monthTx) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Month Selector Header
        _buildMonthNavigator(
          current: _monthlyMonth,
          onPrev: () {
            setState(() {
              _monthlyMonth = DateTime(_monthlyMonth.year, _monthlyMonth.month - 1);
            });
          },
          onNext: () {
            setState(() {
              _monthlyMonth = DateTime(_monthlyMonth.year, _monthlyMonth.month + 1);
            });
          },
        ),
        const SizedBox(height: 14),

        // Monthly Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryMetric(
                      'Pemasukan',
                      '+${_formatCurrency(totalIncome)}',
                      AppColors.teal,
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Pengeluaran',
                      '-${_formatCurrency(totalExpense)}',
                      AppColors.rose,
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Bersih',
                      _formatCurrency(netBalance),
                      netBalance >= 0 ? AppColors.gold : AppColors.rose,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (monthTx.isEmpty)
          _buildEmptyState('Tidak ada transaksi di bulan ini')
        else
          ...sortedKeys.map((key) {
            final txList = grouped[key]!;
            final firstDate = txList.first.date;
            final dayIncome = txList
                .where((t) => t.type == 'income')
                .fold<int>(0, (sum, t) => sum + t.amount);
            final dayExpense = txList
                .where((t) => t.type == 'expense')
                .fold<int>(0, (sum, t) => sum + t.amount);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM', 'id_ID').format(firstDate),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Row(
                          children: [
                            if (dayIncome > 0)
                              Text(
                                '+${_formatCurrency(dayIncome)} ',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppColors.teal,
                                ),
                              ),
                            if (dayExpense > 0)
                              Text(
                                '-${_formatCurrency(dayExpense)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppColors.rose,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ...txList.map((tx) => _buildTransactionItem(tx, catMap, accMap)),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // 3. TOTAL VIEW (RINGKASAN TOTAL)
  // ==========================================
  Widget _buildTotalView(
    List<Transaction> transactions,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    // Category Expense Ranking
    final catExpenseMap = <String, int>{};
    for (final t in transactions.where((t) => t.type == 'expense')) {
      final name = t.categoryId != null ? catMap[t.categoryId]?.name ?? 'Lainnya' : 'Tanpa Kategori';
      catExpenseMap[name] = (catExpenseMap[name] ?? 0) + t.amount;
    }
    final sortedCatExpense = catExpenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Category Income Ranking
    final catIncomeMap = <String, int>{};
    for (final t in transactions.where((t) => t.type == 'income')) {
      final name = t.categoryId != null ? catMap[t.categoryId]?.name ?? 'Lainnya' : 'Tanpa Kategori';
      catIncomeMap[name] = (catIncomeMap[name] ?? 0) + t.amount;
    }
    final sortedCatIncome = catIncomeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Overall Net Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF141D3A), Color(0xFF0F1630)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SALDO KESELURUHAN (TOTAL)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(netBalance),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: netBalance >= 0 ? AppColors.gold : AppColors.rose,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryMetric(
                      'Total Masuk',
                      '+${_formatCurrency(totalIncome)}',
                      AppColors.teal,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Total Keluar',
                      '-${_formatCurrency(totalExpense)}',
                      AppColors.rose,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Jumlah Tx',
                      '${transactions.length} item',
                      AppColors.sky,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Top Expenses
        Text(
          'TOP PENGELUARAN PER KATEGORI',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (sortedCatExpense.isEmpty)
          _buildCardMessage('Belum ada data pengeluaran')
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: sortedCatExpense.take(5).map((e) {
                final pct = totalExpense > 0 ? (e.value / totalExpense) : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '-${_formatCurrency(e.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.rose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.card2,
                        valueColor: const AlwaysStoppedAnimation(AppColors.rose),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 20),

        // Top Incomes
        Text(
          'TOP PEMASUKAN PER KATEGORI',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (sortedCatIncome.isEmpty)
          _buildCardMessage('Belum ada data pemasukan')
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: sortedCatIncome.take(5).map((e) {
                final pct = totalIncome > 0 ? (e.value / totalIncome) : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '+${_formatCurrency(e.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.card2,
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // 4. KALENDER (CALENDAR VIEW)
  // ==========================================
  Widget _buildCalendarView(
    List<Transaction> allTransactions,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 1=Monday, 7=Sunday
    final startWeekday = firstDayOfMonth.weekday;

    // Filter transactions for selected day
    final selectedDayTx = allTransactions.where((t) {
      return t.date.year == _selectedDate.year &&
          t.date.month == _selectedDate.month &&
          t.date.day == _selectedDate.day;
    }).toList();

    // Map of days with transaction badges
    final dayActivity = <int, ({bool hasIncome, bool hasExpense, int income, int expense})>{};
    for (final t in allTransactions) {
      if (t.date.year == year && t.date.month == month) {
        final d = t.date.day;
        final current = dayActivity[d] ??
            (hasIncome: false, hasExpense: false, income: 0, expense: 0);
        if (t.type == 'income') {
          dayActivity[d] = (
            hasIncome: true,
            hasExpense: current.hasExpense,
            income: current.income + t.amount,
            expense: current.expense,
          );
        } else if (t.type == 'expense') {
          dayActivity[d] = (
            hasIncome: current.hasIncome,
            hasExpense: true,
            income: current.income,
            expense: current.expense + t.amount,
          );
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Month Switcher
        _buildMonthNavigator(
          current: _calendarMonth,
          onPrev: () {
            setState(() {
              _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
            });
          },
          onNext: () {
            setState(() {
              _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
            });
          },
        ),
        const SizedBox(height: 12),

        // Calendar Grid Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Weekday Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map((d) => SizedBox(
                          width: 38,
                          child: Center(
                            child: Text(
                              d,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: d == 'Min' ? AppColors.rose : AppColors.textDim,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 8),

              // Calendar Days
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.9,
                ),
                itemCount: (startWeekday - 1) + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < startWeekday - 1) {
                    return const SizedBox.shrink();
                  }
                  final dayNumber = index - (startWeekday - 1) + 1;
                  final isSelected = _selectedDate.year == year &&
                      _selectedDate.month == month &&
                      _selectedDate.day == dayNumber;
                  final isToday = DateTime.now().year == year &&
                      DateTime.now().month == month &&
                      DateTime.now().day == dayNumber;

                  final activity = dayActivity[dayNumber];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(year, month, dayNumber);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.2)
                            : isToday
                                ? AppColors.card2
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : isToday
                                  ? AppColors.border
                                  : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (activity?.hasIncome == true)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.teal,
                                  ),
                                ),
                              if (activity?.hasExpense == true)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.rose,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selected Date Transactions List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '${selectedDayTx.length} transaksi',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDim),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (selectedDayTx.isEmpty)
          _buildCardMessage('Tidak ada transaksi pada tanggal ini')
        else
          ...selectedDayTx.map((tx) => _buildTransactionItem(tx, catMap, accMap)),
      ],
    );
  }

  // ==========================================
  // 5. CATATAN (NOTES VIEW)
  // ==========================================
  Widget _buildNoteView(
    List<Transaction> transactions,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    // Filter transactions that have notes or match query
    final noteTxList = transactions.where((t) {
      final hasContent = (t.note != null && t.note!.trim().isNotEmpty) ||
          (t.description != null && t.description!.trim().isNotEmpty);
      if (!hasContent) return false;

      if (_noteSearchQuery.isEmpty) return true;

      final query = _noteSearchQuery.toLowerCase();
      final matchNote = t.note?.toLowerCase().contains(query) ?? false;
      final matchDesc = t.description?.toLowerCase().contains(query) ?? false;
      final cat = t.categoryId != null ? catMap[t.categoryId]?.name.toLowerCase() ?? '' : '';
      final matchCat = cat.contains(query);

      return matchNote || matchDesc || matchCat;
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _noteSearchController,
            onChanged: (val) {
              setState(() {
                _noteSearchQuery = val.trim();
              });
            },
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari catatan, deskripsi, atau memo...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textDim, size: 20),
              suffixIcon: _noteSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textDim, size: 18),
                      onPressed: () {
                        _noteSearchController.clear();
                        setState(() => _noteSearchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        Expanded(
          child: noteTxList.isEmpty
              ? _buildEmptyState(
                  _noteSearchQuery.isEmpty
                      ? 'Belum ada transaksi dengan catatan'
                      : 'Catatan tidak ditemukan',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: noteTxList.length,
                  itemBuilder: (context, index) {
                    final tx = noteTxList[index];
                    final isIncome = tx.type == 'income';
                    final color = isIncome ? AppColors.teal : AppColors.rose;
                    final cat = tx.categoryId != null ? catMap[tx.categoryId] : null;
                    final acc = accMap[tx.accountId];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cat?.name ?? (isIncome ? 'Pemasukan' : 'Pengeluaran'),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  if (acc != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${acc.name}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.textDim,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${isIncome ? '+' : '-'}${_formatCurrency(tx.amount)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (tx.description != null && tx.description!.isNotEmpty)
                            Text(
                              tx.description!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          if (tx.note != null && tx.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              tx.note!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textDim),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(tx.date),
                                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // 6. STATISTIK (STATS VIEW)
  // ==========================================
  Widget _buildStatsView(
    List<Transaction> allTransactions,
    Map<String, Category> catMap,
  ) {
    final now = DateTime.now();

    // Determine start and end date based on period
    DateTime start;
    DateTime end = now;

    switch (_statsPeriod) {
      case 'weekly':
        // Start from beginning of current week (Monday)
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'annually':
        start = DateTime(now.year, 1, 1);
        break;
      case 'custom':
        if (_customDateRange != null) {
          start = _customDateRange!.start;
          end = _customDateRange!.end;
        } else {
          start = DateTime(now.year, now.month, 1);
        }
        break;
      case 'monthly':
      default:
        start = DateTime(now.year, now.month, 1);
        break;
    }

    // Filter transactions in range
    final filtered = allTransactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    // Split by type
    final targetTx = filtered.where((t) => t.type == _statsType).toList();
    final totalAmount = targetTx.fold<int>(0, (sum, t) => sum + t.amount);

    final totalIncomeAll = filtered
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpenseAll = filtered
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);

    // Group by category
    final catTotals = <String, int>{};
    for (final t in targetTx) {
      final name = t.categoryId != null ? catMap[t.categoryId]?.name ?? 'Lainnya' : 'Tanpa Kategori';
      catTotals[name] = (catTotals[name] ?? 0) + t.amount;
    }
    final sortedCats = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final chartColors = [
      AppColors.gold,
      AppColors.rose,
      AppColors.sky,
      AppColors.lilac,
      AppColors.orange,
      AppColors.teal,
      const Color(0xFF38BDF8),
      const Color(0xFFF472B6),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // Type Selector: Outcome vs Income
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statsType = 'expense'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _statsType == 'expense' ? AppColors.rose : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Pengeluaran',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statsType == 'expense' ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statsType = 'income'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _statsType == 'income' ? AppColors.teal : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Pemasukan',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statsType == 'income' ? AppColors.bg : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Period Filters: Weekly, Monthly, Annually, Period (Custom)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPeriodChip('Mingguan', 'weekly'),
              _buildPeriodChip('Bulanan', 'monthly'),
              _buildPeriodChip('Tahunan', 'annually'),
              _buildCustomPeriodChip(),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Date Range Label
        Text(
          'Periode: ${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDim),
        ),
        const SizedBox(height: 8),

        // Total for this category type
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statsType == 'expense' ? 'TOTAL PENGELUARAN' : 'TOTAL PEMASUKAN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(totalAmount),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _statsType == 'expense' ? AppColors.rose : AppColors.teal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Selisih Bersih',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim),
                  ),
                  Text(
                    _formatCurrency(totalIncomeAll - totalExpenseAll),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (totalIncomeAll - totalExpenseAll) >= 0 ? AppColors.teal : AppColors.rose,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Donut Chart & Legend
        if (sortedCats.isNotEmpty && totalAmount > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSENTASE KATEGORI',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 170,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: sortedCats.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final val = entry.value.value;
                              final pct = val / totalAmount;
                              return PieChartSectionData(
                                value: val.toDouble(),
                                color: chartColors[idx % chartColors.length],
                                title: pct > 0.05 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
                                titleStyle: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 26,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: sortedCats.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final cat = entry.value;
                              final pct = (cat.value / totalAmount) * 100;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: chartColors[idx % chartColors.length],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        cat.key,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${pct.toStringAsFixed(1)}%',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detailed Category Breakdown Bars
          Text(
            'RINCIAN KATEGORI',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: sortedCats.asMap().entries.map((entry) {
                final idx = entry.key;
                final cat = entry.value;
                final pct = (cat.value / totalAmount);
                final color = chartColors[idx % chartColors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat.key,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _formatCurrency(cat.value),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statsType == 'expense' ? AppColors.rose : AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.card2,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ] else
          _buildCardMessage('Tidak ada data ${_statsType == 'expense' ? 'pengeluaran' : 'pemasukan'} di periode ini'),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final selected = _statsPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _statsPeriod = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.bg : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPeriodChip() {
    final selected = _statsPeriod == 'custom';
    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _customDateRange ??
              DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 30)),
                end: DateTime.now(),
              ),
        );
        if (picked != null) {
          setState(() {
            _customDateRange = picked;
            _statsPeriod = 'custom';
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 14,
              color: selected ? AppColors.bg : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'Rentang',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.bg : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SHARED WIDGETS
  // ==========================================
  Widget _buildMonthNavigator({
    required DateTime current,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textMuted),
            onPressed: onPrev,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(current),
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    Transaction tx,
    Map<String, Category> catMap,
    Map<String, Account> accMap,
  ) {
    final isIncome = tx.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    final cat = tx.categoryId != null ? catMap[tx.categoryId] : null;
    final acc = accMap[tx.accountId];

    final title = (tx.description != null && tx.description!.isNotEmpty)
        ? tx.description!
        : (cat?.name ?? (isIncome ? 'Pemasukan' : 'Pengeluaran'));

    final subtitleParts = <String>[];
    if (cat != null && tx.description != null && tx.description!.isNotEmpty) {
      subtitleParts.add(cat.name);
    }
    if (acc != null) {
      subtitleParts.add(acc.name);
    }
    if (tx.note != null && tx.note!.isNotEmpty) {
      subtitleParts.add(tx.note!);
    }

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitleParts.isNotEmpty)
            Text(
              subtitleParts.join(' • '),
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Text(
            DateFormat('HH:mm').format(tx.date),
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textDim),
          ),
        ],
      ),
      trailing: Text(
        '$sign${_formatCurrency(tx.amount)}',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi?'),
            content: const Text('Transaksi ini akan dihapus permanen.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Hapus', style: GoogleFonts.inter(color: AppColors.rose)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          ref.read(transactionsNotifierProvider.notifier).deleteTransaction(tx.id);
        }
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧾', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(color: AppColors.textDim, fontSize: 12),
        ),
      ),
    );
  }
}
