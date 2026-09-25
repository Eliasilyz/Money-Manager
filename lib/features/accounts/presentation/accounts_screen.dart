import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const _typeIcons = {
    'wallet': (Icons.account_balance_wallet_rounded, Color(0xFFEFECFA), Color(0xFF8B5CF6)),
    'savings': (Icons.savings_rounded, Color(0xFFE1F1EA), Color(0xFF1B6E4B)),
    'credit': (Icons.credit_card_rounded, Color(0xFFFEE2E2), Color(0xFFEF4444)),
    'cash': (Icons.payments_rounded, Color(0xFFFEF3E2), Color(0xFFF59E0B)),
    'investment': (Icons.trending_up_rounded, Color(0xFFE8F0FA), Color(0xFF3B82F6)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            final active = accounts.where((a) => !a.isArchived).toList();
            if (active.isEmpty) return _buildEmpty(context, l10n);

            final transactions = transactionsAsync.valueOrNull ?? [];
            final transfers = ref.watch(transfersNotifierProvider).valueOrNull ?? [];

            final accountBalances = <String, int>{};
            for (final a in active) {
              accountBalances[a.id] = BalanceCalculation.accountBalance(
                initialBalance: a.initialBalance,
                accountId: a.id,
                transactions: transactions,
                transfers: transfers,
              );
            }

            final totalBalance = accountBalances.entries.fold<int>(
              0,
              (sum, e) => sum +
                  convertAmount(
                    e.value,
                    active.firstWhere((a) => a.id == e.key).currencyCode,
                    baseCode,
                    rates,
                  ).round(),
            );

            // Find the primary account (BCA Utama or first)
            final primaryAccount = active.isNotEmpty ? active.first : null;
            final primaryAccountTx = primaryAccount != null
                ? (transactions.where((t) => t.accountId == primaryAccount.id).toList()..sort((a, b) => b.date.compareTo(a.date)))
                : <dynamic>[];

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                // Header with title and + Akun button
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.accountsTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.accountsSubtitle(active.length),
                              style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.push('/add-account'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                                l10n.addAccount,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Total Saldo Bersih Hero Card
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
                        l10n.totalNetBalance,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency(totalBalance, currencyCode: baseCode),
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => context.push('/add-transfer'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.transfer,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => context.push('/manage-accounts'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.manage,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Daftar Akun section
                Text(
                  l10n.accountList,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Account cards
                ...active.map((a) {
                  final balance = accountBalances[a.id] ?? a.initialBalance;
                  final cfg = _typeIcons[a.accountType] ??
                      (Icons.account_circle_rounded, const Color(0xFFE1F1EA), const Color(0xFF1B6E4B));
                  final txCount = transactions.where((t) => t.accountId == a.id).length;
                  final isNegative = balance < 0;
                  final isInvestment = a.accountType == 'investment';

                  return GestureDetector(
                    onTap: () => context.push('/add-account', extra: a),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cfg.$2,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(cfg.$1, color: cfg.$3, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.name,
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
                                  l10n.transactionCount(txCount),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(balance, currencyCode: a.currencyCode),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isNegative
                                      ? const Color(0xFFEF4444)
                                      : isInvestment
                                          ? const Color(0xFF2A9D8F)
                                          : colors.textPrimary,
                                ),
                              ),
                              if (isInvestment) ...[
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.trending_up_rounded, size: 12, color: Color(0xFF2A9D8F)),
                                    const SizedBox(width: 2),
                                    Text(
                                      l10n.accountTypeInvestment,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2A9D8F),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (isNegative) ...[
                                const SizedBox(height: 2),
                                Text(
                                  l10n.negative,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Riwayat section for primary account
                if (primaryAccount != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.accountHistoryOf(primaryAccount.name),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/transactions'),
                        child: Text(
                          l10n.seeAll,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (primaryAccountTx.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.noTransactions,
                        style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    ...primaryAccountTx.take(5).map((t) {
                      final isIncome = t.type == 'income';
                      final txColor = isIncome ? const Color(0xFF2A9D8F) : const Color(0xFFEF4444);
                      final iconBg = isIncome ? const Color(0xFFE8F5F3) : const Color(0xFFFEE2E2);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: txColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.description ?? (isIncome ? l10n.income : l10n.expense),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatDate(t.date),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isIncome ? '+' : '-'}${formatCurrency(t.amount, currencyCode: t.currencyCode)}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: txColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Kemarin';
    }
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    final colors = AppColorsT.of(context);
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
            child: Icon(Icons.account_balance_wallet_outlined, size: 32, color: colors.primary),
          ),
          const SizedBox(height: 16),
          Text(l10n.noAccounts, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/add-account'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+ Tambah Akun',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
