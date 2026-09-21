import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
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
                      GestureDetector(
                        onTap: () => context.push('/statistics'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bar_chart_rounded, color: colors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text('Statistik', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => setState(() => _showSearch = !_showSearch),
                        icon: Icon(Icons.search, color: colors.textSecondary, size: 22),
                        tooltip: 'Cari',
                      ),
                      IconButton(
                        onPressed: () => _showFilterSheet(context, colors),
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
    if (_filterType == 'Kalender') {
      list = list.where((t) => t.date.year == _selectedDate.year && t.date.month == _selectedDate.month && t.date.day == _selectedDate.day).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Widget _buildGroupedList(List<Transaction> txList, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors) {
    final dayTotal = txList.fold<int>(0, (s, t) => s + (t.type == 'income' ? t.amount : -t.amount));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        if (_filterType == 'Kalender')
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
    final cat = catMap[t.categoryId];
    final catName = cat?.name ?? '';
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TransactionTile(
        amount: '$sign${fmt.format(t.amount)}',
        isIncome: isIncome,
        date: t.date,
        categoryName: catName.isNotEmpty ? catName : null,
        note: t.note,
        description: t.description,
        isTransfer: t.transferId != null,
        onTap: () => _showTransactionDetail(t, catName, fmt, colors),
      ),
    );
  }

  void _showTransactionDetail(Transaction t, String catName, NumberFormat fmt, AppColorsT colors) {
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
                Text('Detail Transaksi', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: colors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$sign${fmt.format(t.amount)}',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: isIncome ? AppColors.teal : AppColors.rose),
            ),
            const SizedBox(height: 16),
            _detailRow('Tipe', isIncome ? 'Pemasukan' : 'Pengeluaran', colors),
            if (catName.isNotEmpty) _detailRow('Kategori', catName, colors),
            if (t.description != null && t.description!.isNotEmpty) _detailRow('Deskripsi', t.description!, colors),
            if (t.note != null && t.note!.isNotEmpty) _detailRow('Catatan', t.note!, colors),
            _detailRow('Tanggal', DateFormat('dd MMMM yyyy • HH:mm', 'id').format(t.date), colors),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/add-transaction');
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text('Edit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  void _showFilterSheet(BuildContext context, AppColorsT colors) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Transaksi', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.category_outlined, color: colors.primary),
              title: Text('Kategori', style: GoogleFonts.inter(fontSize: 14)),
              trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
              onTap: () {
                Navigator.pop(ctx);
                _showCategoryFilter(context, colors);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined, color: colors.primary),
              title: Text('Akun', style: GoogleFonts.inter(fontSize: 14)),
              trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
              onTap: () {
                Navigator.pop(ctx);
                _showAccountFilter(context, colors);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: colors.primary),
              title: Text('Periode', style: GoogleFonts.inter(fontSize: 14)),
              trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
              onTap: () {
                Navigator.pop(ctx);
                _showPeriodFilter(context, colors);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _searchQuery = '';
                    _filterType = 'Semua';
                    _selectedDate = DateTime.now();
                  });
                },
                child: Text('Reset filter', style: GoogleFonts.inter(color: colors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, AppColorsT colors) {
    final categoriesAsync = ref.read(categoriesNotifierProvider);
    if (!categoriesAsync.hasValue) return;
    final cats = categoriesAsync.value!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...cats.map((c) => ListTile(
              title: Text(c.name, style: GoogleFonts.inter(fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _searchQuery = c.name.toLowerCase();
                  _filterType = 'Semua';
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showAccountFilter(BuildContext context, AppColorsT colors) {
    final accountsAsync = ref.read(accountsNotifierProvider);
    if (!accountsAsync.hasValue) return;
    final accounts = accountsAsync.value!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Akun', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...accounts.map((a) => ListTile(
              title: Text(a.name, style: GoogleFonts.inter(fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _searchQuery = a.name.toLowerCase();
                  _filterType = 'Semua';
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showPeriodFilter(BuildContext context, AppColorsT colors) {
    final now = DateTime.now();
    final periods = <(String, DateTime, DateTime)>[
      ('Bulan ini', DateTime(now.year, now.month, 1), now),
      ('7 hari terakhir', now.subtract(const Duration(days: 7)), now),
      ('30 hari terakhir', now.subtract(const Duration(days: 30)), now),
      ('Bulan lalu', DateTime(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1, 1), DateTime(now.year, now.month, 0)),
      ('Tahun ini', DateTime(now.year, 1, 1), now),
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Periode', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...periods.map((p) => ListTile(
              title: Text(p.$1, style: GoogleFonts.inter(fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _searchQuery = '';
                  _filterType = 'Semua';
                });
              },
            )),
          ],
        ),
      ),
    );
  }
}
