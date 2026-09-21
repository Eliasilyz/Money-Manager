import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/currency.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key, this.editAccount});

  final Account? editAccount;

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  AppColorsT get colors => AppColorsT.of(context);
  late final TextEditingController _nameCtrl;
  late final TextEditingController _balanceCtrl;
  late final TextEditingController _noteCtrl;
  late String _accountType;
  late String _currencyCode;
  bool _saving = false;

  bool get _isEditing => widget.editAccount != null;

  static const _defaultCurrencies = [
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', decimalDigits: 0),
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', decimalDigits: 2),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', decimalDigits: 2),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', decimalDigits: 2),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', decimalDigits: 0),
  ];

  static const _accountTypeKeys = [
    ('wallet', 'accountTypeWallet', Icons.account_balance_wallet_outlined, AppColors.gold),
    ('savings', 'accountTypeSavings', Icons.savings_outlined, AppColors.sky),
    ('credit', 'accountTypeCredit', Icons.credit_card_outlined, AppColors.rose),
    ('cash', 'accountTypeCash', Icons.payments_outlined, AppColors.orange),
    ('investment', 'accountTypeInvestment', Icons.trending_up_rounded, AppColors.lilac),
  ];

  String _localizedAccountType(String key, AppLocalizations l10n) {
    return switch (key) {
      'accountTypeWallet' => l10n.accountTypeWallet,
      'accountTypeSavings' => l10n.accountTypeSavings,
      'accountTypeCredit' => l10n.accountTypeCredit,
      'accountTypeCash' => l10n.accountTypeCash,
      'accountTypeInvestment' => l10n.accountTypeInvestment,
      _ => key,
    };
  }

  @override
  void initState() {
    super.initState();
    final acct = widget.editAccount;
    _nameCtrl = TextEditingController(text: acct?.name ?? '');
    _balanceCtrl = TextEditingController(text: acct?.initialBalance.toString() ?? '0');
    _noteCtrl = TextEditingController(text: acct?.note ?? '');
    _accountType = acct?.accountType ?? 'wallet';
    _currencyCode = acct?.currencyCode ?? 'IDR';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currenciesAsync = ref.watch(currenciesNotifierProvider);

    final rawCurrencies = currenciesAsync.valueOrNull ?? [];
    final currencies = rawCurrencies.isNotEmpty ? rawCurrencies : _defaultCurrencies;
    final selectedCurrency = currencies.any((c) => c.code == _currencyCode)
        ? _currencyCode
        : currencies.first.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.addAccountTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.accountNameLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.accountNameHint,
                  prefixIcon: Icon(Icons.label_outline, color: colors.textSecondary),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              Text(
                l10n.accountTypeLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _accountTypeKeys.map((t) {
                  final selected = _accountType == t.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _accountType = t.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? t.$4.withValues(alpha: 0.15) : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? t.$4 : colors.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$3, size: 16, color: selected ? t.$4 : colors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            _localizedAccountType(t.$2, l10n),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? t.$4 : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.currencyLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedCurrency,
                dropdownColor: colors.surfaceRaised,
                items: currencies.map((c) => DropdownMenuItem(
                  value: c.code,
                  child: Text('${c.code} — ${c.name}', style: GoogleFonts.inter(color: colors.textPrimary)),
                )).toList(),
                onChanged: (val) => setState(() => _currencyCode = val ?? 'IDR'),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.monetization_on_outlined, color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.initialBalanceLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _balanceCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.noteLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.optional,
                  prefixIcon: Icon(Icons.note_outlined, color: colors.textSecondary),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

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
                          _isEditing ? l10n.saveChanges : l10n.saveAccount,
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountNameRequired, style: GoogleFonts.inter())),
      );
      return;
    }

    final balance = int.tryParse(_balanceCtrl.text.replaceAll(RegExp(r'[^0-9\-]'), '')) ?? 0;

    setState(() => _saving = true);
    try {
      final notifier = ref.read(accountsNotifierProvider.notifier);
      if (_isEditing) {
        final updated = widget.editAccount!.copyWith(
          name: name,
          accountType: _accountType,
          currencyCode: _currencyCode,
          initialBalance: balance,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
          updatedAt: DateTime.now(),
        );
        await notifier.updateAccount(updated);
      } else {
        await notifier.addAccount(
          name: name,
          accountType: _accountType,
          currencyCode: _currencyCode,
          initialBalance: balance,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
        );
      }
      ref.invalidate(dashboardProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
