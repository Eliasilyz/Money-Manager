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
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: Semua, 1: Filter, 2: Analitik, 3: Kalender
  DateTime _selectedDate = DateTime.now();
  bool _filterByDate = false;

  // Filter state
  String _filterType = 'all'; // all / expense / income
  List<String> _selectedCategories = [];
  String _datePeriod = 'all'; // all / today / week / month

  final _searchCtrl = TextEditingController();
  String _baseCode = 'IDR';
  Map<String, double> _rates = const {};

  int _toBase(Transaction t) =>
      convertAmount(t.amount, t.currencyCode, _baseCode, _rates).round();

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
    _baseCode = baseCode;
    _rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? const <String, Category>{};
    final accounts = ref.watch(accountsNotifierProvider).valueOrNull ?? [];
    final accountMap = {for (final a in accounts) a.id: a};

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.transactions, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(l10n.allFinancialActivity, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colors.textSecondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onSelected: (val) {
                      if (val == 'categories') context.push('/categories');
                      if (val == 'notes') context.push('/notes');
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'categories',
                        child: Row(
                          children: [
                            Icon(Icons.category_outlined, size: 18, color: colors.textPrimary),
                            const SizedBox(width: 10),
                            Text(l10n.manageCategories, style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'notes',
                        child: Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 18, color: colors.textPrimary),
                            const SizedBox(width: 10),
                            Text(l10n.financialNotes, style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.searchTransactionsHint,
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

            // Chips Row: Semua | Filter | Analitik | Kalender
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _chipItem(l10n.allFilter, _selectedFilterIndex == 0 && !_filterByDate, () {
                    setState(() {
                      _selectedFilterIndex = 0;
                      _filterByDate = false;
                      _filterType = 'all';
                      _selectedCategories = [];
                      _datePeriod = 'all';
                    });
                  }, colors),
                  const SizedBox(width: 8),
                  _chipItem(l10n.filter, _hasActiveFilters, () {
                    _showFilterSheet(context, colors, l10n);
                  }, colors),
                  const SizedBox(width: 8),
                  _chipItem(l10n.statistics, false, () => context.push('/statistics'), colors),
                  const SizedBox(width: 8),
                  _chipItem(l10n.calendar, false, () => context.push('/calendar'), colors),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal Date Strip (September 2026 • Kalender)
            _buildWeekDateStrip(colors, locale, l10n),
            const SizedBox(height: 10),

            // Transaction Grouped List + Akses Cepat
            Expanded(
              child: transactionsAsync.when(
                data: (allTx) {
                  final filtered = _filterTransactions(allTx, l10n, catMap);
                  if (filtered.isEmpty) return _buildEmpty(colors, l10n);
                  return _buildGroupedList(filtered, catMap, accountMap, colors, locale, l10n);
                },
                loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
                error: (e, _) => Center(child: Text('Error: $e', style: GoogleFonts.inter(color: colors.expense))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipItem(String label, bool isSelected, VoidCallback onTap, AppColorsT colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colors.primary : colors.border),
          boxShadow: isSelected
              ? [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDateStrip(AppColorsT colors, String locale, AppLocalizations l10n) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', locale).format(_selectedDate);

    // Current week days (Monday to Sunday)
    final startOfWeek = now.subtract(Duration(days: (now.weekday - 1) % 7));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    final dayLetters = List.generate(7, (i) => DateFormat('E', locale).format(weekDays[i]).substring(0, 1).toUpperCase());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(monthLabel, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              GestureDetector(
                onTap: () => context.push('/calendar'),
                child: Text(l10n.calendar, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (i) {
              final d = weekDays[i];
              final isSelected = d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day;
              final dayIndex = (d.weekday - 1) % 7;
              final letter = dayLetters[dayIndex];

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = d;
                  _filterByDate = true;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? colors.primary : colors.border),
                    boxShadow: isSelected
                        ? [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        letter,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white.withValues(alpha: 0.8) : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters => _filterType != 'all' || _selectedCategories.isNotEmpty || _datePeriod != 'all' || _filterByDate;

  void _showFilterSheet(BuildContext context, AppColorsT colors, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.filterTransactionsTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _filterType = 'all';
                        _selectedCategories = [];
                        _datePeriod = 'all';
                      });
                      setState(() {});
                    },
                    child: Text(l10n.reset, style: GoogleFonts.inter(color: colors.expense, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.transactionType, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _filterChoice(l10n.allFilter, _filterType == 'all', () => setSheetState(() => _filterType = 'all'), colors),
                  const SizedBox(width: 8),
                  _filterChoice(l10n.expense, _filterType == 'expense', () => setSheetState(() => _filterType = 'expense'), colors),
                  const SizedBox(width: 8),
                  _filterChoice(l10n.income, _filterType == 'income', () => setSheetState(() => _filterType = 'income'), colors),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.applyFilter, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChoice(String label, bool isSelected, VoidCallback onTap, AppColorsT colors) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? colors.primary : colors.border),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : colors.textPrimary)),
          ),
        ),
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> all, AppLocalizations l10n, Map<String, Category> catMap) {
    var list = all;

    if (_searchQuery.isNotEmpty) {
      list = list.where((t) {
        final desc = (t.description ?? '').toLowerCase();
        final note = (t.note ?? '').toLowerCase();
        final cat = catMap[t.categoryId];
        final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name).toLowerCase();
        return desc.contains(_searchQuery) || note.contains(_searchQuery) || catName.contains(_searchQuery);
      }).toList();
    }

    if (_filterByDate) {
      list = list.where((t) =>
        t.date.year == _selectedDate.year &&
        t.date.month == _selectedDate.month &&
        t.date.day == _selectedDate.day
      ).toList();
    }

    if (_filterType != 'all') {
      list = list.where((t) => t.type == _filterType).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  IconData _getCategoryIcon(Transaction t, String? systemKey) {
    if (t.transferId != null) return Icons.swap_horiz_rounded;
    final desc = (t.description ?? '').toLowerCase();
    if (desc.contains('supermarket') || desc.contains('belanja')) return Icons.shopping_cart_outlined;
    if (desc.contains('bakso') || desc.contains('kopi') || desc.contains('makan')) return Icons.restaurant_outlined;
    if (desc.contains('bensin') || desc.contains('transport')) return Icons.local_gas_station_outlined;
    if (desc.contains('gaji') || desc.contains('salary')) return Icons.account_balance_wallet_outlined;
    if (desc.contains('proyek') || desc.contains('bisnis')) return Icons.work_outline_rounded;
    if (systemKey == 'food_drink') return Icons.restaurant_outlined;
    if (systemKey == 'transport') return Icons.directions_car_outlined;
    if (systemKey == 'shopping') return Icons.shopping_bag_outlined;
    if (systemKey == 'housing') return Icons.home_outlined;
    if (systemKey == 'salary') return Icons.account_balance_wallet_outlined;
    return t.type == 'income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
  }

  Widget _buildGroupedList(List<Transaction> txList, Map<String, Category> catMap, Map<String, dynamic> accountMap, AppColorsT colors, String locale, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<Transaction>>{};
    for (final t in txList) {
      final dayKey = '${t.date.year}-${t.date.month}-${t.date.day}';
      grouped.putIfAbsent(dayKey, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
      children: [
        ...grouped.entries.map((entry) {
          final dayTx = entry.value;
          final dayDate = dayTx.first.date;
          final dayOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
          final dayTotal = dayTx.fold<int>(0, (s, t) => s + (t.type == 'income' ? _toBase(t) : -_toBase(t)));
          final dayName = dayOnly == today ? l10n.today : dayOnly == yesterday ? l10n.yesterday : DateFormat('EEEE, d MMMM', locale).format(dayOnly);
          final isPositive = dayTotal >= 0;
          final badgeColor = isPositive ? colors.income : colors.expense;
          final badgeText = '${isPositive ? '+' : '-'}Rp ${NumberFormat('#,###', 'id_ID').format(dayTotal.abs())}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dayName, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(badgeText, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor)),
                    ),
                  ],
                ),
              ),
              ...dayTx.map((t) => _buildTxTile(t, catMap, accountMap, colors, l10n)),
              const SizedBox(height: 8),
            ],
          );
        }),

        const SizedBox(height: 16),
        // Akses Cepat section matching design
        Text(l10n.quickAccess, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        const SizedBox(height: 10),
        _buildQuickAccessCard(
          icon: Icons.category_outlined,
          title: l10n.categories,
          subtitle: l10n.manageCategoriesSubtitle,
          onTap: () => context.push('/categories'),
          colors: colors,
        ),
        const SizedBox(height: 8),
        _buildQuickAccessCard(
          icon: Icons.edit_note_rounded,
          title: l10n.notes,
          subtitle: l10n.addNotesSubtitle,
          onTap: () => context.push('/notes'),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppColorsT colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Text('Buka', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxTile(Transaction t, Map<String, Category> catMap, Map<String, dynamic> accountMap, AppColorsT colors, AppLocalizations l10n) {
    final isIncome = t.type == 'income';
    final cat = catMap[t.categoryId];
    final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name);
    final account = accountMap[t.accountId];
    final accountName = account?.name ?? '';
    final iconColor = isIncome ? colors.income : colors.expense;
    final sign = isIncome ? '+' : '-';
    final icon = _getCategoryIcon(t, cat?.systemKey);

    final timeStr = '${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}';
    final subParts = <String>[];
    if (catName.isNotEmpty) subParts.add(catName);
    if (accountName.isNotEmpty) subParts.add(accountName);
    if (t.note != null && t.note!.isNotEmpty) subParts.add('Catatan: ${t.note}');
    subParts.add(timeStr);
    final subtitle = subParts.join(' • ');

    return GestureDetector(
      onTap: () => context.push('/add-transaction', extra: t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.description?.isNotEmpty == true ? t.description! : (catName.isNotEmpty ? catName : (isIncome ? l10n.income : l10n.expense)),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '$sign${currencySymbol(t.currencyCode)} ${NumberFormat('#,###', 'id_ID').format(t.amount)}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppColorsT colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(l10n.noTransactions, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
