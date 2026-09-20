import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/budget.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  AppColorsT get colors => AppColorsT.of(context);
  String? _selectedCategoryId;
  final _amountCtrl = TextEditingController();
  String _period = 'monthly';
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Budget', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              categoriesAsync.when(
                data: (categories) {
                  final expenseCats = categories.where((c) => c.type == 'expense').toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    dropdownColor: colors.surfaceRaised,
                    hint: Text('Pilih Kategori', style: GoogleFonts.inter(color: colors.textSecondary)),
                    items: expenseCats.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, style: GoogleFonts.inter(color: colors.textPrimary)),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined, color: colors.textSecondary),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(color: AppColors.gold),
                error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
              ),
              const SizedBox(height: 24),

              Text(
                'JUMLAH BUDGET',
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
              const SizedBox(height: 24),

              Text(
                'PERIODE',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _period,
                dropdownColor: colors.surfaceRaised,
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                  DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                  DropdownMenuItem(value: 'yearly', child: Text('Tahunan')),
                ],
                onChanged: (val) => setState(() => _period = val ?? 'monthly'),
                decoration: InputDecoration(
                  labelText: 'Periode',
                  prefixIcon: Icon(Icons.calendar_month_outlined, color: colors.textSecondary),
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
                  title: Text('Tanggal Mulai', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy').format(_startDate),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && context.mounted) setState(() => _startDate = picked);
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
                          'Simpan Budget',
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
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi nominal dan pilih kategori', style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final budget = Budget(
        id: const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        amount: amount,
        currencyCode: 'IDR',
        period: _period,
        startDate: _startDate,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(budgetsNotifierProvider.notifier).addBudget(budget);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}