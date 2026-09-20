import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.movie_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
  };

  static const _categoryBgColors = <String, Color>{
    'makan': Color(0xFFE1F1EA),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFE1F1EA),
    'kesehatan': Color(0xFFFBE7E7),
    'pendidikan': Color(0xFFE8F0FA),
  };

  static const _categoryFgColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF1B6E4B),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
  };

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    final accountsAsync = ref.watch(accountsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(colors),
              const SizedBox(height: 20),
              _buildAmountCard(colors),
              const SizedBox(height: 24),
              _buildCategoryRow(categoriesAsync, colors),
              const SizedBox(height: 20),
              _buildAccountSelector(accountsAsync, colors),
              const SizedBox(height: 16),
              _buildDateField(colors),
              const SizedBox(height: 16),
              _buildTextField('Deskripsi / Untuk apa', _descriptionCtrl, Icons.description_outlined, colors, hint: 'Contoh: Nasi Padang Siang'),
              const SizedBox(height: 12),
              _buildTextField('Catatan (opsional)', _noteCtrl, Icons.note_outlined, colors, hint: 'Contoh: Dibayar pakai QRIS', maxLines: 2),
              const SizedBox(height: 28),
              _buildSaveButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppColorsT colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _typeTab('Pengeluaran', 'expense', AppColors.rose, colors)),
          Expanded(child: _typeTab('Pemasukan', 'income', AppColors.teal, colors)),
        ],
      ),
    );
  }

  Widget _typeTab(String label, String type, Color activeColor, AppColorsT colors) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() { _type = type; _selectedCategoryId = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : colors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildAmountCard(AppColorsT colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _type == 'expense'
              ? [const Color(0xFFE0524A), const Color(0xFFC7423B)]
              : [const Color(0xFF1B6E4B), const Color(0xFF0F5A3C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(_type == 'expense' ? 'Pengeluaran' : 'Pemasukan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rp', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(AsyncValue<List<Category>> categoriesAsync, AppColorsT colors) {
    return categoriesAsync.when(
      data: (categories) {
        final filtered = _type == 'income'
            ? categories.where((c) => c.type == 'income').toList()
            : categories.where((c) => c.type == 'expense').toList();

        if (filtered.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final cat = filtered[i];
                  final selected = _selectedCategoryId == cat.id;
                  final key = cat.name.toLowerCase();
                  IconData icon = Icons.receipt_long_rounded;
                  Color bg = const Color(0xFFE1F1EA);
                  Color fg = const Color(0xFF1B6E4B);
                  for (final entry in _categoryIcons.entries) {
                    if (key.contains(entry.key)) {
                      icon = entry.value;
                      bg = _categoryBgColors[entry.key] ?? bg;
                      fg = _categoryFgColors[entry.key] ?? fg;
                      break;
                    }
                  }
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = selected ? null : cat.id),
                    child: Column(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: selected ? fg : bg,
                            borderRadius: BorderRadius.circular(14),
                            border: selected ? Border.all(color: fg, width: 2) : null,
                          ),
                          child: Icon(icon, color: selected ? Colors.white : fg, size: 22),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(cat.name, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
    );
  }

  Widget _buildAccountSelector(AsyncValue accountsAsync, AppColorsT colors) {
    return accountsAsync.when(
      data: (accounts) {
        final active = accounts.where((a) => !a.isArchived).toList();
        if (active.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 18, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text('Belum ada akun · ', style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
                GestureDetector(
                  onTap: () => context.push('/add-account'),
                  child: Text('Tambah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
                ),
              ],
            ),
          );
        }
        final validAccountId = active.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : null;
        return _formField(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validAccountId,
              isExpanded: true,
              dropdownColor: colors.surface,
              hint: Text('Pilih Akun', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 13)),
              items: active.map((a) => DropdownMenuItem(
                value: a.id,
                child: Text('${a.name} (${a.currencyCode})', style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13)),
              )).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
          ),
          icon: Icons.account_balance_wallet_outlined,
          colors: colors,
          label: 'Akun',
        );
      },
      loading: () => const LinearProgressIndicator(color: AppColors.gold),
      error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AppColors.rose)),
    );
  }

  Widget _buildDateField(AppColorsT colors) {
    return _formField(
      child: GestureDetector(
        onTap: _pickDate,
        child: Text(DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDate), style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
      ),
      icon: Icons.calendar_today_outlined,
      colors: colors,
      label: 'Tanggal & Waktu',
      trailing: true,
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, AppColorsT colors, {String? hint, int maxLines = 1}) {
    return _formField(
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: colors.textSecondary, fontSize: 12),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
      icon: icon,
      colors: colors,
      label: label,
    );
  }

  Widget _formField({required Widget child, required IconData icon, required AppColorsT colors, required String label, bool trailing = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: colors.textSecondary)),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          if (trailing) Icon(Icons.chevron_right, size: 18, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppColorsT colors) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: _saving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: _type == 'expense' ? AppColors.rose : AppColors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Simpan Transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
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