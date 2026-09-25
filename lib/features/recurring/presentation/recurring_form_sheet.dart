import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/recurring_transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

Future<void> showRecurringFormSheet(BuildContext context, {RecurringTransaction? edit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RecurringFormSheet(edit: edit),
  );
}

DateTime _addMonths(DateTime d, int months) {
  final total = d.year * 12 + (d.month - 1) + months;
  final y = total ~/ 12;
  final m = total % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, d.day > lastDay ? lastDay : d.day);
}

DateTime _addInterval(String frequency, int interval, DateTime d) {
  switch (frequency) {
    case 'daily': return d.add(Duration(days: interval));
    case 'weekly': return d.add(Duration(days: 7 * interval));
    case 'yearly': return _addMonths(d, 12 * interval);
    case 'monthly':
    default: return _addMonths(d, interval);
  }
}

DateTime nextOccurrenceFor(String frequency, int interval, DateTime start, DateTime now) {
  var next = start;
  var guard = 0;
  while (next.isBefore(now) && guard < 100000) {
    next = _addInterval(frequency, interval, next);
    guard++;
  }
  return next;
}

class RecurringFormSheet extends ConsumerStatefulWidget {
  const RecurringFormSheet({super.key, this.edit});

  final RecurringTransaction? edit;

  @override
  ConsumerState<RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends ConsumerState<RecurringFormSheet> {
  AppColorsT get colors => AppColorsT.of(context);
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _intervalCtrl;
  String _type = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _frequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _enabled = true;
  bool _saving = false;

  bool get _isEditing => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final r = widget.edit;
    if (r != null) {
      _type = r.type;
      _selectedAccountId = r.accountId;
      _selectedCategoryId = r.categoryId;
      _amountCtrl = TextEditingController(text: r.amount.toString());
      _descCtrl = TextEditingController(text: r.description ?? '');
      _frequency = r.frequency;
      _intervalCtrl = TextEditingController(text: r.interval.toString());
      _startDate = r.startDate;
      _endDate = r.endDate;
      _enabled = r.enabled;
    } else {
      _amountCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _intervalCtrl = TextEditingController(text: '1');
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, List<Category> categories) {
    final match = categories.where((c) => c.id == _selectedCategoryId);
    if (match.isNotEmpty) return localizedCategoryName(l10n, match.first.systemKey, match.first.name);
    return l10n.selectCategory;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountsNotifierProvider).valueOrNull ?? [];
    final allCategories = ref.watch(categoriesNotifierProvider).valueOrNull ?? [];
    final categories = allCategories.where((c) => c.type == _type).toList();
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final selectedAccount = accounts.where((a) => a.id == _selectedAccountId).firstOrNull;
    var symbol = currencySymbol(baseCode);
    if (selectedAccount != null) symbol = currencySymbol(selectedAccount.currencyCode);

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tipe ──
        Row(
          children: [
            _typeButton(l10n.expense, 'expense', AppColors.rose),
            const SizedBox(width: 8),
            _typeButton(l10n.income, 'income', AppColors.teal),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixText: '$symbol ',
            prefixStyle: GoogleFonts.jetBrainsMono(color: colors.primary, fontWeight: FontWeight.w600),
            prefixIcon: Icon(Icons.payments_outlined, color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        _dropdownField(
          icon: Icons.repeat_rounded,
          label: l10n.frequency,
          value: _frequency,
          items: {
            'daily': l10n.frequencyDaily,
            'weekly': l10n.frequencyWeekly,
            'monthly': l10n.frequencyMonthly,
            'yearly': l10n.frequencyYearly,
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _intervalCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            labelText: l10n.interval,
            prefixIcon: Icon(Icons.numbers_outlined, color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showCategoryPicker(l10n, categories),
          child: _rowBox(Icons.category_outlined, l10n.category, _categoryLabel(l10n, categories)),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showAccountPicker(l10n, accounts),
          child: _rowBox(Icons.account_balance_wallet_outlined, l10n.fromAccount, _accountLabelFor(accounts, l10n)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          style: GoogleFonts.inter(color: colors.textPrimary),
          decoration: InputDecoration(
            labelText: l10n.description,
            prefixIcon: Icon(Icons.notes_outlined, color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickStartDate(),
                child: _rowBox(Icons.calendar_today_outlined, l10n.startDate, DateFormat('dd MMMM yyyy').format(_startDate)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickEndDate(),
                child: _rowBox(Icons.event_outlined, l10n.endDate, _endDate != null ? DateFormat('dd MMMM yyyy').format(_endDate!) : '-'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.border),
          ),
          child: SwitchListTile(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            title: Text(l10n.active, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
            activeTrackColor: AppColors.gold,
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
                    _isEditing ? l10n.saveChanges : l10n.save,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                _isEditing ? l10n.editRecurring : l10n.recurringAdd,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
              const SizedBox(height: 20),
              form,
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, String type, Color accent) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _selectedCategoryId = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? accent : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? accent : colors.border),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textSecondary)),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({required IconData icon, required String label, required String value, required Map<String, String> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Row(children: [
                    Icon(icon, size: 18, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(e.value, style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary)),
                  ])))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _frequency = v);
          },
        ),
      ),
    );
  }

  Widget _rowBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(AppLocalizations l10n, List<Category> categories) {
    if (categories.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectCategory, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...categories.map((c) => ListTile(
                  title: Text(localizedCategoryName(l10n, c.systemKey, c.name), style: GoogleFonts.inter(fontSize: 14)),
                  trailing: _selectedCategoryId == c.id ? Icon(Icons.check, color: colors.primary) : null,
                  onTap: () {
                    setState(() => _selectedCategoryId = c.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(AppLocalizations l10n, List<Account> accounts) {
    if (accounts.isEmpty) return;
    final active = accounts.where((a) => !a.isArchived).toList();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectAccount, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...active.map((a) => ListTile(
                  title: Text(a.name, style: GoogleFonts.inter(fontSize: 14)),
                  subtitle: Text(a.currencyCode, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                  trailing: _selectedAccountId == a.id ? Icon(Icons.check, color: colors.primary) : null,
                  onTap: () {
                    setState(() => _selectedAccountId = a.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _accountLabelFor(List<Account> accounts, AppLocalizations l10n) {
    final match = accounts.where((a) => a.id == _selectedAccountId);
    if (match.isNotEmpty) return match.first.name;
    return l10n.selectAccount;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && context.mounted) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && context.mounted) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final interval = int.tryParse(_intervalCtrl.text) ?? 1;
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).fillRecurringAmountAccount, style: GoogleFonts.inter())),
      );
      return;
    }

    final account = ref.read(accountsNotifierProvider).valueOrNull?.where((a) => a.id == _selectedAccountId).firstOrNull;
    final currencyCode = account?.currencyCode ?? 'IDR';

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final notifier = ref.read(recurringTransactionsNotifierProvider.notifier);
      final desc = _descCtrl.text.trim();
      final endDate = _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day) : null;
      final start = DateTime(_startDate.year, _startDate.month, _startDate.day);

      if (_isEditing) {
        final updated = widget.edit!.copyWith(
          type: _type,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: desc.isNotEmpty ? desc : null,
          frequency: _frequency,
          interval: interval,
          startDate: start,
          endDate: endDate,
          nextOccurrence: nextOccurrenceFor(_frequency, interval, start, now),
          enabled: _enabled,
          updatedAt: now,
        );
        await notifier.update(updated);
      } else {
        await notifier.add(RecurringTransaction(
          id: const Uuid().v4(),
          type: _type,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: desc.isNotEmpty ? desc : null,
          frequency: _frequency,
          interval: interval,
          startDate: start,
          endDate: endDate,
          nextOccurrence: nextOccurrenceFor(_frequency, interval, start, now),
          enabled: _enabled,
          createdAt: now,
          updatedAt: now,
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
      }
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
    await ref.read(recurringTransactionsNotifierProvider.notifier).delete(widget.edit!.id);
    if (mounted) Navigator.pop(context);
  }
}