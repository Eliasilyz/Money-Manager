import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  AppColorsT get colors => AppColorsT.of(context);
  final _nameCtrl = TextEditingController();
  String _type = 'expense';
  bool _saving = false;

  static const _presets = [
    ('Makanan', '🍜', AppColors.rose),
    ('Transport', '🚗', AppColors.sky),
    ('Belanja', '🛒', AppColors.lilac),
    ('Tagihan', '💡', AppColors.rose),
    ('Hiburan', '🎮', AppColors.lilac),
    ('Kesehatan', '🏥', AppColors.teal),
    ('Pendidikan', '📚', AppColors.orange),
    ('Gaji', '💼', AppColors.teal),
    ('Freelance', '💻', AppColors.sky),
    ('Investasi', '📈', AppColors.lilac),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Kategori', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('TIPE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _typeButton('Pengeluaran', 'expense', AppColors.rose)),
                const SizedBox(width: 12),
                Expanded(child: _typeButton('Pemasukan', 'income', AppColors.teal)),
              ],
            ),
            const SizedBox(height: 24),

            Text('NAMA KATEGORI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.inter(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: Makanan & Minuman',
                prefixIcon: Icon(Icons.label_outline, color: colors.textSecondary),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),

            Text('CEPAT TAMBAH', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                return GestureDetector(
                  onTap: () => _nameCtrl.text = p.$1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: p.$3.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.$3.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.$2, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(p.$1, style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Simpan Kategori', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String label, String value, Color color) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? color : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nama kategori', style: GoogleFonts.inter())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final category = Category(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(categoriesNotifierProvider.notifier).addCategory(category);
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
