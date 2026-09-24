import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  bool _showAnalytics = false;
  bool _showCalendar = false;
  DateTime _calMonth = DateTime.now();

  // Filter state
  String _filterType = 'all'; // all / expense / income
  List<String> _selectedCategories = [];
  String _datePeriod = 'all'; // all / today / week / month

  final _searchCtrl = TextEditingController();
  late NumberFormat _fmt;
  String _baseCode = 'IDR';
  Map<String, double> _rates = const {};

  int _toBase(Transaction t) =>
      convertAmount(t.amount, t.currencyCode, _baseCode, _rates).round();

  static const _catColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF10B981),
    'kesehatan': Color(0xFFEF4444),
    'pendidikan': Color(0xFF0EA5E9),
    'gaji': Color(0xFF1B6E4B),
    'investasi': Color(0xFF3B82F6),
    'lainnya': Color(0xFF9CA3AF),
  };

  static const _fallbackColors = [
    Color(0xFF1B6E4B), Color(0xFF3B82F6), Color(0xFFF59E0B),
    Color(0xFFE0524A), Color(0xFF8B5CF6), Color(0xFF10B981),
    Color(0xFFEF4444), Color(0xFF0EA5E9),
  ];

  Color _getCatColor(String name, int index) {
    final key = name.toLowerCase();
    for (final entry in _catColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _fallbackColors[index % _fallbackColors.length];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    _fmt = NumberFormat.currency(symbol: '${currencySymbol(baseCode)} ', decimalDigits: currencyDigits(baseCode));
    _baseCode = baseCode;
    _rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? const <String, Category>{};

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.transactionTitle, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  Text(l10n.transactionSubtitle, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: l10n.searchTransactions,
                  prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () => _showFilterSheet(context, colors, l10n),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _hasActiveFilters ? colors.primary.withValues(alpha: 0.1) : colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _hasActiveFilters ? colors.primary : colors.border),
                      ),
                      child: Icon(Icons.tune_rounded, size: 18, color: _hasActiveFilters ? colors.primary : colors.textSecondary),
                    ),
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.primary, width: 1.5)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildActionChip(
                    icon: Icons.pie_chart_outline,
                    label: l10n.analytics,
                    isActive: _showAnalytics,
                    onTap: () => setState(() {
                      _showAnalytics = !_showAnalytics;
                      if (_showAnalytics) _showCalendar = false;
                    }),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildActionChip(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.calendar,
                    isActive: _showCalendar,
                    onTap: () => setState(() {
                      _showCalendar = !_showCalendar;
                      if (_showCalendar) _showAnalytics = false;
                    }),
                    colors: colors,
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        _filterType = 'all';
                        _selectedCategories = [];
                        _datePeriod = 'all';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 14, color: AppColors.rose),
                            const SizedBox(width: 4),
                            Text(l10n.reset, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.rose)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: transactionsAsync.when(
                data: (allTx) {
                  final filtered = _filterTransactions(allTx, l10n, catMap);
                  if (_showAnalytics) {
                    return _buildAnalytics(filtered, catMap, colors, l10n);
                  }
                  if (_showCalendar) {
                    return _buildCalendarView(filtered, catMap, colors, locale);
                  }
                  if (filtered.isEmpty) return _buildEmpty(colors, l10n);
                  return _buildGroupedList(filtered, catMap, colors, locale, l10n);
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool get _hasActiveFilters => _filterType != 'all' || _selectedCategories.isNotEmpty || _datePeriod != 'all';

  Widget _buildActionChip({required IconData icon, required String label, required bool isActive, required VoidCallback onTap, required AppColorsT colors}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? colors.primary : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : colors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ─── Filter bottom sheet ───

  void _showFilterSheet(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _FilterSheet(
        filterType: _filterType,
        selectedCategories: _selectedCategories,
        datePeriod: _datePeriod,
        colors: colors,
        l10n: l10n,
        onApply: (type, cats, period) {
          setState(() {
            _filterType = type;
            _selectedCategories = cats;
            _datePeriod = period;
          });
        },
      ),
    );
  }

  // ─── Analytics view ───

  Widget _buildAnalytics(List<Transaction> txList, Map<String, Category> catMap, AppColorsT colors, AppLocalizations l10n) {
    final expenses = txList.where((t) => t.type == 'expense').toList();
    final income = txList.where((t) => t.type == 'income').toList();

    // Group by category
    final catTotals = <String, int>{};
    for (final t in expenses) {
      final cat = catMap[t.categoryId];
      final name = cat == null ? l10n.other : localizedCategoryName(l10n, cat.systemKey, cat.name);
      catTotals[name] = (catTotals[name] ?? 0) + _toBase(t);
    }

    final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalExpense = expenses.fold<int>(0, (s, t) => s + _toBase(t));
    final totalIncome = income.fold<int>(0, (s, t) => s + _toBase(t));
    final balance = totalIncome - totalExpense;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Summary cards
        Row(
          children: [
          _summaryCard(l10n.expense, totalExpense, AppColors.rose, colors),
          const SizedBox(width: 12),
          _summaryCard(l10n.income, totalIncome, AppColors.teal, colors),
          ],
        ),
        const SizedBox(height: 16),
        // Pie chart + legend
        if (sortedCats.isNotEmpty) ...[
          Text(l10n.expensePerCategory, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 12),
          _buildPieChart(sortedCats, totalExpense, colors, l10n),
          const SizedBox(height: 16),
          // Category breakdown
          ...sortedCats.asMap().entries.map((e) {
            final catColor = _getCatColor(e.value.key, e.key);
            return _categoryTile(e.value.key, e.value.value, totalExpense, catColor, colors);
          }),
        ] else ...[
          _buildEmpty(colors, l10n),
        ],
        if (totalIncome > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sky.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.sky, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.netBalance, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        '${balance >= 0 ? '+' : '-'}${_fmt.format(balance.abs())} dari semua transaksi',
                        style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _summaryCard(String label, int amount, Color accent, AppColorsT colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text(_fmt.format(amount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, int>> sortedCats, int total, AppColorsT colors, AppLocalizations l10n) {
    final topItems = sortedCats.take(5).toList();
    final otherTotal = sortedCats.skip(5).fold<int>(0, (s, e) => s + e.value);
    final segments = <_PieSegment>[];
    for (final e in topItems) {
      segments.add(_PieSegment(value: e.value.toDouble(), color: _getCatColor(e.key, sortedCats.indexOf(e))));
    }
    if (otherTotal > 0) segments.add(_PieSegment(value: otherTotal.toDouble(), color: const Color(0xFF9CA3AF)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _PieChartPainter(segments: segments, total: total.toDouble()),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                ...topItems.asMap().entries.map((e) => _pieLegend(e.value.key, e.value.value, total, _getCatColor(e.value.key, e.key), colors)),
                if (otherTotal > 0) _pieLegend(l10n.other, otherTotal, total, const Color(0xFF9CA3AF), colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieLegend(String name, int amount, int total, Color color, AppColorsT colors) {
    final pct = total > 0 ? (amount / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 11, color: colors.textPrimary), overflow: TextOverflow.ellipsis)),
          Text('$pct%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _categoryTile(String name, int amount, int total, Color color, AppColorsT colors) {
    final pct = total > 0 ? (amount / total * 100).round() : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                ],
              ),
              Text(_fmt.format(amount), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (amount / total).clamp(0.0, 1.0),
                    backgroundColor: colors.border,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$pct%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Calendar view ───

  Widget _buildCalendarView(List<Transaction> allTx, Map<String, Category> catMap, AppColorsT colors, String locale) {
    final now = DateTime.now();
    final year = _calMonth.year;
    final month = _calMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startPad = (firstDay.weekday - 1) % 7; // Mon=0

    // Group tx by day
    final dayMap = <int, List<Transaction>>{};
    for (final t in allTx) {
      if (t.date.year == year && t.date.month == month) {
        dayMap.putIfAbsent(t.date.day, () => []).add(t);
      }
    }

    return Column(
      children: [
        // Month nav
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() => _calMonth = DateTime(year, month - 1)),
                icon: Icon(Icons.chevron_left, color: colors.textPrimary),
              ),
              Text(
                DateFormat('MMMM yyyy', locale).format(_calMonth),
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              IconButton(
                onPressed: () => setState(() => _calMonth = DateTime(year, month + 1)),
                icon: Icon(Icons.chevron_right, color: colors.textPrimary),
              ),
            ],
          ),
        ),
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((d) => Expanded(
              child: Center(child: Text(d, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary))),
            )).toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: startPad + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < startPad) return const SizedBox.shrink();
              final day = i - startPad + 1;
              final dayTx = dayMap[day] ?? [];
              final dayTotal = dayTx.fold<int>(0, (s, t) => s + (t.type == 'income' ? _toBase(t) : -_toBase(t)));
              final isToday = year == now.year && month == now.month && day == now.day;
              final hasTx = dayTx.isNotEmpty;

              return GestureDetector(
                onTap: hasTx ? () => _showDayDetail(day, dayTx, catMap, colors, locale) : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? colors.primary.withValues(alpha: 0.1) : (hasTx ? colors.surface : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday ? colors.primary : (hasTx ? colors.border : Colors.transparent),
                      width: isToday ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? colors.primary : colors.textPrimary,
                      )),
                      if (dayTotal != 0) ...[
                        const SizedBox(height: 1),
                        Text(
                          '${dayTotal > 0 ? '+' : '-'}',
                          style: GoogleFonts.inter(fontSize: 7, color: dayTotal > 0 ? AppColors.teal : AppColors.rose),
                        ),
                      ],
                      if (dayTx.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayDetail(int day, List<Transaction> dayTx, Map<String, Category> catMap, AppColorsT colors, String locale) {
    final dayDate = DateTime(_calMonth.year, _calMonth.month, day);
    final dayTotal = dayTx.fold<int>(0, (s, t) => s + (t.type == 'income' ? _toBase(t) : -_toBase(t)));
    final formattedTotal = '${dayTotal >= 0 ? '+' : '-'}${_fmt.format(dayTotal.abs())}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (sCtx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy', locale).format(dayDate),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                  Text(formattedTotal, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: dayTotal >= 0 ? AppColors.teal : AppColors.rose)),
                ],
              ),
              const SizedBox(height: 16),
              ...dayTx.map((t) => _buildTxTile(t, catMap, _fmt, colors)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Filtering ───

  List<Transaction> _filterTransactions(List<Transaction> all, AppLocalizations l10n, Map<String, Category> catMap) {
    var list = all;

    // Search
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) {
        final desc = (t.description ?? '').toLowerCase();
        final note = (t.note ?? '').toLowerCase();
        final cat = catMap[t.categoryId];
        final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name).toLowerCase();
        return desc.contains(_searchQuery) || note.contains(_searchQuery) || catName.contains(_searchQuery);
      }).toList();
    }

    // Type filter
    if (_filterType != 'all') {
      list = list.where((t) => t.type == _filterType).toList();
    }

    // Category filter
    if (_selectedCategories.isNotEmpty) {
      list = list.where((t) {
        final cat = catMap[t.categoryId];
        final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name);
        return _selectedCategories.contains(catName);
      }).toList();
    }

    // Date period filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_datePeriod) {
      case 'today':
        list = list.where((t) => t.date.isAfter(today.subtract(const Duration(days: 1)))).toList();
        break;
      case 'week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        list = list.where((t) => t.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
        break;
      case 'month':
        final monthStart = DateTime(now.year, now.month, 1);
        list = list.where((t) => t.date.isAfter(monthStart.subtract(const Duration(days: 1)))).toList();
        break;
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // ─── Grouped list ───

  Widget _buildGroupedList(List<Transaction> txList, Map<String, Category> catMap, AppColorsT colors, String locale, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<Transaction>>{};
    for (final t in txList) {
      final dayKey = '${t.date.year}-${t.date.month}-${t.date.day}';
      grouped.putIfAbsent(dayKey, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: grouped.entries.map((entry) {
        final dayTx = entry.value;
        final dayDate = dayTx.first.date;
        final dayOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
        final dayTotal = dayTx.fold<int>(0, (s, t) => s + (t.type == 'income' ? _toBase(t) : -_toBase(t)));
        final dayName = dayOnly == today ? l10n.todayTitle : dayOnly == yesterday ? l10n.yesterdayTitle : DateFormat('EEEE', locale).format(dayOnly);
        final formattedTotal = '${dayTotal >= 0 ? '+' : '-'}${_fmt.format(dayTotal.abs())}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dayName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text(formattedTotal, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: dayTotal >= 0 ? AppColors.teal : AppColors.rose)),
                ],
              ),
            ),
            ...dayTx.map((t) => _buildTxTile(t, catMap, _fmt, colors)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTxTile(Transaction t, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final isIncome = t.type == 'income';
    final cat = catMap[t.categoryId];
    final l10n = AppLocalizations.of(context);
    final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name);
    final sign = isIncome ? '+' : '-';
    final amountCode = t.currencyCode;
    final amountFmt = NumberFormat.currency(symbol: '${currencySymbol(amountCode)} ', decimalDigits: currencyDigits(amountCode));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TransactionTile(
        amount: '$sign${amountFmt.format(t.amount)}',
        isIncome: isIncome,
        date: t.date,
        categoryName: catName.isNotEmpty ? catName : null,
        note: t.note,
        description: t.description,
        isTransfer: t.transferId != null,
        onTap: () => _showTransactionDetail(t, catName, amountFmt, colors),
      ),
    );
  }

  // ─── Detail bottom sheet ───

  void _showTransactionDetail(Transaction t, String catName, NumberFormat fmt, AppColorsT colors) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isIncome = t.type == 'income';
    final sign = isIncome ? '+' : '-';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.transactionTitle, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: colors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$sign${fmt.format(t.amount)}',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: isIncome ? AppColors.teal : AppColors.rose),
            ),
            const SizedBox(height: 16),
            _detailRow(l10n.transactionType, isIncome ? l10n.income : l10n.expense, colors),
            if (catName.isNotEmpty) _detailRow(l10n.category, catName, colors),
            if (t.description != null && t.description!.isNotEmpty) _detailRow(l10n.description, t.description!, colors),
            if (t.note != null && t.note!.isNotEmpty) _detailRow(l10n.note, t.note!, colors),
            _detailRow(l10n.date, DateFormat('dd MMMM yyyy • HH:mm', locale).format(t.date), colors),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/add-transaction', extra: t);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.edit, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: Text(l10n.confirmDelete, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(l10n.cancel)),
                            FilledButton(
                              onPressed: () => Navigator.pop(dCtx, true),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        await ref.read(transactionsNotifierProvider.notifier).deleteTransaction(t.id);
                        ref.read(accountsNotifierProvider.notifier).loadAccounts();
                        ref.invalidate(dashboardProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.transactionDeleted, style: GoogleFonts.inter())),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n.delete, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, AppColorsT colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppColorsT colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
            child: const Icon(Icons.receipt_long_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(l10n.noTransactions, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ───

class _FilterSheet extends StatefulWidget {
  final String filterType;
  final List<String> selectedCategories;
  final String datePeriod;
  final AppColorsT colors;
  final AppLocalizations l10n;
  final void Function(String type, List<String> cats, String period) onApply;

  const _FilterSheet({
    required this.filterType,
    required this.selectedCategories,
    required this.datePeriod,
    required this.colors,
    required this.l10n,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _type;
  late List<String> _cats;
  late String _period;

  @override
  void initState() {
    super.initState();
    _type = widget.filterType;
    _cats = List.from(widget.selectedCategories);
    _period = widget.datePeriod;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = widget.l10n;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.filterTransactions, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                TextButton(
                  onPressed: () => setState(() {
                    _type = 'all';
                    _cats = [];
                    _period = 'all';
                  }),
                  child: Text(l10n.reset, style: GoogleFonts.inter(fontSize: 12, color: AppColors.rose)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Tipe ──
            Text(l10n.type, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                _filterChip(l10n.allFilter, _type == 'all', () => setState(() => _type = 'all'), colors),
                const SizedBox(width: 8),
                _filterChip(l10n.expense, _type == 'expense', () => setState(() => _type = 'expense'), colors),
                const SizedBox(width: 8),
                _filterChip(l10n.income, _type == 'income', () => setState(() => _type = 'income'), colors),
              ],
            ),
            const SizedBox(height: 20),

            // ── Periode ──
            Text(l10n.periodFilter, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip(l10n.allFilter, _period == 'all', () => setState(() => _period = 'all'), colors),
                _filterChip(l10n.todayTitle, _period == 'today', () => setState(() => _period = 'today'), colors),
                _filterChip(l10n.thisWeekShort, _period == 'week', () => setState(() => _period = 'week'), colors),
                _filterChip(l10n.thisMonthShort, _period == 'month', () => setState(() => _period = 'month'), colors),
              ],
            ),
            const SizedBox(height: 20),

            // ── Apply button ──
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_type, _cats, _period);
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(l10n.applyFilter, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap, AppColorsT colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
      ),
    );
  }
}

// ─── Pie Chart Painter ───

class _PieSegment {
  final double value;
  final Color color;
  const _PieSegment({required this.value, required this.color});
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;
  final double total;

  _PieChartPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;
    const strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;
    const totalAngle = 2 * math.pi;

    for (final seg in segments) {
      final sweep = (seg.value / total) * totalAngle;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) => old.total != total || old.segments != segments;
}
