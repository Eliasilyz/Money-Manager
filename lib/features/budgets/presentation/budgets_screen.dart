import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/core/widgets/pocket_deposit_sheet.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/budgets/presentation/budget_form_sheet.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key, this.paneOnly = false});

  final bool paneOnly;

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.sports_esports_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
    'tagihan': Icons.receipt_long_rounded,
    'gaji': Icons.account_balance_rounded,
    'investasi': Icons.trending_up_rounded,
  };

  static const _categoryBgColors = <String, Color>{
    'makan': Color(0xFFFDE8E4),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFF3E8FF),
    'kesehatan': Color(0xFFFCE7F3),
    'pendidikan': Color(0xFFE0F2FE),
    'tagihan': Color(0xFFEBF5FF),
  };

  static const _categoryIconColors = <String, Color>{
    'makan': Color(0xFFE76F51),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFEF4444),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF9333EA),
    'kesehatan': Color(0xFFEC4899),
    'pendidikan': Color(0xFF0284C7),
    'tagihan': Color(0xFF2563EB),
  };

  Color _getBgColor(String id) {
    for (final entry in _categoryBgColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFFE8F5E9);
  }

  Color _getIconColor(String id) {
    for (final entry in _categoryIconColors.entries) {
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

  Color _getProgressBarColor(int pct) {
    if (pct >= 90) return const Color(0xFFE63946);
    if (pct >= 70) return const Color(0xFFF4A261);
    return const Color(0xFF2A9D8F);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final transfers = ref.watch(transfersNotifierProvider).valueOrNull ?? [];
    final accounts = accountsAsync.valueOrNull ?? [];
    final transactions = transactionsAsync.valueOrNull ?? [];
    final accountById = {for (final a in accounts) a.id: a};

    final pocketBySystemKey = <String, String>{};
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

    final monthLabel = DateFormat('MMMM yyyy', 'id').format(now);

    final content = budgetsAsync.when(
      data: (budgets) {
        if (budgets.isEmpty) return _buildEmpty(colors, l10n);
        final totalBudget = budgets.fold<int>(0, (s, b) => s + b.amount);
        final totalSpent = spentByCat.values.fold<int>(0, (sum, v) => sum + v);
        final totalRemaining = (totalBudget - totalSpent).clamp(0, totalBudget);
        final totalPct = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

        // Find highest percentage budget for attention callout
        String? highestCatName;
        int highestPct = 0;
        for (final b in budgets) {
          final spent = spentByCat[b.categoryId] ?? 0;
          final pct = b.amount > 0 ? (spent / b.amount * 100).round() : 0;
          if (pct > highestPct) {
            highestPct = pct;
            highestCatName = catNames[b.categoryId] ?? b.categoryId;
          }
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // Hero Card: Sisa Anggaran
            Container(
              width: double.infinity,
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
                    l10n.budgetRemainingThisMonth,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(totalRemaining, currencyCode: baseCode),
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalPct,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: totalPct >= 0.9 ? const Color(0xFFEF4444) : (totalPct >= 0.7 ? const Color(0xFFF59E0B) : Colors.white),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.spent(formatCurrency(totalSpent, currencyCode: baseCode), formatCurrency(totalBudget, currencyCode: baseCode)),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.perCategory,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  l10n.budgetCount(budgets.length),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Budget Items
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
                    child: _buildBudgetCard(
                      context,
                      catName: catName,
                      spent: spent,
                      total: b.amount,
                      pct: pct,
                      bgColor: _getBgColor(b.categoryId),
                      iconColor: _getIconColor(b.categoryId),
                      icon: _getIcon(b.categoryId),
                      baseCode: baseCode,
                      colors: colors,
                    ),
                  ),
                  if (pocketId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPocketRow(
                        context,
                        pocketId,
                        pocketNames[pocketId] ?? '',
                        pocketBalance(pocketId),
                        () => showPocketDepositSheet(
                          context,
                          pocketId: pocketId,
                          pocketName: pocketNames[pocketId] ?? '',
                        ),
                        baseCode,
                      ),
                    ),
                ],
              );
            }),

            const SizedBox(height: 8),

            // Attention Callout (matches Screen 4 bottom callout)
            if (highestCatName != null && highestPct >= 70)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3E2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF92400E)),
                          children: [
                            TextSpan(text: '${l10n.attention}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: l10n.budgetAttentionWarning(highestCatName, highestPct)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
      error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: Colors.red))),
    );

    if (paneOnly) return content;

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
              l10n.budgets,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              monthLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: () => showBudgetFormSheet(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l10n.create,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBudgetCard(
    BuildContext context, {
    required String catName,
    required int spent,
    required int total,
    required int pct,
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
    required String baseCode,
    required AppColorsT colors,
  }) {
    final progressColor = _getProgressBarColor(pct);
    final badgeBg = pct >= 90
        ? const Color(0xFFFEE2E2)
        : (pct >= 70 ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5E9));
    final badgeTextColor = pct >= 90
        ? const Color(0xFFB91C1C)
        : (pct >= 70 ? const Color(0xFFB45309) : const Color(0xFF15803D));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatCurrency(spent, currencyCode: baseCode)} / ${formatCurrency(total, currencyCode: baseCode)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pct%',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? (spent / total).clamp(0.0, 1.0) : 0,
              backgroundColor: colors.border.withValues(alpha: 0.5),
              color: progressColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPocketRow(
    BuildContext context,
    String pocketId,
    String pocketName,
    int balance,
    VoidCallback onDeposit,
    String baseCode,
  ) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.savings_rounded, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.pocketLabel(pocketName, formatCurrency(balance, currencyCode: baseCode)),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onDeposit,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                l10n.deposit,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.pie_chart_outline_rounded, size: 32, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(l10n.noBudgets, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
