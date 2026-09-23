import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/core/widgets/pocket_deposit_sheet.dart';
import 'package:money_manager/features/budgets/presentation/budget_form_sheet.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key, this.paneOnly = false});

  /// When true, renders only the body (used inside the combined tabs screen).
  final bool paneOnly;

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.movie_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
    'gaji': Icons.account_balance_rounded,
    'investasi': Icons.trending_up_rounded,
  };

  static const _categoryColors = <String, Color>{
    'makan': Color(0xFFE1F1EA),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFE1F1EA),
    'kesehatan': Color(0xFFFBE7E7),
    'pendidikan': Color(0xFFE8F0FA),
    'gaji': Color(0xFFE1F1EA),
    'investasi': Color(0xFFEFECFA),
  };

  static const _iconColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF1B6E4B),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
    'gaji': Color(0xFF1B6E4B),
    'investasi': Color(0xFF8B5CF6),
  };

  Color _getProgressBarColor(int pct) {
    if (pct >= 90) return AppColors.rose;
    if (pct >= 70) return AppColors.orange;
    return const Color(0xFF1E9E63);
  }

  Color _getColor(String id) {
    for (final entry in _categoryColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFFE1F1EA);
  }

  Color _getIconColor(String id) {
    for (final entry in _iconColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFF1B6E4B);
  }

  IconData _getIcon(String id) {
    for (final entry in _categoryIcons.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return Icons.category_rounded;
  }

  String _short(int v, String locale, String symbol) =>
      '$symbol ${NumberFormat.compact(locale: locale).format(v)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardShadow = isLight
        ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]
        : null;
    final now = DateTime.now();
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final symbol = currencySymbol(baseCode);
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final transfers = ref.watch(transfersNotifierProvider).valueOrNull ?? [];
    final accounts = accountsAsync.valueOrNull ?? [];
    final transactions = transactionsAsync.valueOrNull ?? [];
    final accountById = {for (final a in accounts) a.id: a};
    final pocketBySystemKey = <String, String>{}; // systemKey -> accountId
    final pocketNames = <String, String>{};
    for (final a in accounts) {
      final key = a.systemKey;
      if (key != null) {
        pocketBySystemKey[key] = a.id;
        pocketNames[a.id] = a.name;
      }
    }
    int pocketBalance(String accountId) => BalanceCalculation.accountBalance(
          initialBalance: accountById[accountId]?.initialBalance ?? 0,
          accountId: accountId,
          transactions: transactions,
          transfers: transfers,
        );
    final catNames = categoriesAsync.whenOrNull(
          data: (cats) => {for (final c in cats) c.id: localizedCategoryName(l10n, c.systemKey, c.name)},
        ) ??
        const <String, String>{};

    // Calculate spent per category for current month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final spentByCat = <String, int>{};
    for (final t in transactions) {
      if (t.type == 'expense' && t.categoryId != null && t.date.isAfter(startOfMonth)) {
        spentByCat[t.categoryId!] = (spentByCat[t.categoryId!] ?? 0) + t.amount;
      }
    }
    final fmt = NumberFormat.currency(symbol: '$symbol ', decimalDigits: currencyDigits(baseCode));
    final monthLabel = DateFormat('MMMM yyyy', locale).format(now);

    final content = budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) return _buildEmpty(colors, l10n);
          final totalBudget = budgets.fold<int>(0, (s, b) => s + b.amount);
          final totalSpent = spentByCat.values.fold<int>(0, (sum, v) => sum + v);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.heroCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: colors.heroCard.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalBudgetRemaining, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 6),
                    Text(fmt.format(totalBudget - totalSpent), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        color: AppColors.orange,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.spent(_short(totalSpent, locale, symbol), _short(totalBudget, locale, symbol)),
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.perCategory, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  Text(l10n.budgetCount(budgets.length), style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...budgets.map((b) {
                final catName = catNames[b.categoryId] ?? b.categoryId;
                final spent = spentByCat[b.categoryId] ?? 0;
                final pct = b.amount > 0 ? (spent / b.amount * 100).round() : 0;
                final pocketId = pocketBySystemKey['pocket:budget:${b.id}'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () => showBudgetFormSheet(context, edit: b),
                      child: _buildBudgetTile(context, catName, spent, b.amount, pct, _getColor(b.categoryId), _getIconColor(b.categoryId), _getIcon(b.categoryId), l10n, locale, cardShadow, symbol),
                    ),
                    if (pocketId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildPocketRow(
                          context,
                          pocketId,
                          pocketNames[pocketId] ?? '',
                          pocketBalance(pocketId),
                          () => showPocketDepositSheet(context, pocketId: pocketId, pocketName: pocketNames[pocketId] ?? ''),
                          fmt,
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.attention, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      );

    if (paneOnly) return content;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetsTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text(monthLabel, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => showBudgetFormSheet(context),
            child: Text(l10n.addBudget, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primary)),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBudgetTile(BuildContext context, String catName, int spent, int total, int pct, Color bgColor, Color iconColor, IconData icon, AppLocalizations l10n, String locale, List<BoxShadow>? shadow, String symbol) {
    final colors = AppColorsT.of(context);
    final progressColor = _getProgressBarColor(pct);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(catName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('$pct%', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: progressColor)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.spent(_short(spent, locale, symbol), _short(total, locale, symbol)), style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? (spent / total).clamp(0.0, 1.0) : 0,
              backgroundColor: colors.border,
              color: progressColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPocketRow(BuildContext context, String pocketId, String pocketName, int balance, VoidCallback onDeposit, NumberFormat fmt) {
    final colors = AppColorsT.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.savings_outlined, size: 16, color: AppColors.gold),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Kantong $pocketName • ${fmt.format(balance)}',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onDeposit,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
            child: Text('Setor', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
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
            child: const Icon(Icons.account_balance_wallet_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(l10n.noBudgets, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
