import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  String _filterType = 'Semua';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? const <String, Category>{};
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaksi', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text('Semua aktivitas keuangan', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _showSearch = !_showSearch),
                        icon: Icon(Icons.search, color: colors.textSecondary, size: 22),
                        tooltip: 'Cari',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.filter_list_rounded, color: colors.textSecondary, size: 22),
                        tooltip: 'Filter',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi atau catatan...',
                    prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
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
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['Semua', 'Kategori', 'Akun', 'Kalender'].map((f) {
                  final selected = _filterType == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterType = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? colors.primary : colors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(f, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
                            if (f != 'Semua') ...[
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: selected ? Colors.white : colors.textSecondary),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_filterType == 'Kalender') ...[
              const SizedBox(height: 12),
              _buildCalendarStrip(colors),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: transactionsAsync.when(
                data: (allTx) {
                  final filtered = _filterTransactions(allTx);
                  if (filtered.isEmpty) return _buildEmpty(colors);
                  return _buildContent(filtered, allTx, catMap, fmt, colors);
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
        foregroundColor: AppColors.bg,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarStrip(AppColorsT colors) {
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final today = DateTime.now();
    return SizedBox(
      height: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMMM yyyy', 'id').format(_calendarMonth), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                Text('Kalender', style: GoogleFonts.inter(fontSize: 11, color: colors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = DateTime(_calendarMonth.year, _calendarMonth.month, index + 1);
                final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                final dayLabels = ['S', 'R', 'K', 'J', 'S', 'M', 'M'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: Container(
                    width: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : (isToday ? colors.primary.withValues(alpha: 0.1) : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayLabels[day.weekday - 1], style: GoogleFonts.inter(fontSize: 10, color: isSelected ? Colors.white.withValues(alpha: 0.7) : colors.textSecondary)),
                        const SizedBox(height: 2),
                        Text('${day.day}', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : colors.textPrimary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> all) {
    var list = all;
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) {
        final desc = (t.description ?? '').toLowerCase();
        final note = (t.note ?? '').toLowerCase();
        return desc.contains(_searchQuery) || note.contains(_searchQuery);
      }).toList();
    }
    if (_filterType == 'Kalender') {
      list = list.where((t) => t.date.year == _selectedDate.year && t.date.month == _selectedDate.month && t.date.day == _selectedDate.day).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Widget _buildContent(List<Transaction> filtered, List<Transaction> allTx, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final statsTx = _filterType == 'Kalender' ? filtered : allTx;
    final expenseTx = statsTx.where((t) => t.type == 'expense').toList();
    final incomeTx = statsTx.where((t) => t.type == 'income').toList();
    final totalExpense = expenseTx.fold<int>(0, (s, t) => s + t.amount);
    final totalIncome = incomeTx.fold<int>(0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        if (expenseTx.isNotEmpty) _buildStatsSection(expenseTx, catMap, fmt, colors, totalExpense, totalIncome),
        if (_filterType == 'Kalender') ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEEE, d MMMM yyyy', 'id').format(_selectedDate), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                Text(
                  '${totalIncome - totalExpense >= 0 ? '+' : '-'}${fmt.format((totalIncome - totalExpense).abs())}',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: totalIncome >= totalExpense ? AppColors.teal : AppColors.rose),
                ),
              ],
            ),
          ),
        ],
        ...filtered.map((t) => _buildTxTile(t, catMap, fmt, colors)),
      ],
    );
  }

  Widget _buildStatsSection(List<Transaction> expenseTx, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors, int totalExpense, int totalIncome) {
    final catTotals = <String, int>{};
    for (final t in expenseTx) {
      final catName = catMap[t.categoryId]?.name ?? 'Lainnya';
      catTotals[catName] = (catTotals[catName] ?? 0) + t.amount;
    }
    final sorted = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topItems = sorted.take(5).toList();
    final otherTotal = sorted.skip(5).fold<int>(0, (s, e) => s + e.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistik', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
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
                    total: totalExpense.toDouble(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
                        Text(fmt.format(totalExpense), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ...topItems.asMap().entries.map((e) => _buildLegendRow(e.value.key, e.value.value, totalExpense, _getCatColor(e.value.key, e.key), fmt, colors)),
                    if (otherTotal > 0) _buildLegendRow('Lainnya', otherTotal, totalExpense, const Color(0xFF9CA3AF), fmt, colors),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String name, int amount, int total, Color color, NumberFormat fmt, AppColorsT colors) {
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
          Text(fmt.format(amount), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        ],
      ),
    );
  }

  Color _getCatColor(String name, int index) {
    final key = name.toLowerCase();
    for (final entry in _catColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _fallbackColors[index % _fallbackColors.length];
  }

  Widget _buildTxTile(Transaction t, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    final cat = catMap[t.categoryId];
    final catName = cat?.name ?? '';
    final fgColor = _getCatColor(catName, 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: fgColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: fgColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (t.description != null && t.description!.isNotEmpty) ? t.description! : (catName.isNotEmpty ? catName : 'Transaksi'),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${catName.isNotEmpty ? catName : 'Lainnya'} • ${DateFormat('HH:mm').format(t.date)}',
                  style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '$sign${fmt.format(t.amount)}',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppColorsT colors) {
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
          Text('Belum ada transaksi', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
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
