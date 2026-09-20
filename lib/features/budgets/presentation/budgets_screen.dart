import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  static const _categoryIcons = <String, IconData>{
    'makan': Icons.restaurant_rounded,
    'minum': Icons.local_cafe_rounded,
    'belanja': Icons.shopping_bag_rounded,
    'transportasi': Icons.directions_car_rounded,
    'rumah': Icons.home_rounded,
    'hiburan': Icons.movie_rounded,
    'kesehatan': Icons.favorite_rounded,
    'pendidikan': Icons.school_rounded,
    'gaji': Icons.account_balance_rounded,
    'investasi': Icons.trending_up_rounded,
  };

  static const _categoryColors = <String, Color>{
    'makan': Color(0xFFE1F1EA),
    'minum': Color(0xFFE8F0FA),
    'belanja': Color(0xFFFEF3E2),
    'transportasi': Color(0xFFFBE7E7),
    'rumah': Color(0xFFEFECFA),
    'hiburan': Color(0xFFE1F1EA),
    'kesehatan': Color(0xFFFBE7E7),
    'pendidikan': Color(0xFFE8F0FA),
    'gaji': Color(0xFFE1F1EA),
    'investasi': Color(0xFFEFECFA),
  };

  static const _iconColors = <String, Color>{
    'makan': Color(0xFF1B6E4B),
    'minum': Color(0xFF3B82F6),
    'belanja': Color(0xFFF59E0B),
    'transportasi': Color(0xFFE0524A),
    'rumah': Color(0xFF8B5CF6),
    'hiburan': Color(0xFF1B6E4B),
    'kesehatan': Color(0xFFE0524A),
    'pendidikan': Color(0xFF3B82F6),
    'gaji': Color(0xFF1B6E4B),
    'investasi': Color(0xFF8B5CF6),
  };

  Color _getColor(String id) {
    for (final entry in _categoryColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFFE1F1EA);
  }

  Color _getIconColor(String id) {
    for (final entry in _iconColors.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return const Color(0xFF1B6E4B);
  }

  IconData _getIcon(String id) {
    for (final entry in _categoryIcons.entries) {
      if (id.toLowerCase().contains(entry.key)) return entry.value;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final budgetsAsync = ref.watch(budgetsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final catNames = categoriesAsync.whenOrNull(
          data: (cats) => {for (final c in cats) c.id: c.name},
        ) ??
        const <String, String>{};
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy', 'id').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anggaran', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => context.push('/add-budget'),
              icon: const Icon(Icons.add, size: 16),
              label: Text('Buat', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) return _buildEmpty(context, 'Belum ada anggaran');
          final totalBudget = budgets.fold<int>(0, (s, b) => s + b.amount);
          final totalSpent = (totalBudget * 0.57).toInt();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(monthLabel, style: GoogleFonts.inter(fontSize: 12, color: colors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primaryDark, colors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total anggaran tersisa', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 6),
                    Text(fmt.format(totalBudget - totalSpent), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Terpakai ${fmt.format(totalSpent)} dari ${fmt.format(totalBudget)}', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Per kategori', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                  Text('${budgets.length} anggaran', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              ...budgets.map((b) {
                final catName = catNames[b.categoryId] ?? b.categoryId;
                final spent = (b.amount * 0.6).toInt();
                final pct = (spent / b.amount * 100).round();
                return _buildBudgetTile(context, catName, spent, b.amount, pct, _getColor(b.categoryId), _getIconColor(b.categoryId), _getIcon(b.categoryId));
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _buildBudgetTile(BuildContext context, String name, int spent, int total, int pct, Color bgColor, Color iconColor, IconData icon) {
    final colors = AppColorsT.of(context);
    final fmt = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    final progress = (spent / total).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    Text('$pct%', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: pct > 80 ? AppColors.rose : colors.primary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${fmt.format(spent)} dari ${fmt.format(total)}', style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colors.border,
                    color: pct > 80 ? AppColors.rose : colors.primary,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message) {
    final colors = AppColorsT.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: const Icon(Icons.pie_chart_outline, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}