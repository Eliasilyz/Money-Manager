import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class CurrenciesScreen extends ConsumerWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final asyncCurrencies = ref.watch(currenciesNotifierProvider);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final refreshing = ref.watch(refreshExchangeRatesProvider);
    final rates = ref.watch(exchangeRatesProvider).valueOrNull ?? const <String, double>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currency, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          refreshing.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.gold)),
                )
              : IconButton(
                  tooltip: l10n.refreshRates,
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(refreshExchangeRatesProvider),
                ),
        ],
      ),
      body: asyncCurrencies.when(
        data: (currencies) {
          if (currencies.isEmpty) {
            return _buildEmpty(context, l10n);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: currencies.map((c) {
              final isBase = c.code == baseCode;
              final rate = c.code == baseCode ? 1.0 : rates['$baseCode:${c.code}'];
              return GestureDetector(
                onTap: () {
                  ref.read(baseCurrencyCodeProvider.notifier).state = c.code;
                  ref.read(settingsServiceProvider).saveBaseCurrencyCode(c.code);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isBase ? colors.primary : colors.border),
                  ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        c.symbol,
                        style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: colors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.code} — ${c.name}',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rate != null
                                ? '1 $baseCode = ${rate.toStringAsFixed(rate < 1 ? 4 : 2)} ${c.code}'
                                : '${c.decimalDigits} decimal',
                            style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!isBase)
                      IconButton(
                        tooltip: l10n.exchangeRateLabel,
                        icon: Icon(Icons.edit_outlined, size: 18, color: colors.textSecondary),
                        onPressed: () => _showManualRateDialog(context, ref, l10n, baseCode, c.code, rate),
                      ),
                    if (isBase)
                      const Icon(Icons.check_circle, color: AppColors.gold, size: 20)
                    else
                      const Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 20),
                  ],
                ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Future<void> _showManualRateDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String baseCode,
    String code,
    double? current,
  ) async {
    final ctrl = TextEditingController(text: current?.toString() ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('1 $baseCode → $code', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.jetBrainsMono(fontSize: 16),
          decoration: InputDecoration(hintText: '0', labelText: l10n.exchangeRateLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    final value = double.tryParse(ctrl.text.trim());
    if (saved == true && value != null && value > 0) {
      await ref.read(currencyRepositoryProvider).saveExchangeRate(ExchangeRate(
            baseCurrency: baseCode,
            targetCurrency: code,
            rate: value,
            date: DateTime.now(),
          ));
      ref.read(ratesRefreshTickProvider.notifier).state++;
    }
    ctrl.dispose();
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
            child: const Icon(Icons.monetization_on_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(l10n.noData, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
