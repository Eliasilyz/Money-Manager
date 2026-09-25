import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  int _tab = 0; // 0=Pengeluaran, 1=Pemasukan, 2=Arus kas
  DateTime _selectedMonth = DateTime.now();

  static const _catColors = <String, Color>{
    'makan': Color(0xFFE76F51),
    'food': Color(0xFFE76F51),
    'minum': Color(0xFF3B82F6),
    'drink': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'shopping': Color(0xFFF59E0B),
    'transportasi': Color(0xFFEF4444),
    'transport': Color(0xFFEF4444),
    'rumah': Color(0xFF8B5CF6),
    'housing': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF10B981),
    'entertainment': Color(0xFF10B981),
    'kesehatan': Color(0xFFEC4899),
    'health': Color(0xFFEC4899),
    'pendidikan': Color(0xFF0EA5E9),
    'education': Color(0xFF0EA5E9),
    'tagihan': Color(0xFF2563EB),
    'gaji': Color(0xFF2A9D8F),
    'salary': Color(0xFF2A9D8F),
    'investasi': Color(0xFF7C3AED),
    'investment': Color(0xFF7C3AED),
    'lainnya': Color(0xFF9CA3AF),
    'other': Color(0xFF9CA3AF),
  };

  static const _fallbackColors = [
    Color(0xFFE76F51), Color(0xFF3B82F6), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF10B981),
    Color(0xFFEC4899), Color(0xFF0EA5E9), Color(0xFF2563EB),
  ];

  Color _getCatColor(String name, int index) {
    final key = name.toLowerCase();
    for (final entry in _catColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _fallbackColors[index % _fallbackColors.length];
  }

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    if (next.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() => _selectedMonth = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};
    int toBase(Transaction t) => convertAmount(t.amount, t.currencyCode, baseCode, rates).round();
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.statisticsSubtitle,
              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          // Month picker pill
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: _prevMonth,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.chevron_left_rounded, size: 20, color: colors.textSecondary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('MMM yyyy', Localizations.localeOf(context).languageCode).format(_selectedMonth),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _nextMonth,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: colors.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: l10n.expense),
                Tab(text: l10n.income),
                Tab(text: l10n.cashFlow),
              ],
            ),
          ),
        ),
      ),
      body: transactionsAsync.when(
        data: (allTx) {
          final catMap = categoriesAsync.whenOrNull(
                data: (cats) => {for (final c in cats) c.id: c},
              ) ??
              <String, Category>{};

          final year = _selectedMonth.year;
          final month = _selectedMonth.month;

          final periodTx = allTx
              .where((t) => t.date.year == year && t.date.month == month)
              .toList();

          final prevMonth = DateTime(year, month - 1, 1);
          final prevTx = allTx
              .where((t) => t.date.year == prevMonth.year && t.date.month == prevMonth.month)
              .toList();

          final income = periodTx
              .where((t) => t.type == 'income')
              .fold<int>(0, (s, t) => s + toBase(t));
          final expense = periodTx
              .where((t) => t.type == 'expense')
              .fold<int>(0, (s, t) => s + toBase(t));
          final cashFlow = income - expense;

          final prevIncome = prevTx
              .where((t) => t.type == 'income')
              .fold<int>(0, (s, t) => s + toBase(t));
          final prevExpense = prevTx
              .where((t) => t.type == 'expense')
              .fold<int>(0, (s, t) => s + toBase(t));

          // Displayed metric depends on tab
          final int primaryValue;
          final int prevValue;
          final String primaryLabel;
          switch (_tab) {
            case 1:
              primaryValue = income;
              prevValue = prevIncome;
              primaryLabel = l10n.totalIncome;
              break;
            case 2:
              primaryValue = cashFlow;
              prevValue = prevIncome - prevExpense;
              primaryLabel = l10n.cashFlow;
              break;
            default:
              primaryValue = expense;
              prevValue = prevExpense;
              primaryLabel = l10n.totalExpenses;
          }

          // Trend delta
          final double trendPct = prevValue > 0
              ? ((primaryValue - prevValue) / prevValue * 100)
              : 0.0;
          final trendDown = trendPct <= 0;
          final trendColor = _tab == 0
              ? (trendDown ? const Color(0xFF2A9D8F) : const Color(0xFFEF4444))
              : (trendDown ? const Color(0xFFEF4444) : const Color(0xFF2A9D8F));
          final localeStr = Localizations.localeOf(context).languageCode;
          final prevMonthName = DateFormat('MMMM', localeStr).format(prevMonth);

          // Dynamic Callout Banner properties
          final String calloutTitle;
          final String calloutBody;
          final Color calloutBg;
          final Color calloutBorder;
          final IconData calloutIcon;
          final Color calloutIconColor;
          final Color calloutTitleColor;
          final Color calloutBodyColor;

          final pctStr = trendPct.abs().toStringAsFixed(1);
          final bool isGoodTrend;

          if (prevValue <= 0) {
            isGoodTrend = true;
            calloutTitle = l10n.financialInsight;
            calloutBody = l10n.trendKeepMonitoring;
          } else if (_tab == 0) {
            // Expense Tab
            if (trendPct <= 0) {
              isGoodTrend = true;
              calloutTitle = l10n.positiveTrend;
              calloutBody = l10n.trendPosTip(pctStr, prevMonthName);
            } else {
              isGoodTrend = false;
              calloutTitle = l10n.attentionNeeded;
              calloutBody = l10n.trendExpenseIncreaseTip(pctStr, prevMonthName);
            }
          } else if (_tab == 1) {
            // Income Tab
            if (trendPct >= 0) {
              isGoodTrend = true;
              calloutTitle = l10n.positiveTrend;
              calloutBody = l10n.trendIncomeIncreaseTip(pctStr, prevMonthName);
            } else {
              isGoodTrend = false;
              calloutTitle = l10n.attentionNeeded;
              calloutBody = l10n.trendIncomeDecreaseTip(pctStr, prevMonthName);
            }
          } else {
            // Cash Flow Tab
            if (trendPct >= 0) {
              isGoodTrend = true;
              calloutTitle = l10n.positiveTrend;
              calloutBody = l10n.trendCashFlowIncreaseTip(pctStr, prevMonthName);
            } else {
              isGoodTrend = false;
              calloutTitle = l10n.attentionNeeded;
              calloutBody = l10n.trendCashFlowDecreaseTip(pctStr, prevMonthName);
            }
          }

          if (isGoodTrend) {
            calloutBg = const Color(0xFFE0F2FE);
            calloutBorder = const Color(0xFFBAE6FD);
            calloutIcon = Icons.lightbulb_rounded;
            calloutIconColor = const Color(0xFF0284C7);
            calloutTitleColor = const Color(0xFF0C4A6E);
            calloutBodyColor = const Color(0xFF0369A1);
          } else {
            calloutBg = const Color(0xFFFEF3E2);
            calloutBorder = const Color(0xFFFDE68A);
            calloutIcon = Icons.warning_amber_rounded;
            calloutIconColor = const Color(0xFFD97706);
            calloutTitleColor = const Color(0xFF78350F);
            calloutBodyColor = const Color(0xFF92400E);
          }

          // Category breakdown
          final expenseTx = periodTx.where((t) => t.type == 'expense').toList();
          final catTotals = <String, int>{};
          for (final t in expenseTx) {
            final cat = catMap[t.categoryId];
            final catName = cat == null ? l10n.categoryDefaultOtherIncome : localizedCategoryName(l10n, cat.systemKey, cat.name);
            catTotals[catName] = (catTotals[catName] ?? 0) + toBase(t);
          }
          final sortedCats = catTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topItems = sortedCats.take(6).toList();
          final otherTotal = sortedCats.skip(6).fold<int>(0, (s, e) => s + e.value);

          // 6-month bar data
          final barData = List.generate(6, (i) {
            final m = DateTime(year, month - 5 + i, 1);
            final mTx = allTx.where((t) => t.date.year == m.year && t.date.month == m.month).toList();
            final mExp = mTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + toBase(t));
            final mInc = mTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + toBase(t));
            return (month: m, expense: mExp, income: mInc);
          });

          // Daily stats
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final avgDaily = daysInMonth > 0 ? (expense / daysInMonth).round() : 0;
          // Find peak day
          final dailyTotals = <int, int>{};
          for (final t in expenseTx) {
            dailyTotals[t.date.day] = (dailyTotals[t.date.day] ?? 0) + toBase(t);
          }
          int peakDay = 0;
          int peakAmount = 0;
          dailyTotals.forEach((day, amt) {
            if (amt > peakAmount) {
              peakAmount = amt;
              peakDay = day;
            }
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // Hero amount overview
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [colors.heroCardBg, colors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.heroCardBg.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(primaryValue, currencyCode: baseCode),
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          trendDown ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                          color: trendColor,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.trendVsLastMonth('${trendPct >= 0 ? '+' : ''}${trendPct.toStringAsFixed(1)}', prevMonthName),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6-month Bar Chart
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.last6Months,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            _chartLegendDot(colors.primary, l10n.exits),
                            const SizedBox(width: 12),
                            _chartLegendDot(const Color(0xFF2A9D8F), l10n.entries),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: _SixMonthBarChart(
                        barData: barData,
                        primaryColor: colors.primary,
                        incomeColor: const Color(0xFF2A9D8F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stat Cards Row: Rata-rata & Hari tertinggi
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.show_chart_rounded,
                      iconBg: colors.primary.withValues(alpha: 0.1),
                      iconColor: colors.primary,
                      label: l10n.dailyAverage,
                      value: formatCurrency(avgDaily, currencyCode: baseCode),
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFEF4444),
                      label: l10n.highestDay,
                      value: peakDay > 0
                          ? '$peakDay ${DateFormat('MMM', localeStr).format(_selectedMonth)}'
                          : '-',
                      subValue: peakAmount > 0
                          ? formatCurrency(peakAmount, currencyCode: baseCode)
                          : null,
                      colors: colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Donut Chart + Legend
              if (topItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoryDistribution,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: _DonutPainter(
                                segments: [
                                  ...topItems.asMap().entries.map((e) => _DonutSegment(
                                        value: e.value.value.toDouble(),
                                        color: _getCatColor(e.value.key, e.key),
                                      )),
                                  if (otherTotal > 0)
                                    _DonutSegment(value: otherTotal.toDouble(), color: const Color(0xFF9CA3AF)),
                                ],
                                total: expense.toDouble(),
                                strokeWidth: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              children: [
                                ...topItems.asMap().entries.map(
                                      (e) => _legendRow(
                                        e.value.key,
                                        e.value.value,
                                        expense,
                                        _getCatColor(e.value.key, e.key),
                                        colors,
                                        baseCode,
                                      ),
                                    ),
                                if (otherTotal > 0)
                                  _legendRow(l10n.categoryDefaultOtherExpense, otherTotal, expense, const Color(0xFF9CA3AF), colors, baseCode),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Dynamic trend callout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: calloutBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: calloutBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(calloutIcon, color: calloutIconColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calloutTitle,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: calloutTitleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            calloutBody,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: calloutBodyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _chartLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    String? subValue,
    required AppColorsT colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendRow(String name, int amount, int total, Color color, AppColorsT colors, String baseCode) {
    final pct = total > 0 ? (amount / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(fontSize: 11, color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$pct%',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Custom painters ─────────────────────────────────────────────────────────

class _SixMonthBarChart extends StatelessWidget {
  final List<({DateTime month, int expense, int income})> barData;
  final Color primaryColor;
  final Color incomeColor;

  const _SixMonthBarChart({
    required this.barData,
    required this.primaryColor,
    required this.incomeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final maxVal = barData.fold<int>(
      1,
      (m, d) => math.max(m, math.max(d.expense, d.income)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: barData.map((d) {
        final expH = maxVal > 0 ? (d.expense / maxVal) : 0.0;
        final incH = maxVal > 0 ? (d.income / maxVal) : 0.0;
        final label = DateFormat('MMM', 'id').format(d.month);
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expense bar
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: expH.clamp(0.0, 1.0),
                        child: Container(
                          width: 10,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Income bar
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: incH.clamp(0.0, 1.0),
                        child: Container(
                          width: 10,
                          decoration: BoxDecoration(
                            color: incomeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double total;
  final double strokeWidth;

  _DonutPainter({required this.segments, required this.total, this.strokeWidth = 18});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04;

    for (final seg in segments) {
      final sweep = (seg.value / total) * (math.pi * 2) - gapAngle;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep.clamp(0.0, math.pi * 2),
        false,
        paint,
      );
      startAngle += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.total != total || old.segments.length != segments.length;
}
