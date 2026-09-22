import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key, this.editGoal});

  final Goal? editGoal;

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  AppColorsT get colors => AppColorsT.of(context);
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _noteCtrl;
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _saving = false;

  bool get _isEditing => widget.editGoal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.editGoal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(text: g?.targetAmount.toString() ?? '');
    _noteCtrl = TextEditingController(text: g?.note ?? '');
    _startDate = g?.startDate ?? DateTime.now();
    _targetDate = g?.targetDate;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editGoal : 'Tambah Tujuan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'NAMA TUJUAN',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: Dana Darurat',
                  prefixIcon: Icon(Icons.flag_outlined, color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'TARGET NOMINAL',
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
                  prefixText: 'Rp ',
                  prefixStyle: GoogleFonts.jetBrainsMono(color: AppColors.gold, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'CATATAN',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                style: GoogleFonts.inter(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Opsional',
                  prefixIcon: Icon(Icons.note_outlined, color: colors.textSecondary),
                ),
                maxLines: 2,
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
                  title: Text('Target Selesai', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                  subtitle: Text(
                    _targetDate != null
                        ? DateFormat('dd MMMM yyyy').format(_targetDate!)
                        : 'Belum ditentukan',
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
                          _isEditing ? l10n.saveChanges : 'Simpan Tujuan',
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
    final name = _nameCtrl.text.trim();
    final target = int.tryParse(_targetCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (name.isEmpty || target == null || target <= 0) {
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
              systemKey: 'pocket:goal:${widget.editGoal!.id}',
              name: 'Kantong ${widget.editGoal!.name}',
              currencyCode: widget.editGoal!.currencyCode,
            );
        final updated = widget.editGoal!.copyWith(
          name: name,
          targetAmount: target,
          startDate: _startDate,
          targetDate: _targetDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
          linkedAccountId: widget.editGoal!.linkedAccountId ?? pocket.id,
          updatedAt: now,
        );
        await notifier.updateGoal(updated);
      } else {
        final goalId = const Uuid().v4();
        final pocket = await ref.read(accountServiceProvider).ensurePocket(
              systemKey: 'pocket:goal:$goalId',
              name: 'Kantong $name',
              currencyCode: 'IDR',
            );
        await notifier.addGoal(Goal(
          id: goalId,
          name: name,
          targetAmount: target,
          currencyCode: 'IDR',
          linkedAccountId: pocket.id,
          startDate: _startDate,
          targetDate: _targetDate,
          note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
          createdAt: now,
          updatedAt: now,
        ));
      }
      ref.read(accountsNotifierProvider.notifier).loadAccounts();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}