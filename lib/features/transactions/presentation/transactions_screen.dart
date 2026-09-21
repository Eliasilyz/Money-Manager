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
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  String _filterType = 'all';
  final _searchCtrl = TextEditingController();

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
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? const <String, Category>{};
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    final filterLabels = {
      'all': l10n.allFilter,
      'filter': 'Filter',
      'analitik': 'Analitik',
      'calendar': 'Kalender',
    };

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
                children: filterLabels.entries.map((e) {
                  final selected = _filterType == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterType = e.key),
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
                            Text(e.value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textPrimary)),
                            if (e.key != 'all') ...[
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
            if (_filterType == 'calendar') ...[
              const SizedBox(height: 12),
              _buildCalendarStrip(colors, locale),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: transactionsAsync.when(
                data: (allTx) {
                  final filtered = _filterTransactions(allTx, l10n, catMap);
                  if (filtered.isEmpty) return _buildEmpty(colors, l10n);
                  return _buildGroupedList(filtered, catMap, fmt, colors, locale);
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

  Widget _buildCalendarStrip(AppColorsT colors, String locale) {
    final today = DateTime.now();
    final dayLabels = ['S', 'R', 'K', 'J', 'S', 'M', 'M'];
    final startDay = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(7, (i) => DateTime(startDay.year, startDay.month, startDay.day + i));

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
                Text(DateFormat('MMMM yyyy', locale).format(today), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                GestureDetector(
                  onTap: () => context.push('/calendar'),
                  child: Text('Kalender', style: GoogleFonts.inter(fontSize: 11, color: colors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
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

  List<Transaction> _filterTransactions(List<Transaction> all, AppLocalizations l10n, Map<String, Category> catMap) {
    var list = all;
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) {
        final desc = (t.description ?? '').toLowerCase();
        final note = (t.note ?? '').toLowerCase();
        final catName = catMap[t.categoryId]?.name.toLowerCase() ?? '';
        return desc.contains(_searchQuery) || note.contains(_searchQuery) || catName.contains(_searchQuery);
      }).toList();
    }
    if (_filterType == 'calendar') {
      list = list.where((t) => t.date.year == _selectedDate.year && t.date.month == _selectedDate.month && t.date.day == _selectedDate.day).toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Widget _buildGroupedList(List<Transaction> txList, Map<String, Category> catMap, NumberFormat fmt, AppColorsT colors, String locale) {
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
        final dayTotal = dayTx.fold<int>(0, (s, t) => s + (t.type == 'income' ? t.amount : -t.amount));
        final dayName = dayOnly == today ? 'Hari ini' : dayOnly == yesterday ? 'Kemarin' : DateFormat('EEEE', locale).format(dayOnly);
        final formattedTotal = '${dayTotal >= 0 ? '+' : '-'}${fmt.format(dayTotal.abs())}';

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
            ...dayTx.map((t) => _buildTxTile(t, catMap, fmt, colors)),
          ],
        );
      }).toList(),
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
