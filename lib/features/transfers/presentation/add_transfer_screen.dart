import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart' show currencySymbol;
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddTransferScreen extends ConsumerStatefulWidget {
  const AddTransferScreen({super.key});

  @override
  ConsumerState<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends ConsumerState<AddTransferScreen> {
  AppColorsT get colors => AppColorsT.of(context);
  String? _fromAccountId;
  String? _toAccountId;
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _exchangeRateCtrl = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _exchangeRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final accounts = accountsAsync.valueOrNull ?? const [];
    final fromAccount = accounts.where((a) => a.id == _fromAccountId).firstOrNull;
    final fromSymbol = fromAccount == null ? '' : '${currencySymbol(fromAccount.currencyCode)} ';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTransferTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              accountsAsync.when(
                data: (accounts) {
                  final active = accounts.where((a) => !a.isArchived).toList();
                  if (active.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 28, color: colors.textSecondary),
                          const SizedBox(height: 6),
                          Text(l10n.noAccounts, style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.push('/add-account'),
                            child: Text(l10n.createNewAccount, style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _fromAccountId,
                        dropdownColor: colors.surfaceRaised,
                        hint: Text(l10n.selectFromAccount, style: GoogleFonts.inter(color: colors.textSecondary)),
                        items: active.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                        )).toList(),
                        onChanged: (val) => setState(() => _fromAccountId = val),
                        decoration: InputDecoration(
                          labelText: l10n.fromAccount,
                          prefixIcon: Icon(Icons.call_made, color: colors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _toAccountId,
                        dropdownColor: colors.surfaceRaised,
                        hint: Text(l10n.selectToAccount, style: GoogleFonts.inter(color: colors.textSecondary)),
                        items: active.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                        )).toList(),
                        onChanged: (val) => setState(() => _toAccountId = val),
                        decoration: InputDecoration(
                          labelText: l10n.toAccount,
                          prefixIcon: Icon(Icons.call_received, color: colors.textSecondary),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(color: AppColors.gold),
                error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.nominalLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money, color: colors.textSecondary),
                  prefixText: fromSymbol,
                  prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.exchangeRateLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _exchangeRateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '1',
                  prefixIcon: Icon(Icons.swap_horiz, color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.descriptionLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.optional,
                  prefixIcon: Icon(Icons.description_outlined, color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: AppColors.gold, size: 20),
                  title: Text(l10n.date, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null && context.mounted) setState(() => _selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg),
                        )
                      : Text(
                          l10n.saveTransfer,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amountText = _amountCtrl.text.trim();
    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    final exchangeRate = double.tryParse(_exchangeRateCtrl.text.trim());

    if (amount == null || amount <= 0 || _fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAmountAndSelectAccounts, style: GoogleFonts.inter())),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountsMustBeDifferent, style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final fromCurrency = (ref.read(accountsNotifierProvider).valueOrNull ?? const [])
          .where((a) => a.id == _fromAccountId)
          .map((a) => a.currencyCode)
          .firstOrNull ?? 'IDR';
      final service = ref.read(transactionServiceProvider);
      await service.addTransfer(
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
        currencyCode: fromCurrency,
        exchangeRate: exchangeRate,
        date: _selectedDate,
        description: _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : null,
      );
      ref.read(transfersNotifierProvider.notifier).loadTransfers();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e', style: GoogleFonts.inter())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
