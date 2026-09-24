import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/core/widgets/app_widgets.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/l10n/app_localizations.dart';
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

  // (systemKey | null, fallback name, emoji, color) — systemKey reuses default-category l10n.
  static const _presets = [
    ('food_drink', 'Makanan', '🍜', AppColors.rose),
    ('transport', 'Transport', '🚗', AppColors.sky),
    ('shopping', 'Belanja', '🛒', AppColors.lilac),
    ('utilities', 'Tagihan', '💡', AppColors.rose),
    ('entertainment', 'Hiburan', '🎮', AppColors.lilac),
    ('health', 'Kesehatan', '🏥', AppColors.teal),
    ('education', 'Pendidikan', '📚', AppColors.orange),
    ('salary', 'Gaji', '💼', AppColors.teal),
    (null, 'Freelance', '💻', AppColors.sky),
    ('investment', 'Investasi', '📈', AppColors.lilac),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.add} ${l10n.categories}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.type, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _typeButton(l10n.expense, 'expense', AppColors.rose)),
                const SizedBox(width: 12),
                Expanded(child: _typeButton(l10n.income, 'income', AppColors.teal)),
              ],
            ),
            const SizedBox(height: 24),

            Text(l10n.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.inter(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: localizedCategoryName(l10n, 'food_drink', 'Makanan & Minuman'),
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
                final label = localizedCategoryName(l10n, p.$1, p.$2);
                return GestureDetector(
                  onTap: () => _nameCtrl.text = label,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: p.$4.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.$4.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.$3, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(label, style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary)),
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
                    : Text(l10n.save, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
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
