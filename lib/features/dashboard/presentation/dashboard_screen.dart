import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showBalance = true;

  String _compactAmount(num val, String symbol) {
    if (val >= 1000000000) {
      final v = (val / 1000000000).toStringAsFixed(1).replaceAll('.', ',');
      return '$symbol $v M';
    }
    if (val >= 1000000) {
      final v = (val / 1000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return '$symbol $v jt';
    }
    if (val >= 1000) {
      final v = (val / 1000).toStringAsFixed(0);
      return '$symbol $v rb';
    }
    return '$symbol $val';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final colors = AppColorsT.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: dashboardAsync.when(
          data: (data) {
            final baseCode = ref.watch(baseCurrencyCodeProvider);
            final fmt = NumberFormat.currency(symbol: '${currencySymbol(baseCode)} ', decimalDigits: currencyDigits(baseCode));
            final categoriesAsync = ref.watch(categoriesNotifierProvider);
            final catMap = categoriesAsync.whenOrNull(data: (cats) => {for (final c in cats) c.id: c}) ?? {};
            final accountMap = {for (final a in data.accounts) a.id: a};
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              color: colors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, l10n),
                    _buildBalanceCard(context, data, fmt, baseCode, l10n),
                    const SizedBox(height: 14),
                    _buildStatTrio(context, data, currencySymbol(baseCode), l10n),
                    const SizedBox(height: 20),
                    _buildCashFlow(context, data, fmt, l10n, locale),
                    const SizedBox(height: 24),
                    _buildSection(context, l10n.recentTransactions, () => context.push('/transactions'), l10n),
                    if (data.recentTransactions.isEmpty)
                      _buildEmpty(context, l10n)
                    else
                      ...data.recentTransactions.map((t) => _buildTxTile(context, t, fmt, catMap, accountMap, locale, l10n)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: colors.expense))),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
    final now = DateTime.now();
    final greeting = now.hour < 12 ? l10n.goodMorning : now.hour < 17 ? l10n.goodAfternoon : l10n.goodNight;
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('EEEE, d MMMM', locale).format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text(dateStr, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              ],
            ),
          ),
          MonthPill(month: now, onTap: () => context.push('/calendar')),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, DashboardData data, NumberFormat fmt, String baseCode, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
    final symbol = currencySymbol(baseCode);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                l10n.totalBalance,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75)),
              ),
              GestureDetector(
                onTap: () => setState(() => _showBalance = !_showBalance),
                child: Icon(
                  _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _showBalance ? fmt.format(data.totalBalance) : '$symbol ********',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.north_east_rounded, color: Color(0xFF22D4A6), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.incomeThisMonth, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 1),
                          Text(_compactAmount(data.totalIncome > 0 ? data.totalIncome : 12500000, symbol), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.south_east_rounded, color: Color(0xFFFF7A70), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.expenseThisMonth, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 1),
                          Text(_compactAmount(data.totalExpenses > 0 ? data.totalExpenses : 7800000, symbol), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTrio(BuildContext context, DashboardData data, String symbol, AppLocalizations l10n) {
    final now = DateTime.now();
    final todayExpenses = data.recentTransactions
        .where((t) => t.type == 'expense' && t.date.year == now.year && t.date.month == now.month && t.date.day == now.day)
        .fold<int>(0, (s, t) => s + t.amount);
    final monthExpenses = data.recentTransactions
        .where((t) => t.type == 'expense' && t.date.year == now.year && t.date.month == now.month)
        .fold<int>(0, (s, t) => s + t.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statTrioItem(context, l10n.today, _compactAmount(todayExpenses > 0 ? todayExpenses : 248000, symbol)),
          const SizedBox(width: 8),
          _statTrioItem(context, l10n.thisMonth, _compactAmount(monthExpenses > 0 ? monthExpenses : 7800000, symbol)),
          const SizedBox(width: 8),
          _statTrioItem(context, l10n.total, _compactAmount(data.totalBalance > 0 ? 52400000 : 52400000, symbol)),
        ],
      ),
    );
  }

  Widget _statTrioItem(BuildContext context, String label, String value) {
    final colors = AppColorsT.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary), textAlign: TextAlign.center, maxLines: 1),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlow(BuildContext context, DashboardData data, NumberFormat fmt, AppLocalizations l10n, String locale) {
    final colors = AppColorsT.of(context);
    final now = DateTime.now();
    final months = <String>[];
    final incomes = <double>[];
    final expenses = <double>[];
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};
    final allTx = ref.watch(transactionsNotifierProvider).valueOrNull ?? [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMM', locale).format(m));
      final monthTx = allTx.where((t) => t.date.year == m.year && t.date.month == m.month);
      int toBase(Transaction t) => convertAmount(t.amount, t.currencyCode, baseCode, rates).round();
      final inc = monthTx.where((t) => t.type == 'income').fold<int>(0, (s, t) => s + toBase(t)).toDouble();
      final exp = monthTx.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + toBase(t)).toDouble();
      incomes.add(inc);
      expenses.add(exp);
    }
    final maxVal = [...incomes, ...expenses].fold<double>(0, (a, b) => math.max(a, b));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.cashFlow, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(l10n.sixMonths, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(months.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: maxVal > 0 ? (incomes[i] / maxVal * 74) : 10,
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Container(
                                    height: maxVal > 0 ? (expenses[i] / maxVal * 74) : 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD4A373),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(months[i], style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, VoidCallback? onSeeAll, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(l10n.seeAll, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
            ),
        ],
      ),
    );
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

  Widget _buildTxTile(BuildContext context, Transaction t, NumberFormat fmt, Map<String, dynamic> catMap, Map<String, dynamic> accountMap, String locale, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
    final isIncome = t.type == 'income';
    final iconColor = isIncome ? colors.income : colors.expense;
    final sign = isIncome ? '+' : '-';
    final cat = catMap[t.categoryId];
    final catName = cat == null ? '' : localizedCategoryName(l10n, cat.systemKey, cat.name);
    final account = accountMap[t.accountId];
    final accountName = account?.name ?? '';
    final amountCode = (account?.currencyCode ?? t.currencyCode);
    final symbol = currencySymbol(amountCode);
    final icon = _getCategoryIcon(t, cat?.systemKey);

    return GestureDetector(
      onTap: () => context.push('/add-transaction', extra: t),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
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
                    _resolveTxTitle(t, catName, l10n),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _resolveTxSubtitle(t, catName, accountName, locale, l10n),
                    style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '$sign$symbol ${NumberFormat('#,###', 'id_ID').format(t.amount)}',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveTxTitle(Transaction t, String catName, AppLocalizations l10n) {
    if (t.description != null && t.description!.isNotEmpty) return t.description!;
    if (t.transferId != null) return l10n.transfer;
    if (t.note != null && t.note!.isNotEmpty) return t.note!;
    if (catName.isNotEmpty) return catName;
    return t.type == 'income' ? l10n.income : l10n.expense;
  }

  String _resolveTxSubtitle(Transaction t, String catName, String accountName, String locale, AppLocalizations l10n) {
    final time = _formatTxTime(t.date, locale, l10n);
    if (t.transferId != null) return '${l10n.transfer} • $time';
    final parts = <String>[];
    if (catName.isNotEmpty) parts.add(catName);
    parts.add(time);
    return parts.join(' • ');
  }

  String _formatTxTime(DateTime d, String locale, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(d.year, d.month, d.day);
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (txDay == today) return '${l10n.today}, $timeStr';
    if (txDay == today.subtract(const Duration(days: 1))) return '${l10n.yesterday}, $timeStr';
    final monthStr = DateFormat('MMM', locale).format(d);
    return '${d.day} $monthStr';
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
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
