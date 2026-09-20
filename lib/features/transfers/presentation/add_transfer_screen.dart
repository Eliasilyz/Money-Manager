import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
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
    final accountsAsync = ref.watch(accountsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transfer', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
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
                          Text('Belum ada akun', style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.push('/add-account'),
                            child: Text('Buat Akun Baru', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
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
                        hint: Text('Pilih Akun Asal', style: GoogleFonts.inter(color: colors.textSecondary)),
                        items: active.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                        )).toList(),
                        onChanged: (val) => setState(() => _fromAccountId = val),
                        decoration: InputDecoration(
                          labelText: 'Dari Akun',
                          prefixIcon: Icon(Icons.call_made, color: colors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _toAccountId,
                        dropdownColor: colors.surfaceRaised,
                        hint: Text('Pilih Akun Tujuan', style: GoogleFonts.inter(color: colors.textSecondary)),
                        items: active.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                        )).toList(),
                        onChanged: (val) => setState(() => _toAccountId = val),
                        decoration: InputDecoration(
                          labelText: 'Ke Akun',
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
                'NOMINAL',
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
                  prefixText: 'Rp ',
                  prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'KURS',
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
                'KETERANGAN',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Opsional',
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
                  title: Text('Tanggal', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
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
                          'Simpan Transfer',
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
    final amountText = _amountCtrl.text.trim();
    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    final exchangeRate = double.tryParse(_exchangeRateCtrl.text.trim());

    if (amount == null || amount <= 0 || _fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi nominal dan pilih kedua akun', style: GoogleFonts.inter())),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Akun asal dan tujuan tidak boleh sama', style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(transactionServiceProvider);
      await service.addTransfer(
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
        currencyCode: 'IDR',
        exchangeRate: exchangeRate,
        date: _selectedDate,
        description: _descriptionCtrl.text.isNotEmpty ? _descriptionCtrl.text : null,
      );
      ref.read(transfersNotifierProvider.notifier).loadTransfers();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}