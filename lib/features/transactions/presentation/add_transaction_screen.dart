import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/dashboard/application/dashboard_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

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
            Text('Tambah transaksi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            Text('Catatan dengan cepat', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primary)),
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
              const SizedBox(height: 16),
              _buildAmountCard(colors),
              const SizedBox(height: 20),
              _buildFieldLabel('KATEGORI', colors),
              _buildCategoryDropdown(categoriesAsync, colors),
              const SizedBox(height: 16),
              _buildFieldLabel('DARI AKUN', colors),
              _buildAccountDropdown(accountsAsync, colors),
              const SizedBox(height: 16),
              _buildFieldLabel('TANGGAL', colors),
              _buildDateField(colors),
              const SizedBox(height: 16),
              _buildFieldLabel('CATATAN', colors),
              _buildNoteField(colors),
              if (_type == 'expense') ...[
                const SizedBox(height: 20),
                _buildTransferSection(accountsAsync, colors),
              ],
              const SizedBox(height: 24),
              _buildSaveButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, AppColorsT colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.5)),
    );
  }

  Widget _buildTypeSelector(AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _typeTab('Pengeluaran', 'expense', colors),
          _typeTab('Pemasukan', 'income', colors),
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

  Widget _buildAmountCard(AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jumlah transaksi', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Rp', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.3)),
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

  Widget _buildCategoryDropdown(AsyncValue<List<Category>> categoriesAsync, AppColorsT colors) {
    return categoriesAsync.when(
      data: (categories) {
        final filtered = _type == 'income'
            ? categories.where((c) => c.type == 'income').toList()
            : categories.where((c) => c.type == 'expense').toList();
        if (filtered.isEmpty) {
          return _dropdownShell(Icons.category_outlined, 'Belum ada kategori', colors);
        }
        return _dropdownShell(
          Icons.category_outlined,
          null,
          colors,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: filtered.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
              isExpanded: true,
              dropdownColor: colors.surface,
              hint: Text('Pilih kategori', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13)),
              items: filtered.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name, style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: AppColors.gold),
      error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
    );
  }

  Widget _buildAccountDropdown(AsyncValue<List<Account>> accountsAsync, AppColorsT colors) {
    return accountsAsync.when(
      data: (accounts) {
        final active = accounts.where((a) => !a.isArchived).toList();
        if (active.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/add-account'),
            child: _dropdownShell(Icons.account_balance_wallet_outlined, 'Belum ada akun · Tambah', colors),
          );
        }
        return _dropdownShell(
          Icons.account_balance_wallet_outlined,
          null,
          colors,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: active.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null,
              isExpanded: true,
              dropdownColor: colors.surface,
              hint: Text('Pilih akun', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13)),
              items: active.map((a) => DropdownMenuItem(
                value: a.id,
                child: Text('${a.name} • ${a.currencyCode}', style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(color: AppColors.gold),
      error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
    );
  }

  Widget _buildDateField(AppColorsT colors) {
    return GestureDetector(
      onTap: _pickDate,
      child: _dropdownShell(
        Icons.calendar_today_outlined,
        DateFormat('dd MMMM yyyy • HH:mm').format(_selectedDate),
        colors,
      ),
    );
  }

  Widget _buildNoteField(AppColorsT colors) {
    return _dropdownShell(
      Icons.notes_outlined,
      null,
      colors,
      child: TextField(
        controller: _noteCtrl,
        style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Makan malam bersama keluarga',
          hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 12),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _dropdownShell(IconData icon, String? text, AppColorsT colors, {Widget? child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: child ?? Text(text ?? '', style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
          ),
          Icon(Icons.chevron_right, size: 18, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildTransferSection(AsyncValue<List<Account>> accountsAsync, AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Atur transfer antar akun', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _transferChip('Dari', _selectedAccountId, accountsAsync, colors),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: colors.textSecondary, size: 18),
              ),
              _transferChip('Ke', null, accountsAsync, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transferChip(String label, String? value, AsyncValue<List<Account>> accountsAsync, AppColorsT colors) {
    String accountName = 'Pilih akun';
    if (value != null && accountsAsync.hasValue) {
      final match = accountsAsync.value!.where((a) => a.id == value);
      if (match.isNotEmpty) accountName = match.first.name;
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.primaryDark.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
            const SizedBox(height: 2),
            Text(accountName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppColorsT colors) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: _saving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Simpan transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
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

    setState(() => _saving = true);
    try {
      final service = ref.read(transactionServiceProvider);
      if (_type == 'income') {
        await service.addIncome(
          accountId: _selectedAccountId!, categoryId: _selectedCategoryId, amount: amount,
          currencyCode: currencyCode, description: description, date: _selectedDate,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );
      } else {
        await service.addExpense(
          accountId: _selectedAccountId!, categoryId: _selectedCategoryId, amount: amount,
          currencyCode: currencyCode, description: description, date: _selectedDate,
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