import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

/// Bottom-sheet form for creating/editing a savings goal (Item 3: CRUD via sheet).
Future<void> showGoalFormSheet(BuildContext context, {Goal? edit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GoalFormSheet(edit: edit),
  );
}

class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({super.key, this.edit});

  final Goal? edit;

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  AppColorsT get colors => AppColorsT.of(context);
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _noteCtrl;
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _isPriority = false;
  bool _saving = false;

  bool get _isEditing => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final g = widget.edit;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(text: g?.targetAmount.toString() ?? '');
    _noteCtrl = TextEditingController(text: g?.note ?? '');
    _startDate = g?.startDate ?? DateTime.now();
    _targetDate = g?.targetDate;
    _isPriority = g?.isPriority ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final baseCode = ref.watch(baseCurrencyCodeProvider);
    final symbol = currencySymbol(baseCode);
    final wrapper = SingleChildScrollView(
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
            _isEditing ? l10n.editGoal : l10n.addTarget,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.goalName,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.inter(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: Localizations.localeOf(context).languageCode == 'id' ? 'mis. Dana Darurat' : 'e.g. Emergency Fund',
              prefixIcon: Icon(Icons.flag_outlined, color: colors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.amount.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.jetBrainsMono(color: colors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Icon(Icons.savings_outlined, color: colors.textSecondary),
              prefixText: '$symbol ',
              prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.note.toUpperCase(),
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
                  context: context, initialDate: _startDate,
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && context.mounted) setState(() => _startDate = picked);
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: ListTile(
              leading: const Icon(Icons.event_outlined, color: AppColors.gold, size: 20),
              title: Text(l10n.targetDate, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              subtitle: Text(
                _targetDate != null
                    ? DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(_targetDate!)
                    : l10n.notSet,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
              ),
              trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context, initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null && context.mounted) setState(() => _targetDate = picked);
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: SwitchListTile(
              value: _isPriority,
              onChanged: (val) => setState(() => _isPriority = val),
              title: Text(l10n.priority, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
              subtitle: Text(l10n.prioritySubtitle, style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
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
                      _isEditing ? l10n.saveChanges : l10n.saveGoal,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FractionallySizedBox(heightFactor: 0.92, child: wrapper),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final target = int.tryParse(_targetCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (name.isEmpty || target == null || target <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi nama dan target nominal', style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final notifier = ref.read(goalsNotifierProvider.notifier);
      if (_isEditing) {
        final pocket = await ref.read(accountServiceProvider).ensurePocket(
              systemKey: 'pocket:goal:${widget.edit!.id}',
              name: 'Kantong ${widget.edit!.name}',
              currencyCode: widget.edit!.currencyCode,
            );
        final updated = widget.edit!.copyWith(
          name: name,
          targetAmount: target,
          startDate: _startDate,
          targetDate: _targetDate,
          isPriority: _isPriority,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
          linkedAccountId: widget.edit!.linkedAccountId ?? pocket.id,
          updatedAt: now,
        );
        await notifier.updateGoal(updated);
      } else {
        final goalId = const Uuid().v4();
        final baseCode = ref.read(baseCurrencyCodeProvider);
        final pocket = await ref.read(accountServiceProvider).ensurePocket(
              systemKey: 'pocket:goal:$goalId',
              name: 'Kantong $name',
              currencyCode: baseCode,
            );
        await notifier.addGoal(Goal(
          id: goalId,
          name: name,
          targetAmount: target,
          currencyCode: baseCode,
          linkedAccountId: pocket.id,
          startDate: _startDate,
          targetDate: _targetDate,
          isPriority: _isPriority,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
          createdAt: now,
          updatedAt: now,
        ));
      }
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
    await ref.read(goalsNotifierProvider.notifier).deleteGoal(widget.edit!.id);
    if (mounted) Navigator.pop(context);
  }
}