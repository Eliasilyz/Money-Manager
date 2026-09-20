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
  final _searchCtrl = TextEditingController();

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.movie_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
  };

  static const _categoryBgColors = <String, Color>{
    'makan': Color(0xFFE1F1EA),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFE1F1EA),
    'kesehatan': Color(0xFFFBE7E7),
    'pendidikan': Color(0xFFE8F0FA),
  };

  static const _categoryFgColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF1B6E4B),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
  };

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
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 20),
                    tooltip: 'Opsi lain',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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
                children: ['Semua', 'Kategori', 'Akun', 'Periode'].map((f) {
                  final selected = _filterType == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterType = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? colors.primary : colors.border),
                        ),
                        child: Text(f, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildCalendarStrip(colors),
            const SizedBox(height: 8),
            Expanded(
              child: transactionsAsync.when(
                data: (allTx) {
                  final filtered = _filterTransactions(allTx);
                  if (filtered.isEmpty) return _buildEmpty(colors);
                  return _buildGroupedList(filtered, catMap, fmt, colors);
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
    list = list.where((t) => t.date.year == _selectedDate.year && t.date.month == _selectedDate.month && t.date.day == _selectedDate.day).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Widget _buildGroupedList(List<Transaction> txList, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final dayTotal = txList.fold<int>(0, (s, t) => s + (t.type == 'income' ? t.amount : -t.amount));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('EEEE, d MMMM yyyy', 'id').format(_selectedDate), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              Text(
                '${dayTotal >= 0 ? '+' : '-'}${fmt.format(dayTotal.abs())}',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: dayTotal >= 0 ? AppColors.teal : AppColors.rose),
              ),
            ],
          ),
        ),
        ...txList.map((t) => _buildTxTile(t, catMap, fmt, colors)),
      ],
    );
  }

  Widget _buildTxTile(Transaction t, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.teal : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    final cat = catMap[t.categoryId];
    final catName = cat?.name ?? '';

    String iconKey = catName.toLowerCase();
    IconData icon = Icons.receipt_long_rounded;
    Color bgColor = const Color(0xFFE1F1EA);
    Color fgColor = const Color(0xFF1B6E4B);
    for (final entry in _categoryIcons.entries) {
      if (iconKey.contains(entry.key)) {
        icon = entry.value;
        bgColor = _categoryBgColors[entry.key] ?? bgColor;
        fgColor = _categoryFgColors[entry.key] ?? fgColor;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: fgColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (t.description != null && t.description!.isNotEmpty) ? t.description! : catName,
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