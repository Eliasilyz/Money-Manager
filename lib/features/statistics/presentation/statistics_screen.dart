import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _period = 'Bulan';
  final _fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

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
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: transactionsAsync.when(
        data: (allTx) {
          final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? <String, Category>{};
          final now = DateTime.now();
          final List<Transaction> periodTx;
          String periodLabel;

          switch (_period) {
            case 'week':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              periodTx = allTx.where((t) => t.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
              periodLabel = l10n.thisWeek;
              break;
            case 'year':
              periodTx = allTx.where((t) => t.date.year == now.year).toList();
              periodLabel = '${l10n.total} ${now.year}';
              break;
            default:
              periodTx = allTx.where((t) => t.date.month == now.month && t.date.year == now.year).toList();
              periodLabel = DateFormat('MMMM yyyy', locale).format(now);
          }

          final income = periodTx.where((t) => t.type == 'income').fold<int>(0, (int sum, t) => sum + t.amount);
          final expense = periodTx.where((t) => t.type == 'expense').fold<int>(0, (int sum, t) => sum + t.amount);
          final diff = income - expense;

          final expenseTx = periodTx.where((t) => t.type == 'expense').toList();
          final catTotals = <String, int>{};
          for (final t in expenseTx) {
            final catName = catMap[t.categoryId]?.name ?? l10n.other;
            catTotals[catName] = (catTotals[catName] ?? 0) + t.amount;
          }
          final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final topItems = sortedCats.take(6).toList();
          final otherTotal = sortedCats.skip(6).fold<int>(0, (s, e) => s + e.value);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(periodLabel, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(height: 12),
              _buildHeroCard(income, expense, diff, colors, l10n),
              const SizedBox(height: 16),
              _buildPeriodSelector(colors, l10n),
              const SizedBox(height: 24),
              if (expenseTx.isNotEmpty) ...[
                _buildDonutSection(topItems, otherTotal, expense, catMap, colors, l10n),
                const SizedBox(height: 24),
              ],
              _buildStatCards(periodTx.length, expense, now, colors, l10n),
              const SizedBox(height: 24),
              _buildCategoryList(sortedCats, catMap, colors, l10n),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _buildHeroCard(int income, int expense, int diff, AppColorsT colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.financialSummary, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 16),
          Row(
            children: [
              _heroStat(l10n.income, income),
              const SizedBox(width: 16),
              _heroStat(l10n.expense, expense),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.changeVsLastMonth, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
          Text(
            _fmt.format(diff),
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, int value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
          Text(_fmt.format(value), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppColorsT colors, AppLocalizations l10n) {
    final periods = [
      ('week', l10n.thisWeek),
      ('month', l10n.thisMonth),
      ('year', l10n.total),
    ];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: periods.map((p) {
          final selected = _period == p.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _period = p.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? colors.primary : colors.border),
                ),
                child: Text(p.$2, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDonutSection(List<MapEntry<String, int>> topItems, int otherTotal, int total, Map<String, Category> catMap, AppColorsT colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.categoryBreakdown, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 80,
                child: CustomPaint(
                  painter: _HalfDonutPainter(
                    segments: [
                      ...topItems.asMap().entries.map((e) => _DonutSegment(
                        value: e.value.value.toDouble(),
                        color: _getCatColor(e.value.key, e.key),
                      )),
                      if (otherTotal > 0) _DonutSegment(value: otherTotal.toDouble(), color: const Color(0xFF9CA3AF)),
                    ],
                    total: total.toDouble(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.total, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
                        Text(_fmt.format(total), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ...topItems.asMap().entries.map((e) => _legendRow(e.value.key, e.value.value, total, _getCatColor(e.value.key, e.key), colors)),
                    if (otherTotal > 0) _legendRow(l10n.other, otherTotal, total, const Color(0xFF9CA3AF), colors),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String name, int amount, int total, Color color, AppColorsT colors) {
    final pct = total > 0 ? (amount / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 11, color: colors.textPrimary), overflow: TextOverflow.ellipsis)),
          Text('$pct%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(width: 8),
          Text(_fmt.format(amount), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildStatCards(int txCount, int expense, DateTime now, AppColorsT colors, AppLocalizations l10n) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final avgPerDay = txCount > 0 ? (expense / daysInMonth).round() : 0;
    return Row(
      children: [
        _statCard(l10n.transactions, '$txCount', colors),
        const SizedBox(width: 12),
        _statCard(l10n.dailyAverage, _fmt.format(avgPerDay), colors),
      ],
    );
  }

  Widget _statCard(String label, String value, AppColorsT colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, int>> sortedCats, Map<String, Category> catMap, AppColorsT colors, AppLocalizations l10n) {
    if (sortedCats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
        child: Text(l10n.noData, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary), textAlign: TextAlign.center),
      );
    }
    final maxCat = sortedCats.first.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.viewDetail, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            Text('${sortedCats.length} ${l10n.categories.toLowerCase()}', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        ...sortedCats.map((entry) {
          final name = entry.key;
          final catColor = _getCatColor(name, 0);
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
                    Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                    Text(_fmt.format(entry.value), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (entry.value / maxCat).clamp(0.0, 1.0),
                    backgroundColor: colors.border,
                    color: catColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _HalfDonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double total;

  _HalfDonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - 6;
    const strokeWidth = 16.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = math.pi;
    const totalAngle = math.pi;

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
  bool shouldRepaint(covariant _HalfDonutPainter old) => old.total != total || old.segments != segments;
}
