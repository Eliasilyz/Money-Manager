import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const _typeConfig = {
    'wallet': ('Dompet', Icons.account_balance_wallet_outlined, Color(0xFFEFECFA), Color(0xFF8B5CF6)),
    'savings': ('Tabungan', Icons.savings_outlined, Color(0xFFE1F1EA), Color(0xFF1B6E4B)),
    'credit': ('Kartu Kredit', Icons.credit_card_outlined, Color(0xFFFBE7E7), Color(0xFFE0524A)),
    'cash': ('Tunai', Icons.payments_outlined, Color(0xFFFEF3E2), Color(0xFFF59E0B)),
    'investment': ('Investasi', Icons.trending_up_rounded, Color(0xFFE8F0FA), Color(0xFF3B82F6)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) return _buildEmpty(context);
            final transactions = transactionsAsync.valueOrNull ?? [];
            final accountBalances = <String, int>{};
            for (final a in accounts) {
              final txForAccount = transactions.where((t) => t.accountId == a.id);
              final income = txForAccount.where((t) => t.type == 'income').fold<int>(0, (sum, t) => sum + t.amount);
              final expense = txForAccount.where((t) => t.type == 'expense').fold<int>(0, (sum, t) => sum + t.amount);
              accountBalances[a.id] = a.initialBalance + income - expense;
            }
            final totalBalance = accountBalances.values.fold<int>(0, (sum, b) => sum + b);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Akun', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                        Text('${accounts.length} akun terhubung', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                      ],
                    ),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.push('/add-account'),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text('Tambah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.filter_list_rounded, color: colors.textSecondary, size: 22),
                          tooltip: 'Filter',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNetWorthCard(totalBalance, fmt, colors),
                const SizedBox(height: 16),
                _buildActionButtons(context, colors),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daftar akun', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    TextButton(
                      onPressed: () {},
                      child: Text('Kelola', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ...accounts.map((a) {
                  final balance = accountBalances[a.id] ?? a.initialBalance;
                  final cfg = _typeConfig[a.accountType] ?? ('Lainnya', Icons.account_circle_outlined, const Color(0xFFE1F1EA), const Color(0xFF1B6E4B));
                  final txCount = transactions.where((t) => t.accountId == a.id).length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: cfg.$3, borderRadius: BorderRadius.circular(12)),
                          child: Icon(cfg.$2, color: cfg.$4, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                              Text('${cfg.$1} • $txCount transaksi', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          fmt.format(balance),
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: balance >= 0 ? colors.textPrimary : AppColors.rose),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(int totalBalance, NumberFormat fmt, AppColorsT colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors.primaryDark.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kekayaan bersih', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 6),
          Text(fmt.format(totalBalance), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.teal, size: 16),
              const SizedBox(width: 4),
              Text('+4,8% bulan ini', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppColorsT colors) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/add-account'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: colors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('+ Tambah akun', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz_rounded, color: colors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Pindah saldo', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = AppColorsT.of(context);
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
          Text('Belum ada akun', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
