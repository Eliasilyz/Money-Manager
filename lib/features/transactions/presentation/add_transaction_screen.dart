import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/balance_calculation.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/transfers/application/transfer_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_colors.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _type = 'expense';
  String? _selectedAccountId;
  String? _toAccountId; // For transfer
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  final _amountCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  final _descCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _type = t.type;
      _selectedAccountId = t.accountId;
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
      _amountCtrl.text = _formatNumber(t.amount);
      _descCtrl.text = t.description ?? '';
      _noteCtrl.text = t.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _amountFocus.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return NumberFormat.decimalPattern('id').format(number);
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      _amountCtrl.value = const TextEditingValue(text: '');
      return;
    }
    final intVal = int.tryParse(clean) ?? 0;
    final formatted = _formatNumber(intVal);
    _amountCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  int get _parsedAmount {
    final clean = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    // Auto-select first account if not set
    if (_selectedAccountId == null && accountsAsync.hasValue && accountsAsync.value!.isNotEmpty) {
      final activeAccounts = accountsAsync.value!.where((a) => !a.isArchived).toList();
      if (activeAccounts.isNotEmpty) {
        _selectedAccountId = activeAccounts.first.id;
      }
    }

    // Auto-select first category if not set
    if (_selectedCategoryId == null && categoriesAsync.hasValue && categoriesAsync.value!.isNotEmpty) {
      final filteredCats = categoriesAsync.value!.where((c) => c.type == _type).toList();
      if (filteredCats.isNotEmpty) {
        _selectedCategoryId = filteredCats.first.id;
      }
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? l10n.editTransaction : l10n.addTransaction,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isEditing ? l10n.editTransactionSubtitle : l10n.addTransactionSubtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    l10n.close,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(colors, l10n),
              const SizedBox(height: 18),
              _buildAmountBanner(colors),
              const SizedBox(height: 20),
              _buildFormCardGroup(colors, l10n, accountsAsync, categoriesAsync),
              const SizedBox(height: 28),
              _buildSaveButton(colors, l10n),
              const SizedBox(height: 12),
              Text(
                l10n.editAfterSave,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppColorsT colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _typeTab(l10n.expense, 'expense', colors),
          _typeTab(l10n.income, 'income', colors),
          _typeTab(l10n.transfer, 'transfer', colors),
        ],
      ),
    );
  }

  Widget _typeTab(String label, String type, AppColorsT colors) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            _selectedCategoryId = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountBanner(AppColorsT colors) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => _amountFocus.requestFocus(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [colors.heroCardBg, colors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.heroCardBg.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.amount.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Rp ',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    focusNode: _amountFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _onAmountChanged,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      hintText: '0',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCardGroup(
    AppColorsT colors,
    AppLocalizations l10n,
    AsyncValue<List<Account>> accountsAsync,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final accountLabel = _getAccountLabelWithBalance(accountsAsync, _selectedAccountId);
    final categoryLabel = _getCategoryLabel(categoriesAsync, l10n);
    final dateLabel = DateFormat('d MMM yyyy, HH:mm', locale).format(_selectedDate);
    final noteLabel = _noteCtrl.text.isEmpty ? l10n.hintTransactionNote : _noteCtrl.text;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_type != 'transfer') ...[
            _buildFormRowItem(
              icon: Icons.restaurant_rounded,
              iconColor: const Color(0xFFE76F51),
              iconBg: const Color(0xFFFDE8E4),
              label: l10n.category.toUpperCase(),
              value: categoryLabel,
              colors: colors,
              onTap: () => _showCategoryPicker(categoriesAsync, colors, l10n),
            ),
            Divider(height: 1, indent: 64, color: colors.border),
          ],
          _buildFormRowItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: colors.primary,
            iconBg: colors.primary.withValues(alpha: 0.12),
            label: _type == 'transfer' ? l10n.fromAccount.toUpperCase() : (_type == 'income' ? l10n.toAccount.toUpperCase() : l10n.fromAccount.toUpperCase()),
            value: accountLabel,
            colors: colors,
            onTap: () => _showAccountPicker(accountsAsync, colors, l10n, isSource: true),
          ),
          if (_type == 'transfer') ...[
            Divider(height: 1, indent: 64, color: colors.border),
            _buildFormRowItem(
              icon: Icons.input_rounded,
              iconColor: const Color(0xFF2A9D8F),
              iconBg: const Color(0xFFE8F7F5),
              label: l10n.toAccount.toUpperCase(),
              value: _getAccountLabelWithBalance(accountsAsync, _toAccountId, defaultLabel: l10n.selectAccount),
              colors: colors,
              onTap: () => _showAccountPicker(accountsAsync, colors, l10n, isSource: false),
            ),
          ],
          Divider(height: 1, indent: 64, color: colors.border),
          _buildFormRowItem(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF457B9D),
            iconBg: const Color(0xFFEAF1F8),
            label: l10n.date.toUpperCase(),
            value: dateLabel,
            colors: colors,
            onTap: () => _pickDate(),
          ),
          Divider(height: 1, indent: 64, color: colors.border),
          _buildFormRowItem(
            icon: Icons.edit_note_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF3E8FF),
            label: l10n.note.toUpperCase(),
            value: noteLabel,
            isPlaceholder: _noteCtrl.text.isEmpty,
            colors: colors,
            onTap: () => _showNoteDialog(colors, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRowItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required AppColorsT colors,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPlaceholder
                          ? colors.textSecondary.withValues(alpha: 0.6)
                          : colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(AsyncValue<List<Category>> categoriesAsync, AppLocalizations l10n) {
    if (!categoriesAsync.hasValue) return l10n.selectCategory;
    final filtered = categoriesAsync.value!.where((c) => c.type == _type).toList();
    if (_selectedCategoryId != null) {
      final match = filtered.where((c) => c.id == _selectedCategoryId);
      if (match.isNotEmpty) return localizedCategoryName(l10n, match.first.systemKey, match.first.name);
    }
    return filtered.isNotEmpty
        ? localizedCategoryName(l10n, filtered.first.systemKey, filtered.first.name)
        : l10n.selectCategory;
  }

  String _getAccountLabelWithBalance(
    AsyncValue<List<Account>> accountsAsync,
    String? accountId, {
    String? defaultLabel,
  }) {
    final fallbackLabel = defaultLabel ?? 'Pilih akun';
    if (!accountsAsync.hasValue) return fallbackLabel;
    final active = accountsAsync.value!.where((a) => !a.isArchived).toList();
    if (accountId != null) {
      final match = active.where((a) => a.id == accountId);
      if (match.isNotEmpty) {
        final acc = match.first;
        final transactions = ref.read(transactionsNotifierProvider).valueOrNull ?? [];
        final transfers = ref.read(transfersNotifierProvider).valueOrNull ?? [];
        final balance = BalanceCalculation.accountBalance(
          initialBalance: acc.initialBalance,
          accountId: acc.id,
          transactions: transactions,
          transfers: transfers,
        );
        return '${acc.name} (${formatCurrency(balance, currencyCode: acc.currencyCode)})';
      }
    }
    return fallbackLabel;
  }

  Widget _buildSaveButton(AppColorsT colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: colors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(
                    _isEditing ? l10n.saveChanges : l10n.saveTransaction,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _saving ? null : _deleteTransaction,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.expense,
                side: BorderSide(color: colors.expense, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                l10n.deleteTransaction,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _deleteTransaction() async {
    final l10n = AppLocalizations.of(context);
    final colors = AppColorsT.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteTransaction, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text(l10n.confirmDeleteTransaction, style: GoogleFonts.inter(color: colors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: GoogleFonts.inter(color: colors.expense, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || widget.transaction == null) return;
    await ref.read(transactionsNotifierProvider.notifier).deleteTransaction(widget.transaction!.id);
    ref.read(accountsNotifierProvider.notifier).loadAccounts();
    ref.invalidate(dashboardProvider);
    if (mounted) context.pop();
  }

  void _showCategoryPicker(AsyncValue<List<Category>> categoriesAsync, AppColorsT colors, AppLocalizations l10n) {
    if (!categoriesAsync.hasValue || categoriesAsync.value!.isEmpty) return;
    final filtered = categoriesAsync.value!.where((c) => c.type == _type).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.selectCategory,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
                  itemBuilder: (ctx, index) {
                    final c = filtered[index];
                    final isSel = _selectedCategoryId == c.id;
                    return ListTile(
                      title: Text(
                        localizedCategoryName(l10n, c.systemKey, c.name),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? colors.primary : colors.textPrimary,
                        ),
                      ),
                      trailing: isSel ? Icon(Icons.check_circle_rounded, color: colors.primary) : null,
                      onTap: () {
                        setState(() => _selectedCategoryId = c.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountPicker(AsyncValue<List<Account>> accountsAsync, AppColorsT colors, AppLocalizations l10n, {required bool isSource}) {
    if (!accountsAsync.hasValue || accountsAsync.value!.isEmpty) return;
    final active = accountsAsync.value!.where((a) => !a.isArchived).toList();
    final currentSelected = isSource ? _selectedAccountId : _toAccountId;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isSource ? l10n.selectAccount : l10n.selectDestinationAccount,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: active.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
                  itemBuilder: (ctx, index) {
                    final a = active[index];
                    final isSel = currentSelected == a.id;
                    final transactions = ref.read(transactionsNotifierProvider).valueOrNull ?? [];
                    final transfers = ref.read(transfersNotifierProvider).valueOrNull ?? [];
                    final bal = BalanceCalculation.accountBalance(
                      initialBalance: a.initialBalance,
                      accountId: a.id,
                      transactions: transactions,
                      transfers: transfers,
                    );
                    return ListTile(
                      title: Text(
                        a.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? colors.primary : colors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        formatCurrency(bal, currencyCode: a.currencyCode),
                        style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary),
                      ),
                      trailing: isSel ? Icon(Icons.check_circle_rounded, color: colors.primary) : null,
                      onTap: () {
                        setState(() {
                          if (isSource) {
                            _selectedAccountId = a.id;
                          } else {
                            _toAccountId = a.id;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(AppColorsT colors, AppLocalizations l10n) {
    final ctrl = TextEditingController(text: _noteCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.note, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.hintTransactionNote,
            hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: GoogleFonts.inter(color: colors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _noteCtrl.text = ctrl.text);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: colors.primary),
            child: Text(l10n.save, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (mounted) {
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
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = _parsedAmount;
    if (amount <= 0 || _selectedAccountId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            amount <= 0 ? l10n.enterTransactionAmount : l10n.selectAccountFirst,
            style: GoogleFonts.inter(),
          ),
        ),
      );
      return;
    }

    if (_type == 'transfer' && _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectDestinationAccountFirst, style: GoogleFonts.inter())),
      );
      return;
    }

    String currencyCode = 'IDR';
    final accounts = ref.read(accountsNotifierProvider).valueOrNull ?? [];
    final match = accounts.where((a) => a.id == _selectedAccountId);
    if (match.isNotEmpty) currencyCode = match.first.currencyCode;

    final note = _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null;

    setState(() => _saving = true);
    try {
      if (_type == 'transfer') {
        final service = ref.read(transactionServiceProvider);
        await service.addTransfer(
          fromAccountId: _selectedAccountId!,
          toAccountId: _toAccountId!,
          amount: amount,
          currencyCode: currencyCode,
          description: note ?? 'Transfer',
        );
        ref.read(transfersNotifierProvider.notifier).loadTransfers();
      } else if (_isEditing) {
        final updated = widget.transaction!.copyWith(
          type: _type,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: note,
          date: _selectedDate,
          note: note,
          updatedAt: DateTime.now(),
        );
        await ref.read(transactionsNotifierProvider.notifier).updateTransaction(updated);
      } else {
        final service = ref.read(transactionServiceProvider);
        if (_type == 'income') {
          await service.addIncome(
            accountId: _selectedAccountId!,
            categoryId: _selectedCategoryId,
            amount: amount,
            currencyCode: currencyCode,
            description: note,
            date: _selectedDate,
            note: note,
          );
          await _allocateToGoalPockets(amount, _selectedAccountId!, currencyCode);
        } else {
          await service.addExpense(
            accountId: _selectedAccountId!,
            categoryId: _selectedCategoryId,
            amount: amount,
            currencyCode: currencyCode,
            description: note,
            date: _selectedDate,
            note: note,
          );
        }
        ref.read(transactionsNotifierProvider.notifier).loadTransactions();
      }
      ref.read(accountsNotifierProvider.notifier).loadAccounts();
      ref.invalidate(dashboardProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e', style: GoogleFonts.inter())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _allocateToGoalPockets(int amount, String fromAccountId, String currencyCode) async {
    const autoAllocatePct = 0.10;
    final pool = (amount * autoAllocatePct).round();
    if (pool < 1000) return;

    final goals = ref.read(goalsNotifierProvider).valueOrNull ?? [];
    final accounts = ref.read(accountsNotifierProvider).valueOrNull ?? [];
    final transactions = ref.read(transactionsNotifierProvider).valueOrNull ?? [];
    final transfers = ref.read(transfersNotifierProvider).valueOrNull ?? [];
    final accountById = {for (final a in accounts) a.id: a};

    int balanceOf(String id) => BalanceCalculation.accountBalance(
          initialBalance: accountById[id]?.initialBalance ?? 0,
          accountId: id,
          transactions: transactions,
          transfers: transfers,
        );

    final eligible = goals
        .where((g) =>
            g.status == 'active' &&
            g.linkedAccountId != null &&
            g.targetAmount > 0 &&
            accountById.containsKey(g.linkedAccountId))
        .where((g) => balanceOf(g.linkedAccountId!) < g.targetAmount)
        .toList();
    if (eligible.isEmpty) return;

    final share = pool ~/ eligible.length;
    if (share < 1000) return;

    final service = ref.read(transactionServiceProvider);
    for (final g in eligible) {
      await service.addTransfer(
        fromAccountId: fromAccountId,
        toAccountId: g.linkedAccountId!,
        amount: share,
        currencyCode: currencyCode,
        description: 'Tabungan otomatis: ${g.name}',
      );
    }
    await ref.read(transfersNotifierProvider.notifier).loadTransfers();
  }
}
