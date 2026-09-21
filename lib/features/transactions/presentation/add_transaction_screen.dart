import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
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
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  final _amountCtrl = TextEditingController();
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
      _amountCtrl.text = t.amount.toString();
      _descCtrl.text = t.description ?? '';
      _noteCtrl.text = t.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? l10n.editTransaction : l10n.addTransaction,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
            Text(
              _isEditing ? l10n.editTransactionSubtitle : l10n.addTransactionSubtitle,
              style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(colors),
              const SizedBox(height: 24),
              _buildCenteredAmount(colors),
              const SizedBox(height: 32),
              _buildFormRow(Icons.category_outlined, 'Kategori', _getCategoryLabel(categoriesAsync), colors, () => _showCategoryPicker(categoriesAsync, colors)),
              _buildFormRow(Icons.account_balance_wallet_outlined, 'Dari Akun', _getAccountLabel(accountsAsync), colors, () => _showAccountPicker(accountsAsync, colors)),
              _buildFormRow(Icons.calendar_today_outlined, 'Tanggal', DateFormat('dd MMMM yyyy • HH:mm', 'id').format(_selectedDate), colors, () => _pickDate()),
              _buildFormRow(Icons.notes_outlined, 'Catatan', _noteCtrl.text.isEmpty ? 'Tambah catatan transaksi' : _noteCtrl.text, colors, () => _showNoteDialog(colors)),
              const SizedBox(height: 32),
              _buildSaveButton(colors, l10n),
              const SizedBox(height: 12),
              Text(
                _isEditing ? '' : 'Anda masih bisa mengedit setelah menyimpan',
                style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(AsyncValue<List<Category>> categoriesAsync) {
    if (!categoriesAsync.hasValue) return 'Pilih kategori';
    final filtered = _type == 'income'
        ? categoriesAsync.value!.where((c) => c.type == 'income').toList()
        : categoriesAsync.value!.where((c) => c.type == 'expense').toList();
    if (_selectedCategoryId != null) {
      final match = filtered.where((c) => c.id == _selectedCategoryId);
      if (match.isNotEmpty) return match.first.name;
    }
    return 'Pilih kategori';
  }

  String _getAccountLabel(AsyncValue<List<Account>> accountsAsync) {
    if (!accountsAsync.hasValue) return 'Pilih akun';
    final active = accountsAsync.value!.where((a) => !a.isArchived).toList();
    if (_selectedAccountId != null) {
      final match = active.where((a) => a.id == _selectedAccountId);
      if (match.isNotEmpty) return match.first.name;
    }
    return 'Pilih akun';
  }

  Widget _buildTypeSelector(AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _typeTab('Pengeluaran', 'expense', colors),
          _typeTab('Pemasukan', 'income', colors),
          _typeTab('Transfer', 'transfer', colors),
        ],
      ),
    );
  }

  Widget _typeTab(String label, String type, AppColorsT colors) {
    final selected = _type == type;
    final activeColor = type == 'expense' ? AppColors.rose : AppColors.teal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _type = type; _selectedCategoryId = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : colors.textSecondary,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredAmount(AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text('Jumlah transaksi', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rp', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: colors.textSecondary.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(IconData icon, String label, String value, AppColorsT colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppColorsT colors, AppLocalizations l10n) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: _saving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                _isEditing ? l10n.saveChanges : 'Simpan transaksi',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
              ),
      ),
    );
  }

  void _showCategoryPicker(AsyncValue<List<Category>> categoriesAsync, AppColorsT colors) {
    if (!categoriesAsync.hasValue || categoriesAsync.value!.isEmpty) return;
    final filtered = _type == 'income'
        ? categoriesAsync.value!.where((c) => c.type == 'income').toList()
        : categoriesAsync.value!.where((c) => c.type == 'expense').toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...filtered.map((c) => ListTile(
              title: Text(c.name, style: GoogleFonts.inter(fontSize: 14)),
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

  void _showAccountPicker(AsyncValue<List<Account>> accountsAsync, AppColorsT colors) {
    if (!accountsAsync.hasValue || accountsAsync.value!.isEmpty) return;
    final active = accountsAsync.value!.where((a) => !a.isArchived).toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Akun', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
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
            ListTile(
              leading: Icon(Icons.add, color: colors.primary),
              title: Text('Tambah akun baru', style: GoogleFonts.inter(fontSize: 14, color: colors.primary)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/add-account');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(AppColorsT colors) {
    final ctrl = TextEditingController(text: _noteCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Catatan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Makan malam bersama keluarga',
            hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              setState(() => _noteCtrl.text = ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
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
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime?.hour ?? _selectedDate.hour,
            pickedTime?.minute ?? _selectedDate.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amountText = _amountCtrl.text.trim();
    final amount = int.tryParse(amountText.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0 || _selectedAccountId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih akun dan masukkan nominal yang valid', style: GoogleFonts.inter())),
      );
      return;
    }

    String currencyCode = 'IDR';
    final accounts = ref.read(accountsNotifierProvider).valueOrNull ?? [];
    final match = accounts.where((a) => a.id == _selectedAccountId);
    if (match.isNotEmpty) currencyCode = match.first.currencyCode;

    final description = _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null;
    final note = _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null;

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final updated = widget.transaction!.copyWith(
          type: _type,
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId,
          amount: amount,
          currencyCode: currencyCode,
          description: description,
          date: _selectedDate,
          note: note,
          updatedAt: DateTime.now(),
        );
        await ref.read(transactionsNotifierProvider.notifier).updateTransaction(updated);
      } else {
        final service = ref.read(transactionServiceProvider);
        if (_type == 'income') {
          await service.addIncome(
            accountId: _selectedAccountId!, categoryId: _selectedCategoryId, amount: amount,
            currencyCode: currencyCode, description: description, date: _selectedDate, note: note,
          );
        } else {
          await service.addExpense(
            accountId: _selectedAccountId!, categoryId: _selectedCategoryId, amount: amount,
            currencyCode: currencyCode, description: description, date: _selectedDate, note: note,
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
          SnackBar(content: Text('${l10n.transactionSaveError}: $e', style: GoogleFonts.inter())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
