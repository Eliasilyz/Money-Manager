import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/theme/app_theme.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const _typeConfig = {
    'wallet': ('Dompet', Icons.account_balance_wallet_outlined, AppColors.gold),
    'savings': ('Tabungan', Icons.savings_outlined, AppColors.sky),
    'credit': ('Kartu Kredit', Icons.credit_card_outlined, AppColors.rose),
    'cash': ('Tunai', Icons.payments_outlined, AppColors.orange),
    'investment': ('Investasi', Icons.trending_up_rounded, AppColors.lilac),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return _buildEmpty(context);
          }

          final grouped = <String, List<dynamic>>{};
          for (final a in accounts) {
            grouped.putIfAbsent(a.accountType, () => []).add(a);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _buildTotalBalance(context, accounts),
              const SizedBox(height: 24),
              for (final entry in grouped.entries) ...[
                _buildSectionHeader(entry.key),
                const SizedBox(height: 8),
                ...entry.value.map((a) => _buildAccountTile(context, ref, a)),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-account'),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        icon: const Icon(Icons.add),
        label: Text('Tambah Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 32, color: AppColors.textDisabled),
          ),
          const SizedBox(height: 16),
          Text('Belum ada akun', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Tap + untuk membuat akun pertama', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTotalBalance(BuildContext context, List<Account> accounts) {
    final total = accounts.fold<int>(0, (sum, a) => sum + a.initialBalance);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        color: AppColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL SALDO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(
            fmt.format(total),
            style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String type) {
    final config = _typeConfig[type];
    final label = config?.$1 ?? type.toUpperCase();
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8),
    );
  }

  Widget _buildAccountTile(BuildContext context, WidgetRef ref, Account account) {
    final config = _typeConfig[account.accountType];
    final color = config?.$3 ?? AppColors.gold;
    final icon = config?.$2 ?? Icons.account_balance_wallet_outlined;
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Dismissible(
          key: ValueKey(account.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.rose,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Akun?'),
                content: Text('"${account.name}" akan dihapus permanen.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Hapus', style: GoogleFonts.inter(color: AppColors.rose)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            ref.read(accountsNotifierProvider.notifier).deleteAccount(account.id);
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              account.name,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              account.currencyCode,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
            ),
            trailing: Text(
              fmt.format(account.initialBalance),
              style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
