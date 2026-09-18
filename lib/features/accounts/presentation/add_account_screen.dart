import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();
  String _accountType = 'wallet';
  String _currencyCode = 'IDR';
  bool _saving = false;

  static const _accountTypes = [
    ('wallet', 'Dompet', Icons.account_balance_wallet_outlined, AppColors.emerald),
    ('savings', 'Tabungan', Icons.savings_outlined, AppColors.blue),
    ('credit', 'Kartu Kredit', Icons.credit_card_outlined, AppColors.coral),
    ('cash', 'Tunai', Icons.payments_outlined, AppColors.amber),
    ('investment', 'Investasi', Icons.trending_up_rounded, AppColors.violet),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currenciesAsync = ref.watch(currenciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Akun', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NAMA AKUN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: BCA Utama',
                prefixIcon: const Icon(Icons.label_outline, color: AppColors.textMuted),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            Text('TIPE AKUN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _accountTypes.map((t) {
                final selected = _accountType == t.$1;
                return GestureDetector(
                  onTap: () => setState(() => _accountType = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? t.$4.withValues(alpha: 0.15) : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? t.$4 : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$3, size: 16, color: selected ? t.$4 : AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(t.$2, style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? t.$4 : AppColors.textMuted,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Text('MATA UANG', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            currenciesAsync.when(
              data: (currencies) {
                return DropdownButtonFormField<String>(
                  initialValue: _currencyCode,
                  items: currencies.map((c) => DropdownMenuItem(
                    value: c.code,
                    child: Text('${c.code} — ${c.name}', style: GoogleFonts.inter()),
                  )).toList(),
                  onChanged: (val) => setState(() => _currencyCode = val ?? 'IDR'),
                );
              },
              loading: () => const LinearProgressIndicator(color: AppColors.emerald),
              error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.coral)),
            ),
            const SizedBox(height: 24),

            Text('SALDO AWAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.jetBrainsMono(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: '0',
                prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),

            Text('CATATAN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Opsional',
                prefixIcon: Icon(Icons.note_outlined, color: AppColors.textMuted),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
                    : Text('Simpan Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nama akun', style: GoogleFonts.inter())),
      );
      return;
    }

    final balance = int.tryParse(_balanceCtrl.text.replaceAll(RegExp(r'[^0-9\-]'), '')) ?? 0;

    setState(() => _saving = true);
    try {
      await ref.read(accountsNotifierProvider.notifier).addAccount(
        name: name,
        accountType: _accountType,
        currencyCode: _currencyCode,
        initialBalance: balance,
        note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
      );
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
