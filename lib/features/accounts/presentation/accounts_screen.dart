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
      appBar: AppBar(
        title: Text('Akun & Dompet', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/add-account'),
              icon: const Icon(Icons.add, size: 16),
              label: Text('Akun', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: accountsAsync.when(
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('${accounts.length} akun aktif • kelola saldo & detail', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primaryDark, colors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total saldo bersih', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 6),
                    Text(fmt.format(totalBalance), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Diperbarui baru saja', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daftar akun', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Atur', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
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
                    border: Border.all(color: colors.border),
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