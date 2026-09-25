import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:money_manager/theme/app_theme.dart';

class ManageAccountsScreen extends ConsumerStatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  ConsumerState<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends ConsumerState<ManageAccountsScreen> {
  static const _typeIcons = {
    'wallet': (Icons.account_balance_wallet_outlined, Color(0xFFEFECFA), Color(0xFF8B5CF6)),
    'savings': (Icons.savings_outlined, Color(0xFFE1F1EA), Color(0xFF1B6E4B)),
    'credit': (Icons.credit_card_outlined, Color(0xFFFBE7E7), Color(0xFFE0524A)),
    'cash': (Icons.payments_outlined, Color(0xFFFEF3E2), Color(0xFFF59E0B)),
    'investment': (Icons.trending_up_rounded, Color(0xFFE8F0FA), Color(0xFF3B82F6)),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final transactionsAsync = ref.watch(transactionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAccounts, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_accounts_fab',
        onPressed: () => context.push('/add-account'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) return _buildEmpty(colors, l10n);

          final transactions = transactionsAsync.valueOrNull ?? [];
          final sorted = List<Account>.from(accounts)
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final active = sorted.where((a) => !a.isArchived).toList();
          final archived = sorted.where((a) => a.isArchived).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              if (active.isNotEmpty) ...[
                _sectionHeader(l10n.activeAccounts, active.length, colors, l10n),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: active.length,
                  onReorderItem: (oldIdx, newIdx) => _onReorderItem(active, oldIdx, newIdx),
                  itemBuilder: (ctx, index) => _accountTile(active[index], transactions, colors, l10n),
                ),
              ],
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 16),
                _sectionHeader(l10n.archivedAccounts, archived.length, colors, l10n),
                ...archived.map((a) => _accountTile(a, transactions, colors, l10n)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  void _onReorderItem(List<Account> activeList, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= activeList.length || newIndex < 0 || newIndex >= activeList.length) return;
    final item = activeList.removeAt(oldIndex);
    activeList.insert(newIndex, item);

    final orders = <({String id, int sortOrder})>[];
    for (var i = 0; i < activeList.length; i++) {
      orders.add((id: activeList[i].id, sortOrder: i));
    }
    ref.read(accountsNotifierProvider.notifier).updateSortOrders(orders);
  }

  Widget _sectionHeader(String title, int count, AppColorsT colors, AppLocalizations l10n) {
    return Padding(
      key: ValueKey('section_$title'),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        '$title (${l10n.transactionCount(count)})',
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
      ),
    );
  }

  Widget _accountTile(Account account, List<Transaction> transactions, AppColorsT colors, AppLocalizations l10n) {
    final cfg = _typeIcons[account.accountType] ?? (Icons.account_circle_outlined, const Color(0xFFE1F1EA), const Color(0xFF1B6E4B));
    final txCount = transactions.where((t) => t.accountId == account.id).length;

    return Container(
      key: ValueKey(account.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: cfg.$2, borderRadius: BorderRadius.circular(12)),
          child: Icon(cfg.$1, color: cfg.$3, size: 20),
        ),
        title: Text(account.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        subtitle: Text(l10n.transactionCount(txCount), style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!account.isArchived)
              const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.more_vert, color: colors.textSecondary, size: 20),
              onPressed: () => _showActions(account, transactions, colors, l10n),
            ),
          ],
        ),
        onTap: () => _showActions(account, transactions, colors, l10n),
      ),
    );
  }

  void _showActions(Account account, List<Transaction> transactions, AppColorsT colors, AppLocalizations l10n) {
    final txCount = transactions.where((t) => t.accountId == account.id).length;
    final hasTransactions = txCount > 0;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(account.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: colors.primary),
              title: Text(l10n.editAccount, style: GoogleFonts.inter(fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/add-account', extra: account);
              },
            ),
            if (!account.isArchived)
              ListTile(
                leading: const Icon(Icons.tune, color: AppColors.sky),
                title: Text(l10n.adjustBalance, style: GoogleFonts.inter(fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAdjustBalance(account, colors, l10n);
                },
              ),
            if (!account.isArchived)
              ListTile(
                leading: Icon(Icons.archive_outlined, color: Colors.orange.shade700),
                title: Text(l10n.archiveAccount, style: GoogleFonts.inter(fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(accountsNotifierProvider.notifier).archiveAccount(account.id, true);
                },
              ),
            if (account.isArchived)
              ListTile(
                leading: const Icon(Icons.unarchive_outlined, color: AppColors.teal),
                title: Text(l10n.activateAccount, style: GoogleFonts.inter(fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(accountsNotifierProvider.notifier).archiveAccount(account.id, false);
                },
              ),
            if (!hasTransactions)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.rose),
                title: Text(l10n.deleteAccountTitle, style: GoogleFonts.inter(fontSize: 14, color: AppColors.rose)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(account, colors, l10n);
                },
              ),
            if (hasTransactions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  l10n.accountHasTransactions(txCount),
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Account account, AppColorsT colors, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(l10n.deleteAccountConfirm(account.name), style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(accountsNotifierProvider.notifier).deleteAccount(account.id);
              ref.invalidate(dashboardProvider);
            },
            child: Text(l10n.delete, style: GoogleFonts.inter(color: AppColors.rose, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAdjustBalance(Account account, AppColorsT colors, AppLocalizations l10n) {
    final transactions = ref.read(transactionsNotifierProvider).valueOrNull ?? [];
    final transfers = ref.read(transfersNotifierProvider).valueOrNull ?? [];
    final currentBalance = BalanceCalculation.accountBalance(
      initialBalance: account.initialBalance,
      accountId: account.id,
      transactions: transactions,
      transfers: transfers,
    );

    final targetCtrl = TextEditingController(text: currentBalance.toString());
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adjustBalance, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.currentBalance}: ${fmt.format(currentBalance)}', style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
            const SizedBox(height: 12),
            Text(l10n.balanceTarget, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.jetBrainsMono(fontSize: 18, color: colors.textPrimary),
              autofocus: true,
              decoration: const InputDecoration(prefixText: 'Rp '),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.adjustmentNote,
              style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              final target = int.tryParse(targetCtrl.text.replaceAll(RegExp(r'[^0-9\-]'), ''));
              if (target == null) return;
              Navigator.pop(ctx);
              _applyAdjustment(account, currentBalance, target, l10n);
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }

  Future<void> _applyAdjustment(Account account, int currentBalance, int targetBalance, AppLocalizations l10n) async {
    final diff = targetBalance - currentBalance;
    if (diff == 0) return;

    final service = ref.read(transactionServiceProvider);
    if (diff > 0) {
      await service.addIncome(
        accountId: account.id,
        amount: diff,
        currencyCode: account.currencyCode,
        description: l10n.balanceAdjustmentDesc,
        date: DateTime.now(),
      );
    } else {
      await service.addExpense(
        accountId: account.id,
        amount: diff.abs(),
        currencyCode: account.currencyCode,
        description: l10n.balanceAdjustmentDesc,
        date: DateTime.now(),
      );
    }

    ref.read(transactionsNotifierProvider.notifier).loadTransactions();
    ref.read(accountsNotifierProvider.notifier).loadAccounts();
    ref.invalidate(dashboardProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.balanceAdjusted, style: GoogleFonts.inter())),
      );
    }
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
          Text(l10n.noAccounts, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
