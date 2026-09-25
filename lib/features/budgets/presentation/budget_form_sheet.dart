import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/budget.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

/// Bottom-sheet form for creating/editing a budget (Item 3: CRUD via sheet).
Future<void> showBudgetFormSheet(BuildContext context, {Budget? edit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BudgetFormSheet(edit: edit),
  );
}

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({super.key, this.edit});

  final Budget? edit;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  AppColorsT get colors => AppColorsT.of(context);
  String? _selectedCategoryId;
  late final TextEditingController _amountCtrl;
  String _period = 'monthly';
  DateTime _startDate = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final b = widget.edit;
    _selectedCategoryId = b?.categoryId;
    _amountCtrl = TextEditingController(text: b?.amount.toString() ?? '');
    _period = b?.period ?? 'monthly';
    _startDate = b?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final symbol = currencySymbol(baseCode);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final wrapper = Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? l10n.editBudget : l10n.addBudget,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) {
                final expenseCats = categories.where((c) => c.type == 'expense').toList();
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  dropdownColor: colors.surfaceRaised,
                  hint: Text(l10n.selectCategory, style: GoogleFonts.inter(color: colors.textSecondary)),
                  items: expenseCats.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(localizedCategoryName(l10n, c.systemKey, c.name), style: GoogleFonts.inter(color: colors.textPrimary)),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    prefixIcon: Icon(Icons.category_outlined, color: colors.textSecondary),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(color: AppColors.gold),
              error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.budgetAmount,
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
                prefixText: '$symbol ',
                prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.period.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _period,
              dropdownColor: colors.surfaceRaised,
              items: [
                DropdownMenuItem(value: 'weekly', child: Text(l10n.frequencyWeekly)),
                DropdownMenuItem(value: 'monthly', child: Text(l10n.frequencyMonthly)),
                DropdownMenuItem(value: 'yearly', child: Text(l10n.frequencyYearly)),
              ],
              onChanged: (val) => setState(() => _period = val ?? 'monthly'),
              decoration: InputDecoration(
                labelText: l10n.period,
                prefixIcon: Icon(Icons.calendar_month_outlined, color: colors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined, color: AppColors.gold, size: 20),
                title: Text(l10n.startDate, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(_startDate),
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
            const SizedBox(height: 16),
            if (_isEditing) ...[
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _saving ? null : _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose,
                    side: const BorderSide(color: AppColors.rose, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.delete, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 10),
            ],
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
                        _isEditing ? l10n.saveChanges : l10n.saveBudget,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    return FractionallySizedBox(heightFactor: 0.92, child: wrapper);
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _selectedCategoryId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).fillBudgetAmountCategory, style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final notifier = ref.read(budgetsNotifierProvider.notifier);
      String budgetId;
      String categoryName = _selectedCategoryId!;
      final l10n = AppLocalizations.of(context);
      final cats = ref.read(categoriesNotifierProvider).valueOrNull;
      if (cats != null) {
        for (final c in cats) {
          if (c.id == _selectedCategoryId) categoryName = localizedCategoryName(l10n, c.systemKey, c.name);
        }
      }
      if (_isEditing) {
        budgetId = widget.edit!.id;
        final updated = widget.edit!.copyWith(
          categoryId: _selectedCategoryId!,
          amount: amount,
          period: _period,
          startDate: _startDate,
          updatedAt: now,
        );
        await notifier.updateBudget(updated);
      } else {
        budgetId = const Uuid().v4();
        final baseCode = ref.read(baseCurrencyCodeProvider);
        await notifier.addBudget(Budget(
          id: budgetId,
          categoryId: _selectedCategoryId!,
          amount: amount,
          currencyCode: baseCode,
          period: _period,
          startDate: _startDate,
          createdAt: now,
          updatedAt: now,
        ));
      }
      await ref.read(accountServiceProvider).ensurePocket(
            systemKey: 'pocket:budget:$budgetId',
            name: 'Kantong $categoryName',
            currencyCode: 'IDR',
          );
      ref.read(accountsNotifierProvider.notifier).loadAccounts();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteConfirm, style: GoogleFonts.inter(color: colors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.rose)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(budgetsNotifierProvider.notifier).deleteBudget(widget.edit!.id);
    if (mounted) Navigator.pop(context);
  }
}