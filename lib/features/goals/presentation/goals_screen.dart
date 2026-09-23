import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/pocket_deposit_sheet.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/goals/presentation/goal_form_sheet.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key, this.paneOnly = false});

  /// When true, renders only the body (used inside the combined tabs screen).
  final bool paneOnly;

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String _short(int v, String locale) {
    final code = ref.read(baseCurrencyCodeProvider);
    return '${currencySymbol(code)} ${NumberFormat.compact(locale: locale).format(v)}';
  }

  String _full(int v, String locale) {
    final code = ref.read(baseCurrencyCodeProvider);
    return '${currencySymbol(code)} ${NumberFormat('#,##0', locale).format(v)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardShadow = isLight
        ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]
        : null;
    final goalsAsync = ref.watch(goalsNotifierProvider);
    final accounts = ref.watch(accountsNotifierProvider).valueOrNull ?? [];
    final transactions = ref.watch(transactionsNotifierProvider).valueOrNull ?? [];
    final transfers = ref.watch(transfersNotifierProvider).valueOrNull ?? [];
    final accountById = {for (final a in accounts) a.id: a};

    int goalProgress(Goal g) {
      final link = g.linkedAccountId;
      if (link == null || !accountById.containsKey(link)) return g.currentAmount;
      return BalanceCalculation.accountBalance(
        initialBalance: accountById[link]!.initialBalance,
        accountId: link,
        transactions: transactions,
        transfers: transfers,
      );
    }

    final content = goalsAsync.when(
      data: (goals) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: _buildGoals(goals, l10n, locale, colors, cardShadow, goalProgress),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
    );

    if (widget.paneOnly) return content;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.savingsTarget, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text(l10n.financialPlan, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => showGoalFormSheet(context),
            child: Text(l10n.addTarget, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primary)),
          ),
        ],
      ),
      body: content,
    );
  }

  List<Widget> _buildGoals(
    List<Goal> goals,
    AppLocalizations l10n,
    String locale,
    AppColorsT colors,
    List<BoxShadow>? shadow,
    int Function(Goal) goalProgress,
  ) {
    if (goals.isEmpty) return [_buildEmpty(colors, l10n)];
    final primary = goals.first;
    final secondary = goals.skip(1).take(2).toList();

    return [
      GestureDetector(
        onTap: () => showGoalFormSheet(context, edit: primary),
        child: _buildPriority(primary, l10n, locale, colors, shadow, goalProgress),
      ),
      const SizedBox(height: 12),
      if (secondary.isNotEmpty) _buildSecondaryRow(secondary, l10n, locale, colors, shadow, goalProgress),
    ];
  }

  Widget _buildPriority(Goal g, AppLocalizations l10n, String locale, AppColorsT colors, List<BoxShadow>? shadow, int Function(Goal) goalProgress) {
    final current = goalProgress(g);
    final pct = g.targetAmount > 0 ? (current / g.targetAmount).clamp(0.0, 1.0) : 0.0;
    final pctText = g.targetAmount > 0 ? (current / g.targetAmount * 100).round() : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.lilac.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, color: AppColors.lilac, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lilac.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lilac.withValues(alpha: 0.35)),
                ),
                child: Text(l10n.priority, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.lilac)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(g.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(_full(current, locale), style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: colors.border,
              color: AppColors.lilac,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(l10n.ofTarget('$pctText%', _short(g.targetAmount, locale)), style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(g.targetDate != null ? DateFormat('MMMM yyyy', locale).format(g.targetDate!) : '', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
            ],
          ),
          if (g.linkedAccountId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => showPocketDepositSheet(
                  context,
                  pocketId: g.linkedAccountId!,
                  pocketName: 'Kantong ${g.name}',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.savings_outlined, size: 16),
                label: Text('Setor', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryRow(List<Goal> secondary, AppLocalizations l10n, String locale, AppColorsT colors, List<BoxShadow>? shadow, int Function(Goal) goalProgress) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: secondary.map((g) {
        final current = goalProgress(g);
        final pct = g.targetAmount > 0 ? (current / g.targetAmount * 100).round() : 0;
        final pctValue = g.targetAmount > 0 ? (current / g.targetAmount).clamp(0.0, 1.0) : 0.0;
        return Expanded(
          child: GestureDetector(
            onTap: () => showGoalFormSheet(context, edit: g),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
                boxShadow: shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.lilac.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.savings_rounded, color: AppColors.lilac, size: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(g.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(_short(current, locale), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: pctValue,
                      backgroundColor: colors.border,
                      color: AppColors.lilac,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.progress(pct), style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
            child: const Icon(Icons.savings_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(l10n.noData, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
