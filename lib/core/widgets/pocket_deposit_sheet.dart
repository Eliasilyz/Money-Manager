import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

/// Bottom sheet: transfer money from a normal account into a pocket account.
Future<void> showPocketDepositSheet(
  BuildContext context, {
  required String pocketId,
  required String pocketName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PocketDepositSheet(pocketId: pocketId, pocketName: pocketName),
  );
}

class PocketDepositSheet extends ConsumerStatefulWidget {
  const PocketDepositSheet({super.key, required this.pocketId, required this.pocketName});

  final String pocketId;
  final String pocketName;

  @override
  ConsumerState<PocketDepositSheet> createState() => _PocketDepositSheetState();
}

class _PocketDepositSheetState extends ConsumerState<PocketDepositSheet> {
  final _amountCtrl = TextEditingController();
  String? _fromAccountId;
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final accounts = accountsAsync.valueOrNull ?? <Account>[];
    final sources = accounts
        .where((a) => !a.isArchived && a.id != widget.pocketId && a.systemKey == null)
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Setor ke ${widget.pocketName}',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.jetBrainsMono(fontSize: 16, color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: l10n.nominalLabel,
                hintText: '0',
                prefixText: 'Rp ',
                prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _fromAccountId,
              dropdownColor: colors.surfaceRaised,
              hint: Text(l10n.selectFromAccount, style: GoogleFonts.inter(color: colors.textSecondary)),
              items: sources
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _fromAccountId = val),
              decoration: InputDecoration(
                labelText: l10n.fromAccount,
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.transfer, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _fromAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectAccountAndAmount, style: GoogleFonts.inter())),
      );
      return;
    }
    final from = ref.read(accountsNotifierProvider).valueOrNull?.where((a) => a.id == _fromAccountId).firstOrNull;
    setState(() => _saving = true);
    try {
      await ref.read(transactionServiceProvider).addTransfer(
            fromAccountId: _fromAccountId!,
            toAccountId: widget.pocketId,
            amount: amount,
            currencyCode: from?.currencyCode ?? 'IDR',
            description: 'Setor ${widget.pocketName}',
          );
      await ref.read(transfersNotifierProvider.notifier).loadTransfers();
      ref.read(accountsNotifierProvider.notifier).loadAccounts();
      ref.invalidate(dashboardProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
