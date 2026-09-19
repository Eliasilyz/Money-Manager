import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _type = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    String? accountCurrency;
    if (_selectedAccountId != null) {
      accountsAsync.whenData((accounts) {
        final match = accounts.where((a) => a.id == _selectedAccountId);
        if (match.isNotEmpty) accountCurrency = match.first.currencyCode;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Button
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'expense';
                          _selectedCategoryId = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'expense' ? AppColors.rose : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _type == 'expense' ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'income';
                          _selectedCategoryId = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == 'income' ? AppColors.teal : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _type == 'income' ? AppColors.bg : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account Selector
              accountsAsync.when(
                data: (accounts) {
                  final active = accounts.where((a) => !a.isArchived).toList();
                  if (active.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 28, color: AppColors.textDim),
                          const SizedBox(height: 6),
                          Text('Belum ada akun', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.push('/add-account'),
                            child: Text('Buat Akun Baru', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  }

                  final validAccountId = active.any((a) => a.id == _selectedAccountId)
                      ? _selectedAccountId
                      : null;

                  return DropdownButtonFormField<String>(
                    value: validAccountId,
                    dropdownColor: AppColors.card2,
                    hint: Text('Pilih Akun', style: GoogleFonts.inter(color: AppColors.textMuted)),
                    items: active.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.name} (${a.currencyCode})', style: GoogleFonts.inter(color: AppColors.textPrimary)),
                    )).toList(),
                    onChanged: (val) => setState(() {
                      _selectedAccountId = val;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Akun',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textMuted),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(color: AppColors.gold),
                error: (e, _) => Text('Error loading accounts: $e', style: GoogleFonts.inter(color: AppColors.rose)),
              ),
              const SizedBox(height: 16),

              // Category Selector
              categoriesAsync.when(
                data: (categories) {
                  final filtered = _type == 'income'
                      ? categories.where((c) => c.type == 'income').toList()
                      : categories.where((c) => c.type == 'expense').toList();

                  final validCatId = filtered.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;

                  return DropdownButtonFormField<String>(
                    value: validCatId,
                    dropdownColor: AppColors.card2,
                    hint: Text('Pilih Kategori (opsional)', style: GoogleFonts.inter(color: AppColors.textMuted)),
                    items: filtered.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, style: GoogleFonts.inter(color: AppColors.textPrimary)),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined, color: AppColors.textMuted),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(color: AppColors.gold),
                error: (e, _) => Text('Error loading categories: $e', style: GoogleFonts.inter(color: AppColors.rose)),
              ),
              const SizedBox(height: 16),

              // Amount
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.jetBrainsMono(fontSize: 16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nominal',
                  prefixText: '${accountCurrency ?? 'Rp'} ',
                  prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionCtrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Untuk apa',
                  hintText: 'Contoh: Nasi Padang Siang',
                  prefixIcon: Icon(Icons.description_outlined, color: AppColors.textMuted),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Note
              TextField(
                controller: _noteCtrl,
                style: GoogleFonts.inter(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Catatan tambahan (opsional)',
                  hintText: 'Contoh: Dibayar pakai QRIS',
                  prefixIcon: Icon(Icons.note_outlined, color: AppColors.textMuted),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Date Picker Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: AppColors.gold, size: 20),
                  title: Text('Tanggal & Waktu', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDate),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textDim),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDate),
                      );
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime?.hour ?? _selectedDate.hour,
                          pickedTime?.minute ?? _selectedDate.minute,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _type == 'expense' ? AppColors.rose : AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Simpan Transaksi',
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
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih akun dan masukkan nominal yang valid', style: GoogleFonts.inter())),
      );
      return;
    }

    String currencyCode = 'IDR';
    final accounts = ref.read(accountsNotifierProvider).valueOrNull ?? [];
    final match = accounts.where((a) => a.id == _selectedAccountId);
    if (match.isNotEmpty) currencyCode = match.first.currencyCode;

    final description = _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : null;

    setState(() => _saving = true);
    try {
      final service = ref.read(transactionServiceProvider);
      if (_type == 'income') {
        await service.addIncome(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: description,
          date: _selectedDate,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );
      } else {
        await service.addExpense(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: description,
          date: _selectedDate,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );
      }
      ref.read(transactionsNotifierProvider.notifier).loadTransactions();
      ref.read(accountsNotifierProvider.notifier).loadAccounts();
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
