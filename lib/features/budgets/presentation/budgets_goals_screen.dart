import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/core/widgets/pocket_deposit_sheet.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/presentation/budget_form_sheet.dart';
import 'package:money_manager/features/budgets/presentation/budgets_screen.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/goals/presentation/goal_form_sheet.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

/// Combined screen: Anggaran | Target Tabungan | Hutang tabs (Screen 4 & 5).
class BudgetsGoalsScreen extends ConsumerStatefulWidget {
  const BudgetsGoalsScreen({super.key});

  @override
  ConsumerState<BudgetsGoalsScreen> createState() => _BudgetsGoalsScreenState();
}

class _BudgetsGoalsScreenState extends ConsumerState<BudgetsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAddPressed() {
    switch (_tab) {
      case 0:
        showBudgetFormSheet(context);
        break;
      case 1:
        showGoalFormSheet(context);
        break;
      case 2:
        context.push('/add-debt');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);

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
              _tab == 0 ? l10n.budgets : (_tab == 1 ? l10n.savingsTarget : l10n.debts),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _tab == 0 ? l10n.monthlyFinancialPlan : (_tab == 1 ? l10n.realizeYourDreams : l10n.manageDebtsAndReceivables),
              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: _onAddPressed,
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
                        _tab == 0 ? l10n.create : l10n.add,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: colors.primary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: l10n.budgets),
                Tab(text: l10n.goals),
                Tab(text: l10n.debts),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const BudgetsScreen(paneOnly: true),
          _GoalsPane(ref: ref),
          _DebtsPane(ref: ref),
        ],
      ),
    );
  }
}

// ─── Goals Pane (Screen 5 - Target Tabungan) ─────────────────────────────────

class _GoalsPane extends ConsumerWidget {
  const _GoalsPane({required this.ref});
  // ignore: unused_field
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
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

    return goalsAsync.when(
      data: (goals) {
        final active = goals.where((g) => g.status == 'active').toList();
        if (active.isEmpty) {
          return _buildEmpty(colors, l10n);
        }

        // Priority card: select goal marked isPriority == true, or fallback to first goal
        final priorityGoals = active.where((g) => g.isPriority).toList();
        final Goal primary = priorityGoals.isNotEmpty ? priorityGoals.first : active.first;
        final secondaryGoals = active.where((g) => g.id != primary.id).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            GestureDetector(
              onTap: () => showGoalFormSheet(context, edit: primary),
              child: _buildPriorityCard(context, ref, primary, goalProgress, colors, baseCode),
            ),
            if (secondaryGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSecondaryGrid(context, ref, secondaryGoals, goalProgress, colors, baseCode),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
      error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter())),
    );
  }

  Future<void> _togglePriority(WidgetRef ref, Goal g) async {
    final updated = g.copyWith(isPriority: !g.isPriority, updatedAt: DateTime.now());
    await ref.read(goalsNotifierProvider.notifier).updateGoal(updated);
  }

  Widget _buildPriorityCard(
    BuildContext context,
    WidgetRef ref,
    Goal g,
    int Function(Goal) goalProgress,
    AppColorsT colors,
    String baseCode,
  ) {
    final l10n = AppLocalizations.of(context);
    final current = goalProgress(g);
    final pct = g.targetAmount > 0 ? (current / g.targetAmount).clamp(0.0, 1.0) : 0.0;
    final pctInt = (pct * 100).round();

    // Purple gradient matching the mockup
    const purpleStart = Color(0xFF7C3AED);
    const purpleEnd = Color(0xFF5B21B6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [purpleStart, purpleEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: purpleStart.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _togglePriority(ref, g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(g.isPriority ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        l10n.priority,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            g.name,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(current, currencyCode: baseCode),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                l10n.progressPercentOfTarget(pctInt),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Text(
                formatCurrency(g.targetAmount, currencyCode: baseCode),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          if (g.linkedAccountId != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => showPocketDepositSheet(
                  context,
                  pocketId: g.linkedAccountId!,
                  pocketName: l10n.pocketName(g.name),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.savings_outlined, size: 16),
                label: Text(l10n.deposit, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryGrid(
    BuildContext context,
    WidgetRef ref,
    List<Goal> goals,
    int Function(Goal) goalProgress,
    AppColorsT colors,
    String baseCode,
  ) {
    // Two-column grid with 0.83 aspect ratio to prevent overflow
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.83,
      ),
      itemCount: goals.length,
      itemBuilder: (ctx, index) {
        final g = goals[index];
        final current = goalProgress(g);
        final pct = g.targetAmount > 0 ? (current / g.targetAmount).clamp(0.0, 1.0) : 0.0;
        final pctInt = (pct * 100).round();

        final cardColors = [
          const Color(0xFF2A9D8F), // teal
          const Color(0xFF457B9D), // blue
          const Color(0xFFE76F51), // orange
          const Color(0xFF8B5CF6), // purple
        ];
        final cardColor = cardColors[index % cardColors.length];

        return GestureDetector(
          onTap: () => showGoalFormSheet(context, edit: g),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.savings_rounded, color: cardColor, size: 18),
                    ),
                    InkWell(
                      onTap: () => _togglePriority(ref, g),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          g.isPriority ? Icons.star_rounded : Icons.star_border_rounded,
                          color: g.isPriority ? AppColors.gold : colors.textSecondary.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  g.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(current, currencyCode: baseCode),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: colors.border,
                    color: cardColor,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$pctInt%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            child: Icon(Icons.savings_outlined, size: 32, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(l10n.noSavingsGoals, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 6),
          Text(l10n.tapAddGoal, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Debts Pane (Screen 5 - Hutang section) ─────────────────────────────────

class _DebtsPane extends ConsumerWidget {
  const _DebtsPane({required this.ref});
  // ignore: unused_field
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final debtsAsync = ref.watch(debtsNotifierProvider);

    return debtsAsync.when(
      data: (debts) {
        final active = debts.where((d) => d.status != 'paid').toList();
        final totalRemaining = active.fold<int>(0, (s, d) => s + d.remainingAmount);

        if (active.isEmpty) {
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
                  child: Icon(Icons.money_off_rounded, size: 32, color: colors.primary),
                ),
                const SizedBox(height: 16),
                Text(l10n.noActiveDebts, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Ringkasan hutang header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.debtSummary,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.activeCount(active.length),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.totalDebtRemaining,
                    style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(totalRemaining, currencyCode: baseCode),
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l10n.debtList,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...active.map((d) {
              final isBorrowed = d.type == 'borrowed';
              final isOverdue = d.dueDate.isBefore(DateTime.now());
              final typeColor = isBorrowed ? const Color(0xFFEF4444) : const Color(0xFF2A9D8F);
              final typeBg = isBorrowed ? const Color(0xFFFEE2E2) : const Color(0xFFE8F5E3);
              final typeLabel = isBorrowed ? l10n.debtTypeBorrowed : l10n.debtTypeLent;

              return GestureDetector(
                onTap: () => context.push('/add-debt', extra: d),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: typeBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isBorrowed ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                          color: typeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    d.personName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: typeBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    typeLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: typeColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(d.remainingAmount, currencyCode: baseCode),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.dueDateWithDate(DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode).format(d.dueDate)),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isOverdue ? const Color(0xFFEF4444) : colors.textSecondary,
                                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
      error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
    );
  }
}
